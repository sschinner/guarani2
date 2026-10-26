<?php

namespace personalizacionUA\operaciones\_comun\operaciones\reporte;

set_include_path('.:' . substr_replace(dirname(__FILE__), 'lib/', -38));
require_once('tcpdf/config/tcpdf_config.php');
require_once("tcpdf/tcpdf.php");
ini_set('display_errors', 0);

use kernel\kernel;
use \siu\guarani;
use \kernel\util\u;

class generador_pdf_TasaEgreso extends \TCPDF {

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

    function imprimir($datos) {
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

        $data = $datos->get_data_reporte();
        ob_clean();
        $blanco = array(0, 0, 0, 0);

        $u = new \siu\modelo\entidades\unidad_academica(\siu\guarani::get_ua_id());
        $nombreUA = $u->get_nombre();

        $this->Image(substr_replace(dirname(__FILE__), 'www/img/unl.JPG', -38), 90, 20, 25, 25, 'JPG', '', '', true, 300, '', false, false, 0, false, false, false);
        $this->SetFont('times', 'BU', 13);
        $this->SetXY(15, 60);
        $this->Cell(20, 4, 'CERTIFICADO DE PAGO DE TASA POR EXPEDICIÓN DE DIPLOMA DE EGRESADO', 0, 0, 'L', false, '', 0, false, 'T', 'C');
        $this->SetFont('times', '', 12);
        $this->MultiCell(180, 20, utf8_encode($data['parrafo1']), 0, '', false, 1, 15, 80, true, 0, false, true, 0, 'T', false);
        $this->MultiCell(180, 20, utf8_encode($data['parrafo2']), 0, '', false, 1, 15, 100, true, 0, false, true, 0, 'T', false);

        $this->SetFont('times', 'B', 10);
        $this->Text(15, 130, 'Código de verificación:');
        $this->SetFont('times', 'BI', 10);
        $this->Text(90, 130, 'Timbrado de Tesorería de la Universidad Nacional del Litoral');

        $this->SetFont('times', 'B', 10);
        $this->Text(30, 265, 'Universidad Nacional del Litoral');
        $this->Text(30, 272, utf8_encode($nombreUA));

        $pdf = "tasaEgreso.pdf";
        $this->Output("$pdf", 'I');
    }

}

?>
