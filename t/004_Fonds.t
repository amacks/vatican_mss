use strict;
use warnings;
use Test::More tests => 6;
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
