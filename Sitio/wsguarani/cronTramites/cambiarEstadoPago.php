<?php

include('tramites.php');

// Recepcion de parametros
$hashAlumno = $_GET['hc'];
$tramites = new Tramites();
$estado = $tramites->cambiarEstadoCobro($hashAlumno);
if ($estado) {
    http_response_code(200);
} else {
    http_response_code(204);
}