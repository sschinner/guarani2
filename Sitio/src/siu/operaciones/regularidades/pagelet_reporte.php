<?php
namespace siu\operaciones\regularidades;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\guarani;

class pagelet_reporte extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {
	protected $datos_consulta;

	public function get_nombre(){
		return 'reporte';
	}

	function configurar(){
		$this->set_rpp(15);
		$this->set_columnas_reporte($this->get_columnas());
		//$this->agregar_corte('FECHA_VENCIMIENTO', '{{valor}}');

		// Setea metodos que se ejecutan al final de cada corte. Con el subconjunto de datos del corte
		//$this->agregar_funcion_pie_corte('nombre_funcion', array(array(0, 10), 'Titulo: ', 1));
		//$this->agregar_mensaje_pie_corte('nombre_funcion_pie');

		// Setea metodos que se ejecutan al final del reporte.
		//$this->agregar_funcion_pie_reporte('nombre_funcion_pie_reporte', array(array(0, 10), 'Titulo: ', 1));
		//$this->agregar_mensaje_pie_reporte('nombre_funcion_pie_reporte');

		// Configuracion pdf
        $this->membrete(kernel::traductor()->trans('header.menu.regularidades'));
		$this->set_titulo_reporte(kernel::traductor()->trans('header.menu.regularidades'));
		$this->pdf_hoja_orientacion = "landscape";
		$this->set_tiene_encabezado(true);
		
		$alumno = guarani::persona()->get_nombre();
		$datos_carrera = guarani::persona()->get_info_carrera_activa();
		$nombre_carrera = "";
		if (isset($datos_carrera)){
			$nombre_carrera = $datos_carrera['nombre'];
		}
		$legajo = guarani::persona()->get_id_legajo_activo();
		$plan = guarani::persona()->get_id_plan_activo();
		//$this->set_encabezado_reporte('Alumno: '.$alumno.PHP_EOL.'Legajo: '.$legajo.PHP_EOL.'Carrera: '.$nombre_carrera.PHP_EOL.'Plan: '.$plan.PHP_EOL);

		
		$encabezado_excel = array();
		$encabezado_excel[0] = 'Alumno: '.$alumno;
		$encabezado_excel[1] = 'Legajo: '.$legajo;
		$encabezado_excel[2] = 'Carrera: '.$nombre_carrera;
		$encabezado_excel[3] = 'Plan: '.$plan;
		$this->set_encabezado_reporte_excel($encabezado_excel);
		
		$encabezado_pdf = array('cant_columnas' => 2,
								'datos' => $encabezado_excel);
		
		$this->set_encabezado_tabla($encabezado_pdf);
	}

	public function get_columnas(){
		$titulo = array();
		$titulo['MATERIA'] = array(ucfirst(kernel::traductor()->trans('regularidades.materia')), array('ordenable' => true, 'width' => 52));
		$titulo['MATERIA_NOMBRE'] = array(ucfirst(kernel::traductor()->trans('regularidades.nombre')), array('ordenable' => true, 'width' => 200));
		$titulo['RESULTADO'] = array(ucfirst(kernel::traductor()->trans('regularidades.resultado')), array('width' => 64));
		$titulo['FECHA_REGULARIDAD'] = array(ucfirst(kernel::traductor()->trans('regularidades.fecha_regularidad')), array('width' => 76));
		$titulo['FECHA_VENCIMIENTO'] = array(ucfirst(kernel::traductor()->trans('regularidades.fecha_vencimiento')), array('width' => 76));
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
		$i=0;
		$reg_por_pagina = $this->get_rpp();
		$pagina = $this->get_pagina();
		$minimo = ($pagina - 1) * $reg_por_pagina;
		$maximo = $minimo + $reg_por_pagina;

		$datos = $this->get_data();

		$nuevo = array();
		foreach($datos as $id => $dato) {
			if ($todo or ($i <= $reg_por_pagina && $id >= $minimo && $id < $maximo)){
				$nuevo[$i] = $dato;
				$nuevo[$i]['URL_LINEA'] = kernel::vinculador()->crear('regularidades', 'info_regularidad', array('parametro'=>1));
				$i++;
			}
		}
		return $nuevo;
	}

	protected function get_data(){
		if (!isset($this->datos_consulta)) {
			$parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
			$parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
			$datos = catalogo::consultar('alumno', 'regularidades', $parametros);
			$this->datos_consulta = $datos;
		}
		$this->datos_consulta = $this->ordenar($this->datos_consulta, $this->columna, $this->orden);
		return $this->datos_consulta;
	}

	protected function ordenar($datos, $columna, $orden){
		if (isset($columna) && isset($orden) && array_key_exists($columna, $this->get_columnas())){
			$count = count($datos);
			for($i=0; $i<=$count; $i++){
				for($j=$count-1; $j>$i; $j=$j-1){
					if (isset($datos[$j][$columna]) && isset($datos[$j-1][$columna])){
						if ($orden == "asc" && $datos[$j][$columna] < $datos[$j-1][$columna]){
							$tmp = $datos[$j];
							$datos[$j] = $datos[$j-1];
							$datos[$j-1] = $tmp;
							unset($tmp);
						} elseif($orden == "desc" && $datos[$j][$columna] > $datos[$j-1][$columna]){
							$tmp = $datos[$j];
							$datos[$j] = $datos[$j-1];
							$datos[$j-1] = $tmp;
							unset($tmp);
						}
					}
				}
			}
		}
		return $datos;
	}

	/**
	 * Retorna la cantidad de datos
	 * @return entero
	 */
	protected function get_total_registros(){
		 return count($this->get_data_reporte(0, true));
	}

	public function get_nombre_archivo(){
		return "regularidades";
	}

	public function datos_excel(){
		$datos = $this->get_data_reporte(0,true);
		foreach ($datos as $indice => $valor){
			$linea = array();
			$linea = $valor;
			unset($linea['DETALLE']);
			$linea['ANIO_ACADEMICO'] = $valor['DETALLE']['ANIO_ACADEMICO'];
			$linea['PER_LEC'] = $valor['DETALLE']['PER_LEC'];
			$linea['ORIGEN'] = $valor['DETALLE']['ORIGEN'];
			$linea['NOTA'] = $valor['DETALLE']['NOTA'];
			$datos[$indice] = $linea;
		}
		return $datos;
	}

	public function titulos_excel(){
		$columnas = $this->get_columnas();
		$nuevas_columnas['ANIO_ACADEMICO'] = ucfirst(kernel::traductor()->trans('regularidades.anio_academico'));
		$nuevas_columnas['PER_LEC'] = ucfirst(kernel::traductor()->trans('regularidades.periodo_lectivo'));
		$nuevas_columnas['ORIGEN'] = ucfirst(kernel::traductor()->trans('regularidades.origen'));
		$nuevas_columnas['NOTA'] = ucfirst(kernel::traductor()->trans('regularidades.nota'));
		$merge = array_merge($columnas,$nuevas_columnas);
		return $merge;
	}

	public function datos_pdf(){
		return $this->datos_excel();
	}

	public function titulos_pdf(){
		return $this->titulos_excel();
	}
}
?>