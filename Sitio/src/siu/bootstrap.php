<?php
namespace siu;
use \kernel\kernel;
use kernel\util\config;
use siu\errores\error_guarani;
use siu\errores\error_guarani_config;
use \siu\guarani;
use \siu\eventos_proyecto;
use kernel\util\u as util;
use kernel\util\manejador_archivos;
include 'func_util.php';
/**
 * Configura el KERNEL
 */
class bootstrap
{
	const URL_IMAGENES_ALUMNOS = '_img_alumnos';
    static protected $instancia;
	protected $config;
	protected $login_config;
	protected $ws_config;
	protected $bloque_acceso;
	protected $bloque_acceso_id;
	protected $acceso_consola;

	static function cargar($consola = false, $acceso = false)
    {
        if (!isset(self::$instancia)) {
            self::$instancia = new bootstrap();
        }
		self::$instancia->_cargar($consola, $acceso);
    }
	
	/**
	 * 
	 * @return \siu\bootstrap
	 */
	static function instancia()
	{
		if (! isset(self::$instancia)) {
			die("no se puede solicitar la instancia sin antes haber invocado al m�todo cargar");
		}
		
		return self::$instancia;
	}
	
	static function registrar_autoload()
	{
		if (!isset(self::$instancia)) {
            self::$instancia = new bootstrap();
        }
		self::$instancia->configurar_autoloader(true);
	}

	protected function __construct()
    {
    }

    protected function _cargar($consola, $acceso)
	{
		if (!$acceso) {
			$config = self::cargar_config_archivo();
			$acceso = key($config['accesos']);
		}
	
		$this->acceso_consola = $consola;
		$this->bloque_acceso_id = $acceso;		
		$this->cargar_config();
		$this->configurar_autoloader();
		$this->check_extensiones();
		$this->configurar_localizador();
		// @todo la carga del proyecto no es necesario si el request es de tipo "carga de recurso web".
		

		$this->cargar_proyecto();		
	}

	//-------------------------------------------------

	static function get_dir_raiz()
	{
		return \realpath(self::get_dir_siu() . '/../..');
	}

	static function get_dir_instalacion()
	{
		return self::get_dir_raiz() . '/instalacion';
	}

	static function get_dir_siu()
	{
		return dirname(__FILE__);
	}

	//-------------------------------------------------
	// 0) Test extensiones
	//-------------------------------------------------
	protected function check_extensiones()
	{
		$this->check_extension('gd');
		if (manejador_archivos::es_windows()) {
			// $this->check_extension('pdo_informix');	forzar odbc ac�?
		} else {
			$this->check_extension('pdo_informix');
		}
		if (!function_exists('xml_parser_create')) {
			$error = "La extensi�n de php 'xml' no est� instalada.";
			$url_doc = 'http://repositorio.siu.edu.ar/trac/g3w2/wiki/doc/instalacion/';
			echo("$error<br><a href='$url_doc'>Ver documentaci�n</a>");
			die();
		}
		
	}
	
	private function check_extension($extension)
	{
		if (!\extension_loaded($extension)) {
			$error = "La extensi�n de php '$extension' no est� instalada.";
			$url_doc = 'http://repositorio.siu.edu.ar/trac/g3w2/wiki/doc/instalacion/';
			echo("$error<br><a href='$url_doc'>Ver documentaci�n</a>");
			die();
		}
	}
	
	//-------------------------------------------------
	// 1) Cargar Configuracion
	//-------------------------------------------------

	/**
	 * @todo cache
	 */
	protected function cargar_config()
	{
		$this->config = self::cargar_config_archivo();
		$this->test_errores_configuracion();
		$this->bloque_acceso = $this->config['accesos'][$this->get_id_bloque_acceso()];
	}

	protected static function cargar_config_archivo()
	{
		// cargo el archivo
		require_once(self::get_dir_siu() . '/lib/kernel/util/config.php');
		$path =  self::get_dir_instalacion() . '/config.php';
		$config = \kernel\util\config::load($path);
		if(!isset($config['global'])) {
			throw new \Exception('Error en la configuraci�n, falta bloque \'global\'');
		}
		
		if (! isset($config['global']['accesos'])) {
			throw new \Exception("Error en la configuraci�n, falta bloque 'accesos' dentro del bloque 'global'");
		}
		
		return $config['global'];
	}
	
