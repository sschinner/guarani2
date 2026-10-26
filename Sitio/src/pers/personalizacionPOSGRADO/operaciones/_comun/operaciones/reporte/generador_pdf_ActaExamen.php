<?php

namespace personalizacionPOSGRADO\operaciones\_comun\operaciones\reporte;

set_include_path('.:'.substr_replace(dirname(__FILE__),'lib/',-38));
require_once('tcpdf/config/tcpdf_config.php');
//require("tcpdf/config/lang/spa.php");	
require_once("tcpdf/tcpdf.php");
ini_set('display_errors', 0);

use kernel\kernel;
use \siu\guarani;
use \kernel\util\u;

class generador_pdf_ActaExamen  extends \TCPDF {

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
        //$this->AliasNbPages(); 
        $this->AddPage();
    }

    function imprimir($datos,$usuario) {
       /*print_r($datos);
       die;*/
        $totalPresentes = 0;
        for ($k = 0; $k < $datos['ENCABEZADO']['FOLIO']; $k++) {
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
            //var_dump($resAlu);die;

            $blanco = array(0, 0, 0, 0);
            
            $this->SetLineWidth(0.4);
            $this->RoundedRect(7, 8, 196, 34, 2, '0000', 'FD', '', $blanco);

            $this->Image(substr_replace(dirname(__FILE__),'www/img/unl.JPG',-38), 8, 10, 15, 15, 'JPG', '', '', true, 300, '', false, false, 0, false, false, false);
            $this->SetLineWidth(0.2);
            $this->Line(24, 8, 24, 26);
            $this->Line(24, 14, 203, 14);
            $this->Line(7, 26, 23, 26);
            $this->Line(23, 26, 203, 26);

            $this->SetFont('times', 'B', 10);
            $this->SetY(9);
            $this->SetX(25);

            $this->Cell(80, 4, 'U.N.L. Acta de Exámenes Número: ' . $datos['ENCABEZADO']['ACTA'], 0, 0, 'L', false, '', 0, false, 'T', 'C');
            $this->SetY(9);
            $this->SetX(25);
            $this->Text(25, 15, 'Facultad: ');
            $this->Text(8, 26, 'Turno de Examen: ');
            $this->Text(130, 26, 'Mesa: ');
            $this->Text(160, 26, 'Apertura: ');
            $this->Text(8, 31, 'Asignatura: ');
            $this->Text(25, 21, 'Carrera: ');
            $this->Text(170, 21, 'Plan: ');
            $this->SetFont('times', '', 10);
            $this->Text(42, 15, utf8_encode($datos['ENCABEZADO']['NUA']));
            $this->Text(42, 21, utf8_encode($datos['ENCABEZADO']['NCARRERA']));
            $this->Text(180, 21, $datos['ENCABEZADO']['PLAN']);
            $this->Text(38, 26, $datos['ENCABEZADO']['TURNO']);
            $this->Text(140, 26, $datos['ENCABEZADO']['MESA']);
            $this->Text(177, 26, $datos['ENCABEZADO']['APERTURA']);
            $this->Text(28, 31, utf8_encode($datos['ENCABEZADO']['MATERIA']));

            /* $this->SetFont('times','B',14);
              $this->Text(170,9,'ES COPIA'); */

            $this->Line(7, 36, 203, 36);

            $this->SetLineWidth(0.2);
            $this->Line(15, 36, 15, 42);
            $this->Line(45, 36, 45, 42);
            $this->Line(95, 36, 95, 42);
            $this->Line(123, 36, 123, 42);
            $this->Line(146, 36, 146, 42);
            $this->Line(158, 36, 158, 42);

            $this->SetFont('times', 'B', 9);
            $this->Text(7, 38, 'Nro.');
            $this->Text(24, 38, 'Legajo');
            $this->Text(55, 38, 'Apellido y Nombre(s)');
            $this->Text(100, 38, 'Documento');
            $this->Text(125, 38, 'F. Examen');
            $this->Text(147, 38, 'Cond.');
            $this->Text(165, 38, 'Calificación (Concepto)');


            //$cantidad=count($valor);
            $y = 42;
            //var_dump($parametros);die;
            $i = 1;
            $cantAus = $cantApr = $cantDis = $cantBue = $cantIns = $cantMuy = $cantSob = 0;
            $this->SetFont('times', '', 9);

            foreach ($datos['CUERPO'][$k + 1] as $fila) {

                if ($fila['CONDICION'] == 'Libre') {
                    $condicion = "L";
                } else if ($fila['CONDICION'] == 'Regular') {
                    $condicion = "R";
                } else {
                    $condicion = "PP";
                }

                $this->Line(7, $y, 203, $y);
                $this->Line(15, $y, 15, $y + 8);
                $this->Line(45, $y, 45, $y + 8);
                $this->Line(95, $y, 95, $y + 8);
                $this->Line(123, $y, 123, $y + 8);
                $this->Line(146, $y, 146, $y + 8);
                $this->Line(158, $y, 158, $y + 8);

                $this->Text(7 + 2, $y + 3, $i);
                $this->Text(15 + 2, $y + 3, $fila['LEGAJO']);
                
                $this->MultiCell(50, 7, utf8_encode($fila['APE_NOM']), 0, 'L', 0, 1, 45, $y+3, true, 0, false, true, 7);

                $this->Text(99 + 2, $y + 3, $fila['NRO_DOCUMENTO']);
                if ($fila['RESULTADO'] != "Sin resultado")
                    $this->Text(123 + 2, $y + 3, $fila['FECHA']);

                $this->Text(146 + 2, $y + 3, $condicion);
                if ($fila['RESULTADO'] != "Sin resultado") {
                    if ($fila['RESULTADO'] == 'Ausente' ) {
                        $this->Text(158 + 2, $y + 3, " AUSENTE ");
                        $cantAus++;
                    } else {
                        $this->Text(158 + 2, $y + 3, $fila['NOTA_NUM'] . " " . $fila['NOTA_LETRAS'] . " " . $fila['CONCEPTO']);
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
                       /* case '':
                            $cantAus++;
                            break;*/
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
            $this->SetFont('times', '', 8);

            $this->Line(7, 240, 203, 240);
            $this->Line(17, 230, 17, 240);
            $this->Line(27, 230, 27, 240);
            $this->Line(37, 230, 37, 240);
            $this->Line(59, 230, 59, 240);
            $this->Line(79, 230, 79, 240);
            $this->Line(99, 230, 99, 240);
            $this->Line(119, 230, 119, 240);
            $this->Line(139, 230, 139, 240);
            $this->Line(177, 230, 177, 240);

            $this->Line(7, 247, 203, 247);
            $this->Line(7, 259, 203, 259);
            $this->Line(7, 277, 203, 277);
            $this->Line(55, 277, 55, 288);
            $this->Line(95, 277, 95, 288);
            $this->Line(148, 277, 148, 288);

            $this->SetFont('times', '', 8);
            $this->Text(9, 231, 'Insc.');
            $this->Text(19, 231, 'Aus.');
            $this->Text(28, 231, 'Exam.');
            $this->Text(40, 231, 'Sobres. (10)');
            $this->Text(60, 231, 'Distinguido (9)');
            $this->Text(80, 231, 'Muy Bueno (8)');
            $this->Text(102, 231, 'Bueno (7)');
            $this->Text(120, 231, 'Aprobado (6)');
            $this->Text(144, 231, 'Insuficiente (1-2-3-4-5)');
            $folio = $k + 1;
            $totalPresentes = $totalPresentes + $i - 1;
            if ($folio != $datos['ENCABEZADO']['FOLIO']) {
                $this->Text(182, 231, 'Total Pracial');
            } else {
                $this->Text(182, 231, 'Total Final');
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
                $this->Text(195, 235, $i - 1);
            } else {
                $this->Text(186, 235, $totalPresentes);
            }
            $this->SetFont('times', 'B', 10);
            $this->Text(8, 243, 'Condición de Regularidad: ');
            $this->Text(8, 248, 'Observaciones');
            $this->Text(8, 259, 'Profesores que componen el tribunal(Firma y Aclaración)');
            //$subCadena=substr($resCab->_array[0][19],0,85);
            $this->MultiCell(175, 5, utf8_encode($datos['ENCABEZADO']['DOCENTES']), 0, 'L', false, 1, 8, 269, true, 0, false, true, 0, 'T', false);
            $this->SetFont('times', '', 10);
            $this->MultiCell(185, 2, utf8_encode($datos['ENCABEZADO']['OBS'])."\n", 1, 'J', 1, 1, 8 ,251, true);
            $this->SetFont('times', 'B', 10);
            $this->Text(8, 278, 'Confeccionó');
            $this->Text(8, 282, utf8_encode($usuario));
            $this->Text(8, 282, '');
            $this->Text(56, 278, 'Firma');
            $this->Text(96, 278, 'Jefe Alumnado');
            $this->Text(149, 278, 'Computadora');

            $this->SetFont('times', '', 9);
            $this->Text(8, 288, date('d-m-Y H:i:s'));
            $anio = explode('/', $datos['ENCABEZADO']['APERTURA']);
            $this->Text(96, 288, $datos['ENCABEZADO']['ACTA']);
            $this->Text(165, 288, 'Folio: ' . $folio);

            $this->SetFont('times', '', 9);
            $this->Text(50, 243, '(PP) Por Promoción; (R)Regular; (L)Libre');
            //$this->Line(7,264,203,264);
            //$this->Line(148,235,148,245);

            /*
              $this->Line(7,233,203,233);
              $this->Line(53,161,53,233);
              $this->Line(63,161,63,233);
              $this->Line(91,161,91,233);
              $this->Line(119,161,119,233);
              $this->Line(147,161,147,233);

              $this->Line(175,161,175,233);

              $this->Line(7,167,203,167);
             */
        }
        // print_r($totalPresentes);die;
        $pdf = "acta_Nro_" . $datos['ENCABEZADO']['ACTA'] . "pdf";
        $this->Output("$pdf", 'I');
        return $pdf;
    }

}

?>
