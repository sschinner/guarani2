<?php
namespace personalizacionPROCAP\operaciones\configuracion;

use kernel\kernel;
use kernel\util\validador;
use kernel\util\mail;
use siu\guarani;
use siu\extension_kernel\controlador_g3w2;
use siu\modelo\datos\catalogo;
use siu\errores\error_guarani_procesar_renglones;
use \siu\errores\error_guarani;
use \siu\modelo\entidades\persona;

class controlador extends \siu\operaciones\configuracion\controlador
{
    function guardar_pass($data)
	{   
		$usuario = guarani::persona()->get_identificacion();
		$actual_pass = $data['password_actual'];
		$nuevo_pass = $data['password'];
		
		try {
			$respuesta = guarani::persona()->actualizar_password($usuario, $actual_pass, $nuevo_pass);
                        $_SESSION['claveKolla']="";
                        $_SESSION['claveKolla']=  md5($nuevo_pass);
		} catch (error_guarani_procesar_renglones $e) {
			$respuesta['cod'] = -1;
			$respuesta['cont'] = "";
			foreach ($e->get_renglones() as $reglon)	{
				$respuesta['cont'] .= $reglon['msg']."<br>";
			}
                        $_SESSION['claveKolla']=  md5($actual_pass);
		}
		return $respuesta;
	}
}
?>
