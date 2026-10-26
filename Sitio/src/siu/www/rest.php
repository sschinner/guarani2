<?php
require_once(realpath(dirname(__FILE__)."/../bootstrap.php"));
require_once(realpath(dirname(__FILE__)."/../bootstrap_rest.php"));
$ua = (isset($_GET['ua']))? $_GET['ua'] : false;

try{
    \siu\bootstrap_rest::cargar($ua);
    $acceso = new \kernel\nucleo\acceso_rest();
    $acceso->procesar();
}
catch (Exception $e){
    header('HTTP/1.1 400 Bad Request');
    header('Content-Type: application/json');
    $data = array(
        "error" => "400",
        "mensaje" => "400 Bad Request",
        "descripcion" => utf8_encode($e->getMessage())
    );
    echo json_encode($data);
    exit;
}
