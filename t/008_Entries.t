use strict;
use warnings;
use Test::More tests => 4;
use JSON;
use Data::Dumper;

## to be tested
use lib "./lib";

BEGIN {
 use_ok('Vatican::Config'); 
 use_ok('Vatican::DB');
 use_ok('Vatican::Entry');
 use_ok('Vatican::Entries');
}
my %test_values = (
    'week_number' => 25,
    'year' => 2019,
    'id' => 1
    );

my $all_entries = Vatican::Entries->new();
my $twenty_twenty = Vatican::Entries->new(where_fields => ['year'], 
    where_values=>[2020], order => 'week_number desc');