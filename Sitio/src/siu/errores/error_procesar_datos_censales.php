<?php
namespace siu\errores;

class error_procesar_datos_censales extends error_guarani_usuario
{
	protected $renglones = array();
	protected $error_base = 'Error procesando datos censales.';
	
	function agregar_mensaje($id, $msg)
	{
		$this->renglones[$id] = $msg;
		$this->actualizar_mensaje();
	}
	
	function get_renglones()
	{
		return $this->renglones;
	}
	
	function hay_errores()
	{
		return count($this->renglones) > 0;
	}
	
	private function actualizar_mensaje()
	{
		$msg = $this->error_base . "\n";
		foreach($this->get_renglones() as $id => $mensaje) {
			$msg .= "[$id]: ". $mensaje .".\n";
		}
		$this->message = $msg;
	}
	
	function get_codigo_response()
	{
		return -100;
	}
	
	function get_params()
	{
		$res = array('campos_error' => array());
		foreach (array_keys($this->renglones) as $key) {
			$res['campos_error'][] = $key;
		}
		return $res;
	}
}

?>