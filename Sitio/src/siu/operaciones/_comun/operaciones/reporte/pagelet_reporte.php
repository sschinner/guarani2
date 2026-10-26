<?php
namespace siu\operaciones\_comun\operaciones\reporte;

use kernel\interfaz\pagelet;
use siu\guarani;
use kernel\kernel;
use kernel\util\u;

abstract class pagelet_reporte extends pagelet{	
	// Variables de navegacion
	private $registros_por_pagina = 15;
	protected $pagina = 1;
	protected $columna;
	protected $orden;
	private $corte = false;

	protected $columnas_reporte = array();

	// Callbacks dentro de cada corte de control
	protected $funciones_pie_corte = array();
	protected $mensaje_pie_corte = array();

	// Callbacks al final del documento
	protected $funciones_pie_reporte = array();
	protected $mensaje_pie_reporte = array();
	
	protected $pdf_hoja = "A4";
	protected $pdf_hoja_orientacion = "portrait";
//	protected $pdf_encabezado = array("", "");
//	protected $pdf_encabezado_img = array("img" => "", "width" => "");
//	protected $pdf_fuente = "";
	protected $pdf_fuente_texto = 10;
	protected $pdf_fuente_titulo = 10;
	protected $pdf_fuente_subtitulo = 12;
	protected $ancho_hoja = 500;
    protected $tiene_encabezado = false;
	protected $encabezado_reporte = "";	
	protected $titulo_reporte = "";	
	protected $encabezado_reporte_excel = array();
	protected $encabezado_tabla = null;
	
	public function get_nombre(){
		return 'reporte';
	}

	function __construct($id){
		parent::__construct($id);
		$this->rpp = $this->get_rpp();
		$this->configurar();
	}

	abstract protected function configurar();

	abstract protected function get_data_reporte($inicio = 0, $todo = false);

	abstract protected function get_total_registros();
	
	abstract protected function get_columnas();
	
	/**
	 * Configura las columnas del reporte
	 * @param array $columnas 
	 * Columnas del reporte
	 * $columnas = array(
	 * 					'col1' => 'Titulo Col1', 
	 * 					'col2' => 'Titulo Col2', 
	 * 					'col3' => 'Titulo Col3', 
	 * 					'col4' => array(
	 *							'Titulo Col4', 
	 *							array('justification'=>'left','width'=>100,'link'=><linkColName>, 'ordenable' => true)
	 * 						)
	 * 					);
	 */
	public function set_columnas_reporte($columnas){
		$this->columnas_reporte = $columnas;		
	}

	/**
	 * Configura la cantidad de lineas por defecto que va a mostrar por página el reporte
	 * @param entero $cant 
	 */
	public function set_rpp($cant = 0){
		$this->registros_por_pagina = $cant;
	}

	/**
	 * Retorna los registros por pagina por defecto
	 * @return integer
	 */
	protected function get_rpp(){
		return $this->registros_por_pagina;
	}
	
	public function ver_pagina($pagina = 1, $columna = null , $orden = null){
		$this->pagina = $pagina;
		$this->columna = $columna;
		$this->orden = $orden;
		
	}
	
	public function inicio(){
		return $this->fin() - $this->get_rpp();
	}
	
	public function fin(){
		return $this->get_rpp() * $this->get_pagina();
	}

	public function get_pagina(){
		return $this->pagina;
	}

	public function agregar_corte($campo = null, $titulo = ''){
		if (isset($campo)){
			$this->corte['campo'] = $campo;
			$this->corte['titulo'] = $titulo;
		}
	}

	public function get_corte(){
		return $this->corte;
	}

