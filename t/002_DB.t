use strict;
use warnings;
use Test::More tests => 36;
use JSON;
use Data::Dumper;

## to be tested
use lib "./lib";

BEGIN {
 use_ok('Vatican::Config'); 
 use_ok('Vatican::DB'); 
}

my $db;
my $dbh;
my $sth;
my $insert_dbh;
ok (
	$db = Vatican::DB->new(), "new DB class object"
	);
ok (
	$dbh = $db->get_generate_dbh(), "get_generate_dbh runs"
	);
isa_ok (
	ref($dbh), "DBI::db", "dbh is the proper type of object"
	);
ok (
	$insert_dbh = $db->get_insert_dbh(), "get_insert_dbh runs"
	);
isa_ok (
	ref($insert_dbh), "DBI::db", "insert_dbh is the proper type of object"
	);
ok (
	$insert_dbh eq $db->get_insert_dbh(), "insert_dbh is properly cached"
	);
ok (
	$sth = $dbh->prepare("select 1,2 from dual"), "prepare a statement"
	);
is (
	ref($sth), "DBI::st", "sth is the proper type of object"
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
## test the static routines for generating sortable fields
is(
	Vatican::DB::generate_sort_shelfmark("9"), "00009", "zero pad a simple integer"
	);
isnt(
	Vatican::DB::generate_sort_shelfmark("9"), "9", "zero pad a simple integer, don't just return it"
	);
is(
	Vatican::DB::generate_sort_shelfmark("9.9"), "00009.00009", "zero pad 2 integers"
	);
is(
	Vatican::DB::generate_sort_shelfmark("ross.9"),  "ross.00009", "zero integer, do not modify string"
	);
is(
	Vatican::DB::generate_sort_shelfmark("vat.lat.9"), "vat.lat.00009", "zero integer, do not modify double string"
	);
is(
	Vatican::DB::generate_sort_shelfmark("ix"), "00009", "convert and zero-pad roman numeral"
	);
is(
	Vatican::DB::generate_sort_shelfmark("ross.ix"), "ross.00009", "convert and zero-pad roman numeral with string"
	);
ok(
	Vatican::DB::generate_sort_shelfmark("v") lt Vatican::DB::generate_sort_shelfmark("ix"), "roman numerals compare properly"
	);
is(
	Vatican::DB::generate_sort_shelfmark("iv"), Vatican::DB::generate_sort_shelfmark("iiii"), "roman numerals equal properly"
	);
is(
	Vatican::DB::generate_sort_shelfmark("Arch.Cap.S.Pietro.A.16"), "Arch.Cap.S.Pietro.A.00016", "Complex shelfmarks correct"
	);
is(
	Vatican::DB::generate_sort_shelfmark("Autogr.Paolo.VI.27.pt.bis"), "Autogr.Paolo.00006.00027.pt.bis", "Complex shelfmarks with romans are correct"
	);
is(
	Vatican::DB::generate_sort_shelfmark("Chig.H.II.22"), "Chig.H.00002.00022", "Chigi H is correct"
	);
is(
	Vatican::DB::generate_sort_shelfmark("Chig.H.I.22"), "Chig.H.00001.00022", "Chigi H.I is correct"
	);
is(
	Vatican::DB::generate_sort_shelfmark("Chig.I.I.17"), "Chig.I.00001.00017", "Chigi I is correct"
	);
is(
	Vatican::DB::generate_sort_shelfmark("Chig.L.IV.110"), "Chig.L.00004.00110", "Chigi L is correct"
	);
is(
	Vatican::DB::generate_sort_shelfmark("Chig.M.I.18"), "Chig.M.00001.00018", "Chigi M is correct"
	);
## edge case, there are some Chigi manuscripts that are all roman numerals.  We are probably doing this wrong, 
## but it seems to match the BAV
is(
	Vatican::DB::generate_sort_shelfmark("Chig.M.V.II"), "Chig.M.V.00002", "Chigi M weird is correct"
	);
is(
	Vatican::DB::generate_sort_shelfmark("Chig.M.VIII.LXVII"), "Chig.M.VIII.00067", "Chigi M weird with large number is correct"
	);
is(
	Vatican::DB::generate_sort_shelfmark("Capp.Giulia.II.40"), "Capp.Giulia.00002.00040", "Capp.Giulia.II.40 is correct"
	);

TODO: {
	local $TODO = "Can't handle non roman \"I\" inside the shelfmark";
	is(
		Vatican::DB::generate_sort_shelfmark("Arch.Cap.S.Pietro.I.1"), "Arch.Cap.S.Pietro.I.00001", "Arch Cap Pietro I stays I"
		);
	is(
		Vatican::DB::generate_sort_shelfmark("P.I.O.5"), "P.I.O.00005", "P.I.O collection"
		);
}