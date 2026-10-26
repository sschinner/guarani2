<?php
namespace siu\operaciones\cursada;

use kernel\kernel;
use kernel\util\mail;
use siu\guarani;
use siu\extension_kernel\controlador_errores_control;
use kernel\util\validador;
use siu\operaciones\cursada\generador_comprobantes_cursada;
use \siu\errores\error_guarani_control;

class controlador extends controlador_errores_control
{
	protected $id_cert_baja;
	/* nuevo */
	protected $id_cert_alta;
	/* */
	/**
	 *
	 * @var generador_comprobantes_cursada
	 */
	protected $generador_comp;

	/**
	 * @return \siu\modelo\transacciones\inscripcion_cursada
	 */
	function modelo()
	{
		return guarani::cursada();
	}

	function ini()
	{
		$this->generador_comp = kernel::localizador()->instanciar('operaciones\cursada\generador_comprobantes_cursada');
		$this->controlar_csrf_accion('inscribir');
		$this->controlar_csrf_accion('baja');
		$this->controlar_csrf_accion('baja_inicial');
	}

	
	function accion__index()
	{
		$hubo_error = $this->exec_fn_modelo('control__inicial', array());
		$this->vista()->set_hay_mensajes($this->hay_mensajes());

		$this->vista()->set_error($hubo_error);		
	}

	function accion__elegir_materia()
	{
		$materia  = $this->validate_param(0, 'get', validador::TIPO_ALPHANUM);
		$pagelet = $this->vista()->pagelet('info_materia');

		$this->elegir_materia($materia);

		$this->add_var('materia', $materia);
		kernel::renderer()->add($pagelet);
	}

	function accion__inscribir()
	{
		$materia  = $this->validate_param('materia', 'post', validador::TIPO_TEXTO);
		$comision = $this->validate_param('comision', 'post', validador::TIPO_ALPHANUM);
		$subcomisiones = $this->get_param('subcomisiones', 'post', 'string_array');

		$hubo_error = $this->exec_fn_modelo('evt__inscripcion', array($materia, $comision, $subcomisiones));
		if ($hubo_error) {
			// Se genera un nuevo csrf xq el anterior ya se consumió
			kernel::renderer()->add_csrf($this->generar_csrf());
			// esta llamada finaliza el request
			$this->finalizar_request_con_notificaciones(kernel::traductor()->trans('error_insc_cursada'), $this->get_var('mensajes'));
		}

		$this->add_var('materia', $materia);
		$this->elegir_materia($materia);

		/* nuevo */ 
		$this->guardar_id_cert_alta($materia, $comision);
		/* */

		kernel::renderer()->add($this->vista()->pagelet('info_materia'));
	}

	function accion__baja()
	{
		$materia  = $this->validate_param('materia',  'post', validador::TIPO_TEXTO, array('allowempty' => true));
		$comision = $this->validate_param('comision', 'post', validador::TIPO_ALPHANUM);

		$hubo_error = $this->exec_fn_modelo('evt__eliminar_inscripcion', array($materia, $comision));

		if ($hubo_error) {
			kernel::renderer()->add_csrf($this->generar_csrf());
			$this->finalizar_request_con_notificaciones(kernel::traductor()->trans('error_baja_cursada'), $this->get_var('mensajes'));
		}

		$this->guardar_id_cert_baja($comision, $this->id_cert_baja);
		$this->add_pagelet_vars($materia, $comision);
		$this->elegir_materia($materia);
		$pagelet = $this->vista()->pagelet('info_materia');
		kernel::renderer()->add($pagelet);
	}

	/**
		* Acción baja que se ejecuta desde el estado inicial del pagelet 
		*/
	function accion__baja_inicial()
	{
		$comision = $this->validate_param('comision', 'post', validador::TIPO_ALPHANUM);
		// Se llama a un método especial en esta baja porque puede ser que se
		// esté dando de baja una materia con el período de alta cerrado (no aparece
		// en la lista de la izquierda). Se hace sólo en este lugar ya que este
		// es el único que lista TODAS las materias en las que se puede dar de baja
		$hubo_error = $this->exec_fn_modelo('evt__eliminar_inscripcion_periodo_alta_cerrado', $comision);

		if ($hubo_error) {
			kernel::renderer()->add_csrf($this->generar_csrf());
			$this->finalizar_request_con_notificaciones(kernel::traductor()->trans('error_baja_cursada'), $this->get_var('mensajes'));
		}
		$this->guardar_id_cert_baja($comision, $this->id_cert_baja);
		kernel::renderer()->add($this->vista()->pagelet('info_materia'));
	}

