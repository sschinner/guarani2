<?php

namespace siu\operaciones\encuestas_respondidas;

use kernel\error_kernel_validacion;
use kernel\kernel;
use kernel\util\validador;
use siu\extension_kernel\controlador_g3w2;
use siu\guarani;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\encuestas_kolla;

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

        $materia = null;
        $materia_descr = null;
        $docente = null;
        $docente_descr = null;
        $fecha_desde = null;
        $fecha_hasta = null;

        if(isset($_GET['formulario_filtro'])){//Si hay filtros...

            $form = $this->get_form();
            $validacion_ok = $this->recuperar_filtro();
            $filtros = $form->get_datos();

            $materia_hash = $filtros['materia'];
            $docente_hash = $filtros['docente'];

            if($materia_hash){
                list($materia, $materia_descr) = $this->decodificar_materia($materia_hash);
            }

            if($docente_hash){
                list($docente, $docente_descr) = $this->decodificar_docente($docente_hash);
            }

            $fecha_desde = ($filtros['fecha_desde'])? $filtros['fecha_desde'] : null;
            $fecha_hasta = ($filtros['fecha_hasta'])? $filtros['fecha_hasta'] : null;

            $form->set_datos(array("materia_descr" => $materia_descr));
            $form->set_datos(array("docente_descr" => $docente_descr));
        }

        $encuestas_respondidas = kernel::persona()->get_encuestas_respondidas($fecha_desde, $fecha_hasta, $docente, $materia);
        $pagelet_listado_encuestas = $this->vista()->pagelet('listado_encuestas');
        $pagelet_listado_encuestas->data['encuestas_respondidas'] = $encuestas_respondidas;

        $url_ver = kernel::vinculador()->crear(kernel::ruteador()->get_id_operacion(), 'ver');
        $pagelet_listado_encuestas->add_var_js('url_ver', $url_ver);

        $url_codigo_recuperacion = kernel::vinculador()->crear(kernel::ruteador()->get_id_operacion(), 'codigo_recuperacion');
        $pagelet_listado_encuestas->add_var_js('url_codigo_recuperacion', $url_codigo_recuperacion);

    }

    function accion__ver(){

        if(kernel::request()->isPost()){

            $hubo_error = false;
            $codigo_recuperacion = null;
            $hash_validacion = null;

            try{

                try{
                    $parametro = "habilitacion";
                    $habilitacion = $this->validate_param('habilitacion', 'post', validador::TIPO_INT);
                    $parametro = "formulario";
                    $formulario = $this->validate_param('formulario', 'post', validador::TIPO_INT);
                    $parametro = "codigo externo";
                    $codigo_externo = $this->validate_param('codigo_externo', 'post', validador::TIPO_INT);
                    $parametro = "password";
                    $password = $this->validate_param('password', 'post', validador::TIPO_ALPHANUM);
                    $parametro = "anonima";
                    $anonima = $this->validate_param('anonima', 'post', validador::TIPO_INT);
                    if($anonima){
                        $parametro = "código recuperación";
                        $codigo_recuperacion = $this->validate_param('codigo_recuperacion', 'post', validador::TIPO_INT);
                        $parametro = "hash validación";
                        $hash_validacion = $this->validate_param('hash_validacion', 'post', validador::TIPO_ALPHANUM);
                    }
                }
                catch(error_kernel_validacion $e){
                    throw new \Exception(kernel::traductor()->trans('encuestas_respondidas.parametro_invalido', array("%parametro%" => $parametro)));
                }


                $data['url_kolla'] = encuestas_kolla::generar_url($habilitacion, $formulario, $codigo_externo, $password, 'ver_respuestas', $codigo_recuperacion, $hash_validacion);

            }
            catch(\Exception $e2){
                $hubo_error = true;
                kernel::renderer()->add_to_ajax_response('mensaje', $e2->getMessage());
            }

            kernel::renderer()->add_to_ajax_response('hubo_error', $hubo_error);

            if(!$hubo_error){
                $this->render_template('encuesta_respondida.twig', $data);
            }

        }
    }

    function accion__codigo_recuperacion(){

        if(kernel::request()->isPost()){

            $hubo_error = false;

            try{

                try{
                    $parametro = "habilitacion";
                    $data['habilitacion'] = $this->validate_param('habilitacion', 'post', validador::TIPO_INT);
                    $parametro = "formulario";
                    $data['formulario'] = $this->validate_param('formulario', 'post', validador::TIPO_INT);
                    $parametro = "codigo externo";
                    $data['codigo_externo'] = $this->validate_param('codigo_externo', 'post', validador::TIPO_INT);
                    $parametro = "password";
                    $data['password'] = $this->validate_param('password', 'post', validador::TIPO_ALPHANUM);
                    $parametro = "anonima";
                    $data['anonima'] = $this->validate_param('anonima', 'post', validador::TIPO_INT);
                }
                catch(error_kernel_validacion $e){
                    throw new \Exception(kernel::traductor()->trans('encuestas_respondidas.parametro_invalido', array("%parametro%" => $parametro)));
                }

            }
            catch(\Exception $e2){
                $hubo_error = true;
                kernel::renderer()->add_to_ajax_response('mensaje', $e2->getMessage());
            }

            kernel::renderer()->add_to_ajax_response('hubo_error', $hubo_error);

            if(!$hubo_error){
                $this->render_template('codigo_recuperacion.twig', $data);
            }

        }

    }

    /**
     * Solo la vista 'vista' tiene el form. Falla en otro caso
     */
    private function recuperar_filtro()
    {
        $form = $this->get_form();

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
            $this->form_builder = kernel::localizador()->instanciar('operaciones\encuestas_respondidas\filtros\builder_form_filtro');
        }

        return $this->form_builder;
    }


    function accion__buscar_materias() {

        $term = $this->validate_param('term', 'get', validador::TIPO_TEXTO, array('allowempty' => true, 'default' => ''));
        $term = utf8_decode($term);
        klog2("Termino materia a buscar", $term);

        $id_perfil_activo = kernel::persona()->get_id_perfil_activo();
        klog2("ID de perfil activo", $id_perfil_activo);

        $paquete = array();

        switch ($id_perfil_activo) {
            //Si el perfil activo es alumno
            case 'ALU':

                $carrera_activa = kernel::persona()->get_id_carrera_activa();
                klog2("ID carrera activa del alumno", $carrera_activa);

                $materias = catalogo::consultar('usuario_anonimo', 'lista_materias_carrera', array('carrera' => $carrera_activa, 'plan' => '', 'materia' => $term));

                $paquete = array_map(function($materia) {
                    return array(
                        'id' => $materia['_ID_'],
                        'label' => "({$materia['MATERIA']}) {$materia['NOMBRE']}"
                    );
                }, $materias);

                break;
            //Si el perfil activo es docente
            case 'DOC':

                $legajo_docente = kernel::persona()->get_legajo_docente();
                klog2("Legajo docente", $legajo_docente);

                $paquete = catalogo::consultar('docente', 'lista_materias', array('legajo' => $legajo_docente, 'term' => $term));

                break;
        }

        $this->render_raw_json($paquete);
    }

    function decodificar_materia($materia_hash) {

        $id_perfil_activo = kernel::persona()->get_id_perfil_activo();
        klog2("ID de perfil activo", $id_perfil_activo);

        $datos = array();

        switch ($id_perfil_activo) {
            //Si el perfil activo es alumno
            case 'ALU':

                $carrera_activa = kernel::persona()->get_id_carrera_activa();
                klog2("ID carrera activa del alumno", $carrera_activa);

                $materias = catalogo::consultar('usuario_anonimo', 'lista_materias_carrera', array('carrera' => $carrera_activa, 'plan' => '', 'materia' => ''));

                $datos = array_map(function($materia) {
                    return array(
                        'id' => $materia['_ID_'],
                        'materia' => $materia['MATERIA'],
                        'label' => "({$materia['MATERIA']}) {$materia['NOMBRE']}"
                    );
                }, $materias);

                break;
            //Si el perfil activo es docente
            case 'DOC':

                $legajo_docente = kernel::persona()->get_legajo_docente();
                klog2("Legajo docente", $legajo_docente);

                $datos = catalogo::consultar('docente', 'lista_materias', array('legajo' => $legajo_docente, 'term' => ''));

                break;
        }

        if (!empty($datos)) {
            foreach($datos as $value){
                if ($value['id'] == $materia_hash){
                    return array($value['materia'], $value['label']);
                }
            }
        }
        return array(null, null);
    }

    function accion__buscar_docentes() {
        $term = $this->validate_param('term', 'get', validador::TIPO_TEXTO);
        $term = utf8_decode($term);

        $datos = array();
        if (!is_null($term)){
            $datos = catalogo::consultar('unidad_academica', 'docentes', array('term' => $term));
        }

        $this->render_raw_json($datos);
    }

    function decodificar_docente($docente_hash) {
        $datos = catalogo::consultar('unidad_academica', 'docentes', array('term' => ""));
        if (!empty($datos)) {
            foreach($datos as $value){
                if ($value['id'] == $docente_hash){
                    return array($value['legajo'], $value['label']);
                }
            }
        }
        return array(null, null);
    }

}