<?php
/**
 * Created by IntelliJ IDEA.
 * User: andres
 * Date: 7/2/14
 * Time: 4:04 PM
 */

namespace kernel\acceso;

use kernel\error_kernel_perfil;

class perfil_php implements interface_perfil
{
    protected $conf;
    /**
     * @var manager_operaciones_inactivas guarda las operaciones que fueron desactivadas por el usuario desde una interfaz (no desde los archivos de acceso).
     */
    protected $manager_operaciones_inactivas;

    /**
     * @param $conf array de configuración. Se asume que ya están mergeadas las personalizaciones
     */
    function __construct($conf)
    {
        $this->conf = $conf;
    }

    /**
     * @return string el id del perfil actual
     */
    function get_id()
    {
        return $this->conf['id'];
    }

    /**
     * uso: $perfil->es('alumno')
     * @param $id string. El id de un perfil
     * @return bool
     */
    function es($id)
    {
        return $this->get_id() == $id;
    }

    /**
     * @param $id
     * @throws error_kernel_perfil
     * @return string el valor de un parámetro con id $id
     */
    function get_parametro($id)
    {
        if (!isset($this->conf['parametros'][$id])) {
            throw new error_kernel_perfil("No existe el parametro con id '$id'");
        }
        return $this->conf['parametros'][$id];
    }

    /**
     * @return array el menu del perfil
     */
    function get_menu()
    {
        $menu = new menu();
        foreach ($this->conf['operaciones'] as $nombre_op => $data_op) {
            $incluir_en_menu = $this->get_operacion_activa($nombre_op) && isset($data_op['menu']) && $data_op['menu']['visible'];
            if (!$incluir_en_menu) {
                continue;
            }

            $texto = isset($data_op['menu']['texto']) ? $data_op['menu']['texto'] : '';
            if (isset($data_op['menu']['submenu']) && is_string($data_op['menu']['submenu'])) {
                $submenu = $data_op['menu']['submenu'];
                $menu->add_opcion($nombre_op, $texto, $submenu);
            } else {
                $menu->add_opcion($nombre_op, $texto);
            }
        }

        return $menu;
    }

    /**
     * @param $id
     * @return bool
     */
    function existe_operacion($id)
    {
        return isset($this->conf['operaciones'][$id]);
    }

    protected function get_operacion($id)
    {
        if (! $this->existe_operacion($id)) {
            throw new error_kernel_perfil("La operación '$id' no existe");
        }
        return $this->conf['operaciones'][$id];
    }
    /**
     * @param $id
     * @return string la acción por defecto
     */
    function get_accion_defecto($id)
    {
        $op = $this->get_operacion($id);
        if (isset($op['accion_default'])) {
            return $op['accion_default'];
        } else {
            return 'index';
        }
    }

    /**
     * @param $id
     * @param $atributo
     * @return mixed
     */
    function get_atributo_operacion($id, $atributo)
    {
        $op = $this->get_operacion($id);
        return $op[$atributo];
    }

    /**
     * @param $id
     * @param $parametro
     * @throws error_kernel_perfil
     * @return mixed
     */
    function get_parametro_operacion($id, $parametro)
    {
        $operacion = $this->get_operacion($id);
        if (!isset($operacion['parametros']) || !isset($operacion['parametros'][$parametro])) {
            throw new error_kernel_perfil("No existe el parametro '$parametro' en la operación con id '$id'");
        }

        return $operacion['parametros'][$parametro];
    }

    /**
     * @param $url
     * @throws error_kernel_perfil
     * @return mixed
     */
    function get_id_operacion_from_url($url)
    {
        if ($url == 'logger') {
            return $url;
        }
        foreach ($this->conf['operaciones'] as $key => $op) {
            if ($this->get_url_operacion($key) == $url) {
                return $key;
            }
        }
        throw new error_kernel_perfil("No existe la operación con url '$url'");
    }

    /**
     * @param $id
     * @return mixed
     */
    function get_url_operacion($id)
    {
        $op = $this->get_operacion($id);
        if (!isset($op['url'])) {
            return $id;
        }
        return $op['url'];
    }

    /**
     * @param $id_operacion
     * @param $id_accion
     * @return mixed
     */
    function get_derechos_accion($id_operacion, $id_accion)
    {
        $operacion = $this->get_operacion($id_operacion);
        if (! isset($operacion['derechos']) || !isset($operacion['derechos'][$id_accion])) {
            return array();
        }

        $derechos = array();
        foreach ($operacion['derechos'][$id_accion] as $id => $sobre) {
            $derechos[] = array($id, $sobre);
        }

        return $derechos;
    }

    /**
     * @param $id
     * @return mixed
     */
    function get_operacion_activa($id)
    {
        $op = $this->get_operacion($id);
        $operaciones_inactivas = $this->manager_operaciones_inactivas->get_operaciones_inactivas();
        return (!isset($op['activa']) || $op['activa']) && ! in_array($id, $operaciones_inactivas);
    }

    /**
     * @return listado de nombres de las operaciones que están activas en el perfil
     */
    function get_operaciones_disponibles()
    {
        $operaciones = array();
        foreach ($this->conf['operaciones'] as $id_operacion => $operacion) {
            if ($operacion['activa']) {
                $operaciones[] = $id_operacion;
            }
        }
        return $operaciones;
    }

    /**
     * @param $operaciones manager_operaciones_inactivas listado de operaciones desactivadas por el usuario
     */
    function set_manager_operaciones_inactivas(manager_operaciones_inactivas $operaciones)
    {
        $this->manager_operaciones_inactivas = $operaciones;
    }

    /**
     * @param array $operaciones recibe un listado de las operaciones desactivadas por el usuario
     */
    function set_operaciones_inactivas($operaciones)
    {
        $this->manager_operaciones_inactivas->set_operaciones_inactivas($operaciones);
    }

    /**
     * @return array un arreglo clave => valor donde clave es el nombre de la operación y valor es un boolean que es true
     * si la operación se puede acceder o falso de cualquier otra manera
     */
    function get_listado_estado_operaciones()
    {
        $operaciones_disp = $this->get_operaciones_disponibles();
        $operaciones_inactivas = $this->manager_operaciones_inactivas->get_operaciones_inactivas();
        $rs = array();
        foreach ($operaciones_disp as $op) {
            $rs[$op] = !in_array($op, $operaciones_inactivas);
        }
        return $rs;
    }
}