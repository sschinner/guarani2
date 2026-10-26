<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of guarani_notificacion
 *
 * @author andres
 */
namespace siu\modelo;
class guarani_notificacion implements \kernel\interface_notificacion
{
	const error = 'E';	
	const advertencia = 'A';
	const info = 'M';
	
	const mensaje_tipo = 'mtipo';
	const mensaje_cuerpo = 'mcuerpo';
	
	protected $tipo;
	protected $mensaje;
	protected $tiene_links = false;
	protected $es_reinscripcion  = false;
	protected $es_datos_censales = false;
	
	// se meten estas variables para no modificar el macro_notificaciones
	public $mtipo;
	public $mcuerpo;
	public $raw;
	function __construct($tipo, $mensaje)
	{
		$this->set_tipo($tipo);
		$this->set_mensaje($mensaje);
	}
	
	function es_advertencia()
	{
		return $this->tipo == self::advertencia;
	}
	
	function es_error()
	{
		return $this->tipo == self::error;
	}
	
	function es_info()
	{
		return $this->tipo == self::info;
	}
	
	function get_tipo()
	{
		return $this->tipo;
	}
		
	function set_tipo($tipo)
	{
		$this->tipo = $tipo;
		$this->mtipo = $tipo;
	}
	
	function set_mensaje($mensaje)
	{
		$this->mensaje = $mensaje;
		$this->mcuerpo = $mensaje;
	}
	
	function get_mensaje()
	{
		return $this->mensaje;
	}
	
	function set_es_reinscripcion()
	{
		$this->es_reinscripcion = true;
	}
	
	function set_es_datos_censales()
	{
		$this->es_datos_censales = true;
	}
	
	function es_de_reinscripcion()
	{
		return $this->es_reinscripcion;
	}
	
	function es_de_datos_censales()
	{
		return $this->es_datos_censales;
	}
	
	function set_tiene_links($tiene)
	{
		$this->tiene_links = $tiene;
		$this->raw = $this->tiene_links;
	}
	
	function como_arreglo()
	{
		return array(
			self::mensaje_tipo => $this->tipo,
			self::mensaje_cuerpo => $this->mensaje
		);
	}
}

?>
