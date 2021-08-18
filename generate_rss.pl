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
my $mss_filename = "manuscripts.rss";
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
## filepath fixup.
if ($filepath !~ /\/$/g){
	$filepath .= '/';
}
my $config = new Vatican::Config();



## start generating by loading in the most recent XX manuscripts
warn "Generating MSS feed" if ($verbose);
my $recent_mss = Vatican::Manuscripts->new(raw_sql=>'1 = 1', limit=>$mss_limit, order=>'date_added desc');
my $mss_count = $recent_mss->load_manuscripts();
warn "Loaded $mss_count manuscripts" if ($verbose);
my $post_process_count = $recent_mss->post_process_manuscripts();
warn "Post-processed $post_process_count manuscripts" if ($verbose);
## now create an rss2 file
 # create an RSS 2.0 file
 my $mss_rss = XML::RSS->new (version => '2.0');
 ## get timestamp
 my $timestamp_str = DateTime::Format::Mail->format_datetime( DateTime->now() );

 $mss_rss->channel(title          => 'Recent Vatican Manuscripts',
               link           => 'http://www.wiglaf.org/vatican/',
               language       => 'en',
               description    => 'The most recently digitized manuscripts from the Vatican Library',
               ##pubDate        => 'Thu, 23 Aug 1999 07:00:00 GMT',
               lastBuildDate  => $timestamp_str,
               docs           => 'http://www.blahblah.org/fm.cdf',
               managingEditor => 'vatican@wiglaf.org (Aaron Macks)',
               webMaster      => 'vatican@wiglaf.org (Aaron Macks)'
               );
## now add things
my $base_url = $config->url_hostname() ;
for my $manuscript (@{$recent_mss->mss_list()}) {
	## build the description
	my $description = '';
	for my $field ("author", "title", "incipit", "notes"){
		if (defined($manuscript->{$field})){
			$description .= ucfirst($field) . ": ". $manuscript->{$field} . " ";
		}
	}

	$mss_rss->add_item(title => $manuscript->{'shelfmark'},
	    # creates a guid field with permaLink=true
	    link  => $base_url . $config->prefix . "/" . $manuscript->{'entry_url'},
	    # alternately creates a guid field with permaLink=false
	    permaLink => undef,
	    guid     =>  $manuscript->{'shelfmark'},
	    description => $description,
	    enclosure => {url=>$base_url . $manuscript->{'thumbnail_url'}, type => 'image/jpeg'}
	);
}

print $mss_rss->save($filepath . $mss_filename);