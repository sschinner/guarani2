<?php
namespace siu\operaciones\inscriptos_examenes;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\guarani;

class pagelet_reporte extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {
	public $filtros = array('filtro' => 'T'); //T= Todas, C= Con Inscripciones, S= Sin Inscripciones
	
	public function get_nombre(){
        return 'reporte';
    }
	
	function configurar(){
		$this->set_rpp(15);        
        
		$this->set_columnas_reporte($this->get_columnas());
		$this->agregar_corte('MATERIA_NOMBRE_COMPLETO', '{{valor}}');

		// Configuracion pdf
		//$this->set_pdf_encabezado(kernel::traductor()->trans('inscripcion_a_examenes'), "", 112);
		$this->set_pdf_fuente("Courier.afm");
		$this->set_pdf_fuente_texto(10);
		$this->set_pdf_fuente_titulo(10);
		$this->set_pdf_fuente_subtitulo(12);
		$this->set_pdf_hoja("a4", "landscape");
		$this->membrete(kernel::traductor()->trans('inscriptos_examen'));
		$this->set_titulo_reporte(kernel::traductor()->trans('inscriptos_examen'));
	
		$this->data['url_generar_pdf'] = kernel::vinculador()->crear('inscriptos_examenes', 'generar_pdf', array('filtro' => $this->filtros['filtro']));
		$this->data['url_generar_excel'] = kernel::vinculador()->crear('inscriptos_examenes', 'generar_excel', array('filtro' => $this->filtros['filtro']));
		$this->data['url_form_filtro'] = kernel::vinculador()->crear('inscriptos_examenes', 'filtrar');
	}
	
	public function get_columnas(){
		$titulo = array();
        $titulo['MATERIA_NOMBRE_COMPLETO'] = "Materia";
		$titulo['MESA_EXAMEN'] = "Mesa";
        $titulo['SEDE'] = "Sede";
        $titulo['CANTIDAD_INSCR'] = "Cantidad de inscriptos ";
        $titulo['ANIO_ACADEMICO'] = "Año";
        $titulo['TURNO_EXAMEN'] = "Turno";
        $titulo['LLAMADO'] = "Llamado";
        $titulo['MOMENTO'] = "Fecha";
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
	public function get_data_reporte($pagina = 0, $todo = false)
	{
		$i=0;
        $reg_por_pagina = $this->get_rpp();
        $pagina = $this->get_pagina();
        $minimo = ($pagina - 1) * $reg_por_pagina;
        $maximo = $minimo + $reg_por_pagina;
		$filtro = $this->get_filtros();
        
        $datos = $this->controlador->get_lista_mesas();
		$operacion = kernel::ruteador()->get_id_operacion();

        $nuevo = array();
        foreach($datos as $id => $dato) {
            if ($todo or ($i <= $reg_por_pagina && $id >= $minimo && $id < $maximo)){
                $id = $dato['__ID__'];
                $dato['URL_LINEA'] = kernel::vinculador()->crear($operacion, 'info_comision', array('id'=>$id, 'ord'=> null));
                $nuevo[$i] = $dato;
                $i++;
            }
        }

		/*FILTRAR*/
		if($filtro['filtro'] == 'C'){ //Devolver sólo comisiones con inscriptos
			$con_inscriptos = array();
			foreach($nuevo as $materia){
				if($materia['CANTIDAD_INSCR'] > 0){
					$con_inscriptos[]=$materia;
				}
				unset($nuevo);
				$nuevo = $con_inscriptos;
			}
		}
		
		if($filtro['filtro'] == 'S'){ //Devolver sólo comisiones sin inscriptos
			$sin_inscriptos = array();
			foreach($nuevo as $materia){
				if($materia['CANTIDAD_INSCR'] == 0){
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
	protected function get_total_registros()
	{
		 return count($this->get_data_reporte(0, true));
	}
	
	public function get_nombre_archivo(){
		return "inscripciones_a_examenes";
	}
	
	public function generar_excel(){
		$excel = $this->get_generador_excel();		
		$data_bruto = $this->datos_excel();
		$titulos = $this->titulos_excel();
		
		$res = array();
		foreach ($titulos as $col => $val){
			if (is_array($val)){
				$res[$col] = $val[0];				
			} else {
				$res[$col] = $val;				
			}
		}		
		$titulos = $res;		
		unset($res);
		
		foreach($data_bruto as $num => $linea){
			$renglon = array();
			foreach ($linea as $key => $value){				
				if ($key != "URL_LINEA" && array_key_exists($key, $titulos)){
					$renglon[$key] = $value;
				}
			}
			$data_bruto[$num] = $renglon;
			unset($renglon);
		}
		
		$excel->set_nombre_archivo('inscripciones_a_examenes');
		$institucion = guarani::ua()->get_nombre_institucion();
		$facultad = guarani::ua()->get_nombre();
		
		$excel->agregar_texto_sin_enter($institucion,1);
		$excel->agregar_texto($facultad,1);
		$estilo_titulo = array(
 			'font' => array('bold' => true),
 		);		
		$excel->agregar_texto_estilos('Inscripciones a Exámenes',1, $estilo_titulo);		
		$excel->agregar_tabla($data_bruto,$titulos,'');		
		$excel->set_nombre_archivo($this->get_nombre_archivo());
		$excel->generar();
	}
	
	public function set_filtros($filtros){
		$this->filtros = array_merge($this->filtros, $filtros);
		$this->data['url_generar_pdf'] = kernel::vinculador()->crear('inscriptos_examenes', 'generar_pdf', array('filtro' => $this->filtros['filtro']));
		$this->data['url_generar_excel'] = kernel::vinculador()->crear('inscriptos_examenes', 'generar_excel', array('filtro' => $this->filtros['filtro']));
	}

	public function get_filtros(){
		return $this->filtros;
	}		
}
?>