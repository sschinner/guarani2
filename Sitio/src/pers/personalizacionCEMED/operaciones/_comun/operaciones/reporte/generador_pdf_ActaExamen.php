<?php

namespace personalizacionCEMED\operaciones\_comun\operaciones\reporte;

set_include_path('.:' . substr_replace(dirname(__FILE__), 'lib/', -38));
require_once('tcpdf/config/tcpdf_config.php');
//require("tcpdf/config/lang/spa.php");	
require_once("tcpdf/tcpdf.php");
ini_set('display_errors', 0);

use kernel\kernel;
use \siu\guarani;
use \kernel\util\u;

class generador_pdf_ActaExamen extends \TCPDF {

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

    function imprimir($datos, $usuario) {

        $totalPresentes = 0;
        for ($k = 0; $k < $datos['ENCABEZADO']['FOLIO']; $k++) {
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
            $this->SetX(25);

            $this->Cell(80, 4, 'U.N.L. Acta de Exámenes Número: ' . $datos['ENCABEZADO']['ACTA'], 0, 0, 'L', false, '', 0, false, 'T', 'C');
            $this->SetFont('Helvetica', 'B', 10);
            $this->SetY(9);
            $this->SetX(25);
            $this->Text(25, 15, 'Facultad: ');
            $this->Text(8, 26, 'Turno de Examen: ');
            $this->Text(130, 26, 'Mesa: ');
            $this->Text(160, 26, 'Apertura: ');
            $this->Text(8, 31, 'Asignatura: ');
            $this->Text(25, 21, 'Carrera: ');
            $this->Text(170, 21, 'Plan: ');
            $this->SetFont('Helvetica', '', 10);
            $this->Text(42, 15, utf8_encode($datos['ENCABEZADO']['NUA']));
            $this->Text(42, 21, utf8_encode(substr($datos['ENCABEZADO']['NCARRERA'],0,60)));
            $this->Text(180, 21, $datos['ENCABEZADO']['PLAN']);
            $this->Text(39, 26, utf8_encode($datos['ENCABEZADO']['TURNO']));
            $this->Text(140, 26, $datos['ENCABEZADO']['MESA']);
            $this->Text(177, 26, $datos['ENCABEZADO']['APERTURA']);
            $this->Text(28, 31, utf8_encode($datos['ENCABEZADO']['MATERIA']));

            $this->Line(7, 36, 203, 36);

            $this->SetLineWidth(0.2);
            $this->Line(15, 36, 15, 42);
            $this->Line(40, 36, 40, 42);
            $this->Line(97, 36, 97, 42);
            $this->Line(123, 36, 123, 42);
            $this->Line(146, 36, 146, 42);
            $this->Line(158, 36, 158, 42);

            $this->SetFont('Helvetica', 'B', 10);
            $this->Text(7, 38, 'Nro.');
            $this->Text(20, 38, 'Legajo');
            $this->Text(55, 38, 'Apellido y Nombre(s)');
            $this->Text(100, 38, 'Documento');
            $this->Text(125, 38, 'F. Examen');
            $this->Text(146, 38, 'Cond.');
            $this->Text(161, 38, 'Calificación (Concepto)');

            $y = 42;
            $i = 1;
            $cantAus = $cantApr = $cantDis = $cantBue = $cantIns = $cantMuy = $cantSob = 0;
           $this->SetFont('Helvetica', '', 9);

            foreach ($datos['CUERPO'][$k + 1] as $fila) {

                if ($fila['CONDICION'] == 'Libre') {
                    $condicion = "L";
                } else if ($fila['CONDICION'] == 'Regular') {
                    $condicion = "R";
                } else if ($fila['CONDICION'] == 'EP') {
                    $condicion = "EP";
                }else{
                    $condicion = "PP";
                }

                $this->Line(7, $y, 203, $y);
                $this->Line(15, $y, 15, $y + 8);
                $this->Line(40, $y, 40, $y + 8);
                $this->Line(97, $y, 97, $y + 8);
                $this->Line(123, $y, 123, $y + 8);
                $this->Line(146, $y, 146, $y + 8);
                $this->Line(158, $y, 158, $y + 8);

                $this->Text(7 + 2, $y + 3, $i);
                $this->Text(14 + 2, $y + 3, $fila['LEGAJO']);

                $this->MultiCell(50, 7, utf8_encode($fila['APE_NOM']), 0, 'L', 0, 1, 41, $y+3, true, 0, false, true, 7);

                $this->Text(99 + 2, $y + 3, $fila['NRO_DOCUMENTO']);
                if ($fila['RESULTADO'] != "Sin resultado")
                    $this->Text(123 + 2, $y + 3, $fila['FECHA']);

                $this->Text(146 + 2, $y + 3, $condicion);
                if ($fila['RESULTADO'] != "Sin resultado") {
                    if ($fila['RESULTADO'] == 'Ausente') {
                        $this->Text(158 + 2, $y + 3, " AUSENTE ");
                        $cantAus++;
                    } else {
                        $this->Text(158 + 2, $y + 3, $fila['NOTA_NUM'] . " " . utf8_encode($fila['NOTA_LETRAS']) . " " . utf8_encode($fila['CONCEPTO']));
                    }

                    switch ($fila['NOTA_NUM']) {
                        case 10:
                            $cantSob++;
                            break;
                        case 9:
                            $cantDis++;
                            break;
                        case 8:
                            $cantMuy++;
                            break;
                        case 7:
                            $cantBue++;
                            break;
                        case 6:
                            $cantApr++;
                            break;
                        case 'A':
                            $cantApr++;
                            break;
                        case 'N':
                            $cantIns++;
                            break;
                        case 5:
                            $cantIns++;
                            break;
                        case 4:
                            $cantIns++;
                            break;
                        case 3:
                            $cantIns++;
                            break;
                        case 2:
                            $cantIns++;
                            break;
                        case 1:
                            $cantIns++;
                            break;
                    }
                }
                $i++;
                $y+=8;
            }
            $this->Line(7, $y, 203, $y);
            $this->RoundedRect(7, 42, 196, $y - 42, 2, '0000', 'S', '', $blanco);

            //ULTIMO CUADRO
            $this->RoundedRect(7, 230, 196, 58, 2, '0000', 'FD', '', $blanco);
            $this->SetFont('Helvetica', '', 8);

            $this->Line(7, 240, 203, 240);
            $this->Line(17, 230, 17, 240);
            $this->Line(27, 230, 27, 240);
            $this->Line(37, 230, 37, 240);
            $this->Line(57, 230, 57, 240);
            $this->Line(79, 230, 79, 240);
            $this->Line(101, 230, 101, 240);
            $this->Line(119, 230, 119, 240);
            $this->Line(140, 230, 140, 240);
            $this->Line(177, 230, 177, 240);

            $this->Line(7, 247, 203, 247);
            $this->Line(7, 259, 203, 259);
            $this->Line(7, 277, 203, 277);
           // $this->Line(55, 277, 55, 288);
            $this->Line(95, 277, 95, 288);
            $this->Line(148, 277, 148, 288);

            $this->SetFont('Helvetica', '', 9);
            $this->Text(8, 231, 'Insc.');
            $this->Text(18, 231, 'Aus.');
            $this->Text(27, 231, 'Exam.');
            $this->Text(37, 231, 'Sobres. (10)');
            $this->Text(57, 231, 'Distinguido (9)');
            $this->Text(79, 231, 'Muy Bueno (8)');
            $this->Text(102, 231, 'Bueno (7)');
            $this->Text(120, 231, 'Aprobado (6)');
            $this->Text(141, 231, 'Insuficiente (1-2-3-4-5)');
            $folio = $k + 1;
            $totalPresentes = $totalPresentes + $i - 1;
            if ($folio != $datos['ENCABEZADO']['FOLIO']) {
                $this->Text(180, 231, 'Total Pracial');
            } else {
                $this->Text(180, 231, 'Total Final');
            }

            $this->Text(10, 235, $i - 1);
            if ($fila['RESULTADO'] != "Sin resultado") {
                $this->Text(21, 235, $cantAus);
                $this->Text(30, 235, ($i - 1) - $cantAus);
                $this->Text(45, 235, $cantSob);
                $this->Text(66, 235, $cantDis);
                $this->Text(86, 235, $cantMuy);
                $this->Text(107, 235, $cantBue);
                $this->Text(126, 235, $cantApr);
                $this->Text(157, 235, $cantIns);
            }
            if ($folio < 2) {
                $this->Text(186, 235, $i - 1);
            } else {
                $this->Text(186, 235, $totalPresentes);
            }
            $this->SetFont('Helvetica', 'B', 10);
            $this->Text(8, 243, 'Condición de Regularidad: ');
            $this->Text(8, 248, 'Observaciones');
            $this->Text(8, 259, 'Profesores que componen el tribunal(Firma y Aclaración)');
            $this->SetFont('Helvetica', '', 10);            
            $this->MultiCell(175, 5, utf8_encode($datos['ENCABEZADO']['DOCENTES']), 0, 'L', false, 1, 8, 269, true, 0, false, true, 0, 'T', false);
            
            $this->MultiCell(185, 2, $datos['ENCABEZADO']['OBS']."\n", 1, 'J', 1, 1, 8 ,251, true);
            $this->SetFont('Helvetica', 'B', 10);
           // $this->Text(8, 252,  utf8_encode($datos['ENCABEZADO']['OBS']));
            $this->Text(8, 278, 'Confeccionó');
            $this->SetFont('Helvetica', '', 9);
            $this->Text(8, 282, utf8_encode($usuario));
            $this->SetFont('Helvetica', 'B', 10);
            $this->Text(8, 282, '');
            //$this->Text(56, 278, 'Firma');
            $this->Text(96, 278, 'Jefe Alumnado');
            $this->Text(149, 278, 'Computadora');

            $this->SetFont('times', '', 9);
            $this->Text(8, 288, date('d-m-Y H:i:s'));
            $anio = explode('/', $datos['ENCABEZADO']['APERTURA']);
            $this->Text(96, 288, $datos['ENCABEZADO']['ACTA']);
            $this->Text(165, 288, 'Folio: ' . $folio.'/'.$datos['ENCABEZADO']['FOLIO']);

            $this->SetFont('Helvetica', '', 10);
            $this->Text(54, 243, '(PP) Por Promoción; (R)Regular; (L)Libre; (EP)Equiv. Parcial');
        }

        $pdf = "acta_Nro_" . $datos['ENCABEZADO']['ACTA'] . "pdf";
        $this->Output("$pdf", 'I');
        return $pdf;
    }

}

?>
