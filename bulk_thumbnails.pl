
my $filepath = undef; ## if defined, the root path where to output the file
GetOptions(
		'filepath=s' => \$filepath);

if (defined($data->{'filepath'})){
	my $config = new Vatican::Config();
	my $ms_table = $config->ms_table();
	## connect to a DB
	my $vatican_db = new Vatican::DB();
	my $dbh=$vatican_db->get_insert_dbh();
## now prepare a handle for the statement
	my $report_stmt = " select shelfmark year(date_added) as year, thumbnail_url from manuscripts where thumbnail_url like 'http%'' and high_quality=1";
	my $sth = $dbh->prepare($report_stmt) or die "cannot prepare report statement: ". $dbh->errstr();
	## now do the query
	$sth->execute() or die "cannot run report: " . $sth->errstr();
	while (my $row = $sth->fetchrow_hashref()){
		my $local_filepath = $data->{'filepath'} . "/" . $row->{'year'} . '/thumbnails';
		my $local_filename =  $row->{'shelfmark'} . ".jpg";
		my $http_response = getstore($row->{'thumbnail_url'}, $local_filepath . '/' . $local_filename);
		if (!is_error($http_response)){
			my $local_thumbnail_code = $vatican_db->set_local_thumbnail($row->{'shelfmark'}, $local_filename);
			if (!defined($local_thumbnail_code)){
				warn "Some sort of error setting the local thumbnail";
			}
		} else {
			warn "Some sort of error in downloading the image for " . $shelfmark;
			warn $http_response;
		}
	}
	$sth->finish();
	$dbh->disconnect();
	return $manuscripts;

}