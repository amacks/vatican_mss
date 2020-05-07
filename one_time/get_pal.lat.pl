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
my $url_base = 'https://digi.ub.uni-heidelberg.de/de/bpd/virtuelle_bibliothek/codpallat';
my @filenames = ('0-99.html');
my $DEBUG=1;

sub get_url($) {
	my $filename = shift;
	my $url = $url_base . '/' . $filename;
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
	my @labels = $tree->findvalues('//ul[ @class="werke" ]/li[ @class="mit-thumbnail"] //strong');
	##my @urls = $tree->findvalues('//span[@class="refManuscrit"][contains(.,"Città del Vaticano")]/../a/@href');
	my @urls = $tree->findvalues('//ul[ @class="werke" ]/li[ @class="mit-thumbnail"] //a[ @class="thumbnail"]/@href');
	my @information = $tree->findvalues('//ul[ @class="werke" ]/li[ @class="mit-thumbnail"]/p[normalize-space(.)]');
	warn "  ". ($#urls+1) . " MS" if ($DEBUG);
	## cleanup information
	map { s/Pal\. lat\. \d{1,4}\s*//}  @information;
	map { s/([a-z])([A-Z0-9])/$1; $2/g } @information;
	map { s/,/;/g } @information;
	map { s/Pal\. lat\. /pal.lat./} @labels;
	return {
		'labels' => \@labels,
		'urls' => \@urls,
		'info' => \@information
	};
}

sub weave($){
	my $two_arrays = shift;
	my $one_array = [];
	for (my$i=0;$i<=$#{$two_arrays->{'labels'}}; $i++){
		push @$one_array, [
			$two_arrays->{'labels'}->[$i],
			$two_arrays->{'urls'}->[$i],
			$two_arrays->{'info'}->[$i]
		];
	}
	return $one_array;
}

sub simple_csv($){
	my $data = shift;
	for my $row (@$data){
		print encode('UTF-8', join(',', @$row) . "\n");
	}
}
my @all_manuscripts;
##generate coded filenames
for (my $i=1;$i<=20;$i++){
	push @filenames, ${i}."xx.html";
}
for my $filename (@filenames){
	#warn Dumper(weave(get_items(get_url($filename))));
	push @all_manuscripts, @{weave(get_items(get_url($filename)))};
}
simple_csv(\@all_manuscripts);