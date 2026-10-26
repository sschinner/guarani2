<?php
namespace siu\operaciones\resumen_cursada;

use kernel\kernel;
use siu\guarani;
use siu\extension_kernel\controlador_g3w2;
use siu\modelo\datos\catalogo;
use kernel\util\validador;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;

class controlador extends controlador_g3w2 
{

    protected $datos_filtro = array('anio_academico' => "", 'periodo' => "");
    protected $pdf_hoja = "A4";
    protected $pdf_encabezado = array("", "");
    protected $pdf_encabezado_img = array("img" => "", "width" => "");
    protected $pdf_fuente = "Courier.afm";
    protected $pdf_fuente_texto = 8;
    protected $pdf_fuente_titulo = 10;
    protected $pdf_fuente_subtitulo = 12;
    protected $tiene_encabezado = true;
    protected $encabezado_reporte = "";

    /**
     * @return \siu\modelo\transacciones\inscripcion_cursada
     */
    function modelo() {
        return guarani::cursada();
    }

    function get_clase_vista() {
        switch ($this->accion) {
            case 'comision':
                return 'vista_comision';
            default:
                return 'vista';
        }
    }

    function accion__index() {
        if (!empty($_GET['formulario_filtro'])) {
            $this->datos_filtro = $_GET['formulario_filtro'];
        }
    }
    
    function accion__comision() {
        
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
            
            if (!empty($resultados_acta_cursada)) {
                $this->vista()->pagelet("contenido")->data['ESTADO_ACTA'] = $resultados_acta_cursada['ESTADO'];
                $this->vista()->pagelet("contenido")->data['ACTA'] = $resultados_acta_cursada['ACTA'];
            }
            
            $tabla = $this->generar_resumen_cursada($parciales, $parciales_alumnos, $alumnos_inscriptos_comision, $resultados_acta_cursada);
            
            if(!empty($tabla)){
                $url_pdf = kernel::vinculador()->crear(kernel::ruteador()->get_id_operacion(), 'exportar_pdf', array($comision_hash, $anio_academico_hash, $periodo_hash));
                $url_xls = kernel::vinculador()->crear(kernel::ruteador()->get_id_operacion(), 'exportar_excel', array($comision_hash, $anio_academico_hash, $periodo_hash));
                $this->vista()->pagelet("contenido")->data['url_pdf'] = $url_pdf;
                $this->vista()->pagelet("contenido")->data['url_xls'] = $url_xls;
            }
            
            //Logs de la info a mostrar en la tabla del resume de cursada
            klog2('Evaluaciones de la comision:', $parciales);
            klog2('Actas de la comision:', $resultados_acta_cursada);
            klog2('Alumnos, evaluaciones y actas:', $tabla);
        }
        
