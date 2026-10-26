<?php

namespace siu\operaciones\inicio_alumno;

use kernel\kernel;
use kernel\interfaz\pagelet;

class pagelet_lista_noticias extends pagelet
{
    function get_nombre()
    {
        return 'lista_noticias';
    }

    function get_js_files()
    {
        $files = parent::get_js_files();
        $files[] = kernel::vinculador()->vinculo_recurso("js/jquery.dotdotdot.min.js");
        return $files;
    }

    function prepare()
    {
        $this->add_var_js('ver_mas', kernel::traductor()->trans('ver_mas'));
        $this->add_var_js('ocultar', kernel::traductor()->trans('ocultar'));

        $noticias = $this->controlador->info_lista_noticias();
		$this->data['noticias'] = $noticias;
    }
}
?>