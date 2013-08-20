#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::Betting::Toolkit::GameState' ) || print "Bail out!\n";
}

diag( "Testing App::Betting::Toolkit::GameState $App::Betting::Toolkit::GameState::VERSION, Perl $], $^X" );