	public function corte_de_control($datos){
		$corte = $this->get_corte();
		$corte_campo = $corte['campo'];
		$corte_titulo = $corte['titulo'];
		$columnas = $this->get_columnas();
		$res = array();
		foreach ($columnas as $col => $val){
			if (is_array($val)){
				$res[$col] = $val[0];
			} else {
				$res[$col] = $val;
			}
		}
		$columnas = $res;
		unset($res);
		
		$corte_resultado = array();
		if($corte && $datos){
			// Ordeno el arreglo por el campo de corte
			$count = count($datos);			
			for($i=0; $i<=$count; $i++){
				for($j=$count-1; $j>$i; $j=$j-1){
					if (isset($datos[$j][$corte_campo]) && isset($datos[$j-1][$corte_campo]) && $datos[$j][$corte_campo] < $datos[$j-1][$corte_campo]){
						$tmp = $datos[$j];
						$datos[$j] = $datos[$j-1];
						$datos[$j-1] = $tmp;
						unset($tmp);
					}
				}
			}

			// Encabezados
			$titulos = array();
			foreach($columnas as $key => $value){
				if ($key != $corte_campo){
					$titulos[$key] = $value;
				}
			}

			// Datos
			$orden_cortes = 0;
			if (!isset($datos[0][$corte_campo])){
				$datos[0][$corte_campo] = "";
			}

			$valor_tmp = $datos[0][$corte_campo];
			$titulo_tmp = str_replace('{{valor}}', $valor_tmp, $corte_titulo);
			$titulo_tmp = str_replace("{{columna}}", $corte_campo, $titulo_tmp);
			$corte_resultado[$orden_cortes]['titulo_corte'] = $titulo_tmp;
			unset($titulo_tmp);
			unset($valor_tmp);
			$corte_resultado[$orden_cortes]['titulos'] = $titulos;

			$orden_datos = 0;
			foreach($columnas as $key => $value){
				if ($key != $corte_campo){
					if (isset($datos[0][$key])){
						$corte_resultado[$orden_cortes]['datos'][$orden_datos][$key] = $datos[0][$key];
					} else {
						$corte_resultado[$orden_cortes]['datos'][$orden_datos][$key] = "";
					}
				}
			}

			if (isset($datos[0]['URL_LINEA'])){
				$corte_resultado[$orden_cortes]['datos'][$orden_datos]['URL_LINEA'] = $datos[0]['URL_LINEA'];
			}

			for($k=1; $k < $count; $k++){
				// Si el registro es distinto del anterior le agrego los encabezados
				if (isset($datos[$k-1][$corte_campo]) && isset($datos[$k][$corte_campo]) && $datos[$k-1][$corte_campo] != $datos[$k][$corte_campo]){
					$orden_cortes++;
					
					$valor_tmp = $datos[$k][$corte_campo];
					$titulo_tmp = str_replace('{{valor}}', $valor_tmp, $corte_titulo);
					$titulo_tmp = str_replace("{{columna}}", $corte_campo, $titulo_tmp);
					$corte_resultado[$orden_cortes]['titulo_corte'] = $titulo_tmp;
					unset($titulo_tmp);
					unset($valor_tmp);					
					$corte_resultado[$orden_cortes]['titulos'] = $titulos;

					$orden_datos = 0;
				}
				else
				{
					$orden_datos++;
				}
				
				foreach($columnas as $key => $value){
					if ($key != $corte_campo){
						$corte_resultado[$orden_cortes]['datos'][$orden_datos][$key] = $datos[$k][$key];						
					}
				}
				
				if (isset($datos[$k]['URL_LINEA'])){
					$corte_resultado[$orden_cortes]['datos'][$orden_datos]['URL_LINEA'] = $datos[$k]['URL_LINEA'];
				}
			}
			
			// Callbacks pie de corte
			$cant_cortes = count($corte_resultado);
			for($j = 0; $j < $cant_cortes; $j++){
				foreach ($this->funciones_pie_corte as $funcion)
				{
					$datos_parametro[0] = $corte_resultado[$j]['datos'];
					$parametros = array_merge($datos_parametro, $funcion['parametros']);

					$corte_resultado[$j]['funciones_pie_corte'][] = call_user_func($funcion['funcion'], $parametros);
					unset($parametros);
				}

				foreach ($this->mensaje_pie_corte as $funcion)
				{
					$datos_parametro[0] = $corte_resultado[$j]['datos'];
					$corte_resultado[$j]['mensaje_pie_corte'][] = call_user_func($funcion['funcion'], $datos_parametro[0]);						
				}
			}

			// Callback pie de reporte
			$datos_tmp = $datos;
			foreach ($this->funciones_pie_reporte as $funcion)
			{
					$datos_parametro[0] = $datos_tmp;
					$parametros = array_merge($datos_parametro, $funcion['parametros']);

					$corte_resultado['funciones_pie_reporte'][] = call_user_func($funcion['funcion'], $parametros);

					unset($parametros);
			}

			foreach ($this->mensaje_pie_reporte as $funcion)
			{
					$datos_parametro[0] = $datos_tmp;
					$corte_resultado['mensaje_pie_reporte'][] = call_user_func($funcion['funcion'], $datos_parametro[0]);
			}
			unset($datos_tmp);

			return $corte_resultado;
		} else {
			return false;
		}
	}

