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

## local tools
use File::Basename;
use lib dirname($0) . "/lib";
use Vatican::Config;
use Vatican::DB;
use Vatican::Entries;
my $url_prefix;




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
my $main_template_filename = "index.tt";
my $year_template_filename = "year_index.tt";
my $filepath_suffix = "vatican/";

## for the database
my $years_stmt = "select year, header_text from __YEAR_TABLE__";

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

##returns an arrayref to a list of the year and year headers known in the DB
sub get_years(){
	my $config = new Vatican::Config();
	my $year_table = $config->year_notes_table();
	## connect to a DB

	my $dbh=Vatican::DB->new()->get_generate_dbh();
    my $stmt = sql_replace($years_stmt, 'year_table', $year_table);
    my $sth = $dbh->prepare($stmt) or die "cannot prepare report statement: ". $dbh->errstr();
	## now do the query
	$sth->execute() or die "cannot run query: " . $sth->errstr();
	my @years=();
	my $m = Text::Markdown->new;
	while (my $row = $sth->fetchrow_hashref()){
	    for my $field ("header_text"){
			$row->{$field . "_html"} = $m->markdown($row->{$field});
	    }
	    push @years, $row;
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
	my $entries;
	if ($options->{'mode'} eq 'top' ){
		$entries = Vatican::Entries->new(order => 'year desc, week_number desc',
			limit => 7);
	} elsif ($options->{'mode'} eq 'year'){
		$entries = Vatican::Entries->new(order => 'year desc, week_number desc',
			where_fields => ['year'], where_values => [$options->{'year'}]);
	} else {
		die "unknown mode";
	}
	## extract the entries data
	my $all_notes;
	for my $entry (@{$entries->entries_data()}){
		push @{$all_notes}, $entry->entry_data();
	}
	return $all_notes;
}

sub format_page{
	my ($weeks_notes, $mode, $year, $year_notes_html) = @_;
	if (!defined($weeks_notes) || (ref($weeks_notes) ne "ARRAY")){
		warn " weeks_notes requires an argument of an arrayref to a list of notes";
		return undef;
	} else {
		## setup the template system
		my %data = (
				'weeks_notes' => $weeks_notes,
				'url_prefix' => $url_prefix,
				'year' => $year,
			);
		my $output;
		my $tt = Template->new({
		    INCLUDE_PATH => 'tt',
		    INTERPOLATE  => 1,
		    ENCODING     => 'utf8',
		}) || die "$Template::ERROR\n";
		## set the right template
		my $template_filename = $main_template_filename; ## set this as default
		if ($mode eq "top"){
			$template_filename = $main_template_filename;
		} elsif ($mode eq "year"){
			$template_filename = $year_template_filename;
			$data{'year_notes'} = $year_notes_html;
		} else {
			warn "mode unknown";
		}
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
my $config = new Vatican::Config();
$url_prefix = $config->prefix();

if (defined($filepath)){
	my $full_filepath = $filepath . $filepath_suffix;
	## top level index
	my $index_html= format_page(get_notes({mode=>'top'}), "top");

	my $filename = $full_filepath . "/index.html" ;
	warn "writing to $filename";
	open(OUTPUT_FILE, ">:utf8", $filename) or die "Could not open file '$filename'. $!";
	print OUTPUT_FILE $index_html;
	close(OUTPUT_FILE);
	## now genrate annual indexes
	my $years = get_years();
	for my $year_row (@$years){
		my $year_html = format_page(
				get_notes({mode=>'year', year=>$year_row->{'year'}}), 
				"year", $year_row->{'year'}, $year_row->{'header_text_html'});
		my $filename = $full_filepath . "/" . $year_row->{'year'} . "/index.html" ;
		warn "writing to $filename";
		open(OUTPUT_FILE, ">:utf8", $filename) or die "Could not open file '$filename'. $!";
		print OUTPUT_FILE $year_html;
		close(OUTPUT_FILE);
	}
} else {
	print "--filepath is a required argument";
}

