#!/usr/bin/perl

package Vatican::Manuscripts;

use strict;
use Exporter;
use POSIX;

use Data::Dumper;
use DBI;
use DBI qw(:sql_types);
use Encode;
use Moose;
use utf8;
use Text::Markdown;

use File::Basename;
use lib "./lib";
use Vatican::Config;
use Vatican::DB;

has 'mss_list' => (
    isa => 'ArrayRef',
    is => 'rw'
);
has 'raw_sql' => (
	isa => 'Str',
	is => 'ro'
);
has 'where_fields' => (
	isa => 'ArrayRef',
	is => 'ro'
);
has 'where_values' => (
	isa => 'ArrayRef',
	is => 'rw'
);

has 'week' => (
	isa => 'Int',
	is => 'ro'
);

has 'year' => (
	isa => 'Int',
	is => 'ro'
);

has 'DEBUG' => (
	isa => "Bool",
	default => 0,
	is => 'rw'
);

#initial SQL statement
has 'mss_stmt' => (
	default => "select shelfmark, 
	title, author, incipit, notes, 
	thumbnail_url, date_added, lq_date_added, 
	high_quality, date
from
(select 
 ms1.shelfmark as shelfmark, 
 ms1.high_quality as high_quality, 
 ms1.date_added as date_added, 
 ms2.date_added as lq_date_added,
 ms1.title as title,
 ms1.author as author,
 ms1.incipit as incipit,
 ms1.notes as notes,
 ms1.thumbnail_url as thumbnail_url,
 ms1.date as date,
 ms1.sort_shelfmark,
 ms1.ignore
 from
__MS_TABLE__ as ms1 left join __MS_TABLE__ as ms2
on ms1.shelfmark=ms2.shelfmark AND ms1.id>ms2.id) as hq_lq
 where
(__WHERE__) AND
hq_lq.ignore is false
ORDER by sort_shelfmark asc",
	isa => 'Str',
	is => 'rw'
);

sub load_manuscripts($){
	my $this = shift;
	my $config = new Vatican::Config();
	my $ms_table = $config->ms_table();
	## connect to a DB
	my $vatican_db = new Vatican::DB();
	my $dbh=$vatican_db->get_generate_dbh();
## now prepare a handle for the statement
	$this->sql_stmt_replace('__MS_TABLE__', $ms_table);
	if (!defined($this->raw_sql)){
		if (defined($this->where_fields()) and defined($this->where_values())){
			my $sql_frag = join(@{$this->where_fields()}. '=?', " and ");
			$this->{'raw_sql'} = $sql_frag;
		} elsif (defined($this->year()) and (defined($this->week()))){
			my $sql_frag  = '(year(date_added) = ?) AND (week(date_added,4) = ?)';
			$this->where_values([$this->year(), $this->week()]);
			$this->{'raw_sql'} = $sql_frag;
		} else {
			warn "No Raw SQL and no field to bind, cannot load";
			return undef;
		}
	}
	## we now have a raw SQL defined, let's build a statement
	my $raw_sql = $this->raw_sql();
	$this->sql_stmt_replace('__WHERE__', "($raw_sql)");
	## do it
	my $sth = $dbh->prepare($this->mss_stmt()) or $this->sql_error("Cannot prepare select: " . $dbh->errstr());
	if (defined($this->where_values())){
		for (my $i=0; $i<=$#{$this->where_values()}; $i++){
			$sth->bind_param($i+1, $this->where_values()->[$i]);
			warn " Binding ". $this->where_values()->[$i] . " to " . ($i+1) if ($this->DEBUG());
		}
	}
	$sth->execute() or $this->sql_error("Cannot Execute Select: ". $sth->errstr());
	$this->mss_list([]);
	while (my $row = $sth->fetchrow_hashref()){
		push @{$this->{'mss_list'}}, $row;
	}
	return $#{$this->mss_list()};
}

## process the notes for markdown
sub post_process_manuscripts($){
	my $this = shift;
	my $m = Text::Markdown->new;
	my $field_count=0; ## the number of fields with markdown processed. 
	##equals # of fields per MS with defined values * MS Count
	for (my $i=0;$i<=$#{$this->mss_list}; $i++){
		for my $field ("notes"){
	    	if (defined $this->mss_list()->[$i]->{$field}){ 
				$this->mss_list()->[$i]->{$field . "_html"} = $m->markdown($this->mss_list()->[$i]->{$field});
				$field_count++;
	    	}
	    } 
	}
	return $field_count;
}

## do a regex replace in the SQL statement
## takes 2 arguments, the macro and the desired value
sub sql_stmt_replace($$$){
	my $this = shift;
	my ($key, $value) = @_;
	my $temp_stmt = $this->mss_stmt();
	$temp_stmt =~ s/$key/$value/g;
	$this->mss_stmt($temp_stmt);
	warn " $temp_stmt" if ($this->DEBUG());
}

## sql error reporter
sub sql_error($$){
	my $this = shift;
	my $errstr = shift;
	warn " SQL ERROR " . $errstr;
	die;
}

1;
