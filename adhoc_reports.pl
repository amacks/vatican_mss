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

## constants
my $base_url="https://digi.vatlib.it/mss";
my $ms_base_url = "https://digi.vatlib.it/view/MSS_";
my @collections=("Autogr.Paolo.VI","Barb.gr","Barb.lat","Barb.or","Bonc","Borg.Carte.naut","Borg.ar","Borg.arm","Borg.cin","Borg.copt","Borg.ebr","Borg.eg","Borg.et","Borg.gr","Borg.ill","Borg.ind","Borg.isl","Borg.lat","Borg.mess","Borg.pers","Borg.sir","Borg.tonch","Borg.turc","Borgh","Capp.Giulia","Capp.Sist","Capp.Sist.Diari","Cappon","Carte.Stefani","Carte.d'Abbadie","Cerulli.et","Cerulli.pers","Chig","Comb","De.Marinis","Ferr","Legat","Neofiti","Ott.gr","Ott.lat","P.I.O","Pagès","Pal.gr","Pal.lat","Pap.Bodmer","Pap.Hanna","Pap.Vat.copt","Pap.Vat.gr","Pap.Vat.lat","Patetta","Raineri","Reg.gr","Reg.gr.Pio.II","Reg.lat","Ross","Ruoli","S.Maria.Magg","S.Maria.in.Via.Lata","Sbath","Sire","Urb.ebr","Urb.gr","Urb.lat","Vat.ar","Vat.arm","Vat.copt","Vat.ebr","Vat.estr.or","Vat.et","Vat.gr","Vat.iber","Vat.ind","Vat.lat","Vat.mus","Vat.pers","Vat.sam","Vat.sir","Vat.slav","Vat.turc");
my $DEBUG=0;

my $url_prefix="vatican";
my $report_infix = 'adhoc';

## for the database
my $results_stmt_skel = "select shelfmark, title, author, incipit, notes, thumbnail_url, date_added, lq_date_added, high_quality, date
from
(select 
 ms1.shelfmark as shelfmark, 
 ms1.high_quality as high_quality, 
 ms1.date_added as date_added, 
 ms2.date_added as lq_date_added,
 ms1.title as title,
 ms1.author as author,
 ms1.incipit as incipit,
 ms1.notes as notes,
 ms1.thumbnail_url as thumbnail_url,
 ms1.date as date,
 ms1.sort_shelfmark from 
__MS_TABLE__ as ms1 left join __MS_TABLE__ as ms2
on ms1.shelfmark=ms2.shelfmark AND ms1.id>ms2.id) as hq_lq
 where
__QUERY__
ORDER by sort_shelfmark asc";

my $header_stmt = "select header_text, short_title, footer_text, query, filename from adhoc_reports where enabled=1";


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

sub get_mss_listing{
	my $query = shift;
	## get the DB configs
	my $ms_table = $config->ms_table();
	## connect to a DB
	my $vatican_db = new Vatican::DB();
	my $dbh=$vatican_db->get_generate_dbh();
## make a copy and prepare the statement
	my $results_stmt = $results_stmt_skel;
	$results_stmt =~ s/__MS_TABLE__/$ms_table/g;
	$results_stmt =~ s/__QUERY__/$query/g;
	my $sth = $dbh->prepare($results_stmt) or die "cannot prepare results statement: ". $dbh->errstr();
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

	my $sth = $dbh->prepare($header_stmt) or die "cannot prepare report statement: ". $dbh->errstr();
	## now do the query
	$sth->execute() or die "cannot run report: " . $sth->errstr();
	my $m = Text::Markdown->new;
	my $headers_data;
	while (my $header_data = $sth->fetchrow_hashref()){
		$header_data->{'header_text_html'} = $m->markdown($header_data->{'header_text'}) if (defined($header_data->{'header_text'}));
		$header_data->{'footer_text_html'} = $m->markdown($header_data->{'footer_text'}) if (defined($header_data->{'footer_text'}));
		push @$headers_data, $header_data;	
	}
	## now markdown it

	$sth->finish();
	$dbh->disconnect();
	return $headers_data;
}
sub format_mss_list{
	my ($mss_list, $header_data) = @_;
	if (!defined($mss_list) || (ref($mss_list) ne "ARRAY")){
		warn " format_mss_list requires an argument of an arrayref to a list of MS";
		return undef;
	} else {
		my $ms_count = $#{$mss_list}+1;
		for my $fieldname ("header_text_html", "footer_text_html"){
			if (defined($header_data->{$fieldname})){
				$header_data->{$fieldname} =~ s/\$NUMBER\$/$ms_count/g;				
			}
		}
		## setup the template system
		my %data = (
				'mss_list' => $mss_list,
				'ms_base_url' => $ms_base_url,
				'header_data' => $header_data,
				'url_prefix' => '/' . $url_prefix,
				'ms_count' => $ms_count,
			);
		my $output;
		my $tt = Template->new({
		    INCLUDE_PATH => 'tt',
		    INTERPOLATE  => 1,
		    ENCODING     => 'utf8',
		}) || die "$Template::ERROR\n";
		$tt->process("adhoc_listing.tt",
			\%data, \$output, {binmode => ':utf8'}
			)|| die $tt->error(), "\n";
    	return $output;
	}
}

## now actually run things!
warn "Getting reports listing";
my $reports_data = get_header_data();
if (!defined($filepath)){
	print "Warning: cannot export without filepath";
} else {
	## double check for directory
	my $subdirectory = $url_prefix . "/" . $report_infix; ## sits between the filesystem prefix and the filename
	if ( ! -d $filepath . '/' . $subdirectory ){
		mkdir($filepath . '/' . $subdirectory) or die "Cannot create $subdirectory";
	}

	foreach my $report (@{${reports_data}}) {
		my $uri = $subdirectory . '/' .$report->{'filename'} . ".html";
		my $filename = $filepath . '/' . $uri;
		$report->{'uri'} = $uri;
		warn "\tbuilding report $filename";

		my $formatted_html = format_mss_list(get_mss_listing($report->{'query'}), $report);

		open(OUTPUT_FILE, ">:utf8", $filename) or die "Could not open file '$filename'. $!";
		print OUTPUT_FILE $formatted_html;
		close(OUTPUT_FILE);
		## store the relevant info in the index-data array
	}
	## now build an index page
	my $index_filename = $filepath . '/' . $subdirectory . '/' .'index.html';
	warn "\tBuilding index $index_filename";
	#warn Dumper($reports_data);exit;
	my $tt = Template->new({
	    INCLUDE_PATH => 'tt',
	    INTERPOLATE  => 1,
	    ENCODING     => 'utf8',
	}) || die "$Template::ERROR\n";
	my $output;
	my $adhoc_index_data = {
		'url_prefix' => '/' . $url_prefix,
		'reports_data' => $reports_data
	};
	$tt->process("adhoc_index.tt",
		$adhoc_index_data, \$output, {binmode => ':utf8'}
		)|| die $tt->error(), "\n";
	open(OUTPUT_FILE, ">:utf8", $index_filename) or die "Could not open file '$index_filename'. $!";
	print OUTPUT_FILE $output;
	close(OUTPUT_FILE);
}
