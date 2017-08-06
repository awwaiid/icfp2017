<?php

namespace Punter;

/**
 * Class Punter
 * @package Punter
 */
class Punter
{
    /**
     * @var Map
     */
    private $map;

    /**
     * @var string
     */
    private $strategy = 'random';

    /**
     * @var string
     */
    private $name = 'PHPunter';

    /**
     * @var array
     */
    public $debug = [];

    /**
     * @return string
     */
    public function findMove()
    {
        $this->addDebug('Using Strategy: ' . $this->strategy);
        /** @var River $river */
        $river = $this->{$this->strategy}();
        if ($river) {
            $this->addDebug('Picking River Segment: ' . $river->prettyPrint());
        }
        if (!$river) {
            return ['pass' => ["punter" => $this->getMap()->getPunter()]];
        }
        $move = array_merge(["punter" => $this->getMap()->getPunter()], $river->toArray());
        return ['claim' => $move];
    }

    /**
     * @return River|null
     */
    public function random()
    {
        $possibleRivers = $this->getMap()->getRivers();
        $this->addDebug("River Count " . count($possibleRivers));
        if (count($possibleRivers)) {
            $riverPosition = null;
            while ($riverPosition === null || $this->getMap()->getRivers($riverPosition)->isClaimed()) {
                $riverPosition = rand(0, count($possibleRivers) - 1);
            }
            $this->addDebug("Picking " . $riverPosition);
            return isset($possibleRivers[$riverPosition]) ? $possibleRivers[$riverPosition] : null;
        }
        return null;
    }

    /**
     * @return mixed|null|River
     */
    public function adjacent()
    {
        $possibleRivers = $this->getMap()->getRivers();
        $this->addDebug("River Count " . count($possibleRivers));
        $claimed = $unclaimed = [];
        $this->addDebug('Finding for punter ' . $this->getMap()->getPunter());
        foreach ($possibleRivers as $possible) {
            if ($possible->isClaimed()) {
                if ($possible->getClaim() == $this->getMap()->getPunter()) {
                    $claimed [] = $possible;
                }
            } else {
                $unclaimed [] = $possible;
            }
        }

        $this->addDebug("unclaimed count " . count($unclaimed));
        foreach ($this->getMap()->getMines() as $mine) {
            $this->addDebug('Checking out mine ' . $mine);
            foreach ($claimed as $cr) {
                if ($cr->adjacentToSite($mine)) {
                    continue 2;
                }
            }
            foreach ($unclaimed as $ur) {
                //$this->addDebug("inspecting unclaimed river " . $ur->prettyPrint());
                if ($ur->adjacentToSite($mine)) {
                    $this->addDebug('found adjacent mine');
                    return $ur;
                }
            }
        }

        foreach ($claimed as $cr) {
            //$this->addDebug('inspecting claimed river ' . $cr->prettyPrint());
            foreach ($unclaimed as $ur) {
                //$this->addDebug("inspecting unclaimed river " . $ur->prettyPrint());
                if ($cr->adjacentTo($ur)) {
                    $this->addDebug('Found Adjacent');
                    return $ur;
                }
            }
        }

        $this->addDebug('no adjacent to pick from, going random');
        return $this->random();

    }

