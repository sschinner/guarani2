<?php
namespace siu\operaciones\historia_academica;

use kernel\kernel;
use siu\guarani;
use siu\extension_kernel\controlador_g3w2;
use kernel\util\u;
use kernel\util\validador;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;
use siu\modelo\datos\catalogo;

class controlador extends controlador_g3w2
{
	protected $pdf_hoja = "A4";
	protected $pdf_encabezado = array("", "");
	protected $pdf_encabezado_img = array("img" => "", "width" => "");
	protected $pdf_fuente = "Courier.afm";
	protected $pdf_fuente_texto = 10;
	protected $pdf_fuente_titulo = 10;
	protected $pdf_fuente_subtitulo = 12;
	protected $tiene_encabezado = true;
	protected $encabezado_reporte = "";

	/**
	 *
	 * @return \siu\modelo\transacciones\historia_academica 
	 */
	function modelo()
	{
		return guarani::historia_academica();
	}

	function accion__index()
	{
		// Parámetros
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
		/* Todos los filtros marcados en caso de que no se mande checks, sino, se aplica normalmente o en caso que esté vacio no se marcara nada.  */ 

		if (!empty($checks)){
			$aChecks = explode(",", substr($checks,0,-1));
		}
		else if (kernel::url()->hay_param('checks')) {
			$checks = '' ;
		}
		else {
			$checks = 'PromocionA,CursadaA,CursadaR,CursadaU,EnCurso,ExamenA,ExamenR,EquivalenciaA,EquivalenciaR,';
			$aChecks = explode(",", substr($checks,0,-1));
		}

		// Estados de los títulos del cada filtro
		$estados = array();
		$estados['cursadas'] = $this->validate_param('e_cu', 'get', validador::TIPO_ALPHA, array(
			'default' => 'N'
		));
		$estados['examenes'] = $this->validate_param('e_ex', 'get', validador::TIPO_ALPHA, array(
			'default' => 'N'
		));
		$estados['equivalencias'] = $this->validate_param('e_eq', 'get', validador::TIPO_ALPHA, array(
			'default' => 'N'
		));
		//******************

		$datos = $this->datos_historia_academica($modo, $param_modo, $aChecks);

		$pagelet_menu_filtros = $this->vista()->pagelet('menu_filtros');
		$pagelet_menu_filtros->data['filtros'] = $aChecks;
		$pagelet_menu_filtros->data['estados'] = $estados;

		$pagelet_historia = $this->vista()->pagelet('info_historia');
		$pagelet_historia->data = $datos;
		$pagelet_historia->data['orden'] = $modo;
		$pagelet_historia->data['param_modo'] = $param_modo;
		$nro_inscripcion = kernel::persona()->get_nro_inscripcion();
		$carrera = kernel::persona()->get_id_carrera_activa();
		$legajo = kernel::persona()->get_id_legajo_activo();
		$pagelet_historia->data['promedios'] = $this->modelo()->get_promedios_por_titulo($nro_inscripcion, $carrera, $legajo);
		$pagelet_historia->data['porcentaje'] = $this->modelo()->get_porcentaje_aprobacion($nro_inscripcion, $carrera);
	}

