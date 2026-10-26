<?php

namespace personalizacionUA\operaciones\_comun\operaciones\reporte;

set_include_path('.:' . substr_replace(dirname(__FILE__), 'lib/', -38));
require_once('tcpdf/config/tcpdf_config.php');

require_once("tcpdf/tcpdf.php");

ini_set('display_errors', 0);

use kernel\kernel;
use siu\guarani;
use kernel\util\u;

class generador_pdf_ActaCursada extends \TCPDF {

    function generador_pdf_ActaCursada() {
        $this->TCPDF('P', 'mm', 'A4', true, 'UTF-8', false);
        $this->SetAutoPageBreak(false, 0);
        $this->SetMargins(40, 40, 40);
        $this->setPrintFooter(false);
        $this->setPrintHeader(false);
        $this->SetFont('Helvetica', '', 10);
        $this->SetFillColor(0, 0, 0, 100);
        $this->SetTextColor(0, 0, 0, 100);
        $this->SetDrawColor(0, 0, 0, 100);
        $this->SetTextColorArray(0, 0, 0, 100);
        $this->SetFontSubsetting(false);
        $this->setJPEGQuality(100);
        $this->AddPage();
    }

    function imprimir($datos,$usuario) {

     // print_r($datos['ENCABEZADO']);
//        die;
        $totalPresentes = 0;
        for ($k = 0; $k < $datos['ENCABEZADO']['FOLIOS']; $k++) {


            $this->SetAutoPageBreak(false, 0);
            $this->SetMargins(40, 40, 40);
            $this->setPrintFooter(false);
            $this->setPrintHeader(false);
            $this->SetFont('Helvetica', '', 10);
            $this->SetFillColor(0, 0, 0, 100);
            $this->SetTextColor(0, 0, 0, 100);
            $this->SetDrawColor(0, 0, 0, 100);
            $this->SetTextColorArray(0, 0, 0, 100);
            $this->SetFontSubsetting(false);
            $this->setJPEGQuality(100);
            $this->AddPage();

            $blanco = array(0, 0, 0, 0);

            $this->SetLineWidth(0.4);
            $this->RoundedRect(7, 8, 196, 34, 2, '0000', 'FD', '', $blanco);

            $this->Image(substr_replace(dirname(__FILE__), 'www/img/unl.JPG', -38), 8, 10, 15, 15, 'JPG', '', '', true, 300, '', false, false, 0, false, false, false);
            $this->SetLineWidth(0.2);
            $this->Line(24, 8, 24, 26);
            $this->Line(24, 14, 203, 14);
            $this->Line(7, 26, 23, 26);
            $this->Line(23, 26, 203, 26);

            $this->SetFont('Helvetica', 'B', 11);
            $this->SetY(9);
            $this->SetX(90);

            $this->Cell(80, 4, 'ACTA DE REGULARES', 0, 0, 'L', false, '', 0, false, 'T', 'C');
            $this->SetFont('Helvetica', 'B', 10);
            $this->SetY(9);
            $this->SetX(25);
            $this->Text(25, 15, 'Facultad: ');
            $this->Text(8, 26, 'Asignatura: ');
            $this->Text(130, 26, 'Comisión: ');

            $this->Text(8, 31, 'Año Académico: ');
            $this->Text(50, 31, 'Periódo Lectivo: ');
            $this->Text(120, 31, 'F. Inicio: ');
            $this->Text(155, 31, 'F. Fin: ');
            $this->Text(25, 21, 'Carrera: ');
            $this->Text(160, 15, 'Acta Nº: ' . $datos['ENCABEZADO']['ACTA']);
            $this->Text(160, 21, 'Libro: ');
            $this->SetFont('Helvetica', '', 10);
            $this->Text(42, 15, utf8_encode($datos['ENCABEZADO']['NUA']));
            $this->Text(42, 21, utf8_encode(substr($datos['ENCABEZADO']['NCARRERA'],0,45)));
            $this->Text(28, 26, utf8_encode(substr($datos['ENCABEZADO']['MATERIA'],0,45)));
            $this->Text(150, 26, utf8_encode(substr($datos['ENCABEZADO']['COMISION'],0,23)));
            $this->Text(135, 31, $datos['ENCABEZADO']['FINICIO']);
            $this->Text(167, 31, $datos['ENCABEZADO']['FFIN']);
            $this->Text(35, 31, $datos['ENCABEZADO']['ANIO_ACAD']);
            $this->Text(78, 31, utf8_encode(substr($datos['ENCABEZADO']['PER_LEC'],0,23)));

            $this->Line(7, 36, 203, 36);

            $this->SetLineWidth(0.2);

            if ($datos['CUERPO'][1][0]['RESULTADO'] != 'Sin resultado') {
                $this->SetFont('Helvetica', 'B', 10);
                $this->Text(7, 38, 'Nro.');
                $this->Text(23, 38, 'Legajo');
                $this->Text(48, 38, 'Apellido y Nombre(s)');
                $this->Text(115, 38, 'Fecha de Regularidad');
                $this->Text(157, 38, 'Nota');
                $this->Text(171, 38, 'Resultado');
            } else {
                $this->SetFont('Helvetica', 'B', 10);
                $this->Text(7, 38, 'Nro.');
                $this->Text(23, 38, 'Legajo');
                $this->Text(48, 38, 'Apellido y Nombre(s)');
                $this->Text(115, 38, 'Cond. Reg.');
                $this->Text(139, 38, 'Nota');
                $this->Text(155, 38, 'Descripción');
                $this->Text(179, 38, 'Resultado');
            }

            $cantidad = $cant;
            $y = 42;
            $i = 1;
            $cantAus = $cantApr = $cantDis = $cantBue = $cantIns = $cantMuy = $cantSob = 0;
            $this->SetFont('Helvetica', '', 9);
            foreach ($datos['CUERPO'][$k + 1] as $fila) {
                if ($fila['RESULTADO'] != 'Sin resultado') {
                    $actaConNotas = true;
                    break;
                }
            }
            foreach ($datos['CUERPO'][$k + 1] as $fila) {

                $this->Line(7, $y, 203, $y);
                $this->Text(7 + 2, $y + 1, $i);
                $this->Text(20, $y + 1, $fila['LEGAJO']);
                $this->Text(48, $y + 1, substr(utf8_encode($fila['APE_NOM']), 0, 38));
                if ($actaConNotas) {
                    $this->Text(120, $y + 1, $fila['FECHA']);
                    $this->Text(159, $y + 1, $fila['NOTA_NUM']);
                    $this->Text(171, $y + 1, substr(utf8_encode($fila['CONDICION']),0,20));
                } else {
                    $this->RoundedRect(120, $y + 1, 4, 4, 2, '0000', 'FD', '', $blanco);
                }
                $i++;
                $y+=6;
            }
            $this->Line(7, $y, 203, $y);
            $this->RoundedRect(7, 42, 196, $y - 42, 2, '0000', 'S', '', $blanco);

            //ULTIMO CUADRO
            $this->RoundedRect(7, 225, 196, 58, 2, '0000', 'FD', '', $blanco);
            $this->SetFont('Helvetica', '', 8);

            $this->Line(7, 235, 203, 235);

            $this->Line(7, 242, 203, 242);
            $this->Line(7, 254, 203, 254);
            $this->Line(7, 272, 203, 272);
            //$this->Line(55, 272, 55, 283);
            $this->Line(95, 272, 95, 283);
            $this->Line(148, 272, 148, 283);

            $this->SetFont('Helvetica', 'B', 10);
            $this->Text(8, 231, 'Escala de Notas: ');
            $this->Text(8, 238, 'Condición de Regularidad: ');
            $this->Text(8, 243, 'Observaciones');
            $this->Text(8, 254, 'Docentes (Firma y Aclaración)');

            $this->Text(8, 273, 'Confeccionó');
            $this->SetFont('Helvetica', 'B', 10);
            $this->Text(8, 277, '');
            $this->SetFont('Helvetica', '', 10);
            $this->Text(8, 277, utf8_encode($usuario));
            $this->SetFont('Helvetica', 'B', 10);
            //$this->Text(56, 273, 'Firma');
            $this->Text(96, 273, 'Jefe Alumnado');
            $this->Text(149, 273, 'Computadora');
            $this->SetFont('Helvetica', '', 9);
            $this->MultiCell(175, 5,utf8_encode($datos['ENCABEZADO']['DOCENTES']), 0, 'L', false, 1, 8, 260, true, 0, false, true, 0, 'T', false);
            $this->SetFont('Helvetica', '', 10);
            $this->Text(55, 238, 'Promocionó; Regular; Libre; Abandonó; Promoción Pendiente');
            $escalaNotas = "";

            $folio = $k + 1;
            $this->SetFont('times', '', 9);
            $this->Text(8, 288, date('d-m-Y H:i:s'));
            $anio = explode('/', $datos['ENCABEZADO']['APERTURA']);
            $this->Text(96, 288, 'Acta: ' . $datos['ENCABEZADO']['ACTA']);
            $this->Text(165, 288, 'Folio: ' . $folio);
        }

        $this->Text(35, 231, substr($escalaNotas, 0, -2));
        $pdf = "acta_cursado_nro_" . $datos['ENCABEZADO']['ACTA'] . ".pdf";
        $this->Output("$pdf", 'I');
        return $pdf;
    }

}

?>
