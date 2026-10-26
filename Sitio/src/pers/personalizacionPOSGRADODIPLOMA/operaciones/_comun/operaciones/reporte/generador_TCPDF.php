<?php

namespace personalizacionPOSGRADODIPLOMA\operaciones\_comun\operaciones\reporte;

set_include_path('.:' . substr_replace(dirname(__FILE__), 'lib/', -38));
//require_once('tcpdf/config/tcpdf_config.php');
require_once("tcpdf/tcpdf.php");
ini_set('display_errors', 0);

use kernel\kernel;
use \siu\guarani;
use \kernel\util\u;

class generador_TCPDF extends \TCPDF {

    function generador_pdf() {
        $this->TCPDF('P', 'mm', 'A4', true, 'UTF-8', false);
        $this->SetAutoPageBreak(false, 0);
        $this->SetMargins(40, 40, 40);
        $this->setPrintFooter(false);
        $this->setPrintHeader(false);
        $this->SetFont('times', '', 10);
        $this->SetFillColor(0, 0, 0, 100);
        $this->SetTextColor(0, 0, 0, 100);
        $this->SetDrawColor(0, 0, 0, 100);
        $this->SetTextColorArray(0, 0, 0, 100);
        $this->SetFontSubsetting(false);
        $this->setJPEGQuality(100);
        $this->AddPage();
    }

}