	function datos_historia_academica($modo, $param_modo = "", $aChecks=array()){
		$historia = $this->modelo()->get_actividad_academica($modo);
		$cant = count($historia);
		$aAnos = array();
		$aMaterias = array();
		$key = null;
		$historia_final = array();
		$datos = array();
		$datos_final = array();
		$j = 0;

		for ($i=0; $i < $cant; $i++){
			if(in_array(trim($historia[$i]['ORIGEN']).trim($historia[$i]['RESULTADO']), $aChecks)){
				if (($key != $historia[$i]['MATERIA'] && $modo == "materia") || ($key != $historia[$i]['ANIO'] && $modo == "anio")) {
					switch ($modo) {
						case 'materia':
							$aMaterias[$historia[$i]['MATERIA']] = $historia[$i]['MATERIA_NOMBRE'];
							break;

						case 'anio':
							$aAnos[$historia[$i]['ANIO']] = $historia[$i]['ANIO'];
							break;
					}
				}

				if (empty($param_modo) || (!empty($param_modo) && ($modo == "anio" && $historia[$i]['ANIO'] == $param_modo)  || ($modo == "materia" && $historia[$i]['MATERIA'] == $param_modo))){
					if (($key != $historia[$i]['MATERIA'] && $modo == "materia") || ($key != $historia[$i]['ANIO'] && $modo == "anio")) {
						switch ($modo) {
							case 'materia':
								$key = $historia[$i]['MATERIA'];
								break;

							case 'anio':
								$key = $historia[$i]['ANIO'];
								break;
						}
						$j = 0;
					}

					$historia_final[$key][$j] = $historia[$i];

					switch (trim($historia[$i]['ORIGEN'])){
						case "Examen":
							$datos[$i]['acta'] = $historia[$i]['ACTA_RESOLUCION'];
						break;

						case "Promocion":
							$datos[$i]['acta'] = $historia[$i]['ACTA_RESOLUCION'];
						break;

						case "Promoción":
							$datos[$i]['acta'] = $historia[$i]['ACTA_RESOLUCION'];
						break;

						case "Cursada" :
							$datos[$i]['acta'] = $historia[$i]['ACTA_RESOLUCION'];
						break;

						case "EnCurso" :
							$datos[$i]['comision'] = $historia[$i]['COMISION'];
						break;

						case "Equivalencia" :
							$datos[$i]['equiv'] = $historia[$i]['EQUIVALENCIA'];
						break;

						case "Equivalencia parc" :
							$datos[$i]['equiv'] = $historia[$i]['EQUIVALENCIA'];
						break;
					}

					if (isset ($historia[$i]['FECHA_FIN_VIGENCIA'])) {
						$historia_final[$key][$j]['FECHA_FIN_VIGENCIA'] = $historia[$i]['FECHA_FIN_VIGENCIA'];
					}

					$historia_final[$key][$j]['id_detalle'] = $i;
					$historia_final[$key][$j]['ORIGEN'] = trim($historia_final[$key][$j]['ORIGEN']);
					$historia_final[$key][$j]['ORIGEN_CLASS'] = str_replace(" ", "_", $historia_final[$key][$j]['ORIGEN']);
                    $historia_final[$key][$j]['ORIGEN_DESC'] = kernel::traductor()->trans('historia_academica.'.trim($historia_final[$key][$j]['ORIGEN_DESC']));
					$j++;
				}
			}
		}
		kernel::sesion()->set('materias_a_seleccionar', $datos);

		$datos_final['historia'] = $historia_final;
		$datos_final['anos'] = $aAnos;
		$datos_final['materias'] = $aMaterias;
		return $datos_final;
	}

	function accion__detalle_examen()
	{
		$datos = kernel::sesion()->get('materias_a_seleccionar');
		$id = $this->validate_param('id', 'post', validador::TIPO_INT);
		$resultado = array();
		if (isset($datos[$id]['acta'])) {
			$detalle = $this->modelo()->get_detalle_materia_aprobada($datos[$id]['acta']);
			if (isset($detalle[0])) {
				$resultado['TURNO_EXAMEN'] = $detalle[0]['TURNO_EXAMEN'];
				$resultado['MESA_EXAMEN'] = $detalle[0]['MESA_EXAMEN'];
				$resultado['TIPO'] = $detalle[0]['TIPO'];
				$resultado['ANIO_ACADEMICO'] = $detalle[0]['ANIO_ACADEMICO'];
				$resultado['ACTA'] = $datos[$id]['acta'];
			}
		}
		$resultado['tipo'] = "detalle_examen";
		$this->render_template('detalle.twig', $resultado);
	}

	function accion__detalle_promocion()
	{
		$datos = kernel::sesion()->get('materias_a_seleccionar');
		$id = $this->validate_param('id', 'post', validador::TIPO_INT);
		$resultado = array();
		
		if (isset($datos[$id]['acta'])){
			$detalle = $this->modelo()->get_detalle_materia_promocionada($datos[$id]['acta']);
			$resultado['tipo'] = "detalle_promocion";
			$resultado['encabezado']['acta'] = $datos[$id]['acta'];
			if (isset($detalle)) {
				$resultado['encabezado']['per_lec'] = $detalle['comision']['PERIODO_LECTIVO'];				
				
				if (isset($detalle['comision']['CATEDRA'])){
					$resultado['encabezado']['catedra'] = $detalle['comision']['CATEDRA'];
				}

				if (isset($detalle['evaluaciones']) && count($detalle['evaluaciones']) > 0){
					$resultado['evaluaciones'] = $detalle['evaluaciones'];					
				}
			}
		}
		$resultado['tipo'] = "detalle_promocion";
		$this->render_template('detalle.twig', $resultado);
	}

