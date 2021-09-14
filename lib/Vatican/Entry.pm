#!/usr/bin/perl

package Vatican::Entry;

use strict;
use Exporter;
use POSIX;
use POSIX qw(strftime);

use Data::Dumper;
use DBI;
use DBI qw(:sql_types);
use Encode;
use Moose;
use utf8;
use Text::Markdown;

use File::Basename;
use lib dirname($0) . "/";
use Vatican::Config;

## constant SQL
my $field_names = ['id','year','week_number', 'header_text',
	'image_filename', 'boundry_image_filename', 'previous_week_id',
	'previous_week_year', 'previous_week_week_number', 'next_week_id',
	'next_week_year', 'next_week_week_number', 'last_updated'];
my $entry_boilerplate = "select __FIELDS__
from __TABLE__ 
where (__WHERE_CLAUSE__)";

## class variables

has 'id' => (
	isa => 'Maybe[Int]',
	is => 'rw'
	);
has 'week_number' => (
	isa => 'Maybe[Int]',
	is => 'rw'
	);
has 'year' => (
	isa => 'Maybe[Int]',
	is => 'rw'
	);
has 'raw_sql' => (
	isa => 'Maybe[Str]',
	is => 'rw'
	);
has 'entry_data' => (
	isa => 'Maybe[HashRef]',
	'is' => 'rw'
	);
has 'where_values' => (
	isa => 'ArrayRef',
	is => 'rw'
	);
has 'where_fields' => (
	isa => 'ArrayRef',
	is => 'rw'
	);
has '_select_stmt' => (
	isa => 'Str',
	is => 'rw',
	default => $entry_boilerplate
	);
## constructor
sub BUILD {
	my $this = shift;
	my $config = Vatican::Config->new();
	if (!defined($this->entry_data())){
		## if we don't have an entry already loaded, assume we need to load one
		if (!defined($this->raw_sql())){
			## build some SQL
			if (!defined($this->where_fields())){
				## we only have specific values
				if (defined($this->id())){
					$this->where_fields(['id']);
					$this->where_values([$this->id()]);
				} elsif (defined($this->year()) or (defined($this->week_number()))){
					if (defined($this->week_number()) and (defined($this->year()))){
						$this->where_fields(['week_number', 'year']);
						$this->where_values([$this->week_number(), $this->year()]);
					} else {
						die "Cannot have only week or year defined, need both";
					}
				} else {
					die "We need either ID or Week/Year to create a record from the DB";
				}
			}
			## at this point either the where fields were manually defined
			## or they have been build from specific values.  Time to make some SQL
			my $sql_frag = join('=? and ', @{$this->where_fields()});
			$sql_frag .= '=?';
			$this->raw_sql($sql_frag);
		}
		## at this point there is raw sql in the structure, either manually defined
		## or generated above, let's run it.
		## first we need to replace all the variables in the sql
		$this->sql_stmt_replace('__TABLE__', $config->notes_linked_table());
		$this->sql_stmt_replace('__WHERE_CLAUSE__', $this->raw_sql());
		## pickup the field names
		$this->sql_stmt_replace('__FIELDS__', join(',', @{$field_names}));
		my $db = Vatican::DB->new();
		my $db_entry = $db->get_one_row($this->_select_stmt(), $this->where_values());
		if (defined($db_entry)){
			$this->entry_data($db_entry);
		}
	} else {
		## data was passed to us already. That's nice
	}
	## make sure the named fields are properly stored
	if (defined($this->entry_data())){
		for my $field ('year', 'week_number', 'id' ){
			if (!defined($this->{$field})){
				$this->{$field} = $this->entry_data()->{$field};
			}
		}
		#markdown the header
		my $m = Text::Markdown->new;
		$this->entry_data()->{'header_text_html'} = $m->markdown($this->entry_data()->{'header_text'});
	} else {
		warn "No entry in DB";
	}
}


## takes 2 values a macro to replace and the replacement string, does the replacement in the 
## sql_statement value
sub sql_stmt_replace($$$){
	my $this = shift;
	my ($macro, $string) = @_;
	my $select_stmt = $this->_select_stmt();
	$select_stmt =~ s/$macro/$string/g;
	$this->_select_stmt($select_stmt);
}

## static functions

## return a comma-seperated list of field names sutable for a SQL statement
sub get_fieldnames(){
	return join(',', @{$field_names});
}


1;