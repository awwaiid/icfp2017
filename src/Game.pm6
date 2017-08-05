
class Game {
  has $.map;
  has %.rivers;
  has $.state;
  has $.punters;

  method TWEAK {

    if $.state<map> {
      $!map = $.state<map>;
    }

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

  method get-neighbors($source) {
    my @rivers = $.map<rivers>.grep({ $^r<source> == $source || $^r<target> == $source});
    @rivers.map(*<source target>).flat.grep(* != $source).list;
  }

  method distance($source, $target) {
    # TODO: Memoize
    return 0 if $source == $target;
    my %seen = ();
    # $*ERR.say("Neighbors of $source: { self.get-neighbors($source).perl }");
    my @next = self.get-neighbors($source).map({($_, 1)}).list;
    # $*ERR.say("queue: { @next.perl }");
    while @next {
      my ($n, $dist) = @next.shift;
      return $dist if $n == $target;
      # $*ERR.say("checking $n $dist");
      my @neighbors = self.get-neighbors($n);
      # $*ERR.say("Neighbors of $n: { @neighbors.perl }");
      my @nnext = @neighbors.map(-> $n { ( $n, $dist + 1 ) }).list;
      # $*ERR.say("Pushing { @nnext.perl }");
      @next.push(|@nnext);
    }
    die "Error: no path from $source to $target";
  }

  method graphviz {
    $*ERR.say("graph \{");
    for $.map<rivers>.list -> $river {
      $*ERR.say("$river<source> -- $river<target> ; ");
    }
    $*ERR.say("}");
  }

  method connected-sites($from, $id, $seen = Set.new) {

    my $neighbors = Set.new(self.get-neighbors($from));
    # $*ERR.say("Neighbors: { $neighbors.perl }");
    $neighbors = $neighbors (-) $seen;
    # $*ERR.say("Filtered neighbors: { $neighbors.perl }");

    my @my-neighbors = $neighbors.keys.grep(-> $dest {
      # $*ERR.say("looking up river name $from -> $dest");
      my $river_name = river-name( {source => $from, target => $dest} );
      # $*ERR.say("river name $from -> $dest is $river_name");
      $.rivers{$river_name}<claim>.defined && $.rivers{$river_name}<claim> == $id
    });

    # $*ERR.say("Connected rivers from $from by $id: { @my-neighbors.perl }");

    return @my-neighbors;

    # my $all-seen = $seen (+) Set.new(|@my-neighbors);
    # my @my-connected = @my-neighbors.map( -> $n {
    #   self.connected-sites($n, $id, $all-seen)
    # }).flat;

    # return @my-connected;
  }

  method score {
    # self.graphviz;

    my @player-score = (^$.punters).map: -> $id {
      { punter => $id, score => 0 }
    };
    # $*ERR.say("scores: { @player-score.perl }");

    for $.map<mines>.list -> $mine {
      for ^$.punters -> $id {
        # $*ERR.say("Calculating score for mine $mine player $id");

        my @mine-player-sites = self.connected-sites($mine, $id);
        # $*ERR.say("sites: { @mine-player-sites.perl }");

        my @distances = @mine-player-sites.map(-> $site {
          self.distance($mine, $site)
        });
        my $mine-player-score = [+] @distances.map(* ** 2);
        # $*ERR.say("mine-player-score: $mine-player-score");
        @player-score[$id]<score> += $mine-player-score;
      }
    }
    # $*ERR.say("scores: { @player-score.perl }");


    return @player-score;
  }

  sub river-name($river) {
    ($river<source>, $river<target>).sort.join('-');
  }
}

