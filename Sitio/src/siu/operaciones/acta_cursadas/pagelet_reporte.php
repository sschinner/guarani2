<?php
namespace siu\operaciones\acta_cursadas;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\guarani;

class pagelet_reporte extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {
	protected $datos_consulta;
	private $filtros = array('anio_academico' => '', 'periodo_lectivo' => '','nombre' => '');

	public function get_nombre(){
		return 'reporte';
	}

	function configurar(){
		$this->set_rpp(15);
		$this->set_columnas_reporte($this->get_columnas());

		// Configuracion pdf
		$this->membrete(kernel::traductor()->trans('actas_regulares'));
		$this->set_pdf_hoja("a4", 'landscape');
		$this->set_tiene_encabezado(true);
		$this->set_titulo_reporte(kernel::traductor()->trans('actas_regulares'));

		$doc = guarani::persona()->get_nombre();
		$this->set_encabezado_reporte(PHP_EOL.'Docente: '.$doc);
		
		$encabezado_excel = array();
		$encabezado_excel['docente'] = 'Docente: '.$doc;
		$this->set_encabezado_reporte_excel($encabezado_excel);	
		
		$this->data['url_form_filtro'] = kernel::vinculador()->crear('acta_cursadas', 'filtrar');
		$this->data['titulos'] =$this->get_columnas_vista();
	}

	public function get_columnas(){
		$titulos = array();
		$titulos['ACTA'] = "Acta";
		$titulos['NOMBRE_MATERIA'] = "Materia";
		$titulos['ANIO_ACADEMICO'] = "Año";
		$titulos['PERIODO_LECTIVO'] = "Período Lectivo";
		$titulos['SEDE'] = "Sede";
		$titulos['ESTADO_ACTA'] = "Estado";
		$titulos['FECHA_CIERRE'] = "Fecha cierre";

		return $titulos;
	}

	public function get_columnas_vista(){
		$titulos = array();
		$titulos['ACTA'] = "Acta";
		$titulos['NOMBRE_MATERIA'] = "Materia";
		$titulos['ANIO_ACADEMICO'] = "Año";
		$titulos['PERIODO_LECTIVO'] = "Período Lectivo";
		$titulos['SEDE'] = "Sede";
		$titulos['ESTADO_ACTA'] = "Estado";
		$titulos['FECHA_CIERRE'] = "Fecha cierre";
		$titulos['ACCIONES'] = "";

		return $titulos;
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
		$i=0;
		$reg_por_pagina = $this->get_rpp();
		$pagina = $this->get_pagina();

		$minimo = ($pagina - 1) * $reg_por_pagina;
		$maximo = $minimo + $reg_por_pagina;

		$operacion = kernel::ruteador()->get_id_operacion();
		$datos = $this->get_data();

		$nuevo = array();
		foreach($datos as $id => $dato) {
			$linea = array();
			if ($todo or ($i <= $reg_por_pagina && $id >= $minimo && $id < $maximo)){
				$linea['ACTA'] = $dato['ACTA'];
				$linea['URL_LINEA'] = kernel::vinculador()->crear($operacion, 'info_acta', array('accion'=>$dato['URL_ACTA']));
				$linea['NOMBRE_MATERIA'] = $dato['NOMBRE_MATERIA']." (".$dato['MATERIA'].")";
				$linea['ANIO_ACADEMICO'] = $dato['ANIO_ACADEMICO'];
				$linea['PERIODO_LECTIVO'] = $dato['PERIODO_LECTIVO'];
				$linea['SEDE'] = $dato['NOMBRE_SEDE'];
				$linea['ESTADO_ACTA'] = $dato['ESTADO_ACTA'];
				$linea['FECHA_CIERRE'] = $dato['FECHA_CIERRE'];
				$linea['URL_PDF'] = kernel::vinculador()->crear($operacion, 'generar_pdf_acta', array('acta'=>$dato['URL_ACTA']));
				$linea['URL_XLS'] = kernel::vinculador()->crear($operacion, 'generar_xls_acta', array('acta'=>$dato['URL_ACTA']));
				
				$nuevo[$i] = $linea;
				$i++;
				unset($acta);
			}
		}
		return $nuevo;
	}

	protected function get_data(){
		if (!isset($this->datos_consulta)) {
			$parametros = $this->get_filtros();
			$parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
			$this->datos_consulta = catalogo::consultar('docente', 'acta_cursadas', $parametros);
		}
		return $this->datos_consulta;
	}

	public function get_datos_filtros(){
		// periodo lectivo
		$pl = catalogo::consultar('unidad_academica', 'periodos_lectivos');
		$filtros['per_lec'] = array();
		foreach($pl as $periodo){
			$filtros['per_lec'][$periodo['_ID_']] = $periodo['PERIODO_LECTIVO'];
		}

		// anios academicos
		$aa = catalogo::consultar('unidad_academica', 'anios_academicos');
		$filtros['anios'] = array();
		foreach($aa as $anio){
			$filtros['anios'][$anio['_ID_']] = $anio['ANIO_ACADEMICO'];
		}
		return $filtros;
	}

	/**
	 * Retorna la cantidad de datos
	 * @return entero
	 */
	protected function get_total_registros(){
		 return count($this->get_data_reporte(0, true));
	}

	public function set_filtros($filtros){
		$this->filtros = array_merge($this->filtros, $filtros);
	}

	public function get_filtros(){
		return $this->filtros;
	}

	public function get_nombre_archivo(){
		return "acta_cursadas";
	}

	public function prepare(){
		parent::prepare();
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->add_var_js('url_periodos_lectivos', kernel::vinculador()->crear($operacion, 'buscar_periodos_lectivos'));
		$this->add_var_js('hash_periodo_lectivo', $this->controlador->hash_per_lec);
	}
}
?>