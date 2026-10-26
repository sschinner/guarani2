<?php

namespace siu\extension_kernel;

use kernel\nucleo\proyecto as proyecto_base;
use kernel\util\cache\admin_cache;
use siu\guarani;
use siu\bootstrap;
use Symfony\Component\Yaml\Yaml;
use kernel\kernel;
use \kernel\util\manejador_archivos;
use kernel\util\config;

class proyecto extends proyecto_base
{
	protected $m = null;

    /**
     * Retorna una instancia de la clase Memcached
     * @return \Memcached
     */
	function memcached()
	{
		if (! isset($this->m)) { 
			$conf_memcached = $this->get('memcached');
			if (empty($conf_memcached)) {
				return null;
			}
			
			$this->m = new \Memcached();
			$servers = array();
			foreach ($conf_memcached as $key => $data) {
				$servers[] = array(
					$data['host'], $data['port'], $data['peso']
				);
			}
			$this->m->addServers($servers);
		}

		return $this->m;
	}

    /**
     * Retorna todos los paths donde hay archivos de mensajes
     * @param type $dominio
     * @param type $locale
     * @return type 
     */
	protected function get_paths_mensajes($dominio, $locale)
	{
		$path_relativo = "mensajes/mensajes.$locale.php";
        return kernel::localizador()->encontrar_archivos($path_relativo);
	}

	function get_mensajes($dominio, $locale)
	{
		$apc_enabled = extension_loaded('apc');
        $apc_key = bootstrap::instancia()->get_id_bloque_acceso().'siu__mensajes';
        if ($this->get_produccion() && $apc_enabled && \apc_fetch($apc_key) !== false) {
            $mensajes = \apc_fetch($apc_key);
            return $mensajes;
        }
        
        $paths = $this->get_paths_mensajes('mensajes', $locale);
        
        if (empty($paths)) { // puede ser vacío si se pide una locale especifica; por ej: es_AR
            return array();
        }
        
        $mensajes = array();
        foreach ($paths as $path) {
            $mensajes = array_merge($mensajes, config::load($path));
        }
		
        if ($this->get_produccion()) { // hay que guardar en apc
            \apc_store($apc_key, $mensajes);
        }
        
        return $mensajes;
	}

	function get_default_locale()
	{
		return 'es';
	}
	
	function get_dir_attachment()
	{
		$dir = $this->get('dir_attachment').'/'.$this->get_bloque_acceso();
		if (! is_dir($dir)) {
			manejador_archivos::crear_arbol_directorios($dir);
		}
		
		return $dir;
	}
	
		
	function get_url_kolla(){
		return $this->get('url_kolla');
	}

    function get_accesos()
    {
        return $this->get('accesos');
    }

    function get_cant_emails_a_enviar_por_corrida_cron()
    {
        return $this->get('cant_emails_a_enviar_por_corrida_cron');
    }

    function get_cant_max_destinatarios_por_email()
    {
        return $this->get('cant_max_destinatarios_por_email');
    }
    
    function get_encuestas_cantidad_maxima_respuestas_kolla()
    {
        return $this->get('encuestas_cantidad_maxima_respuestas_kolla');
    }

    function get_encuesta_evaluar_rtas_libres_expreg()
    {
        return $this->get('encuesta_evaluar_rtas_libres_expreg');
    }
    
    function set_manejador_cache_memoria($manejador){

        switch ($manejador) {
            case 'apc':
                admin_cache::set_manejador_memoria(admin_cache::manejador_memoria_apc);
                break;
            case 'memcached':
                admin_cache::set_manejador_memoria(admin_cache::manejador_memoria_memcached);
                break;
        }

    }
}