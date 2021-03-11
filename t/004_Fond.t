use strict;
use warnings;
use Test::More tests => 7;
use JSON;
use Data::Dumper;

## to be tested
use lib "./lib";

BEGIN {
 use_ok('Vatican::Config'); 
 use_ok('Vatican::Fond');
}

my $fond;
isa_ok(
	$fond = Vatican::Fond->new(id=>1, code=>'Vat.lat', name=>'Vaticani Latini', header_text => 'this _is_ markdown'), 
	"Vatican::Fond", "constructor creates a new object"
	);
ok(
	$fond->id() == 1, "ID returns correct"
	);
ok(
	$fond->code() eq "Vat.lat", "Code returns correct"
	);
ok(
	$fond->header_text() eq "this _is_ markdown", "header is stored properly"
	);
ok (
	$fond->header_text_html() eq "<p>this <em>is</em> markdown</p>\n", 
	"Header is converted to html"
	);