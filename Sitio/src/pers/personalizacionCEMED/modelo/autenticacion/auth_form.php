<?php

namespace personalizacionCEMED\modelo\autenticacion;

use kernel\kernel;
use kernel\util\intentos_login;
use siu\errores\error_guarani;
use siu\errores\error_guarani_login;
use siu\guarani;

class auth_form extends \siu\modelo\autenticacion\auth_form {

    protected $id_persona = null;
    protected $usarios_bd;

    /**
     * @var error_guarani_login
     */
    protected $error_login = null;

    /**
     * Si es existoso tiene que llamar 	$this->session->abrir_sesion($id_persona, false);
     * Si no guardar los errores necesarios para renderizarse en render_login
     * @return bool si tuvo exito
     */
    public function autenticar($esNuevo=false) {
        
        if (kernel::request()->isPost()) {
            
             $_SESSION['usuarioKolla']="";
             $_SESSION['claveKolla']="";
            if ((kernel::request()->getPost('usuario'))) {
                $usuario = kernel::request()->getPost('usuario');
                $pass = md5(kernel::request()->getPost('clave'));
                $_SESSION['claveKolla']=$pass;
           } else if ((kernel::request()->getPost('fUsuario'))) {
                     $usuario = kernel::request()->getPost('fUsuario');
                     $pass = kernel::request()->getPost('fClave');
                     $_SESSION['claveKolla']=$pass;
            } 
            $_SESSION['usuarioKolla']=$usuario;
            if($esNuevo){
            //Personalizacion para que al cerrar la ventana del navegador sin cerrar la sesion previamente
            // y luego entrar con otro usuario, cierre la sesion del anterior y se logue el nuevo
            // No es lo mejor ni mucho menos lo optimo, pero dado los tiempos es lo mas rapido.    
                echo '<script>parent.window.location.reload(true);</script>';
            }
            try {
                if ($this->controlar_captcha_login($usuario)) {
                    $this->check_recaptcha_login();
                }
                return $this->id_persona = $this->validar_user_pass($usuario, $pass);
            } catch (error_guarani_login $e) {
                //guardar errores para mostrar en el render_login()
                $this->error_login = $e;
                intentos_login::error($usuario);
                kernel::log()->add_error($e);
            }
        }
        return null;
    }

}
