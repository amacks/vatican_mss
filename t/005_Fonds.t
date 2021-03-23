use strict;
use warnings;
use Test::More tests => 10;
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
my $fond_count;
ok(
	 ( $fond_count = $fonds->load_fonds())>=87, "Enough fonds were loaded"
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
is_deeply($fonds->get_all_fond_data()->[0],
{
          'header_text' => '494 signatures.

pp. 333-336',
          'id' => 1,
          'full_name' => 'Archivio del Capitolo di S. Pietro',
          'header_text_html' => '<p>494 signatures.</p>

<p>pp. 333-336</p>
',
          'code' => 'Arch.Cap.S.Pietro'
        },
    "get_all_fond_data returns the first element complete"
	);
ok(
	$#{$fonds->get_all_fond_data()} == $fond_count, 
	"get all returns the same number that were loaded"
	);
