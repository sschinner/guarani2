<?php
require_once( dirname(__FILE__).'/../config/paths.inc.php' );
require_once( CLASE_BD );
require_once( PEDIDO_HTTP );
require_once( CLASE_JSON_RESPUESTA );
require_once( INTERFACE_CACHE );
require_once( CLASE_CACHE_APC );
require_once( CLASE_EXCEPCION_CONEXION );
require_once( CLASE_EXCEPCION_CONSULTA );
require_once( CLASE_EXCEPCION_PERMISO );
require_once( CLASE_LOG );

try 
{
  $pedido = new PedidoHTTP();
  $cache = CLASE_CACHE;
  $respuestaHTTP = null;
  $respuestaHTTPClase = 'JSONRespuesta';

  $clase = $pedido->getClaseAccion(); 

  if ( $pedido->getUsuario()->tienePermisos($clase))
  {
    if ($pedido->esGet() and $cache::estaCacheado($pedido->getQueryString()) and USA_CACHE)
    {
        $respuestaHTTP = $cache::traerDeCache( $pedido->getQueryString() ); 
    }
    else
    {
        $accion = new $clase();
        $respuestaHTTPClase = $accion->getClaseRespuesta();        
        $accion->restringirSoloAUas($pedido->getUsuario()->getUasLimitadas());
        $accion->setPedido( $pedido );
        $respuesta = $accion->obtenerRespuesta();
        $respuestaHTTP = new $respuestaHTTPClase( 1, null, $respuesta );
        USA_CACHE and $cache::cachear($pedido->getQueryString(), $respuestaHTTP, false, $accion->getVitalidadSegundos());
    }
  }
  else
  {
    throw new PermisoException($pedido->getAccion().': No tiene suficientes permisos para la accion');
  }

}
catch (PDOConexionException $e) //@TODO: refactoring (evitar repetir codigo)
{
  $respuestaHTTP = new $respuestaHTTPClase( -1, Log::procesar_excepcion_bd($e), array('tipo_error'=>'base_de_datos'), $e->getCodigoHttp());
}
catch (PDOException $e) 
{
  $respuestaHTTP = new $respuestaHTTPClase( -1, Log::procesar_excepcion_bd($e), array('tipo_error'=>'base_de_datos'), $e->getCodigoHttp());
}
catch (HttpExceptionInterface $e) 
{
  $respuestaHTTP = new $respuestaHTTPClase( -1, Log::procesar_excepcion($e), array('tipo_error'=>'permisos'), $e->getCodigoHttp());
}
catch (Exception $e) 
{ 
  $respuestaHTTP = new $respuestaHTTPClase( -1, $e->getMessage(), array('tipo_error'=>'aplicacion'), 500 );
}

$respuestaHTTP->mostrar();
