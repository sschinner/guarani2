<?php
namespace siu\operaciones\fecha_examen;

use kernel\kernel;
use siu\extension_kernel\controlador_g3w2;
use kernel\util\validador;
use siu\modelo\datos\catalogo;
use kernel\error_kernel_validacion;

class controlador extends controlador_g3w2
{
	protected $form_builder;
	protected $datos_filtro;
	function modelo()
	{
		return null;
	}
	
	function accion__index()
	{
		$form = $this->get_form();
		$mostrar_seleccione_turno = true;

		if (!empty($_GET['formulario_filtro'])) {
			$this->recuperar_filtro();
			$filtros = $form->get_datos();

            $carrera = "";
			if($filtros['carrera'] != "") $carrera = $this->decodificar_carrera($filtros['carrera']);
            $plan = "";
            if($carrera && ($filtros['plan'] != "")) $plan = $this->decodificar_plan($filtros['plan'], $carrera);
            $materia = "";
            $materia_descr = "";
            if($filtros['materia'] != ""){
                list($materia, $materia_descr) = $this->decodificar_materia($filtros['materia'], $carrera, $plan);
            }
            $this->datos_filtro["materia_descr"] = $materia_descr;
            $form->set_datos(array("materia_descr" => $materia_descr));
            $fecha_desde = ($filtros['fecha_desde'] != "")? \DateTime::createFromFormat('d/m/Y', $filtros['fecha_desde'])->format('Y-m-d') : "";
            $fecha_hasta = ($filtros['fecha_hasta'] != "")? \DateTime::createFromFormat('d/m/Y', $filtros['fecha_hasta'])->format('Y-m-d') : "";
            $tipo_inscripcion = $filtros['tipo_mesa'];

			$materias = array();

            $parametros = array(
                'carrera'   => $carrera,
                'plan'      => $plan,
                'materia'   => $materia,
                'fecha_desde'   => $fecha_desde,
                'fecha_hasta'   => $fecha_hasta,
                'tipo_inscripcion'  => $tipo_inscripcion
            );

            $datos = catalogo::consultar('usuario_anonimo', 'mesas_examen_usuario_anonimo', $parametros);

            //Hago corte de control por materia
            foreach($datos as $dato){

                $materias[$dato['MATERIA']]['MATERIA_NOMBRE'] = $dato['MATERIA_NOMBRE'];
                $materias[$dato['MATERIA']]['MATERIA'] = $dato['MATERIA'];

                $materias[$dato['MATERIA']]['examenes'][] = array(
                    'MESA' => $dato['MESA_EXAMEN'],
                    'FECHA' => $dato['FECHA_EXAMEN'],
                    'TIPO_MESA' => $dato["TIPO_DE_MESA"],
                    'INSCR_INICIO' => $dato['F_INICIO_INSC'],
                    'INSCR_FIN' => $dato['F_FIN_INSC'],
                    'INFO_EXTRA' => array(
                        'HORA_INICIO' => $dato['HORA_INICIO'],
                        'HORA_FINALIZACION' => $dato['HORA_FINALIZACION'],
                        'EDIFICIO_AULA' => $dato['EDIFICIO_AULA'],
                        'FECHA_TOPE_BAJAS' => $dato['F_TOPE_BAJA_MESA'],
                        'DOCENTES' => $dato['DOCENTES'],
                        'CARRERA_NOMBRE' => $dato['CARRERA_NOMBRE'],
                        'PLAN' => $dato['PLAN'],
                        'GRUPO_CARRERA_NOMBRE' => $dato['GRUPO_CARRERA_NOM'],
						'OBSERVACIONES' => $dato['OBSERVACIONES']
                    )
                );
            }

			$this->vista()->pagelet('filtro')->data['cuadro'] = $materias;
			$mostrar_seleccione_turno = false;
		}

		$this->vista()->pagelet('filtro')->add_var_js('mostrar_seleccione_turno', $mostrar_seleccione_turno);
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

    function decodificar_plan($plan_hash, $carrera) {
        $datos = catalogo::consultar('plan_estudios', 'planes', array('carrera' => $carrera));
        if (!empty($datos)) {
            foreach($datos as $value){
                if ($value['_ID_'] == $plan_hash){
                    return $value['PLAN'];
                }
            }
        }
        return false;
    }

    function decodificar_materia($materia_hash, $carrera, $plan) {
        $datos = catalogo::consultar('usuario_anonimo', 'lista_materias_carrera', array('carrera' => $carrera, 'plan' => $plan, 'materia' => ""));
        if (!empty($datos)) {
            foreach($datos as $value){
                if ($value['_ID_'] == $materia_hash){
                    return array($value['MATERIA'], $value['NOMBRE']);
                }
            }
        }
        return false;
    }
	
	/**
	 * Solo la vista 'vista' tiene el form. Falla en otro caso
	 */
	private function recuperar_filtro()
	{
		$form = $this->get_form();
		if (!$form->procesar('GET')) {
			throw new error_kernel_validacion("Error al validar el filtro");
		}

		//si no se llega aca, aplican los valores default
		$this->datos_filtro = $form->get_datos();
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
				$this->form_builder = kernel::localizador()->instanciar('operaciones\fecha_examen\filtro\builder_form_filtro');
		}

		return $this->form_builder;
	}

    function accion__buscar_planes(){

        $carrera_hash = $this->validate_param('carrera', 'get', validador::TIPO_ALPHANUM);
        $carrera = "";
        if($carrera_hash != "") $carrera = $this->decodificar_carrera($carrera_hash);
        $datos = array();
        $datos['cod'] = 1;
        $datos['planes'] = catalogo::consultar('plan_estudios', 'planes', array('carrera' => $carrera));
        $this->render_raw_json($datos);

    }

    function accion__buscar_materias() {
        $term = $this->validate_param('term', 'get', validador::TIPO_TEXTO);
        $term = utf8_decode($term);
        
        $carrera_hash = $this->validate_param('carrera', 'get', validador::TIPO_ALPHANUM, array('default' => ''));
        $carrera = "";
        if($carrera_hash != "") $carrera = $this->decodificar_carrera($carrera_hash);

        $plan_hash = $this->validate_param('plan', 'get', validador::TIPO_ALPHANUM, array('default' => ''));
        $plan = "";
        if($carrera && ($plan_hash != "")) $plan = $this->decodificar_plan($plan_hash, $carrera);

        $paquete = array();
        if (!is_null($term)){

            $datos = catalogo::consultar('usuario_anonimo', 'lista_materias_carrera', array('carrera' => $carrera, 'plan' => $plan, 'materia' => $term));
            foreach ($datos as $dato){
                $paquete[] = array(
                    'id' => $dato['_ID_'],
                    'label' => $dato['NOMBRE']
                );
            }

        }

        $this->render_raw_json($paquete);
    }
}