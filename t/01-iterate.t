use warnings;
use strict;

use lib 'lib';

use Test::More 'no_plan';

use Hash::Deep::Iterator;

my %single = ( single => 13 );
my $single = Hash::Deep::Iterator->new( \%single );

for ( 1 .. 2 )
   {

   my ( $single_key, $single_value ) = $single->each;

   is_deeply( $single_key,   ['single'], 'each key single - first' );
   is(        $single_value, 13,         'each value single - first' );

   my @end = $single->each;

   is_deeply( \@end, [], 'each key single - end' );

   my $single_scalar = $single->each;

   is_deeply( $single_scalar,   ['single'], 'each scalar single' );
   
   my $single_end = $single->each;
   
   is( $single_end, undef, 'each scalar single' );

   my @got_keys = $single->keys;
   is_deeply( \@got_keys, [ [ 'single' ] ], 'keys single' );

   my @got_values = $single->values;
   is_deeply( \@got_values, [ 13 ], 'values single' );
   
   my $fetch_value = $single->fetch( [ 'single' ] );
   is($fetch_value, 13, 'fetch value single - first' );
   
   ok( $single->exists( [ 'single' ] ), 'exists single' );
  
   ok( ! $single->exists( [ 'mingle' ] ), 'not exists mingle' );

   my $single_clone = hoh_clone( \%single );

   is_deeply( $single_clone, \%single, 'single clone' );

   }
   
$single->store( [ 'single' ] => 15 );

for ( 1 .. 2 )
   {

   my ( $single_key, $single_value ) = $single->each;

   is_deeply( $single_key,   ['single'], 'each key single - first' );
   is(        $single_value, 15,         'each value single - first' );

   my @end = $single->each;

   is_deeply( \@end, [], 'each key single - end' );

   my $single_scalar = $single->each;

   is_deeply( $single_scalar,   ['single'], 'each scalar single' );
   
   my $single_end = $single->each;
   
   is( $single_end, undef, 'each scalar single' );

   my @got_keys = $single->keys;
   is_deeply( \@got_keys, [ [ 'single' ] ], 'keys single' );

   my @got_values = $single->values;
   is_deeply( \@got_values, [ 15 ], 'values single' );
   
   my $fetch_value = $single->fetch( [ 'single' ] );
   is($fetch_value, 15, 'fetch value single - first' );

   ok( $single->exists( [ 'single' ] ), 'exists single' );
  
   ok( ! $single->exists( [ 'mingle' ] ), 'not exists mingle' );

   my $single_clone = hoh_clone( \%single );

   is_deeply( $single_clone, \%single, 'single clone' );

   }
   
$single->store( [ 'single', 'double' ], 17 );

for ( 1 .. 2 )
   {

   my ( $single_key, $single_value ) = $single->each;
   
   is_deeply( $single_key,   ['single','double'], 'each key double - first' );
   is(        $single_value, 17,         'each value double - first' );

   my @end = $single->each;

   is_deeply( \@end, [], 'each key double - end' );

   my $single_scalar = $single->each;

   is_deeply( $single_scalar,   ['single','double'], 'each scalar single' );
   
   my $single_end = $single->each;
   
   is( $single_end, undef, 'each scalar single' );

   my @got_keys = $single->keys;
   is_deeply( \@got_keys, [ [ 'single', 'double' ] ], 'keys single' );

   my @got_values = $single->values;
   is_deeply( \@got_values, [ 17 ], 'values single' );
   
   my $fetch_value = $single->fetch( [ 'single', 'double' ] );
   is($fetch_value, 17, 'fetch value single - first' );

   ok( $single->exists( [ 'single' ] ), 'exists single' );
   ok( $single->exists( [ 'single', 'double' ] ), 'exists single,double' );
  
   ok( ! $single->exists( [ 'mingle' ] ), 'not exists mingle' );
   ok( ! $single->exists( [ 'single', 'bouble' ] ), 'not exists single, bouble' );

   my $single_clone = hoh_clone( \%single );

   is_deeply( $single_clone, \%single, 'single clone' );

   }

$single->store( [ 'single', 'another' ], 19 );

for ( 1 .. 2 )
   {

   my @got_keys = sort { $a->[1] cmp $b->[1] } $single->keys;

   is_deeply( \@got_keys, [ [ 'single', 'another' ], [ 'single', 'double' ] ], 'keys single' );

   my @got_values = sort $single->values;
   is_deeply( \@got_values, [ 17, 19 ], 'values single' );

   my $fetch_value = $single->fetch( [ 'single', 'another' ] );
   is($fetch_value, 19, 'fetch value single - first' );

   my $single_clone = hoh_clone( \%single );

   ok( $single->exists( [ 'single' ] ), 'exists single' );
   ok( $single->exists( [ 'single', 'double' ] ), 'exists single,double' );
   ok( $single->exists( [ 'single', 'another' ] ), 'exists single,another' );
  
   ok( ! $single->exists( [ 'mingle' ] ), 'not exists mingle' );
   ok( ! $single->exists( [ 'single', 'bouble' ] ), 'not exists single, bouble' );

   is_deeply( $single_clone, \%single, 'single clone' );

   }
   
sub hoh_clone
   {
   my ( $hoh ) = @_;
   
   my $iter = Hash::Deep::Iterator->new( $hoh );
   
   my $clone = {};
   
   while ( my ( $key, $val ) = $iter->each )
      {
      my $path = '{' . join('}{', @{ $key } ) . '}';
      eval "\$clone->$path = \$val";
      }
   
   return $clone;
   }
