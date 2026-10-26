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
class ConsultaUsuariosWS extends Consulta
{

    public function __construct()
    {
        parent::__construct();
        $this->setVitalidadSegundos(-1);
    }

    protected function armarDefinicion()
    {

    }

    public function consultar()
    {
        return null;
    }

    public function obtenerRespuesta()
    {
        return $this->filtroSalida(array());
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

    public function filtroSalida($unosResultados)
    {
        require_once( dirname(__FILE__) . '/../config/paths.inc.php' );
        require_once(CONFIG);

        global $usuarios;

        return array_keys($usuarios);
    }

}
