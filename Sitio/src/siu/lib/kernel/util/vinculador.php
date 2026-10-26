<?php

namespace kernel\util;

use kernel\kernel;
use kernel\nucleo\ruteador;

class vinculador
{
	const SEPARADOR_PARAM_PRETTY_URLS = '%-%';
	const TRANSFORMADOR_BARRA = '<|>';
	const ACCION_POR_DEFECTO = 'index';
	/**
	 * Se utiliza este parámetro para que el navegador resuelva correctamentamente
	 * las urls dentro de los css en _comun en desarrollo.
	 * Si la url es: http://localhost/humanidades/rs.php/_comun/pagelets/info_materia/../../../../img/logo-transparente.png
	 * el navegador la convierte, antes de enviarla al servidor a: http://localhost/humanidades/img/logo-transparente.png
	 * sacando rs.php y perdiendo la capacidad de ver las personalizaciones.
	 * Para solucionar esto se agrega un parametro más que siempre se ignora, entonces 
	 * la url se convierte en: http://localhost/humanidades/rs.php/__ignored__/_comun/pagelets/info_materia/../../../../img/logo-transparente.png
	 * haciendo que cuando se calcule ../../.. en el navegador se obtenga correctamente
	 * http://localhost/humanidades/rs.php/img/logo-transparente.png
	 * 
	 * Vale notar que en producción este problema no existe ya que todo se traduce
	 * a un esquema de carpetas.
	 */
	const PARAM_IGNORED_RECURSOS = '__ignored__';
	/**
	 * Este es el identificador con el que viajará el valor de memoria sincronizado
	 */
	const KEY_PARAMS_SYNC = 'sync';
	
	protected $pretty_urls;
	
	function __construct($pretty_urls = false)
	{
		$this->pretty_urls = $pretty_urls;
	}
	
	function vinculos_css_pagelet($op, $nombre)
	{
		$path_pagelet = \kernel\nucleo\recursos::get_dir_pagelet($op, $nombre);
		$desc_archivo = kernel::localizador()->encontrar_css($path_pagelet, "default");
		if (empty($desc_archivo)) {
			return array();
		}
		
		$path_url = "$op/$nombre/".$desc_archivo['nombre'];
		
		// lista de namespaces donde debe aparecer el archivo
		$namespaces = array();
		
		// Si se encontró un archivo en la personalización y también existe en el 
		// ns original hay que devolver los dos
		if ($desc_archivo['es_pers'] && $desc_archivo['namespace_original']['existe']) {
			$namespaces[] = kernel::localizador()->get_nombre_namespace_original();
		}

        //Si se usan personalizaciones y hay repetidas (dos personalizaciones en cascada por bloque de acceso)
        if($desc_archivo['es_pers'] && $desc_archivo['repetidos']){
            $namespaces = array_merge($namespaces, $desc_archivo['repetidos']);
        }
        else{//sino se agrega después este para que primero quede el del namespace original, si es que existe
            $namespaces[] = $desc_archivo['namespace'];
        }

		$urls = array();
		$alias = kernel::proyecto()->get_alias();
		foreach ($namespaces as $ns) {
			if (kernel::proyecto()->get_produccion()) {
				$url_recursos = kernel::proyecto()->get_url_recursos()."/$ns/operaciones";
				$urls[] ="$url_recursos/$path_url";
			} else {
				$urls[] = "$alias/rs.php/".self::PARAM_IGNORED_RECURSOS."/$path_url?ns=$ns";
			}
		}
		
		return $urls;
	}
	
