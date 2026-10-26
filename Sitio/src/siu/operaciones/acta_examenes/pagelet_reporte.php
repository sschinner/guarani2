<?php
namespace siu\operaciones\acta_examenes;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\guarani;

class pagelet_reporte extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {
	protected $datos_consulta;	
	private $filtros = array('anio_academico' => '', 'turno' => '','nombre' => '');

	public function get_nombre(){
		return 'reporte';
	}

	function configurar(){
		$this->set_rpp(15);
		$this->set_columnas_reporte($this->get_columnas());

		// Configuracion pdf
		$this->membrete(kernel::traductor()->trans('header.menu.acta_examenes'));
		$this->set_pdf_hoja("a4", 'landscape');
		$this->set_tiene_encabezado(true);
		$this->set_titulo_reporte(kernel::traductor()->trans('header.menu.acta_examenes'));

		$doc = guarani::persona()->get_nombre();
		$this->set_encabezado_reporte(PHP_EOL.'Docente: '.$doc);
		
		$encabezado_excel = array();
		$encabezado_excel['docente'] = 'Docente: '.$doc;
		$this->set_encabezado_reporte_excel($encabezado_excel);		

		$this->data['url_form_filtro'] = kernel::vinculador()->crear('acta_examenes', 'filtrar');
		$this->data['titulos'] =$this->get_columnas_vista();
	}

	public function get_columnas(){
		$titulos = array();
		$titulos['MATERIA'] = array('Materia', array('width' => 150));
		$titulos['SEDE'] = "Sede";
		$titulos['MESA'] = "Mesa";
		$titulos['FECHA'] = "Fecha";
		$titulos['ACTA'] = "Acta";
		$titulos['TIPO_ACTA'] = "Tipo de acta";
		$titulos['ESTADO'] = "Estado";
		$titulos['ROL_DOCENTE'] = "Rol docente";
		return $titulos;
	}

	public function get_columnas_vista(){
		$titulos = array();
		$titulos['MATERIA'] = array('Materia', array('width' => 150));
		$titulos['SEDE'] = "Sede";
		$titulos['MESA'] = "Mesa";
		$titulos['FECHA'] = "Fecha";
		$titulos['ACTA'] = "Acta";
		$titulos['TIPO_ACTA'] = "Tipo de acta";
		$titulos['ESTADO'] = "Estado";
		$titulos['ROL_DOCENTE'] = "Rol docente";
		$titulos['ACCIONES'] = " ";
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

		$datos = $this->get_data();

		$nuevo = array();
		foreach($datos as $id => $dato) {
			$linea = array();
			if ($todo or ($i <= $reg_por_pagina && $id >= $minimo && $id < $maximo)){
				$linea['MATERIA'] = $dato['MATERIA'];
				$linea['SEDE'] = $dato['SEDE'];
				$linea['MESA'] = $dato['MESA'];
				$linea['FECHA'] = $dato['FECHA'];
				$linea['ACTA'] = $dato['ACTA'];
				$linea['TIPO_ACTA'] = $dato['TIPO_ACTA'];
				$linea['URL_LINEA'] = kernel::vinculador()->crear('acta_examenes', 'info_acta', array('acta'=>$dato['URL_ACTA'], 'tipo_acta'=>$dato['TIPO_ACTA']));
				$linea['ESTADO'] = $dato['ESTADO'];
				$linea['ROL_DOCENTE'] = $dato['ROL_DOCENTE'];
				$linea['URL_PDF'] = kernel::vinculador()->crear('acta_examenes', 'generar_pdf_acta', array('acta'=>$dato['URL_ACTA'], 'tipo_acta'=>$dato['TIPO_ACTA']));
				$linea['URL_XLS'] = kernel::vinculador()->crear('acta_examenes', 'generar_xls_acta', array('acta'=>$dato['URL_ACTA'], 'tipo_acta'=>$dato['TIPO_ACTA']));
				$nuevo[$i] = $linea;
				$i++;
				unset($acta, $tipo_acta);
			}
		}
		return $nuevo;
	}

	protected function get_data(){
		if (!isset($this->datos_consulta)) {
			$parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
			$filtros = $this->get_filtros();

			$parametros["anio_academico"] = $filtros["anio_academico"];
			$parametros["turno"] = $filtros["turno"];
			$parametros["nombre"] = $filtros["nombre"];

			$this->datos_consulta = catalogo::consultar('docente', 'acta_examenes', $parametros);
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

	public function set_filtros($filtros){
		$this->filtros = array_merge($this->filtros, $filtros);
	}

	public function get_filtros(){
		return $this->filtros;
	}

	public function hay_filtros(){
		if (!empty($this->filtros['anio_academico']) or !empty($this->filtros['turno']) or !empty($this->filtros['nombre'])){
			return $this->filtros;
		} 
		return false;
	}

	public function get_datos_filtros(){
		$filtros = array();
		$aa = catalogo::consultar('unidad_academica', 'anios_academicos');
		$te = catalogo::consultar('unidad_academica', 'turnos_examen');

		$filtros['anios'] = array();
		foreach($aa as $anio){
			$filtros['anios'][$anio['_ID_']] = $anio['ANIO_ACADEMICO'];
		}

		$filtros['turnos'] = array();
		foreach($te as $turno){
			$filtros['turnos'][$turno['_ID_']] = $turno['TURNO_EXAMEN'];
		}

		return $filtros;
	}

	public function get_nombre_archivo(){
		return "acta_examenes";
	}

	public function prepare(){
		parent::prepare();
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->add_var_js('url_turnos_examen', kernel::vinculador()->crear($operacion, 'buscar_turnos'));
		$this->add_var_js('hash_turno', $this->controlador->hash_turno);
	}
}
?>