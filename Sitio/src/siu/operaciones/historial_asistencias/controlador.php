<?php
namespace siu\operaciones\historial_asistencias;

use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use kernel\util\validador;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;

class controlador extends \siu\operaciones\_comun\operaciones\reporte\controlador
{
	private $hash = null;

	function accion__asistencias()
	{
		$this->hash = $this->validate_param('hash', 'get', validador::TIPO_ALPHANUM);

		$parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
		$parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
		$comisiones = catalogo::consultar('alumno', 'comisiones_subcomisiones_inscripto', $parametros);

		$comision = $comisiones[$this->hash][3];
		$nombre_comision = $comisiones[$this->hash][12];
		$subcomision = null;
		if (!is_null($comisiones[$this->hash]))
			{
				$subcomision = $comisiones[$this->hash][19];
			};

		$parametros = array(
			'carrera' => kernel::persona()->get_id_carrera_activa(),
			'legajo' => kernel::persona()->get_id_legajo_activo(),
			'comision' =>  $comision,
			'subcomision' => $subcomision,
			'clases' => 'T' //pClases: T=Todas / V = Vigentes (fecha menor o igual a hoy)
		);

		$datos = catalogo::consultar('alumno', 'rep_historial_de_asistencias', $parametros);
		$clase = 'operaciones\historial_asistencias\pagelet_asistencias';
		$pl = kernel::localizador()->instanciar($clase, 'items');
		$this->vista()->add_pagelet($pl);
		$pl->hash = $this->hash;
		$pl->data['nombre_comision'] = $nombre_comision;
		$pl->data['datos'] = $datos;
	}

	protected function get_generador_pdf()
	{
		return new generador_pdf($this->crear_ezpdf('landscape'));
	}

	protected function crear_ezpdf($posicion_hoja = null)
	{
		$instancia = new \Cezpdf("a4", $posicion_hoja);
		return $instancia;
	}

