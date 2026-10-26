<?php
namespace siu\errores;

class error_guarani_control extends error_guarani
{
	protected $mensajes;
	protected $error_reinscripcion = false;
	protected $error_datos_censales = false;
	
	function set_mensajes($mensajes)
	{
		$this->mensajes = $mensajes;
	}
	
	function get_mensajes()
	{
		return $this->mensajes;
	}
	
	//--------------------------------------------------
	
	function set_error_reinscripcion($estado=true)
	{
		$this->error_reinscripcion = $estado;
	}
	
	function requiere_reinscripcion()
	{
		return $this->error_reinscripcion;
	}

	//--------------------------------------------------
	
	function set_error_datos_censales($estado=true)
	{
		$this->error_datos_censales = $estado;
	}
	
	function requiere_datos_censales()
	{
		return $this->error_datos_censales;
	}
}

?>