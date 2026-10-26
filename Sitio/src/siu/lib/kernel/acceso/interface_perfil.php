<?php
/**
 * Created by IntelliJ IDEA.
 * User: andres
 * Date: 7/2/14
 * Time: 3:56 PM
 */

namespace kernel\acceso;


interface interface_perfil {

    /**
     * @return string el id del perfil actual
     */
    function get_id();

    /**
     * uso: $perfil->es('alumno')
     * @param $id string. El id de un perfil
     * @return bool
     */
    function es($id);

    /**
     * @param $id
     * @return string el valor de un parámetro con id $id
     */
    function get_parametro($id);

    /**
     * @return menu el menu del perfil
     */
    function get_menu();

    /**
     * @param $id
     * @return bool
     */
    function existe_operacion($id);

    /**
     * @param $id
     * @return mixed
     */
    function get_operacion_activa($id);

    /**
     * @return listado de nombres de las operaciones que están disponibles en el perfil. Una operación está disponible
     * si está activa en el perfil, ignorando el contenido de los archivos en instalacion/acceso_operaciones
     */
    function get_operaciones_disponibles();

    /**
     * @param $id
     * @return string la acción por defecto
     */
    function get_accion_defecto($id);

    /**
     * @param $id
     * @param $atributo
     * @return mixed
     */
    function get_atributo_operacion($id, $atributo);

    /**
     * @param $id
     * @param $parametro
     * @return mixed
     */
    function get_parametro_operacion($id, $parametro);

    /**
     * @param $url
     * @return mixed
     */
    function get_id_operacion_from_url($url);

    /**
     * @param $id
     * @return mixed
     */
    function get_url_operacion($id);

    /**
     * @param $id_operacion
     * @param $id_accion
     * @return mixed
     */
    function get_derechos_accion($id_operacion, $id_accion);

    /**
     * @param $operaciones manager_operaciones_inactivas listado de operaciones desactivadas por el usuario
     */
    function set_manager_operaciones_inactivas(manager_operaciones_inactivas $operaciones);

    /**
     * @return array un arreglo clave => valor donde clave es el nombre de la operación y valor es un boolean que es true
     * si la operación se puede acceder o falso de cualquier otra manera
     */
    function get_listado_estado_operaciones();

    /**
     * @param array $operaciones recibe un listado de las operaciones desactivadas por el usuario
     */
    function set_operaciones_inactivas($operaciones);
}

?>
