<?php
namespace kernel\util\modelo;


class rs_base implements recordset
{
    protected $columna_id;
    protected $datos;
    protected $entidades;

    public function __construct()
    {
        $this->entidades = array();
    }

    public function set_columna_id($columna_id)
    {
        $this->columna_id = $columna_id;
    }

    public function get_columna_id()
    {
        return $this->columna_id;
    }

    //la forma de setear los datos depende de la implementacion!
    public function &get_datos()
    {
        return $this->datos;
    }

    /**
     * Si la columna es vacia, es igual al tipo. Entidad Comision, columna Comision
     * @param string $tipo
     * @param string $columna
     */
    public function agregar_entidad($tipo, $columna = '')
    {
        if ($columna == '')
            $columna = $tipo;
        $this->entidades[$tipo][] = $columna;
    }

    public function get_entidades()
    {
        return $this->entidades;
    }
}

?>
