<?php

require_once( dirname(__FILE__).'/../config/paths.inc.php' );
require_once( CONFIG );

class Usuario
{

  private $usuario = null;

  public static function validarUsuario($unUsuario, $unaContrasena)
  {
    global $usuarios;

    if (isset($usuarios[$unUsuario]) and $usuarios[$unUsuario] == $unaContrasena) 
    {

      return new Usuario($unUsuario);
    }
    else
    {

      return null;
    }
  }

  public function tienePermisos($accion)
  {
    global $permisos;

    if (!isset($permisos[$accion]))
    {
      throw new Exception($accion.': No tiene suficientes permisos para la accion');
    }
    
    return (in_array($this->usuario, $permisos[$accion]));
  }

  public function getUasLimitadas()
  {
    global $usuarios_ua;
    if (isset($usuarios_ua[$this->usuario]))
    {
      return $usuarios_ua[$this->usuario];
    }
    return null;
  }

  public function __construct($unUsuario)
  {

    $this->usuario = $unUsuario;
  }


}