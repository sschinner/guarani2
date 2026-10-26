<?php
namespace siu\operaciones\historia_academica;

use kernel\interfaz\pagelet;
use kernel\kernel;
use kernel\util\u;

class pagelet_info_historia extends pagelet
{
    function get_nombre()
    {
        return 'info_historia';
    }

    function prepare()
    {
        $this->add_var_js('url_datos_historia_academica', kernel::vinculador()->crear('historia_academica', 'index'));
        $this->add_var_js('url_detalle_examen', kernel::vinculador()->crear('historia_academica', 'detalle_examen'));
        $this->add_var_js('url_detalle_promocion', kernel::vinculador()->crear('historia_academica', 'detalle_promocion'));
        $this->add_var_js('url_detalle_cursada', kernel::vinculador()->crear('historia_academica', 'detalle_cursada'));
        $this->add_var_js('url_detalle_encurso', kernel::vinculador()->crear('historia_academica', 'detalle_encurso'));
        $this->add_var_js('url_detalle_equivalencia', kernel::vinculador()->crear('historia_academica', 'detalle_equivalencia'));
        
		$this->add_var_js('url_pdf', kernel::vinculador()->crear('historia_academica', 'exportar_pdf'));
		$this->add_var_js('url_xls', kernel::vinculador()->crear('historia_academica', 'exportar_xls'));
    }
}
?>