	function accion__info_notificaciones()
	{
		$data = guarani::persona()->cursadas()->info__asignaciones();
		$this->render_raw_json($data);
	}

	function accion__enviar_comprobante()
	{
		$dir_mail = kernel::persona()->get_mail();
		if (empty($dir_mail)) {
			$this->finalizar_request();
		}
		$url_materia = $this->validate_param('materia', 'get', validador::TIPO_TEXTO);
		$url_transaccion = $this->validate_param('transaccion', 'get', validador::TIPO_ALPHANUM);
		$datos = $this->modelo()->info__comprobante($url_materia, $url_transaccion);
		
		$asunto = kernel::traductor()->trans('asunto_mail_alta_certificado_cursada', array(
			'%1%' => $datos['FECHA_INSCRIPCION'],
			'%2%' => $datos['NOMBRE_MATERIA']
		));
		$tpl = kernel::load_template('info_materia/mail_alta_certificado.twig');
		$cuerpo = $tpl->render(array());
		$path_archivo = kernel::proyecto()->get_dir_temp().'/'.  uniqid().'.png';
		$this->generador_comp->set_tipo_generacion(generador_comprobantes_cursada::TIPO_GENERACION_ARCHIVO);
		$this->generador_comp->set_path_destino($path_archivo);
		$this->generador_comp->generar_comp_alta($datos);
		$mail = new mail($dir_mail, $asunto, $cuerpo);
		$mail->agregar_adjunto('comprobante.png', $path_archivo);
		$mail->set_html(true);

		$mail->enviar();
        //Una vez enviado el email elimino el comprobante.
        unlink($path_archivo);
		$this->render_ajax();
	}

	function accion__generar_comprobante()
	{
		$url_materia = $this->validate_param('materia', 'get', validador::TIPO_TEXTO);
		$url_transaccion = $this->validate_param('transaccion', 'get', validador::TIPO_ALPHANUM);
                $mis_inscripciones = $this->validate_param('mis_inscripciones', 'get', validador::TIPO_INT, array('allowempty' => true));
                $historico = $this->validate_param('historico', 'get', validador::TIPO_INT, array('allowempty' => true));
		$imprimir = $this->validate_param('i', 'get', validador::TIPO_INT, array('allowempty' => true,'default' => 0));
                ob_clean();
		if ($imprimir == 1) {
			$this->generador_comp->set_tipo_generacion(generador_comprobantes_cursada::TIPO_GENERACION_STREAM);
		} else {
			$this->generador_comp->set_tipo_generacion(generador_comprobantes_cursada::TIPO_GENERACION_DESCARGA);
		}
                
                if ($historico){
                    $datos = $this->modelo()->info__comprobante_historico($url_transaccion);
                }
                else{
                    $datos = $this->modelo()->info__comprobante($url_materia, $url_transaccion, $mis_inscripciones);
                }
		
		// se trunca el nombre de la sede
		$largo = 40;
		$datos['NOMBRE_SEDE'] = (strlen($datos['NOMBRE_SEDE']) > $largo) ? substr($datos['NOMBRE_SEDE'], 0, $largo)."..." : $datos['NOMBRE_SEDE'];
		
		$this->generador_comp->generar_comp_alta($datos);
		$this->finalizar_request();
	}

	function accion__comprobante_baja()
	{
		$url_comision = $this->validate_param('baja', 'get', validador::TIPO_ALPHANUM);
		$datos = $this->modelo()->info__comprobante_baja($url_comision);
		$this->generador_comp->set_tipo_generacion(generador_comprobantes_cursada::TIPO_GENERACION_DESCARGA);
		
		// se trunca el nombre de la sede
		$largo = 40;
		$datos['NOMBRE_SEDE'] = (strlen($datos['NOMBRE_SEDE']) > $largo) ? substr($datos['NOMBRE_SEDE'], 0, $largo)."..." : $datos['NOMBRE_SEDE'];
		
		$this->generador_comp->generar_comp_baja($datos);
		$this->finalizar_request();
	}
    
