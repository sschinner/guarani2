<?php

namespace kernel\acceso;

interface interface_persona
{
    
    function get_locale();

	/**
     * @return perfil_xml
     */
    function perfil();
    function get_perfiles();
    function set_perfil_activo($id_perfil);
    function ir_operacion_default();
    function get_nombre();
}

?>