	private function test_errores_configuracion()
	{
		$this->test_error_config_global('produccion');
		$this->test_error_config_global('usar_personalizaciones');
		$this->test_error_config_global('sesion_maxtime');
		$this->test_error_config_global('sesion_timeout');
		$this->test_error_config_global_activo('google_analytics', 'account');
		$this->test_error_acceso($this->get_id_bloque_acceso());
		$this->test_error_acceso($this->get_id_bloque_acceso(), 'ua');
		$this->test_error_acceso($this->get_id_bloque_acceso(), 'database');
	}

	/** 
	 * Testea que si existe un parametro activo en true en la entrada de configuraci�n * testea que todos los par�metros en la lista de $obligatorios est�n seteados. 
	 * Si existe la entrada pero no tiene el parametro activo se pone en false 
	 */ 
	private function test_error_config_global_activo($entrada, $obligatorios) 
	{ 
        if (! is_array($obligatorios)) { 
            $obligatorios = array($obligatorios); 
        } 
        if (isset($this->config[$entrada])) { 
            if (! isset($this->config[$entrada]['activo'])) { 
                $this->config[$entrada]['activo'] = false; 
                return; 
            } 
            if (isset($this->config[$entrada]['activo']) && $this->config[$entrada]['activo'] == true) { 
	            foreach ($obligatorios as $obligatorio) { 
                    if (! isset($this->config[$entrada][$obligatorio]) || empty($this->config[$entrada][$obligatorio])) { 
                        $error = "Error en configuraci�instalacion/config.php). La entrada '$entrada' se encuentra activa pero no se incluye el parametro '$obligatorio'"; 
                        echo $error; 
	                    die(); 
                    } 
	            } 
            } 
        } 
	} 	
	
	private function test_error_config_global($parametro)
	{
		if (!isset($this->config[$parametro])) {
			$path =  self::get_dir_instalacion() . '/config_template.php';
			$config  = \kernel\util\config::load($path);
			unset($config['global']['accesos']);
			$error = "Error en configuraci�n (instalacion/config.php). Falta par�metro '$parametro' en bloque 'global'. Para m�s informaci�n vea la <a href='http://repositorio.siu.edu.ar/trac/g3w2/wiki/doc/instalacion/conf'>documentaci�n</a>";
			$ejemplo = str_replace("'$parametro'", "<b>'$parametro'</b>",var_export($config['global'], true));
			echo("$error<br>Ejemplo:<pre>$ejemplo</pre>");
			die();
		}
	}
	
	private function test_error_acceso($bloque_acceso, $parametro = false)
	{
		if ($parametro === false) {
			if (! isset($this->config['accesos'][$bloque_acceso])) {
				$path =  self::get_dir_instalacion() . '/config_template.php';
				$config  = \kernel\util\config::load($path);
				$error = "Error en configuraci�n (instalacion/config.php). El bloque de acceso '$bloque_acceso' no existe. Para m�s informaci�n vea la <a href='http://repositorio.siu.edu.ar/trac/g3w2/wiki/doc/instalacion/conf'>documentaci�n</a>";
				$ejemplo = str_replace("'accesos'", "<b>'accesos'</b>",var_export($config['global'], true));
				echo("$error<br>Ejemplo:<pre>$ejemplo</pre>");
				die();
			}
		} else {
			if (! isset($this->config['accesos'][$bloque_acceso][$parametro])) {
				$path =  self::get_dir_instalacion() . '/config_template.php';
				$config  = \kernel\util\config::load($path);
				$error = "Error en configuraci�n (instalacion/config.php). Falta el par�metro '$parametro' en el bloque de acceso '$bloque_acceso'. Para m�s informaci�n vea la <a href='http://repositorio.siu.edu.ar/trac/g3w2/wiki/doc/instalacion/conf'>documentaci�n</a>";
				$ejemplo = str_replace("'accesos'", "<b>'accesos'</b>",var_export($config['global'], true));
				$ejemplo = str_replace("'$parametro'", "<b>'$parametro'</b>",$ejemplo);
				echo("$error<br>Ejemplo:<pre>$ejemplo</pre>");
				die();
			}
		}
	}

	private function cargar_login_config()
	{
		$path =  self::get_dir_instalacion() . '/login.php';
		if(!file_exists($path)){
			throw new \Exception("No se encuetra el archivo '$path', es obligatorio.");
		}
		$config = config::load($path);
		return $config;
	}
	
	private function cargar_servicios_web_config()
	{
		$path =  self::get_dir_instalacion() . '/servicios_web_config.php';
		if (!file_exists($path)) return array();
		return config::load($path);
	}

