<?php

include('tramites.php');

// Recepcion de parametros
$hashRequisito = $_GET['identificador'];
$pathNuxeo = $_GET['path'];
$uidNuxeo = $_GET['uid'];
$tramites = new Tramites();
$estado = $tramites->setPathRequisitoDiploma($hashRequisito, $pathNuxeo, $uidNuxeo);
if ($estado) {
    http_response_code(200);
} else {
    http_response_code(204);
}
