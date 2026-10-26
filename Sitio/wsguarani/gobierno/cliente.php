<?php
require_once("../adodb/adodb.inc.php");
require_once('funciones.php');
require_once('../nusoap/lib/nusoap.php');

         
//header('Content-type: text/plain; charset=utf-8');       

$wsdl=WSDLG."gobierno?wsdl"; //el nombre del archivo servidor
//print_r($wsdl);die;
$client=new nusoap_client($wsdl, 'wsdl');
$client->setCredentials("wsguarani","WSgua23rect","basic");

$err = $client->getError();
if ($err) {
    // error if any
    echo 'Constructor error' . $err; 
} 


$apellido = array('Piñero','Scarafía','Pérez','Góngora',);
//$apellido = iconv("ISO-8859-1", "utf-8", $apellido);

$nombre = array('Beatriz','Sebastián Andrés','Agostina Marianela','Sebastián');
//$nombre = iconv("ISO-8859-1", "utf-8", $nombre);

$dni = array(40554952,37300397,41905654,39658731);

$sexo= array('F','F','F','M','M','F','F');

$ua= array('1','1','1','1','2','2','2');

//for($i=0;$i<count($dni);$i++){
//$param = array('TI'=>'1','UA'=>$ua[$i],'apellido'=>$apellido[$i],'nombre'=>$nombre[$i],'Tdni'=>'1','dni'=>$dni[$i],'sexo'=>$sexo[$i],'fecha'=>'08/05/2018');
$param = array('TI'=>'1','UA'=>"7",'apellido'=>'Piñero','nombre'=>'Beatriz','Tdni'=>"1",'dni'=>'38896452','sexo'=>"M",'fecha'=>'25/02/2014');
//$param = array('tipo'=>'0','documento'=>"29686498");
//$param = array('usuario'=>'29349542','unidadAcademica'=>'04','posgrado'=>'0');
//$respuesta = $client->call('autenticar');
$resultado = $client->call('esAlumno', $param);

//phpinfo();
//var_dump($resultado);die;
if($resultado[0][0] == 2){
	echo "Usuario o password No VALIDO";
		}else if ($resultado[0][0] == 88){
			echo "Error: Algun campo es vacio.";
			}else if ($resultado[0][0] == 1){
				echo "Error: Error de institucion.";
				}else if($resultado[0][0] == 3){
				  echo "Error de servicio.";
				  }else	if ($resultado[0][0] == 4)
							{
							echo "Error inesperado.";
							}else {         echo mb_detect_encoding($resultado[0][1]);
									?><br><?php                                                                        
									echo $resultado[0][0];
									?><br><?php
									echo $resultado[0][1];
									?><br><?php
									echo $resultado[0][2];
									?><br><?php
									echo $resultado[0][3];
                                                                        ?><br><?php
								   }
//}
				
/*if($resultado==1)
	echo $resultado." = Tiene Usuario";
else if($resultado==0)
	echo $resultado." = NO tiene usuario, IMPOSTOR!!!";
else
	echo "Error ".$resultado
        */
?>