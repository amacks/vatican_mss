use strict;
use warnings;
use Test::Simple tests => 23;
use JSON;
use Data::Dumper;

## to be tested
use lib "./lib";
use Vatican::Config;

my $config;
ok (
	$config = Vatican::Config->new(), "Vatican::Config object created"
	);

ok (
	$config->db_host() eq "127.0.0.1", "hostname retrieved"
	);

ok (
	ref($config->generate_database()) eq "HASH", "generate_database is a hashref"
	);
ok (
	ref($config->insert_database()) eq "HASH", "insert_database is a hashref"
	);
ok (
	$config->get_generate_db('username') eq "vatican_ro", "sub value of generate_database is available"
	);
ok (
	$config->base_url() eq 'https://digi.vatlib.it/mss', "Base URL is Vatican"
	);
ok (
	$config->ms_base_url() eq 'https://digi.vatlib.it/view/MSS_', "Manuscript URL is vatican"
	);

## Attribute coverage
ok (
	$config->db_name() eq 'vatican_mss', "db_name retrieved"
	);
ok (
	$config->notes_table() eq 'weekly_notes', "notes_table retrieved"
	);
ok (
	$config->notes_previous_table() eq 'weekly_notes_previous', "notes_previous_table retrieved"
	);
ok (
	$config->notes_linked_table() eq 'weekly_notes_linked', "notes_linked_table retrieved"
	);
ok (
	$config->year_notes_table() eq 'yearly_notes', "year_notes_table retrieved"
	);
ok (
	$config->ms_table() eq 'manuscripts', "ms_table retrieved"
	);
ok (
	$config->prefix() eq '/vatican', "prefix retrieved"
	);
ok (
	$config->detail_base_url() eq 'https://digi.vatlib.it/mss/detail/', "detail_base_url retrieved"
	);
ok (
	$config->url_hostname() eq 'http://www.wiglaf.org', "url_hostname retrieved"
	);
ok (
	$config->mss_path() eq '/mss', "mss_path retrieved"
	);
ok (
	$config->iiif_base_url() eq 'https://digi.vatlib.it/iiif/MSS_', "iiif_base_url retrieved"
	);

## Hash delegate coverage (username only — no password tests)
ok (
	$config->get_insert_db('username') eq 'vatmss_insert', "get_insert_db username available"
	);
ok (
	$config->num_generate_db() == 2, "generate_database has 2 keys"
	);
ok (
	$config->num_insert_db() == 2, "insert_database has 2 keys"
	);

## Subroutine coverage
ok (
	$config->get_filename('/var/www', 2024, 5) eq '/var/www/vatican/2024/week5.html',
	"get_filename assembles path correctly"
	);
ok (
	$config->get_single_ms_uri('Vat.lat', '1') eq '/vatican/mss/Vat.lat/1.html',
	"get_single_ms_uri assembles URI correctly"
	);
#warn Dumper($config);