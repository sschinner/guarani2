<?php

class ConsultaSQL extends Consulta
{

    protected $sql;
    protected $ua;
    protected $sistema = null;

    public function __construct($sql, $ua = null, $sistema = null)
    {
        $this->sistema = $sistema;
        $this->sql = $sql;
        if ($ua) {
            parent::__construct($ua);
        }
        else {
            parent::__construct();
        }
    }

    protected function armarDefinicion()
    {
        
    }

    protected function setConsulta()
    {
        if ($this->sistema) {
            $var_consulta = "consulta_".$this->sistema;
            $this->$var_consulta = $this->sql;
        }
        $this->consulta = $this->sql;
    }

    protected function getSistemasCompatibles()
    {
        if ($this->sistema) {
            return array($this->sistema => true);
        }
        return parent::getSistemasCompatibles();
    }

}
