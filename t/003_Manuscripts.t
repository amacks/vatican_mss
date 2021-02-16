use strict;
use warnings;
use Test::More tests => 7;
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
	$a = Vatican::Manuscripts->new(raw_sql => 'ms1.shelfmark like "Urb.lat.666"'), 
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
ok (warn $b->load_manuscripts() #== 46, "47 manuscripts for week 1 of 2021" 
	);
ok ($b->post_process_manuscripts() == 35, "35 manuscripts have markdown processed" 
	);
#warn Dumper($b);