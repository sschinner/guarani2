<?php

namespace siu\operaciones\acceso;

use kernel\kernel;
use kernel\nucleo\parametros;
use kernel\util\mail;
use siu\extension_kernel\controlador_g3w2;
use siu\errores\error_guarani;
use siu\errores\error_guarani_login;
use siu\errores\error_guarani_login_externo;
use kernel\util\validador;
use kernel\util\intentos_login;
use siu\guarani;
use \siu\modelo\entidades\persona;
use siu\modelo\datos\catalogo;
use siu\errores\error_guarani_usuario;
use siu\errores\error_guarani_procesar_renglones;
use \siu\modelo\guarani_notificacion;

class controlador extends controlador_g3w2
{	/**
     * @return null
     */
    function modelo()
    {
        return null;
    }
    
    function ini()
    {
    }
	
    function accion__index()
    {
	    $this->vista()->set_pagelet('login');


	    if (kernel::sesion()->abierta()) {
		    $op_defecto = kernel::persona()->perfil()->get_parametro('index');
		    $this->nuevo_request($op_defecto);
	    }
    }
	

    function accion__logout()
    {
	    kernel::login_manager()->logout();
        $this->nuevo_request('acceso', 'index');
    }

	function accion__perfil()
	{
		$perfil = $this->validate_param('id', 'get', validador::TIPO_ALPHANUM);
		kernel::persona()->set_perfil_activo($perfil);
		$op_defecto = kernel::persona()->perfil()->get_parametro('index');
		$this->nuevo_request($op_defecto);
	}
	
	function accion__cambiar_carrera()
	{
        $carrera_hash = $this->validate_param('id', 'get', validador::TIPO_ALPHANUM);
        $carrera = $this->decodificar_carrera($carrera_hash);
		kernel::persona()->set_carrera_activa($carrera);
		$op = $this->validate_param('op', 'get', validador::TIPO_TEXTO, array(
			'allowempty' => true
		));
		
		if (empty($op) || ! kernel::persona()->perfil()->existe_operacion($op)) {
			$op = kernel::persona()->perfil()->get_parametro('index');
		}
		
		
		$this->nuevo_request($op);
	}

    function decodificar_carrera($carrera_hash) {
        $lista_carreras = kernel::persona()->get_lista_carreras();
        if (!empty($lista_carreras)) {
            foreach($lista_carreras as $carrera){
                if ($carrera['id'] == $carrera_hash){
                    return $carrera['carrera'];
                }
            }
        }
        return false;
    }

	/**************************************************************************/
	// RECUPERACIÓN DE CUENTA
	/**************************************************************************/
	function accion__reset_pass()
	{
		$this->vista()->set_pagelet('recuperar_pass');
		$pagelet = $this->vista()->pagelet('login');

		if (kernel::request()->isPost()) {			
			try {
				
				$passError = false;
				$password = $this->validate_param('password', 'post', validador::TIPO_TEXTO);
				$rpassword = $this->validate_param('rpassword', 'post', validador::TIPO_TEXTO);
				$pattern = guarani::get_password_regexp();
				
				if(!$password){
					$passError = true;
				}
				elseif(!preg_match($pattern, $password)){
					$passError = true;
				}
				
				if(!$rpassword){
					$passError = true;
				}
				elseif($password != $rpassword){
					$passError = true;
				}
				
				if($passError){
					throw new error_guarani_procesar_renglones();
				}
				
				$token = $this->validate_param('token', 'post', validador::TIPO_ALPHANUM);
				$nro_inscripcion = persona::get_nro_inscripcion_from_token($token);
				persona::reset_password($nro_inscripcion, $password);
				persona::update_token($nro_inscripcion, persona::generar_token());
				$this->login_after_reset($nro_inscripcion, $password);
				$this->redirigir();
			} catch (error_guarani_procesar_renglones $e) {
				$respuesta = array();
				foreach ($e->get_renglones() as $reglon)	{
					$respuesta[] .= $reglon['msg']."<br>";
				}
				$this->add_var('errores', $respuesta);
			}
			
			$token = $this->validate_param('t', 'get', validador::TIPO_ALPHANUM);			
			persona::get_nro_inscripcion_from_token($token);
			$this->add_var('token', $token);
			$pagelet->set_estado_info(pagelet_recuperar_pass::TOKEN_CORRECTO);
		} else {
			try {
				$token = $this->validate_param('t', 'get', validador::TIPO_ALPHANUM);
				persona::get_nro_inscripcion_from_token($token);
				$this->add_var('token', $token);
				$pagelet->set_estado_info(pagelet_recuperar_pass::TOKEN_CORRECTO);
			} catch (error_guarani $e) {
				$pagelet->set_estado_info(pagelet_recuperar_pass::TOKEN_INCORRECTO);
			}
		}
	}
	
