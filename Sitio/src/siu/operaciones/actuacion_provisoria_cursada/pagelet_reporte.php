<?php
namespace siu\operaciones\actuacion_provisoria_cursada;

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
		$this->set_rpp(5);
		$this->set_pdf_hoja("a4", "landscape");
		$this->set_columnas_reporte($this->get_columnas());
		
		//$this->agregar_corte(1, 'Titulo de la columna {{columna}}: {{valor}}');
		
		// Setea metodos que se ejecutan al final de cada corte. Con el subconjunto de datos del corte
		//$this->agregar_funcion_pie_corte('nombre_funcion', array(array(0, 10), 'Titulo: ', 1));
		//$this->agregar_mensaje_pie_corte('nombre_funcion_pie');

		// Setea metodos que se ejecutan al final del reporte.
		//$this->agregar_funcion_pie_reporte('nombre_funcion_pie_reporte', array(array(0, 10), 'Titulo: ', 1));
		//$this->agregar_mensaje_pie_reporte('nombre_funcion_pie_reporte');

		// Configuracion pdf
                $this->membrete(kernel::traductor()->trans('header.menu.actuacion_provisoria_cursada'));
				$this->pdf_hoja_orientacion = "landscape";
				$this->set_tiene_encabezado(true);
				$this->set_titulo_reporte(kernel::traductor()->trans('header.menu.actuacion_provisoria_cursada'));

				$alumno = guarani::persona()->get_nombre();
				$this->set_encabezado_reporte("\n\n".' Alumno: '.$alumno);

				$encabezado_excel = array();
				$encabezado_excel['alumno'] = 'Alumno: '.$alumno;
				$this->set_encabezado_reporte_excel($encabezado_excel);
	}
	
	public function get_columnas(){
		$titulo = array();
		$titulo['materia'] = "Materia";
		$titulo['nota'] = "Nota";
		$titulo['resultado'] = "Resultado";
		$titulo['fecha_regularidad'] = "Fecha reg.";
		$titulo['comision'] = "Comisión";
		return $titulo;
	}
	
	function get_datos()
	{
                                    $datos= array();
		if (!isset($this->datos_consulta)) {
	        $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
			$datos = catalogo::consultar('alumno', 'actuacion_provisoria_cursada', $parametros);
		}
		
		$corte = array();
		foreach ($datos as $dato){
			$corte[$dato['carrera']]['carrera'] = $dato['carrera'];
			$corte[$dato['carrera']]['carrera_reducido'] = $dato['carrera_reducido'];
			$corte[$dato['carrera']]['legajo'] = $dato['legajo'];
			$corte[$dato['carrera']]['plan'] = $dato['plan'];
			
			$cursada['materia'] = $dato['materia'];
			$cursada['nota'] = $dato['nota'];
			$cursada['resultado'] = $dato['resultado'];
			$cursada['fecha_regularidad'] = $dato['fecha_regularidad'];
			$cursada['comision'] = $dato['comision'];
			
			$corte[$dato['carrera']]['cursadas'][] = $cursada;
			unset($cursada);
		}
		
		$this->datos_consulta = $corte;		
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
		return "actuacion_provisoria_cursada";
	}
	
	
	public function generar_pdf(){
		$this->width_options($this->pdf_hoja_orientacion);
		$pdf = $this->get_generador_pdf();
		$pdf->set_font($this->pdf_fuente);
		$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 750, 'width' => 750, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => $this->get_opciones_reporte_pdf()));
		$pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 750, 'width' => 750));
		$pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
		$pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
		$pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
		$pdf->set_tiene_encabezado($this->tiene_encabezado);
		$pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
		
		if (!empty($this->pdf_encabezado_img["img"])){
			$pdf->set_encabezado_img($this->pdf_encabezado_img["img"], $this->pdf_encabezado_img["width"]);
		} else {
			$logo = kernel::localizador()->encontrar_img('www/img','logo.png');
			$pdf->set_encabezado_img($logo['path'], "100");
		}
		$pdf->set_encabezado_reporte($this->encabezado_reporte);
//                $pdf->posY(720);              
		
		$data = $this->datos_pdf();	
		$titulos = $this->titulos_pdf();
		
		foreach ($data as $cursada){
//			$pdf->agregar_texto("Carrera: ".$cursada['carrera']);
//			$pdf->agregar_texto("Legajo: ".$cursada['legajo']);
//			$pdf->agregar_texto("Plan: ".$cursada['plan']);
//			
			$encabezado = array(
								0 => "Legajo: ".$cursada['legajo'],
								1 => "Carrera: (".$cursada['carrera'].") ".$cursada['carrera_reducido'],
								2 => "Plan: ".$cursada['plan']
							);
			$pdf->agregar_tabla_encabezado(3, $encabezado);	
			$pdf->agregar_texto('');
			$pdf->agregar_tabla($cursada['cursadas'], $titulos, '');
			$pdf->agregar_texto('');
			$pdf->agregar_texto('');
		}		

		$pdf->set_nombre_archivo($this->get_nombre_archivo());
		$pdf->generar();
	}

	public function generar_excel(){
		$excel = $this->get_generador_excel();
		$datos = $this->datos_excel();
		$titulos = $this->titulos_excel();
		$this->membrete_excel($excel);
		
		if (isset($this->titulo_reporte)){
					$estilo_titulo = array(
 			'font' => array('bold' => true),
 		);
		$excel->agregar_texto_estilos($this->titulo_reporte,1, $estilo_titulo);
		}
		
		if (isset($this->tiene_encabezado)){
			$encabezado = $this->encabezado_reporte_excel;
			foreach($encabezado as $renglon){
				$excel->agregar_texto($renglon,1);
			}
		}
			
		foreach ($datos as $cursada){
			$excel->agregar_texto_sin_enter("Carrera: (".$cursada['carrera'].") ".$cursada['carrera_reducido'],1);
			$excel->agregar_texto_sin_enter("Legajo: ".$cursada['legajo'],1);
			$excel->agregar_texto_sin_enter("Plan: ".$cursada['plan'],1);
			$excel->agregar_tabla($cursada['cursadas'], $titulos, '');
			$excel->agregar_texto("", 1);
		}		

		$excel->set_nombre_archivo($this->get_nombre_archivo());
		$excel->generar();
	}	
}
?>