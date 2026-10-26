<?php

class ConsultaSubeActualizaSolicitud extends Consulta
{

    public function __construct()
    {
        parent::__construct();
        $this->setConsultaDeActualizacion(true);
        $this->setParametrosPorPrepare(true);
        $this->setMetodoHttpRequerido(PedidoHTTP::METODO_POST);
    }

    protected function getSistemasCompatibles()
    {
        return array('guarani' => true);
    }

    protected function armarDefinicion()
    {
        $this->setDefinicion(0, 'unidad_academica', 'UnidadAcademica');
        $this->setDefinicion(1, 'tid', 'Hash');
        $this->setDefinicion(null, 'respuesta', 'RespuestaSube');
        $this->setDefinicion(null, 'respuesta_descripcion', 'Texto');
    }

    protected function evaluaRespuestaSube($unValor)
    {
        /*
          Posibles respuestas:
          'ACEPTADA' : Solicitud aceptada
          'RECHAZADA' : Solicitud rechazada
         */
        return in_array($unValor, array('ACEPTADA', 'RECHAZADA'));
    }

    protected function evaluaTexto($unValor)
    {
        if (parent::evaluaTexto($unValor))
        {
            $validos = array('_', ' ', '-');
            return ctype_alnum(str_replace($validos, '', $unValor));
        }
        return false;
    }

    protected function setConsulta()
    {
        $this->consulta = "UPDATE u819_boleto_solicitudes SET respuesta = :respuesta, respuesta_fecha = CURRENT, respuesta_desc = :respuesta_descripcion, procesado = 'S' WHERE unidad_academica = :unidad_academica and hash = :tid ; ";
    }

    public function setParametros($params)
    {
        parent::setParametros($params);
        $this->setUas($params[0]);
    }

    public function obtenerRespuesta()
    {
        if (!$this->existeSolicitud())
        {
            throw new Exception("No existe una solicitud en la unidad académica con el tid informado");
        }
        $respuesta = parent::obtenerRespuesta();
        unset($respuesta[0]['ua']);
        
        return $respuesta[0];
    }

    private function existeSolicitud()
    {
        $ultimos_accesos = new ConsultaSQLPrepare("SELECT count(*) as cant FROM u819_boleto_solicitudes WHERE hash = :tid", $this->getParametro('unidad_academica'));
        $ultimos_accesos->setParametros(array('tid' => $this->getParametro('tid')));
        $existe_solicitud = $ultimos_accesos->obtenerRespuesta()[0]['cant'];

        return ($existe_solicitud > 0);
    }

}
