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
        $this->addDebug('Picking River Segment: ' . $river->prettyPrint());
        if (!$river) {
            return ['pass' => ["punter" => $this->getMap()->getPunter()]];
        }
        $move = array_merge(["punter" => $this->getMap()->getPunter()], $river->toArray());
        return ['claim' => $move, 'state' => ['foo' => 'bar']];
    }

    /**
     * @return River|null
     */
    public function random()
    {
        $possibleRivers = $this->getMap()->getRivers();
        $this->addDebug(count($possibleRivers));
        if (count($possibleRivers)) {
            $riverPosition = null;
            while ($riverPosition === null || $this->getMap()->getRivers($riverPosition)->isClaimed()) {
                $riverPosition = rand(0, count($possibleRivers) - 1);
                $this->addDebug($riverPosition);
            }
            return isset($possibleRivers[$riverPosition]) ? $possibleRivers[$riverPosition] : null;
        }
        return null;
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
