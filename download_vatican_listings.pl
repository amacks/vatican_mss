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

## for the storage engine
use DBD::mysql;
  use DBI qw(:sql_types);

## timestamp formatting from 
##https://stackoverflow.com/questions/2149532/how-can-i-format-a-timestamp-in-perl
sub get_time 
{
    my $format = $_[0] || '%Y%m%d %I:%M:%S %p'; #default format: 20160801 10:48:03 AM
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    return strftime($format, localtime);
}
## constants
my $today_timestamp = get_time("%Y_%m_%d");
my $base_url="https://digi.vatlib.it/mss";
my $ms_base_url = "https://digi.vatlib.it/view/MSS_";
my @collections=("Autogr.Paolo.VI","Barb.gr","Barb.lat","Barb.or","Bonc","Borg.Carte.naut","Borg.ar","Borg.arm","Borg.cin","Borg.copt","Borg.ebr","Borg.eg","Borg.et","Borg.gr","Borg.ill","Borg.ind","Borg.isl","Borg.lat","Borg.mess","Borg.pers","Borg.sir","Borg.tonch","Borg.turc","Borgh","Capp.Giulia","Capp.Sist","Capp.Sist.Diari","Cappon","Carte.Stefani","Carte.d'Abbadie","Cerulli.et","Cerulli.pers","Chig","Comb","De.Marinis","Ferr","Legat","Neofiti","Ott.gr","Ott.lat","P.I.O","Pagès","Pal.gr","Pal.lat","Pap.Bodmer","Pap.Hanna","Pap.Vat.copt","Pap.Vat.gr","Pap.Vat.lat","Patetta","Raineri","Reg.gr","Reg.gr.Pio.II","Reg.lat","Ross","Ruoli","S.Maria.Magg","S.Maria.in.Via.Lata","Sbath","Sire","Urb.ebr","Urb.gr","Urb.lat","Vat.ar","Vat.arm","Vat.copt","Vat.ebr","Vat.estr.or","Vat.et","Vat.gr","Vat.iber","Vat.ind","Vat.lat","Vat.mus","Vat.pers","Vat.sam","Vat.sir","Vat.slav","Vat.turc");
my $DEBUG=1;
my $inital_load_end = '2018-01-21 21:06:15';

## for the database
my $config_file = "config/db.ini";

my $insert_stmt = "insert into __MS_TABLE__ (shelfmark, high_quality, thumbnail_url, date_added) values (?, ?, ?, now())";


warn $today_timestamp;

