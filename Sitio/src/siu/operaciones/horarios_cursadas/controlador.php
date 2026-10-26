<?php
namespace siu\operaciones\horarios_cursadas;

use kernel\kernel;
use siu\extension_kernel\controlador_g3w2;
use kernel\util\validador;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;
use siu\guarani;

class controlador extends controlador_g3w2
{
	protected $form_builder;
	public $datos_reporte;
	function modelo()
	{
		return null;
	}
	
	
	function accion__index()
	{
		$form = $this->get_form();
		if (!empty($_GET['formulario_filtro'])) {

            $validacion_ok = $this->recuperar_filtro();

            if($validacion_ok){//Si el form es valido prosigo

                $datos = $form->get_datos();

				$carrera = "";
				if($datos['carrera'] != "") $carrera = $this->decodificar_carrera($datos['carrera']);
                $materia = "";
                if($datos['materia'] != "") $materia = $this->decodificar_materia($datos['materia'],$carrera);
                $anio = "";
                if($datos['anio_academico'] != "") $anio = $this->decodificar_anio_academico($datos['anio_academico']);
                $sede = "";
                if($datos['sede'] != "") $sede = $this->decodificar_sede($datos['sede']);
                $periodo = "";
                if($anio && ($datos['periodo'] != "")) $periodo = $this->decodificar_periodo($datos['periodo'], $anio);
				$parametros = array(
                    'anio_academico'	=> $anio,
					'periodo_lectivo'	=> $periodo,
					'materia'			=> $materia,
                    'sede'				=> $sede,
                    'dia'				=> $datos['dia_semana'],
                    'turno'				=> $datos['turno'],
                    'carrera'			=> $carrera,
                    'anio_cursada'		=> $datos['anio_cursada'],
                    
                );
				
                $datos = catalogo::consultar('usuario_anonimo', 'horarios_cursadas', $parametros);

                $pagelet = 'operaciones\horarios_cursadas\pagelet_reporte';
                $pl = kernel::localizador()->instanciar($pagelet, 'reporte');
                $pl->data['datos'] = $datos;
				$this->datos_reporte = $datos;
                $this->vista()->add_pagelet($pl);
            }
		}
	}
	
	function accion__buscar_turnos() {
		$anio_academico_hash = $this->validate_param('anio_academico', 'get', validador::TIPO_ALPHANUM);
		$anio_academico = $this->decodificar_anio_academico($anio_academico_hash);
		$datos = array();
		if (!is_null($anio_academico)){
			$datos = catalogo::consultar('unidad_academica', 'buscar_turnos_examen', array('anio' => $anio_academico));
		}
		$this->render_raw_json($datos);
	}
	
	function accion__buscar_periodos() {
		$anio_academico_hash = $this->validate_param('anio_academico', 'get', validador::TIPO_ALPHANUM);
		$anio_academico = $this->decodificar_anio_academico($anio_academico_hash);
		$datos = array();
		if (!is_null($anio_academico)){
			$datos = catalogo::consultar('unidad_academica', 'buscar_periodos_lectivos', array('anio' => $anio_academico));
		}
		$this->render_raw_json($datos);
	}
	
//	function accion__buscar_materia() {
//		$term = $this->validate_param('term', 'get', validador::TIPO_TEXTO);
//		
//		$term = utf8_decode($term);
//		$datos = array();
//		if (!is_null($term)){
//			$datos = catalogo::consultar('unidad_academica', 'materias', array('term' => $term));
//		}
//		
//		$this->render_raw_json($datos);
//	}
	
    function accion__buscar_materias() {
        $term = $this->validate_param('term', 'get', validador::TIPO_TEXTO);
        $term = utf8_decode($term);
        
        $carrera_hash = $this->validate_param('carrera', 'get', validador::TIPO_ALPHANUM, array('default' => ''));
        $carrera = "";
        if($carrera_hash != "") $carrera = $this->decodificar_carrera($carrera_hash);

        //$plan_hash = $this->validate_param('plan', 'get', validador::TIPO_ALPHANUM, array('default' => ''));
        //$plan = "";
        //if($carrera && ($plan_hash != "")) $plan = $this->decodificar_plan($plan_hash, $carrera);

        $paquete = array();
        if (!is_null($term)){

            $datos = catalogo::consultar('usuario_anonimo', 'lista_materias_carrera', array('carrera' => $carrera, 'plan' => "", 'materia' => $term));
            foreach ($datos as $dato){
                $paquete[] = array(
                    'id' => $dato['_ID_'],
                    'label' => $dato['NOMBRE']
                );
            }

        }

        $this->render_raw_json($paquete);
    }

//    function decodificar_materia($materia_hash) {
//        $datos = catalogo::consultar('unidad_academica', 'materias', array('term' => ""));
//        if (!empty($datos)) {
//            foreach($datos as $value){
//                if ($value['id'] == $materia_hash){
//                    return $value['materia'];
//                }
//            }
//        }
//        return false;
//    }
	
