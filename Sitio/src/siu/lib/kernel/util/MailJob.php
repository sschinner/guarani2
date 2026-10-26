<?php
/**
 * Created by PhpStorm.
 * User: leonel
 * Date: 31/07/14
 * Time: 10:54
 */

namespace kernel\util;
use kernel\kernel;

class MailJob extends mail{

    protected $vendor;
    protected $run_at = null;//la fecha en la que se debe enviar el email.

    function __construct($hacia, $asunto, $cuerpo, $desde=null, $firma='', $charset='utf-8', $run_at=null, $pdo=null)
    {
        parent::__construct($hacia, $asunto, $cuerpo, $desde, $firma, $charset);
        $this->run_at = $run_at;
        $bloque_acceso = kernel::proyecto()->get_parametros_db();
        $this->vendor = strtolower($bloque_acceso['vendor']);
        if(is_null($pdo)) $pdo = kernel::db()->conexion();
        if($this->vendor == 'informix'){//Si la DB es informix...
            //... cargo libreria DJJob informix (extiende de DJJob).
            require_once(__DIR__."/../../DJJob/DJJob_informix.php");
            \DJJob_informix::setConnection($pdo);
        }
        elseif($this->vendor == 'pgsql'){//Si la DB es postgresql...
            //... cargo libreria DJJob (ya venia preparada para postgre).
            require_once(__DIR__."/../../DJJob/DJJob.php");
            \DJJob::setConnection($pdo);
        }
    }

    //https://github.com/jfloff/djjob-zf2
    public function sendLater() {

        if($this->vendor == 'informix'){
            \DJJob_informix::enqueue($this, 'email', $this->run_at);
        }
        elseif($this->vendor == 'pgsql'){
            \DJJob::enqueue($this, 'email', $this->run_at);
        }

    }

    public function perform() {
        $this->enviar();
    }

} 