	/**
	 * Configura una funcion que se aplicara al final de cada corte de control
	 * @param array $funcion
	 * array(
	 *			'0' => controlador, 
	 *			'1' => metodo
	 *		)
	 *		
	 * @param array $parametros
	 * array('0' => array(datos), 
	 *			'1' => array(columnas), 
	 *			'2' => string(mensaje), 
	 *			'3' => string(col_mensaje)
	 *		)
	 */
	protected function agregar_funcion_pie_corte($funcion, $parametros){
		$afuncion = array($this, $funcion);
		$this->funciones_pie_corte[] = array('funcion' => $afuncion, 'parametros' => $parametros);
		unset($afuncion);
	}

	/**
	 * Configura una funcion que se aplicara al final de cada corte de control y se mostrara en el pie de cada corte. Se mostrara como un texto.
	 * @param string $funcion
	 */
	protected function agregar_mensaje_pie_corte($funcion){
		$afuncion = array($this, $funcion);
		$this->mensaje_pie_corte[] = array('funcion' => $afuncion);
		unset($afuncion);
	}

	/**
	 * Configura una funcion que se aplicara al final de cada reporte
	 * @param array $funcion
	 * array(
	 *		'0' => controlador, 
	 *		'1' => metodo
	 *		)
	 * @param array $parametros
	 * array(
	 *		'0' => array(datos), 
	 *		'1' => array(columnas), 
	 *		'2' => string(mensaje), 
	 *		'3' => string(col_mensaje)
	 * )
	 */
	protected function agregar_funcion_pie_reporte($funcion, $parametros){		
		$afuncion = array($this, $funcion);
		$this->funciones_pie_reporte[] = array('funcion' => $afuncion, 'parametros' => $parametros);
		unset($afuncion);
	}

	/**
	 * Configura una funcion que se aplicara al final del reporte y se mostrara en el pie de pagina como texto
	 * @param string $funcion
	 */
	protected function agregar_mensaje_pie_reporte($funcion){
		$afuncion = array($this, $funcion);
		$this->mensaje_pie_reporte[] = array('funcion' => $afuncion);
		unset($afuncion);
	}

	public function prepare() {
		$pagina = $this->get_pagina();
		
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->data['url_atributos'] = kernel::vinculador()->crear($operacion, 'ver_pagina', array('pagina'=>$pagina));
		
		$rpp = $this->get_rpp();
		$columnas = $this->get_columnas();
		
		$atributos = array();
		$res = array();
		foreach ($columnas as $col => $val){
			if (is_array($val)){
				$res[$col] = $val[0];
				if (isset($val[1]) && isset($val[1]['ordenable'])){
					$atributos[$col]['asc'] = kernel::vinculador()->crear($operacion, 'ver_pagina', array('pagina'=>$pagina, 'col' => $col,'ord' =>'asc'));
					$atributos[$col]['desc'] = kernel::vinculador()->crear($operacion, 'ver_pagina', array('pagina'=>$pagina, 'col' => $col,'ord' =>'desc'));
				}
			} else {
				$res[$col] = $val;
			}
		}
		$this->data['atributos_titulos'] = $atributos;
		$columnas = $res;
		unset($res);

		$corte = $this->get_corte();
		if (isset($corte)){
			$corte_campo = $corte['campo'];
		} else {
			$corte_campo = false;
		}

		if ($corte_campo)
		{
			$this->data['corte']['campo'] = $corte_campo;
			$this->data['datos_corte'] = $this->corte_de_control($this->get_data_reporte(0, true));
			$this->data['cantidad_columnas'] = count($columnas) -1;
			$this->data['titulos'] = $columnas;
		}
		else
		{
			$this->data['corte']['campo'] = false;
			$this->data['datos'] = $this->get_data_reporte($pagina);
			$this->data['titulos'] = $columnas;
			$this->data['cantidad_columnas'] = count($columnas);
		}

		// Callback pie de reporte
		$datos_tmp = $this->get_data_reporte(0, true);
		foreach ($this->funciones_pie_reporte as $funcion)
		{
			$datos_parametro[0] = $datos_tmp;
			$parametros = array_merge($datos_parametro, $funcion['parametros']);
			$this->data['funciones_pie_reporte'][] = call_user_func($funcion['funcion'], $parametros);
			unset($parametros);
		}

		foreach ($this->mensaje_pie_reporte as $funcion)
		{
			$datos_parametro[0] = $datos_tmp;
			$this->data['mensaje_pie_reporte'][] = call_user_func($funcion['funcion'], $datos_parametro[0]);						
		}
		unset($datos_tmp);

		$operacion = kernel::ruteador()->get_id_operacion();
		$this->data['pagina'] = $pagina;
		$this->data['url']['generar_pdf'] = kernel::vinculador()->crear($operacion, 'generar_pdf');
		$this->data['url']['generar_excel'] = kernel::vinculador()->crear($operacion, 'generar_excel');
		$this->data['url']['index'] = kernel::vinculador()->crear($operacion, 'index');		
		$this->data['cant_por_pagina'] = $rpp;
	}