    function decodificar_materia($materia_hash, $carrera="") {
        $datos = catalogo::consultar('usuario_anonimo', 'lista_materias_carrera', array('carrera' => $carrera, 'plan' => "", 'materia' => ""));
        if (!empty($datos)) {
            foreach($datos as $value){
                if ($value['_ID_'] == $materia_hash){
                    //return array($value['MATERIA'], $value['NOMBRE']);
                    return $value['MATERIA'];
                }
            }
        }
        return false;
    }	

    function decodificar_sede($sede_hash) {
        $datos = catalogo::consultar('sistema', 'sedes');
        if (!empty($datos)) {
            foreach($datos as $value){
                if ($value['_ID_'] == $sede_hash){
                    return $value['SEDE'];
                }
            }
        }
        return false;
    }
	
	function decodificar_anio_academico($anio_hash) {
		$datos = catalogo::consultar('unidad_academica', 'anios_academicos_vigentes');
		if (!empty($datos)) {
			foreach($datos as $value){
				if ($value['_ID_'] == $anio_hash){
					return $value['ANIO_ACADEMICO'];
				}
			}
		}
		return false;
	}

	function decodificar_periodo($periodo_hash = null, $anio_academico = null) {
		if (!is_null($anio_academico)){
			$periodos = catalogo::consultar('unidad_academica', 'buscar_periodos_lectivos', array('anio' => $anio_academico));
			if (!is_null($periodos)) {
				foreach($periodos as $value){
					if ($value['ID'] == $periodo_hash){
						return $value['PERIODO_LECTIVO'];
					}
				}
			}
		}
		return false;
	}
	
	function decodificar_carrera($carrera_hash) {
		$datos = catalogo::consultar('plan_estudios', 'carreras');
		if (!empty($datos)) {
			foreach($datos as $value){
				if ($value['_ID_'] == $carrera_hash){
					return $value['CARRERA'];
				}
			}
		}
		return false;
	}
	
	private function recuperar_filtro()
	{
		$form = $this->get_form();
		/*if (!$form->procesar('GET')) {
			throw new error_kernel_validacion("Error al validar el filtro");
		}*/
        $validacion_ok = $form->procesar('GET');
		//si no se llega aca, aplican los valores default
		$this->datos_filtro = $form->get_datos();
        return $validacion_ok;
	}
	
	/**
	 * @return guarani_form
	 */
	function get_form()
	{
		return $this->get_form_builder()->get_formulario();
	}

	function get_vista_form(){
		return $this->get_form_builder()->get_vista();
	}
	
	/**
	* @return builder_form_filtro
	*/
	function get_form_builder()
	{
		// se hace esta función para no construir cada vez el builder
		if (! isset($this->form_builder)) {
				$this->form_builder = kernel::localizador()->instanciar('operaciones\horarios_cursadas\filtro\builder_form_filtro');
		}

		return $this->form_builder;
	}
	
/*REPORTES PDF Y EXCEL*/	

