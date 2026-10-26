<?php

namespace kernel\util\modelo;

use kernel\kernel;
use kernel\util\modelo\decorador_fila;
use siu\errores\error_guarani;

/**
 * Procesa una fila validando los derechos sobre un conjunto de columnas.
 */
class decorador_entidad implements decorador_fila
{

    public static $link_vacio = "-.-";
    /**Solo para batchear*/
    protected $batch_derechos;
    protected $entidades;
    protected $derechos;
    protected $columna_a_borrar;
    protected $estricto;

    public function __construct($operacion, $accion, $estricto = true)
    {
        $this->entidades = array();
        $this->estricto = $estricto;
        $this->derechos = $this->obtener_derechos($operacion, $accion);
        kernel::log()->add_debug("Derechos - derechos accion", $this->derechos);

    }

    protected function obtener_derechos($operacion, $accion)
    {
        return kernel::persona()->perfil()->get_derechos_accion($operacion, $accion);
    }

    /**
     * Se requiere el recordset adelantado para poder pedir todos los derechos
     * juntos y evitar 1 consulta por fila
     * @param \kernel\util\modelo\recordset $r
     */
    public function batchear_derechos(recordset $r)
    {
        $this->batch_derechos = array();
        $datos = $r->get_datos();
        if (empty($datos)) //tip: no va a funcionar empty($r->get_datos());
        return;
        foreach ($this->derechos as $fila_derecho) {
            $derecho = $fila_derecho[0];
            $entidad = $fila_derecho[1];
            $entidades_controlar = array();
            if (!isset($this->entidades[$entidad])) continue;
            foreach ($this->entidades[$entidad] as $columna) {
                foreach ($datos as $fila) {
                    $entidades_controlar[] = $fila[$columna];
                    //if (!$this->tiene_acceso($derecho, $entidad, $fila[$columna])) {
                }
            }

            $this->batchear_entidades($derecho, $entidad, $entidades_controlar);
        }
    }

    protected function batchear_entidades($derecho, $entidad, $entidades_controlar)
    {
        $derechos = kernel::persona()->tiene_derecho_entidades($derecho, $entidad, $entidades_controlar);
        $this->batch_derechos[$derecho][$entidad] = $derechos;
    }

    /**
     * El formato es array('tipo' => array('colum1', 'colum2'),
     *                     'tipo2' =>...)
     * @param array $arreglo_entidades
     */
    public function set_entidades($arreglo_entidades)
    {
        $this->entidades = $arreglo_entidades;
        kernel::log()->add_debug("Derechos - entidades", $this->entidades);
    }

    public function borrar_columna_on_deny($nombre_col)
    {
        $this->columna_a_borrar = $nombre_col;
    }

    public function procesar_fila(&$fila)
    {
        foreach ($this->derechos as $fila_derecho) {
            $derecho = $fila_derecho[0];
            $entidad = $fila_derecho[1];

            if (isset($this->entidades[$entidad])) {
                foreach ($this->entidades[$entidad] as $columna) {
                    if (!$this->tiene_acceso($derecho, $entidad, $fila[$columna])) {
                        $this->on_deny($fila, $derecho, $entidad, $columna);
                    } else {
                        //kernel::log()->add_debug("Derechos", "Validacion exitosa");
                    }
                }
            } else {
                kernel::log()->add_debug("Derechos", "La consulta no tiene entidades - se omite control");
            }
        }
    }

    protected function tiene_acceso($derecho, $entidad, $valor)
    {
        if (isset($this->batch_derechos)) {
            return isset($this->batch_derechos[$derecho][$entidad][$valor]);
        }
        return kernel::persona()->tiene_derecho_entidad($derecho, $entidad, $valor);
    }

    protected function on_deny(&$fila, $derecho, $entidad, $columna)
    {
        kernel::log()->add_debug("Derechos", "Usuario no tiene derecho $derecho para $entidad id: {$fila[$columna]}");

        if ($this->estricto) {
            $error = new error_guarani("Derecho Denegado");
            kernel::log()->add_error($error);
            throw $error;
        }

        $fila[$this->columna_a_borrar] = self::$link_vacio;
    }

}

?>
