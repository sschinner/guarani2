<?php
namespace kernel\util\modelo;

class persistidor_rs
{
    //Fuente/origen del recordset
    public $fuente_objeto;
    public $fuente_funcion;
    public $fuente_argumentos;

    /**
     * @var recordset
     */
    public $recordset;

    //Datos del recordset que se espera obtener. Se usa para recuperación (clase)
    // y validacion (ambos).
    public $destino_clase;
    public $destino_funcion;

    /**
     * @var fuente_persistencia
     */
    protected $fuente;

    public function __construct(fuente_persistencia $fuente)
    {
        $this->fuente = $fuente;
    }

    function persitir()
    {
        return $this->fuente->persistir_recordset($this);
    }


    function recuperar($id)
    {
        return $this->fuente->get_recordset($this, $id);
    }


}

?>
