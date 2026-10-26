<?php
namespace siu\operaciones\_comun\operaciones\reporte;

require_once "ezpdf/class.ezpdf.php";

use kernel\kernel;
use siu\guarani;
use kernel\util\u;

class generador_pdf {

    //Documentación:
    //http://pdf-php.sourceforge.net/pdf-php-code/readme.php

	protected $datacreator = array ('Title'=>'', 'Author'=>'', 'Subject'=>'', 'Creator'=>'', 'Producer'=>'');
        protected $options = array();
        protected $text_options = array();
        protected $encabezado = array("titulo" => "", "subtitulo" => "", "margen" => "","imagen" => "", "imagen_with" => "");
        protected $instancia;
        protected $font = "Courier.afm";
        protected $font_path = "";
        protected $pdf_fuente_texto = 10;
        protected $pdf_fuente_titulo = 10;
        protected $pdf_fuente_subtitulo = 12;
        protected $nombre_archivo = "file";
        protected $tiene_encabezado = false;
        protected $tiene_encabezado_M = false;
        protected $tiene_encabezado_long = false;
		protected $encabezado_reporte = "";
		protected $encabezado_tabla = null;
		protected $encabezado_tabla2 = null;

	function __construct($instancia = null) {
		if ($instancia === null) {
			$this->instancia = new \Cezpdf('a4');
		} else {
			$this->instancia = $instancia;
		}
		
		$this->font_path = guarani::dir()."/lib/ezpdf/fonts/";
				
		$this->instancia->ezStartPageNumbers((int) ($this->instancia->ez['pageWidth'] / 2),22,10,'left','{PAGENUM} de {TOTALPAGENUM}',1);
		$this->instancia->ezStartPageNumbers((int) ($this->instancia->ez['pageWidth'] - $this->instancia->ez['leftMargin'] - $this->instancia->ez['rightMargin']),22,9,'left',date('d/m/Y H:i:s'),1);
		$this->instancia->ezSetMargins('120','50','40','40');
	}

	public function set_doc_title($title = ""){
		$this->datacreator['Title'] = $title;
	}

	public function set_doc_author($author = ""){
		$this->datacreator['Author'] = $author;
	}

	public function set_doc_subject($subject = ""){
		$this->datacreator['Subject'] = $subject;
	}

	public function set_doc_creator($creator = ""){
		$this->datacreator['Creator'] = $creator;
	}

	public function set_doc_producer($producer){
		$this->datacreator['Producer'] = $producer;
	}
	
	public function set_font($font = ""){
		if (isset($font)){
			if (\kernel\util\manejador_archivos::existe_archivo_en_path($this->font_path.$font)){
				$this->font = $font;				
			}
		}
		$this->instancia->selectFont($this->font_path.$this->font);
	}

	public function set_pdf_fuente_texto($nro = 0){
		$this->pdf_fuente_texto = $nro;
	}

	public function set_pdf_fuente_titulo($nro = 0){
		$this->pdf_fuente_titulo = $nro;
	}
	
	public function set_pdf_fuente_subtitulo($nro = 0){
		$this->pdf_fuente_subtitulo = $nro;
	}
	
	public function set_options($options = array()){
		$this->options = $options;
	}

	public function set_text_options($options = array()){
		$this->text_options = $options;
	}

	public function set_encabezado($titulo = "", $subtitulo = "", $margen = 0){
		$this->encabezado["titulo"] = $titulo;
		$this->encabezado["subtitulo"] = $subtitulo;
		$this->encabezado["margen"] = $margen;
	}

	public function set_tiene_encabezado($tiene_encabezado = false){
		$this->tiene_encabezado = $tiene_encabezado;
	}
	
	public function set_tiene_encabezado_M($tiene_encabezado_M = false){
		$this->tiene_encabezado_M = $tiene_encabezado_M;
	}
	
	public function set_tiene_encabezado_long($tiene_encabezado_long = false){
		$this->tiene_encabezado_long = $tiene_encabezado_long;
	}

	public function set_encabezado_reporte($encabezado){
		$this->encabezado_reporte = $encabezado;
	}

	public function set_encabezado_tabla($encabezado){
		$this->encabezado_tabla = $encabezado;
	}
	
	public function set_encabezado_tabla2($encabezado){
		$this->encabezado_tabla2 = $encabezado;
	}
	
	public function set_encabezado_img($path = "", $width =""){
		$this->encabezado["imagen"] = $path;
		$this->encabezado["imagen_with"] = $width;
	}

	public function agregar_tabla($datos = array(), $columnas = array(), $titulo = ""){
		$this->instancia->ezTable($datos,$columnas,$titulo,$this->options);
	}

	public function agregar_texto($title = "")
	{
        //Devuelve la posicion Y del puntero de escritura luego de haber agregado el texto.
		return $this->instancia->ezText($title,$this->pdf_fuente_texto, $this->text_options);
	}

    public function agregar_img($path, $pad = 5, $width = 0, $resize = 'full', $just = 'center', $border = '')
    {
        $this->instancia->ezImage($path, $pad, $width, $resize, $just, $border);
    }

