<?php

namespace kernel\nucleo;

use kernel\kernel;
/**
 * 	Resuelve los paths siu/personalizacion
 *
 * @todo cache
 *
 */
class localizador
{

    protected $namespaces = array();
	
	protected $ns_original;
	
	protected $chequear_archivos = true;
	
	/**
	 * Agrega un nuevo namespace al localizador
	 * @param string $nombre el nombre del namespace
	 * @param string $dir el directorio raíz del namespace
	 * @param string $tipo el tipo. Puede ser 'original' o 'personalizacion'. Por defecto 'personalizacion' 
	 */
    function nuevo_namespace($nombre, $dir, $tipo = 'personalizacion')
    {
		if ($tipo == 'original') {
			$this->ns_original = array(
				'nombre' => $nombre,
				'dir'	 => $dir
			);
		} else {
			$this->namespaces[$nombre] = $dir;
		}
    }
	
    function get_namespaces()
    {
		$namespaces = $this->namespaces;
		$namespaces[$this->ns_original['nombre']] = $this->ns_original['dir'];
        return $namespaces;
    }
	
	function get_namespaces_pers()
    {
		$namespaces = $this->namespaces;
		if(!kernel::proyecto()->hay_personalizacion_activa()) $namespaces[$this->ns_original['nombre']] = $this->ns_original['dir'];
        return $namespaces;
    }
	
	function get_nombre_namespace_original()
	{
		return $this->ns_original['nombre'];
	}
	
	/**
	 * En el caso que no se personalice es recomendado desactivar el chequeo de 
	 * existencia de archivos
	 * @param boolean $valor 
	 */
	function set_chequear_existencia_archivo($valor)
	{
		$this->chequear_archivos = $valor;
	}

    //----------------------------------------------

	/**
	 * Devuelve todos los paths existentes de un directorio a partir de su dirección relativa
	 * @param string $path_relativo un path relativo a un directorio
	 * @return un arreglo cuyos elementos son pares NOMBRE_NAMESPACE => FULL_PATH. Hay 
	 * una entrada en este arreglo por cada namespace donde existe $relativo. La primer
	 * entrada es la del namespace original (siu)
	 */
	function get_paths_dir($path_relativo)
	{
		$rs = array();
		$path_ns_original = $this->get_path_absoluto($this->ns_original['dir'], $this->ns_original['nombre'], $path_relativo, false);
		if (! empty($path_ns_original)) {
			$rs[$this->ns_original['nombre']] = $path_ns_original;
		}
        
		foreach ($this->namespaces as $id => $dir) {
            $path = $this->get_path_absoluto($dir, $id, $path_relativo, false);
			if (! $path === false) {
				$rs[$id] = $path;
			}
        }
		
		return $rs;
	}
    
    /**
     * Encuentra, a partir de un path relativo, todos los archivos que existen en
     * ese path en todos los namespaces
     */
    function encontrar_archivos($path_relativo)
    {
		$rs = array();
        $path_ns_original = $this->get_path_absoluto($this->ns_original['dir'], $this->ns_original['nombre'], $path_relativo);
		if ($path_ns_original !== false) {
            $rs[$this->ns_original['nombre']] = $path_ns_original; 
        }
        
		foreach ($this->namespaces as $id => $dir) {
            $path = $this->get_path_absoluto($dir, $id, $path_relativo);
			if (! $path === false) {
				$rs[$id] = $path;
			}
        }
		
		return $rs;
    }
	
	function encontrar_path_archivo($dir_relativo, $nombre)
	{
		$pathinfo = pathinfo($nombre);
		$filename = $pathinfo['filename'];
		$ext = $pathinfo['extension'];
		$info = $this->encontrar_archivo($dir_relativo, $filename, $ext, true);
		return $info['path'];
	}
	
	function encontrar_template($dir_relativo, $nombre)
	{
		return $this->encontrar_archivo($dir_relativo, $nombre, 'twig');
	}

	function encontrar_css($dir_relativo, $nombre)
	{
		return $this->encontrar_archivo($dir_relativo, $nombre, 'css', false);
	}
	
	function encontrar_js($dir_relativo, $nombre)
	{
		return $this->encontrar_archivo($dir_relativo, $nombre, 'js', false);
	}
	
	function encontrar_img($dir_relativo, $nombre)
	{
		$pathinfo = pathinfo($nombre);
		$filename = $pathinfo['filename'];
		$ext = $pathinfo['extension'];
		return $this->encontrar_archivo($dir_relativo, $filename, $ext, true);
	}
	
