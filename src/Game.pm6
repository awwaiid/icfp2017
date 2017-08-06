
class Game {
  has $.map;
  has %.rivers;
  has $.state;
  has $.punters;
  # has $.distances;
  has $.sites;

  method TWEAK {

    if $!state<map> {
      $!map = $.state<map>;
    }

    if $!state<punters> {
      $!punters = $!state<punters>;
    }

    # Initialize a hash of rivers
    # if $!state<rivers> {
    #   %.rivers = $!state<rivers>;
    # } else {
      %.rivers = $!map<rivers>.map: -> $river {
        self.river-name($river) => $river
      }
    # }

    # if $.state<distances> {
    #   $!distances = $.state<distances>;
    #   # $*ERR.say("State Distances: { $!distances.gist }");
    # } else {
    #   $!distances = $.map<mines>.map( -> $mine {
    #     $mine => self.all-distance-from($mine)
    #   }).hash;
    #   # $*ERR.say("Distances: { $!distances.gist }");
    #   $!state<distances> = $!distances;
    # }

    if $!state<sites> {
      $!sites = $!state<sites>;
    } else {
      # $*ERR.say("Caching neighbors");
      self.cache-neighbors;
      $!sites = $!state<sites>;
      my $distances = $!map<mines>.map( -> $mine {
        $mine => self.all-distance-from($mine)
      }).hash;
      for $distances.kv -> $mine, $dist {
        for $dist.kv -> $site, $d {
          $!state<sites>{$site}<distance>{$mine} = $d;
        }
      }
      $!sites = $!state<sites>;
      # $*ERR.say("saving state sites { $!sites.gist }");
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
      my $river = self.river-name($move<claim>);
      if ! %.rivers{$river} {
        # $*ERR.say("WARN: River '$river' doesn't exist");
      } elsif defined %.rivers{$river}<claim> {
        # $*ERR.say("WARN: $river is already taken!");
      } else {
        %.rivers{$river}<claim> = $player;
      }
    }
  }

  method get-neighbors($source) {
    # LEAVE { $*ERR.say("get-neighbors $source took { now - ENTER { now } } seconds"); }
    if $.sites{$source}<neighbors> {
      # $*ERR.say("get-neighbors cache hit!");
      return $.sites{$source}<neighbors>;
    } else {
      $*ERR.say("get-neighbors $source cache MISS -- { callframe(2).gist }");
    }
    my @rivers = $.map<rivers>.grep({ $^r<source> == $source || $^r<target> == $source});
    @rivers.map(*<source target>).flat.grep(* != $source).list;
  }

  method cache-neighbors {

    for $.map<sites>.list -> $site {
      my $site-id = $site<id>;
      my @touching-sites = $.map<rivers>.grep({
        $^r<source> == $site-id
        || $^r<target> == $site-id
      }).map( *<source target> ).flat;
      my @n = @touching-sites.grep( -> $site { $site != $site-id }).list;
      $!state<sites>{$site-id}<neighbors> = @n.sort.unique;
    }
  }

  method distance($source, $target) {
    # LEAVE { $*ERR.say("distance $source -> $target took { now - ENTER { now } } seconds"); }
    return 0 if $source == $target;
    # if defined $!distances{$source}{$target} {
    #   return $!distances{$source}{$target};
    # }
    if defined $!sites{$target}<distance>{$source} {
      return $!sites{$target}<distance>{$source};
    }
    my $seen = set();
    # Seed with distance 1
    my @next = self.get-neighbors($source).map({($_, 1)}).list;
    while @next {
      my ($n, $dist) = @next.shift;
      next if $n (elem) $seen;
      $seen (|)= $n;
      if $n == $target {
        return $dist;
      }
      my @neighbors = self.get-neighbors($n);
      my @nnext = @neighbors.map(-> $nn { ( $nn, $dist + 1 ) }).list;
      @next.push(|@nnext);
    }
    die "Error: no path from $source to $target";
  }

  method all-distance-from($source) {
    # LEAVE { $*ERR.say("distance $source took { now - ENTER { now } } seconds"); }
    my @initial_neighbors = self.get-neighbors($source).list;
    my $sites = {};
    my @next = @initial_neighbors.map({($_, 1)}).list;
    while @next {
      # $*ERR.say("Next: { @next.perl }");
      my ($n, $dist) = @next.shift;
      # $*ERR.say("n: { $n.perl }");
      next if $sites{$n}; # Already seen
      $sites{$n} = $dist;
      my @neighbors = self.get-neighbors($n).list;
      # $*ERR.say("neighbors: { @neighbors.perl }");
      my @nnext = @neighbors.map(-> $nn { ( $nn, $dist + 1 ) }).list;
      @next.push(|@nnext);
    }
    return $sites;
  }

  method graphviz {
    $*ERR.say("graph \{");
    for $.map<rivers>.list -> $river {
      $*ERR.say("$river<source> -- $river<target> ; ");
    }
    $*ERR.say("}");
  }

  method connected-sites($from, $id) {
    # LEAVE { $*ERR.say("connected-sites took { now - ENTER { now } } seconds"); }

    my $seen = set $from;
    my @sites = $from;

    while @sites {
      my $current = @sites.shift;
      my $neighbors = self.get-neighbors($current);
      $neighbors = $neighbors (-) $seen;
      for $neighbors.keys -> $dest {
        my $river_name = self.river-name( {source => $current, target => $dest} );
        if $.rivers{$river_name}<claim>.defined && $.rivers{$river_name}<claim> == $id {
          # This one is good to follow
          @sites.push($dest);
          $seen (|)= ($dest);
        }
      }
    }

    $seen (-)= $from; # Don't count the original

    $seen.keys;
  }

  method score {
    my @player-score = (^$.punters).map: -> $id {
      { punter => $id, score => 0 }
    };

    for ^$.punters -> $id {
      @player-score[$id]<score> = self.player-score($id);
    }

    return @player-score;
  }

  method player-score($id) {
    my $score = 0;
    for $.map<mines>.list -> $mine {
      my @mine-player-sites = self.connected-sites($mine, $id);
      my @distances = @mine-player-sites.map(-> $site {
        self.distance($mine, $site)
      });
      my $mine-player-score = [+] @distances.map(* ** 2);
      $score += $mine-player-score;
    }
    return $score;
  }

  method available-rivers {
    my $rivers = $.state<rivers>;
    $rivers.values.grep({! $^claim<claim>.defined }).list;
  }

  method river-name($river) {
    # $*ERR.say("Building river: { $river.perl }");
    ($river<source>, $river<target>).sort.join('-');
  }
}

