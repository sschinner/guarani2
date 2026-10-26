<?php
namespace siu\operaciones\estado_titulo;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;

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
		$this->set_pdf_encabezado(kernel::traductor()->trans('header.menu.estado_titulo'), "", 112);
		$logo = kernel::localizador()->encontrar_img('www/img','logo.png');
		$this->set_pdf_encabezado_img($logo['path'], "100");
		$this->set_pdf_fuente("Courier.afm");
		$this->set_pdf_fuente_texto(10);
		$this->set_pdf_fuente_titulo(13);
		$this->set_pdf_fuente_subtitulo(11);
		$this->set_pdf_hoja("a4");
		$this->set_titulo_reporte(kernel::traductor()->trans('header.menu.estado_titulo'));
	}

	public function get_columnas(){
		$titulo = array();
		$titulo['fecha'] = "Fecha";
		$titulo['expediente'] = "Expediente";
		$titulo['estado'] = "Estado del trámite";
		$titulo['prom_c_aplazos'] = "Promedio con aplazos";
		$titulo['prom_s_aplazos'] = "Promedio sin aplazos";
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
		$reg_por_pagina = $this->get_rpp();
		$pagina = $this->get_pagina();

		$minimo = ($pagina - 1) * $reg_por_pagina;
		$maximo = $minimo + $reg_por_pagina;

		$datos = $this->get_data();
		
		$nuevo = array();
		$i=0;
		foreach($datos as $id => $dato) {
			if ($todo or ($i <= $reg_por_pagina && $id >= $minimo && $id < $maximo)){
				$nuevo[$i]['fecha'] = $dato['fecha'];
				$nuevo[$i]['expediente'] = $dato['expediente'];
				$nuevo[$i]['estado'] = $dato['estado'];
				$nuevo[$i]['prom_c_aplazos'] = $dato['prom_c_aplazos'];
				$nuevo[$i]['prom_s_aplazos'] = $dato['prom_s_aplazos'];
				$i++;
			}
		}
		return $nuevo;
	}

	public function get_encabezado(){
		$datos = $this->get_data();
		if (!empty($datos)){
			$encabezado = array();
			$encabezado['carrera'] = $datos[0]['carrera'];
			$encabezado['legajo'] = $datos[0]['legajo'];
			$encabezado['plan'] = $datos[0]['plan'];
			$encabezado['titulo'] = $datos[0]['titulo'];
			$encabezado['fecha_egreso'] = $datos[0]['fecha_egreso'];
			$encabezado['fecha_jura'] = $datos[0]['fecha_jura'];
			return $encabezado;
		}
		return false;
	}

	protected function get_data(){
		if (!isset($this->datos_consulta)) {
			$parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
			$this->datos_consulta = catalogo::consultar('alumno', 'estado_titulo', $parametros);
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

	public function get_nombre_archivo()
	{
		return "estado_titulo";
	}

	protected function get_generador_pdf()
	{
		return new generador_pdf($this->crear_ezpdf($this->pdf_hoja_orientacion));
	}
	
	public function generar_pdf(){
		$pdf = $this->get_generador_pdf();
		$pdf->set_font($this->pdf_fuente);
		$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 500, 'width' => 500, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => $this->get_opciones_reporte_pdf()));
		$pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 500, 'width' => 500));
		$pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
		$pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
		$pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);		
		$pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
		$pdf->set_encabezado_img($this->pdf_encabezado_img["img"], $this->pdf_encabezado_img["width"]);

		$data_bruto = $this->get_data_reporte(0,true);		
		$titulos = $this->get_columnas();
		
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
		
		
		// enacabezado
		$datos_encabezado = $this->get_encabezado();
		$pdf->agregar_texto("Carrera: ".$datos_encabezado['carrera']);
		$pdf->agregar_texto("Legajo: ".$datos_encabezado['legajo']);
		$pdf->agregar_texto("Plan: ".$datos_encabezado['plan']);
		$pdf->agregar_texto("Título: ".$datos_encabezado['titulo']);
		$pdf->agregar_texto("Fecha egreso: ".$datos_encabezado['fecha_egreso']);
		$pdf->agregar_texto("Fecha jura: ".$datos_encabezado['fecha_jura']);
		$pdf->agregar_texto("");
		
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
}
?>