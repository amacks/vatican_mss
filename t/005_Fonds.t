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
##get the fond data, do surgery
my $gotten_data = $fonds->get_all_fond_data()->[0];
delete($gotten_data->{'random_image_filename'});
is_deeply($gotten_data,
{
          'header_text' => 'The archives of the chapter of St. Peters, which trace their origins to a privilege granted in 1053 by Pope Leo XI. It was transferred to the BAV in 1940 by Pope Pius XII, according to the wishes of the recently deceased Pius XI. Of the collection, some items relate to the business of the Chapter, including mutliple rent and property registers, accounting documents, etc. There are also a number of liturgical manuscripts for the use of the Chapter, including a series of lavish 16th C Antiphonals and manuscripts relating to the history of the city of Rome and St. Peters in particular.  Unusually, this vast majority of these MSS have excellent metadata in the online catalogue.  Sadly due to technical issues this site does not have good tracking data for when these were digitized, the bulk of them can be seen in a two week stretch in 2019, [week 32](http://www.wiglaf.org/vatican/2019/week32.html) and [week 33](http://www.wiglaf.org/vatican/2019/week33.html)

There are currently $NUMBER$ manuscripts digitized out of a total of 494 signatures.

#### Sources

1. Biblioteca apostolica vaticana. (2011). _Guida ai fondi manoscritti, numismatici, a stampa della Biblioteca vaticana._ Biblioteca apostolica vaticana.  pp. 333-336
2. [http://www.mss.vatlib.it/arch_gui/console?service=detail&id=1](http://www.mss.vatlib.it/arch_gui/console?service=detail&id=1)
',
          'id' => 1,
          'full_name' => 'Archivio del Capitolo di S. Pietro',
          'header_text_html' => '<p>The archives of the chapter of St. Peters, which trace their origins to a privilege granted in 1053 by Pope Leo XI. It was transferred to the BAV in 1940 by Pope Pius XII, according to the wishes of the recently deceased Pius XI. Of the collection, some items relate to the business of the Chapter, including mutliple rent and property registers, accounting documents, etc. There are also a number of liturgical manuscripts for the use of the Chapter, including a series of lavish 16th C Antiphonals and manuscripts relating to the history of the city of Rome and St. Peters in particular.  Unusually, this vast majority of these MSS have excellent metadata in the online catalogue.  Sadly due to technical issues this site does not have good tracking data for when these were digitized, the bulk of them can be seen in a two week stretch in 2019, <a href="http://www.wiglaf.org/vatican/2019/week32.html">week 32</a> and <a href="http://www.wiglaf.org/vatican/2019/week33.html">week 33</a></p>

<p>There are currently $NUMBER$ manuscripts digitized out of a total of 494 signatures.</p>

<h4>Sources</h4>

<ol>
<li>Biblioteca apostolica vaticana. (2011). <em>Guida ai fondi manoscritti, numismatici, a stampa della Biblioteca vaticana.</em> Biblioteca apostolica vaticana.  pp. 333-336</li>
<li><a href="http://www.mss.vatlib.it/arch_gui/console?service=detail&amp;id=1">http://www.mss.vatlib.it/arch_gui/console?service=detail&amp;id=1</a></li>
</ol>
',
          'code' => 'Arch.Cap.S.Pietro',
          'image_filename' => undef,
        },
    "get_all_fond_data returns the first element complete"
	);
ok(
	$#{$fonds->get_all_fond_data()} == $fond_count, 
	"get all returns the same number that were loaded"
	);
