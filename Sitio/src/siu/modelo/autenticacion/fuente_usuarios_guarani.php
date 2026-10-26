<?php
namespace siu\modelo\autenticacion;

use kernel\acceso\login_manager;
use siu\modelo\datos\catalogo;
use siu\errores\error_guarani_login;
use siu\errores\error_guarani_login_externo;
use \kernel\kernel;
use \siu\modelo\entidades\parametro;
use kernel\util\bcrypt;
use siu\modelo\entidades\persona;

class fuente_usuarios_guarani
{

//
//	GUARDO DATOS PARA REGISTRAR EL INGRESO (SE PIDE LUEGO DEL LOGIN)
//
	protected $nro_inscripcion;
	protected $status;
	protected $identificacion;
	protected $mensaje;

	/**
	 * id: como es multiperfil, se podria usar cualquier ID
	 * el login tiene que fallar si no tiene al menos un perfil definido.
	 *
	 * retorna el NUMERO DE INSCRIPCION de la persona
	 */
	function autenticar_usuario_clave($id, $clave)
	{
		$this->identificacion = $id;
		$datos = $this->ejecutar_login($id, $clave);
		return $this->validar_persona_logueada($datos[1]);

	}

	/**
	 * @param $params array (proveedor, id, mail)
	 * @throws \siu\errores\error_guarani_login
	 * @return mixed
	 */
	function autenticar_login_externo($params)
	{
		$this->identificacion = $params['id'];
		$persona = catalogo::consultar('persona', 'login_externo', $params);
		if(empty($persona)){
			$this->throw_error_guarani(error_guarani_login::cuenta_externa_invalida);
		}

		return $this->validar_persona_logueada($persona[0]);
	}

	/**
	 * @param $attributes array atributos de saml,
	 * @param $uid_local  string la columna local
	 * @param $uid_saml   string el atributo que referencia al id en saml
	 * @throws \siu\errores\error_guarani_login
	 * @return integer id_persona
	 */
	function autenticar_login_saml($attributes, $uid_local, $uid_saml)
	{
		$this->identificacion = $attributes[$uid_saml][0];
		$funcion = 'saml_buscar_por_'.$uid_local;
		$parametros = array($uid_local => $this->identificacion);

		$persona = catalogo::consultar('persona', $funcion, $parametros);
		if(empty($persona)){
			$this->throw_error_guarani(error_guarani_login::cuenta_externa_invalida);
		}
		return $this->validar_persona_logueada($persona[0]);
	}

	protected function ejecutar_login($id, $clave)
	{
		$enc = new bcrypt(10);
		$parametros = array('id' => $id );
		$datos_clave = catalogo::consultar('persona', 'buscar_clave', $parametros);

		if (empty($datos_clave)) {
			$this->throw_error_guarani(error_guarani_login::id_inexistente);
		}

		$login_ok = ($enc->verify(md5($clave), current($datos_clave)));
		if ($login_ok===false) {
			$this->throw_error_guarani(error_guarani_login::clave_invalida);
		}
		return $datos_clave;
	}

	function registrar_login($auth)
	{
		if(isset($this->status)){ //se logueo este request
			$parametros = array('id'		=> $this->identificacion,
			                    'status'	=> $this->status,
								'nro_inscripcion' => $this->nro_inscripcion,
			                    'registrar'	=> parametro::registrar_log_ingresos(),
								'origen_login' => $auth->get_id(),
			                    'interfaz'	=> kernel::agente()->es_browser()?'3':'5',
			                    'ip'	=> kernel::login_manager()->get_real_ip()
			);

			switch($this->status){
				case error_guarani_login::id_inexistente:
					$parametros['mensaje'] = kernel::traductor()->trans('login.aud.id_inexistente');
					break;
				case error_guarani_login::clave_invalida:
					$parametros['mensaje'] = kernel::traductor()->trans('login.aud.clave_invalida');
					break;
				case error_guarani_login::conexion_ok:
					$parametros['mensaje'] = kernel::traductor()->trans('login.aud.conexion_ok');
					break;
				case error_guarani_login::cuenta_externa_invalida:
					$parametros['mensaje'] = kernel::traductor()->trans('login.aud.cuenta_externa_invalida');
					break;
				case error_guarani_login::no_tiene_perfiles:
					$parametros['mensaje'] = kernel::traductor()->trans('login.aud.no_tiene_perfiles');
					break;
				default:
					$parametros['mensaje'] = 'no-especificado';
			}
			catalogo::consultar('persona', 'insertar_registro_logueo', $parametros);
		}
	}


	protected function validar_persona_logueada($nro_inscripcion)
	{
		$this->nro_inscripcion = $nro_inscripcion;
		$cantidad_perfiles = count(persona::get_perfiles_validos($nro_inscripcion));
		if ($cantidad_perfiles == 0) {
			$this->throw_error_guarani(error_guarani_login::no_tiene_perfiles);
		}
		$this->status = error_guarani_login::conexion_ok;
		return $nro_inscripcion;
	}

	protected function throw_error_guarani($error_type){
		$this->status = $error_type;
		throw new error_guarani_login($error_type);
	}
}
?>