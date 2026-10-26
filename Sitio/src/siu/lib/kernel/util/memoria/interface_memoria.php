<?php

namespace kernel\util\memoria;

interface interface_memoria
{
    function limpiar();
    function agregar($clave, $valor);
    function get($clave);
    function tiene($clave);
}

?>
