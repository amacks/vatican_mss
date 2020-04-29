#!/usr/bin/perl

package Vatican::Config;

use strict;
use Exporter;

use Config::Simple;
use Data::Dumper;
use Encode;
use utf8;
use Moose;



## Constants
my $config_file = "config/db.ini";

## Moose variables
has 'db_name' => (is => 'ro', 
                  isa => 'String');
has 'db_host' => (is => 'ro', 
                  isa => 'String');
has 'notes_table' => (is => 'ro', 
                  isa => 'String');
has 'notes_previous_table' => (is => 'ro', 
                  isa => 'String');
has 'notes_linked_table' => (is => 'ro', 
                  isa => 'String');
has 'year_notes_table' => (is => 'ro', 
                  isa => 'String');
has 'ms_table' => (is => 'ro', 
                  isa => 'String');
has 'prefix' => (isa => 'String',
                  is => 'ro',
                  default => 'vatican')
has 'generate_database' =>(traits    => ['Hash'],
    is        => 'ro',
    isa       => 'HashRef[Str]',
    default   => sub { {} },
    handles   => {
          get_generate_db     => 'get',
    #     has_no_options => 'is_empty',
          num_generate_db    => 'count',
    #     delete_option  => 'delete',
    #     option_pairs   => 'kv',
     },
);
has 'insert_database' =>(traits    => ['Hash'],
    is        => 'ro',
    isa       => 'HashRef[Str]',
    default   => sub { {} },
    handles   => {
          get_insert_db     => 'get',
    #     has_no_options => 'is_empty',
          num_insert_db    => 'count',
    #     delete_option  => 'delete',
    #     option_pairs   => 'kv',
    },
);


## post constructor data loader
sub BUILD {
	my $this = shift;
	my $config_file = new Config::Simple($config_file) or die "Cannot read config file";
	## global parameters
	$this->{'db_name'} = $config_file->param("GLOBAL.DATABASE");
	$this->{'db_host'} = $config_file->param("GLOBAL.HOST");
  $this->{'notes_table'} = $config_file->param("GLOBAL.NOTES_TABLE");
  $this->{'notes_linked_table'} = $config_file->param("GLOBAL.NOTES_LINKED_TABLE");
  $this->{'notes_previous_table'} = $config_file->param("GLOBAL.NOTES_PREVIOUS_TABLE");
  $this->{'year_notes_table'} = $config_file->param("GLOBAL.YEAR_TABLE");
	$this->{'ms_table'} = $config_file->param("GLOBAL.MS_TABLE");
	## hashes for sub configs
	my $generate = {
		'username' => $config_file->param("GENERATE_DATABASE.USERNAME"),
		'password' => $config_file->param("GENERATE_DATABASE.PASSWORD")
	};
	my $insert = {
		'username' => $config_file->param("INSERT_DATABASE.USERNAME"),
		'password' => $config_file->param("INSERT_DATABASE.PASSWORD")
	};
	$this->{'generate_database'} = $generate;
	$this->{'insert_database'} = $insert;
}


sub get_filename($$$$){
  my $this = shift;
  my ($filepath,$year,$week_number) = @_;
  return $this->prefix . '/' . $year . '/' . "week" . $week_number. ".html";
}


1;