    /**
     * @return mixed|null|River
     */
    public function longest()
    {
        //separate list of claimed vs unclaimed out of
        $possibleRivers = $this->getMap()->getRivers();
        $claimed = $taken = $unclaimed = [];
        foreach ($possibleRivers as $possible) {
            if ($possible->isClaimed()) {
                if ($possible->getClaim() == $this->getMap()->getPunter()) {
                    $claimed [] = $possible;
                } elseif ($possible->getClaim() !== null) {
                    $taken [] = $possible;
                }
            } else {
                $unclaimed [] = $possible;
            }
        }
        $this->addDebug(
            "Claimed: " . count($claimed) . " Unclaimed: " . count($unclaimed) . " Taken: " . count($taken)
        );

        if (empty($claimed)) {
            $this->addDebug('No Claimed Yet .. lets get a mine');
            foreach ($this->getMap()->getMines() as $mine) {
                $this->addDebug('Checking out mine ' . $mine);
                foreach ($unclaimed as $ur) {
                    //$this->addDebug("inspecting unclaimed river " . $ur->prettyPrint());
                    if ($ur->adjacentToSite($mine)) {
                        $this->addDebug('found adjacent mine');
                        return $ur;
                    }
                }
            }
        }

        // eliminate unclaimed rivers where we have already visited both sites.
        $sites = $claimedMines = [];
        foreach ($claimed as $c) {
            $sites [] = $c->getTarget();
            $sites [] = $c->getSource();
        }
        $sites = array_unique($sites);
        foreach ($sites as $s) {
            foreach ($this->getMap()->getMines() as $m) {
                if ($s == $m) {
                    $claimedMines [] = $m;
                }
            }
        }
        $this->addDebug('Claimed Mines: ' . count($claimedMines));
        foreach ($unclaimed as $key => $u) {
            if (in_array($u->getTarget(), $sites) && in_array($u->getSource(), $sites)) {
                unset($unclaimed[$key]);
            }
        }

        // get longest chain
        $chains = [];
        $this->addDebug('finding longest chain... ');
        foreach ($claimed as $key => $claim) {
            foreach ($chains as $k => $chain) {
                foreach ($chain as $c) {
                    if ($claim->adjacentTo($c)) {
                        $this->addDebug("add to chain(". $k . "): " . $c->prettyPrint());
                        $chains[$k][] = $claim;
                        continue 3;
                    }
                }
            }
            $chains [] = [$claim];
        }
        $this->addDebug('chain count: ' . count($chains));
        // sort by longest
        usort(
            $chains,
            function ($a, $b) {
                return (count($a) < count($b)) ? 1 : -1;
            }
        );

        $this->addDebug("longest chain is " . (count($chains) ? count($chains[0]) : 0));
        $this->addDebug("unclaimed count " . count($unclaimed));

        $possibilities = [];
        foreach ($chains as $c) {
            foreach ($c as $r) {
                foreach ($unclaimed as $u) {
                    if ($u->adjacentTo($r)) {
                        $possibilities[] = $u;
                    }
                }
            }
            if (count($possibilities)) {
                $this->addDebug("Continuing Chain: " . print_r($possibilities, true));
                break;
            }
        }
        $greatestDistance = 0;
        $bestMove = null;
        if (count($possibilities)) {
            foreach ($possibilities as $p) {
                foreach ($claimedMines as $m) {
                    $distance = $this->getMap()->getSiteDistance($p->getSource(), $m);
                    if ($distance > $greatestDistance) {
                        $greatestDistance = $distance;
                        $bestMove = $p;
                    }
                }
            }
            return $bestMove ?: $possibilities[array_rand($possibilities)];
        }

        foreach ($claimed as $cr) {
            $this->addDebug('inspecting claimed river ' . $cr->prettyPrint());
            foreach ($unclaimed as $ur) {
                //$this->addDebug("inspecting unclaimed river " . $ur->prettyPrint());
                if ($cr->adjacentTo($ur)) {
                    $this->addDebug('Found Adjacent');
                    return $ur;
                }
            }
        }

        $this->addDebug('no adjacent to pick from, going random');
        return $this->random();

    }


    /**
     * @return Map
     */
    public function getMap()
    {
        return $this->map;
    }

    /**
     * @param Map $map
     */
    public function setMap($map)
    {
        $this->map = $map;
    }

    /**
     * @return string
     */
    public function getStrategy()
    {
        return $this->strategy;
    }

    /**
     * @param string $strategy
     */
    public function setStrategy($strategy)
    {
        $this->strategy = $strategy;
    }

    /**
     * @return string
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     * @param string $name
     */
    public function setName($name)
    {
        $this->name = $name;
    }

    /**
     * @return array
     */
    public function getDebug()
    {
        return $this->debug;
    }

    /**
     * @param string $debug
     */
    public function addDebug($debug)
    {
        $this->debug [] = $debug;
    }
}
