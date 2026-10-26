<?php
namespace siu\operaciones\aulas;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\guarani;

class pagelet_reporte extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {
	protected $datos_consulta;
	private $filtros;
	
	public function get_nombre(){
        return 'reporte';
    }

	function configurar(){
		$this->set_rpp(15);
		$this->set_columnas_reporte($this->get_columnas());
		$this->set_pdf_hoja("a4", 'landscape');
		//$universidad = guarani::ua()->get_nombre_institucion().' - '.guarani::ua()->get_nombre();
		//$this->agregar_corte('materia', "{{valor}}");
		
		// Setea metodos que se ejecutan al final de cada corte. Con el subconjunto de datos del corte
		//$this->agregar_funcion_pie_corte('nombre_funcion', array(array(0, 10), 'Titulo: ', 1));
		//$this->agregar_mensaje_pie_corte('nombre_funcion_pie');

		// Setea metodos que se ejecutan al final del reporte.
		//$this->agregar_funcion_pie_reporte('nombre_funcion_pie_reporte', array(array(0, 10), 'Titulo: ', 1));
		//$this->agregar_mensaje_pie_reporte('nombre_funcion_pie_reporte');

		// Configuracion pdf
		//$this->pdf_encabezado = array($universidad, kernel::traductor()->trans('header.menu.aulas'), 100);
//		$this->set_pdf_encabezado(kernel::traductor()->trans('header.menu.aulas'), "", 112);
		$this->membrete(kernel::traductor()->trans('header.menu.aulas'));
		$this->set_tiene_encabezado(true);
		$this->set_titulo_reporte(kernel::traductor()->trans('header.menu.aulas'));

		$alumno = guarani::persona()->get_nombre();
		$this->set_encabezado_reporte(PHP_EOL.'Alumno: '.$alumno);
		
		$encabezado_excel = array();
		$encabezado_excel['alumno'] = 'Alumno: '.$alumno;
		$this->set_encabezado_reporte_excel($encabezado_excel);

//		$this->set_pdf_fuente("Courier.afm");
//		$this->set_pdf_fuente_texto(10);
//		$this->set_pdf_fuente_titulo(13);
//		$this->set_pdf_fuente_subtitulo(11);
//		$this->set_pdf_hoja("a4");
	}
	
	public function get_columnas(){
		$titulo = array();		
		$titulo['dia'] = array("Día", array('width'=>65));
		$titulo['actividad'] = array("Materia", array('width'=>150));
		$titulo['per_lect'] = array("Período lectivo", array('width'=>70));
		$titulo['comision'] = array("Comisión", array('width'=>70));
		$titulo['aula'] = array("Aula", array('width'=>70));
		$titulo['edificio'] = array("Edificio", array('width'=>70));
		$titulo['inicio'] = array("Inicio - Fin", array('width'=>88));
		//$titulo['fin'] = "Hora Fin";
		$titulo['tipo'] = array("Tipo clase", array('width'=>70));
		$titulo['fecha_inicio'] = array("Fecha inicio", array('width'=>70));
		$titulo['periodicidad'] = array("Periodicidad", array('width'=>90));
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
        
        $datos = $this->get_datos();
		
        $nuevo = array();
		$filtro_actividades = array();
        foreach($datos as $id => $dato) {
            $linea = array();
            if ($todo or ($i <= $reg_por_pagina && $id >= $minimo && $id < $maximo)){
				$linea['dia'] = $dato[9];
				$linea['actividad'] = $dato[18]." (".$dato[4].")";				
				$linea['per_lect'] = $dato[21]."-".$dato[22];				
				$linea['comision'] = $dato[5];				
				$linea['aula'] = $dato[12];
				$linea['edificio'] = $dato[20];
				if (isset($dato[10]) and isset($dato[14])) {
					$linea['inicio'] = $dato[10]." - ".$dato[14];
				}else{
					$linea['inicio'] = " ";
				}
				//$linea['inicio'] = $dato[10];
				//$linea['fin'] = $dato[14];
				$linea['tipo'] = $dato[16];
                $linea['fecha_inicio'] = $dato[23];
                $linea['periodicidad'] = $dato[25];
                $nuevo[$i] = $linea;
                $i++;
				
				$filtro_actividades[$dato[18]." (".$dato[4].")"] = $dato[18]." (".$dato[4].")";
                unset($linea);
            }
        }
		
		$this->filtros['actividades'] = $filtro_actividades;
        return $nuevo;
	}

	function get_datos()
	{
		if (!isset($this->datos_consulta)) {
	        $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
			$this->datos_consulta = catalogo::consultar('alumno', 'aulas', $parametros);
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
		return "agenda_de_clases";
	}
	
	public function get_filtros(){
		$filtro_dias['Lunes'] = 'Lunes';
		$filtro_dias['Martes'] = 'Martes';
		$filtro_dias['Miércoles'] = 'Miércoles';
		$filtro_dias['Jueves'] = 'Jueves';
		$filtro_dias['Viernes'] = 'Viernes';
		$filtro_dias['Sábado'] = 'Sábado';
		$filtro_dias['Domingo'] = 'Domingo';
		$filtro_dias[''] = 'NO INFORMA';
		
		$this->filtros['dias'] = $filtro_dias;
		$this->add_var_js('dias_js', array_keys($this->filtros['dias']));
		$this->add_var_js('actividades_js', array_keys($this->filtros['actividades']));
		return $this->filtros;
	}
}
?>