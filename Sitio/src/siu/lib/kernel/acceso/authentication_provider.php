<?php

namespace kernel\acceso;


abstract class authentication_provider {


	protected $id;
	protected $conf;

	function __construct($id, $conf)
	{
		$this->id = $id;
		$this->conf = $conf;
	}


	/**
	 * Un string para referenciar al tipo de autenticacion y su configracion
	 * @return string
	 */
	public function get_id(){

		return $this->id;
	}

	/**
	 * Retorna el arreglo 'parametros' del archivo de configuración.
	 * @return array
	 */
	public function get_parametros(){

		return $this->conf;
	}

	/**
	 * Autentica en base al request y
 	 * Retrona el id de la persona en la tabla de usuarios
	 * @return integer
	 */
	public abstract function autenticar();

	/**
	 * Determina si el usuario está logueado. Puede leer cosas de sesion, o un token externo (saml).
	 * @return boolean
	 */
	public abstract function esta_logueado();

	/**
	 * Se invoca luego de cerrar sesion en el kernel.
	 */
	public abstract function logout();


	/**
	 * Retorna un arreglo con datos necesarios para renderizar este tipo de autenticacion. Queda a cargo del cliente
	 * la visualizacion
	 * @return array
	 */
	public abstract function get_modelo();

	/**
	 * Se invoca luego de abrir sesion en el kernel (luego de una autenticacion exitosa)
	 */
	public abstract function evt_sesion_abierta();

	/**
	 * El kernel instancia la clase de persona. Se pasa a esta clase para realizar configuraciones necesarias, como
	 * la carga de perfiles. Puede ser que no esté autenticada (persona anonima)
	 * @param $persona
	 * @param $autenticada
	 * @return
	 */
	public abstract function evt_persona_instanciada($persona, $autenticada);

	/**
	 * Se invoca cada request en el cual existe una sesiòn abierta (para actualizar maxtimes, estadisticas, etc). No se
	 * llama si la sesion se abre este request.
	 */
	public abstract function evt_nuevo_request();
}