	/**
	 * Recupera la UNIDAD academica actual en el archivo de apache
	 * @return string
	 */
	function get_id_bloque_acceso()
	{
		if ($this->acceso_consola) {
			// si es acceso consola la ua viene preseteada por par�metro
			return $this->bloque_acceso_id;
		}
		if(isset($_SERVER['ACC_ID'])) {
			return $_SERVER['ACC_ID'];
		}

		throw new \Exception('La entrada $_SERVER["ACC_ID"] no est� definida, hay un error en la configuraci�n');
	}

	private function get_alias()
	{
		if ($this->acceso_consola) {
			return 'SHELL';
		}		
		if(isset($_SERVER['ACC_ALIAS'])) {
			return $_SERVER['ACC_ALIAS'];
		}
		return null;
	}
	
	//-------------------------------------------------
	// 2) Autoload y Localizador
	//-------------------------------------------------

	protected function configurar_autoloader($delay_pers = false)
	{
		$dir = self::get_dir_siu();
		require_once($dir.'/lib/kernel/util/UniversalClassLoader.php');
                require_once($dir.'/lib/vendor/autoload.php'); //cargo deps composer
		$loader = new \kernel\util\UniversalClassLoader();
        $loader->registerNamespace('Symfony',self::get_dir_raiz() . '/src/siu/lib');		//por ahora solo por consola!
		$loader->registerNamespace('siu', self::get_dir_raiz() . '/src');
        $loader->registerNamespace('kernel',self::get_dir_raiz() . '/src/siu/lib');

		if (! $delay_pers && $this->existe_pers()) {
			$this->registrar_namespaces_pers($loader);
		}
		$loader->register();
        
        // Registrar Zend
        util::agregar_dir_include_path(self::get_dir_raiz().'/src/siu/lib');
        require_once 'Zend/Loader/Autoloader.php';
        \Zend_Loader_Autoloader::getInstance();
	}

	private function existe_pers()
	{
		return $this->config['usar_personalizaciones'] && isset($this->bloque_acceso['personalizacion']);
	}

	private function get_pers()
	{
		if(!$this->existe_pers()) {
			throw new \Exception('No hay una personalizacion definida');
		}
		
		$pers = $this->bloque_acceso['personalizacion'];
		if (is_string($pers)) {
			$pers = array($pers);
		}
		
		return $pers;
	}
	
	private function registrar_namespaces_pers($loader)
	{
		$pers = $this->get_pers();
		$dir_pers = self::get_dir_raiz() . '/src/pers';

		foreach ($pers as $plugin) {
			$loader->registerNamespace($plugin, $dir_pers);
		}
	}
	
	protected function configurar_localizador()
	{
		$dir = self::get_dir_raiz() . '/src';
		kernel::localizador()->nuevo_namespace('siu', $dir, 'original');
		if ($this->existe_pers()) {
			$this->config_pers_localizador();
		}
	}

	private function config_pers_localizador()
	{
		$pers = $this->get_pers();
		$dir_pers = self::get_dir_raiz() . '/src/pers';

		foreach ($pers as $plugin) {
			kernel::localizador()->nuevo_namespace($plugin, $dir_pers);
		}		
	}

	//-------------------------------------------------
	// 3) Proyecto y eventos del kernel
	//-------------------------------------------------

