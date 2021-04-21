use strict;
use warnings;
use Test::More tests => 24;
use JSON;
use Data::Dumper;

## to be tested
use lib "./lib";

BEGIN {
 use_ok('Vatican::Config'); 
 use_ok('Vatican::Detail');
}

## shelfmarks to test
my $bav_shelfmark_only = 'Borg.arm.2'; ## entry with shelfmark only on page
my $bav_bib_only = 'Barb.lat.4'; ## bibliography, but no description
my $bav_big_bib = 'Vat.lat.8914'; ## large bibliography
my $bav_one_description = 'Vat.lat.15136'; ## single line of description
my $bav_multiple_both = 'Arch.Cap.S.Pietro.H.83'; ## both bib and desvriptions
my $bav_missing = 'Barb.lat.1975' ; ## this might be fixed, finally

## Test all the creators
my $shelfmark_only_detail;
isa_ok ( 
        $shelfmark_only_detail = Vatican::Detail->new(shelfmark => $bav_shelfmark_only), 
        "Vatican::Detail", "Create a Detail object for no details"
        );
my $bib_only_detail;
isa_ok ( 
        $bib_only_detail = Vatican::Detail->new(shelfmark => $bav_bib_only), 
        "Vatican::Detail", "Create a Detail object only bibliography"
        );
my $big_bib_detail;
isa_ok ( 
        $big_bib_detail = Vatican::Detail->new(shelfmark => $bav_big_bib), 
        "Vatican::Detail", "Create a Detail object bib bibliography"
        );
my $one_description_detail;
isa_ok ( 
        $one_description_detail = Vatican::Detail->new(shelfmark => $bav_one_description), 
        "Vatican::Detail", "Create a Detail object one line description"
        );
my $multiple_both_detail;
isa_ok ( 
        $multiple_both_detail = Vatican::Detail->new(shelfmark => $bav_multiple_both), 
        "Vatican::Detail", "Create a Detail object with everything"
        );
my $missing_detail;
isa_ok ( 
        $missing_detail = Vatican::Detail->new(shelfmark => $bav_missing), 
        "Vatican::Detail", "Create a Detail object with nothing"
        );


## test the values returned
ok (
	$shelfmark_only_detail->detail_page_exists(), "Detail page for " . $bav_shelfmark_only
	);
ok (
	$shelfmark_only_detail->get_bib_count() == 0, "no Bibliography for ". $bav_shelfmark_only
	);
ok (
	$shelfmark_only_detail->get_detail_count() == 0, "no Details for ". $bav_shelfmark_only
	);

ok (
	$bib_only_detail->detail_page_exists(), "Detail page for " . $bav_bib_only
	);
ok (
	$bib_only_detail->get_bib_count() == 5, "5 Bibliography entries for ". $bav_bib_only
	);
ok (
	$bib_only_detail->get_detail_count() == 0, "no Details for ". $bav_bib_only
	);

ok (
	$big_bib_detail->detail_page_exists(), "Detail page for " . $bav_big_bib
	);
ok (
	$big_bib_detail->get_bib_count() == 18, "18 Bibliography entries for ". $bav_big_bib
	);
ok (
	$big_bib_detail->get_detail_count() == 0, "no Details for ". $bav_big_bib
	);

ok (
	$one_description_detail->detail_page_exists(), "Detail page for " . $bav_one_description
	);
ok (
	$one_description_detail->get_bib_count() == 0, "No Bibliography entries for ". $bav_one_description
	);
ok (
	$one_description_detail->get_detail_count() == 1, "1 Detail for ". $bav_one_description
	);

ok (
	$multiple_both_detail->detail_page_exists(), "Detail page for " . $bav_multiple_both
	);
ok (
	$multiple_both_detail->get_bib_count() == 2, "2 Bibliography entries for ". $bav_multiple_both
	);
ok (
	$multiple_both_detail->get_detail_count() == 4, "4 Detail for ". $bav_multiple_both
	);
ok (
	!$missing_detail->detail_page_exists(), "No detail page for " . $bav_missing
	);