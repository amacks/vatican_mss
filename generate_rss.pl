#!/usr/bin/perl -w 

use strict;
use POSIX;
use POSIX qw(strftime);
use Getopt::Long;
use DateTime;
use DateTime::Format::MySQL;
use Date::Calc qw( :all );
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
use Vatican::Entries;
my $url_prefix;

## basic usage information
sub help(){
	print "$0 -- generate RSS feeds for the vatican listings:\n";
	print "\t --help - display this help\n";
	print "\t --verbose - make the output verbose\n";
	print "\t --filepath=<path> - directory to write the output rss feeds.  required.\n";
	print "\t --mss-limit=<integer> - number of manuscripts to include, optional value. default=200\n";
}

## generates the feed of recent manuscripts.  takes 4 parameters, 
## a filepath and a filename, a count, and a verbose flag
sub generate_mss_feed($$$$){
	my ($filepath, $mss_filename, $mss_limit, $verbose) = @_;
	## filepath fixup.
	if ($filepath !~ /\/$/g){
		$filepath .= '/';
	}
	my $config = new Vatican::Config();



	## start generating by loading in the most recent XX manuscripts
	warn "Starting to generate MSS feed" if ($verbose);
	my $recent_mss = Vatican::Manuscripts->new(raw_sql=>'1 = 1', limit=>$mss_limit, order=>'date_added desc');
	my $mss_count = $recent_mss->load_manuscripts();
	warn " Loaded $mss_count manuscripts" if ($verbose);
	my $post_process_count = $recent_mss->post_process_manuscripts();
	warn " Post-processed $post_process_count manuscripts" if ($verbose);
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
	               docs           => 'http://www.rssboard.org/rss-specification',
	               managingEditor => 'vatican@wiglaf.org (Aaron Macks)',
	               webMaster      => 'vatican@wiglaf.org (Aaron Macks)'
	               );
	## now add things
	my $base_url = $config->url_hostname() ;
	for my $manuscript (@{$recent_mss->mss_list()}) {
		## build the description
		my $description = '';
		for my $field ("author", "title", "incipit"){
			if (defined($manuscript->{$field})){
				$description .= ucfirst($field) . ": ". $manuscript->{$field} . " ";
			}
		}
		if (defined($manuscript->{'notes_html'})){
			$description .= "Notes: ". $manuscript->{'notes_html'}
		}
		## URL
		my $complete_url = $base_url . $manuscript->{'entry_url'};
		## now include the image and link
		$description = build_description($description, $complete_url, 
			$manuscript->{'thumbnail_url'}, $manuscript->{'year'}, $manuscript->{'week'}
			);
		##generate a date
		my $mss_dt = DateTime::Format::MySQL->parse_datetime( $manuscript->{'date_added'} );
		$mss_rss->add_item(title => $manuscript->{'shelfmark'},
		    # creates a guid field with permaLink=true
		    link  => $complete_url,
		    # alternately creates a guid field with permaLink=false
		    permaLink => undef,
		    guid     =>  $manuscript->{'shelfmark'},
		    description => $description,
		    ##enclosure => {url=>$base_url . $manuscript->{'thumbnail_url'}, type => 'image/jpeg'},
		    pubDate => DateTime::Format::Mail->format_datetime($mss_dt)
		);
	}

	$mss_rss->save($filepath . $config->prefix() . '/' . $mss_filename);
	warn "done generating MSS Feed" if ($verbose);
}

## build a description for a weekly feed takes five args
## main text as html, url for the entry, image url, year and week ##
sub build_description($$$$$){
	my ($text_html, $url, $image_url, $year, $week) = @_;
	my $image_boilerplate = '<img alt="Entry Image" src="__URL__">';
	my $link_boilerplate = '<p>See all of the manuscripts for <a href="__URL__>Week __WEEK__ of __YEAR__</a>.</p>';
	## now assemble those boilerplates
	my $image_html ='';
	if (defined($image_url)){
		$image_html = $image_boilerplate;
		$image_html =~ s/__URL__/$image_url/g;		
	}
	my $link_html = $link_boilerplate;
	$link_html =~ s/__URL__/$url/g;
	$link_html =~ s/__WEEK__/$week/g;
	$link_html =~ s/__YEAR__/$year/g;
	return $image_html . $text_html . $link_html;
}

