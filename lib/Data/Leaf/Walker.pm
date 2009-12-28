package Hash::Deep::Iterator;

use warnings;
use strict;

=head1 NAME

Hash::Deep::Iterator - The great new Hash::Deep::Iterator!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Hash::Deep::Iterator;

    my $foo = Hash::Deep::Iterator->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 new

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

=head2 function2

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
   
sub fetch
   {
   my ( $self, $key_path ) = @_;

   my $hoh = $self->{_data};
   
   my $value;
   
   for my $key ( @{ $key_path } )
      {
      $value = $hoh->{$key};
      $hoh   = $value;
      }
   
   return $value;
   }

sub store
   {
   my ( $self, $key_path, $value ) = @_;
   
   my $hoh = $self->{_data};

   for my $key_i ( 0 .. $#{ $key_path } - 1 )
      {
      my $key = $key_path->[$key_i];
      if ( ! defined $hoh->{$key} || ref $hoh->{$key} ne 'HASH' )
         {
         $hoh->{$key} = {};
         }
      $hoh = $hoh->{$key};
      }
      
   return $hoh->{ $key_path->[-1] } = $value;
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

Please report any bugs or feature requests to C<bug-hash-deep-iterator at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Hash-Deep-Iterator>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Hash::Deep::Iterator


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Hash-Deep-Iterator>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Hash-Deep-Iterator>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Hash-Deep-Iterator>

=item * Search CPAN

L<http://search.cpan.org/dist/Hash-Deep-Iterator/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Dan Boorstein.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Hash::Deep::Iterator
