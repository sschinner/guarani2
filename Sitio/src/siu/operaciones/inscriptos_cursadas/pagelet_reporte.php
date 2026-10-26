<?php
namespace siu\operaciones\inscriptos_cursadas;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;

class pagelet_reporte extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {
	public $filtros = array('filtro' => 'T'); //T= Todas, C= Con Inscripciones, S= Sin Inscripciones
	
	public function get_nombre(){
        return 'reporte';
    }

	function configurar(){
		$this->set_rpp(15);
        
		$this->set_columnas_reporte($this->get_columnas());
		$this->agregar_corte('MATERIA_NOMBRE', "{{valor}}");

		// Configuracion pdf
		$this->membrete(kernel::traductor()->trans('tit_inscriptos_cursada'));
		$this->set_titulo_reporte(kernel::traductor()->trans('tit_inscriptos_cursada'));	
		$this->set_pdf_hoja("a4", "landscape");

		$this->data['url_generar_pdf'] = kernel::vinculador()->crear('inscriptos_cursadas', 'generar_pdf', array('filtro' => $this->filtros['filtro']));
		$this->data['url_generar_excel'] = kernel::vinculador()->crear('inscriptos_cursadas', 'generar_excel', array('filtro' => $this->filtros['filtro']));		
		$this->data['url_form_filtro'] = kernel::vinculador()->crear('inscriptos_cursadas', 'filtrar');
	}
	
	public function get_columnas(){
		$titulo = array();
		$titulo['COMISION_NOMBRE'] = "Comisión";		
		$titulo['SUBCOMISION_NOMBRE'] = "Subcomisión";		
        //$titulo['SEDE'] = "Sede";
        $titulo['PERIODO_LECTIVO'] = "Período Lectivo";
        $titulo['CATEDRA'] = "Cátedra";
        $titulo['TURNO'] = "Turno";
        $titulo['INSCRIPCIONES_PENDIENTES'] = "Pendientes";
        $titulo['INSCRIPCIONES_ACEPTADAS'] = "Aceptadas";
        $titulo['INSCRIPCIONES_TOTALES'] = "Total";
        $titulo['MATERIA_NOMBRE'] = "Materia";
		
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
        $datos = $this->controlador->get_lista_comisiones();
		$filtro = $this->get_filtros();
		
        $nuevo = array();
        $operacion = kernel::ruteador()->get_id_operacion();
        foreach($datos as $id => $dato) {
            if ($todo or ($i <= $reg_por_pagina && $id >= $minimo && $id < $maximo)){
				if ($id != "COMISION_NOMBRE"){
					$comision = $dato['COMISION'];
					$subcomision = $dato['SUBCOMISION'];
					$dato['URL_LINEA'] = kernel::vinculador()->crear($operacion, 'info_comision', array('c'=>$comision, 's'=>$subcomision));
//					if (empty($dato['CATEDRA'])){
//						$dato['CATEDRA'] = kernel::traductor()->trans("sin_catedra");
//					}
					$nuevo[$i] = $dato;
					$i++;
					unset($comision);
				}
            }
        }

		/*FILTRAR*/
		if($filtro['filtro'] == 'C'){ //Devolver sólo comisiones con inscriptos
			$con_inscriptos = array();
			foreach($nuevo as $materia){
				if($materia['INSCRIPCIONES_ACEPTADAS'] > 0){
					$con_inscriptos[]=$materia;
				}
				unset($nuevo);
				$nuevo = $con_inscriptos;
			}
		}
		
		if($filtro['filtro'] == 'S'){ //Devolver sólo comisiones sin inscriptos
			$sin_inscriptos = array();
			foreach($nuevo as $materia){
				if($materia['INSCRIPCIONES_ACEPTADAS'] == 0){
					$sin_inscriptos[]=$materia;
				}
				unset($nuevo);
				$nuevo = $sin_inscriptos;
			}			
		}
		
		//if $filtro['filtro']== 'T' -> Devolver sin filtrar (todos)/
        return $nuevo;
	}

	/**
	 * Retorna la cantidad de datos
	 * @return entero
	 */
	protected function get_total_registros(){
		 return count($this->get_data_reporte(0, true));
	}
	
	public function get_nombre_archivo(){
		return kernel::traductor()->trans("tit_inscriptos_cursada");
	}
	
	public function set_filtros($filtros){
		$this->filtros = array_merge($this->filtros, $filtros);
		$this->data['url_generar_pdf'] = kernel::vinculador()->crear('inscriptos_cursadas', 'generar_pdf', array('filtro' => $this->filtros['filtro']));
		$this->data['url_generar_excel'] = kernel::vinculador()->crear('inscriptos_cursadas', 'generar_excel', array('filtro' => $this->filtros['filtro']));
	}

	public function get_filtros(){
		return $this->filtros;
	}	
}
?>