	function vinculo_css($nombre)
	{
		$path = \kernel\nucleo\recursos::get_dir_css();
		$desc_archivo = kernel::localizador()->encontrar_css($path, $nombre);
		if (empty($desc_archivo)) {
			return array();
		}
		
		$path_url = "css/".$desc_archivo['nombre'];
		
		// lista de namespaces donde debe aparecer el archivo
		$namespaces = array();
		
		// Si se encontró un archivo en la personalización y también existe en el 
		// ns original hay que devolver los dos
		if ($desc_archivo['es_pers'] && $desc_archivo['namespace_original']['existe']) {
			$namespaces[] = kernel::localizador()->get_nombre_namespace_original();
		}

        //Si se usan personalizaciones y hay repetidas (dos personalizaciones en cascada por bloque de acceso)
        if($desc_archivo['es_pers'] && $desc_archivo['repetidos']){
            $namespaces = array_merge($namespaces, $desc_archivo['repetidos']);
        }
        else{//sino se agrega después este para que primero quede el del namespace original, si es que existe
            $namespaces[] = $desc_archivo['namespace'];
        }

		$urls = array();
		$alias = kernel::proyecto()->get_alias();
		foreach ($namespaces as $ns) {
			if (kernel::proyecto()->get_produccion()) {
				$url_recursos = kernel::proyecto()->get_url_recursos()."/$ns/css";
				$urls[] ="$url_recursos/$path_url";
			} else {
				$urls[] = "$alias/rs.php/".self::PARAM_IGNORED_RECURSOS."/$path_url?ns=$ns";
			}
		}
		
		return $urls;
//		$alias = kernel::proyecto()->get_alias();
//		if (kernel::proyecto()->get_produccion()) {
//			$url_recursos = kernel::proyecto()->get_url_recursos()."/$ns";
//			$url ="$url_recursos/$relativo";
//		} else {
//			$url = "$alias/rs.php/".self::PARAM_IGNORED_RECURSOS."/$relativo?ns=$ns";
//		}
//		return $url;
	}
	
	function vinculo_js_pagelet($op, $nombre)
	{
		$path_pagelet = \kernel\nucleo\recursos::get_dir_pagelet($op, $nombre);
		$desc_archivo = kernel::localizador()->encontrar_js($path_pagelet, "pagelet_$nombre");
		if (empty($desc_archivo)) {
			return false;
		}
		
		$path_url = "$op/$nombre/".$desc_archivo['nombre'];
		$ns = $desc_archivo['namespace'];
		
		$alias = kernel::proyecto()->get_alias();
		
		if (kernel::proyecto()->get_produccion()) {
			$url_recursos = kernel::proyecto()->get_url_recursos()."/$ns/operaciones";
			return "$url_recursos/$path_url";
		} else {
			return "$alias/rs.php/$path_url";
		}
	}

    /************Métodos para cargar recursos estáticos por personalizacion***************************/

    /**
     * Genera un vinculo|URL a un archivo JS dentro de la carpeta 'www/js' por personalización
     * @param string $nombre_archivo un string con el nombre del archivo JS a vincular (sin el .js)
     * @param string $nombre_personalizacion un string con el nombre de la personalización donde se encuentra el archivo JS (por defecto lo toma del SIU)
     * @return string vinculo|URL del archivo JS
     */
    function vinculo_js_por_personalizacion($nombre_archivo, $nombre_personalizacion = 'siu')
    {
        $alias = kernel::proyecto()->get_alias();
        $path_url = "js/$nombre_archivo.js";

        if (kernel::proyecto()->get_produccion()) {
            $url_recursos = kernel::proyecto()->get_url_recursos() . "/$nombre_personalizacion";
            $url_js = "$url_recursos/$path_url";
        } else {
            $url_js = "$alias/rs.php/" . self::PARAM_IGNORED_RECURSOS . "/$path_url?ns=$nombre_personalizacion";
        }

        return $url_js;
    }

    /**
     * Genera un vinculo|URL a un archivo CSS dentro de la carpeta 'www/css' por personalización
     * @param string $nombre_archivo un string con el nombre del archivo CSS a vincular (sin el .css)
     * @param string $nombre_personalizacion un string con el nombre de la personalización donde se encuentra el archivo CSS (por defecto lo toma del SIU)
     * @return string vinculo|URL del archivo CSS
     */
    function vinculo_css_por_personalizacion($nombre_archivo, $nombre_personalizacion = 'siu')
    {
        $alias = kernel::proyecto()->get_alias();
        $path_url = "css/$nombre_archivo.css";

        if (kernel::proyecto()->get_produccion()) {
            $url_recursos = kernel::proyecto()->get_url_recursos() . "/$nombre_personalizacion";
            $url_css = "$url_recursos/$path_url";
        } else {
            $url_css = "$alias/rs.php/" . self::PARAM_IGNORED_RECURSOS . "/$path_url?ns=$nombre_personalizacion";
        }

        return $url_css;
    }

