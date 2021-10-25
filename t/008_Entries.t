use strict;
use warnings;
use Test::More tests => 15;
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
my $all_entries;
my $twenty_twenty;
my $verbose_entries;
isa_ok ( 
    $all_entries = Vatican::Entries->new(verbose=>0), 
    "Vatican::Entries", "Create with no parameters" );
ok (!$all_entries->verbose(), "Verbose set false is false"
    );
isa_ok (
    $twenty_twenty = Vatican::Entries->new(where_fields => ['year'], 
    where_values=>[2020], order => 'week_number desc'), "Vatican::Entries",
    "Create an Entries for 2020, week_number desc");
is_deeply(
    $twenty_twenty->where_values(), [2020], "Where value properly set"
    );
is_deeply(
    $twenty_twenty->where_fields(), ['year'], "Where fields properly set"
    );
ok (
    $twenty_twenty->get_entry_count() == 53, "year 2020 had 53 weeks"
    );
ok (
    $twenty_twenty->raw_sql() eq "year=?", "SQL generation works"
    );
my $twenty_twenty_last = $twenty_twenty->entries_data()->[52];
my $twenty_twenty_reverse;
isa_ok (
    $twenty_twenty_reverse = Vatican::Entries->new(where_fields => ['year'], 
    where_values=>[2020], order => 'week_number asc'), "Vatican::Entries",
    "Create an Entries for 2020, week_number asc");
is_deeply (
    $twenty_twenty_last, $twenty_twenty_reverse->entries_data->[0],
    "first sorted asc is the same as last sorted desc");
isa_ok ( 
    $verbose_entries = Vatican::Entries->new(verbose => 1), 
    "Vatican::Entries", "Create with verbose" );
ok (
    $verbose_entries->verbose(), "Verbose set true is true"
    );