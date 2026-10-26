<?php
namespace siu\operaciones\_comun;
use siu\util\generador_escalas;
use siu\guarani;
use siu\extension_kernel\controlador_g3w2;
use kernel\kernel;

abstract class controlador_carga_notas extends controlador_g3w2
{
	private $escalas;
	
	/* Metodos de escalas de nota */
	public function get_escala_js()
	{
		$encabezado = $this->get_encabezado();		
		$escala_id = $encabezado['ESCALA_NOTAS'];
		
		$this->ini_escalas($escala_id);
		
		if (isset($this->escalas)){
			return $this->escalas;
		}
		
		include_once (guarani::path_escalas()."/escala_$escala_id.php");
		$nombre_escala = "escala_".$escala_id;
		$escala = new $nombre_escala();
		$escalas = $escala->get_escala();
		$this->escalas = $escalas;
		return $escalas;
	}
	
	private function ini_escalas($escala){
		$path = guarani::path_escalas()."/escala_$escala.php";
		$path_condiciones = generador_escalas::get_path_condiciones();
		if (! file_exists($path) || !file_exists($path_condiciones)) {
			kernel::log()->add_debug('path escalas', "el archivo '$path' no existe. Generando escalas...");
			generador_escalas::generar();
		}
	}
}

?>
