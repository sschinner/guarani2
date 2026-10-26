<?php

namespace personalizacionUA\operaciones\vincular_encuestas;

use kernel\kernel;
use siu\extension_kernel\controlador_g3w2;
use siu\modelo\datos\catalogo;
use siu\guarani;
use kernel\util\validador;
use personalizacionUA\modelo\transacciones\encuestas;
//use siu\modelo\transacciones\encuestas;

class controlador extends \siu\operaciones\vincular_encuestas\controlador {

    function get_ids_encuestas_kolla() {

        $encuestas_kolla = $this->modelo()->get_encuestas_kolla();

        $ids_encuestas_kolla = array();
        foreach ($encuestas_kolla as $encuesta_kolla) {
            $ids_encuestas_kolla[] = $encuesta_kolla['encuesta'];
        }

        $encuestas_kolla = $this->modelo()->get_encuestas_kolla_egresados();

        foreach ($encuestas_kolla as $encuesta_kolla) {
            $ids_encuestas_kolla[] = $encuesta_kolla['encuesta'];
        }

        return $ids_encuestas_kolla;
    }
    
    function accion__ver(){
        $encuestasEgresadosAdmitidas = array('123');
        $hubo_error = false;
        
        try{

            if(kernel::request()->isPost()){
                try{
                    $parametro = "encuesta de Kolla";
                    $encuesta_kolla_a_ver = $this->validate_param('encuesta_kolla_a_ver', 'post', validador::TIPO_INT);
                   
                }
                catch(\Exception $e){
                    throw new \Exception(kernel::traductor()->trans('vincular_encuestas.parametro_invalido', array("%parametro%" => $parametro)));
                }

                if(!in_array($encuesta_kolla_a_ver, $this->get_ids_encuestas_kolla())){
                    
                    throw new \Exception(kernel::traductor()->trans('vincular_encuestas.encuesta_no_existe_en_kolla', array("%encuesta%" => $encuesta_kolla_a_ver)));
                } 
                if (in_array($encuesta_kolla_a_ver,$encuestasEgresadosAdmitidas)){
                    $encuesta['encuesta'] = $this->modelo()->get_encuesta_kolla_egresado($encuesta_kolla_a_ver);
                }else{
                    $encuesta['encuesta'] = $this->modelo()->get_encuesta_kolla($encuesta_kolla_a_ver);
                }

                $hubo_error = false;
                kernel::renderer()->add_to_ajax_response('hubo_error', $hubo_error);
            }
        }
        catch(\Exception $e){
            $hubo_error = true;
            kernel::renderer()->add_to_ajax_response('hubo_error', $hubo_error);
            kernel::renderer()->add_to_ajax_response('mensaje', $e->getMessage());
        }

        if(!$hubo_error){
            $this->render_template('detalle.twig', $encuesta);
        }
    }

    function accion__vincular(){

        try{
            if(kernel::request()->isPost()){
                try{
                    $parametro = "encuesta";
                    $encuesta = $this->validate_param('encuesta', 'post', validador::TIPO_INT);
                    $parametro = "encuesta de Kolla";
                    $encuesta_kolla_a_vincular = $this->validate_param('encuesta_kolla_a_vincular', 'post', validador::TIPO_INT);
                }
                catch(\Exception $e){
                    throw new \Exception(kernel::traductor()->trans('vincular_encuestas.parametro_invalido', array("%parametro%" => $parametro)));
                }

                if(!in_array($encuesta_kolla_a_vincular, $this->get_ids_encuestas_kolla())){
                   
                    throw new \Exception(kernel::traductor()->trans('vincular_encuestas.encuesta_no_existe_en_kolla', array("%encuesta%" => $encuesta_kolla_a_vincular)));
                }

                $parametros['encuesta'] = $encuesta;
                $parametros['kolla_id_encuesta'] = $encuesta_kolla_a_vincular;
                catalogo::consultar('encuestas', 'asociar_kolla_id_encuesta', $parametros);

                kernel::renderer()->add_to_ajax_response('hubo_error', false);
                kernel::renderer()->add_to_ajax_response('mensaje', kernel::traductor()->trans('vincular_encuestas.vinculacion_exitosa'));
            }
        }
        catch(\Exception $e){
            kernel::renderer()->add_to_ajax_response('hubo_error', true);
            kernel::renderer()->add_to_ajax_response('mensaje', $e->getMessage());
        }

    }

}
