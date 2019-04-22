use 5.006;
use strict;
use warnings;
use Config;
use ExtUtils::MakeMaker;
use File::Spec;

my $source = File::Spec->catfile(qw(lib Getargs Mixed.pm));
my $secure_perl_path = get_perl_filename();
my $provides;
my $is_trial;

# Get the filename of the Perl interpreter running this. {{{1
# Modified from perlvar.
# The -x test is for cygwin or other systems where $Config{perlpath} has no
# extension and $Config{_exe} is nonempty.  E.g., symlink perl->perl5.10.1.exe.
# There is no "perl.exe" on such a system.
sub get_perl_filename {
    my $secure_perl_path = $Config{perlpath};
    if ($^O ne 'VMS') {
        $secure_perl_path .= $Config{_exe}
            unless (-x $secure_perl_path) ||
                            ($secure_perl_path =~ m/$Config{_exe}$/i);
    }
    return $secure_perl_path;
} # get_perl_filename()

# }}}1
# Fill in $provides {{{1
eval {	# ignore errors
	require Module::Metadata;
	$provides = Module::Metadata->provides(version => '2', dir => 'lib');
		# Thanks to https://stackoverflow.com/a/28928985/2877364 by LEONT
};

# }}}1
# Fill in $is_trial {{{1
eval {	# ignore errors
	# Check for underscore versions.
	my $version = MM->parse_version($source);
	$is_trial = (index($version||'', '_') != -1);
};

eval {	# Ignore errors
	# Check for "# TRIAL", for perl-bump-version compatibility.
	TRIAL: {
		# Get the VERSION line
		open my $fd, '<', $source or last TRIAL;
		my $linetext;
		while(<$fd>) {
			next unless /VERSION/;
			$linetext = $_;
			last;
		}
		close $fd;
		$is_trial = 1 if $linetext and $linetext =~ /\bTRIAL\b/;
	}
};

print "TRIAL version\n" if $is_trial;
# }}}1
# Makefile customization (MY) {{{1
{   package MY;

    # dist_core: make `dist` a :: target rather than a : target,
    # and add distcheck before dist.  Also, add -TRIAL to the tgz if necessary.
    sub dist_core {
        my $self = shift;
        my $text = $self->SUPER::dist_core(@_);
        $text =~ s/^dist\h*:[^:]/dist:: distcheck /m;

        # Add -TRIAL if it's a trial release
        if($is_trial) {
            # Note: we don't have to worry about EOL; Appveyor uses gmake even
            # on Windows, and it only uses \n.
            print STDERR "TRIAL version\n";
            my $newtext .=  # Command to rename the tgz.  TODO see if this works on Windows.
                "\t\"$secure_perl_path\" -MExtUtils::Command -e mv -- " .
                '"$(DISTVNAME).tar$(SUFFIX)" ' .
                '"$(DISTVNAME)-TRIAL.tar$(SUFFIX)"' . "\n";

            # Insert $newtext at the end of the `dist` target
            $text =~ s{
                ^(dist\h*:.*\n      # dist header line
                    (?:\h+\S.*\n)+) # dist body lines.  `.` doesn't match `\n`.
                                    # NOTE: on Appveyor, the continuation line
                                    # begins with a space rather than a tab.
                                    # Therefore, look for \h after \n.
                                    # Not \s, because that matches a \n!
            }{$1$newtext}mx;
        } #endif $is_trial

        return $text;
    } # MY::dist_core

} #package MY

# }}}1

# Main options for EUMM
my %opts = (
	NAME			=> 'Getargs::Mixed',
	VERSION_FROM	=> $source,
	ABSTRACT_FROM	=> $source,

	LICENSE			=> 'perl_5',
	AUTHOR			=> 'Andrew Sterling Hanenkamp <hanenkamp@cpan.org>',

	MIN_PERL_VERSION=> '5.006',
	PREREQ_PM => {
		'Carp'		=> '0',
		'Exporter'	=> '0',
		'strict'	=> '0',
		'warnings'	=> '0',
	},
	CONFIGURE_REQUIRES => {
		'Config'				=> '0',
		'ExtUtils::MakeMaker'	=> '0',
		'File::Spec'			=> '3.2701',	# for a Win32 bugfix
		'strict'				=> '0',
		'warnings'				=> '0',
	},
	# Note: for the sake of ExtUtils::MakeMaker < 6.63_03, don't use
	# TEST_REQUIRES.  Put test requirements in PREREQ_PM instead.  See, e.g.,
	# https://metacpan.org/source/CXW/List-AutoNumbered-0.000005/Makefile.PL#L202
	# for documentation links.

	META_MERGE => {
		'meta-spec'	=> { version => 2 },

		resources	=> {
			# The code is on GitHub (but we'll take bug reports on RT, too)
			bugtracker	=> {
				web	=> 'https://github.com/cxw42/Getargs-Mixed/issues',
			},

			repository => {
				type	=> 'git',
				url		=> 'https://github.com/cxw42/Getargs-Mixed.git',
				web		=> 'https://github.com/cxw42/Getargs-Mixed',
			},
		},

		x_contributors => [
			# Use CPAN emails so MetaCPAN will pick them up.
			'Andrew Sterling Hanenkamp <hanenkamp@cpan.org>',
			'Christopher White <cxw@cpan.org>',
		],

		$provides ? (provides => $provides) : (),

		prereqs => {
			develop => {
				recommends => {
					'App::RewriteVersion' => '0',	# for perl-bump-version
					'Module::Metadata' => '1.000016',
				},
			},
		},

	}, # META_MERGE

	dist	=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean	=> { FILES => 'Getargs-Mixed-*' },
); # %opts

$opts{META_MERGE}->{release_status} = 'testing' if $is_trial;

WriteMakefile(%opts);
# vi: set fdm=marker: #
