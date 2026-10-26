<?php
namespace siu\operaciones\horarios_cursadas;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\guarani;

class pagelet_reporte extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte  {
	protected $datos_consulta;

	public function get_nombre()
	{
		return 'reporte';
	}

	public function prepare()
	{
		$anio= $this->controlador->datos_filtro['anio_academico'];
		$periodo= $this->controlador->datos_filtro['periodo'];
		$materia= $this->controlador->datos_filtro['materia'];
		$sede= $this->controlador->datos_filtro['sede'];
		$dia= $this->controlador->datos_filtro['dia_semana'];
		$turno= $this->controlador->datos_filtro['turno'];
		$carrera= $this->controlador->datos_filtro['carrera'];
		$anio_cursada= $this->controlador->datos_filtro['anio_cursada'];
        $operacion = kernel::ruteador()->get_id_operacion();            
		$this->data['url']['generar_pdf'] = kernel::vinculador()->crear($operacion, 'generar_pdf', array('anio'=>$anio, 'periodo'=>$periodo, 'materia'=>$materia, 'sede'=>$sede, 'dia'=>$dia, 'turno'=>$turno, 'carrera'=>$carrera, 'anio_curs'=>$anio_cursada));
		$this->data['url']['generar_excel'] = kernel::vinculador()->crear($operacion, 'generar_excel', array('anio'=>$anio, 'periodo'=>$periodo, 'materia'=>$materia, 'sede'=>$sede, 'dia'=>$dia, 'turno'=>$turno, 'carrera'=>$carrera, 'anio_curs'=>$anio_cursada));
	}
	function configurar(){

		}
	
	public function get_columnas(){

	}
	
	function get_datos()
	{

	}
	
	/**
	 * Recupera los datos
	 * @param entero $pagina
	 * Numero de página que se desea recuperar
	 * @param buleano $todo
	 * Recuperar todos los datos
	 * @return array 
	 */
	public function get_data_reporte($pagina = 0, $todo = true){	
		$i=0;
        $reg_por_pagina = $this->get_rpp();
        $pagina = $this->get_pagina();
        
        $minimo = ($pagina - 1) * $reg_por_pagina;
        $maximo = $minimo + $reg_por_pagina;
        
		$datos = $this->get_datos();
        $nuevo = array();
        foreach($datos as $id => $dato) {
            if ($todo or ($i <= $reg_por_pagina && $id >= $minimo && $id < $maximo)){
                $nuevo[$i] = $dato;
                $i++;
            }
        }
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
		return "horarios_cursadas";
	}	
	
			
}
?>