<?php
namespace %pers%\operaciones\%operacion%;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;

class pagelet_reporte extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {
	
	protected $datos_consulta;
	
	public function get_nombre(){
        return 'reporte';
    }

	function configurar(){
		$this->set_rpp(15);
		$this->set_columnas_reporte($this->get_columnas());
		//$this->agregar_corte(1, 'Titulo de la columna {{columna}}: {{valor}}');
		
		// Setea metodos que se ejecutan al final de cada corte. Con el subconjunto de datos del corte
		//$this->agregar_funcion_pie_corte('nombre_funcion', array(array(0, 10), 'Titulo: ', 1));
		//$this->agregar_mensaje_pie_corte('nombre_funcion_pie');

		// Setea metodos que se ejecutan al final del reporte.
		//$this->agregar_funcion_pie_reporte('nombre_funcion_pie_reporte', array(array(0, 10), 'Titulo: ', 1));
		//$this->agregar_mensaje_pie_reporte('nombre_funcion_pie_reporte');

		// Configuracion pdf
		$this->set_pdf_encabezado(kernel::traductor()->trans('header.menu.%operacion%'), "", 112);
		$this->set_pdf_fuente("Courier.afm");
		$this->set_pdf_fuente_texto(10);
		$this->set_pdf_fuente_titulo(13);
		$this->set_pdf_fuente_subtitulo(11);
		$this->set_pdf_hoja("a4");
	}
	
	public function get_columnas(){
		$titulo = array();
		$titulo['KEY_1'] = "Title1";
		$titulo['KEY_2'] = "Title1";
		$titulo['KEY_3'] = "Title1";
		$titulo['KEY_4'] = "Title1";
		$titulo['KEY_5'] = "Title1";
		return $titulo;
	}
	
	function get_datos()
	{
		if (!isset($this->datos_consulta)) {
			//$this->datos_consulta = datos;
		}
		return $this->datos_consulta;
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
		return '%operacion%';
	}
}
?>