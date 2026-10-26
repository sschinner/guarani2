<?php
namespace siu\operaciones\tesis;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\guarani;
use siu\modelo\datos\catalogo;

class pagelet_reporte extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {
	protected $datos_consulta;
	protected $pdf_hoja_orientacion = "landscape";
	
	public function get_nombre(){
        return 'reporte';
    }

	function configurar(){
		$this->set_rpp(5);
		$this->set_columnas_reporte($this->get_columnas());
		$this->set_pdf_hoja("a4", "landscape");
		//$this->agregar_corte(1, 'Titulo de la columna {{columna}}: {{valor}}');
		
		// Setea metodos que se ejecutan al final de cada corte. Con el subconjunto de datos del corte
		//$this->agregar_funcion_pie_corte('nombre_funcion', array(array(0, 10), 'Titulo: ', 1));
		//$this->agregar_mensaje_pie_corte('nombre_funcion_pie');

		// Setea metodos que se ejecutan al final del reporte.
		//$this->agregar_funcion_pie_reporte('nombre_funcion_pie_reporte', array(array(0, 10), 'Titulo: ', 1));
		//$this->agregar_mensaje_pie_reporte('nombre_funcion_pie_reporte');
		$this->membrete(kernel::traductor()->trans('header.menu.tesis'));
		$this->set_titulo_reporte(kernel::traductor()->trans('header.menu.tesis'));
		$this->set_tiene_encabezado(true);
		$alumno = guarani::persona()->get_nombre();
		$this->set_encabezado_reporte(PHP_EOL.'Alumno: '.$alumno);
		
		$encabezado_excel = array();
		$encabezado_excel['alumno'] = 'Alumno: '.$alumno;
		$this->set_encabezado_reporte_excel($encabezado_excel);
	}
	
	public function get_columnas(){
		$titulo = array();
		$titulo['titulo'] = array('Título de la tesis', array('width' => 120));
		$titulo['carrera'] = array('Carrera', array('width' => 120));
		//$titulo['titulo'] = 'Título de la tesis';
		//$titulo['carrera'] = 'Carrera';
		$titulo['legajo'] = 'Legajo';
		$titulo['fecha_alta'] = 'Fecha de alta';
		$titulo['fecha_vencimiento'] = 'Fecha de vencimiento';
		$titulo['fecha_aprobacion'] = 'Fecha de aprobación';
		$titulo['estado'] = 'Estado';
		
		return $titulo;
	}
	
	/**
	 * Recupera los datos
	 * @param entero $pagina
	 * Numero de página que se desea recuperar
	 * @param buleano $todo
	 * Recuperar todos los datos
	 * @return array 
	 */
	public function get_data_reporte($pagina = 0, $todo = false){	
		$reg_por_pagina = $this->get_rpp();
		$pagina = $this->get_pagina();

		$minimo = ($pagina - 1) * $reg_por_pagina;
		$maximo = $minimo + $reg_por_pagina;

		$datos = $this->get_data();
		
		$nuevo = array();
		$i=0;
		foreach($datos as $id => $dato) {
			if ($todo or ($i <= $reg_por_pagina && $id >= $minimo && $id < $maximo)){
				$nuevo[$i] = $dato;
				$i++;
			}
		}
		return $nuevo;
	}

	protected function get_data(){
		if (!isset($this->datos_consulta)) {
			$parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
			$this->datos_consulta = catalogo::consultar('alumno', 'tesis', $parametros);
		}
		return $this->datos_consulta;
	}
	
	/**
	 * Retorna la cantidad de datos
	 * @return entero
	 */
	protected function get_total_registros(){
		 return count($this->get_data_reporte(0, true));
	}
	
	public function get_nombre_archivo(){
		return "tesis";
	}

	protected function get_generador_pdf()
	{
		//require_once(realpath(guarani::dir()."/operaciones/tesis/generador_pdf.php"));
		return new generador_pdf($this->crear_ezpdf($this->pdf_hoja_orientacion));
	}
	
	protected function get_generador_excel()
	{
		//require_once(realpath(guarani::dir()."/operaciones/tesis/generador_excel.php"));
		return new generador_excel();
	}
}
?>