        $this->vista()->pagelet("contenido")->data['encabezado'] = $encabezado;
        $this->vista()->pagelet("contenido")->data['parciales'] = $parciales;
        $this->vista()->pagelet("contenido")->data['tabla'] = $tabla;
        $this->vista()->pagelet("contenido")->data['tiene_actas'] = !empty($resultados_acta_cursada);
    }

    protected function get_parciales($encabezado){
        return catalogo::consultar('comisiones', 'get_parciales', array('comision' => $encabezado['COMISION'], 'visible_al_alumno' => "N"));
    }
    
    protected function get_parciales_alumnos($encabezado){
        return catalogo::consultar('comisiones', 'get_parciales_alumnos', array('comision' => $encabezado['COMISION'], 'visible_al_alumno' => "N"));
    }
    
    protected function get_alumnos_inscriptos_comision($encabezado){
        return catalogo::consultar('docente', 'alum_inscriptos_comision', array('comision' => $encabezado['COMISION']));
    }
    
    protected function get_resultados_acta_cursada($encabezado){
        return catalogo::consultar('comisiones', 'get_resultados_acta_cursada', array('comision' => $encabezado['COMISION']));
    }
    
    protected function get_alumnos_de_parciales_insc_acta($encabezado){
        return catalogo::consultar('comisiones', 'get_alumnos_de_parciales_insc_acta', array('comision' => $encabezado['COMISION']));
    }

    //Genera el Join entre evaluacion y las evaluaciones de los alumnos, de no haber eval para el alumno completa con campos vacios
    protected function generar_resumen_cursada($parciales, $parciales_alu, $alumnos, $acta_cursada) {
        $tabla = array();
        
        foreach ($alumnos as $key => $alumno) {
            $tabla[$alumno['LEGAJO']]['ALUMNO'] = $alumno['ALUMNO'];
            $tabla[$alumno['LEGAJO']]['LEGAJO'] = $alumno['LEGAJO'];
        }
        // Carga los parciales si encuentra al alumno.
        foreach ($parciales_alu as $key => $parcial_alu) {
            if (array_key_exists($parcial_alu['LEGAJO'], $tabla)) {
                $tabla[$parcial_alu['LEGAJO']]['PARCIALES'][$parcial_alu['FECHA_IDEVALUACION']]['NOTA'] = $parcial_alu['NOTA'];
            }
        }
        
        //Comienzo a procesar la tabla para completar las evaluaciones que estan vacias en cada alumno, esto evita romper la tabla al momento de mostrar las notas
        foreach ($tabla as $key_legajo => $parciales_alu) {
            
            //Diferencia entra comparacion de array con las evaluaciones de la comision vs las evaluaciones del alumno
            $array_column = array_map(function($element){return $element['FECHA_IDEVALUACION'];}, $parciales);
            $aux_diff = array_diff($array_column, (isset($parciales_alu['PARCIALES']) ? array_keys($parciales_alu['PARCIALES']) : array()));
            
            while (!empty($aux_diff)) {
                $i = array_shift($aux_diff);
                $tabla[$key_legajo]['PARCIALES'][$i]['NOTA'] = '';
            }
            
            //Si hay parciales del alumno los ordeno por fecha de parcial
            if (!empty($tabla[$key_legajo]['PARCIALES']))
                ksort($tabla[$key_legajo]['PARCIALES'], SORT_NATURAL);
            
        }
        
        // Acta
        if (!empty($acta_cursada)) {
            foreach ($acta_cursada['FILAS'] as $key => $acta) {
                $tabla[$acta['LEGAJO']]['ACTA']['COND_REG'] = $acta['COND_REG'];
                $tabla[$acta['LEGAJO']]['ACTA']['NOTA'] = $acta['NOTA'];
                $tabla[$acta['LEGAJO']]['ACTA']['RESULTADO'] = $acta['RESULTADO'];
            }
            
            // Agrego con campos vacios en los casos donde no se haya cargado ningun acta al alumno
            foreach ($tabla as $key_legajo => $alumno) {
                if (!isset($alumno['ACTA'])) {
                    $tabla[$key_legajo]['ACTA']['COND_REG'] = '';
                    $tabla[$key_legajo]['ACTA']['NOTA'] = '';
                    $tabla[$key_legajo]['ACTA']['RESULTADO'] = '';
                }
            }
        }
        klog2('El resumen de la cursada procesada fue: ', $tabla);
        return $tabla;
    }

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
            list($titulos, $titulos_options) = $this->generar_titulos_reporte($parciales, $resultados_acta_cursada, true);
            $data_tabla = $this->generar_tabla_reporte($tabla, $resultados_acta_cursada);

            $pdf->set_options(array('showHeadings' => 1, 'protectRows' => 1, 'maxWidth' => 800, 'width' => 800, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8, 0.8, 0.8), 'cols' => $titulos_options));
            $pdf->agregar_tabla($data_tabla, $titulos, '');
            $pdf->generar();
        }
    }

    function accion__exportar_excel() {
        
        $comision_hash = $this->validate_param(0, 'get', validador::TIPO_ALPHANUM);
        $anio_academico_hash = $this->validate_param(1, 'get', validador::TIPO_ALPHANUM);
        $periodo_hash = $this->validate_param(2, 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
        
        $encabezado = $this->get_comision($anio_academico_hash, $periodo_hash, $comision_hash);
        $parciales = $this->get_parciales($encabezado);
        $parciales_alumnos = $this->get_parciales_alumnos($encabezado);
        $alumnos_inscriptos_comision = $this->get_alumnos_inscriptos_comision($encabezado);
        $resultados_acta_cursada = $this->get_resultados_acta_cursada($encabezado);
        $tabla = $this->generar_resumen_cursada($parciales, $parciales_alumnos, $alumnos_inscriptos_comision, $resultados_acta_cursada);

        $xls = new generador_excel();

        $xls->agregar_texto_sin_enter(guarani::ua()->get_nombre_institucion(), 1);
        $xls->agregar_texto(guarani::ua()->get_nombre(), 1);

        $estilo_titulo = array(
            'font' => array('bold' => true),
        );
        $xls->agregar_texto_estilos(kernel::traductor()->trans("tit_resumen_cursada"), 1, $estilo_titulo);

        $xls->agregar_texto_sin_enter(ucfirst(kernel::traductor()->trans("resumen_cursada.comision.encabezado.materia")) . ': ' . $encabezado['MATERIA_NOMBRE'], 1);
        $xls->agregar_texto_sin_enter(ucfirst(kernel::traductor()->trans("resumen_cursada.comision.encabezado.comision")) . ': ' . $encabezado['COMISION_NOMBRE'], 1);
        $xls->agregar_texto_sin_enter(ucfirst(kernel::traductor()->trans("resumen_cursada.comision.encabezado.anio_acad")) . ': ' . $encabezado['ANIO_ACADEMICO'], 1);
        $xls->agregar_texto_sin_enter(ucfirst(kernel::traductor()->trans("resumen_cursada.comision.encabezado.periodo")) . ': ' . $encabezado['PERIODO_LECTIVO'], 1);

        list($titulos, ) = $this->generar_titulos_reporte($parciales, $resultados_acta_cursada);
        $data_tabla = $this->generar_tabla_reporte($tabla, $resultados_acta_cursada);

        $xls->agregar_tabla($data_tabla, $titulos);
        $xls->set_nombre_archivo('Resumen Cursada');
        $xls->generar();
    }
    
    protected function generar_titulos_reporte($parciales, $resultados_acta_cursada, $tipo_pdf = false){
        
        $titulos = array('ALUMNO' => strtoupper(kernel::traductor()->trans("resumen_cursada.comision.encabezado.alumno")),
                         'LEGAJO' => strtoupper(kernel::traductor()->trans("resumen_cursada.comision.encabezado.legajo")));
        $titulos_options = array();
        
        if ($tipo_pdf){
            
            $titulos_options['ALUMNO'] = array('width'=>110);
            $titulos_options['LEGAJO'] = array('width'=>40);
        }
        foreach ($parciales as $parcial) {
            $titulos[$parcial['FECHA_IDEVALUACION']] = $parcial['EVALUACION_DESC']." ".$parcial['SFECHA_PARCIAL'];
            if ($tipo_pdf){
                $titulos_options[$parcial['EVALUACION']] = array('width'=>80);
            }    
        }   
        if (!empty($resultados_acta_cursada)) {
            $titulos ['ACTA'] = strtoupper(kernel::traductor()->trans("resumen_cursada.comision.encabezado.acta_cursadas"))." Nro ".$resultados_acta_cursada['ACTA'];
            if ($tipo_pdf){
                $titulos_options['ACTA'] = array('width'=>90);
            }   
        }
        klog2('Titulos de tabla reporte:', $titulos);
        return array($titulos, $titulos_options);
    }
    
    protected function generar_tabla_reporte($tabla, $resultados_acta_cursada) {
        
        $data_tabla = array();
        foreach ($tabla as $alumno) {
            
            $data_alumno = array(
                'ALUMNO' => $alumno['ALUMNO'],
                'LEGAJO' => $alumno['LEGAJO'],
            );

            if (!empty($alumno['PARCIALES']))
            {
                foreach ($alumno['PARCIALES'] as $key => $parciales)
                {
                    $data_alumno[$key] = $parciales['NOTA'];
                }
            }
            
            if (!empty($resultados_acta_cursada)) {
                $data_alumno['ACTA'] = $alumno['ACTA']['COND_REG'].' '.$alumno['ACTA']['NOTA'].' '.$alumno['ACTA']['RESULTADO'];
            }
            $data_tabla[] = $data_alumno;
        }
        klog2('Contenido tabla reporte:', $data_tabla);
        return $data_tabla;
    }

    protected function crear_ezpdf() {
        require_once "ezpdf/class.ezpdf.php";
        $instancia = new \Cezpdf($this->pdf_hoja, 'landscape');
        return $instancia;
    }

    function accion__buscar_periodos() {
        $anio_academico_hash = $this->validate_param('anio_academico', 'get', validador::TIPO_TEXTO);
        $anio_academico = $this->decodificar_anio_academico($anio_academico_hash);
        $datos = array();
        if (!is_null($anio_academico)) {
            $datos = catalogo::consultar('unidad_academica', 'buscar_periodos_lectivos', array('anio' => $anio_academico));
        }
        $this->render_raw_json($datos);
    }

    function get_comision($anio_academico_hash = null, $periodo_hash = null, $comision_hash = null) {
        $comision_actual = null;

        $comisiones = $this->get_comisiones($anio_academico_hash, $periodo_hash);
        foreach ($comisiones as $comision) {
            if ($comision['__ID__'] == $comision_hash) {
                $comision_actual = $comision;
            }
        }
        return $comision_actual;
    }

    function get_comisiones($anio_academico_hash, $periodo_hash = null) {
        $periodo = null;
        $anio_academico = null;
        $operacion = kernel::ruteador()->get_id_operacion();
        if (!empty($anio_academico_hash)) {
            $anio_academico = $this->decodificar_anio_academico($anio_academico_hash);
            if (!empty($anio_academico)) {
                if (!empty($periodo_hash)) {
                    $periodo = $this->decodificar_periodo($periodo_hash, $anio_academico);
                }
                $parametros = array(
                    'nro_inscripcion' => kernel::persona()->get_nro_inscripcion(),
                    'anio_academico' => $anio_academico,
                    'periodo' => $periodo
                );
                $comisiones = catalogo::consultar('comisiones', 'lista_comisiones_docente', $parametros);

                foreach ($comisiones as $key => $comision) {
                    $comisiones[$key]['LINK'] = kernel::vinculador()->crear($operacion, 'comision', array($comision['__ID__'], $anio_academico_hash, $periodo_hash));
                }
                return $comisiones;
            }
        }
        return false;
    }

    function get_periodo() {
        return $this->datos_filtro['periodo'];
    }

    function get_anio_academico() {
        return $this->datos_filtro['anio_academico'];
    }

    /**
     * @return guarani_form
     */
    function get_form() {
        return $this->get_form_builder()->get_formulario();
    }

    function get_vista_form() {
        return $this->get_form_builder()->get_vista();
    }

    /**
     * @return builder_form_filtro
     */
    function get_form_builder() {
        if (!isset($this->form_builder)) {
            $this->form_builder = kernel::localizador()->instanciar('operaciones\resumen_cursada\filtro\builder_form_filtro');
        }

        return $this->form_builder;
    }

    function decodificar_anio_academico($anio_hash) {
        $datos = catalogo::consultar('unidad_academica', 'anios_academicos_todos');
        if (!empty($datos)) {
            foreach ($datos as $value) {
                if ($value['_ID_'] == $anio_hash) {
                    return $value['ANIO_ACADEMICO'];
                }
            }
        }
        return false;
    }

    function decodificar_periodo($periodo_hash = null, $anio_academico = null) {
        if (!is_null($anio_academico)) {
            $periodos = catalogo::consultar('unidad_academica', 'buscar_periodos_lectivos', array('anio' => $anio_academico));
            if (!is_null($periodos)) {
                foreach ($periodos as $value) {
                    if ($value['ID'] == $periodo_hash) {
                        return $value['PERIODO_LECTIVO'];
                    }
                }
            }
        }
        return false;
    }
}
?>