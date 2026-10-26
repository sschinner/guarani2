<?php
require('adodb/adodb.inc.php');
require_once('nusoap/lib/nusoap.php');

function web_service_insertar_en_kolla($clave,$apellido,$nombres,$email,
					$tipodoc,$nrodoc,$sexo,$fechanac,
					$nombretit,$nombretitfem,$codigotit,
					$ua,$anioegreso,$fechaegreso){

	$wsdl="http://kolla.intranet/wskolla?wsdl"; //el nombre del archivo servidor
       
	$client=new nusoap_client($wsdl, 'wsdl');
     
	$client->setCredentials("wskolla","WSK0ll4","basic");

	$err = $client->getError();
	if ($err) {
	    // error if any
	    echo 'Constructor error' . $err; 
	} 
       
	$param =array('clave'=>$clave, 'apellido'=>  $apellido, 'nombres'=> $nombres, 'email'=>$email,
			'tipodoc'=>$tipodoc, 'nrodoc'=>$nrodoc, 'sexo'=>$sexo, 'fechanac'=>$fechanac,
			'nombretit'=> $nombretit, 'nombretitfem'=>$nombretitfem, 'codigotit'=>$codigotit,
			'ua'=>  $ua, 'anioegreso'=>$anioegreso, 'fechaegreso'=>$fechaegreso);
        
     
	$resultado = $client->call('insertaUsuario', $param,"uri:http://kolla.intranet/wskolla/index.php?wsdl","uri:http://kolla.intranet/wskolla/index.php?wsdl/insertaUsuario");
     
	if($resultado[0][0] == 2){
		$estado = 2;
		$mensaje = "Usuario o password No VALIDO - Contactar con Administrador";
		return $mensaje;
			}else if ($resultado[0][0] == 3){
				$estado = 3;
                		$mensaje = "Error: Algun campo es vacio - Contactar con Administrador";
		                return $mensaje;
				}else if ($resultado[0][0] == 4){
					$estado = 4;
					$mensaje = "Error: Error de procedimiento de insercion - Contactar con Administrador";
					return $mensaje;
						}else if ($resultado[0][0] == 5){
							$estado = 5;
							$mensaje = "Llego hasta ese lugar";
							return $mensaje;
								}else { 
								$estado = 0;
								$mensaje = "El usuario se agrego correctamente.";
								return $mensaje;
						}

}

?>
