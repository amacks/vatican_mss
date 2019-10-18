#!/usr/bin/perl -w 

use strict;
use POSIX;
use POSIX qw(strftime);
## for all the HTTP work
use Net::SSLeay;
## there's nothing to "use" but we need it installed for SSL to verify
use Mozilla::CA;
use LWP::UserAgent;
use LWP::Simple;
use Getopt::Long;

use HTML::TreeBuilder::XPath;
use Data::Dumper;
use Encode;
use utf8;

## for the storage engine
use DBD::mysql;
use DBI qw(:sql_types);

use File::Basename;
use lib dirname($0) . "/lib/";
use Vatican::Config;
use Vatican::DB;
my $filepath = undef; ## if defined, the root path where to output the file
GetOptions(
		'filepath=s' => \$filepath);

if (defined($filepath)){
	my $config = new Vatican::Config();
	my $ms_table = $config->ms_table();
	my $ms_count=0;
	## connect to a DB
	my $vatican_db = new Vatican::DB();
	my $dbh=$vatican_db->get_insert_dbh();
## now prepare a handle for the statement
	my $report_stmt = " select shelfmark, year(date_added) as year, thumbnail_url from manuscripts where thumbnail_url like 'http%' and high_quality=1 limit 1000";
	my $sth = $dbh->prepare($report_stmt) or die "cannot prepare thumbnail statement: ". $dbh->errstr();
	## now do the query
	$sth->execute() or die "cannot run report: " . $sth->errstr();
	while (my $row = $sth->fetchrow_hashref()){
		$ms_count++;
		if ($ms_count % 10 == 0){
			print ".";
		}
		if ($ms_count % 100 == 0){
			print $ms_count;
		}
		if ($ms_count % 800 == 0){
			print "\n";
		}
		#warn Dumper($row);
		my $local_filepath = $filepath . "/" . $row->{'year'} . '/thumbnails';
		my $local_filename =  $row->{'shelfmark'} . ".jpg";
		my $exists = undef;
		if (-e $local_filepath . "/". $local_filename) {
			warn "file $local_filename exists";
			$exists=1;
		}
		my $http_response = getstore($row->{'thumbnail_url'}, $local_filepath . '/' . $local_filename);
		if (defined($exists) or !is_error($http_response)){
			my $local_thumbnail_code = $vatican_db->set_local_thumbnail($row->{'shelfmark'}, $local_filename, $row->{'year'});
			if (!defined($local_thumbnail_code)){
				warn "Some sort of error setting the local thumbnail";
			}
		} else {
			warn "Some sort of error in downloading the image for " . $row->{'shelfmark'};
			warn $http_response;
		}
	}
	$sth->finish();
	$dbh->disconnect();

}
