<?php

namespace siu\operaciones\gestion_encuestas;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_formulario extends pagelet
{
    function get_nombre()
    {
        return 'formulario';
    }

    function get_alcances_a_vincular(){
        return catalogo::consultar('encuestas', 'alcances_a_vincular');
    }
	 
    function prepare()
    {

        $alcances_a_vincular = $this->get_alcances_a_vincular();
        $encuestas_alcances = array();
        //Hago corte de control por encuesta...
        foreach($alcances_a_vincular as $alcance){
            $encuestas_alcances[$alcance['ENCUESTA']]['encuesta_titulo'] = $alcance['ENCUESTA_TITULO'];
            $encuestas_alcances[$alcance['ENCUESTA']]['kolla_id_encuesta'] = $alcance['KOLLA_ID_ENCUESTA'];
            $encuestas_alcances[$alcance['ENCUESTA']]['alcances'][$alcance['ALCANCE']] = array(
                'alcance_titulo' => $alcance['ALCANCE_TITULO'],
                'fecha_desde' => $alcance['FECHA_DESDE'],
                'fecha_hasta' => $alcance['FECHA_HASTA']
            );
        }
		$this->data['encuestas_alcances'] = $encuestas_alcances;

        $url_sincronizar = kernel::vinculador()->crear('gestion_encuestas', 'sincronizar');
        $this->add_var_js('url_sincronizar', $url_sincronizar);

		if ($this->controlador->hay_var('mensaje')) {
			$this->data['mensaje'] = $this->controlador->get_var('mensaje');
		}
		
    }
}
?>
