<?php
namespace siu\errores;

class error_guarani_procesar_renglones extends error_guarani
{
	protected $renglones = array();
	protected $error_base = 'Error procesando renglones.';
	
	function add_renglon($id, $msg, $renglon=null)
	{
		$this->renglones[$id]['msg'] = $msg;
		$this->renglones[$id]['renglon'] = $renglon;
		$this->actualizar_mensaje();
	}
	
	function get_renglones()
	{
		return $this->renglones;
	}
	
	function hay_renglones()
	{
		return count($this->renglones) > 0;
	}
	
	private function actualizar_mensaje()
	{
		$msg = $this->error_base . "\n";
		foreach($this->get_renglones() as $id => $renglon) {
			$msg .= "[$id]: ". $renglon['msg'] .".\n";
		}
		$this->message = $msg;
	}
}

?>