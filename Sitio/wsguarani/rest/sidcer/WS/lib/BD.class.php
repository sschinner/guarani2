<?php

require_once( dirname(__FILE__) . '/../config/paths.inc.php' );
require_once( CONFIG );
require_once( CLASE_JSON_RESPUESTA );
require_once( CLASE_EXCEPCION_CONEXION );
require_once( CLASE_EXCEPCION_CONSULTA );

class BD
{

    static protected $conexiones;
    protected $conexion = null;
    protected $ua = null;

    protected function __construct($objCon, $ua = null)
    {
        $this->conexion = $objCon;
        $this->ua = $ua;
    }

    static function desconectar($ua)
    {
        self::$conexiones[$ua] = null;
    }

    static function opciones_pdo($datos_conexion)
    {
        $atributos_pdo = array(PDO::ATTR_TIMEOUT => 'timeout');
        $opciones = array();
        foreach ($atributos_pdo as $atributo_pdo => $atributo) {
            if (isset($datos_conexion[$atributo])) {
                $opciones[$atributo_pdo] = $datos_conexion[$atributo];
            }
        }

        return $opciones;
    }

    private static function conexion_pdo($datos_conexion, $fetch_mode = PDO::FETCH_ASSOC)
    {
        $host = $datos_conexion["host"];
        $service = $datos_conexion["service"];
        $db = $datos_conexion["bd"];
        $server = $datos_conexion["conexion"];
        $protocolo = $datos_conexion["protocolo"];
        if (($datos_conexion["tipo_conexion"] == "pdo_guarani") or ( $datos_conexion["tipo_conexion"] == "informix")) {
            $conexion = "informix:host=$host;service=$service ;database=$db;server=$server;protocol=$protocolo;EnableScrollableCursors=1";
        } elseif ($datos_conexion["tipo_conexion"] == "mysql") {
            $conexion = 'mysql:host=' . $datos_conexion['host'] . ';' . ( $datos_conexion['service'] != '' ? 'port=' . $datos_conexion['service'] . ';' : '') . 'dbname=' . trim($datos_conexion["bd"]);
        } else {
            throw new PDOException($datos_conexion["tipo_conexion"] . ': No soportado.');
        }
        $pdo = new PDO($conexion, $datos_conexion["usuario"], $datos_conexion["clave"], static::opciones_pdo($datos_conexion));
        $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, $fetch_mode);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdo->setAttribute(PDO::ATTR_CASE, PDO::CASE_NATURAL);

        return new static($pdo, $ua);
    }
    
    
    private static function conectar_en_lista($datos_conexion, $conexion_id, $fetch_mode)
    {
        global $secundarios;
        $cache = null;
        $cache_clave = null;
        if (CONEXIONES_USA_CACHE) {
            $cache = CONEXIONES_CLASE_CACHE;
            $cache_clave = 'conexion.'.$conexion_id;
        }
        // Se arma la lista en orden de conexiones sobre las cuales se intentará conectar.
        $lista_conexiones = array();
        $orden_cache = -1;
        if ($cache and $cache::estaCacheado($cache_clave)) {
            $lista_conexiones[] = $cache::traerDeCache($cache_clave);
            $orden_cache=0;
        }
        $lista_conexiones[] = $datos_conexion;
        $uas_intentos = array('primario:'.$conexion_id);
        if (isset($datos_conexion['secundarios']) and !empty($datos_conexion['secundarios'])) {
            foreach ($datos_conexion['secundarios'] as $una_conexion) {
                if (!isset($secundarios[$una_conexion])) {
                    throw new PDOConexionException(new Exception('No se encontraron los datos de la conexion secundaria '.$una_conexion), $conexion_id);
                }
                $lista_conexiones[] = $secundarios[$una_conexion];
                $uas_intentos[] = 'secundario:'.$una_conexion;
            }
        }
        
        // Se intenta conectar en el orden de conexiones establecidas en la lista
        $conexion_devuelta = null;
        $ultima_exepcion = null;
        foreach ($lista_conexiones as $orden => $conexion) {
            try {
                $conexion_devuelta = static::conexion_pdo($conexion, $fetch_mode);
                if ($cache and !$cache::estaCacheado($cache_clave)) {
                    $cache::cachear($cache_clave, $conexion, true, CONEXIONES_CACHE_TTL);
                }
                return $conexion_devuelta;
            } catch (PDOException $e) {
                if ($cache and $orden == $orden_cache) { // Se cayó la BD con los datos cacheados
                    $cache::borrarValorDeCache($cache_clave);
                }
                $ultima_exepcion = $e;
            }
        }
        
        throw new PDOConexionException($ultima_exepcion, implode(', ', $uas_intentos));
    }
    
    static function conectar($ua = null, $fetch_mode = PDO::FETCH_ASSOC)
    {
        global $bdGuarani;
        global $secundarios;

        $bds = array();

        if ($ua) {
            if (!is_array($ua)) {
                $bds[] = $ua;
            } else {
                $bds = $ua;
            }
        } else {
            foreach ($bdGuarani as $ua => $unaBase) {
                $bds[] = $ua;
            }
        }


        $conexiones = array();
        
        foreach ($bds as $ua) {
            if (!isset(self::$conexiones[$ua])) {
                if (isset($bdGuarani[$ua])) {
                
                    $conexiones[$ua] = self::$conexiones[$ua] = static::conectar_en_lista($bdGuarani[$ua], $ua, $fetch_mode);
                  
                    } else {
                    throw new PDOConexionException(new PDOException('No existe la UA'), $ua);
                }
            } else {
                $conexiones[$ua] = self::$conexiones[$ua];
            }
        }

        return $conexiones;
    }

    protected static function error(PDOException $e, $extra = null)
    {
        $respuesta = new JSONRespuesta(-1, $e->getMessage() . ($extra ? ': ' . $extra : ''));
        $respuesta->mostrar();
    }

    public function consultar($strSql, $params = null, $es_actualizacion = false, $fetch = PDO::FETCH_ASSOC)
    {
        $query = $this->conexion->prepare($strSql);
        if ($params and is_array($params) and ! empty($params)) {
            foreach ($params as $k => $v) {
                $k = ':' . trim($k);
                if (strpos($strSql, $k) !== false) {
                    $query->bindValue($k, $v);
                }
            }
        }
        $resultado = $query->execute();

        if ($es_actualizacion) {
            return $resultado;
        }

        return $query->fetchAll();
    }

    public function desconectar_instancia()
    {
        // No hay desconectar en PDO. Se deconecta, seteando sus referencias a null.
        $this->conexion = null;
        static::desconectar($this->ua);
    }

}