    /**
     * Genera un vinculo|URL a una imagen dentro de la carpeta 'www/img' por personalización
     * @param string $nombre_archivo un string con el nombre de la imagen a vincular (con la extensión incluida)
     * @param string $nombre_personalizacion un string con el nombre de la personalización donde se encuentra la imagen (por defecto la toma del SIU)
     * @return string vinculo|URL de la imagen
     */
    function vinculo_img_por_personalizacion($nombre_archivo, $nombre_personalizacion = 'siu')
    {
        $alias = kernel::proyecto()->get_alias();
        $path_url = "img/$nombre_archivo";

        if (kernel::proyecto()->get_produccion()) {
            $url_recursos = kernel::proyecto()->get_url_recursos() . "/$nombre_personalizacion";
            $url_img = "$url_recursos/$path_url";
        } else {
            $url_img = "$alias/rs.php/" . self::PARAM_IGNORED_RECURSOS . "/$path_url?ns=$nombre_personalizacion";
        }

        return $url_img;
    }

    /************Fin métodos para cargar recursos estáticos por personalizacion***************************/

	function vinculo_img($nombre)
	{
		$path_img = \kernel\nucleo\recursos::get_dir_img();
		$desc_archivo = kernel::localizador()->encontrar_img($path_img, $nombre);
		
		$path_url = "img/".$desc_archivo['nombre'];
		$ns = $desc_archivo['namespace'];
		
		$alias = kernel::proyecto()->get_alias();
		
		if (kernel::proyecto()->get_produccion()) {
			$url_recursos = kernel::proyecto()->get_url_recursos()."/$ns";
			return "$url_recursos/$path_url";
		} else {
			return "$alias/rs.php/$path_url";
		}
	}
	
    function vinculo_recurso($path_relativo, $ns = false)
    {
		$ns = ($ns === false) ? kernel::localizador()->get_nombre_namespace_original() : $ns;
		$alias = kernel::proyecto()->get_alias();
		if (kernel::proyecto()->get_produccion()) {
			$url_recursos = kernel::proyecto()->get_url_recursos()."/$ns";
			return "$url_recursos/$path_relativo";
		} else {
			return "$alias/$path_relativo";
		}
    }
	
	function crear_sin_chequeo($controlador, $accion = '', $parametros = array(), $opciones = array())
	{
		$s = '';

		if ((isset($opciones['ssl']) && $opciones['ssl']) || (kernel::proyecto()->get_ssl_alcance() == ruteador::SSL_ALCANCE_ALL)) {
			$s = 's';
		}

		$protocol = u::strleft(strtolower($_SERVER["SERVER_PROTOCOL"]), "/").$s;
		$server_name = kernel::proyecto()->get_server_name();
		$port = ($_SERVER['SERVER_PORT'] == 80) ? '' : ':'.$_SERVER['SERVER_PORT'];
		$alias = kernel::proyecto()->get_alias();
		$comun = $protocol."://".$server_name.$port.$alias;
		$vinculo = "$comun/$controlador/$accion";
		if (!empty($parametros)) {
			$vinculo .= $this->generate_params($parametros, $opciones);
		}
		return $vinculo;
	}

	function crear_home()
	{
		$op = kernel::persona()->perfil()->get_parametro('index');
		return $this->crear($op);
	}
	
	/**
	 * Genera un vínculo dentro de la aplicación
	 * @param string $controlador
	 * @param string $accion
	 * @param mixed $parametros los parámetros del vínculo. Si es un valor que no es un array
	 * se agrega como el primer valor posicional.
	 * Cuando es un arreglo se utilizan las claves del mismo para definir el tipo de
	 * los parámetros de la url. Si la clave es un entero se asume que se quiere un
	 * parámetro posicional (http://algo/param) y si es un string se asume un parámetro
	 * con clave (http://algo?key=param)
	 * @param array $opciones
	 *	'ssl' -> si está en true el vínculo generado tiene protocolo https
	 * @return string el vínculo
	 */
	function crear($controlador, $accion = false, $parametros = array(), $opciones = array())
	{
		if ($accion === false) {
			$accion = kernel::persona()->perfil()->get_accion_defecto($controlador);
		}
		
		$vinculo = $this->get_vinculo_accion($controlador, $accion, $opciones);
		if (!empty($parametros)) {
			if (!is_array($parametros)) {
                $parametros = array($parametros);
            }
			
			$vinculo .= $this->generate_params($parametros, $opciones);
			
		}
		
		return $vinculo;
	}
	
