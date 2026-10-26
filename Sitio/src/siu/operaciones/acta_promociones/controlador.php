<?php
namespace siu\operaciones\acta_promociones;

use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\validador;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;

class controlador extends \siu\operaciones\_comun\operaciones\reporte\controlador
{
    protected $acta;
	public $hash_per_lec;
	protected $pdf_hoja = "A4";
	protected $pdf_encabezado = array("", "");
	protected $pdf_encabezado_img = array("img" => "", "width" => "");
	protected $pdf_fuente = "Courier.afm";
	protected $pdf_fuente_texto = 9;
	protected $pdf_fuente_titulo = 9;
	protected $pdf_fuente_subtitulo = 12;
	protected $tiene_encabezado = true;
	protected $tiene_encabezado_long = true;
	protected $encabezado_reporte = "";

    function accion__info_acta()
    {
        $this->acta = $this->validate_param('accion', 'get', validador::TIPO_ALPHANUM);
        $clase = 'operaciones\acta_promociones\pagelet_acta';
		$pl = kernel::localizador()->instanciar($clase, 'items');
        $this->vista()->add_pagelet($pl);

		/* url botón Volver */
		$operacion = kernel::ruteador()->get_id_operacion();
		$pl->data['url_back'] = kernel::vinculador()->crear($operacion);
		$pl->data['generar_pdf'] = kernel::vinculador()->crear($operacion, 'generar_pdf_acta', array('acta'=>$this->acta));
		$pl->data['generar_xls'] = kernel::vinculador()->crear($operacion, 'generar_xls_acta', array('acta'=>$this->acta));			
        $pl->data['alumnos'] = $this->get_info_acta();        
    }

    function get_info_acta(){
        $parametros = array('acta' => $this->acta);
		$datos = catalogo::consultar('docente', 'detalle_acta_promociones', $parametros);
        return $datos;
    }

	function accion__filtrar(){
		$filtros = array();
        $filtros['anio_academico'] = $this->get_anio_by_id($this->validate_param('filtro_anio', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true)));
		$this->hash_per_lec = $this->get_param('filtro_per_lectivo', 'get');
        $filtros['periodo_lectivo'] = $this->get_per_lec_by_id($this->hash_per_lec);
        $filtros['nombre'] = $this->validate_param('filtro_nombre_materia', 'get', validador::TIPO_TEXTO, array('allowempty' => true));
        $pagelet = $this->vista()->pagelet('items');
		$pagelet->set_filtros($filtros);
        kernel::renderer()->add($pagelet);
    }
