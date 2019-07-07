#!/usr/bin/perl -w 

use strict;
use POSIX;
use POSIX qw(strftime);
use Text::Markdown;
use Getopt::Long;
use DateTime;


use Data::Dumper;
use Encode;
use utf8;
use Config::Simple;

## for the storage engine
use DBD::mysql;
use DBI qw(:sql_types);

## for formatting the output
use Template;

## timestamp formatting from 
##https://stackoverflow.com/questions/2149532/how-can-i-format-a-timestamp-in-perl
sub get_time 
{
    my $format = $_[0] || '%Y%m%d %I:%M:%S %p'; #default format: 20160801 10:48:03 AM
    return strftime($format, localtime);
}

sub get_week_and_year($){
	my $week_offset = shift;
	my $offset_date = DateTime->now->subtract(days => 7*$week_offset);
	my ($week_year, $week_number) = $offset_date->week;
	return {
		'year' => $week_year,
		'week' => $week_number
	};
}
## constants
my $today_timestamp = get_time('%Y_%m_%d');

my $header = "";
my $footer = "";
my $template_filename = "index.tt";
my $url_prefix = "/aaronm/vatican";

## for the database
my $config_file = "config/db.ini";
my $db_stmt = "select year, week_number, header_text, image_filename from __TABLE__ order by year desc, week_number desc";

sub get_notes(){
	## do some config reading
	my $config = new Config::Simple($config_file) or die "Cannot read config file";
	my $db_table = $config->param("GLOBAL.NOTES_TABLE");
	## connect to a DB

	my $dbh=DBI->connect ("dbi:mysql:database=" . $config->param("GLOBAL.DATABASE") .
		":host=" . $config->param("GLOBAL.HOST"). ":port=3306'",
		$config->param("GENERATE_DATABASE.USERNAME"), $config->param("GENERATE_DATABASE.PASSWORD"), 
		{RaiseError => 0, PrintError => 0, AutoCommit => 1 }) 
	or die "Can't connect to the MySQL " . $config->param("GLOBAL.HOST") . '-' . $config->param("GLOBAL.DATABASE") .": $DBI::errstr\n";
    $dbh->{LongTruncOk} = 0;
    $dbh->do("SET OPTION SQL_BIG_TABLES = 1");
    $dbh->do('SET NAMES utf8');
    ## regex to swap in the table name
    $db_stmt =~ s/__TABLE__/$db_table/g;
## now prepare a handle for the statement
	my $sth = $dbh->prepare($db_stmt) or die "cannot prepare report statement: ". $dbh->errstr();
	## now do the query
	$sth->execute() or die "cannot run query: " . $sth->errstr();
	my $weeks_notes = [];
	my $m = Text::Markdown->new;
	while (my $row = $sth->fetchrow_hashref()){
	    for my $field ("header_text"){
		$row->{$field . "_html"} = $m->markdown($row->{$field});
	    }
	    push @$weeks_notes, $row;
	}
	$sth->finish();
	$dbh->disconnect();
	return $weeks_notes;
}

sub format_page{
	my ($weeks_notes) = @_;
	if (!defined($weeks_notes) || (ref($weeks_notes) ne "ARRAY")){
		warn " weeks_notes requires an argument of an arrayref to a list of notes";
		return undef;
	} else {
		## setup the template system
		my %data = (
				'weeks_notes' => $weeks_notes,
				'url_prefix' => $url_prefix,
			);
		my $output;
		my $tt = Template->new({
		    INCLUDE_PATH => 'tt',
		    INTERPOLATE  => 1,
		    ENCODING     => 'utf8',
		}) || die "$Template::ERROR\n";
		$tt->process($template_filename,
			\%data, \$output, {binmode => ':utf8'}
			)|| die $tt->error(), "\n";
    	return $header . $output .$footer;
	}
}

print format_page(get_notes());