	function accion__detalle_cursada()
	{
		$datos = kernel::sesion()->get('materias_a_seleccionar');
		$id = $this->validate_param('id', 'post', validador::TIPO_INT);
		$resultado = array();

		if (isset($datos[$id]['acta'])){
			$detalle = $this->modelo()->get_detalle_materia_cursada($datos[$id]['acta']);
			$resultado['encabezado']['acta'] = $datos[$id]['acta'];
			if (isset($detalle)) {
				$resultado['encabezado']['per_lec'] = $detalle['PERIODO_LECTIVO'];
				if (isset($detalle['CATEDRA'])){
					$resultado['encabezado']['catedra'] = $detalle['CATEDRA'];
				}

				$evaluaciones = catalogo::consultar('alumno','get_datos_parciales',
									array(	'carrera'=>kernel::persona()->get_id_carrera_activa(),
											'legajo' => kernel::persona()->get_id_legajo_activo(),
											'acta' => $datos[$id]['acta'],
											'comision' => $detalle['COMISION']
										)
								);
				if (!empty($evaluaciones) && count($evaluaciones) > 0){
					$resultado['evaluaciones'] = $evaluaciones;
				}
			}
			unset($detalle);
		}
		$resultado['tipo'] = "detalle_cursada";
		$this->render_template('detalle.twig', $resultado);
	}

	function accion__detalle_equivalencia()
	{
		$datos = kernel::sesion()->get('materias_a_seleccionar');
		$id = $this->validate_param('id', 'post', validador::TIPO_INT);
		$resultado = array();
		if (isset($datos[$id]['equiv'])){
			$detalle = $this->modelo()->get_detalle_equivalencia($datos[$id]['equiv']);
			if (isset($detalle)){
				$resultado['FECHA_VENCIMIENTO'] = $detalle['FECHA_VENCIMIENTO'];
				$resultado['NRO_RESOLUCION'] = $detalle['NRO_RESOLUCION'];
				$resultado['TEMAS_A_RENDIR'] = $detalle['TEMAS_A_RENDIR'];
			}
		}
		$resultado['tipo'] = "detalle_equivalencia";
		$this->render_template('detalle.twig', $resultado);
	}

	function accion__detalle_encurso()
	{
		$datos = kernel::sesion()->get('materias_a_seleccionar');
		$id = $this->validate_param('id', 'post', validador::TIPO_INT);
		
		$resultado = array();
		if (isset($datos[$id]) && isset($datos[$id]['comision'])){
			$evaluaciones = catalogo::consultar('alumno','get_datos_parciales',
									array(	'carrera'=>kernel::persona()->get_id_carrera_activa(),
											'legajo' => kernel::persona()->get_id_legajo_activo(),
											'comision' => $datos[$id]['comision']
										)
									);

			if (!empty($evaluaciones)){
					$resultado['evaluaciones'] = $evaluaciones;
				}
		}
		$resultado['tipo'] = "detalle_encurso";
		$this->render_template('detalle.twig', $resultado);
	}

	/* Exportación */
	function accion__exportar_pdf()
	{
		// Parámetros
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
		
		$logo = kernel::localizador()->encontrar_img('www/img','logo.png');
		
		$this->pdf_encabezado = array($universidad, '<b><u>Historia Académica</u></b>', 110);
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
		
		$pdf->agregar_texto("<b>Porcentaje de Aprobación</b>");	
		foreach($data_porcentaje as $porcentaje){
			$pdf->agregar_texto(ucfirst($this->trans('historia_academica.titulo')).": <b>".$porcentaje['titulo_nombre']."</b>");
			foreach($porcentaje['orientaciones'] as $orientacion){
				if($orientacion['orientacion'] == 0)
				{
					$pdf->agregar_texto(ucfirst($this->trans('historia_academica.plan_basico')).": ".$orientacion['porcentaje_aprobacion_orientacion']."%");
				}
				else	
				{
					$pdf->agregar_texto(ucfirst($this->trans('historia_academica.orientacion'))." ".$orientacion['orientacion_nombre'].": ".$orientacion['porcentaje_aprobacion_orientacion']."% - %Título: ".$orientacion['porcentaje_aprobacion_titulo']."%");
				}
			}

			$pdf->agregar_texto("");		
			};
		
			
		$pdf->generar();		
	}

