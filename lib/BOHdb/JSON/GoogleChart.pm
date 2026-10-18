#!/usr/bin/perl -w

## tools for handling and generating the json feeds needed by google graph API

package BOHdb::JSON::GoogleChart;
use strict;
use File::Basename;
use Data::Dumper;
use Moose;
use JSON;
use JSON::XS;
use lib dirname($0) . "/..";

## data tools for google graph
sub new($){
	my $class = shift;
	my $internals = {
		'cols' => [],
		'colcount' => 0,
		'rows' => [],
	};
	bless $internals;
	return $internals;
}

## add a column header, assume a single hashref in google's format, eg.
#			{ 'type' => 'date', 'label' => 'Date', 'id' => 'count'},
## returns the number of columns

sub add_column($$){
	my $this = shift;
	my $column = shift;
	if (ref($column) ne "HASH") {
		warn "add_column requires a hashref to define a column";
		return undef;
	} else {
		push @{$this->{'cols'}}, $column;
		$this->{'colcount'}++;
		return $this->{'colcount'};
	}
}

## add a row of data, assume a single-dimensional array passed in, simply the data values.  Google want's a weird format, but we'll generate that later
## {
# 	'c' => [
# 		{ 'v' => $country_row->{'country'}},
# 		{ 'v' => $country_row->{'number'}}
# 	]
## };
## returns the NUMBER of rows in the array, not the $#, but the number ($#+1)

sub add_row($$){
	my $this = shift;
	my $row = shift;
	if (ref($row) ne "ARRAY") {
		warn "add_row requires an arrayref to define a column";
		return undef;
	} else {
		push @{$this->{'rows'}}, $row;
		return $#{$this->{'rows'}}+1;
	}
}

## generate the properly formatted json for the google graph API
## NB, this does NOT yet verify that the dimensions match

sub get_json($){
	my $this = shift;
	## build a hash of the weirly formatted data for the rows
	my @rows;
	for my $rowdata (@{$this->{'rows'}}){
		my %row = ( 'c' => []); ## basic structure of a row
		for my $coldata (@$rowdata){
			push @{$row{'c'}}, { 'v' => $coldata};
		}
		push @rows, \%row;
	}
    my $json = JSON->new->allow_nonref;
    $json->utf8(0);
    $json->indent(1);
    my $json_string = $json->encode({
    	'cols' => $this->{'cols'},
    	'rows' => \@rows
    	});
}

1;