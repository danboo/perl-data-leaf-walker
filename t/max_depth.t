use warnings;
use strict;

use lib 'lib';

use Test::More 'no_plan';

use Data::Leaf::Walker;

my @orig =
   (
   111,
   112,
   [ 113, 114 ],
   [ [ 115, { aaa => 116 } ] ],
   {
   aab => 117,
   aac => 118,
   aad => { aae => { aaf => [[ 119 ]] }, aag => 120 },
   aah => [ 121, 122 ],
   aai => [[]],
   aaj => [ 123, 124, { aak => 125 }, { aal => 126 } ],
   aam => { aan => {} },
   aao => 127,
   },
   128,
   );

my @exp_keys =
   (
   [ qw/ 0 / ],
   [ qw/ 1 / ],
   [ qw/ 2 0 / ],
   [ qw/ 2 1 / ],
   [ qw/ 3 0 0 / ],
   [ qw/ 3 0 1 / ],
   [ qw/ 4 aab / ],
   [ qw/ 4 aac / ],
   [ qw/ 4 aad aae / ],
   [ qw/ 4 aad aag / ],
   [ qw/ 4 aah 0 / ],
   [ qw/ 4 aah 1 / ],
   [ qw/ 4 aai 0 / ],
   [ qw/ 4 aaj 0 / ],
   [ qw/ 4 aaj 1 / ],
   [ qw/ 4 aaj 2 / ],
   [ qw/ 4 aaj 3 / ],
   [ qw/ 4 aam aan / ],
   [ qw/ 4 aao / ],
   [ qw/ 5 / ],
   );
   
my @exp_values =
   (
   111,
   112,
   113,
   114,
   115,
   117,
   118,
   120,
   121,
   122,
   123,
   124,
   127,
   128,
   [],
   {},
   { aaa => 116 },
   { aaf => [[ 119 ]] },
   { aak => 125 },
   { aal => 126 },
   );

my $walker = Data::Leaf::Walker->new( \@orig, max_depth => 3 );

EACH:
   {

   my @keys;
   my @values;

   while ( my ( $k, $v ) = $walker->each )
      {
      push @keys, $k;
      push @values, $v;
      }
   
   @keys = map  { $_->[0] }
           sort { $a->[1] cmp $b->[1] }
           map  { [ $_, join(':', @{$_}) ] } @keys;
             
   is_deeply( \@keys, \@exp_keys, "each - keys" );

   @values = map { $_->[0] } sort { $a->[1] cmp $b->[1] } map
      {
      my $w = ref $_ ? Data::Leaf::Walker->new( $_ ) : ();
      my $k = ref $_ ? $w->each : ();
      ref $_ && $w->keys;
      [ $_, $k ? join ':', @{ $k } : ref $_ ? ref $_ : $_ ]
      } @values;

   is_deeply( \@values, \@exp_values, "each - values" );
   
   }

KEYS:
   {

   my @keys = map  { $_->[0] }
              sort { $a->[1] cmp $b->[1] }
              map  { [ $_, join(':', @{$_}) ] } $walker->keys;
             
   is_deeply( \@keys, \@exp_keys, "keys" );

   }

VALUES:
   {

   my @values = $walker->values;

   @values = map { $_->[0] } sort { $a->[1] cmp $b->[1] } map
      {
      my $w = ref $_ ? Data::Leaf::Walker->new( $_ ) : ();
      my $k = ref $_ ? $w->each : ();
      ref $_ && $w->keys;
      [ $_, $k ? join ':', @{ $k } : ref $_ ? ref $_ : $_ ]
      } @values;

   is_deeply( \@values, \@exp_values, "values" );

   }

## switch exp keys back to leaf mode

@exp_keys =
   (
   [ qw/ 0 / ],
   [ qw/ 1 / ],
   [ qw/ 2 0 / ],
   [ qw/ 2 1 / ],
   [ qw/ 3 0 0 / ],
   [ qw/ 3 0 1 aaa / ],
   [ qw/ 4 aab / ],
   [ qw/ 4 aac / ],
   [ qw/ 4 aad aae aaf 0 0 / ],
   [ qw/ 4 aad aag / ],
   [ qw/ 4 aah 0 / ],
   [ qw/ 4 aah 1 / ],
   [ qw/ 4 aaj 0 / ],
   [ qw/ 4 aaj 1 / ],
   [ qw/ 4 aaj 2 aak / ],
   [ qw/ 4 aaj 3 aal / ],
   [ qw/ 4 aao / ],
   [ qw/ 5 / ],
   );

FETCH:
   {

   for my $key_path_i ( 0 .. $#exp_keys )
      {
      
      my $key_path = $exp_keys[$key_path_i];
      
      my $value = $walker->fetch( $key_path );
      
      is( $value, $key_path_i + 111, "fetch - @{ $key_path } : $value" );
      
      }
      
   my $top_undef = $walker->fetch( [ qw/ 1000 / ] );
   is( $top_undef, undef, 'fetch - top not exist' );

   my $deep_undef = $walker->fetch( [ qw/ 3 0 1 potato / ] );
   is( $deep_undef, undef, 'fetch - deep not exist' );
   
   eval { $walker->fetch( [ qw/ 3 0 0 potato / ] ) };
   my $err = $@;
   like( $err, qr/\A\QError: cannot lookup key (potato) in invalid ref type ()/,
         'fetch - invalid path' );

   }

STORE:
   {

   my @exp_data =
      (
      211,
      212,
      [ 213, 214 ],
      [ [ 215, { aaa => 216 } ] ],
      {
      aab => 217,
      aac => 218,
      aad => { aae => { aaf => [[ 219 ]] }, aag => 220 },
      aah => [ 221, 222 ],
      aai => [[]],
      aaj => [ 223, 224, { aak => 225 }, { aal => 226 } ],
      aam => { aan => {} },
      aao => 227,
      },
      228,
      );

   for my $key_path_i ( 0 .. $#exp_keys )
      {
      my $key_path = $exp_keys[$key_path_i];
      $walker->store( $key_path, $key_path_i + 211 );
      }

   is_deeply( \@orig, \@exp_data, 'store' );   

   }
   
EXISTS:
   {

   for my $key_path ( @exp_keys )
      {
      ok( $walker->fetch( $key_path ), "exists - @{ $key_path }" );
      }

   my $top = $walker->exists( [ qw/ 1000 / ] );
   ok( ! $top, 'exists - top not exist' );

   my $deep = $walker->exists( [ qw/ 3 0 1 potato / ] );
   ok( ! $deep, 'exists - deep not exist' );
   
   my $invalid = $walker->exists( [ qw/ 3 0 0 potato / ] );
   ok( ! $invalid, 'exists - invalid not exist' );

   }

DELETE:
   {
   
   my $ret = $walker->delete( [ qw/ 4 aaj 3 aal / ] );
   
   my @exp_data =
      (
      211,
      212,
      [ 213, 214 ],
      [ [ 215, { aaa => 216 } ] ],
      {
      aab => 217,
      aac => 218,
      aad => { aae => { aaf => [[ 219 ]] }, aag => 220 },
      aah => [ 221, 222 ],
      aai => [[]],
      aaj => [ 223, 224, { aak => 225 }, {} ],
      aam => { aan => {} },
      aao => 227,
      },
      228,
      );

   is_deeply( \@orig, \@exp_data, 'delete' );
   is( $ret, 226, 'delete - return' );

   }
