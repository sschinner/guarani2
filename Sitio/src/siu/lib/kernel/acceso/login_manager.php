<?php

namespace kernel\acceso;

use kernel\error_kernel;
use kernel\kernel;
use kernel\nucleo\nuevo_request;
use kernel\nucleo\sesion;


class login_manager
{

	protected static $persona;

	/**
	 * @var fuentes_autenticacion
	 */
	protected $fuentes;

	function __construct()
	{
		$conf = kernel::proyecto()->get_login_config();
		$this->fuentes = new fuentes_autenticacion($conf);
	}


	public function autenticar()
	{
        //Personalizacion para que al cerrar la ventana del navegador sin cerrar la sesion previamente
        // y luego entrar con otro usuario, cierre la sesion del anterior y se logue el nuevo
        // Solicitado por terceros que hacen uso del guarani...
        if (kernel::sesion()->abierta()) {
            if ((kernel::request()->getPost('fUsuario'))) {
                if ($_SESSION['usuarioKolla'] != kernel::request()->getPost('fUsuario')) {
                    $_SESSION['usuarioRedir'] = kernel::request()->getPost('fUsuario');
                    $_SESSION['claveRedir'] = kernel::request()->getPost('fClave');

                    $persona = $this->get_clase_persona(null);
                    kernel::set_persona($persona);
                   
                    kernel::ruteador()->get_controlador()->nuevo_request_url('https://servicios.unl.edu.ar'.$_SERVER['REDIRECT_ALIAS'].'/redireccion');
                }
            }
        }
		$session = kernel::sesion(); //session_start

		$auth = $this->get_auth_provider($session); //los auth- usan session para guardar sus cosas

		$logueado_auth = $auth != null && $auth->esta_logueado();
		$logueado_kernel = $session->abierta();


		if (!$logueado_auth && $logueado_kernel) {
			//se cerro la sesion externa, tengo que respetarlo
			klog2('Autenticacion', 'Usuario autenticado en el kernel pero no en el proveedor. Se cierra sesion');
			$session->cerrar();
			$logueado_kernel = false;
		}

		if (!$logueado_kernel) {
			if ($this->es_url_login() && $auth != null) {
				klog2('Autenticacion', 'Procesar login/credenciales');
				if ($id_persona = $auth->autenticar()) {
					klog2('Autenticacion', 'Usuario autenticado con credenciales. Se abre sesion nueva');
					$this->abrir_sesion_kernel($session, $auth, $id_persona);
					$this->instanciar_persona($session, $auth);
					throw $this->get_redireccion_ok();
				}else {
					klog2('Autenticacion', 'Autenticación inválida - reintentar');
				}
			} else {
				$this->save_referrer(); //guardo para redirigirlo cuando se autentique
			}
			klog2('Autenticacion', 'El usuario no esta autenticado - Anonimo');
		} else { //$logueado_kernel
			if($this->es_url_logout()){
				$this->logout();
				klog2('Autenticacion', 'Logout - Se cierra la sesion');
				$this->instanciar_persona($session, $auth); //pers anonima para poder hacer el redirect ...
				throw $this->get_redireccion_logout();
			}else{
				$auth->evt_nuevo_request();
				klog2('Autenticacion', 'Usuario autenticado con la sesion');
			}
		}

		$this->instanciar_persona($session, $auth);
	}

	public function get_auth_providers()
	{
		return $this->fuentes->get_fuentes_disponibles();
	}

	protected function es_url_login()
	{
		return isset($_GET['__o']) && $_GET['__o'] == 'acceso' && isset($_GET['auth']);
	}

	protected function es_url_logout()
	{
		return isset($_GET['__o']) && $_GET['__o'] == 'acceso' && isset($_GET['__a']) && $_GET['__a'] == 'logout';
	}

	public function logout()
	{
		$session = kernel::sesion();
		$auth = $this->get_auth_provider($session);

		if ($auth != null) {
			$auth->logout();
		}
		$session->cerrar();
	}


	/**
	 * @param sesion $session
	 * @return authentication_provider
	 */
	protected function get_auth_provider(sesion $session)
	{
		$auth_type = $session->get_con_default('__kernel_auth', null);
		if ($auth_type == null && isset($_GET['auth'])) {
			$auth_type = $_GET['auth'];
		}
		return $this->fuentes->instanciar_fuente($auth_type);
	}

	protected function abrir_sesion_kernel(sesion $session, authentication_provider $auth, $id_persona)
	{
//		$id_persona = $auth->get_id_persona();
		$session->abrir_sesion($id_persona, false);
		$session->set('__kernel_auth', $auth->get_id());
		$auth->evt_sesion_abierta();
	}

	protected function instanciar_persona(sesion $session, authentication_provider $auth = null)
	{
		if($autenticado = $session->abierta()){
			$id_persona = $session->get_id_persona();
			$persona = $this->get_clase_persona($id_persona);
			kernel::set_persona($persona);
		}else {
			$persona = $this->get_clase_persona(null);
			kernel::set_persona($persona);
		}
		if($auth != null){
			$auth->evt_persona_instanciada($persona, $autenticado);
		}

		return $persona;
	}

	protected function save_referrer()
	{
        if(isset($_GET['ref'])){
            $referer = $_GET['ref'];
        }

        if(isset($referer)){
            $url = parse_url($referer);
            if (strpos($url['path'], '/acceso') === false
                && strpos($url['host'], $_SERVER['SERVER_NAME']) !== false
            ) {
                $_SESSION['referer'] = $referer;
            }
        }
	}

	protected function get_redireccion_ok()
	{
		if (isset($_SESSION['referer'])) {
			$ref = $_SESSION['referer'];
			unset($_SESSION['referer']);
			$nuevo_req = new nuevo_request('index');
			$nuevo_req->set_url($ref);
		} else {
			$nuevo_req = new nuevo_request(kernel::persona()->perfil()->get_parametro('index'));
		}
		return $nuevo_req;
	}

	protected function get_redireccion_logout(){
		return $nuevo_req = new nuevo_request('acceso', 'index');
	}


	protected function get_clase_persona($id_persona = null)
	{
		if (!isset(self::$persona)) {
			if (isset($id_persona)) {
				$clase = kernel::proyecto()->get_clase_persona();
				if (!isset($clase)) {
					throw new error_kernel('La clase persona no esta definida');
				}
				self::$persona = kernel::localizador()->instanciar($clase, $id_persona);
			} else {
				$clase = kernel::proyecto()->get_clase_persona_anonima();
				if ($clase) {
					self::$persona = kernel::localizador()->instanciar($clase);
				} else {
					self::$persona = new persona_anonima();
				}
			}
		}
		return self::$persona;
	}

	function get_real_ip()
	{
		if (isset($_SERVER["HTTP_CLIENT_IP"]))
		{
			return $_SERVER["HTTP_CLIENT_IP"];
		}
		elseif (isset($_SERVER["HTTP_X_FORWARDED_FOR"]))
		{
			return $_SERVER["HTTP_X_FORWARDED_FOR"];
		}
		elseif (isset($_SERVER["HTTP_X_FORWARDED"]))
		{
			return $_SERVER["HTTP_X_FORWARDED"];
		}
		elseif (isset($_SERVER["HTTP_FORWARDED_FOR"]))
		{
			return $_SERVER["HTTP_FORWARDED_FOR"];
		}
		elseif (isset($_SERVER["HTTP_FORWARDED"]))
		{
			return $_SERVER["HTTP_FORWARDED"];
		}
		else
		{
			return $_SERVER["REMOTE_ADDR"];
		}
	}	

}

?>
