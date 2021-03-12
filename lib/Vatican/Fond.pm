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

## constants
our $db_fields = ["id", "code", "full_name", "header_text"];
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
	return \%data;
}
1;