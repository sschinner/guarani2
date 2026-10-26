<?php
namespace siu\operaciones\historial_asistencias;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;

class pagelet_asistencias extends pagelet {
	public $hash;
	
	public function get_nombre(){
		return 'asistencias';
	}

	public function prepare() {
		$this->data['url_back'] = kernel::vinculador()->crear('historial_asistencias', 'index');
		$this->data['url']['generar_pdf'] = kernel::vinculador()->crear('historial_asistencias', 'generar_pdf', array('hash' => $this->hash));
		$this->data['url']['generar_excel'] = kernel::vinculador()->crear('historial_asistencias', 'generar_xls', array('hash' => $this->hash));
	}
}
?>