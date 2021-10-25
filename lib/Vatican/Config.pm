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
                  isa => 'Str');
has 'db_host' => (is => 'ro', 
                  isa => 'Str');
has 'notes_table' => (is => 'ro', 
                  isa => 'Str');
has 'notes_previous_table' => (is => 'ro', 
                  isa => 'Str');
has 'notes_linked_table' => (is => 'ro', 
                  isa => 'Str');
has 'year_notes_table' => (is => 'ro', 
                  isa => 'Str');
has 'ms_table' => (is => 'ro', 
                  isa => 'Str');
has 'prefix' => (isa => 'Str',
                  is => 'ro',
                  default => '/vatican');
has 'base_url' => (is => 'ro', 
                  isa => 'Str');
has 'ms_base_url' => (is => 'ro', 
                  isa => 'Str');
has 'detail_base_url' => (is => 'ro', 
                  isa => 'Str');
has 'url_hostname' => (is => 'ro',
                       isa => 'Str');

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
  $this->{'prefix'} = $config_file->param("GLOBAL.PREFIX");
  $this->{'base_url'} = $config_file->param("GLOBAL.BASE_URL");
  $this->{'ms_base_url'} = $config_file->param("GLOBAL.MS_BASE_URL");
  $this->{'detail_base_url'} = $config_file->param("GLOBAL.DETAIL_BASE_URL");
  $this->{'url_hostname'} = $config_file->param("GLOBAL.URL_HOSTNAME");
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
  return $filepath . $this->prefix . '/' . $year . '/' . "week" . $week_number. ".html";
}


1;