	protected function generate_params($params, $opciones)
	{
		$encode = ! isset($opciones['raw']) || $opciones['raw'] === false;
		
		if (! $this->pretty_urls) {
			$params_qs = array();
			foreach ($params as $key => $value) {
				$value = ($encode) ? urlencode($value) : $value;
				$params_qs[] = "$key=$value";
			}
			
			return implode('&', $params_qs);
		}
		
		$sin_clave = array();
		$con_clave = array();
		foreach ($params as $key => $value) {
			$value = ($encode) ? urlencode($value) : $value;
			if (is_int($key)) {
				$sin_clave[] = $value;
			} else {
				$con_clave[] = "$key=$value";
			}
		}
		$rs = (empty($sin_clave)) ? '' : '/';
		$rs .= implode('/',$sin_clave);
		$rs .= (empty($con_clave)) ? '' : '?';
		$rs .= implode('&', $con_clave);
		return $rs;
	}
	
    function crear_sync($controlador, $accion = false, $parametros = false, $id_bolsa = false)
    {
		if ($accion === false) {
			$accion = kernel::persona()->perfil()->get_accion_defecto($controlador);
		}
		$vinculo = $this->get_vinculo_accion($controlador, $accion);
		
		if ($parametros !== false) {
			$id_bolsa = ($id_bolsa !== false) ? $id_bolsa : $this->get_id_bolsa($controlador, $accion);
			$parametros = $this->embolsar_params($parametros, $id_bolsa);
			
			foreach ($parametros as $key => $value) {
				$vinculo .= $this->get_param_qs($key, $value);
			}
		}
		
		return $vinculo;
    }
	
    /**
     * @return string un vinculo sin parametros
     */
    protected function get_vinculo_accion($controlador, $accion, $opciones = array())
    {
		$s = '';

		if ((isset($opciones['ssl']) && $opciones['ssl']) || (kernel::proyecto()->get_ssl_alcance() == ruteador::SSL_ALCANCE_ALL)) {
			$s = 's';
		}
		
		$protocol = u::strleft(strtolower($_SERVER["SERVER_PROTOCOL"]), "/").$s;
		$server_name = kernel::proyecto()->get_server_name();
		$port = ($_SERVER['SERVER_PORT'] == 80) ? '' : ':'.$_SERVER['SERVER_PORT'];
		$alias = kernel::proyecto()->get_alias();
		
		$comun = $protocol."://".$server_name.$port.$alias;
        $url_op = kernel::persona()->perfil()->get_url_operacion($controlador);
		
		if ($this->pretty_urls) {
			if ($controlador == 'logger') {
				$accion_default = 'index';
			} else {
				$accion_default = kernel::persona()->perfil()->get_accion_defecto($controlador);
			}
			if ($accion == $accion_default) {
				return "$comun/$url_op";
			}
			return "$comun/$url_op/$accion";
		} else {
			return "$comun/index.php?o=$url_op&a=$accion";	
		}
    }

	/**
	 * Devuelve un parámetro listo para concatenar con el qs que se viene generando
	 * @param string $key 
	 * @param string $value
	 * @param boolean $raw
	 */
	protected function get_param_qs($key, $value, $opciones = array())
	{
		if (! isset($opciones['raw']) || $opciones['raw'] === false) {
			$value = urlencode($value);
		}
		if ($this->pretty_urls) {
			$value = str_replace('/', self::TRANSFORMADOR_BARRA, $value);
			$value = str_replace('\\', self::TRANSFORMADOR_BARRA, $value);
			// Si es entero ni se agrega a la url
//			$param = (is_int($key)) ? "/$value" : "/$key".self::SEPARADOR_PARAM_PRETTY_URLS."$value";
			$param = (is_int($key)) ? "/$value" : "&$key=$value";
		} else {
			$param = "&$key=$value";
		}
		
		return $param;
	}
	
	/**
	 *
	 * @param mixed $params
	 * @param boolean $id_bolsa se usa la bolsa con id $id_bolsa
	 * @return id de la celda de memoria correspondiente
	 */
	protected function embolsar_params($params, $id_bolsa)
	{
		if (! is_array($params)) {
			$params = array($params);
		}
		
		return array(
			self::KEY_PARAMS_SYNC => kernel::bolsas()->agregar($id_bolsa, $params)
		);
	}
	
    function get_id_bolsa($controlador, $accion)
    {
        return $controlador . '_' . $accion;
    }
}

?>
