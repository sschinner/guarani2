<?php

namespace kernel;

use kernel\acceso\login_manager;
use kernel\acceso\persona_con_derechos;
use kernel\interfaz\pagina;
use kernel\interfaz\renderer;
use kernel\nucleo\proyecto;
use kernel\nucleo\interface_eventos_aplicacion;
use kernel\nucleo\interface_proyecto;
use kernel\nucleo\ruteador;
use kernel\nucleo\localizador;
use kernel\nucleo\seguridad;
use kernel\nucleo\sesion;
use kernel\nucleo\sesion_consola;
use kernel\nucleo\agente;
use kernel\util\db\dba;
use kernel\util\manejador_bolsa_opciones;
use kernel\acceso\interface_persona;
use kernel\acceso\persona_anonima;
use kernel\util\log;
use kernel\util\u;
use kernel\nucleo\recursos;

use siu\modelo\entidades\persona;
use Symfony\Component\Translation\Translator;
use Symfony\Bridge\Twig\Extension\TranslationExtension;
use Symfony\Component\Translation\MessageSelector;
use Symfony\Component\Translation\Loader\YamlFileLoader;
use kernel\interfaz\templates\Twig_Loader_Custom;
use kernel\interfaz\templates\Twig_Extension_Text;
use kernel\util\url;

class kernel
{
    static $tipo_archivo_acceso_php = 'php';
    static $tipo_archivo_acceso_xml = 'xml';

    static protected $proyecto;
    static protected $eventos_proyecto;
    static protected $ruteador;
    static protected $localizador;
    static protected $db;
    static protected $db_loader;
    static protected $db_enabled;
    static protected $log;
    static protected $pagina;
    static protected $renderer;
    static protected $tpl_loader;
    static protected $vinculador;
    static protected $manejador_bolsas;
    static protected $agente;
    static protected $seguridad;
    /**
     * @var sesion
     */
    static protected $sesion;
    static protected $persona;
    static protected $request;
    static protected $traductores = array();
    static protected $url;
    static protected $usa_pretty_urls = true;
    static protected $tipo_archivos_acceso;
	protected static $login_manager;

	static function registrar_proyecto(interface_proyecto $proyecto, interface_eventos_aplicacion $eventos)
    {
        self::$proyecto = $proyecto;
        self::$eventos_proyecto = $eventos;
        self::$eventos_proyecto->ini();
    }


    /**
     * Setea el tipo de los archivos de acceso. Esto es una configuración para conservar compatibilidad para atrás.
     * Por defecto son los archivos xml.
     * @param $tipo string. Valores posibles son kernel\kernel::$tipo_archivo_acceso_php y kernel\kernel::$tipo_archivo_acceso_xml
     */
    static function set_tipo_archivos_acceso($tipo)
    {
        self::$tipo_archivos_acceso = $tipo;
    }

    static function get_tipo_archivos_acceso()
    {
        if (! empty(self::$tipo_archivos_acceso)) {
            return self::$tipo_archivos_acceso;
        }
        // por defecto xml para no romper el resto de los archivos
        return self::$tipo_archivo_acceso_xml;
    }

    //-----------------------------------------------
    // Elementos CORE
    //-----------------------------------------------

    /**
     *
     * @return \kernel\nucleo\proyecto
     */
    static function proyecto()
    {
        if (!self::$proyecto) {
			return null;
//			throw new error('Proyecto no definido');
        }
        return self::$proyecto;
    }

    /**
     *
     * @return \kernel\nucleo\interface_eventos_proyecto
     */
    static function eventos_proyecto()
    {
        if (!self::$eventos_proyecto) {
            throw new error('eventos_proyecto no definido');
        }
        return self::$eventos_proyecto;
    }

    /**
     *
     * @return \kernel\nucleo\ruteador
     */
    static function ruteador()
    {
        if (!self::$ruteador) {
            self::$ruteador = new ruteador();
        }
        return self::$ruteador;
    }

    /**
     *
     * @return \kernel\nucleo\seguridad
     */
    static function seguridad()
    {
        if (!self::$seguridad) {
            self::$seguridad = new seguridad();
        }
        return self::$seguridad;
    }

    /**
     *
     * @return \kernel\nucleo\localizador
     */
    static function localizador()
    {
        if (!self::$localizador) {
            self::$localizador = new localizador();
        }
        return self::$localizador;
    }

    /**
     * @return \kernel\util\db\interface_db
     */
    static function db()
    {
        if (!self::$db) {
        	if (isset(self::$db_loader)) {
        		self::$db = self::$db_loader->get_db();
        	} else {
	            $param = self::proyecto()->get_parametros_db();
	            self::$db = dba::conectar($param);
        	}
        }
        return self::$db;
    }
    
    static function set_db_loader($loader)
    {
    	self::$db_loader = $loader;
    }
	
    /**
     * @return \kernel\util\log
     */
    static function log($reset=false)
    {
        if (!self::$log || $reset) {
			if (self::proyecto() !== null) { // si no hay proyecto no se loguea
				$dir = self::proyecto()->get_dir_log();
			} else {
				$dir = false;
			}
			if (self::proyecto()->get_clase_logger() !== false) {
				self::$log = kernel::localizador()->instanciar(self::proyecto()->get_clase_logger(), $dir);
			} else {
				self::$log = new \kernel\util\log($dir);
			}
        }
        return self::$log;
    }

    /**
     * Ubicacion del kernel
     *
     * @return string
     */
    static function dir()
    {
        return dirname(__FILE__);
    }

