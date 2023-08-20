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
use Vatican::Fonds;


## for the storage engine
use DBD::mysql;
use DBI qw(:sql_types);

## for formatting the output
use Template;

## constants
my $base_url="https://digi.vatlib.it/mss";
my $ms_base_url = "https://digi.vatlib.it/view/MSS_";
my @collections;
my $DEBUG=0;

my $url_prefix="vatican";
my $fond_infix = 'fonds';

## for the database

### handle arguments to set the offset values and decide if we're output to console or note

my $filepath = undef; ## if defined, the root path where to output the file
GetOptions(
		'verbose' => \$DEBUG,
		'filepath=s' => \$filepath);

my $config = new Vatican::Config();

sub get_mss_listing{
	my $fond = shift;
	## get the DB configs
	my $ms_table = $config->ms_table();
	## connect to a DB
	my $vatican_db = new Vatican::DB();
	my $dbh=$vatican_db->get_generate_dbh();
	my $mss = Vatican::Manuscripts->new(where_fields => ['fond_code'], where_values => [$fond]);
	$mss->load_manuscripts();
	$mss->post_process_manuscripts();
	return $mss->mss_list();
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
		$tt->process("fond_listing.tt",
			\%data, \$output, {binmode => ':utf8'}
			)|| die $tt->error(), "\n";
    	return $output;
	}
}

## now actually run things!
warn "Getting Fond listing";
if (!defined($filepath)){
	print "Warning: cannot export without filepath";
} else {
	## double check for directory
	my $subdirectory = $url_prefix . "/" . $fond_infix; ## sits between the filesystem prefix and the filename
	if ( ! -d $filepath . '/' . $subdirectory ){
		mkdir($filepath . '/' . $subdirectory) or die "Cannot create $subdirectory";
	}
	## build out the fond object
	my $fonds = Vatican::Fonds->new();
	$fonds->load_fonds();
	my $fond_listings = $fonds->get_all_fond_data();
	foreach my $fond (@{${fond_listings}}) {
		my $uri = $subdirectory . '/' .$fond->{'code'} . ".html";
		my $filename = $filepath . '/' . $uri;
		$fond->{'uri'} = $uri;
		warn "\tbuilding fond ". $fond->{'code'} . " at $filename";
		## make a complete url for the image
		if (defined($fond->{'image_filename'})){
			$fond->{'image_complete_url'} = $config->url_hostname . $config->prefix() . '/' . 'fonds' .'/' . $fond->{'image_filename'};
		}

		my $formatted_html = format_mss_list(get_mss_listing($fond->{'code'}), $fond);

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
		'fond_listings' => $fond_listings
	};
	$tt->process("fond_index.tt",
		$adhoc_index_data, \$output, {binmode => ':utf8'}
		)|| die $tt->error(), "\n";
	open(OUTPUT_FILE, ">:utf8", $index_filename) or die "Could not open file '$index_filename'. $!";
	print OUTPUT_FILE $output;
	close(OUTPUT_FILE);
}
