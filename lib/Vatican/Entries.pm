#!/usr/bin/perl

package Vatican::Entries;

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
use Vatican::Entry;

has 'verbose' => (
	isa => 'Bool',
	is => 'ro',
	default => 0
	);
has 'limit' => (
	isa => 'Maybe[Int]',
	is => 'rw'
	);
has 'order' => (
	isa => 'Maybe[Str]',
	is => 'rw'
	);
## currently there is no where functionality, this is in place to support it in the future
has 'where_values' => (
	isa => 'ArrayRef',
	is => 'ro'
	);
has 'where_fields' => (
	isa => 'ArrayRef',
	is => 'ro'
	);
has '_select_stmt' => (
	isa => 'Str',
	is => 'rw',
	default => 'select __FIELDS__
from __TABLE__ 
__WHERE_CLAUSE__
__ORDER_CLAUSE__
__LIMIT_CLAUSE__'
);
has 'raw_sql' => (
	isa => 'Maybe[Str]',
	is => 'rw'
	);
## store the actual data
has 'entries_data' => (
	isa => 'Maybe[ArrayRef]',
	is => 'rw',
	default => sub { return [] }
	);

sub BUILD {
	my $this = shift;
	my $config = Vatican::Config->new();
	## set the fields and table
	$this->sql_stmt_replace('__FIELDS__', Vatican::Entry::get_fieldnames());
	$this->sql_stmt_replace('__TABLE__', $config->notes_linked_table());
	## set the limit and order if needed
	if (defined($this->limit())){
		$this->sql_stmt_replace('__LIMIT_CLAUSE__', " limit " . $this->limit());
	} else {
		$this->sql_stmt_replace('__LIMIT_CLAUSE__','');
	}
	if (defined($this->order())){
		$this->sql_stmt_replace('__ORDER_CLAUSE__', " order by " . $this->order());
	} else {
		$this->sql_stmt_replace('__ORDER_CLAUSE__','');
	}
	## in the future we might select where statements, but not yet
	if ( defined($this->where_fields()) && defined($this->where_values()) ){
		if ($#{$this->where_fields()} != $#{$this->where_values()}){
			warn "Cannot have fieldname and value mismatch in a where clause\n
			there are ". $#{$this->where_fields()}+1 . " fields and " . $#{$this->where_values()}+1 . " Values";
			return undef;
		} else {
			## we have the right values
			my $sql_frag = join('=? and ', @{$this->where_fields()});
			$sql_frag .= '=?';
			$this->raw_sql($sql_frag);
		}
	}
	if (defined($this->raw_sql())){
		$this->sql_stmt_replace('__WHERE_CLAUSE__', 'Where '. $this->raw_sql());
	} else {
		## only choice
		$this->sql_stmt_replace('__WHERE_CLAUSE__', '');
	}
	warn " SQL is " . $this->_select_stmt() if ($this->verbose());
	## we've got SQL, get some data
	my $db = Vatican::DB->new();
	my $dbh = $db->get_generate_dbh();
	my $sth = $dbh->prepare($this->_select_stmt()) or die "Cannot prepare the statement ". $this->_select_stmt() . " " . $dbh->errstr();
	## do binding
	if (defined($this->where_values())){
		for (my $i=0;$i<=$#{$this->where_values()};$i++){
			$sth->bind_param($i+1, $this->where_values->[$i]);
		}
	}
	$sth->execute() or die "Cannot execute select " . $sth->errstr();
	while (my $row = $sth->fetchrow_hashref()){
		my $entry = Vatican::Entry->new(entry_data=>$row);
		push @{$this->entries_data()}, $entry;
	}
	warn " " . $this->get_entry_count() . " entries loaded" if ($this->verbose());
}

sub get_entry_count($){
	my $this = shift;
	return $#{$this->entries_data()} + 1;
}

sub sql_stmt_replace($$$){
	my $this = shift;
	my ($macro, $string) = @_;
	my $select_stmt = $this->_select_stmt();
	$select_stmt =~ s/$macro/$string/g;
	$this->_select_stmt($select_stmt);
}


1;