## generate a feed of recent weekly entries.  Takes 3 paremeters
## a filepath to write the file and an entry count. Final is Verbose flag
sub generate_weekly_feed($$$$){
	my ($filepath, $weekly_filename, $entry_count, $verbose) = @_;
	warn "Starting to generate weekly feed" if ($verbose);
	my $config = new Vatican::Config();
	my $entries = Vatican::Entries->new(order=>'year desc, week_number desc',
		limit => $entry_count, verbose=>$verbose);
    # create an RSS 2.0 file
	my $weekly_rss = XML::RSS->new (version => '2.0');
	my $base_url = $config->url_hostname() ;
	## get timestamp
	my $timestamp_str = DateTime::Format::Mail->format_datetime( DateTime->now() );

	$weekly_rss->channel(title          => 'Vatican Manuscript Weekly Reports',
	           link           => 'http://www.wiglaf.org/vatican/',
	           language       => 'en',
	           description    => 'Weekly reports on the most recently digitized manuscripts from the BAV',
	           ##pubDate        => 'Thu, 23 Aug 1999 07:00:00 GMT',
	           lastBuildDate  => $timestamp_str,
	           docs           => 'http://www.rssboard.org/rss-specification',
	           managingEditor => 'vatican@wiglaf.org (Aaron Macks)',
	           webMaster      => 'vatican@wiglaf.org (Aaron Macks)'
	           );


	for my $entry (@{$entries->entries_data()}){
		my $row = $entry->entry_data();
		if (defined($row->{'header_text'}) and ($row->{'header_text'} ne '')){
			$row->{'title'} = "Week " . $row->{'week_number'} . " of " . $row->{'year'};
			## make a url
			$row->{'entry_url'} = $config->get_filename('',$row->{'year'} ,$row->{'week_number'} );
			## make an image url
			if (defined($row->{'image_filename'})){
				$row->{'image_url'} = $base_url . $config->prefix() . '/' . $row->{'year'} . '/' . $row->{'image_filename'};
			}
			## assemble the HTML for the description
			my $description = build_description($row->{'header_text_html'}, 
				$row->{'entry_url'}, $row->{'image_url'}, $row->{'year'}, $row->{'week_number'});
			## figure out the right date
			my @friday_date = Add_Delta_Days(Monday_of_Week($row->{'week_number'}, $row->{'year'}),4);
			my $weekly_dt = DateTime->new( year => $friday_date[0], month => $friday_date[1], day => $friday_date[2] );
			$weekly_rss->add_item(title => $row->{'title'},
			    # creates a guid field with permaLink=true
			    permaLink  => $base_url . $row->{'entry_url'},
			    # alternately creates a guid field with permaLink=false
			    description => $description,
			    ##enclosure => {url=>$row->{'image_url'}, type => 'image/jpeg'},
			    pubDate => DateTime::Format::Mail->format_datetime($weekly_dt)
			);
		}
	}
	$weekly_rss->save($filepath . $config->prefix() . '/'. $weekly_filename);
	warn "Done generating weekly feed" if ($verbose);
}

### now actually do things

## handle parameters
my $filepath = undef; ## if defined, the root path where to output the file
my $verbose;
my $help;
my $mss_limit=200; ## default value
my $mss_filename = "manuscripts.rss";
my $weekly_filename = "weekly.rss";
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
generate_mss_feed($filepath, $mss_filename, $mss_limit, $verbose);
warn "------" if ($verbose);
generate_weekly_feed($filepath, $weekly_filename, 20, $verbose);