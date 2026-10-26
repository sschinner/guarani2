<?php

require_once( dirname(__FILE__).'/../config/paths.inc.php' );
require_once( CONFIG );

class Accion 
{

  public static function aClase($unaAccion)
  {
    global $acciones;
    if (isset($acciones[$unaAccion]))
    {

      return $acciones[$unaAccion];
    }
    else
    {
      throw new Exception($unaAccion.': La accion no existe.');
    }
  }

}