	function accion__exportar_xls()
	{
		// Parámetros
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
		
		$xls = new generador_excel();
		$titulos = $this->get_columnas($modo);
		$xls->set_nombre_archivo('historia_academica');

		$alumno = guarani::persona()->get_nombre();
		$datos_carrera = guarani::persona()->get_info_carrera_activa();
		$nombre_carrera = "";
		if (isset($datos_carrera)){
			$nombre_carrera = $datos_carrera['nombre'];
		}
		$legajo = guarani::persona()->get_id_legajo_activo();
		$plan = guarani::persona()->get_id_plan_activo();
		$institucion = guarani::ua()->get_nombre_institucion();
		$facultad = guarani::ua()->get_nombre();
		
		$xls->agregar_texto_sin_enter($institucion,1);
		$xls->agregar_texto($facultad,1);
		$estilo_titulo = array(
 			'font' => array('bold' => true),
 		);
		$xls->agregar_texto_estilos('Historia Académica',1, $estilo_titulo);
		$xls->agregar_texto_sin_enter('Alumno: '.$alumno,1);
		$xls->agregar_texto_sin_enter('Legajo: '.$legajo,1);
		$xls->agregar_texto_sin_enter('Carrera: '.$nombre_carrera,1);
		$xls->agregar_texto_sin_enter('Plan: '.$plan,1);
		$xls->agregar_tabla($datos, $titulos);
		
		$xls->agregar_texto_sin_enter("",1);
		
		$xls->agregar_texto_estilos('Promedios',1, $estilo_titulo);
		foreach($data_titulos as $titulo){
			$data_promedio_general = number_format($titulo['promedio_general'],2);
			$data_promedio_sin_aplazos = number_format($titulo['promedio_sin_aplazos'],2);		
			
			$xls->agregar_texto_sin_enter(ucfirst($this->trans('plan.titulo')).": ".$titulo['nombre'], 1);
			$xls->agregar_texto_sin_enter(ucfirst($this->trans('plan.promedio_general')).": ".$data_promedio_general, 1);
			$xls->agregar_texto(ucfirst($this->trans('plan.promedio_sin_aplazos')).": ".$data_promedio_sin_aplazos, 1);
			$xls->agregar_texto_sin_enter("",1);
			};

		
		$xls->agregar_texto_estilos('Porcentaje de Aprobación',1, $estilo_titulo);
		foreach($data_porcentaje as $porcentaje){
			$xls->agregar_texto_sin_enter(ucfirst($this->trans('historia_academica.titulo')).": ".$porcentaje['titulo_nombre'], 1);
			foreach($porcentaje['orientaciones'] as $orientacion){
				if($orientacion['orientacion'] == 0)
				{
					$xls->agregar_texto_sin_enter(ucfirst($this->trans('historia_academica.plan_basico')).": ".$orientacion['porcentaje_aprobacion_orientacion']."%", 1);
				}
				else	
				{
					$xls->agregar_texto_sin_enter(ucfirst($this->trans('historia_academica.orientacion'))." ".$orientacion['orientacion_nombre'].": ".$orientacion['porcentaje_aprobacion_orientacion']."% - %Título: ".$orientacion['porcentaje_aprobacion_titulo']."%", 1);
				}
			}
			$xls->agregar_texto_sin_enter("",1);
			};		
		
		$xls->generar();
	}

	protected function crear_ezpdf(){
		$instancia = new \Cezpdf($this->pdf_hoja, 'landscape');
		return $instancia;
	}

	function get_columnas($modo = "anio"){
		switch ($modo){
			case "materia": 
					return array(
                        'ACTIVIDAD' => ucfirst(kernel::traductor()->trans('historia_academica.actividad')),
                        'FECHA_DISPLAY' => ucfirst(kernel::traductor()->trans('historia_academica.fecha')),
                        'ORIGEN_DESC' => ucfirst(kernel::traductor()->trans('historia_academica.tipo')),
                        'NOTA' => ucfirst(kernel::traductor()->trans('historia_academica.nota')),
                        'RESULTADO_DESCRIPCION' => ucfirst(kernel::traductor()->trans('historia_academica.resultado'))
                    );
				break;
			case "anio":
					return array(
                        'FECHA_DISPLAY' => ucfirst(kernel::traductor()->trans('historia_academica.fecha')),
                        'ACTIVIDAD' => ucfirst(kernel::traductor()->trans('historia_academica.actividad')),
                        'ORIGEN_DESC' => ucfirst(kernel::traductor()->trans('historia_academica.tipo')),
                        'NOTA' => ucfirst(kernel::traductor()->trans('historia_academica.nota')),
                        'RESULTADO_DESCRIPCION' => ucfirst(kernel::traductor()->trans('historia_academica.resultado'))
                    );
				break;
		}
	}

	function datos_exportar($modo, $param_modo = "", $aChecks=array()){
		$historia = $this->modelo()->get_actividad_academica($modo);
		$cant = count($historia);
		$historia_final = array();
		$j = 0;

		for ($i=0; $i < $cant; $i++){
			if(in_array(trim($historia[$i]['ORIGEN']).trim($historia[$i]['RESULTADO']), $aChecks)){
				if (empty($param_modo) || (!empty($param_modo) && ($modo == "anio" && $historia[$i]['ANIO'] == $param_modo)  || ($modo == "materia" && $historia[$i]['MATERIA'] == $param_modo))){
					$historia_final[$j] = $historia[$i];
                    $historia_final[$j]['ACTIVIDAD'] = $historia_final[$j]['MATERIA_NOMBRE'].' ('.$historia_final[$j]['MATERIA'].')';
					$historia_final[$j]['ORIGEN_DESC'] = kernel::traductor()->trans('historia_academica.'.trim($historia_final[$j]['ORIGEN_DESC']));
					$j++;
				}
			}
		}
		unset($j,$i);
		return $historia_final;
	}
}
?>
