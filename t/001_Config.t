use strict;
use warnings;
use Test::Simple tests => 4;
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
	$config->get_generate_db('username') eq "vatican_ro", "sub value of generate_database is available"
	);

#warn Dumper($config);