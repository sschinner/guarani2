<?php

/**
 * Clase de respuesta abstracta
 *
 * @author lucianoc
 */
abstract class AbstractRespuesta
{
    protected $codigoDeRespuesta = -1;
    protected $datos = null;
    protected $mensaje = '';
    protected $codigoHttp = 200;

    protected function mostrarCodigoHttp($statusCode) {
        static $status_codes = null;

        if ($status_codes === null) {
            $status_codes = array (
                100 => 'Continue',
                101 => 'Switching Protocols',
                102 => 'Processing',
                200 => 'OK',
                201 => 'Created',
                202 => 'Accepted',
                203 => 'Non-Authoritative Information',
                204 => 'No Content',
                205 => 'Reset Content',
                206 => 'Partial Content',
                207 => 'Multi-Status',
                300 => 'Multiple Choices',
                301 => 'Moved Permanently',
                302 => 'Found',
                303 => 'See Other',
                304 => 'Not Modified',
                305 => 'Use Proxy',
                307 => 'Temporary Redirect',
                400 => 'Bad Request',
                401 => 'Unauthorized',
                402 => 'Payment Required',
                403 => 'Forbidden',
                404 => 'Not Found',
                405 => 'Method Not Allowed',
                406 => 'Not Acceptable',
                407 => 'Proxy Authentication Required',
                408 => 'Request Timeout',
                409 => 'Conflict',
                410 => 'Gone',
                411 => 'Length Required',
                412 => 'Precondition Failed',
                413 => 'Request Entity Too Large',
                414 => 'Request-URI Too Long',
                415 => 'Unsupported Media Type',
                416 => 'Requested Range Not Satisfiable',
                417 => 'Expectation Failed',
                422 => 'Unprocessable Entity',
                423 => 'Locked',
                424 => 'Failed Dependency',
                426 => 'Upgrade Required',
                500 => 'Internal Server Error',
                501 => 'Not Implemented',
                502 => 'Bad Gateway',
                503 => 'Service Unavailable',
                504 => 'Gateway Timeout',
                505 => 'HTTP Version Not Supported',
                506 => 'Variant Also Negotiates',
                507 => 'Insufficient Storage',
                509 => 'Bandwidth Limit Exceeded',
                510 => 'Not Extended'
            );
        }

        if ($status_codes[$statusCode] !== null) {
            $status_string = $statusCode . ' ' . $status_codes[$statusCode];
            header($_SERVER['SERVER_PROTOCOL'] . ' ' . $status_string, true, $statusCode);
        }
    }    
    
    public function __construct($unCodigo = -1, $unMensaje = null, $unosDatos = null, $codigoHttp = 200)
    {
        $this->codigoDeRespuesta = $unCodigo;
        $this->datos = $unosDatos;
        $this->mensaje = $unMensaje;
        $this->codigoHttp = $codigoHttp;
    }

    protected static function utf8Encode(&$array)
    {
        if (is_string($array)) {
            $array = utf8_encode($array);
        } elseif (is_array($array) and count($array) > 0) {
            foreach ($array as $k => $v) {
                self::utf8Encode($array[$k]);
            }
        }
    }

    protected function mostrarEncabezado()
    {
        header('Cache-Control: no-cache, must-revalidate');
        header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
        header('Content-type: application/json; charset=utf-8');
        $this->mostrarCodigoHttp($this->codigoHttp);
    }

    protected abstract function getContenido();
    
    protected abstract function codificar($contenido);

    protected function mostrarCuerpo()
    {
        $respuesta = $this->getContenido();
        self::utf8Encode($respuesta);
        echo $this->codificar($respuesta);
    }

    public function mostrar()
    {
        if ($this->datos !== null and ! is_array($this->datos)) {
            $this->datos = array($this->datos);
        }
        $this->mostrarEncabezado();
        $this->mostrarCuerpo();
        die();
    }

}
