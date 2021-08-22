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

use File::Basename;
use lib dirname($0) . "/";
use Vatican::Config;

## constant SQL
my $field_names = ['id','year','week_number', 'header_text',
	'image_filename', 'boundry_image_filename', 'previous_week_id',
	'previous_week_year', 'previous_week_week_number', 'next_week_id',
	'next_week_year', 'next_week_week_number'];
my $entry_boilerplate = "select __FIELDS__
from __NOTES_TABLE__ 
where (__WHERE_CLAUSE__)";

## class variables

has 'id' => (
	isa => 'Maybe[Int]',
	is => 'ro'
	);
has 'week' => (
	isa => 'Maybe[Int]',
	is => 'ro'
	);
has 'year' => (
	isa => 'Maybe[Int]',
	is => 'ro'
	);
has 'raw_sql' => (
	isa => 'Maybe[Str]',
	is => 'ro'
	);
has 'entry_data' => (
	isa => 'HashRef',
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
has 'select_stmt' => (
	isa => 'Str',
	is => 'rw',
	default => $entry_boilerplate
	);
## constructor
sub BUILD {
	my $this = shift;
	if (!defined($this->entry_data())){
		## if we don't have an entry already loaded, assume we need to load one
		if (!defined($this->raw_sql())){
			## build some SQL
			if (!defined($this->where_fields())){
				## we only have specific values
				if (defined($this->id())){
					$this->where_fields(['id']);
					$this->where_values([$this->id()]);
				} elsif (defined($this->year()) or (defined($this->week()))){
					if (defined($this->week()) and (defined($this->year()))){
						$this->where_fields(['week', 'year']);
						$this->where_values([$this->week(), $this->year()]);
					} else {
						die "Cannot have only week or year defined, need both";
					}
				} else {
					die "We need either ID or Week/Year to create a record from the DB";
				}
			}
			## at this point either the where fields were manually defined
			## or they have been build from specific values.  Time to make some SQL
			my $sql_frag = join('=?, ', @{$this->where_fields()});
			$sql_frag .= '=?';
			$this->raw_sql($sql_frag);
		}
		## at this point there is raw sql in the structure, either manually defined
		## or generated above, let's run it

	} else {
		## data was passed to us already. That's nice
	}

}


1;