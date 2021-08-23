use strict;
use warnings;
use Test::More tests => 19;
use JSON;
use Data::Dumper;

## to be tested
use lib "./lib";

BEGIN {
 use_ok('Vatican::Config'); 
 use_ok('Vatican::DB');
 use_ok('Vatican::Entry');
}
my %test_values = (
    'week_number' => 25,
    'year' => 2019,
    'id' => 1
    );

my $id;
my $week_year;

## test creating by id. ID 1 is 2019 week 25
isa_ok ( 
    $id = Vatican::Entry->new(id=>$test_values{'id'}), 
    "Vatican::Entry", "Create with ID of 1" );
ok (
    $id->id() == $test_values{'id'}, "Create with ID stores value" );
ok (
    $id->entry_data()->{'year'} == $test_values{'year'}, "Create by ID gives right year");
ok (
    $id->entry_data()->{'week_number'} == $test_values{'week_number'}, "Create by ID gives right week");
ok (
    $id->entry_data()->{'id'} == $test_values{'id'}, "Create by ID gives right id in the row");
ok (
    $id->year() == $test_values{'year'}, "Create by ID gives right year in object");
ok (
    $id->week_number() == $test_values{'week_number'}, "Create by ID gives right week in object");


isa_ok ( 
    $week_year = Vatican::Entry->new(week_number=>$test_values{'week_number'}, year=>$test_values{'year'}), 
    "Vatican::Entry", "Create with week of 30, year of 2021"
    );
ok ($week_year->week_number() == $test_values{'week_number'} && 
    $week_year->year() == $test_values{'year'}, 
    "Create with week/year stores both"
    );
ok (
    $week_year->id() == $test_values{'id'}, 
    "Create with week/year gets id value" );
ok (
    $week_year->entry_data()->{'year'} == $test_values{'year'}, 
    "Create with week/year gives right year in row");
ok (
    $week_year->entry_data()->{'week_number'} == $test_values{'week_number'}, 
    "Create with week/year gives right week in row");
ok (
    $week_year->entry_data()->{'id'} == $test_values{'id'}, 
    "Create with week/year gives right id in the row");

## we have these 2, compare them
is_deeply( 
    $id->entry_data(), $week_year->entry_data(), "Both objects are equal");

## check fields
ok(
    Vatican::Entry::get_fieldnames() =~ /^([a-z_]+,\s?)+([a-z_]+)$/, "get_fieldnames returns a proper string"
    );

## testing the markdown
my $md = Vatican::Entry->new(entry_data=>{header_text => 'Hello, _hello_'});
ok (
    $md->entry_data()->{'header_text_html'} =~ qr(^<p>Hello, <em>hello</em></p>), 
    "Header text is markdown processed");