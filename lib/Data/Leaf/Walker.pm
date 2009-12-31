package Data::Leaf::Walker;

use warnings;
use strict;

=head1 NAME

Data::Leaf::Walker - Walk the leaves of arbitrarily deep nested data structures.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

   $data   = {
      a    => 'hash',
      or   => [ 'array', 'ref' ],
      with => { arbitrary => 'nesting' },
      };

   $walker = Data::Leaf::Walker->new( $data );
   
   while ( my ( $k, $v ) = $walker->each )
      {
      print "@{ $k } : $v\n";
      }
      
   ## output might be
   ## a : hash
   ## or 0 : array
   ## or 1 : ref
   ## with arbitrary : nesting

=head1 FUNCTIONS

=head2 new( $data )

Construct a new C<Data::Leaf::Walker> instance.

   $data   = {
      a    => 'hash',
      or   => [ 'array', 'ref' ],
      with => { arbitrary => 'nesting' },
      };

   $walker = Data::Leaf::Walker->new( $data );

=cut

sub new
   {
   my $class = shift;
   return bless
      {
      _data       => shift(),
      _data_stack => [],
      _key_path   => [],
      }, $class;
   }

=head2 keys()

Returns the list of all key paths.

   my @key_paths = $walker->keys;

=cut

sub keys
   {
   my ( $self ) = @_;

   my @keys;

   while ( defined( my $key = $self->each ) )
      {
      push @keys, $key;
      }
   
   return @keys;
   }
   
=head2 values()

Returns the list of all leaf values.

   my @leaf_values = $walker->values;

=cut

sub values
   {
   my ( $self ) = @_;

   my @values;

   EACH:
      {
      my ( $key, $value ) = $self->each;
      if ( defined $key )
         {
         push @values, $value;
         redo EACH;
         }
      }
   
   return @values;
   }

=head2 fetch( $key_path )

Lookup the value corresponding to the given key path.

   my $leaf = $walker->fetch( [ $key1, $index1, $index2, $key2 ] );

=cut

sub fetch
   {
   my ( $self, $key_path ) = @_;

   my $data = $self->{_data};
   
   for my $key ( @{ $key_path } )
      {
      my $type = ref $data;
      if ( $type eq 'ARRAY' )
         {
         $data = $data->[$key];
         }
      elsif ( $type eq 'HASH' )
         {
         $data = $data->{$key};
         }
      }
   
   return $data;
   }

=head2 store( $key_path, $value )

Set the value for the corresponding key path.

   $walker->store( [ $key1, $index1, $index2, $key2 ], $value );

=cut

sub store
   {
   my ( $self, $key_path, $value ) = @_;
   
   my $data = $self->{_data};
   my $type = ref $data;

   for my $key_i ( 0 .. $#{ $key_path } - 1 )
      {
      my $key  = $key_path->[$key_i];

      my $autovivify_error;

      VALID:
         {
         if ( $type eq 'HASH' )
            {

            if ( ! exists $data->{$key} )
               {
               $autovivify_error = 1;
               last VALID;
               }
               
            if ( ! defined $data->{$key} )
               {
               $autovivify_error = 2;
               last VALID;
               }

            my $nested_type = ref $data->{$key};
            if ( ! ( $nested_type eq 'HASH' || $nested_type eq 'ARRAY' ) )
               {
               $autovivify_error = 3;
               last VALID;
               }
               
            $data = $data->{$key};

            }
         elsif ( $type eq 'ARRAY' )
            {

            if ( ! exists $data->[$key] )
               {
               $autovivify_error = 4;
               last VALID;
               }
               
            if ( ! defined $data->[$key] )
               {
               $autovivify_error = 5;
               last VALID;
               }

            my $nested_type = ref $data->[$key];
            if ( ! ( $nested_type eq 'HASH' || $nested_type eq 'ARRAY' ) )
               {
               $autovivify_error = 6;
               last VALID;
               }
               
            $data = $data->[$key];

            }

         $type = ref $data;

         }
         
      if ( $autovivify_error )
         {
         die "Error($autovivify_error): cannot autovivify key ($key) arbitrarily (@{ $key_path })";
         }

      }
      
   if ( $type eq 'HASH' )
      {
      return $data->{ $key_path->[-1] } = $value;
      }
   elsif  ( $type eq 'ARRAY' )
      {
      return $data->[ $key_path->[-1] ] = $value;
      }
   }
   
sub delete
   {
   my ( $self, $key_path ) = @_;

   my $hoh = $self->{_data};
   
   my $exists = 1;

   for my $key_i ( 0 .. $#{ $key_path } )
      {
      my $key = $key_path->[$key_i];
      }

   }

sub exists
   {
   my ( $self, $key_path ) = @_;

   my $hoh = $self->{_data};
   
   my $exists = 1;

   for my $key_i ( 0 .. $#{ $key_path } )
      {
      my $key = $key_path->[$key_i];
      if ( ! defined $hoh || ref $hoh ne 'HASH' || ! exists $hoh->{$key} )
         {
         $exists = '';
         last;
         }
      $hoh = $hoh->{$key};
      }
      
   return $exists;
   }

sub each
   {
   my ( $self ) = @_;
   
   if ( ! @{ $self->{_data_stack} } )
      {
      push @{ $self->{_data_stack} }, $self->{_data};
      }
      
   return $self->_iterate;
   }

{
   
my %array_tracker;
   
sub _each
   {
   my ( $data ) = @_;
   
   if ( ref $data eq 'HASH' )
      {
      return CORE::each %{ $data };
      }
   elsif ( ref $data eq 'ARRAY' )
      {
      $array_tracker{ $data } ||= 0;
      if ( exists $data->[ $array_tracker{ $data } ] )
         {
         my $index = $array_tracker{ $data };
         ++ $array_tracker{ $data };
         return( $index, $data->[ $index ] );
         }
      else
         {
         $array_tracker{ $data } = 0;
         return;
         }
      
      }
   else
      {
      die "Error: cannot call _each() on non-HASH/non-ARRAY data record";
      }
   
   }
   
}

sub _iterate
   {
   my ( $self ) = @_;

   ## find the top of the stack   
   my $data = ${ $self->{_data_stack} }[-1];
   
   ## iterate on the stack top
   my ( $key, $val ) = _each($data);

   ## if we're at the end of the stack top
   if ( ! defined $key )
      {
      ## remove the stack top
      pop @{ $self->{_data_stack} };
      pop @{ $self->{_key_path} };

      ## iterate on the new stack top if available
      if ( @{ $self->{_data_stack} } )
         {
         return $self->_iterate;
         }
      ## mark the stack as empty
      ## return empty/undef
      else
         {
         return;
         }

      }
   
   ## _each() succeeded

   ## if the value is a HASH, add it to the stack and iterate
   if ( defined $val && ( ref $val eq 'HASH' || ref $val eq 'ARRAY' ) )
      {
      push @{ $self->{_data_stack} }, $val;
      push @{ $self->{_key_path} }, $key;
      return $self->_iterate;
      }
      
   my $key_path = [ @{ $self->{_key_path} }, $key ];

   return wantarray ? ( $key_path, $val ) : $key_path;   
   }

=head1 AUTHOR

Dan Boorstein, C<< <danboo at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-Data-Leaf-Walker at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-Leaf-Walker>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Data::Leaf::Walker


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data-Leaf-Walker>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Data-Leaf-Walker>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Data-Leaf-Walker>

=item * Search CPAN

L<http://search.cpan.org/dist/Data-Leaf-Walker/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Dan Boorstein.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Data::Leaf::Walker