	protected function cargar_proyecto()
	{

        //Configuraci�n global
        $config_global = $this->config;
        //Le quito los bloques de accesos a la configuraci�n global
        unset($config_global['accesos']);
        //Ac� va todo lo que NO puede ser configurable por bloque de acceso
        unset($this->bloque_acceso['manejador_cache_memoria']);
        unset($this->bloque_acceso['memcached']);
        //Reemplazo en la configuraci�n global lo configurado en el bloque de acceso (configuraci�n en cascada).
        $config_final = array_replace_recursive($config_global, $this->bloque_acceso);

		// VALORES por DEFECTO
		if (!isset($config_final['intentos_login_captcha'])) {
			$config_final['intentos_login_captcha'] = 3;
		}
		$produccion = $config_final['produccion'];
		$id_bloque_acceso = $this->get_id_bloque_acceso();
		$dir_log = self::get_dir_instalacion() . '/log/' . $id_bloque_acceso;
		$dir_cache = self::get_dir_instalacion() . '/cache/' . $id_bloque_acceso;
		$dir_instalacion = self::get_dir_instalacion();
		$dir_temp = (isset($config_final['dir_temp'])) ? $config_final['dir_temp'] : self::get_dir_instalacion() . '/temp/' . $id_bloque_acceso;
		$dir_attachment = (isset($config_final['dir_attachment'])) ? $config_final['dir_attachment'] : $dir_temp;
		$clase_persona = "modelo\\entidades\\persona";
		$clase_fuente_usuarios = "modelo\\autenticacion\\fuente_usuarios_guarani";
		$clase_pagina = "extension_kernel\\pagina";
		$clase_logger = "extension_kernel\\log";
        $url_recursos = (isset($config_final['url_recursos']))	? $config_final['url_recursos']	: $this->get_alias().'/_comp';
        $ssl_alcance = (isset($config_final['ssl']['alcance']))? $config_final['ssl']['alcance'] : 'none';
        $ssl_redirigir_ssl = (isset($config_final['ssl']['redirigir_ssl']))? $config_final['ssl']['redirigir_ssl'] : true;
        $manejador_cache_memoria = (isset($config_final['manejador_cache_memoria'])) ?  $config_final['manejador_cache_memoria'] : 'apc';
		$memcached =	(isset($config_final['memcached']))		? $config_final['memcached']	: null;
		$smtp =			(isset($config_final['smtp']))			? $config_final['smtp']			: null;
		$login_config = $this->cargar_login_config();
		$servicios_web_config = $this->cargar_servicios_web_config();
		$server_name = (isset($config_final['server_name'])) ? $config_final['server_name'] : null;
        
		$usa_captcha = (isset($config_final['captcha']['activo']) && $config_final['captcha']['activo'] === true);
		$intentos_login_captcha = ($usa_captcha) ?  $config_final['captcha']['intentos_login'] : 0;
		$site_key_captcha = ($usa_captcha && isset($config_final['captcha']['site_key'])) ?  $config_final['captcha']['site_key'] : 'site_key';
		$secret_key_captcha = ($usa_captcha && isset($config_final['captcha']['secret_key'])) ?  $config_final['captcha']['secret_key'] : 'secret_key';
		$salt = ($config_final['salt']) ?  $config_final['salt'] : 'no_salt';

        $usa_proxy = (isset($config_final['proxy']['activo']) && $config_final['proxy']['activo'] === true);
        $parametros_proxy = ($usa_proxy) ?  $config_final['proxy'] : 0;


		// Fotos
		if(isset($config_final['imagen_alumno_dir'])){
			$imagen_alumno_dir = $config_final['imagen_alumno_dir'];
		}else{
			$imagen_alumno_dir = $this->get_dir_siu()."/www/_comp/" . self::URL_IMAGENES_ALUMNOS;
		}
		if(isset($config_final['imagen_alumno_url'])){
			$imagen_alumno_url = $config_final['imagen_alumno_url'];
		}else{
			$imagen_alumno_url = $url_recursos.'/'.self::URL_IMAGENES_ALUMNOS;
		}
		$url_kolla = isset($config_final['url_kolla']) ? $config_final['url_kolla']: "http://localhost/kolla/3.3/";

		$personalizacion = '';
		if ($this->existe_pers()) {
			$personalizacion = reset($this->get_pers());
		}

        $default_dir_ops_inactivas = self::get_dir_instalacion()."/operaciones_inactivas";
        $dir_ops_inactivas = isset($config_final['dir_ops_inactivas']) ? $config_final['dir_ops_inactivas'] : $default_dir_ops_inactivas;

		$ga_params = (isset($config_final['google_analytics'])) ? $config_final['google_analytics'] : array('activo' => false);

        $cant_emails_a_enviar_por_corrida_cron = (isset($config_final['cant_emails_a_enviar_por_corrida_cron']))? $config_final['cant_emails_a_enviar_por_corrida_cron'] : 0;

        $cant_max_destinatarios_por_email = (isset($config_final['cant_max_destinatarios_por_email']))? $config_final['cant_max_destinatarios_por_email'] : 0;
        
        $encuestas_cantidad_maxima_respuestas_kolla = (isset($config_final['encuestas_cantidad_maxima_respuestas_kolla'])) ? $config_final['encuestas_cantidad_maxima_respuestas_kolla'] : 0;
        
		$encuesta_evaluar_rtas_libres_expreg = (isset($config_final['encuesta_evaluar_rtas_libres_expreg'])) ? $config_final['encuesta_evaluar_rtas_libres_expreg'] : false;

		$proyecto = new extension_kernel\proyecto(array(
            'db'				=> $this->bloque_acceso['database'],
            'alias'				=> $this->get_alias(),
            'produccion'		=> $produccion,
			'personalizacion'	=> $personalizacion,
            'sesion_maxtime'	=> $config_final['sesion_maxtime'],
            'sesion_timeout'	=> $config_final['sesion_timeout'],
            'url_recursos'		=> $url_recursos,
			'manejador_cache_memoria' => $manejador_cache_memoria,
			'memcached'			=> $memcached,
            'dir_instalacion'	=> $dir_instalacion,
            'bloque_acceso'     => self::get_id_bloque_acceso(),
            'dir_log'			=> $dir_log,
            'dir_cache'			=> $dir_cache,
            'dir_temp'			=> $dir_temp,
            'imagen_alumno_dir'	=> $imagen_alumno_dir,
            'imagen_alumno_url'	=> $imagen_alumno_url,
            'salt'				=> $salt,
            'dir_attachment'	=> $dir_attachment,
            'fuente_usuarios'	=> $clase_fuente_usuarios,
            'clase_persona'		=> $clase_persona,
            'clase_persona_anonima' => false,
            'clase_pagina'		=> $clase_pagina,
            'clase_logger'		=> $clase_logger,
            'server_name'		=> $server_name,
			'usa_captcha'		=> $usa_captcha,
            'intentos_login_captcha' => $intentos_login_captcha,
			'captcha_site_key' => $site_key_captcha,
			'captcha_secret_key' => $secret_key_captcha,
            'usa_proxy' => $usa_proxy,
            'parametros_proxy' => $parametros_proxy,
			'barra_dev'		=> 
					isset($config_final['log']['activo'])		&&
					$config_final['log']['activo'] == true		&&
					isset($config_final['log']['barra_dev'])	&&
					$config_final['log']['barra_dev'] == true,
            'smtp'  => $smtp,
            'ssl_alcance'  => $ssl_alcance,
            'ssl_redirigir_ssl'  => $ssl_redirigir_ssl,
			'login_config' => $login_config,
			'url_kolla' => $url_kolla,
			'servicios_web' => $servicios_web_config,
            'dir_ops_inactivas' => $dir_ops_inactivas,
            'ga_params' => $ga_params,
            'accesos' => $this->config['accesos'],
            'cant_emails_a_enviar_por_corrida_cron' => $cant_emails_a_enviar_por_corrida_cron,
            'cant_max_destinatarios_por_email' => $cant_max_destinatarios_por_email,
            'encuestas_cantidad_maxima_respuestas_kolla' => $encuestas_cantidad_maxima_respuestas_kolla,
			'encuesta_evaluar_rtas_libres_expreg' => $encuesta_evaluar_rtas_libres_expreg
        ));
		
        try {
            $eventos = kernel::localizador()->instanciar('extension_kernel\eventos_aplicacion');
        } catch (\Exception $e) {
            die('Debe crear la clase eventos_aplicacion a partir del archivo eventos_aplicacion_template.php. Mensaje: "'.$e->getMessage().'"');
        }
//        \kernel\util\cache\admin_cache::set_manejador_memoria(\kernel\util\cache\admin_cache::manejador_memoria_memcached);
		// registro el proyecto
        kernel::set_tipo_archivos_acceso(kernel::$tipo_archivo_acceso_php);
		guarani::set_ua_id($this->bloque_acceso['ua']);
        kernel::registrar_proyecto($proyecto, $eventos);
		kernel::proyecto()->set_encoding('iso-8859-1');
		kernel::proyecto()->set_bloque_acceso($id_bloque_acceso);
        kernel::proyecto()->set_manejador_cache_memoria($manejador_cache_memoria);

		// Inicializacion del LOG
		if(isset($config_final['log']['activo']) &&
				$config_final['log']['activo'] == true){
			kernel::log()->set_activo(true);
			if(isset($config_final['log']['nivel'])){
				try {
					kernel::log()->set_nivel($config_final['log']['nivel']);
				} catch (\Exception $e) {
					die($e->getMessage());
				}
			}
		}

		// Inicializacion handle de debug
		if(isset($config_final['ini_debug']) &&
				$config_final['ini_debug'] == true){
			$debug = kernel::localizador()->instanciar('debug');
			$debug->ini();
			kernel::log()->add_debug('Perfil de debug', get_class($debug));
		}
		
		if (!$this->acceso_consola && ! version::es_valida()) {
			$ver_requerida = version::requerida();
			die("La base no est� actualizada, se requiere que se haya ejecutado alguno de los siguientes scripts: '$ver_requerida'");
		}
	}
}
?>