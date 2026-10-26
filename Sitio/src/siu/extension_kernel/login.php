<?php
namespace siu\extension_kernel;

use kernel\acceso\login_manager as login_manager;
use siu\modelo\datos\catalogo;
use siu\errores\error_guarani_login;
use siu\errores\error_guarani_login_externo;
use \kernel\kernel;
use \siu\modelo\entidades\parametro;
use siu\guarani;
use kernel\util\bcrypt;
use \siu\modelo\entidades\persona;

class login implements login_manager
{
	
	function ejecutar_login($id, $clave)
	{
		$enc = new bcrypt(10);
		$parametros = array('id'		=> $id, 
							'status'	=> error_guarani_login::conexion_ok, 
							'mensaje'	=> kernel::traductor()->trans('login.aud.conexion_ok'),
							'registrar'	=> parametro::registrar_log_ingresos(),
							'interfaz'	=> kernel::agente()->es_browser()?'3':'5',
							'ip'		=> kernel::login_manager()->get_real_ip()
						);
		$datos_clave = catalogo::consultar('persona', 'buscar_clave', $parametros); 
		if (empty($datos_clave)) {
			$parametros['status'] = error_guarani_login::id_inexistente;
			$parametros['mensaje'] = kernel::traductor()->trans('login.aud.id_inexistente');
			catalogo::consultar('persona', 'insertar_registro_logueo', $parametros);
			throw new error_guarani_login(error_guarani_login::id_inexistente);
		}
		
		$login_ok = ($enc->verify(md5($clave), current($datos_clave)));     
		if ($login_ok===false) { 
			$parametros['status'] = error_guarani_login::clave_invalida;
			$parametros['mensaje'] = kernel::traductor()->trans('login.aud.clave_invalida');
			catalogo::consultar('persona', 'insertar_registro_logueo', $parametros);
			throw new error_guarani_login(error_guarani_login::clave_invalida);
		} 

		$perfiles_validos = persona::get_perfiles_validos($id);; 
		if (count($perfiles_validos) == 0) {
			$parametros['status'] = error_guarani_login::no_tiene_perfiles;
			$parametros['mensaje'] = kernel::traductor()->trans('login.aud.no_tiene_perfiles');
			catalogo::consultar('persona', 'insertar_registro_logueo', $parametros);
			throw new error_guarani_login(error_guarani_login::no_tiene_perfiles);
		}
		
		catalogo::consultar('persona', 'insertar_registro_logueo', $parametros);
		return $datos_clave;
	}
	
	/**
	 * id: como es multiperfil, se podria usar cualquier ID
	 * el login tiene que fallar si no tiene al menos un perfil definido.
	 *
	 * retorna el NUMERO DE INSCRIPCION de la persona
	 */
	function autenticar($id, $clave)
	{
		$datos = $this->ejecutar_login($id, $clave);
		$nro_inscripcion = $datos[1];
		$cantidad_perfiles = count(persona::get_perfiles_validos($nro_inscripcion));
		if ($cantidad_perfiles == 0) {
			throw new error_guarani_login(error_guarani_login::no_tiene_perfiles);
		} 

		// Retorno el numero de inscripcion
		return $datos[1];
	}

	function autenticar_login_externo($id, $mail, $medio, $forzar_login_mail=false)
	{		
		$parametros = array(
			'id'	=> $id,
			'mail'	=> $mail, 
			'medio' => $medio,
			// @todo: sacar esto del parámetro
			'login_mail' => $forzar_login_mail?'S':parametro::permitir_login_mail(),
			'registrar'=>parametro::registrar_log_ingresos(),
			'interfaz'=>kernel::agente()->es_browser()?'3':'5'
			
		);
		
		
		$datos = catalogo::consultar('persona', 'login_externo', $parametros);
		if ($datos[0] != 0) {
			throw new error_guarani_login_externo($datos[3]);
		}
		// Retorno el numero de inscripcion
		return $datos[1];
	}
	
	
	}	
?>