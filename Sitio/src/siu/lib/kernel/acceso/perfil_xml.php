<?php
namespace kernel\acceso;

class perfil_xml implements interface_perfil
{
    protected $xml;
    
    function __construct(\SimpleXMLElement $xml)
    {
		//@todo: traer la lista de codigos activos
        $this->xml = $xml;
    }
    
    function get_id()
    {
        return (string) $this->xml['id'];
    }
    
    /**
     * uso: $perfil->es('alumno')
     */
    function es($id)
    {
        return $this->get_id() == $id;
    }
    
    function get_parametro($id)
    {
        foreach ($this->xml->parametros->parametro as $parametro) {
            if ((string) $parametro['id'] == $id) {
                return (string) $parametro['valor'];
            }
        }
        
        throw new \Exception("No existe el parametro con id '$id'");
    }

    /**
     * @return menu
     */
    function get_menu()
    {
        $menu = new menu();
        if (!isset($this->xml->menu->opcion)) {
            return $menu;
        }

        foreach ($this->xml->menu->opcion as $opcion) {
            if (isset($opcion->opcion)) { // es submenu
                foreach ($opcion->opcion as $sub_opcion) {
                    $destino = (string)$sub_opcion['destino'];
                    $texto = (isset($sub_opcion['texto'])) ? $sub_opcion['texto'] : '';
                    $menu->add_opcion($destino, $texto, (string)$opcion['nombre']);
                }
            } else {
                $destino = (string)$opcion['destino'];
                $texto = (isset($opcion['texto'])) ? $opcion['texto'] : '';
                $menu->add_opcion($destino, $texto);
            }
        }

        return $menu;
    }
    
    function existe_operacion($id)
    {
        try {
            $this->get_operacion($id);    
        } catch (\Exception $e) {
            return false;
        }
		//@todo: sacar
		/*
		 * la operacion tiene codigo?
		 *	si: que exista en el array de codigos activados
		 *  no: ok, no controlar
		 */
        return true;
        return $this->get_atributo_operacion($id, 'activa') == '1';
    }
	
	function get_accion_defecto($id)
	{
		$operacion = $this->get_operacion($id);
        if (isset($operacion['accion_default'])) {
            return (string) $operacion['accion_default'];
        } else {
			return 'index';
		}
	}
	
    function get_atributo_operacion($id, $atributo)
    {
        $operacion = $this->get_operacion($id);
        if (isset($operacion[$atributo])) {
            return (string) $operacion[$atributo];
        }
        
        throw new \Exception("No existe el atributo '$atributo' en la operación con id '$id'");
    }
    
    function get_parametro_operacion($id, $parametro)
    {
        $operacion = $this->get_operacion($id);
        foreach ($operacion->parametros->parametro as $param_obj) {
            if ((string) $param_obj['id'] == $parametro) {
                return (string) $param_obj['valor'];
            }
        }
        
        throw new \Exception("No existe el parametro '$parametro' en la operación con id '$id'");
    }
    
    protected function get_operacion($id)
    {
        foreach ($this->xml->operaciones->operacion as $operacion) {
            if ((string) $operacion['id'] == $id) {
                return $operacion;
            }
        }
        
        throw new \Exception("No existe la operación con id '$id'");
    }
	
    function get_id_operacion_from_url($url)
    {
		if ($url == 'logger') {
			return $url;
		}
        foreach ($this->xml->operaciones->operacion as $operacion) {
            if ((string) $operacion['url'] == $url) {
                return $operacion['id'];
            }
        }
        
        throw new \Exception("No existe la operación con url '$url'");
    }
    
	function get_url_operacion($id)
	{
		$op = $this->get_operacion($id);
		return $op['url'];
	}
	
	function get_derechos_accion($id_operacion, $id_accion)
	{
		$accion = $this->get_accion($id_operacion, $id_accion);
		
		$derechos = array();
		if(!isset($accion) || !isset($accion->derecho)) 
			return $derechos;

		foreach ($accion->derecho as $d){
			$derechos[] = array((string)$d['id'], (string)$d['sobre']);
		}
		
		return $derechos;
	}

	protected function get_accion($id_operacion, $id)
	{
		$operacion = $this->get_operacion($id_operacion);
		foreach ($operacion->accion as $accion) {
			if ((string) $accion['id'] == $id) {
				return $accion;
			}
		}
		return null; //xml vacio
		//throw new \Exception("No existe la accion con id '$id'");
	}

    /**
     * @param $id
     * @return mixed
     */
    function get_operacion_activa($id)
    {
        return $this->get_atributo_operacion($id, 'activa') == '1';
    }

    /**
     * @return listado de nombres de las operaciones que están activas en el perfil
     */
    function get_operaciones_disponibles()
    {
        // TODO: Implement get_operaciones_activas() method.
        return array();
    }

    /**
     * @param $operaciones manager_operaciones_inactivas listado de operaciones desactivadas por el usuario
     */
    function set_manager_operaciones_inactivas(manager_operaciones_inactivas $operaciones)
    {
        // TODO: Implement set_manager_operaciones_inactivas() method.
    }

    /**
     * @return array un arreglo clave => valor donde clave es el nombre de la operación y valor es un boolean que es true
     * si la operación se puede acceder o falso de cualquier otra manera
     */
    function get_listado_estado_operaciones()
    {
        // TODO: Implement get_listado_estado_operaciones() method.
        return array();
    }

    /**
     * @param array $operaciones recibe un listado de las operaciones desactivadas por el usuario
     */
    function set_operaciones_inactivas($operaciones)
    {
        // TODO: Implement set_operaciones_inactivas() method.
    }
}

?>
