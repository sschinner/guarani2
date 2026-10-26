<?php
namespace kernel\acceso;
interface interface_persona_con_derechos extends interface_persona
{
    function add_derecho($derecho);
    function tiene_derecho($derecho, $params);
	function tiene_derecho_entidad($derecho, $tipo_entidad, $id_modelo);
}

?>
