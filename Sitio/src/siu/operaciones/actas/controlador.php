<?php
namespace siu\operaciones\actas;

use kernel\kernel;
use siu\extension_kernel\controlador_g3w2;
use kernel\util\validador;
use siu\modelo\datos\catalogo;

class controlador extends controlador_g3w2
{
	protected $form_builder;
	protected $datos_filtro;
	function modelo()
	{
		return null;
	}
	
	function get_clase_vista()
	{
		switch ($this->accion) {
			case 'acta_examen': 
			case 'acta_cursada': 
			case 'acta_promocion': 
				return 'vista_acta';
			default: 
				return 'vista';
		}
	}
	
	function accion__index()
	{
		$form = $this->get_form();
		if (!empty($_GET['formulario_filtro'])) {

            $validacion_ok = $this->recuperar_filtro();

            if($validacion_ok){//Si el form es valido prosigo

                $datos = $form->get_datos();

                $materia = "";
                if($datos['materia'] != "") $materia = $this->decodificar_materia($datos['materia']);
                $anio = "";
                if($datos['anio_academico'] != "") $anio = $this->decodificar_anio_academico($datos['anio_academico']);
                $sede = "";
                if($datos['sede'] != "") $sede = $this->decodificar_sede($datos['sede']);
                $turno = "";
                if($anio && ($datos['turno'] != "")) $turno = $this->decodificar_turno($datos['turno'], $anio);
                $periodo = "";
                if($anio && ($datos['periodo'] != "")) $periodo = $this->decodificar_periodo($datos['periodo'], $anio);

                $parametros = array(
                    'materia'			=> $materia,
                    'origen'			=> $datos['origen'],
                    'anio_academico'	=> $anio,
                    'sede'				=> $sede,
                    'turno_examen'		=> $turno,
                    'turno_desde'		=> $datos['desde'],
                    'turno_hasta'		=> $datos['hasta'],
                    'periodo_lectivo'	=> $periodo
                );

                $datos_cuadro = catalogo::consultar('unidad_academica', 'listar_actas_gerencial', $parametros);

                $datos_cuadro_link = array();
                foreach($datos_cuadro as $acta){
                    $datos_con_link = $acta;
                    switch($datos['origen']) {
                        case "E":
                            $datos_con_link['LINK'] = kernel::vinculador()->crear('actas', 'acta_examen', array(
                                't' => $acta['TIPO_ACTA'],
                                'a' => $acta['ACTA'],
                            ));
                            break;
                        case "P":
                            $datos_con_link['LINK'] = kernel::vinculador()->crear('actas', 'acta_promocion', array(
                                'a' => $acta['ACTA'],
                            ));
                            break;
                        case "R":
                            $datos_con_link['LINK'] = kernel::vinculador()->crear('actas', 'acta_cursada', array(
                                'a' => $acta['ACTA'],
                            ));
                            break;
                        default :
                            $datos_con_link['LINK'] = "-.-";
                    }
                    $datos_cuadro_link[] = $datos_con_link;
                    unset($datos_con_link);
                }
                $pagelet_cuadro = 'operaciones\actas\pagelet_cuadro';
                $pl = kernel::localizador()->instanciar($pagelet_cuadro, 'cuadro');
                $pl->data['cuadro'] = $datos_cuadro_link;
                $pl->data['tipo'] = $datos['origen'];
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
	
	function accion__buscar_materia() {
		$term = $this->validate_param('term', 'get', validador::TIPO_TEXTO);
		
		$term = utf8_decode($term);
		$datos = array();
		if (!is_null($term)){
			$datos = catalogo::consultar('unidad_academica', 'materias', array('term' => $term));
		}
		
		$this->render_raw_json($datos);
	}

    function decodificar_materia($materia_hash) {
        $datos = catalogo::consultar('unidad_academica', 'materias', array('term' => ""));
        if (!empty($datos)) {
            foreach($datos as $value){
                if ($value['id'] == $materia_hash){
                    return $value['materia'];
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
		$datos = catalogo::consultar('unidad_academica', 'anios_academicos');
		if (!empty($datos)) {
			foreach($datos as $value){
				if ($value['_ID_'] == $anio_hash){
					return $value['ANIO_ACADEMICO'];
				}
			}
		}
		return false;
	}
	
	function decodificar_turno($turno_hash = null, $anio_academico = null) {
		if (!is_null($anio_academico)){
			$turnos = catalogo::consultar('unidad_academica', 'buscar_turnos_examen', array('anio' => $anio_academico));
			if (!is_null($turnos)) {
				foreach($turnos as $value){
					if ($value['ID'] == $turno_hash){
						return $value['TURNO'];
					}
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
	
	function accion__acta_examen()
	{
		$tipo = $this->validate_param('t', 'get', validador::TIPO_TEXTO);
		$acta = $this->validate_param('a', 'get', validador::TIPO_TEXTO);
		
		
		$datos_acta = catalogo::consultar('docente', 'detalle_acta_examen', array(
			'tipo_acta' => $tipo,
			'acta' => $acta,
		));

		
		$pagelet_acta = 'operaciones\actas\pagelet_acta_examen';
		$pl = kernel::localizador()->instanciar($pagelet_acta, 'acta');
		$pl->data['datos'] = $datos_acta;
		$this->vista()->add_pagelet($pl);
	}
	
	function accion__acta_promocion()
	{
		$acta = $this->validate_param('a', 'get', validador::TIPO_TEXTO);
		$datos_acta = catalogo::consultar('docente', 'detalle_acta_promociones', array(
			'acta' => $acta,
		));
		
		$param_link = array();
		if (!empty($datos_acta) && !empty($datos_acta['ENCABEZADO']) && !empty($datos_acta['CUERPO'])){
			$param_link['a'] = $datos_acta['ENCABEZADO']['ACTA'];
			$param_link['c'] = $datos_acta['ENCABEZADO']['COMISION'];
			foreach($datos_acta['CUERPO'] as $hoja => $alumnos){
				foreach($alumnos as $orden => $alumno){
					$param_link['p'] = $alumno['CARRERA'];
					$param_link['l'] = $alumno['LEGAJO'];
					$datos_acta['CUERPO'][$hoja][$orden]['LINK'] = kernel::vinculador()->crear('actas', 'evaluaciones', $param_link);
				}
			}
		}
		
		$pagelet_acta = 'operaciones\actas\pagelet_acta_promocion';
		$pl = kernel::localizador()->instanciar($pagelet_acta, 'acta');
		$pl->data['datos'] = $datos_acta;
		$this->vista()->add_pagelet($pl);
	}
	
	function accion__acta_cursada()
	{
		$acta = $this->validate_param('a', 'get', validador::TIPO_TEXTO);
		$datos_acta = catalogo::consultar('docente', 'detalle_acta_cursada', array(
			'acta' => $acta,
		));
		
		$param_link = array();
		if (!empty($datos_acta) && !empty($datos_acta['ENCABEZADO']) && !empty($datos_acta['CUERPO'])){
			$param_link['a'] = $datos_acta['ENCABEZADO']['ACTA'];
			$param_link['c'] = $datos_acta['ENCABEZADO']['COMISION'];
			foreach($datos_acta['CUERPO'] as $hoja => $alumnos){
				foreach($alumnos as $orden => $alumno){
					$param_link['p'] = $alumno['CARRERA'];
					$param_link['l'] = $alumno['LEGAJO'];
					$datos_acta['CUERPO'][$hoja][$orden]['LINK'] = kernel::vinculador()->crear('actas', 'evaluaciones', $param_link);
				}
			}
		}
		
		$pagelet_acta = 'operaciones\actas\pagelet_acta_cursada';
		$pl = kernel::localizador()->instanciar($pagelet_acta, 'acta');
		$pl->data['datos'] = $datos_acta;
		$pl->add_var_js('acta', $acta);
		$this->vista()->add_pagelet($pl);
	}
	
	function accion__evaluaciones()
	{
		$carrera = $this->validate_param('p', 'get', validador::TIPO_TEXTO);
		$legajo = $this->validate_param('l', 'get', validador::TIPO_TEXTO);
		$acta = $this->validate_param('a', 'get', validador::TIPO_TEXTO);
		$comision = $this->validate_param('c', 'get', validador::TIPO_TEXTO);
		
		$evaluaciones = catalogo::consultar('alumno', 'get_datos_parciales', array(
			'carrera' => $carrera,
			'legajo' => $legajo,
			'acta' => $acta,
			'comision' => $comision,
		));

//		evaluaciones = 
//		array(
//			n => array(
//				SFECHA
//				EVALUACION_DESC
//				TIPO_EVALUACION
//				NOTA_DESCRIPCION
//				NOTA
//				RESULTADO_DESC
//			)
//		)
//		$resultado = array(
//			'evaluaciones' => array(
//				0 => array(
//					'SFECHA' => '10/08/2014',
//					'EVALUACION_DESC' => 'Descripción',
//					'TIPO_EVALUACION' => 'Parcial',
//					'NOTA_DESCRIPCION' => 'Nueve',
//					'NOTA' => '9',
//					'RESULTADO_DESC' => 'Aprobado',
//				)
//			)
//		);
		$this->render_template('evaluaciones.twig', array('evaluaciones' => $evaluaciones));
	}
	
	/**
	 * Solo la vista 'vista' tiene el form. Falla en otro caso
	 */
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
				$this->form_builder = kernel::localizador()->instanciar('operaciones\actas\filtro\builder_form_filtro');
		}

		return $this->form_builder;
	}
}
?>