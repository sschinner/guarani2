<?php
namespace siu\operaciones\configuracion;

use kernel\kernel;
use kernel\util\validador;
use kernel\util\mail;
use siu\guarani;
use siu\extension_kernel\controlador_g3w2;
use siu\modelo\datos\catalogo;
use siu\errores\error_guarani_procesar_renglones;
use \siu\errores\error_guarani;
use \siu\modelo\entidades\persona;

class controlador extends controlador_g3w2
{
	function modelo()
	{

	}
	
	function ini()
	{
		$this->controlar_csrf_accion('guardar');
	}
	
	function accion__index()
	{
		
	}


	function accion__eliminar_token()
	{
		guarani::persona()->eliminar_token(null, guarani::persona()->get_nro_inscripcion());
		$this->render_ajax(kernel::traductor()->trans('configuracion.mensaje.mail_token.cancel'));
	}
	
	function accion__guardar()
	{
		$respuesta = array();
		$passData = kernel::request()->getPost('password');
		$checkData = kernel::request()->getPost('checks');
		$loginData = kernel::request()->getPost('login');
		if($passData) {
			$respuesta['password'] = $this->guardar_pass($passData);
		}
		if($checkData) {
			$respuesta['checks'] = $this->guardar_checks($checkData, $loginData);
		}

		$respuesta['csrf_token'] = $this->generar_csrf();
		$this->render_ajax(kernel::traductor()->trans("configuracion.titulo.cambios.realizados"), $respuesta);
	}
	

	function guardar_pass($data)
	{   
		$usuario = guarani::persona()->get_identificacion();
		$actual_pass = $data['password_actual'];
		$nuevo_pass = $data['password'];
		
		try {
			$respuesta = guarani::persona()->actualizar_password($usuario, $actual_pass, $nuevo_pass);	
		} catch (error_guarani_procesar_renglones $e) {
			$respuesta['cod'] = -1;
			$respuesta['cont'] = "";
			foreach ($e->get_renglones() as $reglon)	{
				$respuesta['cont'] .= $reglon['msg']."<br>";
			}
		}
		return $respuesta;
	}

	function guardar_checks($data, $login)
	{
		$conf = guarani::persona()->get_configuracion();
		$nro_inscripcion = guarani::persona()->get_nro_inscripcion();
		$recibe_mail = $data['recibe_mail'];
		$mail = strtolower($data['mail']);
		$respuesta = array('cont'=>'Guardado', 'cod'=>1);
		if($mail != $conf['E_MAIL'] && $data['manual'] == 'true') {
			//Enviar mail confirmación
			$token = persona::generar_token();
			persona::update_token($nro_inscripcion, $token, $mail);
			$this->enviar_cambio_mail($mail, $token, $login);
			$respuesta = array('cod'=>2, 'mail_old'=>$conf['E_MAIL'], 'mail_new'=>$mail, 'l'=>print_r($login,true));
			$mail = $conf['E_MAIL'];
		} 
		guarani::persona()->actualizar_configuracion($nro_inscripcion, $recibe_mail, $mail);
		return $respuesta;
	}
	
	function accion__cambiar_mail() 
	{
		$conf = guarani::persona()->get_configuracion();
		$nro_inscripcion = guarani::persona()->get_nro_inscripcion();
		$token = $this->validate_param('t', 'get', validador::TIPO_ALPHANUM);
		$login = json_decode(urldecode(kernel::request()->get('s')),true);
		$nro_inscripcion1 = persona::get_nro_inscripcion_from_token($token);
		if($nro_inscripcion != $nro_inscripcion1) {
			throw new error_guarani('El token fue gestionado para otra persona.');
		}
		$mail = persona::get_mail_from_token($token);
		guarani::persona()->actualizar_configuracion($nro_inscripcion, $conf['RECIBE_MAIL'], $mail);
		guarani::persona()->set_configuracion();

		guarani::persona()->eliminar_token($token);
		$this->vista()->pagelet('configuraciones')->add_mensaje_js('cambio_mail_exitoso', kernel::traductor()->trans('configuracion.mensaje.cambio_mail'));
	}

	function accion__cuentas_externas(){
		kernel::renderer()->add($this->vista()->pagelet('cuentas_externas'));
	}

	function accion__vincular_cuenta_externa(){
		$proveedor = $this->validate_param(0, 'get', validador::TIPO_TEXTO);
		$manager = $this->get_administrador_cuentas_externas();
		$url_procesar = kernel::vinculador()->crear('configuracion', 'vincular_cuenta_externa', $proveedor);

		try{
			$datos = $manager->obtener_datos_cuenta($proveedor, $url_procesar);
			$datos['nro_inscripcion'] = guarani::persona()->get_nro_inscripcion();

			if($exito = catalogo::consultar('persona', 'vincular_login_externo', $datos)){
				$mje = array('f' =>$proveedor, 'vinculada' => true) ;
			}else {
				$mje = array('error' => 'No se pudo vincular la cuenta!') ;
			}
		}catch (error_kernel $e){
			kernel::log()->add_error($e);
			$mje = array('error' => 'Error al procesar el pedido!');//que paso?
		}
		$mje = json_encode($mje);

		echo "
			<script>
				window.opener.returnPopup($mje);
				window.close();
			</script>
		";
		throw new finalizador_request();
	}


	function accion__desvincular_cuenta_externa()
	{
		$proveedor = $this->validate_param(0, 'get', validador::TIPO_TEXTO);
		if($exito = catalogo::consultar('persona', 'desvincular_login_externo', array(
			'nro_inscripcion' => guarani::persona()->get_nro_inscripcion(), 'proveedor' => $proveedor))){
			$respuesta = array('estado' => 'ok', 'proveedor' => $proveedor) ;
		}else {
			$respuesta = array('estado' => 'error', 'error' => 'No se pudo remover la cuenta') ; //no la pongo en mjes porque no debería pasar
		}
		$this->render_ajax('Guardado', $respuesta);
	}



	/**
	 * @return authentication_provider
	 */
	public function get_administrador_cuentas_externas(){
		$lm = kernel::login_manager();

		foreach ($lm->get_auth_providers() as $auth){
			if($auth->get_id() == 'cuenta_ext'){
				return $auth;
			}
		}
		return null;

	}

	protected function enviar_cambio_mail($dir_mail, $token)
	{
		$asunto = kernel::traductor()->trans('asunto_cambio_mail_notificaciones');
		$tpl = kernel::load_template('configuraciones/mail.twig');
		$link = kernel::vinculador()->crear('configuracion', 'cambiar_mail', array(
			't' => $token
		));
		$cuerpo = $tpl->render(array(
			'mail' => $dir_mail,
			'link' => $link
		));
		
		$mail = new mail($dir_mail, $asunto, $cuerpo);
		$mail->set_html(true);
		
		$mail->enviar();
	}
}
?>