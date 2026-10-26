<?php
namespace personalizacionCEMEDDIPLOMA\modelo\autenticacion;

use kernel\acceso\login_manager;
use siu\modelo\datos\catalogo;
use siu\errores\error_guarani_login;
use siu\errores\error_guarani_login_externo;
use \kernel\kernel;
use \siu\modelo\entidades\parametro;
use kernel\util\bcrypt;
use siu\modelo\entidades\persona;

class fuente_usuarios_guarani  extends \siu\modelo\autenticacion\fuente_usuarios_guarani{
    
    protected function ejecutar_login($id, $clave)
	{
		$enc = new bcrypt(10);
		$this->usuario = $id;
		$parametros = array('id' => $id );
		$datos_clave = catalogo::consultar('persona', 'buscar_clave', $parametros);

		if (empty($datos_clave)) {
			$this->status = error_guarani_login::id_inexistente;
			throw new error_guarani_login(error_guarani_login::id_inexistente);
		}

		$login_ok = ($enc->verify(($clave), current($datos_clave)));
		if ($login_ok===false) {
			$this->status = error_guarani_login::clave_invalida;
			throw new error_guarani_login(error_guarani_login::clave_invalida);
		}

		$this->status = error_guarani_login::conexion_ok;
		return $datos_clave;
	}
    
}

