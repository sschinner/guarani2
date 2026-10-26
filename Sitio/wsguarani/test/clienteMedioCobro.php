<?php

include_once '../../clientes_ws/mediosCobro/clientews.php';

$pagos = new ClienteMediosCobro();
$datos = new stdClass();
$datos->tipoDoc = "1";
$datos->nroDoc = "28647934";
$datos->apellido = "TORRES";
$datos->nombre = "Vanina Elena";
$datos->email = "lalala2@hotmail.com";
$datos->monto = "160.00";
$datos->cuotas = "1";
$datos->periodo = "03/2018";
$datos->detalle = "Tasa por Certificado Analitico";
$datos->vigencia = 30;
$datos->entidad = "1";
$datos->idServicio = "1";
$datos->identificadorDeuda = "101720180305091112";
$datos->url = "https://servicios.unl.edu.ar/integracion/guarani/ws/cronTramites/cambiarEstadoPago.php?hc=ebc89411a6e6230304ce24c0205f7c53";
// $datos->medioPago = array(0 => "1", 1 => "2", 2 => "3");
$medioPago = explode(',', $pagos->configApp['wsMediosDeCobro']['medioPago']);
$datos->medioPago = ($medioPago[0] == "") ? array() : $medioPago;
//$datos->medioPago = array();
$resultado = $pagos->notificarNuevoCobro($datos);
var_dump($resultado);


/*$mediosCobro = $pagos->obtenerMediosCobro();
echo "Los medios de cobro son: <br /><br />";
var_dump($mediosCobro);*/

/*$entidades = $pagos->obtenerEntidades();
echo "Las entidades de pago son: <br /><br />";
var_dump($entidades);*/

// $idCobro = '6f4922f45568161a8cdf4ad2299f6d23';
// 6f4922f45568161a8cdf4ad2299f6d23
// 1f0e3dad99908345f7439f8ffabdffc4
// $estado = $pagos->consultarEstadoCobro($idCobro);
// echo "El estado del pago " . $idCobro .": <br /><br />";
// var_dump($estado);



/*echo "<br /><br />";
echo "El estado del pago " . $idCobro .": <br /><br />";
var_dump($estado);
echo "<br /><br />";
if ($estado["return"]["cobrada"] == "true") {
    echo "TRUE";
} else {
    echo "FALSE";
}
echo "<br /><br />";
print_r($pagos->configApp);
$mediosPago = explode(",",$pagos->configApp["wsMediosDeCobro"]["medioPago"]);
echo "<br /><br />";
print_r($mediosPago);*/