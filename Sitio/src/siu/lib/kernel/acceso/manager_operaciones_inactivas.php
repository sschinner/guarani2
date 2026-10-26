<?php
/**
 * Created by IntelliJ IDEA.
 * User: andres
 * Date: 7/7/14
 * Time: 3:21 PM
 */

namespace kernel\acceso;


use kernel\error_kernel;
use kernel\kernel;
use kernel\util\manejador_archivos;

class manager_operaciones_inactivas
{
    protected $id_bloque_acceso;
    protected $path;
    protected $perfil;
    protected $operaciones;

    function __construct($perfil, $id_bloque_acceso)
    {
        $this->id_bloque_acceso = $id_bloque_acceso;
        $this->perfil = $perfil;
        $this->path = kernel::proyecto()->get_dir_ops_inactivas()."/ops_$id_bloque_acceso.json";
        $this->cargar();
    }

    protected function cargar($force = false)
    {
        $apc_enabled = extension_loaded('apc');
        $apc_key = md5($this->path);

        if ($apc_enabled) {
            $this->operaciones = \apc_fetch($apc_key);
        }

        if (! isset($this->operaciones) || $this->operaciones === false || $force) {
            if (file_exists($this->path)) {
                $this->operaciones = json_decode(file_get_contents($this->path), true);
            } else {
                $this->operaciones = array();
                $this->operaciones[$this->perfil] = array();
            }
            if ($apc_enabled && kernel::proyecto()->get_produccion()) {
                \apc_store($apc_key, $this->operaciones, 600);
            }
        }
    }

    function get_operaciones_inactivas()
    {
        return (isset($this->operaciones[$this->perfil]))? $this->operaciones[$this->perfil] : array();
    }

    /**
     * Cambia las operaciones inactivas del sistema. Este método impacta en el sistema de archivos
     * @param array $operaciones arreglo de ids de operaciones inactivas
     */
    function set_operaciones_inactivas($operaciones)
    {
        // se recarga por si el archivo cambió desde que se instanció el objeto (puede haber cambiado otro perfil que se guarda en el mismo archivo)
        $this->cargar(true);
        $this->operaciones[$this->perfil] = $operaciones;
        $this->guardar();
    }

    protected function guardar()
    {
        if (! is_dir(kernel::proyecto()->get_dir_ops_inactivas())) {
            manejador_archivos::crear_arbol_directorios(kernel::proyecto()->get_dir_ops_inactivas());
        }

        if (file_put_contents($this->path, json_encode($this->operaciones)) === false){
            throw new error_kernel('Hubo un error al guardar');
        }

        $this->cargar(true);
    }
} 