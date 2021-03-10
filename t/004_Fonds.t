use strict;
use warnings;
use Test::More tests => 1;
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

warn $fonds->load_fonds();
warn Dumper($fonds->get_fond_codes());