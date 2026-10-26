<?php

namespace siu\modelo\autenticacion;

use kernel\acceso\authentication_provider;

use kernel\kernel;
use kernel\util\config;

use OneLogin_Saml2_Auth;
use OneLogin_Saml2_Metadata;
use OneLogin_Saml2_Settings;
use siu\bootstrap;
use siu\errores\error_guarani_login;

class auth_saml extends auth_guarani{

	/**
	 * @var \OneLogin_Saml2_Auth
	 */
	protected $saml_auth;
	protected $errors;

	function __construct($id, $conf)
	{
        //Obtengo el id del bloque de acceso
        $id_bloque_acceso = bootstrap::instancia()->get_id_bloque_acceso();

        $settingsInfo = array(); 
        $settingsInfoGlobal = array(); 
        $settingsInfoBloqueAcceso = array(); 
        
        if(isset($conf['settings_file'])){
            $settings_file = $conf['settings_file'];
            //Si existe el archivo settings_file global
            if(file_exists($settings_file)){
                $settingsInfoGlobal = config::load($settings_file);
            }
        }

        if(isset($conf['accesos'][$id_bloque_acceso]['settings_file'])){
            $settings_file_bloque_acceso = $conf['accesos'][$id_bloque_acceso]['settings_file'];
            //Si existe el archivo settings_file del bloque de acceso
            if(file_exists($settings_file_bloque_acceso)){
                $settingsInfoBloqueAcceso = config::load($settings_file_bloque_acceso);
            }
        }
        //Reemplazo los valores de los archivos en cascada
        $settingsInfo = array_replace_recursive($settingsInfo, $settingsInfoGlobal, $settingsInfoBloqueAcceso);

        klog2("Configuracion SAML (settings.php)", $settingsInfo);

        //Tomo la configuración del bloque de acceso correspondiente
        $conf_bloque_acceso = isset($conf['accesos'][$id_bloque_acceso])? $conf['accesos'][$id_bloque_acceso] : array();
        //Elimino las configuraciones de los bloques de acceso
        unset($conf['accesos']);
        //Reemplazo los valores en cascada
        $conf = array_replace_recursive($conf, $conf_bloque_acceso);

        klog2("Configuracion SAML (login.php)", $conf);

        parent::__construct($id, $conf);
        $this->saml_auth  = new OneLogin_Saml2_Auth($settingsInfo);

//		$this->show_metadata();
	}


	function autenticar()
	{
		if($this->es_callback_saml()){
			$this->saml_auth->processResponse();
			$errors = $this->saml_auth->getErrors();

			if (!empty($errors)) {
				$this->errors = $errors;
				return false;
			}

			if (!$this->saml_auth->isAuthenticated()) {
				$this->errors = 'saml.no_autenticado';
				return false;
			}

//			TODO: analizar guardar el callback en este atributo para redirigir luego del login
//			if (isset($_POST['RelayState']) && OneLogin_Saml2_Utils::getSelfURL() != $_POST['RelayState']) {
//				$auth->redirectTo($_POST['RelayState']);
//			}
			try{
				$attr = $this->saml_auth->getAttributes();
				$id_persona = $this->get_clase_usuarios()->autenticar_login_saml($attr, $this->conf['local_uid'], $this->conf['saml_uid']);
				$_SESSION['samlUserdata'] = $attr;
				return $id_persona;
			} catch (error_guarani_login $e) {
				//guardar errores para mostrar en el render_login()
				kernel::log()->add_error($e);
				$this->errors = $e->get_mensaje();
			}
			return false;

		}else{

			$this->saml_auth->login();
//			$this->saml_auth->login($returnTo);
			return true;
		}

	}


	public function esta_logueado()
	{
		return isset($_SESSION['samlUserdata']);
	}



	public function get_modelo()
	{
		$datos = array();
		$datos['url_login'] = kernel::vinculador()->crear('acceso', 'index', array('auth' => 'saml'));
		if($this->errors){
			$datos['error'] = $this->errors;
		}
		return $datos;
	}


	public function logout()
	{
		//Si el logout se inicia desde g3, hace un redirect. Luego vuelve y cierra la sesion.
		if( isset($_GET) && (isset($_GET['SAMLResponse']) || isset($_GET['SAMLRequest']) ) ){
			$this->saml_auth->processSLO();
		}else {
			$this->saml_auth->logout();
		}

	}

	protected function es_callback_saml(){

		//TODO: hay algo mejor?
		return isset($_POST) && isset($_POST['SAMLResponse']);
	}

	protected function show_metadata(){
		//DEBUG PARA VER LA CONFIGURACION LOCAL
		header('Content-Type: text/xml');
		$settings = $this->saml_auth->getSettings()->getSPData();
		$samlMetadata = OneLogin_Saml2_Metadata::builder($settings);
		echo '<pre><xmp>' .$samlMetadata .'</xmp></pre>';
		die;
	}

	/**
	 * Se invoca luego de abrir sesion en el kernel (luego de una autenticacion exitosa)
	 */
	public function evt_sesion_abierta()
	{
		// TODO: Implement evt_sesion_abierta() method.
	}

	/**
	 * Se invoca cada request en el cual existe una sesiòn abierta (para actualizar maxtimes, estadisticas, etc). No se
	 * llama si la sesion se abre este request.
	 */
	public function evt_nuevo_request()
	{
		// TODO: Implement evt_nuevo_request() method.
	}
}