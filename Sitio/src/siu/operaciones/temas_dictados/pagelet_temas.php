<?php
namespace siu\operaciones\temas_dictados;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;

class pagelet_temas extends pagelet {
	public $hash;
	
	public function get_nombre(){
		return 'temas';
	}

	public function prepare() {
		$this->data['url_back'] = kernel::vinculador()->crear('temas_dictados', 'index');
		$this->data['url']['generar_pdf'] = kernel::vinculador()->crear('temas_dictados', 'generar_pdf', array('hash' => $this->hash));
		$this->data['url']['generar_excel'] = kernel::vinculador()->crear('temas_dictados', 'generar_xls', array('hash' => $this->hash));
	}
}
?>