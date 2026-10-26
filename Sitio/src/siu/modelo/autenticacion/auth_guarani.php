<?php

namespace siu\modelo\autenticacion;

use kernel\acceso\authentication_provider;
use kernel\kernel;
use kernel\util\intentos_login;
use siu\errores\error_guarani;
use siu\errores\error_guarani_login;
use siu\guarani;
use siu\modelo\entidades\parametro;

abstract class auth_guarani extends authentication_provider {

	protected $fuente_usuarios;

	protected function get_clase_usuarios()
	{
		if(!isset($this->fuente_usuarios)){
			$clase = kernel::proyecto()->get_fuente_usuarios();
			if(!isset($clase)) {
				throw new error_guarani('Autenticacion: no se seteo el parámetro "fuente_usuarios" en la configuracion.');
			}
			$this->fuente_usuarios = kernel::localizador()->instanciar($clase);
		}
		return $this->fuente_usuarios;
	}

	/**
	 * El kernel instancia la clase de persona. Se pasa a esta clase para realizar configuraciones necesarias, como
	 * la carga de perfiles. Puede ser que no esté autenticada (persona anonima)
	 * @param $persona
	 * @param $autenticada
	 */
	public function evt_persona_instanciada($persona, $autenticada)
	{
		if(parametro::registrar_log_ingresos()){
			$this->get_clase_usuarios()->registrar_login($this);
		}
	}

}