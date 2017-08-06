#!/usr/bin/php
<?php

namespace Punter;

include 'Map.php';
include 'Punter.php';


$options = getopt("s:d");
$debug = isset($options['d']);
$strategy = isset($options['s']) ? $options['s'] : 'random';

debug('---------------------------------------------');

/** @noinspection PhpAssignmentInConditionInspection */
while ($line = trim(fgets(STDIN))) {
    //debug($line);
    $input = json_decode($line, true);
    debug(
        'MOVE NUM: ' . $input['state']['move_num'] . "/" . count($input['state']['rivers'])
        . " PUNTER: " . $input['state']['punter']
    );
    $map = new Map($input['state']);
    $punter = new Punter();
    $punter->setMap($map);
    $punter->setStrategy($strategy);
    if (!$input || !is_array($input)) {
        die("Bad Json " . json_last_error() . "\n");
    }
    if (isset($input['stop'])) {
        if (isset($input['stop']['scores'])) {
            debug(print_r($input['stop']['scores'], true));
        }
        debug("Game Over!\n\n\n");
        exit;
    } elseif (isset($input['move'])) {
        debug("Game In Progress");
        $move = $punter->findMove();
        debug(implode("\n", $punter->getDebug()));
        move($move);
    } else {
        die("Unknown Server Operation: " . print_r($input, true));
    }
}



/**
 * @param $move
 */
function move($move)
{
    print json_encode($move) . "\n";
}

/**
 * @param $debugOutput
 */
function debug($debugOutput)
{
    global $debug;
    if ($debug) {
        error_log($debugOutput . "\n", 3, '/tmp/debug');
    }
}
