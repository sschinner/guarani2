<?php

require_once(INTERFACE_EXCEPCION_HTTP);

/**
 * Description of PDOExceptionConexion
 *
 * @author lucianoc
 */
class PDOConexionException extends PDOException  implements HttpExceptionInterface
{
    protected $conexionId = null;
    protected $pdoException = null;
    protected $str_tipo = "ERROR_CONEXION";

    function __construct(PDOException $e, $conexionId = null)
    {
	parent::__construct($e);
        $this->pdoException = $e;
        $this->setConexionId($conexionId);
    }
    function setConexionId($id) 
    {
        $this->conexionId = $id;
        $this->message = '['.$this->str_tipo.'] '.$this->pdoException->getMessage().'. CONEXIONES: '.$id;
    }

    public function getCodigoHttp()
    {
        return 500;
    }
}
