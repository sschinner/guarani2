<?php

require_once(CLASE_RESPUESTA);

class JSONDatosCrudosRespuesta extends AbstractRespuesta
{

    protected function getContenido()
    {
        return $this->datos;
    }

    protected function codificar($contenido)
    {
        return json_encode($contenido);
    }

}
