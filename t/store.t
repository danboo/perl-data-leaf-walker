use warnings;
use strict;

use lib 'lib';

use Test::More 'no_plan';

use Data::Leaf::Walker;

my @got_data =
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

my @exp_keys =
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
   
my $walker = Data::Leaf::Walker->new( \@got_data );

for my $key_path_i ( 0 .. $#exp_keys )
   {
   
   my $key_path = $exp_keys[$key_path_i];
   
   $walker->store( $key_path, $key_path_i + 211 );
   
   }

is_deeply( \@got_data, \@exp_data, 'store' );