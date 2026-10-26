<?php
namespace siu\operaciones\encuestas_kolla;

use kernel\interfaz\pagelet;
use kernel\kernel;

class pagelet_encuesta extends pagelet {
	public function get_nombre(){
        return 'encuesta';
    }

	function prepare() 
	{
		$url_kolla = $this->controlador->get_var('url_formulario');
		$domain_kolla = $this->controlador->get_var('domain_kolla');

		$this->add_var_js('domain_kolla', $domain_kolla);
		$this->add_var_js('url_accion', kernel::vinculador()->crear('encuestas_kolla', 'encuesta_respondida') );
		if (! is_null($url_kolla)) {
			$this->data['url_encuesta'] = $url_kolla;
            $encuesta_seleccionada_id = $this->controlador->get_var('encuesta_seleccionada_id');
            $this->data['encuesta_seleccionada_id'] = "#kl_".$encuesta_seleccionada_id;
			kernel::log()->add_debug('url_encuesta', $url_kolla);
		}
	}
}
?>