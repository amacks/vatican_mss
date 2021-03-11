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
 use_ok('Vatican::Fond');
}