# vim: set ft=perl :

use Test::More tests => 6;
BEGIN { use_ok('Getargs::Mixed') };

sub foo {
	my %args = Getargs::Mixed->new->parameters([ qw( x y z ) ], @_);

	fail("This shouldn't be reachable.");
}

my @args = (
	[ 1, 2, 3, -x => 4 ],	# specify twice
	[ 1, 2 ],				# required missing
	[ 1, 2, 3, -bar => 4 ],	# unknown argument
	[ -x => 1, 2, 3 ],		# tried to switch back
	[ -x => undef ],		# parameters() treats undef as missing
);

foreach (@args) {
	eval {
		foo(@$_);
	};

	if ($@) {
		pass("Exception thrown as it should be.");
	}
}
