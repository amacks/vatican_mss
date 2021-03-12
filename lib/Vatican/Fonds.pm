#!/usr/bin/perl

package Vatican::Fonds;

use strict;
use Exporter;
use POSIX;
use POSIX qw(strftime);

use Data::Dumper;
use DBI;
use DBI qw(:sql_types);
use Encode;
use Moose;
use Roman;
use utf8;

use File::Basename;
use lib dirname($0) . "/";
use Vatican::Config;
use Vatican::Fond;

has 'config' => (
	is => 'ro',
	isa => 'Vatican::Config'
	);

has 'fond_listing' => (
	is => 'ro',
	isa => 'Maybe[Arrayref]'
	);
has '_dbh' => (
	is => 'rw',
	isa => 'Maybe[DBI::db]'
	);

has 'DEBUG' => (
	is => 'ro',
	isa => 'Bool',
	default => 1
	);

## constants
my $select_fonds_skel = "select __FIELDS__ from __TABLE__ where enabled order by code asc";
my $fonds_table = "fonds";
my $fields = $Vatican::Fond::db_fields;


sub BUILD{
	my $this = shift;
	$this->{'config'} = Vatican::Config->new() or die "Cannot read config file";
	my $db = Vatican::DB->new();
	$this->_dbh($db->get_generate_dbh());
}

sub load_fonds($){
	my $this = shift;
	$this->{'fond_listing'} = [];
	my $get_fonds_statement = $select_fonds_skel;
	my $field_names = join(',', @{$fields});

	$get_fonds_statement =~ s/__TABLE__/$fonds_table/g;
	$get_fonds_statement =~ s/__FIELDS__/$field_names/g;

	my $sth = $this->_dbh()->prepare($get_fonds_statement) or die "Cannot prepare statement: " . $this->_dbh()->errstr();
	$sth->execute() or die "Cannot execute statement: " . $sth->errstr();
	while (my $row = $sth->fetchrow_hashref()){
		my $fond = Vatican::Fond->new($row);
		push @{$this->{'fond_listing'}}, $fond;
	}
	return $#{$this->fond_listing()};
}

## return an array of just the codes.  Useful for iterating through the website 
sub get_fond_codes($){
	my $this = shift;
	if (!defined($this->fond_listing()) || $this->fond_listing() == []){
		warn " Fonds not yet loaded, loading them";
		my $count = $this->load_fonds();
		## note if the load fails, we won't catch it here
	}
	my @fond_codes = ();
	my $listings = $this->fond_listing();
	for (my $i=0;$i<=$#{$listings}; $i++){
		push @fond_codes, $listings->[$i]->code();
	}
	return \@fond_codes;
}

## returns all the fond data as a single dictionary.  useful for generating listing pages
sub get_all_fond_data($){
	my $this = shift;
	if (!defined($this->fond_listing()) || $this->fond_listing() == []){
		warn " Fonds not yet loaded, loading them";
		my $count = $this->load_fonds();
		## note if the load fails, we won't catch it here
	}	
	my @data = ();
	my $listings = $this->fond_listing();
	for (my $i=0;$i<=$#{$listings}; $i++){
		push @data, $listings->[$i]->get_data();
	}
	return \@data;
}

1;