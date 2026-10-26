<?php
namespace siu\operaciones\acceso;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\guarani;
use siu\modelo\entidades\parametro;

class pagelet_recuperar_pass extends pagelet
{
	const MAIL_ENVIADO		= 'mail_enviado';
	const MAIL_NO_EXISTENTE = 'mail_no_existente';
	const TOKEN_CORRECTO    = 'token_correcto';
	const TOKEN_INCORRECTO  = 'token_incorrecto';
	
	function ini()
	{
	}
	
	function get_nombre()
	{
		return 'recuperar_pass';
	}

	protected function obfuscate_mail($mail)
	{
		$aux = substr_replace($mail, '***', 2, strpos($mail, '@') - 2);
		$pos_punto = strpos($aux, '.', strpos($aux, '@'));
		$aux = substr_replace($aux, '***', $pos_punto);
		return $aux;
	}
	
	function prepare()
	{
		$this->add_mensaje_js('password_nuevo_error', ucfirst(kernel::traductor()->trans('configuracion.label.password_nuevo_error')));
		$this->add_mensaje_js('password_repetir_error', ucfirst(kernel::traductor()->trans('configuracion.label.password_repetir_error')));
		$this->add_mensaje_js('password_debil', ucfirst(kernel::traductor()->trans('configuracion.label.password_debil')));
		$this->add_mensaje_js('passwords_no_coinciden', ucfirst(kernel::traductor()->trans('configuracion.label.passwords_no_coinciden')));
		$this->add_var_js('pass_pattern', guarani::get_password_regexp_without_slashes());
		
		$minima_cantidad_caracteres_password = parametro::clave_longitud_minima();
		$info_clave_fuerte = kernel::traductor()->trans('info_clave_fuerte');
		$info_clave_fuerte = str_replace("%minima_cantidad_caracteres_password%", $minima_cantidad_caracteres_password, $info_clave_fuerte);
		$this->data['info_clave_fuerte'] = $info_clave_fuerte;
		
		switch ($this->estado) {
			// seleccioné una materia que no estoy inscripto
			case self::MAIL_ENVIADO: 
				$this->data['mail'] = $this->obfuscate_mail($this->controlador->get_var('mail'));
				break;
			case self::MAIL_NO_EXISTENTE: 
				$this->data['action_reset_pass'] = kernel::vinculador()->crear('acceso', 'reset_pass');
				break;
			case self::TOKEN_CORRECTO: 
				$this->data['token'] = $this->controlador->get_var('token');
				$this->data['errores'] = $this->controlador->get_var('errores');
				break;
			case self::TOKEN_INCORRECTO: 
				break;
			default:
				$this->data['mensajes'] = $this->controlador->get_var('mensajes');
				$this->data['paises'] = catalogo::consultar('etiquetas', 'paises'); 
				$this->data['tipos_doc'] = catalogo::consultar('etiquetas', 'tipos_documento'); 
				$this->data['documento'] = $this->controlador->get_var('documento');
				$this->data['action_recuperar'] = kernel::vinculador()->crear('acceso', 'recuperar');
		}
	}
}
?>