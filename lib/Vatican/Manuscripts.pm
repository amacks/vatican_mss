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

has 'order' => (
	isa => 'Str',
	is => 'ro',
	default => 'sort_shelfmark asc'
	);

has 'limit' => (
	isa => 'Maybe[Str]',
	is => 'ro'
	);

#initial SQL statement
has 'mss_stmt' => (
	default => "select shelfmark, 
	title, author, incipit, notes, 
	thumbnail_url, date_added, lq_date_added, 
	high_quality, date, fond_code, week, year
from
(select 
 coalesce(ms1.shelfmark) as shelfmark, 
 max(ms1.high_quality) as high_quality, 
 max(ms1.date_added) as date_added, 
 max(ms2.date_added) as lq_date_added,
 max(ms1.title) as title,
 max(ms1.author) as author,
 max(ms1.incipit) as incipit,
 max(ms1.notes) as notes,
 max(ms1.thumbnail_url) as thumbnail_url,
 max(ms1.date) as date,
 max(ms1.sort_shelfmark) as sort_shelfmark,
 max(ms1.ignore) as `ignore`,
 max(ms1.fond_code) as fond_code,
 year(coalesce(max(ms1.date_added), max(ms2.date_added))) as year,
 week(coalesce(max(ms1.date_added), max(ms2.date_added)), 4) as week
 from
__MS_TABLE__ as ms1 left join __MS_TABLE__ as ms2
on ms1.shelfmark=ms2.shelfmark AND ms1.id>ms2.id
group by ms1.shelfmark) as hq_lq
 where
(__WHERE__) AND
hq_lq.ignore is false
ORDER by __ORDER__
__LIMIT__",
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
			my $sql_frag;
			for (my $i=0; $i<=$#{$this->where_fields()}; $i++){
				$sql_frag .= $this->where_fields()->[$i] . '=?';
				if ($i<$#{$this->where_fields()}){
					$sql_frag .= " and "; ## and if we are not the last
				}
			}
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
	## install an order statement
	$this->sql_stmt_replace('__ORDER__', $this->order());
	## put in limit if desired
	my $limit_stmt='';
	if (defined($this->limit())){
		$limit_stmt = "limit " . $this->limit();
	}
	$this->sql_stmt_replace('__LIMIT__', $limit_stmt);
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

## process the notes for markdown and url
sub post_process_manuscripts($){
	my $this = shift;
	my $m = Text::Markdown->new;
	my $config = new Vatican::Config();
	my $field_count=0; ## the number of fields with markdown processed. 
	##equals # of fields per MS with defined values * MS Count
	for (my $i=0;$i<=$#{$this->mss_list}; $i++){
		for my $field ("notes"){
	    	if (defined $this->mss_list()->[$i]->{$field}){ 
				$this->mss_list()->[$i]->{$field . "_html"} = $m->markdown($this->mss_list()->[$i]->{$field});
				$field_count++;
	    	}
	    }
	    ## now generate the proper URL for the entry with this manuscript
 		$this->mss_list()->[$i]->{'entry_url'} = $config->get_filename('',$this->mss_list()->[$i]->{'year'} ,$this->mss_list()->[$i]->{'week'} );
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
