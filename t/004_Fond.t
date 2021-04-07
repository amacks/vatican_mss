use strict;
use warnings;
use Test::More tests => 12;
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
	$fond = Vatican::Fond->new(id=>1, code=>'Vat.lat', full_name=>'Vaticani Latini', header_text => 'this _is_ markdown'), 
	"Vatican::Fond", "constructor creates a new object"
	);
ok(
	$fond->id() == 1, "ID returns correct"
	);
ok(
	$fond->code() eq "Vat.lat", "Code returns correct"
	);
ok(
	$fond->full_name() eq "Vaticani Latini", "full_name returns correct"
	);
ok(
	$fond->header_text() eq "this _is_ markdown", "header is stored properly"
	);
ok (
	$fond->header_text_html() eq "<p>this <em>is</em> markdown</p>\n", 
	"Header is converted to html"
	);
#warn Dumper($fond->get_data());
is_deeply($fond->get_data(),
	{
		id=>1, code=>'Vat.lat', full_name=>'Vaticani Latini', header_text => 'this _is_ markdown',
		header_text_html => "<p>this <em>is</em> markdown</p>\n",
		random_image_filename => undef

	}, "get_data returns all the data"
	);
my $rand_image_1 = $fond->get_random_image_url();
my $rand_image_2 = $fond->get_random_image_url();
ok (
	$rand_image_1 =~ /^\/vatican\/20/, "Random image 1 is a url"
	);
ok (
	$rand_image_2 =~ /^\/vatican\/20/, "Random image 2 is a url"
	);
ok (
	$rand_image_1 ne $rand_image_2, "Two random images are different"
	);