//    function accion__filtrar(){
//		$filtros = array();
//        $filtros['anio_academico'] = $this->get_param('filtro_anio', 'get');
//        $filtros['periodo_lectivo'] = $this->get_param('filtro_per_lectivo', 'get');
//        $filtros['nombre'] = $this->get_param('filtro_nombre_materia', 'get');
//        $pagelet = $this->vista()->pagelet('items');
//		$pagelet->set_filtros($filtros);
//        kernel::renderer()->add($pagelet);
//    }
	
	private function get_anio_by_id($id){
		$aa = catalogo::consultar('unidad_academica', 'anios_academicos');

		foreach($aa as $anio){
			if ($anio['_ID_'] == $id){
				return $anio['ANIO_ACADEMICO'];
			}
		}
		return null;
	}
	
	private function get_per_lec_by_id($id){
		$pl = catalogo::consultar('unidad_academica', 'periodos_lectivos');
		
		foreach($pl as $periodo){
			if ($periodo['_ID_'] == $id){
				return $periodo['PERIODO_LECTIVO'];
			}
		}
		return null;
	}
	
	function accion__buscar_periodos_lectivos(){
		$anio = $this->get_anio_by_id($this->validate_param('anio', 'post', validador::TIPO_ALPHANUM));
		
		$periodos = catalogo::consultar('unidad_academica', 
										'buscar_periodos_lectivos', 
										array('anio' => $anio)
										);
		$this->render_raw_json($periodos);
	}
	
	/*ACTAS PDF Y EXCEL*/
	public function accion__generar_pdf_acta(){
		$this->acta = $this->validate_param('acta', 'get', validador::TIPO_ALPHANUM);
		$data = $this->get_info_acta();

		$pdf = new generador_pdf($this->crear_ezpdf());

		$pdf->set_font($this->pdf_fuente);
		$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 500, 'width' => 570, 'fontSize' => $this->pdf_fuente_texto,'shaded'=> 0, 'showLines'=> 2,'cols' => array('RENGLON'=> array('width'=>30), 'LEGAJO'=> array('width'=>60), 'CONDICION'=> array('width'=>37), 'NOTA'=> array('width'=>32, 'justification'=>'right'),'RESULTADO'=> array('width'=>83), 'FECHA'=> array('width'=>70),'CONCEPTO'=> array('width'=>90))));
		$pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 500, 'width' => 500));
		$pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
		$pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
		$pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
		$pdf->set_tiene_encabezado($this->tiene_encabezado);
		$pdf->set_tiene_encabezado_long($this->tiene_encabezado_long);
		$universidad = "\n".guarani::ua()->get_nombre_institucion()."\n".guarani::ua()->get_nombre()."\n";
		$this->pdf_encabezado = array($universidad, '<b><u>ACTA DE PROMOCIÓN</u></b>', 112);
		$pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
		
		$logo = kernel::localizador()->encontrar_img('www/img','logo.png');
		$pdf->set_encabezado_img($logo['path'], '100');

		$titulos = $this->titulos_exportacion_acta();
		
		$datos_encabezado = array(
								'cant_columnas' => 2,
								'datos' => array(0 => ucfirst($this->trans('info_materia.materia')).": ".$data['ENCABEZADO']['MATERIA'],
												 1 => ucfirst($this->trans('info_materia.acta')).": ".$data['ENCABEZADO']['ACTA'],
												 2 => ucfirst($this->trans('anio_academico')).": ".$data['ENCABEZADO']['ANIO_ACAD'],
												 3 => "Folios: ".$data['ENCABEZADO']['FOLIOS'],
												 4 => "Período Lectivo: ".$data['ENCABEZADO']['PER_LEC'],
												 5 => "Comisión: ".$data['ENCABEZADO']['COMISION_NOMBRE']." (".$data['ENCABEZADO']['COMISION'].")",
												 6 => ucfirst($this->trans('libro')).": ".$data['ENCABEZADO']['LIBRO'],
												 7 => ucfirst($this->trans('plan.estado')).": ".$data['ENCABEZADO']['ESTADO_ACTA'],
												 )
										);	
		$datos_encabezado2 = array(
								'cant_columnas' => 1,
								'datos' => array(0 => "Docentes: ".$data['ENCABEZADO']['DOCENTES'],
												 1 => ucfirst($this->trans('observaciones')).": ".$data['ENCABEZADO']['OBS']
												 )
										);
		$pdf->set_encabezado_tabla($datos_encabezado);
		$pdf->set_encabezado_tabla2($datos_encabezado2);
		$pdf->agregar_texto("");
		$n= 0;
		foreach($data['CUERPO'] as $folio => $alumnos){
			$data_alumnos = array();
			$n=$n+1;
			foreach($alumnos as $alumno){
				$alumno['FOLIO'] = $folio;
				$alumno['CONDICION'] = !empty($alumno['CONDICION'])? substr($alumno['CONDICION'],0,1):"";
				$alumno['NOTA'] = !empty($alumno['NOTA_NUM'])? $alumno['NOTA_NUM']:"";
				$data_alumnos[] = $alumno;
			}
			$pdf->agregar_texto("");
			$pdf->agregar_tabla($data_alumnos, $titulos, '');
			if($n < $data['ENCABEZADO']['FOLIOS'])
			{
				$pdf->salto_pagina();	
			}
		}
		$pdf->set_nombre_archivo('acta_promocion');
		$pdf->generar();
	}
	
	protected function crear_ezpdf(){
		require_once "ezpdf/class.ezpdf.php";
		$instancia = new \Cezpdf($this->pdf_hoja, 'portrait');
		return $instancia;
	}
	
	public function accion__generar_xls_acta(){
		$excel = $this->get_generador_excel();
		$this->acta = $this->validate_param('acta', 'get', validador::TIPO_ALPHANUM);
		$data = $this->get_info_acta();

		$institucion = guarani::ua()->get_nombre_institucion();
		$facultad = guarani::ua()->get_nombre();
		
		$excel->agregar_texto_sin_enter($institucion,1);
		$excel->agregar_texto($facultad,1);
		$estilo_titulo = array(
 			'font' => array('bold' => true),
 		);
		$excel->agregar_texto_estilos('ACTA DE PROMOCIÓN',1, $estilo_titulo);
		$data = $this->get_info_acta();

		$excel->agregar_texto_sin_enter(ucfirst($this->trans('info_materia.materia')).": ".$data['ENCABEZADO']['MATERIA'],1);
		$excel->agregar_texto_sin_enter(ucfirst($this->trans('info_materia.acta')).": ".$data['ENCABEZADO']['ACTA'],1);
		$excel->agregar_texto_sin_enter(ucfirst($this->trans('anio_academico')).": ".$data['ENCABEZADO']['ANIO_ACAD'],1);
		$excel->agregar_texto_sin_enter("Folios: ".$data['ENCABEZADO']['FOLIOS'],1);
		$excel->agregar_texto_sin_enter("Período Lectivo: ".$data['ENCABEZADO']['PER_LEC'],1);
		$excel->agregar_texto_sin_enter("Comisión: ".$data['ENCABEZADO']['COMISION_NOMBRE']." (".$data['ENCABEZADO']['COMISION'].")",1);
		$excel->agregar_texto_sin_enter("Libro: ".$data['ENCABEZADO']['LIBRO'],1);
		$excel->agregar_texto_sin_enter("Estado: ".$data['ENCABEZADO']['ESTADO_ACTA'],1);
		$excel->agregar_texto_sin_enter("Docentes: ".$data['ENCABEZADO']['DOCENTES'],1);
		$excel->agregar_texto_sin_enter(ucfirst($this->trans('observaciones')).": ".$data['ENCABEZADO']['OBS'],1);
		$excel->agregar_texto(" ",1);
		
		$titulos = $this->titulos_exportacion_acta();
		$n= 0;

		foreach($data['CUERPO'] as $folio => $alumnos){
			$data_alumnos = array();
			$n=$n+1;
			foreach($alumnos as $alumno){
				$alumno['FOLIO'] = $folio;
				$alumno['CONDICION'] = !empty($alumno['CONDICION'])? substr($alumno['CONDICION'],0,1):"";
				$alumno['NOTA'] = !empty($alumno['NOTA_NUM'])? $alumno['NOTA_NUM']:"";
				$data_alumnos[] = $alumno;
			}
			
			$excel->agregar_texto_sin_enter('Folio '.$n,1);	
			$excel->agregar_tabla($data_alumnos,$titulos,'');
			$excel->agregar_texto(" ",1);
		}
		

		$excel->set_nombre_archivo('acta_promocion');
		$excel->generar();
	}
	
	protected function get_generador_excel()
	{
		return new generador_excel();
	}
	
	public function titulos_exportacion_acta(){
		$titulos = array(
			//'FOLIO' => ucfirst($this->trans('folio')),
			'RENGLON' => "N°",
			'LEGAJO' => ucfirst($this->trans('legajo')),
			'APE_NOM' => ucfirst($this->trans('apellido_y_nombre')),
			'FECHA' => ucfirst($this->trans('fecha')),
			'NOTA' => ucfirst($this->trans('nota')),
			'RESULTADO' => ucfirst($this->trans('resultado'))
		);
		return $titulos;
	}	
}
?>