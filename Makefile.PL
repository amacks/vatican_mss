use ExtUtils::MakeMaker 6.64;

WriteMakefile(
    'NAME' => 'vatican_mss',
    BUILD_REQUIRES => {
	    'Template::Toolkit' => 0,
		'IO::Socket::SSL' => 0,
		'Mozilla::CA' => 0,
		'LWP::UserAgent' => 0,
		'LWP::Simple' => 0,
		'HTML::TreeBuilder::XPath' => 0,
		'DBI' => 0,
		'DBD::mysql' => 0,
		'Text::Markdown' => 0,
		'Data::Dumper' => 0,
		'Template::Plugin::POSIX' => 0,
		'Template::Plugin::Date' => 0,
		'DateTime' => 0,
		'Config::Simple' => 0,
		'Getopt::Long' => 0,
		"Roman" => 0,
		"LWP::Protocol::https" => 0,
		"List::Compare" => 0,
    },
    test => {TESTS => 't/*.t'}
);