sub get_listing_html{
	my $collection = shift || return undef;
	my $collection_url = $base_url . '/' . $collection;
	my $html_content;
	warn " Preparing to retrieve $collection_url" if ($DEBUG);
	my $ua=new LWP::UserAgent;
    $ua->timeout(35);
    
    my $request = new HTTP::Request('GET', $collection_url); 
    my $response = $ua->request($request); 
    
    if ($response->is_error){
        warn "Unable to retrieve URL $collection_url: ". $response->status_line;
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

## take a HTML datafile, extract the items and return 2 arrays in a hash "good" and "low-quality"
sub get_items{
	my $html = shift || return undef;
	my $tree = HTML::TreeBuilder::XPath->new_from_content( $html );
	my @good_data = $tree->findvalues('//div[ @class = "item-thumbnail-list" ]//a[@class != "low-quality"]');
	warn "  ". ($#good_data+1) . " high-quality MS" if ($DEBUG);
	my @lq_data = $tree->findvalues('//div[ @class = "item-thumbnail-list" ]//a[@class = "low-quality"]');
	warn "  ". ($#lq_data+1) . " low-quality MS" if ($DEBUG);
	return {
		'high-quality' => \@good_data,
		'low-quality' => \@lq_data
	};
}

## connect to the DB, return a handle
sub get_dbh(){
	my $config = new Config::Simple($config_file) or die "Cannot read config file";
	my $ms_table = $config->param("GLOBAL.MS_TABLE");

	my $dbh=DBI->connect ("dbi:mysql:database=" . $config->param("GLOBAL.DATABASE") .
		":host=" . $config->param("GLOBAL.HOST"). ":port=3306'",
		$config->param("INSERT_DATABASE.USERNAME"), $config->param("INSERT_DATABASE.PASSWORD"), 
		{RaiseError => 0, PrintError => 0, AutoCommit => 1 }) 
	or die "Can't connect to the MySQL " . $config->param("GLOBAL.HOST") . '-' . $config->param("GLOBAL.DATABASE") .": $DBI::errstr\n";
    $dbh->{LongTruncOk} = 0;
    $dbh->do("SET OPTION SQL_BIG_TABLES = 1");
    $dbh->do('SET NAMES utf8');
    return $dbh;
}

## takes an argument, a hashref of the data
sub update_database{
	my $data = shift;
	if (!defined($data) || (ref($data) ne "HASH")){
		warn "update_database needs an argument of a hashref";
		return undef;
	} else {
		## connect to a DB
		my $dbh = get_dbh();
## now prepare a handle for the statement
		$insert_stmt =~ s/__MS_TABLE__/$ms_table/g;
		my $sth = $dbh->prepare($insert_stmt) or die "cannot prepare statement: ". $dbh->errstr();
		## do the good ones 
		my $rows_inserted = 0;
		$sth->bind_param(2, 1, SQL_INTEGER);
		for my $shelfmark (@{$data->{'high-quality'}}){
			$sth->bind_param(1, $shelfmark, SQL_VARCHAR);
			$sth->bind_param(3,"https://digi.vatlib.it/pub/digit/". $shelfmark . "/cover/cover.jpg", SQL_VARCHAR);
			my $insert_success = $sth->execute();
			if (defined($insert_success)){
				$rows_inserted++;
			} elsif ($sth->err() != 1062) {## 1062 is code for "duplicate key", we use that to handle only adding new values, so ignore those errors
				warn "Insert failure: ". $sth->errstr() . ' ' . $sth->err();
			}
		}
		# do the low-quality ones
		$sth->bind_param(2, 0, SQL_INTEGER);
		$sth->bind_param(3,undef, SQL_VARCHAR);
		for my $shelfmark (@{$data->{'low-quality'}}){
			$sth->bind_param(1, $shelfmark, SQL_VARCHAR);
			my $insert_success = $sth->execute();
			if (defined($insert_success)){
				$rows_inserted++;
			} elsif ($sth->err() != 1062) {## 1062 is code for "duplicate key", we use that to handle only adding new values, so ignore those errors
				warn "Insert failure: ". $sth->errstr() . ' ' . $sth->err();
			}
		}
		## we're done
		$dbh->disconnect();
		return $rows_inserted;
	}
}

## run some post-load updates to get linked data from other tables
sub post_import_update(){
	my %update_stmts = (
	ptolmey => 'update manuscripts as bav join
		(select shelfmark, group_concat(author SEPARATOR ", ") as author, group_concat(title SEPARATOR ", ") as title, 
		group_concat(concat("See [PAL](", url, ") for siglum ", siglum) SEPARATOR ", ") as notes 
		from ptolemy_sources group by shelfmark) as pal 
	on bav.shelfmark=pal.shelfmark
	set 
	bav.author= pal.author, bav.title=pal.title, bav.notes=pal.notes
	where bav.author is null and bav.title is null and bav.notes is null',
	);
	## now loop through the SQL and execute it
	my $dbh = get_dbh();
	for my $stm_key (sort keys %update_stmts){
		warn " Doing $stm_key update";
		my $sth = $dbh->prepare($update_stmts{$stm_key}) or warn "Cannot prepare $stm_key ". $dbh->errstr();
		if (defined($sth)){
			$sth->execute();
		}
	}
}

## Main body
print "Starting for ". ($#collections+1) . " collections on $today_timestamp\n";
my $total_count = 0;
for my $collection (@collections){
	my $html = get_listing_html($collection);
	if (defined($html)){
		my $item_hash = get_items($html);
		if (defined($item_hash)){
			my $row_count = update_database($item_hash);
			print " $row_count inserted for $collection \n";
			$total_count+=$row_count;
		} else {
			warn "No items found in $collection"
		}
	} else {
		warn "Failure downloading HTML for $collection";
	}
}
print "Done with $total_count inserted \n";
post_import_update();

