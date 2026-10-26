<?php
namespace siu\modelo\controles;
use kernel\kernel;
use kernel\util\db\db;
use kernel\util\cache\admin_cache;
use kernel\util\log;
use siu\guarani;
use siu\errores\error_guarani_control;
use siu\modelo\datos\catalogo;
use siu\modelo\datos\util;
use siu\modelo\guarani_notificacion;

class proceso_control
{
	const FALTA_REINSCRIPCION = 0;
	const FALTA_DATOS_CENSALES = 1;
	
	static $controles_activos = true;
	static $usar_cache = true;
	
	protected $evento;
	protected $operacion;
	protected $puntos_control = array();
	// Mensajes
	protected $mensajes = array();
	
	protected $controles_reinscripcion;
	static $ejecutar_controles_reinscripcion = true;
	
	// Analisis especial
	protected $metadatos_analisis_resultado = array (
		self::FALTA_REINSCRIPCION => array(14, 15, 23, 24, 46, 64),
		self::FALTA_DATOS_CENSALES => array(81)
	);
	protected $analisis_resultado = array();
	
	static function activar($activado=true)
	{
		kernel::log()->add_debug('ACTIVAR CONTROLES', $activado);
		self::$controles_activos = $activado;
	}	

	static function usar_cache($activado=true)
	{
		kernel::log()->add_debug('ACTIVAR CACHE', $activado);
		self::$usar_cache = $activado;
	}	
	
	function __construct($operacion, $evento)
	{
		$this->operacion = $operacion;
		$this->evento = $evento;
		$this->controles_reinscripcion = $this->metadatos_analisis_resultado[self::FALTA_REINSCRIPCION];
	}
	
	static function set_ejecutar_controles_reinscripcion($ejecutar)
	{
		self::$ejecutar_controles_reinscripcion = $ejecutar;
	}
	
	function agregar_punto($id_punto, $parametros)
	{
		$clase = "modelo\controles\puntos_control\punto_control_{$id_punto}";
		$this->puntos_control[$id_punto] = kernel::localizador()->instanciar($clase, $id_punto);
		$this->puntos_control[$id_punto]->set_parametros($parametros, $this->operacion, $this->evento);
	}
	
	function ejecutar()
	{
		kernel::log()->add_debug('PROCESO_CONTROL: ejecutar puntos', array_keys($this->puntos_control));		
		if(!self::$controles_activos) return;
		foreach($this->puntos_control as $punto) {
			$info_controles = $punto->get_controles(self::$usar_cache);
			foreach($info_controles as $info_control) {
				$es_control_reinscripcion = in_array($info_control['control'], $this->controles_reinscripcion);
				if (! self::$ejecutar_controles_reinscripcion && $es_control_reinscripcion) {
					continue;
				}
				$this->ejecutar_control($punto->get_id(), $info_control);
			}
		}
		kernel::log()->add_debug('PROCESO_CONTROL: mensajes', $this->get_mensajes());	
		if($this->hay_errores()) {
			$e = new error_guarani_control('Error ejecutando controles');
			$e->set_error_reinscripcion($this->requiere_reinscripcion());
			$e->set_error_datos_censales($this->requiere_datos_censales());
			$e->set_mensajes($this->get_mensajes());
			throw $e;
		}
		return $this->get_mensajes();
	}
	
	protected function ejecutar_control($punto, $info_control)
	{	
		// Metadata para el catalogo
		$metadata = array();		
		$usar_cache = self::$usar_cache && ($info_control['cacheable'] == 1);
		if($usar_cache){
			$metadata['cache'] = admin_cache::tipo_sesion;
		} else {
			$metadata['cache'] = admin_cache::tipo_no;
		}
		$metadata['parametros'] = $info_control['metadata_parametros'];
		$metadata['parametros'][] = '__store_procedure__';
		// Metodo (varia para identificar controles en el log)
		$metodo = 'punto_'. $info_control['punto'] . '__control_' . $info_control['control'];
		// Parametros (ordenar)
		$parametros = array();
		foreach($info_control['metadata_parametros'] as $p) {
			$parametros[$p] = $info_control['parametros'][$p];
		}
		$parametros['__store_procedure__'] = $info_control['store_procedure'];
		$resultado = catalogo::consultar('controles', $metodo,  $parametros, $metadata);
		
		if((int)($resultado[0]) < 0) {
			$mensaje = new guarani_notificacion($info_control['actua_como'], util::mensaje($resultado[1]));

			// Analisis especifico de errores
			foreach($this->metadatos_analisis_resultado as $flag => $lista_controles) {
				if (in_array($info_control['control'], $lista_controles)){
					$this->analisis_resultado[$flag][] = array(
						'control'=>$info_control['control'],
						'actua_como' => $info_control['actua_como']
					);
					if ($flag == self::FALTA_REINSCRIPCION) {
						$mensaje->set_es_reinscripcion();
					}
					if ($flag == self::FALTA_DATOS_CENSALES) {
						$mensaje->set_es_datos_censales();
					}
				} 
			}

			$this->mensajes[] = $mensaje;
		}
		kernel::log()->ejecutar_control($punto, 
								$info_control['control'], 
								$info_control['actua_como'], 
								'mensaje', 
								$resultado[0], 
								$resultado[1],
								99);
	}
	
	function hay_advertencias()
	{
		foreach($this->mensajes as $msg) {
			if ($msg->es_advertencia()) return true;
		}
		return false;
	}
	
	function hay_errores()
	{
		foreach($this->mensajes as $msg) {
			if ($msg->es_error()) return true;
		}
		return false;
	}
	
	function requiere_reinscripcion()
	{
		foreach ($this->analisis_resultado as $key => $analisis) {
			foreach ($analisis as $campo) {
				if ($key == self::FALTA_REINSCRIPCION && $campo['actua_como'] == guarani_notificacion::error) {
					return true;
				}	
			}
		}
		
		return false;
	}
	
	function requiere_datos_censales()
	{
		foreach ($this->analisis_resultado as $key => $analisis) {
			foreach ($analisis as $campo) {
				if ($key == self::FALTA_DATOS_CENSALES && $campo['actua_como'] == guarani_notificacion::error) {
					return true;
				}	
			}
		}
		
		return false;
	}
	
	function get_mensajes()
	{
		$ordenados = array();
		$orden = array(guarani_notificacion::error, guarani_notificacion::advertencia, guarani_notificacion::info);
		foreach($orden as $tipo) {
			foreach($this->mensajes as $msg) {
				if ($msg->get_tipo() == $tipo) {
					$ordenados[] = $msg;
				}
			}
		}
		return $ordenados;
	}
}
?>
