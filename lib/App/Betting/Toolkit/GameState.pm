package App::Betting::Toolkit::GameState;

use 5.006;

use strict;
use warnings;

use Data::Dumper;
use Try::Tiny;
use Storable qw(dclone);

=head1 NAME

=over 1

App::Betting::Toolkit::GameState - A GameState object for use with App::Betting::Toolkit

=back

=head1 VERSION

=over 1

Version 0.061

=back

=cut

our $VERSION = '0.061';


=head1 SYNOPSIS

=over 1

use App::Betting::Toolkit::GameState;

my $match = App::Betting::Toolkit::GameState->new();

$match->name("Arsenal V Aston Villa");

=back

=head1 SUBROUTINES/METHODS

=head2 new

=over 1

Create a new App::Betting::Toolkit::GameState object.

Default object:

=back

	my $match = App::Betting::Toolkit::GameState->new();

=over 1

Object with required fields:

=back

	my $match = App::Betting::Toolkit::GameState->new( { 
		required => qw(name) 
	} );

=over 1

Object with auto validation (note validation would always return true here as there are no required fields):

=back

	my $match = App::Betting::Toolkit::GameState->new( { 
		options => { autovalidate => 1 } 
	} );

=over 1

Object with restricted flags, auto validation and required fields:

=back

	my $match = App::Betting::Toolkit::GameState->new( {
		options		=>	{ autovalidate => 1 },
		required	=>	[ qw(name time state) ],
		restrict	=>	{
			state	=>	[ qw(suspended active finished) ],
		}
	});

=over 1

New match objects ALWAYS start invalid.

=back

=cut

sub new {
        my $class = shift;

	my $args = shift;

	my $required	= [];
	my $options	= {};
	my $restrict	= {};

	$options = $args->{options} if ( $args->{options} );
	$restrict = $args->{restrict} if ( $args->{restrict} );
	$required = $args->{required} if ( $args->{required} );

        my $self = {
		special			=>	{
			version		=>	$VERSION,
			localtime	=>	time,
			valid		=>	0,
		},
		options			=>	$options,
                required                =>      $required,
		restrict		=>	$restrict,
		var			=>	{},
        };

        bless $self, $class;
    return $self;
}

=head2 load

=over 1

Load a App::Betting::Toolkit::GameState object from a scalar.

=back

	my $unblessedObject = someSouce();

	my $match = App::Betting::Toolkit::GameState->load($unblessedObject);

=cut

sub load {
        my $class = shift;
        my $self = shift;

	$self = dclone($self);

        bless $self, $class;

        return $self;
}

=head2 loadable 

=over 1

Check if a passed object will load without error.

On error: return 0

On success: return 1

	if (App::Betting::Toolkit::GameState->loadable($unblessedObject)) {
		$match = App::Betting::Toolkit::GameState->load($unblessedObject);
	}

=back

=cut

sub loadable {
        my $class = shift;
	my $self = shift;

	try { bless $self, $class }
	catch { return 0 }

        return 1;
}

=head2 pureCopy

=over 1

Loop through the match object and return an unblessed scalar version that can be sent elsewhere and loaded with the load function.

On error: Returns undef

On success: Returns a unblessed GameState object.

=back

=cut

sub pureCopy {
        my $self = shift;
        my $copy;

        foreach my $key (keys %{ $self }) { $copy->{$key} = $self->{$key}; }

        return $copy;
}

=head2 dump

=over 1

Return the match as a plain scalar that has been outputted through Data::Dumper

On error: Something is very wrong 8)

On success: Returns a Data Dumped scalar of the GameState object.

=back

=cut

sub dump {
        return Dumper(shift);
}

=head2 validate

=over 2

Validate the required fields against the current fields in the object, this
is done automatically if autovalidate => 1 is set.

NOTE: This function cannot fail, it will simply just return 0 (invalid)

On success: Returns 0 or 1 (Invalid or Valid)

=back

=cut

sub validate {
        my $self = shift;

	foreach my $key ( @{ $self->{required} } ) {
		return 0 if (!$self->view($key));

		# Ok is there any restraints on this field
		my $value = $self->view($key);

		if ($self->{restrict}->{$key}) {
			return 0 if (!isin($value,$self->{restrict}->{$key}));
		}

		# Ok so this one is valid..
	}

	$self->{special}->{valid} = 1;

	return 1;
}

=head2 isValid

=over 1

Return the current validation state.

On error: Returns undef;

On success: Returns 0 or 1 (Invalid or Valid)

=back

=cut

sub isValid {
	my $self = shift;

	return undef if (!defined $self->{special}->{valid});
	return undef if ($self->{special}->{valid} !~ m#^0|1$#);

	return $self->{special}->{valid};
}

=head2 set

=over 1 

Set a variable in the match object. If called without a second parameter
the current value of the flag will be returned. 

On error: Returns undef;

On success: Returns new value

	$match->set('team1name','Sheffield Wednesday');

	print $match->set('team1name'),"\n"; 

=back

=cut

sub set {
        my $self = shift;
        my $varName = shift;
        my $varValue = shift;

        return if (!$varName);

        $self->{var}->{$varName} = $varValue if (defined $varValue);

	$self->validate() if ($self->{options}->{autovalidate});

        return $self->{var}->{$varName} if (defined $self->{var}->{$varName});
}

=head2 view

=over 1

View a variable stored in the match object (does the same as set without its second parameter but does not trigger a validate call even with autovalidate set)

On error: Returns undef;

On success: Returns value

	print $match->view('name');

=back

=cut

sub view {
        my $self = shift;
        my $varName = shift;

	return undef if (!$varName);

        return $self->{var}->{$varName} if (defined $self->{var}->{$varName});

}


=head1 AUTHOR

=over 1

Paul G Webster, C<< <daemon at cpan.org> >>

=back 

=head1 BUGS

=over 1

Please report any bugs or feature requests to C<bug-app-betting-toolkit-gamestate at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Betting-Toolkit-GameState>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=back


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::Betting::Toolkit::GameState


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-Betting-Toolkit-GameState>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-Betting-Toolkit-GameState>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-Betting-Toolkit-GameState>

=item * Search CPAN

L<http://search.cpan.org/dist/App-Betting-Toolkit-GameState/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Paul G Webster.

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/bsd-license.php>

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

* Neither the name of Paul G Webster's Organization
nor the names of its contributors may be used to endorse or promote
products derived from this software without specific prior written
permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

sub isin {
        my $test = shift;
        my $array = shift;

        foreach my $key ( @{ $array } ) {
                next if ( (!$key) || (!$test) );
                return 1 if ($key eq $test);
        }

        return 0;
}

1; # End of App::Betting::Toolkit::GameState
