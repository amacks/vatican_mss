#!/usr/bin/perl

package Vatican::Detail;
## package for downloading and parsing the detail page from a manuscript

use strict;
use Exporter;

use Data::Dumper;
use Encode;
use utf8;
use Moose;
use LWP;
use LWP::UserAgent;
use HTML::TreeBuilder::XPath;
use List::Compare;

use File::Basename;
use lib dirname($0) . "/lib/";
use Vatican::Config;

## Constants
my @ignore_entries = ( '1)(Shelfmark Only)'); ## array of meaningless entries to ignore
my $DEBUG = undef;

## Moose class variables

has 'shelfmark' => (
	is => 'ro',
	isa => 'Str'
);

has 'description_html' => (
	is => 'rw',
	isa => 'Maybe[Str]'
);
has 'detail_page' => (
	is => 'rw',
	isa => 'Bool'
	);

has 'bib_entries' => (
	is => 'rw',
	isa => 'Maybe[ArrayRef]');

has 'detail_entries' => (
	is => 'rw',
	isa => 'Maybe[ArrayRef]');


sub BUILD{
	my $this = shift;
	if (!defined($this->shelfmark())){
		warn "Cannot create a detail without a shelfmark";
		return undef
	} else {
		$this->get_catalogue_data();
	}
}
## takes the complete HTML of a description page and parses it to count the number of description items and the number 
## of bibiligraphy entries
sub process_description_html($){
	my $this = shift;
	## sometimes there are just self links.  Those are ignorable.
	my $tree = HTML::TreeBuilder::XPath->new_from_content( $this->description_html() );
	## first check if we got the "no page" page
	if ($tree->exists("//span[ contains(text(), 'No record match') ]")){
		$this->detail_page(undef);
		warn "no recrods";
		return undef;
	} else {
		$this->detail_page(1);
		## HTML is not well formed. Need to get a list of all details and then subtract the bibliography
			## each entry looks like
		## <div class="row-title"><a href="/mss/detail/192068"><div class="row-mss-title">
		## <div class="order">5)</div><div class="title">Ghilardi, Massimiliano 
		## «Non fuimus et fuimus». Gaetano Marini e le reliquie, In Gaetano Marini 
		## (1742-1815) protagonista della cultura europea: scritti per il bicentenario 
		## della morte: II, a cura di Marco Buonocore (Studi e testi, 493), 2015
		##</div></div></a>
		my @all_entries = $tree->findvalues('//div[ @class="row-title" ]');
		## section for bibliography begins <div class="bibliographic_ref_label">
		my @bib_entries = $tree->findvalues('//div[ @class="bibliographic_ref_label" ]/following::div[ @class="row-title" ]');
		## now add the bibliography entries to the ignore list
		@ignore_entries = (@ignore_entries, @bib_entries);
		my $lc = List::Compare->new( {
	    	lists    => [\@all_entries, \@ignore_entries]
	    	});
		my @detail_entries = $lc->get_unique();
		## now set some values, if they exist
		$this->bib_entries(\@bib_entries);
		$this->detail_entries(\@detail_entries);
		return 1;
	}
}

## gets the detail page and processes it.  Needs three arguments inside a hash
## shelfmark
## vatican_db handle for updating the record
## base of the detail url from the config 
sub get_catalogue_data($){
	my $this = shift;

	my $config = new Vatican::Config();
	my $detail_base_url = $config->detail_base_url();

	my $description_html = get_url_content(
		$detail_base_url . $this->shelfmark());
	if (defined($description_html)){
		warn "we got a description page" if ($DEBUG);
		$this->description_html($description_html);
		$this->process_description_html();
	} else {
		warn "no description in BAV";
	}
}

## helper functions for getting counts, since it's so common
sub get_bib_count($){
	my $this = shift;
	return 1+$#{$this->bib_entries()};
}
sub get_detail_count($){
	my $this = shift;
	return 1+$#{$this->detail_entries()};
}

sub detail_page_exists($){
	my $this = shift;
	return $this->detail_page();
}

## Static functions
## just a simple get of a url
sub get_url_content($){
	my $url = shift;
	my $html_content;

	my $ua=new LWP::UserAgent;
    $ua->timeout(35);
    
    my $request = new HTTP::Request('GET', $url); 
    my $response = $ua->request($request); 
    
    if ($response->is_error){
        warn "Unable to retrieve URL $url: ". $response->status_line;
        return undef;
    } else {
        warn " Page retrieved" if ($DEBUG);
        $html_content = $response->content;
        #warn $html_content if ($DEBUG);
    }
    ## decode utf8
    $html_content= decode('UTF-8', $html_content);
    return $html_content;
}


1;