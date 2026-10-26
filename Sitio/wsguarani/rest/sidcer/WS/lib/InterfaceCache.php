<?php

/**
 *
 * @author lucianoc
 */

interface InterfaceCache
{
    public static function cachear($clave, $valor, $forzar_grabado = false, $ttl = null);
    
    public static function borrarValorDeCache($clave);
    
    public static function estaCacheado($clave);
    
    public static function traerDeCache($clave);
}
