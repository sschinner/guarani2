<?php

require_once(CLASE_RESPUESTA);

class JSONRespuesta extends AbstractRespuesta
{

    protected function getContenido()
    {
        return array('codigo' => $this->codigoDeRespuesta, 'mensaje' => ($this->mensaje), 'datos' => $this->datos);
    }

    protected function codificar($contenido)
    {
        return json_encode($contenido);
    }

}
