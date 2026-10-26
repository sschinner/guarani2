<?php
require_once("adodb/adodb.inc.php");
require_once('funciones.php');
require_once('../nusoap/lib/nusoap.php');

//$wsdl = "http://guarani3w-dev.intranet/wsguarani/fhuc?wsdl"; //el nombre del archivo servidor
$wsdl = WSDLG."fhuc?wsdl";

$client = new nusoap_client($wsdl, 'wsdl');
$client->setCredentials("wsfhuc", "WSfH5c", "basic");

$err = $client->getError();
if ($err) {
    // error if any
    echo 'Constructor error' . $err;
}
$resu=array();
$param = array('tipoTitulo' => '1','anio_academico'=>'2013','periodo_lectivo'=>'2do. Cuatrimestre');
$resultado = $client->call('cursadasFhuc', $param);
$resu[]=json_decode($resultado);
//$respuesta = $client->call('autenticar');
$param = array('tipoTitulo' => '1', 'plan' => '2000', 'carrera' => '06');
$resultado = $client->call('carrerasFhuc', $param);
$resu[]=json_decode($resultado);
// print_r($resultado);die;
$param = array('nroDocumento' => '31200283','tipoTitulo' => '3');
$resultado = $client->call('alumnoReg5aniosFhuc', $param);
$resu[]=json_decode($resultado);
//print_r($resultado);die;
//$resp=json_decode($resultado);
print_r($resu);die;

/*foreach ($resultado as $fila) {
    for ($i = 0; $i < count($fila); $i++) {//$resultado as $fila)
        echo $fila[$i].'<br />';
    }
    echo '-----------------------------------------------------<br/>';
}
/* for ($i=0;$i<count($resultado);$i++)//$resultado as $fila)
  {
  echo $resultado[0][$i].' <br/> ';
  }
  echo "<br /><br />RETURNING : <br />	 nombres.<br /> apellido.<br />
  tipo_documento.<br />
  nro_documento.<br />
  pasaporte<br />	 tipo de usuario.<br /> unidad_academica.<br /> codigo carrera univ.<br />	 fecha_vencimiento.
  <br /> e_mail.<br /> calle_per_lect. <br /> localidad_per_lect.<br /> provincia_per_lect.<br /> pais_per_lect.<br /> te_per_lect.<br /> fax_per_lect.
  <br /> calle_proc.<br /> localidad_proc.<br /> provincia_per_lect.<br /> pais_proc.<br /> te_proc.<br /> fax_proc.";
 */
?>
