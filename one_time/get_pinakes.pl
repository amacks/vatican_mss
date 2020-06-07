#!/usr/bin/perl -w 


use strict;
use POSIX;
use POSIX qw(strftime);

use HTML::TreeBuilder::XPath;
use Data::Dumper;
use Encode;
use Roman;
use LWP;
use utf8;

## local variables
my %fonds = (
	'vat.gr' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1403/',
	'ott.gr' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1388/',
	'pal.gr' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1391/',
	'pal.lat' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1392/',
	'reg.lat' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1839/',
	'ross' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1397/',
	'barb.gr' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1380/',
	'sbath' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1398/',
	'urb.gr' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1400/',
	'urb.lat' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1402/',
	'vat.lat' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1404/',
	'vat.sir' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1405/',
	'vat.copt' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1671/',
	'vat.ar' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1840/',
	'barb.lat' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1381/',
	'bonc' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1382/',
	'borg.copt' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1383/',
	'borg.gr' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1384/',
	'borg.lat' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1385/',
	'chig' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1386/',
	'arch.cap.s.pietro' => 'https://pinakes.irht.cnrs.fr/notice/fonds/1379/'
);
my $base_url = "https://pinakes.irht.cnrs.fr";
my $DEBUG=0;

sub get_url($) {
	my $url = shift;
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
	my $fond = shift;
	my $tree = HTML::TreeBuilder::XPath->new_from_content( $html );
	my @shelfmarks = $tree->findvalues('//table[@id="villes"]/tbody/tr/td[1]');
	## parse the string like I-Rvat : Barb. lat 0711
	## into Barb.lat.711
	for (my $i=0;$i<=$#shelfmarks;$i++){
		my $shelfmark = $shelfmarks[$i];
		$shelfmark =~ s/^0+//g;
		$shelfmark =~ s/\s0*//g;
		$shelfmark = $fond . '.' . $shelfmark;
		$shelfmarks[$i] = $shelfmark;
	}
	my @urls = $tree->findvalues('//table[@id="villes"]/tbody/tr/td[1]/a/@href');
	for (my $i=0;$i<=$#urls;$i++){
		$urls[$i] =$base_url . $urls[$i];
	}
	warn "  ". ($#urls+1) . " MS" if ($DEBUG);
	return {
		'shelfmarks' => \@shelfmarks,
		'urls' => \@urls
	};
}

sub weave($){
	my $four_arrays = shift;
	my $one_array = [];
	for (my$i=0;$i<=$#{$four_arrays->{'shelfmarks'}}; $i++){
		push @$one_array, [
			$four_arrays->{'shelfmarks'}->[$i],
			$four_arrays->{'urls'}->[$i]

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


for my $fond (sort keys(%fonds)){
	warn "\t Fond: $fond";
	my $html = get_url($fonds{$fond});
	warn length($html);
	simple_csv(weave(get_items($html, $fond)));

}