	protected function elegir_materia($materia)
	{
		$pagelet = $this->vista()->pagelet('info_materia');

		if (\siu\modelo\entidades\parametro::filtrar_inscripciones_por_carrera() == 'S') {
			if (! $this->modelo()->info__hay_periodo_inscripcion_vigente()) {
				throw new \siu\errores\error_guarani_usuario(
						kernel::traductor()->trans('param_error.filtrar_inscripciones_por_carrera'));
			}
		}

		$hubo_error = $this->exec_fn_modelo('control__seleccion_materia', $materia);
		
		if ($hubo_error) {
			$pagelet->set_estado_info(pagelet_info_materia::ERROR_MATERIA_SELECCIONADA);
		} else {
			$pagelet->set_estado_info(pagelet_info_materia::MATERIA_SELECCIONADA);
		}
	}

	protected function add_pagelet_vars($materia, $comision)
	{
		$this->add_var('materia', $materia);
		$this->add_var('comision', $comision);
	}

	/**************************************************************************/
	// FUNCIONES DE ACCESO AL MODELO
	/**************************************************************************/
	protected function modelo__control__inicial()
	{
		$mensajes = $this->modelo()->control__inicial();
		
		$this->acum_mensajes($mensajes);
	}

	protected function modelo__control__seleccion_materia($materia)
	{
		$mensajes = $this->modelo()->control__seleccion_materia($materia);
		$this->acum_mensajes($mensajes);
	}
	
	protected function modelo__evt__inscripcion($materia, $comision, $subcomisiones)
	{
		list($mensajes, $transaccion) = $this->modelo()->evt__inscripcion($materia, $comision, $subcomisiones);
		$this->add_var('transaccion', $transaccion);
		/* nuevo */
		$this->id_cert_alta = $transaccion;
		/**/
		$this->acum_mensajes($mensajes);
	}

	protected function modelo__evt__eliminar_inscripcion($materia, $comision)
	{
		list($mensajes, $transaccion) = $this->modelo()->evt__eliminar_inscripcion($materia, $comision);
		$this->acum_mensajes($mensajes);
		// @todo: borrar. Esto es un hack para meter el certificado de baja
		// provisionalmente.
		$this->id_cert_baja = $transaccion;
	}

	protected function modelo__evt__eliminar_inscripcion_periodo_alta_cerrado($comision)
	{
		list($mensajes, $transaccion) = $this->modelo()->evt__eliminar_inscripcion_periodo_alta_cerrado($comision);
		$this->acum_mensajes($mensajes);
		// @todo: borrar. Esto es un hack para meter el certificado de baja
		// provisionalmente.
		$this->id_cert_baja = $transaccion;
	}

	protected function guardar_id_cert_baja($key, $value)
	{
		kernel::sesion()->set("id_cert_baja_$key", $value);
		$mensaje = kernel::traductor()->trans('mensaje_baja_comprobante', array(
			'%1%' => kernel::vinculador()->crear('cursada', 'comprobante_baja', array(
				'baja' => $key
			))
		));
		kernel::renderer()->add_to_ajax_response('mensaje_cert_baja', $mensaje);
	}

	protected function guardar_id_cert_alta($key, $value)
	{
		kernel::sesion()->set("id_cert_alta_$key", $value);

		$info = $this->modelo()->info__inscripcion($key,$value);
		$url_transaccion = $info['URL_NRO_TRANSACCION'];
		$estado = substr($info['ESTADO_INSCRIPCION'],0,1);
		if ($estado == 'A')
		{
			$mensaje = kernel::traductor()->trans('mensaje_alta_comprobante', array(
				'%1%' => kernel::vinculador()->crear('cursada', 'generar_comprobante', array(
					'materia' => $key,
					'transaccion' => $url_transaccion
				))
			));			
		} 
		if ($estado == 'P')
		{
			$mensaje = kernel::traductor()->trans('mensaje_alta_comprobante_pendiente', array(
				'%1%' => kernel::vinculador()->crear('cursada', 'generar_comprobante', array(
					'materia' => $key,
					'transaccion' => $url_transaccion
				))
			));			
		}

		kernel::renderer()->add_to_ajax_response('mensaje_cert_alta', $mensaje);
	}
}