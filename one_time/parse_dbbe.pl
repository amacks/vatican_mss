#!/usr/bin/perl -w 


use strict;
use POSIX;
use POSIX qw(strftime);

use HTML::TreeBuilder::XPath;
use Data::Dumper;
use Encode;
use utf8;

## local variables
my $url = 'https://liturgicum.irht.cnrs.fr/fr/manuscrits/index?lettre=C';
my $DEBUG=0;

sub get_items{
	my $html = shift || return undef;
	my $tree = HTML::TreeBuilder::XPath->new_from_content( $html );
	my @dates = $tree->findvalues('//tr[ @class="" ]/td[2]');
	my @titles = $tree->findvalues('//tr[ @class="" ]/td[3]');
	my @shelfmarks = $tree->findvalues('//tr[ @class="" ]/td[1]');
	## parse the string like VATICAN CITY - Biblioteca Apostolica Vaticana - Palat. gr. 149
	## into palat.gr.149
	for (my $i=0;$i<=$#shelfmarks;$i++){
		my $shelfmark = $shelfmarks[$i];
		my @sm_parts = split(/ - /, $shelfmark);
		$shelfmark = $sm_parts[2];
		$shelfmark =~ s/\s+//g;
		$shelfmarks[$i] = $shelfmark;
	}
	my @urls = $tree->findvalues('//tr[ @class="" ]/td[1]/a/@href');
	warn "  ". ($#urls+1) . " MS" if ($DEBUG);
	return {
		'shelfmarks' => \@shelfmarks,
		'urls' => \@urls,
		'titles' => \@titles,
		'dates' => \@dates
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


my $html;
while (<>){
	$html .= $_;
}
$html = decode('UTF-8', $html);
simple_csv(weave(get_items($html)));
