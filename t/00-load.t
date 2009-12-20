#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Hash::Deep::Iterator' );
}

diag( "Testing Hash::Deep::Iterator $Hash::Deep::Iterator::VERSION, Perl $], $^X" );
