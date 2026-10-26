<?php

namespace kernel\acceso;

use kernel\kernel;
use kernel\nucleo\sesion;

/**
 * Ejemplo de como se usa con relacion a la sesion
 * @package kernel\acceso
 */
abstract class auth_con_sesion extends authentication_provider {

	protected $session;

	function __construct($id, $conf)
	{
		parent::__construct($id, $conf);
		$this->session = kernel::sesion();
	}


	public function esta_logueado(){
		if ($this->session->abierta()) {
			if ($this->excede_maxtime() || $this->excede_timeout()) {
				return false;
			}
			return true;
		}
		return false;
	}

	/**
	 * Se invoca luego de abrir sesion en el kernel (luego de una autenticacion exitosa)
	 */
	public function evt_sesion_abierta()
	{
		$this->session->set('__kernel_ses_start', time());
		$this->session->set('__kernel_ses_last_request', time());
//		if (esta el checkbox) {
//			session_set_cookie_params(86400*30);
//		}
	}

	public function evt_nuevo_request()
	{
		$this->session->set('__kernel_ses_last_request', time());
	}

	public function evt_persona_instanciada($persona, $autenticada)
	{

	}

	protected function excede_maxtime()
	{
		$maxtime = kernel::proyecto()->get('sesion_maxtime') * 60;
		$hora_entrada = $this->session->get('__kernel_ses_start');

		return (time() - $hora_entrada) > $maxtime;
	}

	protected function excede_timeout()
	{
		$timeout = kernel::proyecto()->get('sesion_timeout') * 60;
		$hora_ultimo_request = $this->session->get('__kernel_ses_last_request');

		return (time() - $hora_ultimo_request) > $timeout;
	}

}