
class Game {
  has $.map;
  has %.rivers;

  method TWEAK {

    # Initialize a hash of rivers
    %.rivers = $.map<rivers>.map: -> $river {
      river-name($river) => $river
    }

  }

  # {"claim" : {"punter" : PunterId, "source" : SiteId, "target" : SiteId}}
  method make-move($player, $move) {
    # $*ERR.say("make-move. rivers: { %.rivers.perl }");
    # $*ERR.say("player { $player.perl } move { $move.perl }");
    if $move<claim> {
      if $player !== $move<claim><punter> {
        die "Move and player don't match!";
      }
      my $river = river-name($move<claim>);
      if ! %.rivers{$river} {
        $*ERR.say("WARN: River '$river' doesn't exist");
      } elsif defined %.rivers{$river}<claim> {
        $*ERR.say("WARN: $river is already taken!");
      } else {
        %.rivers{$river}<claim> = $player;
      }
    }
  }

  sub river-name($river) {
    ($river<source>, $river<target>).sort.join('-');
  }
}

