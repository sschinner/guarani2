<?php
namespace kernel\util\modelo;


interface decorador_fila
{
    /**
     * Porcesa una fila. El parametro es por referencia para evitar el copy on
     * write de php. Es decir, se modifica el registro para los que tengan una
     * referencia a esta fila.
     * @param array $fila
     */
    function procesar_fila(&$fila);

}

?>
