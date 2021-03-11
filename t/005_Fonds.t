use strict;
use warnings;
use Test::More tests => 8;
use JSON;
use Data::Dumper;

## to be tested
use lib "./lib";

BEGIN {
 use_ok('Vatican::Config'); 
 use_ok('Vatican::DB');
 use_ok('Vatican::Fonds');
}

my $fonds;
isa_ok ( 
        $fonds = Vatican::Fonds->new(), 
        "Vatican::Fonds", "Create a bare Fonds object"
        );

ok(
	$fonds->load_fonds()>=87, "Enough fonds were loaded"
	);
isa_ok(
	$fonds->get_fond_codes(), "ARRAY", "Get Fond Codes returns an arrayref"
	);
ok(
	$fonds->get_fond_codes()->[0] eq "Arch.Cap.S.Pietro", "Get fond codes returns an array of strings"
	);
isa_ok(
	$fonds->fond_listing()->[0], "Vatican::Fond", "Fond listing is internally vatican::fond objects"
	);