	/**
	 * Devuelve el archivo indicado buscando automaticamente el que más se acerque
	 * al agente actual.
	 * @param string $dir_relativo
	 * @param string $nombre
	 * @param string $extension 
	 * @param boolean $force_exist si no existe y este flag está activado lanza una excepción
	 * @return array un descriptor del archivo encontrado
	 *  'nombre' => el nombre del archivo
	 *  'path' => el path completo del archivo
	 *  'namespace' => namespace donde se encuentra
	 */
	protected function encontrar_archivo($dir_relativo, $nombre, $extension, $force_exist = true)
	{
		$agente_actual = kernel::agente()->get_tipo();
		
		$nombre_completo = '';
		$descriptor_archivo = false;
		
		// Si no es browser cambia el nombre del archivo
		if (! kernel::agente()->es_browser()) {
			$nombre_completo = $nombre."_$agente_actual.$extension";
			$descriptor_archivo = $this->buscar_archivo($dir_relativo.'/'.$nombre_completo);
		}
		
		// Si es browser o no se encontró un archivo específico del agente actual
		// hay que cargar el archivo de browser
		if (kernel::agente()->es_browser() || ! $descriptor_archivo['existe']) {
			$nombre_completo = "$nombre.$extension";
			$descriptor_archivo = $this->buscar_archivo($dir_relativo.'/'.$nombre_completo);
		}
		
		if (! $descriptor_archivo['existe']) {
			if ($force_exist) {
				throw new \Exception("LOCALIZADOR: No existe el recurso solicitado. Nombre: '$dir_relativo/$nombre_completo'");
			} else {
				return array();
			}
		}
		
		if ($descriptor_archivo['hay_repetidos']) {
			$pers1 = $descriptor_archivo['repetidos']['pers1'];
			$pers2 = $descriptor_archivo['repetidos']['pers2'];
			kernel::log()->add_debug("LOCALIZADOR: El recurso se encuentra repetido entre las personalizaciones '$pers1' y '$pers2'. Nombre: '$dir_relativo/$nombre_completo'", array());
		//	throw new \Exception("LOCALIZADOR: El recurso se encuentra repetido entre las personalizaciones '$pers1' y '$pers2'. Nombre: '$dir_relativo/$nombre_completo'");
		}
		
		return array(
			'nombre' => $nombre_completo,
			'path'	 => $descriptor_archivo['path'],
			'namespace' => $descriptor_archivo['namespace'],
			'es_pers' => $descriptor_archivo['es_pers'],
			'namespace_original' => array(
				'existe' => $descriptor_archivo['namespace_original']['existe'],
				'path' => $descriptor_archivo['namespace_original']['path']
			)
		);
	}
	
    function path_recurso($relativo, $force_ns = false)
    {
		$descriptor_archivo = $this->buscar_archivo($relativo, $force_ns);
		
		if (! $descriptor_archivo['existe']) {
			throw new \Exception("LOCALIZADOR: No existe el recurso solicitado. Nombre: '$relativo'");
		}
		
		if ($descriptor_archivo['hay_repetidos']) {
			$pers1 = $descriptor_archivo['repetidos']['pers1'];
			$pers2 = $descriptor_archivo['repetidos']['pers2'];
			kernel::log()->add_debug("LOCALIZADOR: El recurso se encuentra repetido entre las personalizaciones '$pers1' y '$pers2'.  Nombre: '$relativo'", array());
			//throw new \Exception("LOCALIZADOR: El recurso se encuentra repetido entre las personalizaciones '$pers1' y '$pers2'. Nombre: '$relativo'");
		}
		
		return $descriptor_archivo['path'];
    }
		
