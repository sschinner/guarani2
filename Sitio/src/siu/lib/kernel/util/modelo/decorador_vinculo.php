<?php
namespace kernel\util\modelo;

use kernel\kernel;

class decorador_vinculo implements decorador_fila
{

    protected $columna_destino;
    protected $controlador;
    protected $accion;
    protected $parametros;
    protected $columnas_visibles;
    protected $columna_id;
    protected $decorado;

    public function __construct()
    {
        $this->columnas_visibles = array();
        $this->parametros = array();
    }

    public function set_datos_vinculo($columna_id, $columna_destino, $controlador, $accion)
    {
        $this->columna_destino = $columna_destino;
        $this->columna_id = $columna_id;
        $this->controlador = $controlador;
        $this->accion = $accion;
    }

    /**
     * Agrega parametros fijos al vinculo
     * @param array $array_params
     */
    public function agregar_parametros_al_vinculo($array_params)
    {
        $this->parametros = array_merge($this->parametros, $array_params);
    }

    /**
     * Agrega columnas al vinculo
     * @param string $nombre_var
     * @param string $nombre_columna
     */
    public function agregar_columna_al_vinculo($nombre_var, $nombre_columna)
    {
        $this->columnas_visibles[$nombre_var] = $nombre_columna;
    }

    public function procesar_fila(&$fila)
    {
        //le pongo el id al principio
        $params = $this->parametros;
        array_unshift($params, $fila[$this->columna_id]); //lo pongo al principio
        foreach ($this->columnas_visibles as $nombre_var => $col) {
            $params[$nombre_var] = $fila[$col];
        }
	    if(kernel::persona()->perfil()->get_operacion_activa($this->controlador)){
		    $fila[$this->columna_destino] =
			    kernel::vinculador()->crear($this->controlador, $this->accion, $params);
	    }else {
		    $fila[$this->columna_destino] = decorador_entidad::$link_vacio;
	    }

    }

}

?>