	public function get_columnas(){
		$titulo = array();
		$titulo['COMISION_NOMBRE'] = "Comisión";
		$titulo['TURNO_DESC'] = "Turno";
		$titulo['DIA_SEMANA_DESC'] = "Día de semana";
		$titulo['INICIO_FIN_CLASE'] = "Hora inicio-fin";
		$titulo['TIPO_CLASE_DESC'] = "Tipo clase";
		$titulo['AULA_NOMBRE'] = "Aula";
		$titulo['EDIFICIO'] = "Edificio";
		$titulo['CUPO'] = "Cupo";
		return $titulo;
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
	
	protected function get_datos()
	{
		if(!isset($this->datos_reporte)){
			
			//Parámetros filtro
			$hash_materia = $this->validate_param('materia', 'get', validador::TIPO_TEXTO, array('allowempty' => true));
			$hash_anio = $this->validate_param('anio', 'get', validador::TIPO_ALPHANUM);
			$hash_sede = $this->validate_param('sede', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
			$hash_periodo = $this->validate_param('periodo', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
			$hash_carrera = $this->validate_param('carrera', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
			$dia = $this->validate_param('dia', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
			$turno = $this->validate_param('turno', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
			$anio_cursada = $this->validate_param('anio_curs', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
			
			//Seteo parámetros
				$carrera = "";
				if($hash_carrera != "") $carrera = $this->decodificar_carrera($hash_carrera);
                $materia = "";
                if($hash_materia != "") $materia = $this->decodificar_materia($hash_materia);
                $anio = "";
                if($hash_anio != "") $anio = $this->decodificar_anio_academico($hash_anio);
                $sede = "";
                if($hash_sede != "") $sede = $this->decodificar_sede($hash_sede);
                $periodo = "";
                if($anio && ($hash_periodo != "")) $periodo = $this->decodificar_periodo($hash_periodo, $anio);

				$parametros = array(
                    'anio_academico'	=> $anio,
					'periodo_lectivo'	=> $periodo,
					'materia'			=> $materia,
                    'sede'				=> $sede,
                    'dia'				=> $dia,
                    'turno'				=> $turno,
                    'carrera'			=> $carrera,
                    'anio_cursada'		=> $anio_cursada,
                    
                );
				
			//Realizo consulta	
                $this->datos_reporte = catalogo::consultar('usuario_anonimo', 'horarios_cursadas', $parametros);			
		}
		return $this->datos_reporte;
	}
	
	public function accion__generar_pdf(){
		$pdf = $this->get_generador_pdf();
		$pdf->set_font($this->pdf_fuente);
		$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 750, 'width' => 750, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => array()));
		$pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 750, 'width' => 750));
		$pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
		$pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
		$pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
		$pdf->set_tiene_encabezado(false);
		$institucion = guarani::ua()->get_nombre_institucion();
		$pdf->set_encabezado($institucion, '<b><u>Horarios Cursadas</u></b>',110);
		
		if (!empty($this->pdf_encabezado_img["img"])){
			$pdf->set_encabezado_img($this->pdf_encabezado_img["img"], $this->pdf_encabezado_img["width"]);
		} else {
			$logo = kernel::localizador()->encontrar_img('www/img','logo.png');
			$pdf->set_encabezado_img($logo['path'], "100");
		}

		$data = $this->get_datos();	
		$titulos= $this->get_columnas(); 
	
		foreach ($data as $sede){
			$pdf->agregar_texto('<b>Sede: </b>'.$sede['SEDE_NOMBRE']);
			$pdf->agregar_texto(' ');
			
			foreach ($sede['PERIODOS_LECTIVOS'] as $periodo_lectivo){
				$pdf->agregar_texto('<b>Período Lectivo: </b>'.$periodo_lectivo['PERIODO_LECTIVO']);
				$pdf->agregar_texto(' ');
				
				foreach($periodo_lectivo['MATERIAS'] as $materia){
					$pdf->agregar_texto('<b>Materia: </b>'.$materia['MATERIA_NOMBRE']);
					$pdf->agregar_texto(' ');
					$pdf->agregar_tabla($materia['HORARIOS'], $titulos, '');
					$pdf->agregar_texto(' ');
					$pdf->agregar_texto(' ');
					
				}
			}
			$pdf->agregar_texto('');
		}		

		$pdf->set_nombre_archivo('horarios_cursadas');
		$pdf->generar();
	}
	
	protected function get_generador_excel()
	{
		return new generador_excel();
	}
	

	public function accion__generar_excel(){
		$excel = $this->get_generador_excel();
		$data = $this->get_datos();
		$titulos = $this->get_columnas();
		$institucion = guarani::ua()->get_nombre_institucion();
		$estilo_titulo = array(
 			'font' => array('bold' => true));

		$excel->agregar_texto_estilos($institucion,1, $estilo_titulo);
		$excel->agregar_texto_estilos('Horarios Cursadas',1, $estilo_titulo);
		
		
			
		foreach ($data as $sede){
			$excel->agregar_texto('Sede: '.$sede['SEDE_NOMBRE'],1);
			
			foreach ($sede['PERIODOS_LECTIVOS'] as $periodo_lectivo){
				$excel->agregar_texto('Período Lectivo: '.$periodo_lectivo['PERIODO_LECTIVO'],1);
				
				foreach($periodo_lectivo['MATERIAS'] as $materia){
					$excel->agregar_texto('Materia: '.$materia['MATERIA_NOMBRE'],1);
					$excel->agregar_tabla($materia['HORARIOS'], $titulos, '');
					$excel->agregar_texto('',1);
					
				}
			}
			$excel->agregar_texto('',1);
		}	

		$excel->set_nombre_archivo('horarios_cursadas');
		$excel->generar();
	}	
}
?>