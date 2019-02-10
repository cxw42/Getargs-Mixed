use 5.008;
use ExtUtils::MakeMaker;
use File::Spec;

# Reminder: when bumping the version, also update 'provides' below.
my $source = File::Spec->catfile(qw(lib Getargs Mixed.pm));

WriteMakefile(
	NAME			=> 'Getargs::Mixed',
	VERSION_FROM	=> $source,
	ABSTRACT_FROM	=> $source,

	LICENSE			=> 'perl_5',
	AUTHOR			=> 'Andrew Sterling Hanenkamp <hanenkamp@users.sourceforge.net>',

	MIN_PERL_VERSION=> '5.008',
	PREREQ_PM => {
		'Carp' => '0',
		'Exporter' => '0',
		'strict' => '0',
		'warnings' => '0',
	},
	CONFIGURE_REQUIRES => {
		'ExtUtils::MakeMaker' => '0',
		'File::Spec' => '3.2701',	# for a Win32 bugfix
	},

	META_MERGE => {
		'meta-spec' => { version => 2 },

		resources => {
			# RT is still the bug tracker
			bugtracker  => {
				web	=> 'https://rt.cpan.org/Public/Dist/Display.html?Name=Getargs-Mixed',
				mailto => 'bug-Getargs-Mixed@rt.cpan.org',
			},

			# The code is on GitHub
			repository => {
				type => 'git',
				url  => 'https://github.com/cxw42/Getargs-Mixed.git',
				web  => 'https://github.com/cxw42/Getargs-Mixed',
			},
		},

		x_contributors => [
			'Christopher White <cxw@cpan.org>',
		],

		provides => {
			'Getargs::Mixed' => {
				file => 'Mixed.pm',
				version => '1.03_1',
			},
		},
	},

	dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean => { FILES => 'Build-Hopen-*' },
);
