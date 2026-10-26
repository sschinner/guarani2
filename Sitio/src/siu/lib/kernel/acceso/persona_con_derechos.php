<?php
namespace kernel\acceso;

abstract class persona_con_derechos implements interface_persona
{
    protected $derechos = array();
    
    function add_derecho($derecho)
    {
        $this->derechos[] = $derecho;
    }
    
    function tiene_derecho($derecho)
    {
        return in_array($derecho, $this->derechos);
    }
    
    function ir_operacion_default()
    {
        throw new nuevo_request($this->perfil()->get_parametro('index'), 'index');
    }
	
	function tiene_derecho_entidad($derecho, $tipo_entidad, $id_modelo){
		
	}
	
	/**
	 * Consulta todos los derechos en 1 consulta. Devuelve un arreglo [id_modelo]=> 1 para cada $id_modelo
	 * que tiene acceso.
	 */
	function tiene_derecho_entidades($derecho, $tipo_entidad, $ids_modelo){}
}

?>
