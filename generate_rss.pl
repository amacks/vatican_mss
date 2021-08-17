#!/usr/bin/perl -w 

use strict;
use POSIX;
use POSIX qw(strftime);
use Text::Markdown;
use Getopt::Long;
use DateTime;
use XML::RSS;

use Data::Dumper;
use Encode;
use utf8;
use Config::Simple;

## local tools
use File::Basename;
use lib dirname($0) . "/lib";
use Vatican::Config;
use Vatican::DB;
use Vatican::Manuscripts;
my $url_prefix;

## basic usage information
sub help(){
	print "$0 -- generate RSS feeds for the vatican listings:\n";
	print "\t --help - display this help\n";
	print "\t --verbose - make the output verbose\n";
	print "\t --filepath=<path> - directory to write the output rss feeds.  required.\n";
	print "\t --mss-limit=<integer> - number of manuscripts to include, optional value. default=200\n";
}

## handle parameters
my $filepath = undef; ## if defined, the root path where to output the file
my $verbose;
my $help;
my $mss_limit=200; ## default value
GetOptions(
		'verbose!'   => \$verbose,
		'filepath=s' => \$filepath,
		'help!'      => \$help,
		'mss-limit=i' => \$mss_limit);

if (!defined($filepath) || defined($help)){
	help();
	if ($help){
		exit 0;
	} else {
		print "--filepath is a required argument\n";
		exit 1;
	}
}

## start generating by loading in the most recent XX manuscripts
warn "Generating MSS feed" if ($verbose);
my $recent_mss = Vatican::Manuscripts->new(raw_sql=>'1 = 1', limit=>$mss_limit, order=>'date_added desc');
my $mss_count = $recent_mss->load_manuscripts();
warn "Loaded $mss_count manuscripts" if ($verbose);
my $post_process_count = $recent_mss->post_process_manuscripts();
warn "Post-processed $post_process_count manuscripts" if ($verbose);

