<?php
namespace personalizacionUA\operaciones\historia_academica;

use kernel\kernel;
use siu\guarani;
use siu\extension_kernel\controlador_g3w2;
use kernel\util\u;
use kernel\util\validador; 
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;
use siu\modelo\datos\catalogo;

class controlador extends \siu\operaciones\historia_academica\controlador
{
	

		/* Exportaci�n */
	function accion__exportar_pdf()
	{
		// Par�metros
		$modo = $this->validate_param('modo', 'get', validador::TIPO_ALPHA, array(
			'default' => 'anio'
		));

		$param_modo = $this->validate_param('param_modo', 'get', validador::TIPO_TEXTO, array(
			'default' => ''
		));

		$checks = $this->validate_param('checks', 'get', validador::TIPO_TEXTO, array(
			'default' => ''
		));
		$aChecks = array();
		if (!empty($checks)){
			$aChecks = explode(",", substr($checks,0,-1));
		}

		$datos = $this->datos_exportar($modo, $param_modo, $aChecks);
		foreach($datos as &$dato){
			if($dato['NOTA_DESCRIPCION'] != ""){
				 $dato['NOTA'].=" (".$dato['NOTA_DESCRIPCION'].")";
			}
		}
		
		$datos_aux = array();
		$datos_aux = $datos;
		unset($datos);
		for($i = 0; $i < sizeof($datos_aux); $i++){
			if ($datos_aux[$i]['ORIGEN'] != 'EnCurso'){
				$datos[$i] = $datos_aux[$i];
			}
		}

		$nro_inscripcion = kernel::persona()->get_nro_inscripcion();
		$carrera = kernel::persona()->get_id_carrera_activa();
		$legajo = kernel::persona()->get_id_legajo_activo();
		$data_titulos = $this->modelo()->get_promedios_por_titulo($nro_inscripcion, $carrera, $legajo);
		$data_porcentaje = $this->modelo()->get_porcentaje_aprobacion($nro_inscripcion, $carrera);
		
		$pdf = new generador_pdf($this->crear_ezpdf());
		$pdf->set_font($this->pdf_fuente);
		$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 800, 'width' => 800, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => array('FECHA_DISPLAY'=>array('width'=>75))));
		$pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 800, 'width' => 800));
		$pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
		$pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
		$pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
		$pdf->set_tiene_encabezado($this->tiene_encabezado);
		$pdf->set_nombre_archivo('historia_academica');

		$alumno = guarani::persona()->get_nombre();
		$datos_carrera = guarani::persona()->get_info_carrera_activa();
		$nombre_carrera = "";
		if (isset($datos_carrera)){
			$nombre_carrera = $datos_carrera['nombre'];
		}
		$legajo = guarani::persona()->get_id_legajo_activo();
		$plan = guarani::persona()->get_id_plan_activo();
		//$pdf->set_encabezado_reporte('Alumno: '.$alumno.PHP_EOL.'Legajo: '.$legajo.PHP_EOL.'Carrera: '.$nombre_carrera.PHP_EOL.'Plan: '.$plan.PHP_EOL);
		
		$datos_encabezado = array(
								'cant_columnas' => 2,
								'datos' => array(0 => 'Alumno: '.$alumno,
												 1 => 'Legajo: '.$legajo,
												 2 => 'Carrera: '.$nombre_carrera,
												 3 => 'Plan: '.$plan
												)
								);
								
		$pdf->set_encabezado_tabla($datos_encabezado);
	
		$universidad = guarani::ua()->get_nombre_institucion()."\n".guarani::ua()->get_nombre()."\n";
		
		$logo = kernel::localizador()->encontrar_img('www/img','logo.jpeg');
		
		$this->pdf_encabezado = array($universidad, '<b><u>Historia Acad�mica</u></b>', 110);
		$this->pdf_encabezado_img = array('img'=>$logo['path'],'width' => '100');

		$pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
		$pdf->set_encabezado_img($this->pdf_encabezado_img["img"], $this->pdf_encabezado_img["width"]);
//                $pdf->posY(720);
                $pdf->agregar_texto("");

		$titulos = $this->get_columnas($modo);
//		$pdf->agregar_texto('Alumno: '.$alumno.PHP_EOL.'Legajo: '.$legajo.PHP_EOL.'Carrera: '.$nombre_carrera.PHP_EOL.'Plan: '.$plan.PHP_EOL);
		$pdf->agregar_tabla($datos, $titulos, '');
		$pdf->agregar_texto("");
		
		$pdf->agregar_texto("<b>Promedios</b>");
		foreach($data_titulos as $titulo){
			$data_promedio_general = number_format($titulo['promedio_general'],2);
			$data_promedio_sin_aplazos = number_format($titulo['promedio_sin_aplazos'],2);

			$pdf->agregar_texto(ucfirst($this->trans('plan.titulo')).": <b>".$titulo['nombre']."</b>");
			$pdf->agregar_texto(ucfirst($this->trans('plan.promedio_general')).": ".$data_promedio_general);
			$pdf->agregar_texto(ucfirst($this->trans('plan.promedio_sin_aplazos')).": ".$data_promedio_sin_aplazos);
			$pdf->agregar_texto("");		
			};
		
		$pdf->agregar_texto("<b>Porcentaje de Aprobaci�n</b>");	
		foreach($data_porcentaje as $porcentaje){
			$pdf->agregar_texto(ucfirst($this->trans('historia_academica.titulo')).": <b>".$porcentaje['titulo_nombre']."</b>");
			foreach($porcentaje['orientaciones'] as $orientacion){
				if($orientacion['orientacion'] == 0)
				{
					$pdf->agregar_texto(ucfirst($this->trans('historia_academica.plan_basico')).": ".$orientacion['porcentaje_aprobacion_orientacion']."%");
				}
				else	
				{
					$pdf->agregar_texto(ucfirst($this->trans('historia_academica.orientacion'))." ".$orientacion['orientacion_nombre'].": ".$orientacion['porcentaje_aprobacion_orientacion']."% - %T�tulo: ".$orientacion['porcentaje_aprobacion_titulo']."%");
				}
			}

			$pdf->agregar_texto("");		
			};
		
			
		$pdf->generar();		
	}


	
}
?>