<?php

namespace kernel\util\modelo;


interface recordset
{
    function &get_datos();

    function get_columna_id();

    function get_entidades();
}

?>
