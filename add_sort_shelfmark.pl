#!/usr/bin/perl -w 

use strict;
use POSIX;
use POSIX qw(strftime);

use Getopt::Long;

use Data::Dumper;
use Encode;
use utf8;

## for the storage engine
use DBD::mysql;
use DBI qw(:sql_types);

use File::Basename;
use lib dirname($0) . "/lib/";
use Vatican::Config;
use Vatican::DB;


sub get_unsorted_records($){
	my $dbh = shift;
	my @rows;
	my $statement = "select id, shelfmark from manuscripts where sort_shelfmark is null";
	my $sth = $dbh->prepare($statement) or die ("Cannot prepare statement ". $dbh->errstr());
	$sth->execute() or die("Cannot execute ". $sth->errstr());
	while (my $row = $sth->fetchrow_hashref()){
		push @rows, [$row->{'id'},  $row->{'shelfmark'}];
	}
	return \@rows;
}

sub update_records($$){
	my ($dbh, $records) = @_;
	my $sth = $dbh->prepare("update manuscripts set sort_shelfmark=? where id=?") or die("cannot prepare update ". $dbh->errstr());
	my $count=0;
	for my $record (@$records){
		$sth->bind_param(1,$record->[2]);
		$sth->bind_param(2,$record->[0]);
		$sth->execute() or die("Cannot execute ". $sth->errstr());
		$count++;
	}
	return $count;
}

my $vatican_db = new Vatican::DB();
my $dbh=$vatican_db->get_insert_dbh();## now prepare a handle for the statement
my $raw_records = get_unsorted_records($dbh);
## generate the new shelfmarks
for (my $i=0;$i<=$#{$raw_records};$i++){
	push $raw_records->[$i], Vatican::DB::generate_sort_shelfmark($raw_records->[$i]->[1]);
}
print "Records updated: ". update_records($dbh, $raw_records)
