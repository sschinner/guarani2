<?php

namespace siu\operaciones\encuestas_respondidas;

use kernel\interfaz\pagelet;
use kernel\kernel;

class pagelet_listado_encuestas extends pagelet {

    public function get_nombre(){
        return 'listado_encuestas';
    }

    function prepare()
    {

        $this->add_mensaje_js('debe_ingresar_codigo_recuperacion', kernel::traductor()->trans('encuestas_respondidas.debe_ingresar_codigo_recuperacion'));
        $this->add_mensaje_js('codigo_recuperacion_debe_ser_entero', kernel::traductor()->trans('encuestas_respondidas.codigo_recuperacion_debe_ser_entero'));
        $this->add_mensaje_js('codigo_recuperacion_error_longitud', kernel::traductor()->trans('encuestas_respondidas.codigo_recuperacion_error_longitud'));
        $this->add_mensaje_js('debe_ingresar_hash_validacion', kernel::traductor()->trans('encuestas_respondidas.debe_ingresar_hash_validacion'));
        $this->add_mensaje_js('hash_validacion_debe_ser_alfanumerico', kernel::traductor()->trans('encuestas_respondidas.hash_validacion_debe_ser_alfanumerico'));

    }

} 