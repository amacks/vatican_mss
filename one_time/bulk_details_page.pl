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
$| = 1; ## no buffering

## for the storage engine
use DBD::mysql;
use DBI qw(:sql_types);

use File::Basename;
use lib dirname($0) . "/../lib/";
use Vatican::Config;
use Vatican::DB;
use Vatican::Detail;

my $config = new Vatican::Config();
my $ms_table = $config->ms_table();
my $ms_count=0;
## connect to a DB
my $vatican_db = new Vatican::DB();
my $dbh=$vatican_db->get_insert_dbh();
## now prepare a handle for the statement
my $report_stmt = " select shelfmark from manuscripts 
where details_page is null and high_quality=1 
limit 1000";
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
	my $detail = new Vatican::Detail(shelfmark => $row->{'shelfmark'});
	$detail->process_description_html();
	if (defined($detail->detail_page_exists())){
		$detail->store_details();
	}
	#warn ($detail->get_detail_count() . " " . $detail->get_bib_count());
	#warn Dumper($row);
}
$sth->finish();
$dbh->disconnect();
