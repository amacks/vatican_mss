use strict;
use warnings;
use Test::More tests => 36;
use JSON;
use Data::Dumper;

## to be tested
use lib "./lib";

BEGIN {
 use_ok('Vatican::Config'); 
 use_ok('Vatican::DB');
 use_ok('Vatican::Manuscripts');
}

my $a;

isa_ok ( 
	$a = Vatican::Manuscripts->new(raw_sql => 'shelfmark like "Urb.lat.666"'), 
	"Vatican::Manuscripts", "Raw SQL for Urb.lat.666"
	);
ok (
	$a->load_manuscripts() == 0, "one manuscript matches Urb.lat.666"
	);
$a->post_process_manuscripts();
#warn Dumper($a);
## do week/year selection
my $b;
isa_ok ( 
	$b = Vatican::Manuscripts->new(week=>1, year=>2021, DEBUG=>0), 
	"Vatican::Manuscripts", "Week/year for 2021/1"
	);
ok ($b->load_manuscripts() == 46, "47 manuscripts for week 1 of 2021" 
	);
ok ($b->post_process_manuscripts() == 35, "35 manuscripts have markdown processed" 
	);
my $order_test;
isa_ok (
	$order_test = Vatican::Manuscripts->new(week=>4, year=>2018, order=>"shelfmark asc", DEBUG=>0),
	"Vatican::Manuscripts", "build a listing for the first block sorted by shelfmark asc"
	);
ok (
	$order_test->load_manuscripts() == 12862, "12862 manuscripts loaded for the initial block"
	);
ok (
	$order_test->post_process_manuscripts() > 1, "at least 2 manuscripts post processed"
	);
ok (
	$order_test->mss_list->[0]->{'shelfmark'} eq "Autogr.Paolo.VI.27.pt.bis", "first manuscript is the right one"
	);
isa_ok (
	$order_test = Vatican::Manuscripts->new(week=>4, year=>2018, order=>"shelfmark desc", DEBUG=>0),
	"Vatican::Manuscripts", "build a listing for the first block sorted by shelfmark desc"
	);
ok (
	$order_test->load_manuscripts() == 12862, "12862 manuscripts loaded for the initial block"
	);
ok (
	$order_test->post_process_manuscripts() > 1, "at least 2 manuscripts post processed"
	);
ok (
	$order_test->mss_list->[0]->{'shelfmark'} eq "Vat.turc.99", "first manuscript is the right one"
	);
my $limit_test;
isa_ok (
	$limit_test = Vatican::Manuscripts->new(week=>4, year=>2018, order=>"shelfmark asc", limit=>20, DEBUG=>0),
	"Vatican::Manuscripts", "build a listing for the first block sorted by shelfmark asc, limit 20"
	);
ok (
	$limit_test->load_manuscripts() == 19, "20 manuscripts loaded per limit"
	);
ok (
	$limit_test->post_process_manuscripts() > 1, "at least 2 manuscripts post processed"
	);
ok (
	$limit_test->mss_list->[19]->{'shelfmark'} eq "Barb.gr.114", "last manuscript is the right one"
	);
#warn Dumper($limit_test->mss_list->[0]);

## Group A: post_process_manuscripts computed fields
## Piggyback on $a (Urb.lat.666) — already loaded and post-processed above
ok (
	defined($a->mss_list->[0]->{'entry_url'}), "entry_url is defined after post_process"
	);
ok (
	defined($a->mss_list->[0]->{'iiif_url'}), "iiif_url is defined after post_process"
	);
like (
	$a->mss_list->[0]->{'iiif_url'}, qr|/manifest\.json$|, "iiif_url ends with /manifest.json"
	);
ok (
	defined($a->mss_list->[0]->{'details_url'}), "details_url is defined after post_process"
	);
ok (
	defined($a->mss_list->[0]->{'ms_page_uri'}), "ms_page_uri is defined after post_process"
	);
ok (
	defined($a->mss_list->[0]->{'ms_page_url'}), "ms_page_url is defined after post_process"
	);
ok (
	defined($a->mss_list->[0]->{'complete_thumbnail_url'}), "complete_thumbnail_url is defined after post_process"
	);
## notes_html: $b (week 1/2021) has 35 manuscripts with notes — check first that has notes_html
my ($notes_ms) = grep { defined $_->{'notes_html'} } @{$b->mss_list()};
ok (
	defined($notes_ms->{'notes_html'}), "notes_html is defined for a manuscript with notes"
	);

## Group B: where_fields / where_values constructor path
my $wf;
isa_ok (
	$wf = Vatican::Manuscripts->new(
		where_fields => ['shelfmark'],
		where_values => ['Urb.lat.666']
	),
	"Vatican::Manuscripts", "where_fields/where_values constructor"
	);
ok (
	$wf->load_manuscripts() == 0, "where_fields path returns same single result as raw_sql"
	);

## Group C: no-conditions path returns undef
my $empty;
ok (
	$empty = Vatican::Manuscripts->new(), "new() with no conditions creates object"
	);
ok (
	!defined($empty->load_manuscripts()), "load_manuscripts with no conditions returns undef"
	);

## Group D: sql_stmt_replace directly
my $repl = Vatican::Manuscripts->new();
$repl->sql_stmt_replace('__ORDER__', 'shelfmark asc');
like (
	$repl->mss_stmt(), qr/shelfmark asc/, "sql_stmt_replace substitutes macro in mss_stmt"
	);

## Group E: sql_error causes die
eval { Vatican::Manuscripts->new()->sql_error("test error") };
ok (
	$@, "sql_error causes die"
	);

## Group F: http thumbnail_url branch — complete_thumbnail_url equals thumbnail_url verbatim
my $http_ms = Vatican::Manuscripts->new(where_fields => ['shelfmark'], where_values => ['Vat.lat.10589']);
$http_ms->load_manuscripts();
$http_ms->post_process_manuscripts();

like (
	$http_ms->mss_list->[0]->{'thumbnail_url'}, qr/^http/, "Vat.lat.10589 thumbnail_url starts with http"
	);
is (
	$http_ms->mss_list->[0]->{'complete_thumbnail_url'},
	$http_ms->mss_list->[0]->{'thumbnail_url'},
	"http thumbnail_url stored verbatim in complete_thumbnail_url"
	);