<?php

require_once(INTERFACE_EXCEPCION_HTTP);

/**
 * Lanzada cunado el usuario no tiene permisos
 *
 * @author lucianoc
 */
class PermisoException extends RuntimeException implements HttpExceptionInterface
{
    protected $str_tipo = 'ERROR_PERMISO';
    
    public function __construct($message, $code = null, $previous = null)
    {
        $message = '['.$this->str_tipo.'] '.$message;
        parent::__construct($message, $code, $previous);
    }

    public function getCodigoHttp()
    {
        return 403;
    }
    
}
