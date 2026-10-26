<?php
namespace siu\operaciones\creditos;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;

class pagelet_detalle extends pagelet {
	public function get_nombre(){
        return 'detalle';
    }

	public function prepare() {
        $this->data['url_volver'] = kernel::vinculador()->crear('creditos', 'index');
    }
}
?>