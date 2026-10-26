<?php

class ConsultaSQLPrepare extends ConsultaSQL
{

    public function __construct($sql, $ua = null, $sistema = null)
    {
        parent::__construct($sql, $ua, $sistema);
        $this->setParametrosPorPrepare(true);
    }

    protected function verificaConsulta()
    {

        return true;
    }

    public function setParametros($parametros)
    {
        $this->parametros = $parametros;
    }
}