	/**
	 *
	 * @param string $relativo
	 * @param mixed $force_ns el namespace donde se debe buscarlo. Si es false se lo
	 * busca en todos los namespaces activos y se le da prioridad a los que están 
	 * en las personalizaciones
	 * @return array un arreglo:
	 *	'existe' => si existe o no el archivo
	 *  'hay_repetidos' => si hay más de una personalización que tiene el archivo
	 *  'path' => el path completo del archivo. Si no existe esto es false 
	 *  'es_pers' => si el archivo se encontró o no en una personalización
	 *  'namespace_original' => 
	 *		'existe' => si existe o no el archivo en el ns original
	 *		'path' => el path absoluto del archivo. Si no existe esto es false
	 * Los elementos en el primer nivel del arreglo se refieren al archivo deseado
	 * (si se encontró uno en la personalización trae la información de este y sino
	 * trae la del namespace original). Se agrega la entrada namespace_original
	 * para el caso de los css que se tienen que agregar todos en cascada
	 */
	function buscar_archivo($relativo, $force_ns = false)
	{
		$rs = array();
		$rs['hay_repetidos'] = false;
		$path_ns_original = false;
		if ($force_ns !== false) {
			if ($force_ns == $this->ns_original['nombre']) {
				$path_ns_original = $this->get_path_absoluto($this->ns_original['dir'], $this->ns_original['nombre'], $relativo);
			} else {
				$path = $this->get_path_absoluto($this->namespaces[$force_ns], $force_ns, $relativo);
				$personalizado = $path;
				$personalizacion = $force_ns;
			}
		} else {
			$path_ns_original = $this->get_path_absoluto($this->ns_original['dir'], $this->ns_original['nombre'], $relativo);

			foreach ($this->namespaces as $id => $dir) {
				$path = $this->get_path_absoluto($dir, $id, $relativo);
				if (! $path === false) {
					if (isset($personalizado)) {
						$rs['hay_repetidos'] = true;
						$rs['repetidos'] = array(
							'pers1' => $personalizacion,
							'pers2' => $id,
							'nombre' => $relativo
						);
					}
					$personalizado = $path;
					$personalizacion = $id;
				}
			}
		}
				
		$rs['existe']  = isset($personalizado) || $path_ns_original !== false;
		$rs['path']    = (isset($personalizado)) ? $personalizado : $path_ns_original;
		$rs['namespace'] = (isset($personalizacion)) ? $personalizacion : $this->ns_original['nombre'];
		$rs['es_pers'] = isset($personalizacion);
		$rs['namespace_original'] = array(
			'existe' => $path_ns_original !== false,
			'path'	 => $path_ns_original
		);
		return $rs;
	}
	
	protected function get_path_absoluto($dir, $ns, $relativo, $es_archivo = true)
	{
		$absoluto = $dir . "/$ns/" . $relativo;
		if (! $this->chequear_archivos) {
			return $absoluto;
		}
		
		if ($es_archivo && is_file($absoluto)) {
			return $absoluto;
		} else if (!$es_archivo && is_dir($absoluto)) {
			return $absoluto;
		} else {
			return false;
		}
	}

    protected function buscar_clase($clase, $force_original = false)
    {
        $relativo = str_replace('\\', DIRECTORY_SEPARATOR, $clase) . '.php';
		
		$original = $this->get_path_clase($this->ns_original['dir'], $this->ns_original['nombre'], $relativo, $clase);
		
        foreach ($this->namespaces as $id => $dir) {
			$clase_completa = $this->get_path_clase($dir, $id, $relativo, $clase);
			if ($clase_completa !== false) {
				if (isset($personalizado)) {
					kernel::log()->add_debug("LOCALIZADOR: La clase se encuentra repetida entre las personalizaciones '$id' y '$personalizacion'. Clase: '$clase'", array());
					//throw new \Exception("LOCALIZADOR: La clase se encuentra repetida entre las personalizaciones '$id' y '$personalizacion'. Clase: '$clase'");
				}
				$personalizado = $clase_completa;
				$personalizacion = $id;
			}
        }
		
		if (!isset($personalizado) && $original === false) { // no existe la clase
			throw new \Exception("LOCALIZADOR: No existe la clase solicitada: $clase.\n path_relativo: $relativo.");
        }
		
		if (! isset($personalizado) || $force_original) { // Si no está personalizado se devuelve el original
			return $original;
		} else {
			return $personalizado;
		}
    }
	
	protected function esta_personalizada($clase)
	{
		$relativo = str_replace('\\', DIRECTORY_SEPARATOR, $clase) . '.php';
		
		$personalizado = false;
		foreach ($this->namespaces as $id => $dir) {
			$clase_completa = $this->get_path_clase($dir, $id, $relativo, $clase);
			if ($clase_completa !== false) {
				if ($personalizado !== false) {
					kernel::log()->add_debug("LOCALIZADOR: La clase se encuentra repetida entre las personalizaciones '$id' y '$personalizacion'. Clase: '$clase'", array());
				//	throw new \Exception("LOCALIZADOR: La clase se encuentra repetida entre las personalizaciones '$id' y '$personalizacion'. Clase: '$clase'");
				}
				$personalizado = $clase_completa;
				$personalizacion = $id;
			}
        }
		
		return $personalizado !== false;
	}
	
	protected function buscar_clase_pers($clase)
	{
		$relativo = str_replace('\\', DIRECTORY_SEPARATOR, $clase) . '.php';
		
		$personalizado = false;
		foreach ($this->namespaces as $id => $dir) {
			$clase_completa = $this->get_path_clase($dir, $id, $relativo, $clase);
			if ($clase_completa !== false) {
				if ($personalizado !== false) {
					kernel::log()->add_debug("LOCALIZADOR: La clase se encuentra repetida entre las personalizaciones '$id' y '$personalizacion'. Clase: '$clase'", array());
					//throw new \Exception("LOCALIZADOR: La clase se encuentra repetida entre las personalizaciones '$id' y '$personalizacion'. Clase: '$clase'");
				}
				$personalizado = $clase_completa;
				$personalizacion = $id;
			}
        }
		
		return $personalizado;
		
	}
	
