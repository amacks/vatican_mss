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
## constants
my $today_timestamp = get_time('%Y_%m_%d');

my $header = "";
my $footer = "";
my $template_filename = "index.tt";
my $url_prefix = "/vatican";

## for the database
my $config_file = "config/db.ini";
my $db_stmt_master = "select year, week_number, header_text, image_filename from __TABLE__ __WHERE__ order by year desc, week_number desc __LIMIT__";
my $years_stmt = "select distinct year from __TABLE__";

## sql subroutines
## replace a single macro in the SQL statement
sub sql_replace($$$){
	my ($stmt, $field_name, $field_value) = @_;
	my $field_macro = '__' . uc($field_name) . '__';
	$stmt =~ s/$field_macro/$field_value/g;
	return $stmt;
}

## remove any unused macros from the SQL statement
sub sql_cleanup($){
	my $stmt = shift;
	$stmt =~ s/__[A-Z]+__//g;
	return $stmt;
}

##returns an arrayref to a list of the years known in the DB
sub get_years(){
	my $config = new Config::Simple($config_file) or die "Cannot read config file";
	my $db_table = $config->param("GLOBAL.NOTES_TABLE");
	## connect to a DB

	my $dbh=DBI->connect ("dbi:mysql:database=" . $config->param("GLOBAL.DATABASE") .
		":host=" . $config->param("GLOBAL.HOST"). ":port=3306'",
		$config->param("GENERATE_DATABASE.USERNAME"), $config->param("GENERATE_DATABASE.PASSWORD"), 
		{RaiseError => 0, PrintError => 0, AutoCommit => 1, mysql_enable_utf8 => 1 }) 
	or die "Can't connect to the MySQL " . $config->param("GLOBAL.HOST") . '-' . $config->param("GLOBAL.DATABASE") .": $DBI::errstr\n";
    $dbh->{LongTruncOk} = 0;
    $dbh->do("SET OPTION SQL_BIG_TABLES = 1");
    $dbh->do('SET NAMES utf8');
    my $stmt = sql_replace($years_stmt, 'table', $db_table);
    my $sth = $dbh->prepare($stmt) or die "cannot prepare report statement: ". $dbh->errstr();
	## now do the query
	$sth->execute() or die "cannot run query: " . $sth->errstr();
	my @years=();
	while (my $row = $sth->fetchrow_hashref()){
	    push @years, $row->{'year'};
	}
	$sth->finish();
	$dbh->disconnect();
	return \@years;
}

sub get_notes{
	my $options = shift;
	## set some defaults
	if (!defined($options) || ref($options) ne "HASH"){
		$options = {};
	}
	if (!defined($options->{'mode'})){
		## default mode is "top level"
		$options->{'mode'} = 'top';
	}
	if ($options->{'mode'} eq 'year' && !defined($options->{'year'})){
		## default year is this year
		$options->{'year'} = get_time('%Y');
	}
	my $db_stmt = $db_stmt_master;
	## do some config reading
	my $config = new Config::Simple($config_file) or die "Cannot read config file";
	my $db_table = $config->param("GLOBAL.NOTES_TABLE");
	## connect to a DB

	my $dbh=DBI->connect ("dbi:mysql:database=" . $config->param("GLOBAL.DATABASE") .
		":host=" . $config->param("GLOBAL.HOST"). ":port=3306'",
		$config->param("GENERATE_DATABASE.USERNAME"), $config->param("GENERATE_DATABASE.PASSWORD"), 
		{RaiseError => 0, PrintError => 0, AutoCommit => 1, mysql_enable_utf8 => 1 }) 
	or die "Can't connect to the MySQL " . $config->param("GLOBAL.HOST") . '-' . $config->param("GLOBAL.DATABASE") .": $DBI::errstr\n";
    $dbh->{LongTruncOk} = 0;
    $dbh->do("SET OPTION SQL_BIG_TABLES = 1");
    $dbh->do('SET NAMES utf8');
    ## regex to swap in the table name
    $db_stmt = sql_replace($db_stmt, 'table', $db_table);
    if ($options->{'mode'} eq 'year') {
    	$db_stmt = sql_replace($db_stmt, 'where', "where year=$options->{'year'}");
    }
    if ($options->{'mode'} eq 'top') {
    	$db_stmt = sql_replace($db_stmt, 'limit', "limit 7");
    }
    $db_stmt = sql_cleanup($db_stmt);
    warn $db_stmt;
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

## real code, first get a filepath if desired
my $week_offset=0;
my $filepath = undef; ## if defined, the root path where to output the file
GetOptions(
		'filepath=s' => \$filepath);


if (defined($filepath)){
	## top level index
	my $index_html= format_page(get_notes({mode=>'top'}));

	my $filename = $filepath . "/index.html" ;
	warn "writing to $filename";
	open(OUTPUT_FILE, ">:utf8", $filename) or die "Could not open file '$filename'. $!";
	print OUTPUT_FILE $index_html;
	close(OUTPUT_FILE);
	## now genrate annual indexes
	my $years = get_years();
	for my $year (@$years){
		my $year_html = format_page(get_notes({mode=>'year', year=>$year}));
		my $filename = $filepath . "/" . $year . "/index.html" ;
		warn "writing to $filename";
		open(OUTPUT_FILE, ">:utf8", $filename) or die "Could not open file '$filename'. $!";
		print OUTPUT_FILE $year_html;
		close(OUTPUT_FILE);
	}
} else {
	print "--filepath is a required argument";
}

