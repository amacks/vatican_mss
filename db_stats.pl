#!/usr/bin/perl -w 

use strict;
use POSIX;
use POSIX qw(strftime);
use Text::Markdown;
use Getopt::Long;
use DateTime;
use Config::Simple;
use CGI;

use Data::Dumper;
use Encode;
use utf8;

use File::Basename;
use lib dirname($0) . "/lib/";
use Vatican::Config;
use Vatican::DB;
use BOHdb::JSON::GoogleChart;

## for the storage engine
use DBD::mysql;
use DBI qw(:sql_types);

## for formatting the output
use Template;

## constants
my $DEBUG=0;
my $template_filename = "weekly_stats.tt";
my $output_filename = "weekly_stats.html";

my $config = Vatican::Config->new();
## get some stats
my $vatican_db = new Vatican::DB();
my $dbh=$vatican_db->get_generate_dbh();


## SQL variables
my $weekly_stats_stmt = 'select year(date_added) as year_added, week(date_added)+1 as week_added, count(*) as ms_count
from __MS_TABLE__ where high_quality=1 and date_added > "2018-01-21 21:06:15"

group by year_added, week_added
order by year_added, week_added';

## returns a json string of all the weekly DB stats
sub get_weekly_stats(){
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
			my $data_point=$yearly_data->{$year}->{$i};
			if (!defined($data_point)){
				$data_point=0;
			}
			push @week, $data_point;
		}
		push @week_data, \@week;
	}
	warn Dumper(@week_data);
	## process the data for google chart

	my $json = BOHdb::JSON::GoogleChart->new();

	$json->add_column({ 'type' => 'string', 'label' => 'Week Number', 'id' => 'count'});
	for my $year (sort keys(%$yearly_data)){
		$json->add_column({ 'type' => 'number', 'label' => $year, 'id' => 'count'});
	}
	## load the data
	for my $one_week (@week_data){
		$json->add_row($one_week);
	}
	return $json->get_json();
}
my $filepath = undef; ## if defined, the root path where to output the file
GetOptions(
		'filepath=s' => \$filepath);

my $full_file = $filepath . '/'. $config->prefix() . $output_filename;

## at this point we have the graph as data, time to build a webpage with TT
my %tt_data = (
	'weekly_stats_json' => get_weekly_stats()
);
my $output;
my $tt = Template->new({
    INCLUDE_PATH => 'tt',
    INTERPOLATE  => 1,
    ENCODING     => 'utf8',
}) || die "$Template::ERROR\n";
$tt->process($template_filename,
	\%tt_data, \$output, {binmode => ':utf8'}
	)|| die $tt->error(), "\n";
## webpage is in $output, we just need to put it somewhere
warn "writing to $full_file";
open(OUTPUT_FILE, ">:utf8", $full_file) or die "Could not open file '$full_file'. $!";
print OUTPUT_FILE $output;
close(OUTPUT_FILE);