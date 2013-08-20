package App::Betting::Toolkit::GameState;

use 5.006;
use strict;
use warnings;

=head1 NAME

App::Betting::Toolkit::GameState - A GameState object for use with App::Betting::Toolkit

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS


use App::Betting::Toolkit::GameState;

my $match = App::Betting::Toolkit::GameState->new();

$match->name("Arsenal V Aston Villa");

=head1 SUBROUTINES/METHODS



=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Paul G Webster, C<< <daemon at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-betting-toolkit-gamestate at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-Betting-Toolkit-GameState>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




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

sub new {
        my $class = shift;

        my $self = {
                required                =>      [ qw(name bookie link state type found game) ],
                stateAllowed            =>      [ qw(complete active suspended) ],
                typeAllowed             =>      [ qw(favourite teams) ],
                match                   =>      {
                        odds            =>      [],
                },
        };

        bless $self, $class;
    return $self;
}

sub load {
        my $class = shift;
        my $self = shift;

        bless $self, $class;

        return $self;
}

sub isValid {
        my $self = shift;

        foreach my $key ( @{ $self->{required} } ) {
                return 0 if (!$self->{match}->{$key});
        }

        # Additional checks based on type
        return 0 if (!$self->{match}->{type});

        if ($self->{match}->{type} eq 'favourite') {
                # then we should only have one team and one set of odds
                return 0 if (
                        (!$self->{match}->{odds}->[0]) ||
                        (scalar( @{ $self->{match}->{odds} }) != 1) ||
                        (!$self->{match}->{odds}->[0]->{name}) ||
                        (!$self->{match}->{odds}->[0]->{odds})
                );
        } else {
                return 0 if (
                        (scalar( @{ $self->{match}->{odds} }) < 2)
                );
                foreach my $oddsSet ( @{ $self->{match}->{odds} } ) {
                        next if ( ($oddsSet->{name}) && ($oddsSet->{odds}) );
                        return 0;
                }
        }

        return 1;
}

sub dump {
        return Dumper(shift);
}

sub teamscore {
        my $self = shift;
        my $teamid = shift;

        return if ($teamid !~ m#^\d+$#);

        $teamid--;

        return $self->{match}->{odds}->[$teamid]->{score} if ($self->{match}->{odds}->[$teamid]);
        return;
}

sub teamodds {
        my $self = shift;
        my $team = shift;

        return if ($team !~ m#^\d+$#);

        $team--;

        return $self->{match}->{odds}->[$team]->{odds} if ($self->{match}->{odds}->[$team]);
        return;
}

sub teamname {
        my $self = shift;
        my $team = shift;

        return "" if ($team !~ m#^\d+$#);

        $team--;

        return $self->{match}->{odds}->[$team]->{name} if ($self->{match}->{odds}->[$team]);
        return;
}

sub oddsCount {
        my $self = shift;

        return scalar( @{ $self->{match}->{odds} } ) if ($self->{match}->{odds});

        return 0;
}
sub pureCopy {
        my $self = shift;
        my $copy;

        foreach my $key (keys %{ $self }) { $copy->{$key} = $self->{$key}; }

        return $copy;
}

sub game {
        my $self = shift;
        my $newState = shift;

        if ($newState) {
                $self->{match}->{game} = $newState;
        }

        $self->{valid} = $self->isValid();

        return $self->{match}->{game} if ($self->{match}->{game});
}

sub unique {
        my $self = shift;
        my $newName = shift;

        $self->{match}->{unique} = $newName if ($newName);

        $self->{valid} = $self->isValid();

        return $self->{match}->{unique} if ($self->{match}->{unique});
}


sub score {
        my $self = shift;
        my $newName = shift;

        if ($newName) {
                return if ($newName !~ m#^\d\s+-\s+\d+$#);
                $self->{match}->{score} = $newName;
        }

        $self->{valid} = $self->isValid();

        return $self->{match}->{score} if ($self->{match}->{score});
}

sub var {
        my $self = shift;
        my $varName = shift;
        my $varValue = shift;

        return if (!$varName);

        $self->{var}->{$varName} = $varValue if (defined $varValue);

        return $self->{var}->{$varName} if (defined $self->{var}->{$varName});
}

sub found {
        my $self = shift;
        my $newName = shift;

        $self->{match}->{found} = $newName if ($newName);

        $self->{valid} = $self->isValid();

        return $self->{match}->{found} if ($self->{match}->{found});
}

sub name {
        my $self = shift;
        my $newName = shift;

        $self->{match}->{name} = $newName if ($newName);

        $self->{valid} = $self->isValid();

        return $self->{match}->{name} if ($self->{match}->{name});
}

sub addOdds {
        my $self = shift;
        my $team = shift;

        push @{ $self->{match}->{odds} },$team;

        # Could probably check if type had been set and validate against it

        $self->{valid} = $self->isValid();

        return 0;
}

sub bookie {
        my $self = shift;
        my $newBookie = shift;

        $self->{match}->{bookie} = $newBookie if ($newBookie);

        $self->{valid} = $self->isValid();

        return $self->{match}->{bookie} if ($self->{match}->{bookie});
}

sub link {
        my $self = shift;
        my $newLink = shift;

        $self->{match}->{link} = $newLink if ($newLink);

        $self->{valid} = $self->isValid();

        return $self->{match}->{link} if ($self->{match}->{link});
}

sub state {
        my $self = shift;
        my $newState = shift;

        if ($newState) {
                return if (!isin($newState,$self->{stateAllowed}));
                $self->{match}->{state} = $newState;
        }

        $self->{valid} = $self->isValid();

        return $self->{match}->{state} if ($self->{match}->{state});
}


sub type {
        my $self = shift;
        my $newType = shift;

        if ($newType) {
                return if (!isin($newType,$self->{typeAllowed}));
                $self->{match}->{type} = $newType;
        }

        $self->{valid} = $self->isValid();

        return $self->{match}->{type} if ($self->{match}->{type});
}

sub isin {
        my $test = shift;
        my $array = shift;

        foreach my $key ( @{ $array } ) {
                next if ( (!$key) || (!$test) );
                return 1 if ($key eq $test);
        }

        return 0;
}

sub complete {
        my $self = shift;

        foreach my $test ( @{ $self->{required} } ) {
                return 0 if (!$self->{$test});
        }

        return 1;
}

1; # End of App::Betting::Toolkit::GameState
