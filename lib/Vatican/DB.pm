#!/usr/bin/perl

package Vatican::DB;

use strict;
use Exporter;

use Data::Dumper;
use DBI;
use Encode;
use Moose;
use utf8;

use File::Basename;
use lib dirname($0) . "/";
use Vatican::Config;

has 'config' => (
	is => 'ro',
	isa => 'Vatican::Config'
	);

sub BUILD{
	my $this = shift;
	$this->{'config'} = Vatican::Config->new() or die "Cannot read config file";
}

## return a handle to the database system
sub get_generate_dbh(){
	my $this = shift;
	my $config = $this->config();
	## connect to a DB

	my $dbh=DBI->connect ("dbi:mysql:database=" . $config->db_name() .
		":host=" . $config->db_host(). ":port=3306'",
		$config->generate_database()->{'username'}, $config->generate_database()->{'password'}, 
		{RaiseError => 0, PrintError => 0, AutoCommit => 1, mysql_enable_utf8 => 1 }) 
	or die "Can't connect to the MySQL " . $config->db_host() . '-' . $config->db_name() .": $DBI::errstr\n";
    $dbh->{LongTruncOk} = 0;
    $dbh->do("SET OPTION SQL_BIG_TABLES = 1");
    $dbh->do('SET NAMES utf8');
   	return $dbh;
}

sub get_insert_dbh(){
	my $this = shift;
	my $config = $this->config();
	## connect to a DB

	my $dbh=DBI->connect ("dbi:mysql:database=" . $config->db_name() .
		":host=" . $config->db_host(). ":port=3306'",
		$config->generate_database()->{'username'}, $config->generate_database()->{'password'}, 
		{RaiseError => 0, PrintError => 0, AutoCommit => 1, mysql_enable_utf8 => 1 }) 
	or die "Can't connect to the MySQL " . $config->db_host() . '-' . $config->db_name() .": $DBI::errstr\n";
    $dbh->{LongTruncOk} = 0;
    $dbh->do("SET OPTION SQL_BIG_TABLES = 1");
    $dbh->do('SET NAMES utf8');
   	return $dbh;
}


1;