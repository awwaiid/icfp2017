<?php

namespace Punter;

/**
 * Class Map
 * @package Punter
 */
class Map
{
    /**
     * @var Site[]
     */
    private $sites;

    /**
     * @var River[]
     */
    public $rivers;

    /**
     * @var int[]
     */
    public $mines;

    /**
     * @var int
     */
    private $punter;

    /**
     * @var int
     */
    private $punters;

    /**
     * @var int
     */
    private $moveNum = 0;

    /**
     * @var array
     */
    private $claimedRivers = [];

    /**
     * Map constructor.
     * @param array $world
     */
    public function __construct(array $world)
    {
        $this->punter = $world['punter'];
        $this->punters = $world['punters'];
        $this->import($world['map']);
        $this->moveNum = $world['move_num'];
        foreach ($world['rivers'] as $key => $rc) {
            $this->claimedRivers[$key] = new River($rc);
        }
    }

    /**
     * @param array $map
     */
    public function import(array $map)
    {
        foreach ($map['sites'] as $site) {
            $this->sites[] = new Site($site['id'], $site['x'], $site['y']);
        }
        foreach ($map['rivers'] as $river) {
            $this->rivers[] = new River($river);
        }
        $this->mines = $map['mines'];
    }

    /**
     * @return int
     */
    public function getSiteCount()
    {
        return count($this->sites);
    }

    /**
     * @return int
     */
    public function getRiverCount()
    {
        return count($this->rivers);
    }

    /**
     * @param int $index
     * @return River|River[]
     */
    public function getRivers($index = null)
    {
        if (is_int($index)) {
            return $this->getRiver($index);
        } else {
            return $this->rivers;
        }
    }

    /**
     * @param $index
     * @return null|River
     */
    public function getRiver($index)
    {
        return isset($this->rivers[$index]) ? $this->rivers[$index] : null;
    }

    /**
     * @return int
     */
    public function getMineCount()
    {
        return count($this->mines);
    }

    /**
     * @return int
     */
    public function getPunter()
    {
        return $this->punter;
    }

    /**
     * @return int
     */
    public function getPunters()
    {
        return $this->punters;
    }
}

/**
 * Class River
 * @package Punter
 */
class River
{
    /**
     * @var int
     */
    private $source;

    /**
     * @var int
     */
    private $target;

    /**
     * @var int
     */
    private $claim;

    /**
     * River constructor.
     * @param array $river
     */
    public function __construct(array $river)
    {
        $this->source = $river['source'];
        $this->target = $river['target'];
        if (isset($river['claim'])) {
            $this->claim = $river['claim'];
        }
    }

    /**
     * @return bool
     */
    public function isClaimed()
    {
        return $this->getClaim() !== null;
    }

    /**
     * @return array
     */
    public function toArray()
    {
        return ['source' => $this->getSource(), 'target' => $this->getTarget(), 'claim' => $this->getClaim()];
    }

    /**
     * @return int
     */
    public function getSource()
    {
        return $this->source;
    }

    /**
     * @param int $source
     */
    public function setSource($source)
    {
        $this->source = $source;
    }

    /**
     * @return int
     */
    public function getTarget()
    {
        return $this->target;
    }

    /**
     * @param int $target
     */
    public function setTarget($target)
    {
        $this->target = $target;
    }

    /**
     * @return int
     */
    public function getClaim()
    {
        return $this->claim;
    }

    /**
     * @param int $claim
     */
    public function setClaim($claim)
    {
        $this->claim = $claim;
    }

    public function prettyPrint()
    {
        $out = "Source: " . $this->getSource() . " Target: " . $this->getTarget();
        if ($this->isClaimed()) {
            $out .= " ==CLAIMED== ";
        }
        return $out;
    }
}

/**
 * Class Site
 * @package Punter
 */
class Site
{
    /**
     * @var
     */
    public $id;
    /**
     * @var
     */
    public $x;
    /**
     * @var
     */
    public $y;
    /**
     * @var bool
     */
    public $isMine = false;

    /**
     * Site constructor.
     * @param $id
     * @param $x
     * @param $y
     */
    public function __construct($id, $x, $y)
    {
        $this->id = $id;
        $this->x = $x;
        $this->y = $y;
    }
}
