<?php
namespace ejemplo01\extension_kernel;

use kernel\kernel;
use kernel\nucleo\nuevo_request;
use siu\extension_kernel\interface_helper_controlador_g3w2;

class helper_controlador_g3w2 implements interface_helper_controlador_g3w2{

    public function pre_accion(){

        //Obtengo la operación a la que se quiere acceder
        $operacion = kernel::ruteador()->get_id_operacion();
        //Obtengo la acción a la que se quiere acceder
        $accion = kernel::ruteador()->get_accion();
        //Obtengo el perfil actual
        if(kernel::sesion()->esta_seteada('__persona_perfil')) $perfil = kernel::sesion()->get('__persona_perfil');

        //Escribo en el log
        klog("pre_accion ejecutada");
        klog2("operacion", $operacion);
        klog2("accion", $accion);
        klog2("perfil", $perfil);

        //Si el perfil es alumno solamente lo dejo acceder a las operaciones de Acceso, logger y Encuestas pendientes
        if(!in_array($operacion, array("encuestas_kolla", "logger", "acceso")) && in_array($perfil, array("ALU"))){
            $nuevo_request = new nuevo_request('encuestas_kolla', 'index', false);
            $nuevo_request->set_mensaje_post_nav("¡¡¡Responde todas tus encuestas!!!");
            throw $nuevo_request;
        }

    }

}