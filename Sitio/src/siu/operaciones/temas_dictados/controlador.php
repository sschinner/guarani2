<?php
namespace siu\operaciones\temas_dictados;

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

	function accion__temas()
	{
		$this->hash = $this->validate_param('hash', 'get', validador::TIPO_ALPHANUM);

		$parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
		$parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
		$comisiones = catalogo::consultar('alumno', 'comision_inscripto', $parametros);

		$comision = $comisiones[$this->hash][8];
		$nombre_comision = $comisiones[$this->hash][9]." (".$comisiones[$this->hash][8].")";

		$parametros = array(
			'carrera' => kernel::persona()->get_id_carrera_activa(),
			'legajo' => kernel::persona()->get_id_legajo_activo(),
			'comision' =>  $comision
		);

		$datos = catalogo::consultar('alumno', 'temas_dictados', $parametros);
		$clase = 'operaciones\temas_dictados\pagelet_temas';
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
		$encabezado = $datos['encabezado'];
		$comision = $datos['encabezado']['comision'];

		$pdf = $this->get_generador_pdf();
		$pdf->set_font("Courier.afm");
		$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 750, 'width' => 750, 'fontSize' => 10, 'shadeCol' => array(0.8,0.8,0.8), 'cols' => array('fecha'=>array('width'=>150), 'inicio'=>array('width'=>95), 'horas'=>array('width'=>45), 'tema'=>array('width'=>380), 'tipo_clase'=>array('width'=>120))));
		$pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 750, 'width' => 750));
		$pdf->set_tiene_encabezado(true);
		
		$nombre_reporte = kernel::traductor()->trans('header.menu.temas_dictados');
		$logo = kernel::localizador()->encontrar_img('www/img','logo.png');
		$pdf->set_encabezado_img($logo['path'], "100");
		$pdf->set_encabezado($encabezado['institucion']."\n".$encabezado['facultad'], '<b><u>'.$nombre_reporte.'</b></u>', 110);
		
		$datos_encabezado = array(
								'cant_columnas' => 2,
								'datos' => array(0 => 'Materia: '.$encabezado['materia'],
												 1 => 'Comisión: '.$encabezado['comision'],
												 2 => 'Alumno: '.$encabezado['alumno'],
												 3 => 'Legajo: '.$encabezado['legajo'],
												 4 => 'Carrera: '.$encabezado['carrera'],
												 5 => 'Plan: '.$encabezado['plan']
												)
								);
	
		$pdf->set_encabezado_tabla($datos_encabezado);
		
		foreach($datos['datos'] as $subcomision) //recorro las subcomisiones. Si no hay subcomisiones, cant_subco = 1
		{
			if ($encabezado['cant_subco'] > 1)
			{
				$pdf->agregar_texto("\n".'<b>Subcomisión: </b>'.$subcomision['subcomision_nombre']." (".$subcomision['subcomision'].")");
			}
			$pdf->agregar_texto("\n");
			$pdf->agregar_tabla($subcomision['datos'],$this->get_columnas(),'');
		}
		$pdf->set_nombre_archivo('temas_dictados_por_clase_'.$comision);
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
		$comision = $datos['encabezado']['comision'];
		$encabezado = $datos['encabezado'];

		$excel = $this->get_generador_excel();
		$excel->agregar_texto_sin_enter($encabezado['institucion'],1);
		$excel->agregar_texto($encabezado['facultad'],1);
		$estilo_titulo = array(
 			'font' => array('bold' => true),
 		);
		$excel->agregar_texto_estilos('Temas Dictados por Clase',1, $estilo_titulo);
		$excel->agregar_texto_sin_enter('Materia: '.$encabezado['materia'],1);
		$excel->agregar_texto_sin_enter('Comisión: '.$encabezado['comision'],1);
		$excel->agregar_texto_sin_enter('Alumno: '.$encabezado['alumno'],1);
		$excel->agregar_texto_sin_enter('Legajo: '.$encabezado['legajo'],1);
		$excel->agregar_texto_sin_enter('Carrera: '.$encabezado['carrera'],1);
		
		foreach($datos['datos'] as $subcomision) //recorro las subcomisiones. Si no hay subcomisiones, cant_subco = 1
		{
			if ($encabezado['cant_subco'] > 1)
			{
				$excel->agregar_texto("",1);
				$estilo_titulo = array(
										'font' => array('bold' => true),
										);
				$excel->agregar_texto_estilos("Subcomisión: ".$subcomision['subcomision_nombre']." (".$subcomision['subcomision'].")",1, $estilo_titulo);
			}
			
			$excel->agregar_tabla($subcomision['datos'],$this->get_columnas());
		}

		$excel->set_nombre_archivo('temas_dictados_por_clase_'.$comision);
		$excel->generar();
	}

	function datos_exportacion() 
	{
		$parametros['carrera'] = kernel::persona()->get_id_carrera_activa();
		$parametros['legajo'] = kernel::persona()->get_id_legajo_activo();
		$comisiones = catalogo::consultar('alumno', 'comision_inscripto', $parametros);

		$comision = $comisiones[$this->hash][8];
		$nombre_comision = $comisiones[$this->hash][9]." (".$comisiones[$this->hash][8].")";
		$nombre_materia = $comisiones[$this->hash][11]." (".$comisiones[$this->hash][10].")";

		$parametros = array(
			'carrera' => kernel::persona()->get_id_carrera_activa(),
			'legajo' => kernel::persona()->get_id_legajo_activo(),
			'comision' =>  $comision
		);

		$datos = catalogo::consultar('alumno', 'temas_dictados', $parametros);
		$datos_result = array();

		//Traigo datos para el encabezado
		$datos_encabezado = $this->encabezado_reporte();
		$datos_encabezado['materia'] = $nombre_materia;
		$datos_encabezado['comision'] = $nombre_comision;
		$datos_encabezado['cant_subco'] = sizeof($datos);
		
		$datos_result['encabezado'] = $datos_encabezado;
		$datos_result['datos'] = $datos;
		return $datos_result;
	}

	function get_columnas() 
	{
		$titulos = array(
			'fecha' => $this->trans('temas_dictados.fecha'),
			'inicio' => $this->trans('temas_dictados.inicio')." - ".$this->trans('temas_dictados.fin'),
			//'fin' => $this->trans('temas_dictados.fin'),
			'horas' => $this->trans('temas_dictados.horas'),
			'tema' => $this->trans('temas_dictados.tema'),
			'tipo_clase' => $this->trans('temas_dictados.tipo_clase'),
		);
		return $titulos;
	}
	
	function encabezado_reporte(){
		$nombre_carrera = "";
		$datos_carrera = guarani::persona()->get_info_carrera_activa();
		if (isset($datos_carrera)){
			$nombre_carrera = $datos_carrera['nombre'];
		}
		
		$encabezado = array();
		$encabezado['institucion']= guarani::ua()->get_nombre_institucion();
		$encabezado['facultad']= guarani::ua()->get_nombre();
		$encabezado['legajo']= guarani::persona()->get_id_legajo_activo();
		$encabezado['alumno']= guarani::persona()->get_nombre();
		$encabezado['carrera']= $nombre_carrera;
		$encabezado['plan']= guarani::persona()->get_id_plan_activo();;
		
		return $encabezado;
	}
}
?>