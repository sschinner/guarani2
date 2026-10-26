<?php

namespace siu\modelo\autenticacion;

use kernel\kernel;
use kernel\util\intentos_login;
use siu\errores\error_guarani;
use siu\errores\error_guarani_login;
use siu\guarani;
use siu\modelo\datos\catalogo;
use kernel\nucleo\controlador;


class auth_form extends auth_con_sesion {

	protected $id_persona = null;
	protected $usarios_bd;

	/**
	 * @var error_guarani_login
	 */
	protected $error_login = null;


	public function autenticar()
	{
		if (kernel::request()->isPost()) {
			$usuario = kernel::request()->getPost('usuario');
			$pass = kernel::request()->getPost('password');

			try {
                //Valido el captcha.
				if ($this->controlar_captcha_login($usuario)) {
					$this->check_recaptcha_login();
				}
                //Valido el usuario y la contraseña.
				return $this->id_persona = $this->validar_user_pass($usuario, $pass);

			} catch (error_guarani_login $e) {
				//guardar errores para mostrar en el render_login()
				$this->error_login = $e;
				intentos_login::error($usuario);
				kernel::log()->add_error($e);
			}
		}
		return null;
	}

	public function get_modelo(){
		$datos = array();
		$datos['accion'] = kernel::vinculador()->crear('acceso', 'index', array('auth' => 'form'));
		$datos['campos'] = array(
				"usuario" => array('name'=>"usuario", 'type'=>"text", 'value' => ''),
				"password" => array('name'=>"password", 'type'=>"password", 'value' => ''),
				"submit" => array('name'=>"login", 'type'=>"submit", 'value' => 'Ingresar')
			);
		
		$datos['usar_captcha'] = false; //se pisa si es post el usuario excede el limite

		if (kernel::request()->isPost()) {
			$usuario = kernel::request()->getPost('usuario');
			$datos['usar_captcha'] = $this->usar_captcha_login($usuario);
			if($this->error_login){
//				$this->vista()->pagelet('form')->data['mensajes']['error'] = $this->error_login->get_mensaje();
//				$this->vista()->pagelet('form')->data['mensajes']['url'] = array('url_olvide_pass' => $url_olvide_pass);
				$datos['error'] = $this->error_login->get_mensaje();
			}
		}
		return $datos;
	}

	protected function validar_user_pass($usuario, $password)
	{
		$id_persona = $this->get_clase_usuarios()->autenticar_usuario_clave($usuario, $password);
		intentos_login::eliminar($usuario);
		return $id_persona;
	}


	/**
	 * Cerrar sesion en el proveedor.
	 */
	public function logout()
	{
		//como es la misma sesion que el kernel no la toco.
		$parametros = array ( 'log_ingreso' => kernel::sesion()->get('log_ingreso') );
		if(!empty($parametros['log_ingreso']))
		{
			catalogo::consultar('persona', 'registrar_logout', $parametros);			
		}

	}


	/**************************************************************************/
	// RECAPTCHA
	/**************************************************************************/

	protected function check_recaptcha_login()
	{
		$rs = controlador::check_recaptcha2();
		if (! $rs) {
			throw new error_guarani_login(-4);
		}
	}

	protected function usar_captcha_login($identificador_usuario)
	{
		if (kernel::proyecto()->usa_captcha()) {
			return intentos_login::usar_recaptcha($identificador_usuario);
		}

		return false;
	}

	protected function controlar_captcha_login($identificador_usuario)
	{
		if (kernel::proyecto()->usa_captcha()) {
			return intentos_login::controlar_recaptcha($identificador_usuario);
		}

		return false;
	}


}