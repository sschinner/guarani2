<?php

namespace siu\extension_kernel;

use kernel\kernel;
use siu\guarani;
use siu\errores\error_guarani;
use siu\errores\error_guarani_usuario;
use siu\errores\error_guarani_control;
use siu\extension_kernel\controlador_g3w2;
use siu\operaciones\reinscripcion\controlador as controlador_reinscripcion;
use \siu\modelo\guarani_notificacion;

abstract class controlador_errores_control extends controlador_g3w2
{
	/**
	 * Ejecuta una función del controlador que impacta el modelo. Estas funciones
	 * se llaman modelo__*.
	 * Como efecto colateral si hay error deja los mensajes en $this->mensajes
	 * @param string $nombre el nombre de la función a ejecutar
	 * @param mixed $params 
	 * @param boolean $forzar_error_control para hacer debugging
	 * @param boolean $forzar_error_guarani para hacer debugging
	 * @return boolean si hubo o no error
	 */
	protected function exec_fn_modelo($nombre, $params = array(), $forzar_error_control = false)
	{
		$hubo_error = false;
		$nombre_fn = "modelo__$nombre";
		$mensajes = array();
		$params = (is_array($params)) ? $params : array($params);
		
		try {
			call_user_func_array(array($this, $nombre_fn), $params);
		} catch (error_guarani_control $error_control) { // error en controles
			$hubo_error = true;
			$mensajes = $error_control->get_mensajes();
			if ($error_control->requiere_reinscripcion()) {
				controlador_reinscripcion::activar_modo_reinscripcion(kernel::ruteador()->get_id_operacion());
			}

		} catch (error_guarani_usuario $e) { // error en la inscripción
			$hubo_error = true;
			$mensajes[] = new guarani_notificacion(guarani_notificacion::error, $e->get_mensaje());
			kernel::log()->add_error($e);
		} catch (error_guarani $e) {
			$hubo_error = true;
			$mensajes[] = new guarani_notificacion(guarani_notificacion::error, trans($e->get_id_error_generico()));
			
			kernel::log()->add_error($e);
		}
		
		kernel::log()->add_debug("Resultado ejecucion fn modelo '$nombre'", $hubo_error? "error" : "ok");
		
		$this->acum_mensajes($mensajes);
		return $hubo_error;
	}
	
	/**
	 * Acumula mensajes en var mensajes en vez de pisarlos. $this->get_var('mensajes')
	 * @param type $mensajes
	 */
	protected function acum_mensajes($mensajes)
	{
		$this->agregar_link_datos_censales_y_reinscripcion($mensajes);
		if ($this->hay_var('mensajes')) {
			$mensajes = array_merge($this->get_var('mensajes'), $mensajes);
		}
		$this->add_var('mensajes', $mensajes);
	}
	
	protected function mens($v){
        return array(
            array(
				guarani::mensaje_cuerpo  => '[E]'.$v,
				guarani::mensaje_tipo	 => guarani::control_error
			),
            array(
				guarani::mensaje_cuerpo  => '[W]'.$v,
				guarani::mensaje_tipo	 => guarani::control_advertencia
			),
            array(
				guarani::mensaje_cuerpo  => '[I]'.$v,
				guarani::mensaje_tipo	 => guarani::control_info
			),
        );
    }
	
	
	protected function agregar_link_datos_censales_y_reinscripcion($mensajes)
	{
		/* @var $notificacion guarani_notificacion */
		foreach ($mensajes as $notificacion) {
			if (!$notificacion->es_de_datos_censales() && !$notificacion->es_de_reinscripcion()) {
				continue;
			}
			
			if ($notificacion->es_de_reinscripcion()) {
				$link = trans('falta_reinscripcion', array(
					'%1%' => kernel::vinculador()->crear('reinscripcion')
				));
			} else if ($notificacion->es_de_datos_censales()) {
				$link = trans('falta_datos_censales', array(
					'%1%' => kernel::vinculador()->crear('censo')
				));	
			}
			
			$notificacion->set_tiene_links(true);
			$notificacion->set_mensaje($notificacion->get_mensaje().'. '.$link);
		}
	}
	
	function get_mensajes()
	{
		return $this->get_var('mensajes');
	}
	
	protected function hay_mensajes()
	{
		$mensajes = $this->get_var('mensajes');
		return ! empty($mensajes);
	}
}

?>
