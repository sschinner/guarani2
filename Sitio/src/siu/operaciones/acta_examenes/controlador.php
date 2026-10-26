<?php
namespace siu\operaciones\acta_examenes;

use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\u;
use kernel\util\validador;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;

class controlador extends \siu\operaciones\_comun\operaciones\reporte\controlador
{
	protected $acta;
	protected $tipo_acta;
	public $hash_turno;
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
		$hash_acta = $this->validate_param('acta', 'get', validador::TIPO_ALPHANUM);
		$this->acta = $this->buscar_acta($hash_acta);
		$this->tipo_acta = $this->validate_param('tipo_acta', 'get', validador::TIPO_ALPHANUM);

		$clase = 'operaciones\acta_examenes\pagelet_acta';
		$pl = kernel::localizador()->instanciar($clase, 'items');
		$this->vista()->add_pagelet($pl);

		/* url botón Volver */
		$operacion = kernel::ruteador()->get_id_operacion();
		$pl->data['url_back'] = kernel::vinculador()->crear($operacion);
		$pl->data['generar_pdf'] = kernel::vinculador()->crear($operacion, 'generar_pdf_acta', array('acta'=>$hash_acta, 'tipo_acta'=>$this->tipo_acta));
		$pl->data['generar_xls'] = kernel::vinculador()->crear($operacion, 'generar_xls_acta', array('acta'=>$hash_acta, 'tipo_acta'=>$this->tipo_acta));
		$pl->data['alumnos'] = $this->get_info_acta();
	}

	function get_info_acta(){
		$parametros = array('tipo_acta' => $this->tipo_acta, 'acta' => $this->acta);
		$datos = catalogo::consultar('docente', 'detalle_acta_examen', $parametros);
		return $datos;
	}

	function accion__filtrar(){
		$filtros = array();
		$filtros['anio_academico'] = $this->get_anio_by_id($this->validate_param('filtro_anio', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true)));
		$this->hash_turno = $this->validate_param('filtro_turno_examen', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
		$filtros['turno'] = $this->get_turno_by_id($this->hash_turno);
		$filtros['nombre'] = $this->validate_param('filtro_nombre_materia', 'get', validador::TIPO_TEXTO, array('allowempty' => true));

		$pagelet = $this->vista()->pagelet('items');
		$pagelet->set_filtros($filtros);
		kernel::renderer()->add($pagelet);
	}
	
	private function get_turno_by_id($id){
		$te = catalogo::consultar('unidad_academica', 'turnos_examen');
		
		foreach($te as $turno){
			if ($turno['_ID_'] == $id){
				return $turno['TURNO_EXAMEN'];
			}
		}
		return null;
	}
	
	private function get_anio_by_id($id){
		$aa = catalogo::consultar('unidad_academica', 'anios_academicos');
		
		foreach($aa as $anio){
			if ($anio['_ID_'] == $id){
				return $anio['ANIO_ACADEMICO'];
			}
		}
		return null;
	}
	
	function accion__buscar_turnos(){
		$anio = $this->get_anio_by_id($this->validate_param('anio', 'post', validador::TIPO_ALPHANUM));
		
		$turnos = catalogo::consultar('unidad_academica', 
										'buscar_turnos_examen', 
										array('anio' => $anio)
										);
		$this->render_raw_json($turnos);
	}
	
	private function buscar_acta($hash_acta)
	{
		$parametros = array(
							'nro_inscripcion' => kernel::persona()->get_nro_inscripcion(), 
							'anio_academico' => null,
							'turno' => null,
							'nombre' => null,
						);
		$datos = catalogo::consultar('docente', 'acta_examenes', $parametros);
		foreach($datos as $dato){
			if ($dato['URL_ACTA'] == $hash_acta){
				return $dato['ACTA'];
			}
		}
		return false;
	}
	
	public function accion__generar_pdf_acta(){
		$hash_acta = $this->validate_param('acta', 'get', validador::TIPO_ALPHANUM);
		$this->acta = $this->buscar_acta($hash_acta);
		$this->tipo_acta = $this->validate_param('tipo_acta', 'get', validador::TIPO_ALPHANUM);
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
		$this->pdf_encabezado = array($universidad, '<b><u>ACTA DE EXAMEN</u></b>', 112);
		$pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
		
		$logo = kernel::localizador()->encontrar_img('www/img','logo.png');
		$pdf->set_encabezado_img($logo['path'], '100');

		$titulos = $this->titulos_exportacion_acta();
		$datos_encabezado = array(
								'cant_columnas' => 2,
								'datos' => array(0 => ucfirst($this->trans('info_materia.materia')).": ".$data['ENCABEZADO']['MATERIA'],
												 1 => ucfirst($this->trans('info_materia.acta')).": ".$data['ENCABEZADO']['ACTA'],
												 2 => ucfirst($this->trans('anio_academico')).": ".$data['ENCABEZADO']['ANIO_ACAD'],
												 3 => ucfirst($this->trans('fecha')).": ".$data['ENCABEZADO']['FECHA'],
												 4=> ucfirst($this->trans('turno_examen')).": ".$data['ENCABEZADO']['TURNO'],
												 5 => ucfirst($this->trans('mesa_examen')).": ".$data['ENCABEZADO']['MESA'],
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
		
		$n= 0;
		foreach($data['CUERPO'] as $folio => $alumnos){
			$data_alumnos = array();
			$n=$n+1;
			foreach($alumnos as $alumno){
				$alumno['FOLIO'] = $folio;
				$alumno['CONDICION'] = substr($alumno['CONDICION'],0,1);
				$alumno['NOTA'] = !empty($alumno['NOTA_NUM'])? $alumno['NOTA_NUM']:"";
				$data_alumnos[] = $alumno;
			}
			$pdf->agregar_texto("");
			$pdf->agregar_tabla($data_alumnos, $titulos, '');
			if($n < $data['ENCABEZADO']['FOLIO'])
			{
				$pdf->salto_pagina();	
			}
		}
		$pdf->set_nombre_archivo('acta_examen');
		$pdf->generar();
	}
	
	protected function crear_ezpdf(){
		require_once "ezpdf/class.ezpdf.php";
		$instancia = new \Cezpdf($this->pdf_hoja, 'portrait');
		return $instancia;
	}
	
	public function accion__generar_xls_acta(){
		$excel = $this->get_generador_excel();
		$hash_acta = $this->validate_param('acta', 'get', validador::TIPO_ALPHANUM);
		$this->acta = $this->buscar_acta($hash_acta);
		$this->tipo_acta = $this->validate_param('tipo_acta', 'get', validador::TIPO_ALPHANUM);
		
		$institucion = guarani::ua()->get_nombre_institucion();
		$facultad = guarani::ua()->get_nombre();
		
		$excel->agregar_texto_sin_enter($institucion,1);
		$excel->agregar_texto($facultad,1);
		$estilo_titulo = array(
 			'font' => array('bold' => true),
 		);
		$excel->agregar_texto_estilos('ACTA DE EXAMEN',1, $estilo_titulo);
		$data = $this->get_info_acta();
		$excel->agregar_texto_sin_enter(ucfirst($this->trans('info_materia.materia')).": ".$data['ENCABEZADO']['MATERIA'],1);
		$excel->agregar_texto_sin_enter(ucfirst($this->trans('info_materia.acta')).": ".$data['ENCABEZADO']['ACTA'],1);
		$excel->agregar_texto_sin_enter(ucfirst($this->trans('anio_academico')).": ".$data['ENCABEZADO']['ANIO_ACAD'],1);
		$excel->agregar_texto_sin_enter(ucfirst($this->trans('fecha')).": ".$data['ENCABEZADO']['FECHA'],1);
		$excel->agregar_texto_sin_enter(ucfirst($this->trans('turno_examen')).": ".$data['ENCABEZADO']['TURNO'],1);
		$excel->agregar_texto_sin_enter(ucfirst($this->trans('mesa_examen')).": ".$data['ENCABEZADO']['MESA'],1);
		$excel->agregar_texto_sin_enter(ucfirst($this->trans('libro')).": ".$data['ENCABEZADO']['LIBRO'],1);
		$excel->agregar_texto_sin_enter(ucfirst($this->trans('plan.estado')).": ".$data['ENCABEZADO']['ESTADO_ACTA'],1);
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
		

		$excel->set_nombre_archivo('acta_examen');
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
			'CONDICION' => 'Cond.',
			'NOTA' => ucfirst($this->trans('nota')),
			'RESULTADO' => ucfirst($this->trans('resultado')),
			'CONCEPTO' => ucfirst($this->trans('concepto')),

		);
		return $titulos;
	}
}
?>