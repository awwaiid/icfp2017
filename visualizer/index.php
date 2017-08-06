<?php
if (isset($_GET['echo'])) {
    echo $_GET['echo'];
    exit;
}

if (isset($_GET['loadResult'])) {

}

if (isset($_GET['getMap'])) {
    if ($_GET['getMap'] && file_exists(__DIR__ . '/../../maps/' . $_GET['getMap'])) {
        echo file_get_contents(__DIR__ . '/../../maps/' . $_GET['getMap']);
    } else {
        echo file_get_contents(__DIR__ . '/../../maps/sample.json');
    }
    exit;
}
?>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Map Viewer</title>
    <link rel="stylesheet" href="bootstrap.min.css">
    <link rel="stylesheet" href="viewer.css">
  </head>
  <body>
    <div class="container-fluid">
      <h1>&#955; Map Viewer</h1><input type="text" value="result.json" id="resultFile" />
        <input type="submit" onClick="getResultFile()" />

        <span style="float:right" id="arrows">
            <input type="submit" value="< prev" onClick="previousMove()" />
            <input type="submit" value="next >" onClick="nextMove()" />
        </span>
        <fieldset>
        <legend>Game Information <span id="gameLoaded"></span></legend>
          <div class="info-sec">
              <label>Player Count</label><div class="info-content" id="info-player-count">-</div></div>
          <div class="info-sec">
              <label>Map Name</label><div class="info-content" id="info-map-name">-</div></div>
          <div class="info-sec">
              <label>Current Move Count</label><div class="info-content" id="info-move-count">-</div></div>
          <div class="info-sec">
              <label>Total Moves</label><div class="info-content" id="info-total-move-count">-</div></div>
          <div class="info-sec">
              <label>Last Punter</label><div class="info-content" id="info-last-punter">-</div></div>
          <div class="info-sec">
              <label>Last Move</label><div class="info-content" id="info-last-move">-</div></div>
          <!-- <textarea id="info-world"></textarea> -->
      </fieldset>
    </div>
    <div class="container-fluid">
      <fieldset>
        <legend>Canvas</legend>
        <div class="container-fluid" id="cy"></div>
        <div id="loading">
          <span class="fa fa-refresh fa-spin"></span>
        </div>
      </fieldset>
    </div>
    <!--- load scripts -->
    <script src="jquery.min.js"></script>
    <script src="bootstrap.min.js"></script>
    <script src="fastclick.min.js"></script>
    <script src="cytoscape.min.js"></script>
    <script src="bluebird.min.js"></script>
    <script src="js-core.js"></script>
    <script src="viewer.js"></script>
    <script>
        $(function(){
            //selectJson(result.state.map);
            //selectResult("/result.json");
            $("#arrows").hide();
        })
    </script>
    <br><br><br>
    </body>
</html>