	public function get_paginas() {
		$pagina = $this->get_pagina();
		$operacion = kernel::ruteador()->get_id_operacion();
		$count = $this->get_total_registros();
		
		// paginado
		$pag_fin = 10;
		$cant_paginas = \ceil($count/$this->get_rpp());

		if (($pagina - 5) < 0){
			$pag_inicio = 0;
		}
		else
		{
			$pag_inicio = ($pagina - 5);
		}

		if (($pagina + 5) < $cant_paginas){
			$pag_fin = ($pagina + 5);
		}
		else
		{
			$pag_fin = $cant_paginas;
		}

		$paginas = array();
		for($i = 0; $i < $cant_paginas; $i++){			
			if (($i+1) >= $pag_inicio && ($i+1) <= $pag_fin)
			{
				$atributos = array();
				$atributos['pagina'] = $i+1;
				$atributos['col'] = $this->columna;
				$atributos['ord'] = $this->orden;
				$paginas[$i + 1] = kernel::vinculador()->crear($operacion, 'ver_pagina', $atributos);
			}
		}
		unset($pag_fin);
		unset($pag_inicio);

		return $paginas;
	}

	public function get_opciones_reporte_pdf(){
		$columnas = $this->columnas_reporte;
		
		$tmp = array();
		foreach($columnas as $key => $columna){
			if (is_array($columna)){
				$tmp[$key] = $columna[1];
			}
		}
		return $tmp;
	}

	/**
	 * Configura el tamaño de la hoja.
	 * @param string $tamaño 
	 * 4A0, 2A0, A0, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, B0, B1, B2, B3, B4, B5, B6, B7, B8, B9, B10, C0, C1, C2, C3, C4, C5, C5, C6, C7, C8, C9, C10, RA0, RA1, RA2, RA3, RA4, SRA0, SRA1, SRA2, SRA3, SRA4, LETTER, LEGAL, EXECUTIVE, FOLIO
	 */
	public function set_pdf_hoja($tamano = "a4", $orientacion = 'portrait'){
		$this->pdf_hoja = $tamano;
		$this->pdf_hoja_orientacion = $orientacion;
	}

	/**
	 * Configura titulo y subtitulo del pdf
	 * @param string $titulo
	 * @param string $subtitulo
	 */
	public function set_pdf_encabezado($titulo = "", $subtitulo = "", $margin = 0){
		$this->pdf_encabezado[0] = $titulo;
		$this->pdf_encabezado[1] = $subtitulo;
		$this->pdf_encabezado[2] = $margin;
	}

	/**
	 * Configura la imágen del encabezado del pdf
	 * @param string $img
	 * Path a la imagen
	 * @param string $width
	 * Ancho de la imagen
	 */
	public function set_pdf_encabezado_img($img = "", $width = ""){
		$this->pdf_encabezado_img["img"] = $img;
		$this->pdf_encabezado_img["width"] = $width;
	}

	/**
	 * Configura la fuente del pdf
	 * @param string $fuente
	 * Helvetica.afm, Courier.afm, Symbol.afm, ZapfDingbats.afm, Times-Roman.afm, Times-Bold.afm, Times-BoldItalic.afm, Times-Italic.afm, Helvetica-Bold.afm, Helvetica-BoldOblique.afm, Helvetica-Oblique.afm, Courier-Bold.afm, Courier-BoldOblique.afm, Courier-Oblique.afm	
	 */
	public function set_pdf_fuente($fuente = ""){
		$this->pdf_fuente = $fuente;
	}

	/**
	 * Tamaño de fuente de los textos del pdf
	 * @param entero $nro
	 */
	public function set_pdf_fuente_texto($nro = 0){
		$this->pdf_fuente_texto = $nro;
	}

	/**
	 * Tamaño de fuente del titulo del pdf
	 * @param entero $nro
	 */
	public function set_pdf_fuente_titulo($nro = 0){
		$this->pdf_fuente_titulo = $nro;
	}

	/**
	 * Tamaño de fuente del subtitulo del pdf
	 * @param entero $nro
	 */
	public function set_pdf_fuente_subtitulo($nro = 0){
		$this->pdf_fuente_subtitulo = $nro;
	}
	
	public function set_tiene_encabezado($tiene_encabezado = false){
		$this->tiene_encabezado = $tiene_encabezado;
	}

	public function set_encabezado_reporte($encabezado){
		$this->encabezado_reporte = $encabezado;
	}

