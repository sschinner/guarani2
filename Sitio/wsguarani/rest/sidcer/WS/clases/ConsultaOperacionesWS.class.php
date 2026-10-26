<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of ConsultaOperacionesWS
 *
 * @author lucianoc
 */
class ConsultaOperacionesWS extends Consulta
{
  public function __construct()
  {
    parent::__construct();
    $this->setVitalidadSegundos(-1);
  }

  protected function armarDefinicion()
  {
    $this->setDefinicion(0, 'usuario', 'TextoSimple');
  }
  public function consultar()
  {
      return null;
  }
  
  public function obtenerRespuesta()
  {
      return $this->filtroSalida( array() );
  }
  protected function setConsulta() 
  {
    $this->consulta = null;
  }

  public function setParametros($params)
  {
    parent::setParametros($params);
    $this->setUas(array());
  }
  
  public function filtroSalida ($unosResultados)
  {
    require_once( dirname(__FILE__).'/../config/paths.inc.php' );
    require_once(CONFIG);
    
    global $acciones;
    global $permisos;
    
    $consulta = null;
    $unosResultados = array(); 
    
    foreach ($acciones as $accion => $clase)
    {
        if (in_array($this->getParametro('usuario'), $permisos[$clase]) or $this->getParametro('usuario') == 'todos')
        {
            $consulta = new $clase();
            $parametros = $consulta->getDefinicionParametros();
            $parametros_post = $consulta->getDefinicionDatosParametros();
            $url = '/'.$accion . '/';
            foreach ($parametros as $parametro)
            {
                $url.=':'.$parametro['nombre'].'/';
            }
            $url = substr_replace($url ,"",-1);
            $unosResultados[$accion] = array(
                'url' => $url,
                'parametros' => $parametros,
                'parametros_post' => $parametros_post,
                'metodo' => $consulta->getMetodoHttpRequerido(),
            );
        }
    }
    
    return $unosResultados;
  }  
}

?>