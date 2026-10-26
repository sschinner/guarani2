<?php

/**
 * Description of Log
 *
 * @author lucianoc
 */
class Log
{
    public static function procesar_excepcion(\Exception $e)
    {
        $id_error = time() . ',' . uniqid();
        $msg_error = $e->getMessage() . ". REQUEST_URI:" . $_SERVER['REQUEST_URI'];
        $directorio = dirname(__FILE__).'/../var/log/';
        $archivo = $directorio.date('Ymd').'.log';
        if (is_writable($directorio)) {
            error_log(date('Y-m-d H:i:s')." [" . $id_error . "]: " . $msg_error."\n", 3, $archivo);
        } else {
            error_log("[" . $id_error . "]: " . $msg_error);
        }

        return $msg_error;
    }
    
    public static function procesar_excepcion_bd(\Exception $e)
    {
        $msg_error = static::procesar_excepcion($e);
        if (ES_PRODUCCION) {
            $msg_error = "Error. [" . $id_error . "]";
        }

        return $msg_error;
    }

}
