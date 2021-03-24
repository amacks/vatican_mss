#!/usr/bin/perl

package Vatican::Fond;

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
use Text::Markdown;
use utf8;

use File::Basename;
use lib dirname($0) . "/";
use Vatican::Config;
use Vatican::DB;

## constants
our $db_fields = ["id", "code", "full_name", "header_text", "image_filename"];
my $md_fields = ["header_text_html"];

has 'id' => (
	is => 'ro',
	isa => 'Int'
	);
has 'code' => (
	is => 'ro',
	isa => 'Str'
	);
has 'full_name' => (
	is => 'ro',
	isa => 'Str'
	);
has 'header_text' => (
	is => 'ro',
	isa => 'Maybe[Str]'
	);
has 'header_text_html' => (
	is => 'ro',
	isa => 'Maybe[Str]'
	);
has 'image_filename' => (
	is => 'ro',
	isa => 'Maybe[Str]'
	);
has '_thumbnail_url' => (
	is => 'rw',
	isa => 'Maybe[Str]'
	);

has '_dbh' => (
	is => 'rw',
	isa => 'Maybe[DBI::db]'
	);

sub BUILD {
	my $this = shift;
	my $m = Text::Markdown->new;
	for my $fieldname (@$md_fields){
		my $raw_fieldname = $fieldname;
		$raw_fieldname =~ s/_html$//;
		$this->{$fieldname} = $m->markdown($this->{$raw_fieldname});
	}
} 

## dump out all the fields as a dictionary
sub get_data($){
	my $this = shift;
	my %data;
	for my $field (@{$db_fields}){
		$data{$field} = $this->{$field};
	}
	for my $field (@{$md_fields}){
		$data{$field} = $this->{$field};		
	}
	## store a random image
	if (!defined($data{'image_filename'})){
		$data{'image_filename'} = $this->get_random_image_url();
	}
	return \%data;
}

sub get_random_image_url($){
	my $this = shift;
	my $db = Vatican::DB->new();
	$this->_dbh($db->get_generate_dbh());
	my $sth = $this->_dbh()->prepare("select thumbnail_url from manuscripts where fond_code like ? and high_quality order by rand() limit 1");
	$sth->bind_param(1, $this->code());
	$sth->execute();
	if (my $row = $sth->fetchrow_hashref()){
		$this->_thumbnail_url($row->{'thumbnail_url'});
	} else {
		warn "no row returned";
	}
	$sth->finish();
	return $this->_thumbnail_url();
}
1;