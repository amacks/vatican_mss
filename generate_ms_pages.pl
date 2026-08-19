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
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($ERROR);

use File::Basename;
use lib dirname($0) . "/lib/";
use Vatican::Config;
use Vatican::DB;
use Vatican::Manuscripts;
use Vatican::Entry;
use Vatican::Fonds;

## for the storage engine
use DBD::mysql;
use DBI qw(:sql_types);

## for formatting the output
use Template;

### handle arguments to set the offset values and decide if we're output to console or note
my $filepath = undef; ## if defined, the root path where to output the file
my $DEBUG_MODE=0;
my $days_ago_interval = 2;

GetOptions(
		'verbose' => \$DEBUG_MODE,
		'filepath=s' => \$filepath,
		'days=i' => \$days_ago_interval
	);

if ($DEBUG_MODE){
	Log::Log4perl->easy_init($INFO);
}
print "Generating single MS pages for the last $days_ago_interval days\n";

INFO "Writing to location ". $filepath;
my $config = new Vatican::Config();

## make sure we have all the relevant directories
my $fonds = Vatican::Fonds->new();
$fonds->load_fonds();
my $fond_listings = $fonds->get_fond_codes();
foreach my $fond (@{${fond_listings}}) {
	INFO "Checking directory for ". $fond;

	my $dir_path = $filepath . $config->prefix() . $config->mss_path() . '/' .$fond;
	if ( ! -d $dir_path){
		INFO " Making directory for ". $fond;
		mkdir($dir_path) or ERROR "Cannot create directory ". $dir_path;
	}
	## make an empty index page
	open(OUTPUT_FILE, ">:utf8", $dir_path . "/index.html") or die "Could not open file '${dir_path}/index.html'. $!";
	print OUTPUT_FILE "<html><title>No</title></html>";
	close(OUTPUT_FILE);
}

## now we get all the manuscripts

my $ms_table = $config->ms_table();
## connect to a DB
my $vatican_db = new Vatican::DB();
my $dbh=$vatican_db->get_generate_dbh();
INFO "Connected to Database for manuscripts";
my $mss;
if ($days_ago_interval > 0 ){
	my $days_ago_sql = "date_updated>=date_sub(now(), interval $days_ago_interval day)";
	INFO "where clause ". $days_ago_sql;
	$mss = Vatican::Manuscripts->new(raw_sql => $days_ago_sql);	
} else {
	INFO "Days ago 0, doing for all manuscripts";
	$mss = Vatican::Manuscripts->new(raw_sql => "hq_lq.ignore is false"); ## it's duplicative	
}

my $mss_count = $mss->load_manuscripts();
INFO "Manuscripts loaded: ". $mss_count;
$mss->post_process_manuscripts();
INFO "Manuscripts post processed";
my $tt = Template->new({
    INCLUDE_PATH => 'tt',
    INTERPOLATE  => 1,
    ENCODING     => 'utf8',
}) || die "$Template::ERROR\n";
## loop through the list of manuscripts, write an HTML file for each
$mss_count=0;
for my $ms (@{$mss->mss_list()}){
	my $ms_filepath = $filepath . $config->get_single_ms_uri($ms->{'fond_code'}, $ms->{'shelfmark'});
	## make a full description
	$ms->{'full_description'} = "Vatican MS: ". $ms->{'shelfmark'}. " ";
	$ms->{'full_description'} .= "Author: ". $ms->{'author'}. " " if defined($ms->{'author'});
	$ms->{'full_description'} .= "Title: ". $ms->{'title'}. " " if defined($ms->{'title'});
	$ms->{'full_description'} .= "Date: ". $ms->{'date'}. " " if defined($ms->{'date'});
	## add base url in the data elements
	$ms->{'ms_base_url'} = $config->ms_base_url();
	$ms->{'url_prefix'} = $config->prefix();

	INFO "Generating for ". $ms->{'shelfmark'};
	my $output;
	$tt->process("single_ms_page.tt",
		$ms, \$output, {binmode => ':utf8'}
		)|| die $tt->error(), "\n";
	INFO "writing to ". $ms_filepath;
	open(OUTPUT_FILE, ">:utf8", $ms_filepath ) or die "Could not open file '${ms_filepath}.html'. $!";
	print OUTPUT_FILE $output;
	close(OUTPUT_FILE);
	$mss_count++;
}
print "A total of $mss_count pages were generated\n";
