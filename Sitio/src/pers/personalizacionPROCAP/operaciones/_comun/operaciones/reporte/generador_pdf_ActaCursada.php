<?php

namespace personalizacionPROCAP\operaciones\_comun\operaciones\reporte;

set_include_path('.:'.substr_replace(dirname(__FILE__),'lib/',-38));
require_once('tcpdf/config/tcpdf_config.php');
//require("tcpdf/config/lang/spa.php");	
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

    function imprimir($datos) {

//        print_r($datos['CUERPO'][1][0]['RESULTADO']);
//        die;
        $totalPresentes = 0;
        for ($k = 0; $k < $datos['ENCABEZADO']['FOLIOS']; $k++) {

            //$this->TCPDF('P', 'mm', 'A4', true, 'UTF-8', false);
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

            $this->SetFont('times', 'B', 11);
            $this->SetY(9);
            $this->SetX(90);

            $this->Cell(80, 4, 'ACTA DE REGULARES', 0, 0, 'L', false, '', 0, false, 'T', 'C');
            $this->SetFont('times', 'B', 10);
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
            $this->SetFont('times', '', 10);
            $this->Text(42, 15, utf8_encode($datos['ENCABEZADO']['NUA']));
            $this->Text(42, 21, utf8_encode($datos['ENCABEZADO']['NCARRERA']));
            //$this->Text(180,21,$resAlu->_array[0][11]);
            $this->Text(28, 26, utf8_encode($datos['ENCABEZADO']['MATERIA']));
            // $this->Text(40, 26, $resCab->_array[0][7]);
            $this->Text(150, 26, $datos['ENCABEZADO']['COMISION']);
            $this->Text(135, 31, $datos['ENCABEZADO']['FINICIO']);
            $this->Text(167, 31,$datos['ENCABEZADO']['FFIN']);
            $this->Text(35, 31, $datos['ENCABEZADO']['ANIO_ACAD']);
            $this->Text(77, 31, utf8_encode($datos['ENCABEZADO']['PER_LEC']));
            //$this->Text(177,26,$resCab->_array[0][10]);
            //$this->Text(28,31,$resCab->_array[0][3]."   ". utf8_encode($resCab->_array[0][4]));

            /* $this->SetFont('times','B',14);
              $this->Text(170,9,'ES COPIA'); */

            $this->Line(7, 36, 203, 36);

            $this->SetLineWidth(0.2);
            /* $this->Line(15,36,15,42);
              $this->Line(45,36,45,42);
              $this->Line(95,36,95,42);
              $this->Line(123,36,123,42);
              $this->Line(146,36,146,42);
              $this->Line(158,36,158,42); */
            if ($datos['CUERPO'][1][0]['RESULTADO'] != 'Sin resultado') {
                $this->SetFont('times', 'B', 9);
                $this->Text(7, 38, 'Nro.');
                $this->Text(24, 38, 'Legajo');
                $this->Text(50, 38, 'Apellido y Nombre(s)');
                $this->Text(115, 38, 'Fecha de Regularidad');
                $this->Text(153, 38, 'Nota');
                $this->Text(174, 38, 'Resultado');
            } else {
                $this->SetFont('times', 'B', 9);
                $this->Text(7, 38, 'Nro.');
                $this->Text(24, 38, 'Legajo');
                $this->Text(50, 38, 'Apellido y Nombre(s)');
                $this->Text(115, 38, 'Cond. Reg.');
                $this->Text(135, 38, 'Nota');
                $this->Text(155, 38, 'Descripción');
                $this->Text(180, 38, 'Resultado');
            }

            /* $this->Text(155,38,'Descripción');	
              $this->Text(180,38,'Resultado'); */


            $cantidad = $cant;
            $y = 42;
            $i = 1;
            $cantAus = $cantApr = $cantDis = $cantBue = $cantIns = $cantMuy = $cantSob = 0;
            $this->SetFont('times', '', 9);

            foreach ($datos['CUERPO'][$k + 1] as $fila) {

                $this->Line(7, $y, 203, $y);
                /* $this->Line(15,$y,15,$y+8);
                  $this->Line(45,$y,45,$y+8);
                  $this->Line(95,$y,95,$y+8);
                  $this->Line(123,$y,123,$y+8);
                  $this->Line(146,$y,146,$y+8);
                  $this->Line(158,$y,158,$y+8); */

                $this->Text(7 + 2, $y + 1, $i);
                $this->Text(22, $y + 1, $fila['LEGAJO']);
                $this->Text(50, $y + 1, utf8_encode($fila['APE_NOM']));
                if ($datos['CUERPO'][1][0]['RESULTADO'] != 'Sin resultado') {
                    $this->Text(120, $y + 1, $fila['FECHA']);
                    $this->Text(155, $y + 1, $fila['NOTA_NUM']);
                    $this->Text(175, $y + 1, $fila['CONDICION']);
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
            $this->SetFont('times', '', 8);

            $this->Line(7, 235, 203, 235);
            /* $this->Line(17,225,17,235);
              $this->Line(27,225,27,235);
              $this->Line(37,225,37,235);
              $this->Line(59,225,59,235);
              $this->Line(79,225,79,235);
              $this->Line(99,225,99,235);
              $this->Line(119,225,119,235);
              $this->Line(139,225,139,235);
              $this->Line(177,225,177,235);
             */
            $this->Line(7, 242, 203, 242);
            $this->Line(7, 254, 203, 254);
            $this->Line(7, 272, 203, 272);
            $this->Line(55, 272, 55, 283);
            $this->Line(95, 272, 95, 283);
            $this->Line(148, 272, 148, 283);
            /*
              $this->SetFont('times','',8);
              $this->Text(9,226,'Insc.');
              $this->Text(19,226,'Aus.');
              $this->Text(28,226,'Exam.');
              $this->Text(40,226,'Sobres. (10)');
              $this->Text(60,226,'Distinguido (9)');
              $this->Text(80,226,'Muy Bueno (8)');
              $this->Text(102,226,'Bueno (7)');
              $this->Text(120,226,'Aprobado (6)');
              $this->Text(144,226,'Insuficiente (1-2-3-4-5)');
              if($resAlu->_array[0][5]!=$resCab->_array[0][16]){
              $this->Text(182,226,'Total Pracial');
              }else{
              $this->Text(182,226,'Total Final');
              }


              $this->Text(10,230,$i-1);
              if($parametros["folio"]>1){
              $this->Text(195,230,$i-1);
              }else{
              $this->Text(189,230,($i-1)+(22*($parametros["folio"]-1)));
              }
             */

            $this->SetFont('times', 'B', 10);
            $this->Text(8, 231, 'Escala de Notas: ');
            $this->Text(8, 238, 'Condición de Regularidad: ');
            $this->Text(8, 243, 'Observaciones');
            $this->Text(8, 254, 'Docentes (Firma y Aclaración)');
            /* $subCadena=substr($resCab->_array[0][19],0,85);
              $this->MultiCell(175,5,$subCadena,0,'L',false,1,8,264,true,0,false,true,0,'T',false); */
            $this->Text(8, 273, 'Confeccionó');
            $this->SetFont('times', 'B', 8);
            $this->Text(8, 277, '');
            $this->Text(56, 273, 'Firma');
            $this->Text(96, 273, 'Jefe Alumnado');
            $this->Text(149, 273, 'Computadora');
            $this->SetFont('times', '', 9);
            $this->MultiCell(175, 5, $datos['ENCABEZADO']['DOCENTES'], 0, 'L', false, 1, 8, 260, true, 0, false, true, 0, 'T', false);
            //$this->Text(8,260,$rsDocentes->_array[0][0]);
            $this->Text(50, 238, '(P)Promoción; (R)Regular; (L)Libre; (A)Abandonó; (R)Cond. Pend.');
            $escalaNotas = "";
            /* foreach ($rsEscala->_array as $fila) {
              $escalaNotas .=$fila[0] . ", ";
              } */
            $folio = $k + 1;
            $this->SetFont('times', '', 9);
            $this->Text(8, 288, date('d-m-Y H:i:s'));
            $anio = explode('/', $datos['ENCABEZADO']['APERTURA']);
            $this->Text(96, 288, 'Acta: '.$datos['ENCABEZADO']['ACTA']);
            $this->Text(165, 288, 'Folio: ' . $folio);
        }
        // $this->Text(35,231,'(10)Sobresaliente; (9)Distinguido; (8)M. Bueno; (7)Bueno; (6)Aprobado; (5,4,3,2 y 1)Insuf.');						
        $this->Text(35, 231, substr($escalaNotas, 0, -2));
        $pdf = "acta_cursado_nro_" . $datos['ENCABEZADO']['ACTA'] . ".pdf";
        $this->Output("$pdf", 'I');
        return $pdf;
    }

}

?>