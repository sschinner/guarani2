<?php
namespace siu\operaciones\agenda_cursadas;

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
		$this->agregar_corte("MATERIA_NOMBRE_COMPLETO", "{{valor}}");

		// Configuracion pdf
		$this->set_pdf_encabezado(kernel::traductor()->trans('agenda_de_cursadas'), \siu\guarani::persona()->get_nombre(), 112);
		$this->set_pdf_fuente("Courier.afm");
		$this->set_pdf_fuente_texto(10);
		$this->set_pdf_fuente_titulo(13);
		$this->set_pdf_fuente_subtitulo(11);
		$this->set_pdf_hoja('a4', 'landscape');
		//$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 500, 'width' => 500, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => $this->get_opciones_reporte_pdf()));
	}

	public function get_columnas(){
		$titulo = array();
		$titulo['MATERIA_NOMBRE_COMPLETO'] = ucfirst(kernel::traductor()->trans('agenda_cursadas.materia'));
		$titulo['DIA_SEMANA_DESC'] = ucfirst(kernel::traductor()->trans('agenda_cursadas.dia'));
		$titulo['HORA_COMIENZO_CLASE'] = ucfirst(kernel::traductor()->trans('agenda_cursadas.inicio'));
		$titulo['HORA_FIN_CLASE'] = ucfirst(kernel::traductor()->trans('agenda_cursadas.fin'));
		$titulo['COMISION_NOMBRE'] = ucfirst(kernel::traductor()->trans('agenda_cursadas.comision'));
		$titulo['COMISION_CATEDRA'] = ucfirst(kernel::traductor()->trans('agenda_cursadas.catedra'));
		$titulo['TURNO'] = ucfirst(kernel::traductor()->trans('agenda_cursadas.turno'));
		$titulo['AULA_NOMBRE'] = ucfirst(kernel::traductor()->trans('agenda_cursadas.aula'));
		$titulo['VCEDIFICIODESC'] = ucfirst(kernel::traductor()->trans('agenda_cursadas.edificio'));
		$titulo['TIPO_CLASE_DESC'] = ucfirst(kernel::traductor()->trans('agenda_cursadas.tipo'));
		$titulo['SEDE_DISPLAY'] = ucfirst(kernel::traductor()->trans('agenda_cursadas.sede'));
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
		foreach($datos as $id => $dato) {
			if ($todo or ($i <= $reg_por_pagina && $id >= $minimo && $id < $maximo)){
				$nuevo[$i] = $dato;
				$i++;
			}
		}
		return $nuevo;
	}

	function get_datos()
	{
		if (!isset($this->datos_consulta)) {
			$parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
			$this->datos_consulta = catalogo::consultar('docente', 'agenda_cursadas', $parametros);
		}
		return $this->datos_consulta;
	}

	/**
	 * Retorna la cantidad de datos
	 * @return entero
	 */
	protected function get_total_registros(){
		 return count($this->get_data_reporte(1, true));
	}

	public function get_nombre_archivo(){
		return "agenda_cursadas";
	}

	public function generar_pdf(){
		$pdf = $this->get_generador_pdf();
		$pdf->set_font($this->pdf_fuente);
		$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 750, 'width' => 750, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => $this->get_opciones_reporte_pdf()));
		$pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 500, 'width' => 500));
		$pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
		$pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
		$pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
		$pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
		$pdf->set_encabezado_img($this->pdf_encabezado_img["img"], $this->pdf_encabezado_img["width"]);

		$data_bruto = $this->datos_pdf();

		$titulos = $this->titulos_pdf();

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

		$corte = $this->get_corte();
		if (!empty($corte)){
			$corte_campo = $corte['campo'];
		} else {
			$corte_campo = false;
		}

		$data_final = array();
		foreach($data_bruto as $num => $linea){
			$renglon = array();
			foreach ($linea as $key => $value){
				if ($key != "URL_LINEA" && $key != "detalle"){
					$renglon[$key] = $value;
				}
			}
			$data_final[$num] = $renglon;
			unset($renglon);
		}
		$data_bruto = $data_final;

		// si hay corte de control
		if ($corte_campo){
			// genero el corte
			$data = $this->corte_de_control($data_bruto);

			// ordeno titulos
			$titulos_corte = array();
			foreach($titulos as $key => $title){
				if ($key != $corte_campo){
					$titulos_corte[$key] = $title;
				}
			}
			$titulos = $titulos_corte;
			unset($titulos_corte);
			
			foreach($data as $clave => $linea){
				if (is_numeric($clave)){
					$mensaje_pie = "";
					$tabla = array();
					if (isset($linea['funciones_pie_corte'])){
						$funciones = array();
						foreach($linea['funciones_pie_corte'] as $key_func => $func){
							foreach($titulos as $key => $titulo){
								$funciones[$key_func][$key] = $linea['funciones_pie_corte'][$key_func][$key];
							}
						}
						$linea['funciones_pie_corte'] = $funciones;
						unset($funciones);
						$tabla = array_merge($linea['datos'], $linea['funciones_pie_corte']);
					}
					else
					{
						$tabla = $linea['datos'];
					}

					$pdf->agregar_tabla($tabla,$titulos,$linea['titulo_corte']);
					if (isset($linea['mensaje_pie_corte'])){
						$mensaje_pie = "";
						foreach($linea['mensaje_pie_corte'] as $mensaje){
							$mensaje_pie .= "\n".$mensaje."\n";
						}
						$pdf->agregar_texto($mensaje_pie);
					}
				}
			}

			if (isset($data['funciones_pie_reporte'])){
				$tabla = array();
				$funciones = array();
				foreach($data['funciones_pie_reporte'] as $key_func => $func){
					foreach($titulos as $key => $title){
						$funciones[$key_func][$key] = $data['funciones_pie_reporte'][$key_func][$key];
					}
				}

				$data['funciones_pie_reporte'] = $funciones;
				unset($funciones);
				$tabla = $data['funciones_pie_reporte'];
				$pdf->agregar_tabla($tabla,$titulos,"");
			}

			if (isset($data['mensaje_pie_reporte'])){
				$mensaje_pie_reporte = "";
				foreach($data['mensaje_pie_reporte'] as $mensaje){
					$mensaje_pie_reporte .= "\n".$mensaje."\n";
				}
				$pdf->agregar_texto($mensaje_pie_reporte);
			}
		}
		else
		{
			$pdf->agregar_tabla($data_bruto,$titulos,'');
		}
		$pdf->set_nombre_archivo($this->get_nombre_archivo());
		$pdf->generar();
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
		
		$titulo = kernel::traductor()->trans('agenda_de_cursadas');
		$titulo .= " - ".\siu\guarani::persona()->get_nombre();
		
		$excel->agregar_tabla($data_bruto,$titulos, $titulo);
		$excel->set_nombre_archivo($this->get_nombre_archivo());
		$excel->generar();
	}
}
?>