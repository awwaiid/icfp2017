let gameLoaded = false;
let lastMove = {};
let lastMoveCount = 0;
let lastPunter = 0;
let playerCount = 0;
let mapName = '';
let world = {}

function getResultFile() {
    mapName = $("#resultFile").val();
    console.log('getting result file' + mapName);
    var url = "./" + mapName;
    fetch(url, {mode: "no-cors"})
        .then(function(res) {
            return res.json()
        }).then(function(json) {
            world = json;
            gameLoaded = true;
            $("#arrows").show();
            playerCount = world[0].state.punters;
            lastPunter = world[0].state.punter;
            lastMoveCount = world[0].state.move_num + 1;
            refreshInfo();
        });

}

function nextMove() {
    if (lastMoveCount >= world.length) {
        alert('game finished');
    } else {
        console.log('next');
        lastMoveCount++;
        refreshInfo();
    }
}

function previousMove () {
    console.log('previous');
    lastMoveCount --;
    if (lastMoveCount < 1) lastMoveCount = 1;
    refreshInfo();
}


function refreshInfo()
{
    console.log(world[lastMoveCount -1]);
    lastMove = world[lastMoveCount-1].move;
    $("#gameLoaded").html(gameLoaded ? "IN PROGRESS" : "");
    $("#info-player-count").html(playerCount);
    $("#info-map-name").html(mapName);
    $("#info-move-count").html(lastMoveCount);
    $("#info-total-move-count").html(world.length);
    $("#info-last-punter").html(lastPunter);
    $("#info-last-move").html(JSON.stringify(world[lastMoveCount -1].move.moves[lastPunter]));
    $("#info-world").html(JSON.stringify(world))
    refreshMap();
}

function refreshMap() {
    if (cy.elements !== undefined) {
        cy.destroy();
    }
    initCy(world[lastMoveCount-1].state.map, function () {
        cy.autolock(true);
        cy.edges().on("select", function(evt) { cy.edges().unselect() } );
    } );

    //console.log(world[lastMoveCount - 1 ].state.map);
    $.each(world[lastMoveCount-1].state.map.rivers, function(index,value) {
        if (value.claim !== undefined) {
            console.log(index + "::" + JSON.stringify(value));
            updateEdgeOwner(value.claim, value.source, value.target);
        }
    })
}

function updateEdgeOwner(punter, source, target) {
    const es = cy.edges("[source=\"" + source + "\"][target=\"" + target + "\"]");
    if (es.length > 0) {
        const e = es[0];
        e.data()["owner"] = punter;
        e.style("line-color", getPunterColour(punter));
    } else {
        logError("Trying to update nonexistent edge! (" + source + " -- " + target + ")");
    }
}


/* Graph rendering */

const colours =
    [
        'green',
        'red',
        'yellow',
        "#2ca02c",
        "#dbdb8d",
        "#f7b6d2",
        "#1f77b4",
        "#aec7e8",
        "#9467bd",
        "#7f7f7f",
        "#ff7f0e",
        "#ffbb78",
        "#98df8a",
        "#d62728",
        "#ff9896",
        "#c5b0d5",
        "#8c564b",
        "#e377c2",
        "#c7c7c7",
        "#bcbd22",
        "#17becf",
        "#9edae5"
    ];

function getPunterColour(punter) {
    return colours[punter % colours.length];
}

function renderGraph(graph) {
    initCy(graph,
        function() {
            initialised = true;
            cy.autolock(true);
            bindCoreHandlers();
            if (queuedClaims.length > 0 || queuedPass) {
                playQueuedClaims();
                ourTurn();
            } else {
                theirTurn();
            }
        }
    );
    return;
}








