<?php

namespace kernel\util\modelo;


/**
 * Procesa el resultset, con una api orientada a usarse en la entrada al modelo
 */
class procesador_modelo extends procesador_datos
{
    /**
     * @var recordset
     */
    protected $recordset;

    /**
     * @var decorador_entidad
     */
    protected $control_entidades;

    /**
     * @param \kernel\util\modelo\recordset $recordset
     * @param \kernel\util\modelo\decorador_ids $generador_ids
     */
    public function __construct(recordset $recordset, decorador_ids $generador_ids)
    {
        $datos = & $recordset->get_datos();
        parent::__construct($datos);
        $this->agregar_decordador($generador_ids);
        $this->recordset = $recordset;

    }

    /**
     * @param string $columna_id
     * @param string $valor_id
     * @return mixed
     */
    public function recuperar_fila($columna_id, $valor_id)
    {
        $fila = parent::recuperar_fila($columna_id, $valor_id);

        if (isset($this->control_entidades)) {
            $this->control_entidades->procesar_fila($fila);
        }
        return $fila;
    }

    /**
     * @param string $operacion
     * @param string $accion
     */
    public function habilitar_control_entidades($operacion, $accion)
    {
        $dec = new decorador_entidad($operacion, $accion);
        $dec->set_entidades($this->recordset->get_entidades());
        $this->control_entidades = $dec;
    }

}

?>
