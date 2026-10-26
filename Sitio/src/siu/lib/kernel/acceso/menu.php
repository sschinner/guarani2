<?php
/**
 * Created by IntelliJ IDEA.
 * User: andres
 * Date: 7/2/14
 * Time: 5:53 PM
 */

namespace kernel\acceso;

use kernel\kernel;
use kernel\error_kernel_menu;

class menu implements \Iterator
{
    protected $items = array();
    protected $item_order = array();
    protected $submenu_items_order = array();
    function __construct()
    {

    }

    function add_opcion($nombre_op, $texto = '', $submenu = false)
    {
        $meta = array('nombre_operacion' => $nombre_op, 'texto' => $texto);
        if ($submenu === false) {
            $this->items[$nombre_op] = $meta;
        } else {
            if (!isset($this->items[$submenu])) {
                $this->items[$submenu] = array();
            }
            $this->items[$submenu][$nombre_op] = $meta;
        }
    }

    function esta_vacio()
    {
        return count($this->items) == 0;
    }

    function tiene_submenu($item)
    {
        return !isset($this->items[$item]['nombre_operacion']);
    }

    /**
     * No utilizar, esta función se incluye con fines de testeo
     * @ignore
     * @return array
     */
    function get_items_array()
    {
        return $this->items;
    }

    /**
     * @param $nombre_op string. Nombre de la de operación o submenú que se desea reordenar
     * @param $orden integer. Es un número que representa la posición relativa dentro del sub-menu donde se encuentra
     * @throws error_kernel_menu
     */
    function set_orden($nombre_op, $orden)
    {
        if ($orden < 0) {
            throw new error_kernel_menu("El nro de orden $orden no es válido, tiene que ser un nro entre 0 y cantidad de items en el menu");
        }
        if (isset($this->items[$nombre_op])) {
            if ($orden >= count($this->items)) {
                $orden = count($this->items)-1;
            }
            $this->item_order[$nombre_op] = $orden;
            return;
        } else { // buscar en submenu
            foreach (array_keys($this->items) as $nombre_item) {
                if ($this->tiene_submenu($nombre_item)) {
                    foreach (array_keys($this->items[$nombre_item]) as $nombre_subitem) {
                        if ($nombre_op == $nombre_subitem) {
                            if ($orden >= count($this->items[$nombre_item])) {
                                $orden = count($this->items)-1;
                            }
                            $this->submenu_items_order[$nombre_item][$nombre_subitem] = $orden;
                            return;
                        }
                    }
                }
            }
        }

        kernel::log()->add_info('SE INTENTA CAMBIAR EL ORDEN DE UNA OPERACION QUE NO EXISTE EN EL MENU ACTUAL', $nombre_op);
    }

    function reordenar()
    {
        if (empty($this->item_order) && empty($this->submenu_items_order)) {
            return;
        }

        // se ordenan los submenus
        foreach (array_keys($this->submenu_items_order) as $nombre_item_submenu) {
            $this->items[$nombre_item_submenu] = $this->reordenar_array($this->items[$nombre_item_submenu], $this->submenu_items_order[$nombre_item_submenu]);
        }

        $this->items = $this->reordenar_array($this->items, $this->item_order);

        $this->item_order = array();
        $this->submenu_items_order = array();
    }

    protected function reordenar_array($items, $orden)
    {
        foreach ($orden as $nombre_op => $nro_orden_nuevo) {
            $nro_orden_actual = array_search($nombre_op, array_keys($items));
            if ($nro_orden_nuevo == $nro_orden_actual) {
                continue;
            }
            if ($nro_orden_actual < $nro_orden_nuevo) {
                $p1 = array_slice($items, 0, $nro_orden_actual);
                $p2 = array_slice($items, $nro_orden_actual + 1, $nro_orden_nuevo - $nro_orden_actual);
                $item = array_slice($items, $nro_orden_actual, 1);
                $resto = array_slice($items, $nro_orden_nuevo + 1);
                $items = array_merge($p1, $p2, $item, $resto);
            } else {
                $p1 = array_slice($items, 0, $nro_orden_nuevo);
                $p2 = array_slice($items, $nro_orden_nuevo, $nro_orden_actual - $nro_orden_nuevo);
                $item = array_slice($items, $nro_orden_actual, 1);
                $resto = array_slice($items, $nro_orden_actual+1);
                $items = array_merge($p1, $item, $p2, $resto);
            }
        }

        return $items;
    }

    /**
     * (PHP 5 &gt;= 5.0.0)<br/>
     * Return the current element
     * @link http://php.net/manual/en/iterator.current.php
     * @return mixed Can return any type.
     */
    public function current()
    {
        return current($this->items);
    }

    /**
     * (PHP 5 &gt;= 5.0.0)<br/>
     * Move forward to next element
     * @link http://php.net/manual/en/iterator.next.php
     * @return void Any returned value is ignored.
     */
    public function next()
    {
        return next($this->items);
    }

    /**
     * (PHP 5 &gt;= 5.0.0)<br/>
     * Return the key of the current element
     * @link http://php.net/manual/en/iterator.key.php
     * @return mixed scalar on success, or null on failure.
     */
    public function key()
    {
        return key($this->items);
    }

    /**
     * (PHP 5 &gt;= 5.0.0)<br/>
     * Checks if current position is valid
     * @link http://php.net/manual/en/iterator.valid.php
     * @return boolean The return value will be casted to boolean and then evaluated.
     * Returns true on success or false on failure.
     */
    public function valid()
    {
        $key = key($this->items);
        $var = ($key !== NULL && $key !== FALSE);
        return $var;
    }

    /**
     * (PHP 5 &gt;= 5.0.0)<br/>
     * Rewind the Iterator to the first element
     * @link http://php.net/manual/en/iterator.rewind.php
     * @return void Any returned value is ignored.
     */
    public function rewind()
    {
        reset($this->items);
    }
}