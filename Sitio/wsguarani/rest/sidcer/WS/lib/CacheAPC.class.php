<?php

require_once( dirname(__FILE__).'/../config/paths.inc.php' );

/**
 * Description of CacheAPC
 *
 * @author lucianoc
 */
class CacheAPC implements InterfaceCache
{
    static private $ttl = 600;
    
    public static function cachear($clave, $valor, $forzar_grabado = false, $ttl = null)
    {
        if (!$ttl)
        {
            $ttl = self::$ttl;
        }
        elseif ($ttl == -1)
        {
            apc_delete($clave);
            return null;
        }

        if ($forzar_grabado)
        {
            return apc_store($clave, $valor, $ttl);
        }
        else
        {
            return apc_add($clave, $valor, $ttl);
        }
    }
    
    public static function estaCacheado($clave)
    {
        return apc_exists($clave);
    }
    
    public static function traerDeCache($clave)
    {
        if (self::estaCacheado($clave))
        {
            return apc_fetch($clave);
        }
        return null;
    }
    
    public static function borrarValorDeCache($clave) {
        static::cachear($clave, null, null, -1);
    }
}

if(!function_exists('apc_exists'))
    {
    function apc_exists($keys)
        {
        $result;
        apc_fetch($keys, $result);
        return $result;
        }
    }
