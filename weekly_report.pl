#!/usr/bin/perl -w 

use strict;
use POSIX;
use POSIX qw(strftime);
use Text::Markdown;
use Getopt::Long;
use DateTime;
use Config::Simple;

use Data::Dumper;
use Encode;
use utf8;

use File::Basename;
use lib dirname($0) . "/lib/";
use Vatican::Config;
use Vatican::DB;
use Vatican::Manuscripts;
use Vatican::Entry;

## for the storage engine
use DBD::mysql;
use DBI qw(:sql_types);

## for formatting the output
use Template;

## timestamp formatting from 
##https://stackoverflow.com/questions/2149532/how-can-i-format-a-timestamp-in-perl
sub get_time 
{
    my $format = $_[0] || '%Y%m%d %I:%M:%S %p'; #default format: 20160801 10:48:03 AM
    return strftime($format, localtime);
}

sub get_week_and_year(){
	my $offset_date = DateTime->now();
	my ($week_year, $week_number) = $offset_date->week;
	return (
		$week_year,
		$week_number,
	);
}
## constants
my $today_timestamp = get_time('%Y_%m_%d');
my $ms_base_url;
my @collections=("Autogr.Paolo.VI","Barb.gr","Barb.lat","Barb.or","Bonc","Borg.Carte.naut","Borg.ar","Borg.arm","Borg.cin","Borg.copt","Borg.ebr","Borg.eg","Borg.et","Borg.gr","Borg.ill","Borg.ind","Borg.isl","Borg.lat","Borg.mess","Borg.pers","Borg.sir","Borg.tonch","Borg.turc","Borgh","Capp.Giulia","Capp.Sist","Capp.Sist.Diari","Cappon","Carte.Stefani","Carte.d'Abbadie","Cerulli.et","Cerulli.pers","Chig","Comb","De.Marinis","Ferr","Legat","Neofiti","Ott.gr","Ott.lat","P.I.O","Pagès","Pal.gr","Pal.lat","Pap.Bodmer","Pap.Hanna","Pap.Vat.copt","Pap.Vat.gr","Pap.Vat.lat","Patetta","Raineri","Reg.gr","Reg.gr.Pio.II","Reg.lat","Ross","Ruoli","S.Maria.Magg","S.Maria.in.Via.Lata","Sbath","Sire","Urb.ebr","Urb.gr","Urb.lat","Vat.ar","Vat.arm","Vat.copt","Vat.ebr","Vat.estr.or","Vat.et","Vat.gr","Vat.iber","Vat.ind","Vat.lat","Vat.mus","Vat.pers","Vat.sam","Vat.sir","Vat.slav","Vat.turc");
my $DEBUG=0;
my $inital_load_end = '2018-01-21 21:06:15';

my $header = "";
my $footer = "";
my $url_prefix;


### handle arguments to set the offset values and decide if we're output to console or note
my $week_number;
my $year;
my $today;
my $filepath = undef; ## if defined, the root path where to output the file
GetOptions(
		'week=i' => \$week_number,
		'year=i' => \$year,
		'today' => \$today,
		'filepath=s' => \$filepath);


## handle today flag
if (defined($today)){
	($year, $week_number) = get_week_and_year();
}

my $config = new Vatican::Config();
warn "Processing Week: ". $week_number . " of year ". $year;

sub get_mss_interval{
	my $week_number = shift;
	my $year = shift;
	my $mss = Vatican::Manuscripts->new(year=>$year, week=>$week_number);
	$mss->load_manuscripts();
	$mss->post_process_manuscripts();
	return $mss->mss_list();
}

sub get_header_data{
	my $week_number = shift;
	my $year = shift;
	my $entry = Vatican::Entry->new(week_number=>$week_number, year=>$year);
	my $header_data = $entry->entry_data();
	## figure out the previous and next links
	if (defined($header_data->{'previous_week_id'})){
		$header_data->{'previous_link'} = $config->get_filename("", $header_data->{'previous_week_year'}, $header_data->{'previous_week_week_number'});
	}
	if (defined($header_data->{'next_week_id'})){
		$header_data->{'next_link'} = $config->get_filename("", $header_data->{'next_week_year'}, $header_data->{'next_week_week_number'});
	}
	## calculate the complete url for the image.
	if (defined($header_data->{'image_filename'})){
		$header_data->{'image_complete_url'} = $config->url_hostname . $config->prefix() . '/' . $year .'/' . $header_data->{'image_filename'};
	}
	##warn Dumper($header_data);
	return $header_data;
}
sub format_mss_list{
	my ($mss_list, $header_data) = @_;
	if (!defined($mss_list) || (ref($mss_list) ne "ARRAY")){
		warn " format_mss_list requires an argument of an arrayref to a list of MS";
		return undef;
	} else {
		## setup the template system
		my %data = (
				'mss_list' => $mss_list,
				'datestamp_parts' => { 'week' => $week_number, 'year' => $year},
				'ms_base_url' => $config->ms_base_url(),
				'header_data' => $header_data,
				'url_prefix' => $config->prefix(),
				'ms_count' => $#{$mss_list}+1,
			);
		my $output;
		my $tt = Template->new({
		    INCLUDE_PATH => 'tt',
		    INTERPOLATE  => 1,
		    ENCODING     => 'utf8',
		}) || die "$Template::ERROR\n";
		$tt->process("weekly_listing.tt",
			\%data, \$output, {binmode => ':utf8'}
			)|| die $tt->error(), "\n";
    	return $header . $output .$footer;
	}
}

## now actually run things!
my $formatted_html = format_mss_list(get_mss_interval($week_number, $year),get_header_data($week_number, $year));
if (!defined($filepath)){
	print $formatted_html;
} else {
	my $filename = $config->get_filename($filepath,$year,$week_number);

	warn "writing to $filename";
	open(OUTPUT_FILE, ">:utf8", $filename) or die "Could not open file '$filename'. $!";
	print OUTPUT_FILE $formatted_html;
	close(OUTPUT_FILE);
}
