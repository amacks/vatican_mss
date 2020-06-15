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
my $base_url="https://digi.vatlib.it/mss";
my $ms_base_url = "https://digi.vatlib.it/view/MSS_";
my @collections=("Autogr.Paolo.VI","Barb.gr","Barb.lat","Barb.or","Bonc","Borg.Carte.naut","Borg.ar","Borg.arm","Borg.cin","Borg.copt","Borg.ebr","Borg.eg","Borg.et","Borg.gr","Borg.ill","Borg.ind","Borg.isl","Borg.lat","Borg.mess","Borg.pers","Borg.sir","Borg.tonch","Borg.turc","Borgh","Capp.Giulia","Capp.Sist","Capp.Sist.Diari","Cappon","Carte.Stefani","Carte.d'Abbadie","Cerulli.et","Cerulli.pers","Chig","Comb","De.Marinis","Ferr","Legat","Neofiti","Ott.gr","Ott.lat","P.I.O","Pagès","Pal.gr","Pal.lat","Pap.Bodmer","Pap.Hanna","Pap.Vat.copt","Pap.Vat.gr","Pap.Vat.lat","Patetta","Raineri","Reg.gr","Reg.gr.Pio.II","Reg.lat","Ross","Ruoli","S.Maria.Magg","S.Maria.in.Via.Lata","Sbath","Sire","Urb.ebr","Urb.gr","Urb.lat","Vat.ar","Vat.arm","Vat.copt","Vat.ebr","Vat.estr.or","Vat.et","Vat.gr","Vat.iber","Vat.ind","Vat.lat","Vat.mus","Vat.pers","Vat.sam","Vat.sir","Vat.slav","Vat.turc");
my $DEBUG=0;
my $inital_load_end = '2018-01-21 21:06:15';

my $header = "";
my $footer = "";
my $url_prefix="/vatican";

## for the database
my $report_stmt = "select 
 ms1.shelfmark as shelfmark, 
 ms1.high_quality as high_quality, 
 ms1.date_added as date_added, 
 ms2.date_added as lq_date_added,
 ms1.title as title,
 ms1.author as author,
 ms1.incipit as incipit,
 ms1.notes as notes,
 ms1.thumbnail_url as thumbnail_url,
 ms1.date as date from 
__MS_TABLE__ as ms1 left join __MS_TABLE__ as ms2
on ms1.shelfmark=ms2.shelfmark AND ms1.id>ms2.id 
 where
(year(ms1.date_added) = ?) AND
(week(ms1.date_added,0)+1 = ?)
ORDER by ms1.sort_shelfmark asc";

my $header_stmt = "select header_text, image_filename, boundry_image_filename, previous_week_id, next_week_id from __NOTES_TABLE__ 
where  year=? and week_number=?  ";
my $links_stmt = "select year, week_number from __NOTES_TABLE__ where id=?  ";


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
	## get the DB configs
	my $ms_table = $config->ms_table();
	## connect to a DB
	my $vatican_db = new Vatican::DB();
	my $dbh=$vatican_db->get_generate_dbh();
## now prepare a handle for the statement
	$report_stmt =~ s/__MS_TABLE__/$ms_table/g;
	my $sth = $dbh->prepare($report_stmt) or die "cannot prepare report statement: ". $dbh->errstr();
	$sth->bind_param(1,$year, SQL_INTEGER);
	$sth->bind_param(2,$week_number, SQL_INTEGER);
	## now do the query
	$sth->execute() or die "cannot run report: " . $sth->errstr();
	my $manuscripts = [];
	my $m = Text::Markdown->new;
	while (my $row = $sth->fetchrow_hashref()){
	    for my $field ("notes"){
	    	if (defined $row->{$field}){ 
				$row->{$field . "_html"} = $m->markdown($row->{$field});
	    	}
	    }
	    push @$manuscripts, $row;
	}
	$sth->finish();
	$dbh->disconnect();
	return $manuscripts;
}

sub get_header_data{
	my $week_number = shift;
	my $year = shift;
	## get the DB configs
	my $notes_table = $config->notes_linked_table();
	## connect to a DB
	my $vatican_db = new Vatican::DB();
	my $dbh=$vatican_db->get_generate_dbh();
## now prepare a handle for the statement
	$header_stmt =~ s/__NOTES_TABLE__/$notes_table/g;
	$links_stmt =~ s/__NOTES_TABLE__/$notes_table/g;

	my $sth = $dbh->prepare($header_stmt) or die "cannot prepare report statement: ". $dbh->errstr();
	$sth->bind_param(1,$year, SQL_INTEGER);
	$sth->bind_param(2,$week_number, SQL_INTEGER);
	## now do the query
	$sth->execute() or die "cannot run report: " . $sth->errstr();
	my $header_data= $sth->fetchrow_hashref();
	## now markdown it
	my $m = Text::Markdown->new;
	$header_data->{'header_text_html'} = $m->markdown($header_data->{'header_text'});
	$sth->finish();
	## figure out the previous and next links
	my $link_sth = $dbh->prepare($links_stmt) or die "cannot prepare links statement: ". $dbh->errstr();
	## get the previous
	if (defined($header_data->{'previous_week_id'})){
		$link_sth->execute($header_data->{'previous_week_id'});
		my $row = $link_sth->fetchrow_hashref();
		if (defined($row)){
			$header_data->{'previous_link'} = $config->get_filename("/", $row->{'year'}, $row->{'week_number'});
		}
	}
	if (defined($header_data->{'next_week_id'})){
		$link_sth->execute($header_data->{'next_week_id'});
		my $row = $link_sth->fetchrow_hashref();
		if (defined($row)){
			$header_data->{'next_link'} = $config->get_filename("/", $row->{'year'}, $row->{'week_number'});
		}
	}
	$link_sth->finish();
	$dbh->disconnect();
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
				'ms_base_url' => $ms_base_url,
				'header_data' => $header_data,
				'url_prefix' => $url_prefix,
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
