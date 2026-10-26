<?php

namespace siu\operaciones\_comun\pagelets;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use \siu\modelo\entidades\parametro;
use \siu\modelo\datos\catalogo;

class pagelet_notificaciones extends pagelet
{
	protected $notificaciones = array();
	
	function ini()
	{
		$this->add_mensaje_js('error_subcomision', kernel::traductor()->trans('notificaciones.errores.subcomision'));
	}
	
	protected function get_operacion_fisica()
    {
        return '_comun/pagelets';
    }
	
    function get_nombre()
    {
        return 'notificaciones';
    }

/*	protected function get_codigo_response()
	{
		if ($this->estado == 'materia_seleccionada_insc') {
			return 2;
		}
		
		return parent::get_codigo_response();
	}*/

	/**
	 * @todo:
	 * Los dos metodos que siguen hay que cambiarlos
	 * por una inyeccion de datos mas directa...
	 * se estan haciendo dos if iguales en dos lugares distintos
	 */

    function get_js_files()
    {
		$archivos = parent::get_js_files();
//		$archivos[] = kernel::vinculador()->vinculo_recurso("js/jquery_tools_min.js");
		$archivos[] = kernel::vinculador()->vinculo_recurso("js/notificaciones.js");
		return $archivos;
    }
    
    function get_css_files()
    {
		$archivos = parent::get_css_files();
//		$archivos[] = kernel::vinculador()->vinculo_recurso("css/coda-slider.css");
     
        return $archivos;
    }
    
	function agregar_notificacion($msg, $tipo)
	{
		$this->notificaciones[] = array(
			'tipo' => $tipo,
			'mensaje' => $msg
		);
	}
	
    function prepare()
    {
		// se limpia la memoria para borrar los viejos csrf keys
		$this->memoria()->limpiar();
		//echo "<pre>",print_r($asignaciones,true),"</pre>";
/*		$asig=array();
		foreach($data as $as) {
			$tmp=array();
			foreach($as as $k=>$v) {
				$tmp[] = "'$k': '$v'";
			}
			$asig[] = '{'.implode(', ',$tmp).'}';
		}
		$this->data['procesar'] = $asig?'true':'false';*/
		$this->data['banda_horaria_cursado'] = parametro::banda_horaria_cursado();
		$this->add_var_js('banda_horaria_cursado', $this->data['banda_horaria_cursado']);
		$data = \siu\guarani::persona()->cursadas()->info__asignaciones();
		$this->data['asignaciones'] = $data;

		
		$parametros_insc_examen = array();
		$parametros_insc_examen['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
		$parametros_insc_examen['estado'] = "T";
		$parametros_insc_examen['alcance'] = "A";

		$carrera = kernel::persona()->get_id_carrera_activa();
		$inscs = catalogo::consultar('alumno', 'inscripciones_examenes', $parametros_insc_examen);
		$inscs_por_carrera = array();
		
		foreach ($inscs as $insc) {
			if ($insc['carrera'] == $carrera) {
				$inscs_por_carrera[] = $insc;
			}
		}
		
		
		
		/*$data_inscripciones = \siu\guarani::persona()->examenes()->info__inscripciones();
		$this->data['info_examenes'] = $data_inscripciones;*/
		$this->data['info_examenes'] = $inscs_por_carrera;
		$this->add_var_js('asignaciones', $this->data['asignaciones']);
		
		$op_actual = kernel::ruteador()->get_id_operacion();
		$this->add_var_js('url_refresh', kernel::vinculador()->crear($op_actual, 'info_notificaciones'));
		$this->data['notificaciones'] = $this->notificaciones;
    }
}
?>
