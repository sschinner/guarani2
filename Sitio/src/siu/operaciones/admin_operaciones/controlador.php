<?php
namespace siu\operaciones\admin_operaciones;

use kernel\error_kernel;
use kernel\kernel;
use kernel\util\config;
use siu\extension_kernel\controlador_g3w2;
use siu\bootstrap;
use kernel\acceso\factory_perfil;

class controlador extends controlador_g3w2 {

    /**
     *
     * @return \siu\modelo\transacciones\historia_academica
     */
    function modelo() {
        return null;
    }

    //https://repositorio.siu.edu.ar/trac/g3w2/wiki/conf_op
    function accion__index() {

        $path_conf_acceso = '/conf/acceso/';
        $path_siu =  bootstrap::instancia()->get_dir_siu();
        $path_siu_conf_acceso = $path_siu.$path_conf_acceso;
        $archivos_acceso = $this->get_archivos_acceso($path_siu_conf_acceso);

        if(kernel::proyecto()->hay_personalizacion_activa()){//Si hay personalización activa
            $personalizacion_activa = kernel::proyecto()->get_personalizacion_activa();
            $path_pers = bootstrap::instancia()->get_dir_raiz().'/src/pers/'.$personalizacion_activa;
            $path_pers_conf_acceso = $path_pers.$path_conf_acceso;
            $archivos_acceso_pers = $this->get_archivos_acceso($path_pers_conf_acceso);

            $func = function($a, $b) {
                if(basename($a, ".php") == basename($b, ".php")){
                    return 0;
                }
                else{
                    return 1;
                }
            };

            //Obtengo los archivos de acceso de perfiles nuevos agregados en la personalización...
            $archivos_acceso_diff = array_udiff($archivos_acceso_pers, $archivos_acceso, $func);
            //...y los concateno con los que vienen por defecto en el core.
            foreach($archivos_acceso_diff as $archivo_acceso_diff){
                $archivos_acceso[] = $archivo_acceso_diff;
            }
        }

        foreach($archivos_acceso as $archivo_acceso){
            $array_acceso = config::load($archivo_acceso);
            $perfiles[] = factory_perfil::instancia()->construir($array_acceso['id'], kernel::proyecto()->get('bloque_acceso'));
        }

        $pagelet_operaciones = $this->vista()->pagelet('operaciones');
        $pagelet_operaciones->data['perfiles'] = $perfiles;
        $pagelet_operaciones->data['form_action'] = kernel::vinculador()->crear('admin_operaciones', 'guardar');
    }

    function accion__guardar(){

        if(kernel::request()->isPost()){

            $perfiles = kernel::request()->getPost('estado-operacion');

            $mensaje_respuesta = kernel::traductor()->trans('guardado_datos_exitoso');
            $respuesta_exitosa = true;

            foreach($perfiles as $perfil => $operaciones){

                $operaciones_inactivas = array();
                foreach($operaciones as $operacion => $estado){

                    if(!$estado){

                        $operaciones_inactivas[] = $operacion;

                    }

                }

                $perfil_obj = factory_perfil::instancia()->construir($perfil, kernel::proyecto()->get('bloque_acceso'));

                try{
                    $perfil_obj->set_operaciones_inactivas($operaciones_inactivas);
                }
                catch(error_kernel $e){
                    $mensaje_respuesta = kernel::traductor()->trans('hubo_error_al_guardar');
                    $respuesta_exitosa = false;
                    break;
                }

            }

            kernel::renderer()->add_to_ajax_response('info_estado', array(
                'mensaje' => $mensaje_respuesta,
                'exitoso' => $respuesta_exitosa
            ));


        }
        else{
            $this->nuevo_request("admin_operaciones", "index");
        }

    }

    function get_archivos_acceso($dir){

        if (file_exists($dir)) {
            $files = glob($dir.'*.php');
            if($files) return $files;
        }

        return array();
    }

}