    /**
     *
     * @return sesion
     */
    static function sesion($tipo=sesion::tipo_web)
    {
        if (!self::$sesion) {
			if($tipo ==  sesion::tipo_web) {
				$handler = kernel::proyecto()->get_custom_session_handler();
				if ($handler !== false) {
					self::$sesion = $handler;
				} else {
					self::$sesion = new sesion();
				}
			} elseif ($tipo == sesion::tipo_shell) {
				self::$sesion = new sesion_consola();
			} else {
				throw new error_kernel('Tipo de sesion invalida');
			}
        }
        return self::$sesion;
    }

	static function login_manager(){
		if(!isset(self::$login_manager)){
			self::$login_manager = new login_manager();
		}
		return self::$login_manager;
	}

	static function set_persona($persona){
		self::$persona = $persona;
	}
    /**
     *
     * @return persona|persona_anonima
     */
    static function persona()
    {
	    return self::$persona;
    }

    /**
     *
     * @return \Zend_Controller_Request_Http
     */
    static function request()
    {
        if (!isset(self::$request)) {
            self::$request = new \Zend_Controller_Request_Http();
        }

        return self::$request;
    }

    /**
     *
     * @return manejador_bolsa_opciones
     */
    static function bolsas()
    {
        if (!isset(self::$manejador_bolsas)) {
            self::$manejador_bolsas = new manejador_bolsa_opciones();
        }

        return self::$manejador_bolsas;
    }

    /**
     *
     * @return agente
     */
    static function agente()
    {
        if (!isset(self::$agente)) {
            self::$agente = new agente();
        }

        return self::$agente;
    }

    //-----------------------------------------------
    // INTERFACE
    //-----------------------------------------------

    /**
     *
     * @return \kernel\interfaz\pagina
     */
    static function pagina()
    {
        if (!self::$pagina) {
            $clase_pagina = kernel::proyecto()->get_clase_pagina();
            if (empty($clase_pagina)) {
                self::$pagina = new pagina();
            } else {
                self::$pagina = kernel::localizador()->instanciar($clase_pagina);
            }            
        }
        return self::$pagina;
    }

    /**
     *
     * @return \kernel\interfaz\renderer
     */
    static function renderer()
    {
        if (!self::$renderer) {
            self::$renderer = new renderer();
        }
        return self::$renderer;
    }

    static function agregar_path_templates($path)
    {
		if (empty($path)) {
			throw new error_kernel("El path de templates es nulo");
		}
		
        kernel::template_loader()->prependPath($path);
    }

    static function load_template($path_template)
    {
		if (kernel::proyecto()->get_produccion()) {
			$cache = kernel::proyecto()->get_dir_temp();
		} else {
			$cache = false;
		}
		
		$loader = self::template_loader();
        $env = new \Twig_Environment($loader, array(
            'debug' => false,
			'cache' => $cache,
			'charset' => kernel::proyecto()->get_encoding()
        ));
        
        $env->addExtension(new TranslationExtension(kernel::traductor()));
        $env->addExtension(new Twig_Extension_Text());
		
		// Agrego variables globales para reCAPTCHA
		$env->addGlobal('usa_captcha', kernel::proyecto()->usa_captcha());
		$env->addGlobal('captcha_site_key', kernel::proyecto()->get_captcha_site_key());
		$env->addGlobal('captcha_secret_key', kernel::proyecto()->get_captcha_secret_key());
		
        try {
            $tpl = $env->loadTemplate($path_template);
            return $tpl;
        } catch (\Exception $e) {
            kernel::log()->add_error($e);
            throw $e;
        }
    }

    /**
     * @return kernel\interfaz\templates\Twig_Loader_Custom
     */
    protected static function template_loader()
    {
        if (!isset(self::$tpl_loader)) {
            require_once(self::dir() . '/../Twig/Autoloader.php');

            \Twig_Autoloader::register();

            $path = self::dir() . '/interfaz/templates';
            self::$tpl_loader = new Twig_Loader_Custom($path);
        }
        return self::$tpl_loader;
    }

	/**
	 *
	 * @return \kernel\util\vinculador
	 */
    static function vinculador()
    {
		if (!isset(self::$vinculador)) {
			self::$vinculador = new \kernel\util\vinculador(kernel::usa_pretty_urls());
		}
        return self::$vinculador;
    }

    /**
     *
     * @return \Symfony\Component\Translation\Translator 
     */
    static function traductor($dominio = 'mensajes')
    {
        if (isset(self::$traductores[$dominio])) {
            return self::$traductores[$dominio];
        }

        $default_locale = kernel::proyecto()->get_default_locale();
        $locale = new nucleo\locale($dominio, $default_locale);
        
        $locale_persona = kernel::persona() != null? kernel::persona()->get_locale(): false;
        if ($locale_persona === false) {
            $locale_persona = $default_locale;
        }
		
        $t = $locale->traductor($locale_persona);
        
        self::$traductores[$dominio] = $t;
        
        return $t;
    }
	
	/**
	 *
	 * @return kernel\util\url
	 */
	static function url()
	{
		if (!isset(self::$url)) {
			self::$url = new url(kernel::usa_pretty_urls());
		}
		
		return self::$url;
	}
	
	static function usa_pretty_urls($bool = null)
	{
		if (! is_null($bool)) {
			self::$usa_pretty_urls = $bool;
		}
		
		return self::$usa_pretty_urls;
	}

}

?>