    public function agregar_img_png_desde_archivo($path_img_file, $x, $y, $w=0, $h=0)
    {
        $this->instancia->addPngFromFile($path_img_file, $x, $y, $w, $h);
    }

    public function agregar_img_jpeg_desde_archivo($path_img_file, $x, $y, $w=0, $h=0)
    {
        $this->instancia->addJpegFromFile($path_img_file, $x, $y, $w, $h);
    }

	public function set_nombre_archivo($nombre) {
		$this->nombre_archivo = $nombre;
	}

    protected function preparar_pdf(){
        // Datos del documento
        $this->instancia->addInfo($this->datacreator);
        // Encabezados
        foreach ($this->instancia->ezPages as $pageNum => $id) {
            $this->instancia->reopenObject($id);

            $yPos = (int) $this->instancia->ez['pageHeight'] - $this->instancia->ez['topMargin'] / 2;
            if($this->tiene_encabezado){
                $yPos = (int) $this->instancia->ez['pageHeight'] - $this->instancia->ez['topMargin'] /3;
            }
            if($this->tiene_encabezado_M){
                $yPos = (int) $this->instancia->ez['pageHeight'] - $this->instancia->ez['topMargin'] /8;
            }
            if($this->tiene_encabezado_long){
                $yPos = (int) $this->instancia->ez['pageHeight'] - $this->instancia->ez['topMargin'] /20;
            }

            $xPos = (int) $this->instancia->ez['pageWidth'] - $this->instancia->ez['leftMargin'] - $this->instancia->ez['rightMargin'] - 15;

            $this->instancia->ezSetY($yPos);
            $this->instancia->ezImage($this->encabezado["imagen"], 0, $this->encabezado["imagen_with"], "none", "left");

            $this->instancia->ezSetY($yPos+$this->pdf_fuente_titulo+5);

            $this->instancia->ezText($this->encabezado["titulo"], $this->pdf_fuente_titulo, array('left' => $this->encabezado["margen"], 'width' => $xPos, 'maxWidth' => $xPos, 'spacing'=> 1));
			
            //$this->instancia->ezSetY($yPos - 35 - $this->pdf_fuente_subtitulo);
			$this->instancia->ezSetY($yPos + $this->pdf_fuente_subtitulo-20);
            $this->instancia->ezText($this->encabezado["subtitulo"], $this->pdf_fuente_subtitulo, array('width' => $xPos, 'maxWidth' => $xPos, 'justification' => 'center', 'spacing'=> 2));

            if ($this->tiene_encabezado){
				if (isset($this->encabezado_tabla)){
					$this->instancia->ezSetY($yPos+$this->pdf_fuente_titulo-48);
					$this->agregar_tabla_encabezado($this->encabezado_tabla["cant_columnas"], $this->encabezado_tabla["datos"]);
					if(isset($this->encabezado_tabla2))
					{
					//$this->instancia->ezSetY($yPos+$this->pdf_fuente_titulo);
					$this->agregar_tabla_encabezado($this->encabezado_tabla2["cant_columnas"], $this->encabezado_tabla2["datos"]);						
					}
				}else{					
					$this->instancia->ezText($this->encabezado_reporte, $this->pdf_fuente_texto, array('left' => 0, 'width' => $xPos, 'maxWidth' => $xPos, 'spacing'=> 1));
				}	
            }
            $this->instancia->closeObject();
        }
    }

	public function generar() 
	{
        $this->preparar_pdf();
		$options['compress'] = 1;
		$options['Content-Disposition'] = $this->nombre_archivo;
		$contenido = $this->instancia->ezStream($options);
		$longitud = filesize($contenido);
	}

    public function genera_output()
    {
        $this->preparar_pdf();
        $options['compress'] = 1;
        $options['Content-Disposition'] = $this->nombre_archivo;
        return $this->instancia->ezOutput();
    }

    public function dejar_espacio($espacio)
    {
        $this->instancia->ezSetDY($espacio);
    }
    
    public function posY($posY)
    {
       $this->instancia->ezSetY($posY);
    }
    
    public function salto_pagina()
    {
       $this->instancia->ezNewPage();
    }
	
	public function agregar_tabla_encabezado($columnas_cant,$datos = array())
	{
		$xPos = (int) $this->instancia->ez['pageWidth'] - $this->instancia->ez['leftMargin'] - $this->instancia->ez['rightMargin'] - 15;
		$options = array('showHeadings' => 0, 'shaded'=>0,'showLines'=>0, 'fontSize' => $this->pdf_fuente_texto, 'maxWidth' => $xPos, 'width' => $xPos, 'rowGap' => 1);
		$columnas = array();
		for($i= 1; $i<=$columnas_cant; $i++){
			$columnas[$i] = $i;
		}
		$cant_filas = round(sizeof($datos)/$columnas_cant);
		$datos_encabezado = array();

		$fila	= 1;
		$col	= 1;
		$indice = 0;
		while($fila <= $cant_filas) {
			while($col <= $columnas_cant){
				$datos_encabezado[$fila][$col] = $datos[$indice];
				$indice++;
				$col++;
			}
			$fila++;
			$col = 1;
		};
		$this->instancia->ezTable($datos_encabezado,$columnas,'',$options);
	}
	

}
?>