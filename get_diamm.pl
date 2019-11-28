#!/usr/bin/perl -w 


use strict;
use POSIX;
use POSIX qw(strftime);
## for all the HTTP work
use IO::Socket::SSL;
## there's nothing to "use" but we need it installed for SSL to verify
use Mozilla::CA;
use LWP::UserAgent;
use LWP::Simple;
use Config::Simple;

use HTML::TreeBuilder::XPath;
use Data::Dumper;
use Encode;
use utf8;

## local variables
my $url = 'https://www.diamm.ac.uk/archives/73/';
my $DEBUG=0;

sub get_url() {
	warn " Preparing to retrieve $url" if ($DEBUG);
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

sub get_items{
	my $html = shift || return undef;
	my $tree = HTML::TreeBuilder::XPath->new_from_content( $html );
	my @dates = $tree->findvalues('//tbody/tr/td[3]');
	my @titles = $tree->findvalues('//tbody/tr/td[4]');
	my @shelfmarks = $tree->findvalues('//tbody/tr/td[2]');
	my @urls = $tree->findvalues('//tbody/tr/td[2]/a/@href');
	## cleanup the shelfmarks
	for (my $i=0;$i<=$#shelfmarks;$i++){
		my $shelfmark = $shelfmarks[$i];
		$shelfmark =~ s/I-Rvat MS //gi;
		$shelfmark =~ s/\s+//g;
		$shelfmarks[$i] = $shelfmark;
	}
	warn "  ". ($#urls+1) . " MS" if ($DEBUG);
	return {
		'dates' => \@dates,
		'urls' => \@urls,
		'shelfmarks' => \@shelfmarks,
		'titles' => \@titles
	};
}

sub weave($){
	my $four_arrays = shift;
	my $one_array = [];
	for (my$i=0;$i<=$#{$four_arrays->{'shelfmarks'}}; $i++){
		push @$one_array, [
			$four_arrays->{'shelfmarks'}->[$i],
			$four_arrays->{'urls'}->[$i],
			$four_arrays->{'titles'}->[$i],
			$four_arrays->{'dates'}->[$i]

		];
	}
	return $one_array;
}

sub simple_csv($){
	my $data = shift;
	for my $row (@$data){
		print join(',', @$row) . "\n";
	}
}
simple_csv(weave(get_items(get_url())));
