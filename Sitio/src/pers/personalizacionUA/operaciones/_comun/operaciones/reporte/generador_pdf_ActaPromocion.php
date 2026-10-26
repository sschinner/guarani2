<?php

namespace personalizacionUA\operaciones\_comun\operaciones\reporte;

set_include_path('.:' . substr_replace(dirname(__FILE__), 'lib/', -38));
require_once('tcpdf/config/tcpdf_config.php');
//require("tcpdf/config/lang/spa.php");	
require_once("tcpdf/tcpdf.php");
ini_set('display_errors', 0);

use kernel\kernel;
use \siu\guarani;
use \kernel\util\u;

class generador_pdf_ActaPromocion extends \TCPDF {

    function generador_pdf_ActaPromocion() {
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

    function imprimir($datos, $nombreLogueado) {

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

            $this->Cell(80, 4, 'ACTA  DE  PROMOCIÓN', 0, 0, 'L', false, '', 0, false, 'T', 'C');
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
            $this->Text(42, 15, utf8_encode($datos['ENCABEZADO']['NOMBRE_UA']));
            $this->Text(42, 21, utf8_encode(substr($datos['ENCABEZADO']['NOMBRE_CAR'], 0, 45)));

            $this->Text(28, 26, utf8_encode(substr($datos['ENCABEZADO']['MATERIA'], 0, 45)));

            $this->Text(150, 26, utf8_encode(substr($datos['ENCABEZADO']['COMISION'],0,23)));
            $this->Text(135, 31, $datos['ENCABEZADO']['FECHA_INICIO']);
            $this->Text(167, 31, $datos['ENCABEZADO']['FECHA_FIN']);
            $this->Text(36, 31, $datos['ENCABEZADO']['ANIO_ACAD']);
            $this->Text(78, 31, utf8_encode(substr($datos['ENCABEZADO']['PER_LEC'],0,23)));


            $this->Line(7, 36, 203, 36);

            $this->SetLineWidth(0.2);
            $this->Line(15, 36, 15, 42);
            $this->Line(43, 36, 43, 42);
            $this->Line(99, 36, 99, 42);
            $this->Line(123, 36, 123, 42);
            $this->Line(158, 36, 158, 42);

            $this->SetFont('Helvetica', 'B', 10);
            $this->Text(7, 38, 'Nro.');
            $this->Text(24, 38, 'Legajo');
            $this->Text(45, 38, 'Apellido y Nombre(s)');
            $this->Text(100, 38, 'Documento');
            $this->Text(125, 38, 'Fecha Promoción');

            $this->Text(161, 38, 'Calificación (Concepto)');

            $y = 42;

            $i = 1;
            $noProm = $cantApr = $cantDis = $cantBue = $prom = $cantMuy = $cantSob = 0;
            $this->SetFont('Helvetica', '', 9);

            foreach ($datos['CUERPO'][$k + 1] as $fila) {

                if ($fila['CONDICION_INSC'] == 'S') {

                    $this->Line(7, $y, 203, $y);
                    $this->Line(15, $y, 15, $y + 6); //debe ser y + 7 cambiar para el proximo cuat.
                    $this->Line(43, $y, 43, $y + 6); //debe ser y + 7 cambiar para el proximo cuat.
                    $this->Line(99, $y, 99, $y + 6); //debe ser y + 7 cambiar para el proximo cuat.
                    $this->Line(123, $y, 123, $y + 6); //debe ser y + 7 cambiar para el proximo cuat.

                    $this->Line(158, $y, 158, $y + 6); //debe ser y + 7 cambiar para el proximo cuat.

                    $this->Text(7 + 2, $y + 2, $i); //debe ser y + 3 cambiar para el proximo cuat.
                    $this->Text(18 + 2, $y + 2, $fila['LEGAJO']); //debe ser y + 3 cambiar para el proximo cuat.

                    if (strlen($fila['APE_NOM']) > 25) {
                        $cortaNombre = explode(" ", $fila['APE_NOM']);
                        if (count($cortaNombre) > 2) {
                            $armaNombre = $cortaNombre[0] . " " . $cortaNombre[1] . " " . $cortaNombre[2];
                            if (strlen($armaNombre) > 25)
                                $armaNombre = $cortaNombre[0] . " " . $cortaNombre[1];
                        }else {
                            $armaNombre = $cortaNombre[0] . " " . $cortaNombre[1];
                        }
                    } else {
                        $armaNombre = $fila['APE_NOM'];
                    }
                    $this->Text(43 + 2, $y + 2, substr(utf8_encode($armaNombre), 0, 35)); //debe ser y + 3 cambiar para el proximo cuat.
                    $this->Text(99 + 2, $y + 2, $fila['NRO_DOCUMENTO']); //debe ser y + 3 cambiar para el proximo cuat.
                    // if ($fila['RESULTADO'] != "Sin resultado")
                    $this->Text(130 + 2, $y + 2, $fila['FECHA']); //debe ser y + 3 cambiar para el proximo cuat.

                    $this->Text(146 + 2, $y + 2, $condicion); //debe ser y + 3 cambiar para el proximo cuat.

                    if (utf8_encode($fila['RESULTADO']) != 'Promovido') {
                        $this->Text(158 + 2, $y + 2, " No Promovido "); //debe ser y + 3 cambiar para el proximo cuat.
                        $noProm++;
                    } else {
                        $this->Text(158 + 2, $y + 2, ($fila['NOTA_NUM'] != '' ? $fila['NOTA_NUM'] : "") . " " . utf8_encode(($fila['NOTA_NUM'] != '' ? $fila['NOTA_LETRAS'] : '')) . " " . utf8_encode($fila['RESULTADO'])); //debe ser y + 3 cambiar para el proximo cuat.
                        $prom++;
                    }

                    if (utf8_encode($fila['RESULTADO']) == 'Promovido') {
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
                        }
                    }
                    $i++;
                    $y+=6; //debe ser y+= 7 cambiar para el proximo cuat.
                }
            }
            $this->Line(7, $y, 203, $y);
            $this->RoundedRect(7, 42, 196, $y - 42, 2, '0000', 'S', '', $blanco);


            //ULTIMO CUADRO
            $this->RoundedRect(7, 230, 196, 58, 2, '0000', 'FD', '', $blanco);
            $this->SetFont('Helvetica', '', 8);

            $this->Line(7, 240, 203, 240);
            $this->Line(17, 230, 17, 240);

            $this->Line(37, 230, 37, 240);
            $this->Line(62, 230, 62, 240);
            $this->Line(82, 230, 82, 240);
            $this->Line(103, 230, 103, 240);
            $this->Line(124, 230, 124, 240);
            $this->Line(144, 230, 144, 240);
            $this->Line(175, 230, 175, 240);

            $this->Line(7, 247, 203, 247);
            $this->Line(7, 259, 203, 259);
            $this->Line(7, 277, 203, 277);
            //$this->Line(55, 277, 55, 288);
            $this->Line(95, 277, 95, 288);
            $this->Line(148, 277, 148, 288);

            $this->SetFont('Helvetica', '', 8);
            $this->Text(9, 231, 'Insc.');
            $this->Text(19, 231, 'Promovidos');

            $this->Text(40, 231, 'No Promovidos');
            $this->Text(65, 231, 'Sobres. (10)');
            $this->Text(83, 231, 'Distinguido (9)');
            $this->Text(104, 231, 'Muy Bueno (8)');
            $this->Text(127, 231, 'Bueno (7)');
            $this->Text(149, 231, 'Aprobado (6)');
            $folio = $k + 1;
            $totalPresentes = $totalPresentes + $i - 1;
            if ($folio != $datos['ENCABEZADO']['FOLIOS']) {
                $this->Text(180, 231, 'Total Parcial');
            } else {
                $this->Text(180, 231, 'Total Final');
            }

            $this->Text(10, 235, $i - 1);

            $this->Text(25, 235, $prom);
            $this->Text(49, 235, $noProm);
            $this->Text(70, 235, $cantSob);
            $this->Text(90, 235, $cantDis);
            $this->Text(110, 235, $cantMuy);
            $this->Text(131, 235, $cantBue);
            $this->Text(157, 235, $cantApr);

            if ($folio < 2) {
                $this->Text(185, 235, $i - 1);
            } else {
                $this->Text(185, 235, $totalPresentes);
            }

            $this->SetFont('Helvetica', 'B', 10);
            $this->Text(8, 248, 'Observaciones');
            $this->Text(8, 259, 'Profesores que componen el tribunal(Firma y Aclaración)');
            $this->SetFont('Helvetica', '', 10);
            $this->MultiCell(175, 5, utf8_encode($datos['ENCABEZADO']['DOCENTES']), 0, 'L', false, 1, 8, 265, true, 0, false, true, 0, 'T', false);
            $this->Text(8, 252, $datos['ENCABEZADO']['OBS']);
            $this->SetFont('Helvetica', 'B', 10);
            $this->Text(8, 278, 'Confeccionó');
            $this->SetFont('Helvetica', '', 9);
            $this->Text(8, 282, utf8_encode($nombreLogueado));
            $this->Text(8, 282, '');
            $this->SetFont('Helvetica', 'B', 10);
            //$this->Text(56, 278, 'Firma');
            $this->Text(96, 278, 'Jefe Alumnado');
            $this->Text(149, 278, 'Computadora');

            $this->SetFont('times', '', 9);
            $this->Text(8, 288, date('d-m-Y H:i:s'));
            $anio = explode('/', $datos['ENCABEZADO']['APERTURA']);
            $this->Text(96, 288, 'Acta Promoción N°: ' . $datos['ENCABEZADO']['ACTA']);
            $this->Text(165, 288, 'Folio: ' . $folio);
            $this->SetFont('times', '', 9);
        }
        $pdf = "acta_Prom_Nro_" . $datos['ENCABEZADO']['ACTA'] . "pdf";
        $this->Output("$pdf", 'I');
        return $pdf;
    }

}

?>
