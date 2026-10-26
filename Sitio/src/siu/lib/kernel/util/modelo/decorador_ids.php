<?php

namespace kernel\util\modelo;

use kernel\kernel;

/**
 * Crea un identificador unico en base al valor de la columna que sea id (unica),
 * y un token adicional para darle contexto.
 * En modo id_simple,
 */
class decorador_ids implements decorador_fila
{

    /**
     * @var string
     */
    public static $nombre_columna_generada = "__ID__";

    /**
     * @var string
     */
    protected $columna_id;
    /**
     * @var string
     */
    protected $token;
    /**
     * @var bool
     */
    protected $hashear = true;
    /**
     * @var bool
     */
    protected $generar_id_compuesto;


    public function __construct()
    {
        //no hago nada porque me pueden acceder para descomponer un id o para
        //decorar un id.
        $this->generar_id_compuesto = false;
    }

    /**
     * @param array $registro
     */
    function procesar_fila(&$registro)
    {
        $id_fila = $registro[$this->columna_id];
        $vinculo = $this->componer_id_fila($this->generar_id_fila($id_fila));
        $registro[$this->get_nombre_columna_generada()] = $vinculo;
    }

    /**
     * Descompone un id en id_fila (puede estar hasheado), y el token. Asume que
     * el token tiene 40 caracteres (sha1 por ej)
     * -Deberia ser estatica, no lo es para que se acceda por medio de una
     * instancia y no cree una dependencia estatica!
     * Funciona si el id es compuesto, no se lee el estado del objeto!
     * @param string $id_fila
     * @return mixed array($id_fila, $token);
     */
    function descomponer_id_fila($id_fila)
    {
        //si el id no es compuesto, no hay que llamar a este metodo para recuperarlo.
        //no se lee el registro para no tener que setearlo.
        $token = substr($id_fila, 0, 40);
        $id = substr($id_fila, 40, strlen($id_fila));

        return array($id, $token);
    }

    function generar_ids_simples()
    {
        $this->generar_id_compuesto = false;
    }

    function generar_ids_compuestos($token)
    {
        $this->generar_id_compuesto = true;
        $this->token = $token;
    }

    function set_columna_id($columna_id)
    {
        $this->columna_id = $columna_id;
    }

    protected function generar_id($id)
    {
        $salt = kernel::proyecto()->get('salt');
        return sha1($salt . $id);
    }

    /**
     * El nombre de la columna donde se genera el id.
     * @return string
     */
    function get_nombre_columna_generada()
    {
        return self::$nombre_columna_generada;
    }

    /**
     * Compone la fila concatenando el y token. Asume que el
     * token tiene 40 caracteres (sha1)
     */
    protected function componer_id_fila($id_fila)
    {
        if ($this->generar_id_compuesto) {
            return $this->token . $id_fila;
        }
        return $id_fila;
    }

    protected function generar_id_fila($valor)
    {
        if ($this->hashear) {
            return self::generar_id($valor . $this->token);
        } else {
            return $valor;
        }
    }

}

?>
