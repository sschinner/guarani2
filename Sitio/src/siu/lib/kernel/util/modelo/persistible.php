<?php
namespace kernel\util\modelo;

/**
 * Para ordenar un poco que es lo que se necesita para poder persistir algo. Tiene
 * que tener un id unico para poder guardarlo sin colisionar con otros objetos,
 * guardar lo que requiera (minimal en lo posible), y con eso que se guarda poder
 * reconstruirse.
 */
interface persistible
{
    function get_id_unico($sal);

    function get_parametros_para_guardar();

    /**
     * @param object $objeto objeto que devuelve lo que se guardo
     * @param array $parametros_guardados
     */
    static function regenerar_instancia($objeto, $parametros_guardados);
}

?>
