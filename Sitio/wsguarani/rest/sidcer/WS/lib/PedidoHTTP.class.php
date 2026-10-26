<?php

require_once( dirname(__FILE__).'/../config/paths.inc.php' );
require_once( CLASE_USUARIO );
require_once( CLASE_ACCION );

class PedidoHTTP {
    
  const METODO_GET = 'get';
  const METODO_POST = 'post';
  const METODO_PUT = 'put';
  const METODO_DELETE = 'delete';
  

  private $parametros = array();
  private $usuario = null;
  private $query_string = null;
  private $metodo = null;

  public function __construct($autenticarse = true)
  {
    if ($autenticarse)
    {
      $this->usuario = $this->autenticarse();
    }
    $this->parametros = $this->parsear($_GET['params']);
    $this->query_string = $_GET['params'];
    $this->metodo = strtolower($_SERVER['REQUEST_METHOD']);
  }

  private function parsearQueryString() {
    $parametros_qs = null;
    $url = parse_url($_SERVER['REQUEST_URI']);
    parse_str($url['query'], $parametros_qs);
    
    return $parametros_qs;
  }
  
  private function parsear($sParametros)
  {

    $sParametros = rtrim ($sParametros, "/");
    $parametros = explode('/', $sParametros);
    
    if ( empty($parametros) ) {
      return null;
    }
    return array( 
      'accion' => array_shift($parametros),
      'parametros' => $parametros,
      'parametros_qs' => $this->parsearQueryString(),
    );
  }

  public function esPost()
  {
    return $this->esMetodo(static::METODO_POST);
  }

  public function esGet()
  {
    return $this->esMetodo(static::METODO_GET);
  }

  public function esMetodo($metodo)
  {
    return ($this->metodo == $metodo);
  }  
  
  public function getParametros()
  {
    return $this->parametros['parametros'];
  }

  public function getParametrosQueryString()
  {
    return $this->parametros['parametros_qs'];
  }  
  
  public function getPostParametros()
  {
    return $_POST;
  }  

  public function getQueryString()
  {
    return $this->query_string;
  }
  
  public function getAccion()
  {
    return $this->parametros['accion'];
  }

  public function getClaseAccion()
  {
    return Accion::aClase( $this->getAccion() );
  }


  public function getUsuario()
  {
    return $this->usuario;
  }

  public function autenticarse()
  {
    if ( !isset($_SERVER['PHP_AUTH_USER']) or 
         !($usuario = Usuario::validarUsuario($_SERVER['PHP_AUTH_USER'], $_SERVER['PHP_AUTH_PW']))
       ) {
      $this->autenticar();
    }
    
    return $usuario;
  }

  private function autenticar()
  {
    header('WWW-Authenticate: Basic realm="Guarani REST"');
    header('HTTP/1.0 401 Unauthorized');
    exit;
  }
}
