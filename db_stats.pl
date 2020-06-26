#!/usr/bin/perl -w 

use strict;
use POSIX;
use POSIX qw(strftime);
use Text::Markdown;
use Getopt::Long;
use DateTime;
use Config::Simple;

use Data::Dumper;
use Encode;
use utf8;

use File::Basename;
use lib dirname($0) . "/lib/";
use Vatican::Config;
use Vatican::DB;

## for the storage engine
use DBD::mysql;
use DBI qw(:sql_types);

## for formatting the output
use Template;

## constants
my $DEBUG=0;

my $config = Vatican::Config->new();

## SQL variables
my $weekly_stats_stmt = 'select year(date_added) as year_added, week(date_added)+1 as week_added, count(*) as ms_count
from __MS_TABLE__ where high_quality=1 and date_added > "2018-01-21 21:06:15"

group by year_added, week_added
order by year_added, week_added';

## get some stats
my $vatican_db = new Vatican::DB();
my $dbh=$vatican_db->get_generate_dbh();

## get a list of years
my $ms_table = $config->ms_table();
$weekly_stats_stmt =~ s/__MS_TABLE__/$ms_table/g;
my $sth = $dbh->prepare($weekly_stats_stmt) or die "cannot prepare report statement: ". $dbh->errstr();

$sth->execute() or die "Cannot execute: " . $sth->errstr;
my $yearly_data;
while (my $row= $sth->fetchrow_hashref()){
	$yearly_data->{$row->{'year_added'}}->{$row->{'week_added'}} = $row->{'ms_count'};
}
my @week_data;
for (my $i=1;$i<=53;$i++){
	my @week = ($i);
	for my $year (sort keys(%$yearly_data)){
		push @week, $yearly_data->{$year}->{$i};
	}
	push @week_data, \@week;
}

warn Dumper(@week_data);