	public function set_titulo_reporte($titulo){
		$this->titulo_reporte = $titulo;		
	}	

	public function set_encabezado_reporte_excel($encabezado){
		$this->encabezado_reporte_excel = $encabezado;
	}

	protected function crear_ezpdf($posicion_hoja = null){		
		$instancia = new \Cezpdf($this->pdf_hoja, $posicion_hoja);
		return $instancia;
	}

	protected function get_generador_pdf()
	{
		require_once (realpath(guarani::dir()."/operaciones/_comun/operaciones/reporte/generador_pdf.php"));
		return new \siu\operaciones\_comun\operaciones\reporte\generador_pdf($this->crear_ezpdf($this->pdf_hoja_orientacion));
	}

	public function generar_pdf(){
		$this->width_options($this->pdf_hoja_orientacion);
		$pdf = $this->get_generador_pdf();
		$pdf->set_font($this->pdf_fuente);
		$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => $this->ancho_hoja, 'width' => $this->ancho_hoja, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => $this->get_opciones_reporte_pdf()));
		$pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => $this->ancho_hoja, 'width' => $this->ancho_hoja));
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
		$pdf->set_encabezado_tabla($this->encabezado_tabla);
//                $pdf->posY(720);              
                $pdf->agregar_texto("");
                
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
	
	public function get_nombre_archivo(){
		return "file";
	}

	protected function get_generador_excel()
	{
		require_once (realpath(guarani::dir()."/operaciones/_comun/operaciones/reporte/generador_excel.php"));
		return new \siu\operaciones\_comun\operaciones\reporte\generador_excel();
	}

	public function generar_excel(){
		$excel = $this->get_generador_excel();
		$data_bruto = $this->datos_excel();
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
				$excel->agregar_texto_sin_enter($renglon,1);
			}
		}
			
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

		// si hay corte de control
		if ($corte_campo){
			// genero el corte
			$data = $this->corte_de_control($data_bruto);

			// ordeno titulos
			$restitles = array();
			foreach($titulos as $key => $title){
				if ($key != $corte_campo && $key != "URL_LINEA"){
					$restitles[$key] = $title;
				}
			}
			$titulos = $restitles;

			$cant_titulos = 0;
			if (!empty($titulos)){
				$cant_titulos = count($titulos);
			}

			unset($restitles);
						
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

					$excel->agregar_tabla($tabla,$titulos,$linea['titulo_corte']);

					if (isset($linea['mensaje_pie_corte'])){
						$mensaje_pie = "";
						foreach($linea['mensaje_pie_corte'] as $mensaje){
							$mensaje_pie .= $mensaje;
						}
						$excel->agregar_texto($mensaje_pie, $cant_titulos);
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
				$excel->agregar_tabla($tabla,$titulos);
			}

			if (isset($data['mensaje_pie_reporte'])){
				$mensaje_pie_reporte = "";
				foreach($data['mensaje_pie_reporte'] as $mensaje){
					$mensaje_pie_reporte .= $mensaje;
				}
				$excel->agregar_texto($mensaje_pie_reporte, $cant_titulos);
			}
		}
		else
		{
			$excel->agregar_tabla($data_bruto,$titulos);
		}
		$excel->set_nombre_archivo($this->get_nombre_archivo());
		$excel->generar();
	}

	public function datos_excel(){
		return $this->get_data_reporte(0,true);
	}

	public function titulos_excel(){
		return $this->get_columnas();
	}

	public function datos_pdf(){
		return $this->get_data_reporte(0,true);
	}

	public function titulos_pdf(){
		return $this->get_columnas();
	}
	
	public function membrete($subtitulo = "") {
//		$universidad = guarani::ua()->get_nombre_institucion().' - '.guarani::ua()->get_nombre()."\n ";
		$universidad = guarani::ua()->get_nombre_institucion()."\n".guarani::ua()->get_nombre()."\n";
		$this->pdf_encabezado = array($universidad, '<b><u>'.$subtitulo.'</u></b>', 110);
		
	}
	
	public function membrete_excel($excel) {
		$institucion = guarani::ua()->get_nombre_institucion();
		$facultad = guarani::ua()->get_nombre();
		$excel->agregar_texto_sin_enter($institucion,1);
		$excel->agregar_texto($facultad,1);	
	}
	
	public function width_options($orientacion = 'portrait'){
		if ($orientacion == 'landscape'){
			$this->ancho_hoja = 800;
		}
		
	}
	
	public function set_encabezado_tabla($encabezado){
		$this->encabezado_tabla = $encabezado;
	}
		
}
?>