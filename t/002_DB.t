use strict;
use warnings;
use Test::Simple tests => 10;
use JSON;
use Data::Dumper;

## to be tested
use lib "./lib";
use Vatican::Config;
use Vatican::DB;

my $db;
my $dbh;
my $sth;
ok (
	$db = Vatican::DB->new(), "new DB class object"
	);
ok (
	$dbh = $db->get_generate_dbh(), "get_generate_dbh runs"
	);
ok (
	ref($dbh) eq "DBI::db", "dbh is the proper type of object"
	);
ok (
	$sth = $dbh->prepare("select 1,2 from dual"), "prepare a statement"
	);
ok (
	ref($sth) eq "DBI::st", "sth is the proper type of object"
	);
ok(
	$sth->execute(), "sth can be executed"
	);
my @data;
ok (
	@data = $sth->fetchrow_array(), "was able to fetch data"
	);
ok (
	$data[0] == 1 && $data[1] == 2, "proper data returned"
	);
ok(
	$sth->finish(), "was able to close the statement"
	);
ok (
	$dbh->disconnect(), "was able to close the connection"
	);