#!/usr/bin/env perl6

use lib 'src';
use JSON::Fast;
use Test;
use Game;



# my $game = Game.new(
#   map => {
#     rivers => (
#       { source => 0, target => 1 }
#     ),
#     sites => (
#       { id => 0 },
#       { id => 1 },
#     ),
#     mines => ( 0 ),
#   },
#   punters => 1
# );

# my $map = {
#     mines => [1],
#     rivers => [ { source => 0, target => 1 } ],
#     sites => [
#       {id => 0, x => 0, y => 0},
#       {id => 1, x => 1, y => 0}
#     ]
#   };
my $map = from-json('
  {
    "sites": [
      { "id": 0, "x": 0, "y": 0 },
      { "id": 1, "x": 1, "y": 0 },
      { "id": 2, "x": 1, "y": 0 },
      { "id": 3, "x": 1, "y": 0 },
      { "id": 4, "x": 1, "y": 0 },
      { "id": 5, "x": 1, "y": 0 }
    ],
    "rivers": [
      { "source": 0, "target": 1 },
      { "source": 2, "target": 1 },
      { "source": 2, "target": 3 },
      { "source": 3, "target": 4 },
      { "source": 4, "target": 5 }
    ],
    "mines": [ 1, 5 ]
  }
');
my $game = Game.new(
  # map => $map,
  # {
  #   mines => [1],
  #   rivers => [ { source => 0, target => 1 } ],
  #   sites => [
  #     {id => 0, x => 0, y => 0},
  #     {id => 1, x => 1, y => 0}
  #   ]
  # },
  punters => 1,
    state => {
      # punter => $punter,
      # punters => 1,
      map => $map,
      # rivers => $game.rivers,
      # move_num => $punter,
    }
);

say $game;

# my $game1-results = from-json("src/test/game1.json".IO.slurp);
# my $game = Game.new(
#   map => $game1-results<state><map>,
#   punters => $game1-results<state><punters>,
# );

is $game.distance(0,1), 1, "Simple distance works";
is $game.connected-sites(1, 0), (), "No initial connected sites";

my $score = $game.score;
is $score[0]<score>, 0, 'No move, no points';

$game.make-move(0, { claim => { punter => 0, source => 0, target => 1 } });
is $game.connected-sites(1, 0), (0), "One connected site";
my $score = $game.score;
is $score[0]<score>, 1, 'Simple connection';

$game.make-move(0, { claim => { punter => 0, source => 1, target => 2 } });
is $game.connected-sites(1, 0), (set 0, 2), "Two connected site";
my $score = $game.score;
is $score[0]<score>, 2, 'Another simple connection';

$game.make-move(0, { claim => { punter => 0, source => 2, target => 3 } });
is $game.connected-sites(1, 0), ( set 0, 2, 3), "Three connected site";
my $score = $game.score;
is $score[0]<score>, 6, 'Longer connection';

$game.make-move(0, { claim => { punter => 0, source => 3, target => 4 } });
is $game.connected-sites(1, 0), ( set 0, 2, 3, 4), "Four connected site";
my $score = $game.score;
is $score[0]<score>, 15, 'Longerer connection';

$game.make-move(0, { claim => { punter => 0, source => 4, target => 5 } });
is (set $game.connected-sites(1, 0)), ( set 0, 2, 3, 4, 5), "Five connected site";
my $score = $game.score;
is $score[0]<score>, 86, 'Two mine connection. Big time bonus.';

done-testing;