	protected function buscar_clase_original($clase)
	{
		$relativo = str_replace('\\', DIRECTORY_SEPARATOR, $clase) . '.php';
		$original = $this->get_path_clase($this->ns_original['dir'], $this->ns_original['nombre'], $relativo, $clase);
		return $original;
	}
	
	/**
	 * Devuelve el path (namespace) de una clase. Si no existe el archivo
	 * devuelve falso
	 */
	protected function get_path_clase($dir, $ns, $relativo, $clase)
	{
		$path = $this->get_path_absoluto($dir, $ns, $relativo);
		if ($path === false) {
			return false;
		}
		
		return '\\' . $ns . '\\' . $clase;
	}

    function existe_clase($clase)
    {
        try {
            $this->buscar_clase($clase);
        } catch (\Exception $e) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Instancia una clase
	 * @param string $clase El nombre relativo de la clase que se quiere instanciar
	 * @param mixed $parametros El parámetro (null por defecto) que se le va
	 * a pasar al constructor de la clase
	 * @return instancia de $clase localizada
     */	
    function instanciar($clase, $parametros = null)
    {
        $clase_completa = $this->buscar_clase($clase);
        $objeto = new $clase_completa($parametros);
        return $objeto;
    }

	/**
	 * Instancia una clase con un constructor con N parámetros
	 * @param string $clase El nombre relativo de la clase que se quiere instanciar
	 * @param array $parametros los parámetros a pasarle a la clase. Se mapean al 
	 * constructor posicionalmente
	 * @return instancia de $clase
	 */
	function instanciar_params_array($clase, $parametros)
	{
		$clase_completa = $this->buscar_clase($clase);
		$reflejo = new \ReflectionClass($clase_completa);
		//return $reflejo->newInstanceArgs($parametros);
		//gsdalmolin: solucion parsererror sin estar logueado
		if(empty($parametros)){
            		$objeto = $reflejo->newInstanceArgs();
		}
		else{
            		$objeto = $reflejo->newInstanceArgs($parametros);
		}
return $objeto;
	}
	
    function instanciar_singleton($clase, $parametros = null)
    {
        $clase_completa = $this->buscar_clase($clase);
        return $clase_completa::instancia($parametros);
    }
	
	/**
	 * Invoca una función estática
	 */
	function invocacion_estatica($clase, $metodo, $parametros = array())
	{		
		if ($this->esta_personalizada($clase)) {
			$clase_completa = $this->buscar_clase($clase);
			$invocacion_pers = "$clase_completa::$metodo";
			if (is_callable($invocacion_pers)) {
				return call_user_func_array($invocacion_pers, $parametros);
			} else {
				$clase_original = $this->buscar_clase_original($clase);
				$invocacion = "$clase_original::$metodo";
				if ($clase_original !==false && is_callable($invocacion)) {
					return call_user_func_array($invocacion, $parametros);
				} else {
					throw new \kernel\error_kernel("El método estático no está definido: '$invocacion' '$invocacion_pers'");
				}
			}
		} else {
			$clase_original = $this->buscar_clase_original($clase);
			$invocacion = "$clase_original::$metodo";
			if ($clase_original !==false && is_callable($invocacion)) {
				return call_user_func_array($invocacion, $parametros);
			} else {
				throw new \kernel\error_kernel("El método estático no está definido: '$invocacion'");
			}
		}
	}

	function constante($clase, $nombre)
	{
		if ($this->esta_personalizada($clase)) {
			$clase_completa = $this->buscar_clase($clase);
			$invocacion_pers = "$clase_completa::$nombre";
			if (defined($invocacion_pers)) {
				return constant($invocacion_pers);
			} else {
				$clase_original = $this->buscar_clase_original($clase);
				$invocacion = "$clase_original::$nombre";
				if ($clase_original !==false && defined($invocacion)) {
					return constant($invocacion);	
				} else {
					throw new \kernel\error_kernel("La constante no está definida: '$invocacion' '$invocacion_pers'");
				}
			}
		} else {
			$clase_original = $this->buscar_clase_original($clase);
			$invocacion = "$clase_original::$nombre";
			if ($clase_original !==false && defined($invocacion)) {
				return constant($invocacion);	
			} else {
				throw new \kernel\error_kernel("La constante no está definida: '$invocacion'");
			}
		}
	}
}

?>
