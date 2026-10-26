<?php
namespace siu\operaciones\acceso;

use kernel\acceso\authentication_provider;
use kernel\interfaz\pagelet;
use kernel\kernel;


class pagelet_login extends pagelet
{
	function ini()
	{
	}
	
	function get_nombre()
	{
		return 'login';
	}

	function prepare()
	{
		$this->data['url_recuperar'] = kernel::vinculador()->crear('acceso', 'recuperar'); //este queda en esta accion?
		$this->data['url_olvide_pass'] = kernel::vinculador()->crear('acceso', 'olvide_pass');

		$lm = kernel::login_manager();

		$modelo = array();
		foreach ($lm->get_auth_providers() as $auth){
			/** @var $auth authentication_provider */
			$modelo[$auth->get_id()] = $auth->get_modelo();
		}
		$this->data['providers'] = $modelo;

        $this->add_mensaje_js('id_requerido', kernel::traductor()->trans('login.errores.id_requerido'));
        $this->add_mensaje_js('clave_requerida', kernel::traductor()->trans('login.errores.clave_requerida'));
	}
}
?>