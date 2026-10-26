<?php
namespace siu\operaciones\inscriptos_cursadas;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;


class pagelet_comision extends \siu\operaciones\_comun\operaciones\reporte\pagelet_reporte {
	public $filtros = array('filtro' => 'T'); //T= Todas, C= Con Inscripciones, S= Sin Inscripciones
    protected $pdf_hoja = "A4";
    protected $pdf_encabezado = array("", "");
    protected $pdf_encabezado_img = array("img" => "", "width" => "");
    protected $pdf_fuente = "Courier.afm";
    protected $pdf_fuente_texto = 10;
    protected $pdf_fuente_titulo = 10;
    protected $pdf_fuente_subtitulo = 12;
    protected $tiene_encabezado = true;
    protected $encabezado_reporte = "";	
	
	public function get_nombre(){
        return 'comision';
    }

	public function prepare() {
		parent::prepare();
		$operacion = kernel::ruteador()->get_id_operacion();
		$this->data['url']['generar_pdf'] = kernel::vinculador()->crear($operacion, 'generar_pdf_comision', array('c'=>$this->controlador->comision, 's'=>$this->controlador->subcomision));
		$this->data['url']['generar_excel'] = kernel::vinculador()->crear($operacion, 'generar_excel_comision', array('c'=>$this->controlador->comision, 's'=>$this->controlador->subcomision));
    }
	
	function configurar(){
		$this->set_rpp(15);
        
		$this->set_columnas_reporte($this->get_columnas());
		//$encabezado = $this->get_encabezado();
		
		// Configuracion pdf
		$this->set_pdf_encabezado(kernel::traductor()->trans("tit_inscriptos_cursada"), "", 112);
		$this->set_pdf_fuente("Courier.afm");
		$this->set_pdf_fuente_texto(10);
		$this->set_pdf_fuente_titulo(10);
		$this->set_pdf_fuente_subtitulo(12);
		$this->set_pdf_hoja("a4");
		$this->set_tiene_encabezado(true);
	}
	
	public function get_columnas(){
		$titulo = array();        
        $titulo['LEGAJO'] = "Legajo";
        $titulo['ALUMNO'] = "Alumno";
        $titulo['CALIDAD'] = "Calidad";
        $titulo['ESTADO'] = "Estado";
        $titulo['CARRERA'] = "Carrera";
		
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
		$datos = $this->controlador->get_info_comision();

		$i = 0;
		$nuevo = array();
		foreach($datos as $id => $dato) {
			if ($todo or ($i <= $reg_por_pagina && $id >= $minimo && $id < $maximo)){
				$nuevo[$i]['LEGAJO'] = $dato['LEGAJO'];
				$nuevo[$i]['ALUMNO'] = $dato['ALUMNO'];
				$nuevo[$i]['CALIDAD'] = $dato['CALIDAD'];
				$nuevo[$i]['ESTADO'] = $dato['ESTADO'];
				$nuevo[$i]['CARRERA'] = $dato['CARRERA'];
				$nuevo[$i]['MATERIA'] = '('.$dato['MATERIA_COD'].') '.$dato['MATERIA'];
				//$nuevo[$i]['SEDE'] = '('.$dato['SEDE_COD'].') '.$dato['SEDE'];
				$nuevo[$i]['COMISION'] = $dato['COMISION'];
				$nuevo[$i]['SUBCOMISION'] = $dato['SUBCOMISION_NOMBRE'];
				$nuevo[$i]['CATEDRA'] = $dato['CATEDRA'];
				$nuevo[$i]['ANIO'] = $dato['ANIO'];
				$nuevo[$i]['PER_LEC'] = $dato['PER_LEC'];
				$i++;
			}
		}
		return $nuevo;
	}

