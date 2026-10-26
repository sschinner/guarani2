<?php
namespace siu\operaciones\mensajes;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\guarani;
use \siu\modelo\datos\catalogo;

class pagelet_envio_mensajes extends pagelet
{
	var $mensaje = "";

	function ini()
	{
	}
	
	function get_nombre()
	{
		return 'envio_mensajes';
	}
	
	function modelo()
	{
		return $this->controlador->modelo();
	}
		
	function set_resultado($mensaje)
	{	
		$this->mensaje = $mensaje;
	}

	function prepare()
	{
		$mesas_y_comisiones = $this->modelo()->get_mesas_y_comisiones();
		$this->data['mesas'] = array();		
		if (isset($mesas_y_comisiones['mesas'])) {
			$this->data['mesas'] = $mesas_y_comisiones['mesas'];
		}
		
		$this->data['comisiones'] = array();
		if (isset($mesas_y_comisiones['comisiones'])) {
			$this->data['comisiones'] = $mesas_y_comisiones['comisiones'];
		}
		
		if (empty($mesas_y_comisiones)) {
				$this->data['deshabilitado'] = true;
		} else {
				$this->data['deshabilitado'] = false;
		}
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->data['url_envio'] = kernel::vinculador()->crear($operacion, 'enviar_mensaje');
		$this->data['url_enviados'] = kernel::vinculador()->crear($operacion, 'enviados');
		$this->data['url_recibidos'] = kernel::vinculador()->crear($operacion);
		$this->data['mensaje'] = $this->mensaje;
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->add_var_js('url', kernel::vinculador()->crear($operacion, 'leer_mensaje'));
		$this->data['es_docente'] = kernel::persona()->perfil()->es('DOC');
		
		/**/
		$fecha_actual = catalogo::consultar('sistema', 'fecha_actual');
		$default_fecha_desde = date("d/m/Y", strtotime($fecha_actual[0]));
		$default_fecha_hasta = date("d/m/Y", strtotime($fecha_actual[0] . " +7 day"));
		
		$this->add_var_js('default_fecha_desde', $default_fecha_desde);
		$this->add_var_js('default_fecha_hasta', $default_fecha_hasta);
		$this->data['default_fecha_desde'] = $default_fecha_desde;
		$this->data['default_fecha_hasta'] = $default_fecha_hasta;
		
		$this->data['mensaje_guardado'] = $this->controlador->get_var('mensaje_guardado');
		if ($this->controlador->hay_var('comision')) {
			$this->add_var_js('comision', $this->controlador->get_var('comision'));
		}
	}
}
?>