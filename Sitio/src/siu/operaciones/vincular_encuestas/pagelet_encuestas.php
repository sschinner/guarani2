<?php

namespace siu\operaciones\vincular_encuestas;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_encuestas extends pagelet
{
    function get_nombre()
    {
        return 'encuestas';
    }

    function prepare()
    {

        /*$this->data['encuestas_a_vincular'] = $this->get_encuestas_a_vincular();

        $url_vincular = kernel::vinculador()->crear('vincular_encuestas', 'vincular');
        $this->add_var_js('url_vincular', $url_vincular);*/

    }

    /*function get_encuestas_a_vincular(){
        return catalogo::consultar('encuestas', 'get_encuestas_a_asociar_con_kolla');
    }*/

}