	public function get_encabezado(){
		$datos = $this->controlador->get_info_comision();
		
		if (!empty($datos)){
			$encabezado = array();
			$encabezado['MATERIA_COD']	= $datos[0]['MATERIA_COD'];		
			$encabezado['MATERIA_NOMBRE']	= $datos[0]['MATERIA'];		
			//$encabezado['SEDE'] = $datos[0]['SEDE'];	
			$encabezado['COMISION_NOMBRE']	= $datos[0]['COMISION'];
			$encabezado['SUBCOMISION_NOMBRE']	= $datos[0]['SUBCOMISION_NOMBRE'];
			$encabezado['CATEDRA'] = $datos[0]['CATEDRA'];				
			$encabezado['ANIO'] = $datos[0]['ANIO'];	
			$encabezado['PERIODO_LECTIVO'] = $datos[0]['PER_LEC'];	
			return $encabezado;	
		}
		return false;
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
	
	protected function get_generador_pdf()
	{
		return new generador_pdf($this->crear_ezpdf($this->pdf_hoja_orientacion));
	}
	
	public function generar_pdf(){
		$pdf = new generador_pdf($this->crear_ezpdf());
		$pdf->set_font($this->pdf_fuente);
        $pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 750, 'width' => 750, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => array('LEGAJO'=> array('width'=>110))));
        $pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 750, 'width' => 750));
        $pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
        $pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
        $pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
        $pdf->set_tiene_encabezado($this->tiene_encabezado);
		$pdf->set_nombre_archivo($this->get_nombre_archivo());

		$encabezado = $this->get_encabezado();
		if(!empty($encabezado['SUBCOMISION_NOMBRE']))
		{
			$datos_encabezado = array(
									'cant_columnas' => 2,
									'datos' => array(0 => "Materia: ".$encabezado['MATERIA_NOMBRE']." (".$encabezado['MATERIA_COD'].")",
														//1 => "Sede: ".$encabezado['SEDE'],
														1 => "Comisión: ".$encabezado['COMISION_NOMBRE']."   Subcomisión: ".$encabezado['SUBCOMISION_NOMBRE'],
														2 => "Año: ".$encabezado['ANIO'],
														3 => "Período Lectivo: ".$encabezado['PERIODO_LECTIVO'],
													)
									);			
		}else
		{
			$datos_encabezado = array(
									'cant_columnas' => 2,
									'datos' => array(0 => "Materia: ".$encabezado['MATERIA_NOMBRE']." (".$encabezado['MATERIA_COD'].")",
														//1 => "Sede: ".$encabezado['SEDE'],
														1 => "Comisión: ".$encabezado['COMISION_NOMBRE'],
														2 => "Año: ".$encabezado['ANIO'],
														3 => "Período Lectivo: ".$encabezado['PERIODO_LECTIVO'],
													)
									);				
		}

         $pdf->set_encabezado_tabla($datos_encabezado);
		 $universidad = guarani::ua()->get_nombre_institucion()."\n".guarani::ua()->get_nombre()."\n";
         $logo = kernel::localizador()->encontrar_img('www/img','logo.png');
		 $this->pdf_encabezado = array($universidad, '<b><u>Inscripciones a Cursadas</u></b>', 110);
		
		$pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
		if (!empty($this->pdf_encabezado_img["img"])){
			$pdf->set_encabezado_img($this->pdf_encabezado_img["img"], $this->pdf_encabezado_img["width"]);
		} else {
			$logo = kernel::localizador()->encontrar_img('www/img','logo.png');
			$pdf->set_encabezado_img($logo['path'], "100");
		}
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
		$pdf->agregar_texto('');
		$pdf->agregar_tabla($data_bruto,$titulos,'');
		$pdf->generar();
	}

    protected function crear_ezpdf()
	{
      $instancia = new \Cezpdf($this->pdf_hoja, 'landscape');
      return $instancia;
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

       $institucion = guarani::ua()->get_nombre_institucion();
       $facultad = guarani::ua()->get_nombre();

       $excel->agregar_texto_sin_enter($institucion,1);
       $excel->agregar_texto($facultad,1);
       $estilo_titulo = array(
                        'font' => array('bold' => true),
                );
        $excel->agregar_texto_estilos('Inscripciones a Cursadas',1, $estilo_titulo);	

		// enacabezado
		$datos_encabezado = $this->get_encabezado();
		$excel->agregar_texto_sin_enter("Materia: ".$datos_encabezado['MATERIA_NOMBRE']." (".$datos_encabezado['MATERIA_COD'].")", 1);
		//$excel->agregar_texto_sin_enter("Sede: ".$datos_encabezado['SEDE'],1);
		$excel->agregar_texto_sin_enter("Comisión: ".$datos_encabezado['COMISION_NOMBRE'],1);
		if(!empty($datos_encabezado['SUBCOMISION_NOMBRE'])){
			$excel->agregar_texto_sin_enter("Subomisión: ".$datos_encabezado['SUBCOMISION_NOMBRE'],1);
		}		
		$excel->agregar_texto_sin_enter("Cátedra: ".$datos_encabezado['CATEDRA'],1);
		$excel->agregar_texto_sin_enter('Año: '.$datos_encabezado['ANIO'],1);
		$excel->agregar_texto_sin_enter("Período Lectivo: ".$datos_encabezado['PERIODO_LECTIVO'],1);

		$excel->agregar_tabla($data_bruto,$titulos);
		$excel->set_nombre_archivo($this->get_nombre_archivo());
		$excel->generar();
	}	
}
?>