	protected function login_after_reset($nro_inscripcion, $password)
	{
//		$parametros = array('nro_inscripcion' => $nro_inscripcion);
//		$datos_basicos = catalogo::consultar('persona', 'datos_basicos', $parametros);
//		$ident = $datos_basicos['IDENTIFICACION'];
//		$this->login($ident, $password);
		//@TODO: ya no esta bien loguear al usuario derecho. Bypassea todo el esquema de login.
	}
	
	function accion__recuperar()
	{
		$this->vista()->set_pagelet('recuperar_pass');
		
		if (kernel::request()->isPost()) {
			$pais = $this->validate_param('pais', 'post', validador::TIPO_INT);
			$tipo_doc = $this->validate_param('tipo_doc', 'post', validador::TIPO_INT);
			$documento = $this->validate_param('documento', 'post', validador::TIPO_TEXTO);
			$this->add_var('documento', $documento);
			$pagelet = $this->vista()->pagelet('login');
			
			try {
				$exito = static::check_recaptcha2();
				if (! $exito) {
					throw new error_guarani_usuario(kernel::traductor()->trans('error_recaptcha'));
				}
				
				list($mail, $nro_ingreso, $usuario) = $this->get_data_persona($pais, $tipo_doc, $documento);
				//CHEQUEO CON NRO DE INGRESO SI TIENE PERFIL VÁLIDO
				$perfiles_validos = persona::get_perfiles_validos($nro_ingreso); 
				if(count($perfiles_validos) == 0){
					throw new error_guarani_usuario(kernel::traductor()->trans('login.errores.no_tiene_perfiles'));
				}
					
				if (!empty($mail)) {
					$token = persona::generar_token();
					persona::update_token($nro_ingreso, $token);
					$this->enviar_mail_recuperar_pass($mail, $token, $usuario);
					$pagelet->set_estado_info(pagelet_recuperar_pass::MAIL_ENVIADO);
					$this->add_var('mail', $mail);
				} else {
					$pagelet->set_estado_info(pagelet_recuperar_pass::MAIL_NO_EXISTENTE);
				}
				
			} catch (error_guarani_usuario $e) {
				$mensajes[] = new guarani_notificacion(guarani_notificacion::error, $e->get_mensaje());
				$this->add_var('mensajes', $mensajes);
				kernel::log()->add_error($e);
			}
		}
	}
	
	protected function get_data_persona($pais, $tipo_doc, $doc)
	{
		return persona::get_data_recuperar_pass($pais, $tipo_doc, $doc);
	}
	
	protected function enviar_mail_recuperar_pass($dir_mail, $token, $usuario)
	{
		$asunto = kernel::traductor()->trans('asunto_mail_recuperar_pass');
		$tpl = kernel::load_template('recuperar_pass/mail_recover.twig');
		$link = kernel::vinculador()->crear('acceso', 'reset_pass', array(
			't' => $token
		));
		$cuerpo = $tpl->render(array(
			'mail' => $dir_mail,
			'link' => $link,
			'user' => $usuario
		));
		
		$mail = new mail($dir_mail, $asunto, $cuerpo);
		$mail->set_html(true);
		
		$mail->enviar();
	}

	protected function redirigir()
	{
	    $this->nuevo_request(kernel::persona()->perfil()->get_parametro('index'));
	}
}
?>