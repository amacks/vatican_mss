use strict;
use warnings;
use Test::More tests => 20;
use JSON;
use Data::Dumper;

## to be tested
use lib "./lib";

BEGIN {
 use_ok('Vatican::Config'); 
 use_ok('Vatican::DB');
 use_ok('Vatican::Manuscripts');
}

my $a;

isa_ok ( 
	$a = Vatican::Manuscripts->new(raw_sql => 'shelfmark like "Urb.lat.666"'), 
	"Vatican::Manuscripts", "Raw SQL for Urb.lat.666"
	);
ok (
	$a->load_manuscripts() == 0, "one manuscript matches Urb.lat.666"
	);
$a->post_process_manuscripts();
#warn Dumper($a);
## do week/year selection
my $b;
isa_ok ( 
	$b = Vatican::Manuscripts->new(week=>1, year=>2021, DEBUG=>0), 
	"Vatican::Manuscripts", "Week/year for 2021/1"
	);
ok ($b->load_manuscripts() == 46, "47 manuscripts for week 1 of 2021" 
	);
ok ($b->post_process_manuscripts() == 35, "35 manuscripts have markdown processed" 
	);
my $order_test;
isa_ok (
	$order_test = Vatican::Manuscripts->new(week=>4, year=>2018, order=>"shelfmark asc", DEBUG=>0),
	"Vatican::Manuscripts", "build a listing for the first block sorted by shelfmark asc"
	);
ok (
	$order_test->load_manuscripts() == 14092, "14092 manuscripts loaded for the initial block"
	);
ok (
	$order_test->post_process_manuscripts() > 1, "at least 2 manuscripts post processed"
	);
ok (
	$order_test->mss_list->[0]->{'shelfmark'} eq "Autogr.Paolo.VI.27.pt.bis", "first manuscript is the right one"
	);
isa_ok (
	$order_test = Vatican::Manuscripts->new(week=>4, year=>2018, order=>"shelfmark desc", DEBUG=>0),
	"Vatican::Manuscripts", "build a listing for the first block sorted by shelfmark desc"
	);
ok (
	$order_test->load_manuscripts() == 14092, "14092 manuscripts loaded for the initial block"
	);
ok (
	$order_test->post_process_manuscripts() > 1, "at least 2 manuscripts post processed"
	);
ok (
	$order_test->mss_list->[0]->{'shelfmark'} eq "Vat.turc.99", "first manuscript is the right one"
	);
my $limit_test;
isa_ok (
	$limit_test = Vatican::Manuscripts->new(week=>4, year=>2018, order=>"shelfmark asc", limit=>20, DEBUG=>0),
	"Vatican::Manuscripts", "build a listing for the first block sorted by shelfmark asc, limit 20"
	);
ok (
	$limit_test->load_manuscripts() == 19, "20 manuscripts loaded per limit"
	);
ok (
	$limit_test->post_process_manuscripts() > 1, "at least 2 manuscripts post processed"
	);
ok (
	$limit_test->mss_list->[19]->{'shelfmark'} eq "Barb.gr.114", "last manuscript is the right one"
	);
warn Dumper($limit_test->mss_list->[0]);