	function accion__generar_pdf()
	{
		$this->hash = $this->validate_param('hash', 'get', validador::TIPO_ALPHANUM);

		$datos = $this->datos_exportacion();
		$encabezado = $this->encabezado_reporte();

		$pdf = $this->get_generador_pdf();
		$pdf->set_font("Courier.afm");
		$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 750, 'width' => 750, 'fontSize' => 10, 'shadeCol' => array(0.8,0.8,0.8), 'cols' => array('clase_fecha'=>array('width'=>85), 'cant_inasistencias'=>array('width'=>90), 'cant_justificadas'=>array('width'=>90))));
		$pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 750, 'width' => 750));
		$pdf->set_tiene_encabezado(true);
		$pdf->set_tiene_encabezado_M(true);
		
		$nombre_reporte = kernel::traductor()->trans('header.menu.historial_asistencias');
		$logo = kernel::localizador()->encontrar_img('www/img','logo.png');
		$pdf->set_encabezado_img($logo['path'], "100");
		$pdf->set_encabezado($encabezado['institucion']."\n".$encabezado['facultad'], '<b><u>'.$nombre_reporte.'</b></u>', 110);
		
		if(is_null($datos['subcomision_nombre']))
		{
			$datos_encabezado = array(
									'cant_columnas' => 2,
									'datos' => array(0 => $this->trans('historial_asistencia.carrera').': '.$datos['carrera_nombre'],
													1 => $this->trans('historial_asistencia.materia').':'.$datos['materia_nombre'].' ('.$datos['materia'].')',
													2 => $this->trans('historial_asistencia.legajo').': '.$datos['legajo'],
													3 => $this->trans('historial_asistencia.ape_nombres').': '.$datos['apellido'].', '.$datos['nombres'],
													4 => $this->trans('historial_asistencia.anio_academico').': '.$datos['anio_academico'],
													5 => $this->trans('historial_asistencia.periodo_lectivo').': '.$datos['periodo_lectivo'],
													6 => $this->trans('historial_asistencia.comision').': '.$datos['comision_nombre']
													)
									);			
		}
		else
		{	
			$datos_encabezado = array(
									'cant_columnas' => 2,
									'datos' => array(0 => $this->trans('historial_asistencia.carrera').': '.$datos['carrera_nombre'],
													1 => $this->trans('historial_asistencia.materia').':'.$datos['materia_nombre'].' ('.$datos['materia'].')',
													2 => $this->trans('historial_asistencia.legajo').': '.$datos['legajo'],
													3 => $this->trans('historial_asistencia.ape_nombres').': '.$datos['apellido'].', '.$datos['nombres'],
													4 => $this->trans('historial_asistencia.anio_academico').': '.$datos['anio_academico'],
													5 => $this->trans('historial_asistencia.periodo_lectivo').': '.$datos['periodo_lectivo'],
													6 => $this->trans('historial_asistencia.comision').': '.$datos['comision_nombre'],
													7 => $this->trans('historial_asistencia.subcomision').': '.$datos['subcomision_nombre'],
													)
									);
		};
		$datos_encabezado2 = array(
								'cant_columnas' => 3,
								'datos' => array(0 => "Inasistencias permitidas",
												 1 => $this->trans('historial_asistencia.porc_regu').': '.$datos['porc_asist_regular'].'%',
												 2 => $this->trans('historial_asistencia.porc_prom').': '.$datos['porc_asist_promocion'].'%'
												 )
										);

		$pdf->set_encabezado_tabla($datos_encabezado);
		$pdf->set_encabezado_tabla2($datos_encabezado2);

		$pdf->agregar_texto('');
		$pdf->agregar_texto('');
		$pdf->agregar_tabla($datos['clases'],$this->get_columnas(),'');
		$pdf->agregar_texto(' ');
		$pdf->agregar_texto('<b><u>Totales</b></u>');
		$pdf->agregar_texto('<b>Clases</b>: '.$datos['cant_clases'].'			'.'<b>Inasistencias</b>: '.$datos['cant_inasistencias'].'			'.'<b>Justificadas</b>: '.$datos['cant_justificadas']);
		$pdf->set_nombre_archivo('historial_asistencias');
		$pdf->generar();
	}

	protected function get_generador_excel()
	{
		return new generador_excel();
	}

	function accion__generar_xls()
	{
		$this->hash = $this->validate_param('hash', 'get', validador::TIPO_ALPHANUM);

		$datos = $this->datos_exportacion();
		$encabezado = $this->encabezado_reporte();

		$excel = $this->get_generador_excel();
		$excel->agregar_texto_sin_enter($encabezado['institucion'],1);
		$excel->agregar_texto($encabezado['facultad'],1);
		$estilo_titulo = array(
 			'font' => array('bold' => true),
 		);
		$excel->agregar_texto_estilos('Historial de Asistencias',1, $estilo_titulo);
		$excel->agregar_texto_sin_enter($this->trans('historial_asistencia.carrera').': '.$datos['carrera_nombre'],1);
		$excel->agregar_texto_sin_enter($this->trans('historial_asistencia.materia').': '.$datos['materia_nombre'].' ('.$datos['materia'].')',1);
		$excel->agregar_texto_sin_enter($this->trans('historial_asistencia.legajo').': '.$datos['legajo'],1);
		$excel->agregar_texto_sin_enter($this->trans('historial_asistencia.ape_nombres').': '.$datos['apellido'].', '.$datos['nombres'],1);
		$excel->agregar_texto_sin_enter($this->trans('historial_asistencia.anio_academico').': '.$datos['anio_academico'],1);
		$excel->agregar_texto_sin_enter($this->trans('historial_asistencia.periodo_lectivo').': '.$datos['periodo_lectivo'],1);
		$excel->agregar_texto_sin_enter($this->trans('historial_asistencia.comision').': '.$datos['comision_nombre'],1);
		if(!is_null($datos['subcomision_nombre'])){
			$excel->agregar_texto_sin_enter($this->trans('historial_asistencia.subcomision').': '.$datos['subcomision_nombre'],1);
		};
		$excel->agregar_texto_sin_enter("Inasistencias permitidas",1);
		$excel->agregar_texto_sin_enter($this->trans('historial_asistencia.porc_regu').': '.$datos['porc_asist_regular'].'%',1);
		$excel->agregar_texto_sin_enter($this->trans('historial_asistencia.porc_prom').': '.$datos['porc_asist_promocion'].'%',1);

		$excel->agregar_tabla($datos['clases'],$this->get_columnas());
		$excel->agregar_texto_sin_enter(' ',1);
		$excel->agregar_texto_estilos('Totales',1, $estilo_titulo);
		$excel->agregar_texto_sin_enter('Clases: '.$datos['cant_clases'],1);
		$excel->agregar_texto_sin_enter('Inasistencias: '.$datos['cant_inasistencias'],1);
		$excel->agregar_texto_sin_enter('Justificadas: '.$datos['cant_justificadas'],1);

		$excel->set_nombre_archivo('historial_asistencias');
		$excel->generar();
	}

	function datos_exportacion() 
	{
		$parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
		$parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
		$comisiones = catalogo::consultar('alumno', 'comisiones_subcomisiones_inscripto', $parametros);

		$comision = $comisiones[$this->hash][3];
		$subcomision = null;
		if (!is_null($comisiones[$this->hash]))
			{
				$subcomision = $comisiones[$this->hash][19];
			};

		$parametros = array(
			'carrera' => kernel::persona()->get_id_carrera_activa(),
			'legajo' => kernel::persona()->get_id_legajo_activo(),
			'comision' =>  $comision,
			'subcomision' => $subcomision,
			'clases' => 'T' //pClases: T=Todas / V = Vigentes (fecha menor o igual a hoy)
		);
		
		$datos = catalogo::consultar('alumno', 'rep_historial_de_asistencias', $parametros);
		return $datos[$comision];
	}

	function get_columnas() 
	{
		$titulos = array(
			'clase_fecha' => $this->trans('historial_asistencia.clase_fecha'),
			'cant_inasistencias' => $this->trans('historial_asistencia.cant_inasistencias'),
			'desc_inasistencias' => $this->trans('historial_asistencia.desc_inasistencias'),
			'cant_justificadas' => $this->trans('historial_asistencia.cant_justificadas'),
			'desc_justificacion' => $this->trans('historial_asistencia.desc_justificacion'),
		);
		return $titulos;
	}
	
	function encabezado_reporte(){
		$encabezado = array();
		$encabezado['institucion']= guarani::ua()->get_nombre_institucion();
		$encabezado['facultad']= guarani::ua()->get_nombre();
	
		return $encabezado;
	}
}
?>