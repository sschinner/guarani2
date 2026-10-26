<?php
namespace siu\operaciones\requisitos_ingreso;

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
	}
	
	public function get_columnas(){
		$titulo = array();
		$titulo['requisito_nombre'] = "Requisito";
		$titulo['f_tope_present'] = "Fecha Límite Presentación";
		return $titulo;
	}
	
	function get_datos()
	{
       $this->data['datos'] = guarani::persona()->get_requisitos_pendientes();
	   return $this->data['datos'];
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
        return $this->get_datos();
	}

	/**
	 * Retorna la cantidad de datos
	 * @return entero
	 */
	protected function get_total_registros(){
		 return count($this->get_data_reporte(0, true));
	}
	
	public function get_nombre_archivo(){
		return "requisitos_pendientes";
	}
	
}
?>