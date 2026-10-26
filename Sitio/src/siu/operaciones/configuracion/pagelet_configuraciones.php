<?php
namespace siu\operaciones\configuracion;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\guarani;
use siu\modelo\entidades\parametro;

class pagelet_configuraciones extends pagelet
{
	function ini()
	{
	}
	
	function get_nombre()
	{
		return 'configuraciones';
	}

	function prepare()
	{
		
		$minima_cantidad_caracteres_password = parametro::clave_longitud_minima();
		$info_clave_fuerte = kernel::traductor()->trans('info_clave_fuerte');
		$info_clave_fuerte = str_replace("%minima_cantidad_caracteres_password%", $minima_cantidad_caracteres_password, $info_clave_fuerte);
		$this->data['info_clave_fuerte'] = $info_clave_fuerte;
		
		$this->data['csrf']	= $this->generar_csrf();
		$this->data['persona'] = $this->datos_persona();
		
		switch(guarani::persona()->get_id_perfil_activo()){
			case "DOC":
				$operacion = 'censo_docente';
				break;
			case "ALU":
				$operacion = 'censo';
				break;
		} 
		if (isset($operacion)){
			$this->data['url_datos_censales'] = kernel::vinculador()->crear($operacion);	
		}
		$this->data['checks'] = guarani::persona()->get_configuracion();
		$mail_token = guarani::persona()->get_mail_from_token(false, guarani::persona()->get_nro_inscripcion());
		if(isset($mail_token) && $mail_token) {
			$this->add_var_js('mail_token', $mail_token);
		}
		//kernel::log()->add_debug('datos_con');
		$operacion = kernel::ruteador()->get_id_operacion();        
		$this->data['url_guardar'] = kernel::vinculador()->crear($operacion, 'guardar');
		$this->data['es_alumno'] = kernel::persona()->perfil()->es('ALU');
		$this->data['perfil'] = kernel::persona()->get_id_perfil_activo();
		

		$this->add_mensaje_js('password_actual_error', ucfirst(kernel::traductor()->trans('configuracion.label.password_actual_error')));
		$this->add_mensaje_js('password_nuevo_error', ucfirst(kernel::traductor()->trans('configuracion.label.password_nuevo_error')));
		$this->add_mensaje_js('password_repetir_error', ucfirst(kernel::traductor()->trans('configuracion.label.password_repetir_error')));
		$this->add_mensaje_js('password_debil', ucfirst(kernel::traductor()->trans('configuracion.label.password_debil')));
		$this->add_mensaje_js('passwords_no_coinciden', ucfirst(kernel::traductor()->trans('configuracion.label.passwords_no_coinciden')));
		$this->add_mensaje_js('mail_token_cambio', kernel::traductor()->trans('configuracion.mensaje.mail_token.cambio'));
		//$this->add_mensaje_js('mail_token_cancel', kernel::traductor()->trans('configuracion.mensaje.mail_token.cancel'));
		$this->add_mensaje_js('mail_no_concuerda', kernel::traductor()->trans('configuracion.mensaje.mail_no_concuerda'));
		$this->add_mensaje_js('revincular_singular', kernel::traductor()->trans('configuracion.mensaje.revincular.singular'));
		$this->add_mensaje_js('revincular_plural', kernel::traductor()->trans('configuracion.mensaje.revincular.plural'));
		$this->add_mensaje_js('aceptar', kernel::traductor()->trans('aceptar'));
		$this->add_mensaje_js('cancelar', kernel::traductor()->trans('configuracion.mensaje.cancelar_solicitud'));
		$this->add_mensaje_js('revertir', kernel::traductor()->trans('revertir'));
		$this->add_var_js('url_eliminar_token', kernel::vinculador()->crear($operacion, 'eliminar_token'));
		$this->add_var_js('pass_pattern', guarani::get_password_regexp_without_slashes());
		
	}
	
	function datos_persona()
	{
		$datos = array();
		$datos_censales = guarani::datos_censales()->get_datos_censales();
		
		$datos['calle'] = $datos_censales['CENS_CALLE_PER_LECT'];
		$datos['numero'] = $datos_censales['CENS_NUMERO_PER_LECT'];
		$datos['piso'] = $datos_censales['CENS_PISO_PER_LECT'];
		$datos['dpto'] = $datos_censales['CENS_DPTO_PER_LECT'];
		$datos['unidad'] = $datos_censales['CENS_UNIDAD_PER_LECT'];
		$datos['localidad'] = $datos_censales['CENS_LOC_PER_LECT'];
		$datos['cp'] = $datos_censales['CENS_CP_PER_LECT'];
		$datos['nombre'] = $datos['nombre'] = guarani::persona()->get_nombre();
		$datos['usuario'] = guarani::persona()->get_identificacion();

		return $datos;
	}
}
?>