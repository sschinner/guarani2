<?php

include_once(dirname(__DIR__) . '/cronTramites/logs/log4php/Logger.php');

Logger::configure('logs/config.xml');

class logTramiteAnalitico {

    private $log;

    public function __construct() {
        $this->log = Logger::getLogger(__CLASS__);
    }

    public function info($mensaje) {
        $this->log->info($mensaje);
    }

    public function warn($mensaje) {
        $this->log->warn($mensaje);
    }
    
    public function error($mensaje) {
        $this->log->error($mensaje);
    }
    
    public function fatal($mensaje) {
        $this->log->fatal($mensaje);
    }

}

class mailTramiteAnalitico {

    private $log;

    public function __construct() {
        $this->log = Logger::getLogger(__CLASS__);
    }

    public function errorMail($mensaje) {
        $this->log->error($mensaje);
    }

}
