<?php

namespace kernel\interfaz\pagelets;

use kernel\interfaz\pagelet;

/**
 * De esta clase deben extender los pagelets que sean comunes a varias operaciones.
 * Por defecto se asume que pertenecen a una operación llamada _comun con la
 * misma estructura que cualquier otra operación
 *
 */
abstract class pagelet_comun extends pagelet
{

    protected function get_path_template()
    {
        return recursos::get_pl_template('_comun',
                $this->get_nombre(), $this->get_nombre_tp());
    }

}

?>
