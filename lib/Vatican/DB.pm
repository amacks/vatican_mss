#!/usr/bin/perl

package Vatican::DB;

use strict;
use Exporter;
use POSIX;
use POSIX qw(strftime);

use Data::Dumper;
use DBI;
use DBI qw(:sql_types);
use Encode;
use Moose;
use utf8;

use File::Basename;
use lib dirname($0) . "/";
use Vatican::Config;

## local constants
my $update_tn_stmt = "update __MS_TABLE__ set thumbnail_url=? where shelfmark=?";


has 'config' => (
	is => 'ro',
	isa => 'Vatican::Config'
	);



sub BUILD{
	my $this = shift;
	$this->{'config'} = Vatican::Config->new() or die "Cannot read config file";
}

## return a handle to the database system
sub get_generate_dbh{
	my $this = shift;
	my $config = $this->config();
	## connect to a DB

	my $dbh=DBI->connect_cached ("dbi:mysql:database=" . $config->db_name() .
		":host=" . $config->db_host(). ":port=3306'",
		$config->generate_database()->{'username'}, $config->generate_database()->{'password'}, 
		{RaiseError => 0, PrintError => 0, AutoCommit => 1, mysql_enable_utf8 => 1 }) 
	or die "Can't connect to the MySQL " . $config->db_host() . '-' . $config->db_name() .": $DBI::errstr\n";
    $dbh->{LongTruncOk} = 0;
    $dbh->do("SET OPTION SQL_BIG_TABLES = 1");
    $dbh->do('SET NAMES utf8');
    return $dbh;
}

sub get_insert_dbh{
	my $this = shift;
	my $config = $this->config();
	## connect to a DB

	my $dbh=DBI->connect_cached ("dbi:mysql:database=" . $config->db_name() .
		":host=" . $config->db_host(). ":port=3306'",
		$config->insert_database()->{'username'}, $config->insert_database()->{'password'}, 
		{RaiseError => 0, PrintError => 0, AutoCommit => 1, mysql_enable_utf8 => 1 }) 
	or die "Can't connect to the MySQL " . $config->db_host() . '-' . $config->db_name() .": $DBI::errstr\n";
    $dbh->{LongTruncOk} = 0;
    $dbh->do("SET OPTION SQL_BIG_TABLES = 1");
    $dbh->do('SET NAMES utf8');
   	return $dbh;
}

sub set_local_thumbnail {
	my $this = shift;
	my $shelfmark = shift;
	my $local_filename= shift;

	my $config = $this->config();
	my $year = get_time("%Y");
	my $ms_table = $config->ms_table();
	## update the master statement, this is per class 
	$update_tn_stmt =~ s/__MS_TABLE__/$ms_table/g;
	$update_tn_stmt =~ s/__YEAR__/$year/g;
	## set the full thumbnail_url
	my $thumbnail_uri = "/vatican/" . $year . "/thumbnails/" . $local_filename;
	my $dbh = $this->get_insert_dbh();
	my $update_sth = $dbh->prepare($update_tn_stmt) or warn "Cannot prepare statement: " . $dbh->errstr();
	$update_sth->bind_param(1, $thumbnail_uri, SQL_VARCHAR);
	$update_sth->bind_param(2, $shelfmark, SQL_VARCHAR);
	return $update_sth->execute();
}


## statics
sub get_time 
{
    my $format = $_[0] || '%Y%m%d %I:%M:%S %p'; #default format: 20160801 10:48:03 AM
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    return strftime($format, localtime);
}


1;