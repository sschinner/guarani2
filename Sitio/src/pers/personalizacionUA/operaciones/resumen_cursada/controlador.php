<?php

namespace personalizacionUA\operaciones\resumen_cursada;

use kernel\kernel;
use siu\guarani;
use siu\extension_kernel\controlador_g3w2;
use siu\modelo\datos\catalogo;
use kernel\util\validador;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;

class controlador extends \siu\operaciones\resumen_cursada\controlador{
    
    function accion__exportar_pdf() {
        
        $comision_hash = $this->validate_param(0, 'get', validador::TIPO_ALPHANUM);
        $anio_academico_hash = $this->validate_param(1, 'get', validador::TIPO_ALPHANUM);
        $periodo_hash = $this->validate_param(2, 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
        
        $encabezado = $this->get_comision($anio_academico_hash, $periodo_hash, $comision_hash);

        $parciales = array();
        $tabla = array();
        $resultados_acta_cursada = array();

        if (!empty($encabezado['COMISION'])) {
            $parciales = $this->get_parciales($encabezado);
            $parciales_alumnos = $this->get_parciales_alumnos($encabezado);
            $alumnos_inscriptos_comision = $this->get_alumnos_inscriptos_comision($encabezado);
            $resultados_acta_cursada = $this->get_resultados_acta_cursada($encabezado);
            $tabla = $this->generar_resumen_cursada($parciales, $parciales_alumnos, $alumnos_inscriptos_comision, $resultados_acta_cursada);
            $universidad = guarani::ua()->get_nombre_institucion() . "\n" . guarani::ua()->get_nombre() . "\n";

            $pdf = new generador_pdf($this->crear_ezpdf());
            $pdf->set_font($this->pdf_fuente);
            $pdf->set_text_options(array('left' => 5, 'top' => 20, 'maxWidth' => 800, 'width' => 800));
            $pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
            $pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
            $pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
            $pdf->set_tiene_encabezado($this->tiene_encabezado);

            $datos_encabezado = array(
                'cant_columnas' => 2,
                'datos' => array(
                    0 => '<b>' . ucfirst(kernel::traductor()->trans("resumen_cursada.comision.encabezado.materia")) . ':</b> ' . $encabezado['MATERIA_NOMBRE'],
                    1 => '<b>' . ucfirst(kernel::traductor()->trans("resumen_cursada.comision.encabezado.comision")) . ':</b> ' . $encabezado['COMISION_NOMBRE'],
                    2 => '<b>' . ucfirst(kernel::traductor()->trans("resumen_cursada.comision.encabezado.anio_acad")) . ':</b> ' . $encabezado['ANIO_ACADEMICO'],
                    3 => '<b>' . ucfirst(kernel::traductor()->trans("resumen_cursada.comision.encabezado.periodo")) . ':</b> ' . $encabezado['PERIODO_LECTIVO']
                )
            );

            $pdf->set_encabezado_tabla($datos_encabezado);

            $this->pdf_encabezado = array($universidad, "<u><b>" . kernel::traductor()->trans("tit_resumen_cursada") . "</b></u>", 110);
            $pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);

            $logo = kernel::localizador()->encontrar_img('www/img', 'logo.png');
            $pdf->set_encabezado_img($logo['path'], '100');
            
            $titulos_options = array();
            //if (!empty($parciales)) { SE COMENTA PARA QUE APAREZCA EL LISTADO POR MAS DE QUE NO HALLA PARCIALES
                list($titulos, $titulos_options) = $this->generar_titulos_reporte($parciales, $resultados_acta_cursada, true);
                $data_tabla = $this->generar_tabla_reporte($tabla, $resultados_acta_cursada);
            //}
            $pdf->set_options(array('showHeadings' => 1, 'protectRows' => 1, 'maxWidth' => 800, 'width' => 800, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8, 0.8, 0.8), 'cols' => $titulos_options));
            $pdf->agregar_tabla($data_tabla, $titulos, '');
            $pdf->generar();
        }
    }
    
    
    protected function generar_titulos_reporte($parciales, $resultados_acta_cursada, $tipo_pdf = false){
        
        $titulos = array('ALUMNO' => strtoupper(kernel::traductor()->trans("resumen_cursada.comision.encabezado.alumno")),
                         'LEGAJO' => strtoupper(kernel::traductor()->trans("resumen_cursada.comision.encabezado.legajo")));
        $titulos_options = array();
        
        if ($tipo_pdf){
            
            $titulos_options['ALUMNO'] = array('width'=>200);
            $titulos_options['LEGAJO'] = array('width'=>100);
        }
        foreach ($parciales as $parcial) {
            $titulos[$parcial['FECHA_IDEVALUACION']] = $parcial['EVALUACION_DESC']." ".$parcial['SFECHA_PARCIAL'];
            if ($tipo_pdf){
                $titulos_options[$parcial['EVALUACION']] = array('width'=>160);
            }    
        }   
        if (!empty($resultados_acta_cursada)) {
            $titulos ['ACTA'] = strtoupper(kernel::traductor()->trans("resumen_cursada.comision.encabezado.acta_cursadas"))." Nro ".$resultados_acta_cursada['ACTA'];
            if ($tipo_pdf){
                $titulos_options['ACTA'] = array('width'=>160);
            }   
        }
        klog2('Titulos de tabla reporte:', $titulos);
        return array($titulos, $titulos_options);
    }
}

