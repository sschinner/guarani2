<?php
namespace siu\operaciones\inscripciones;

use kernel\kernel;
use siu\extension_kernel\controlador_g3w2;
use kernel\util\validador;
use siu\guarani;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;
use siu\operaciones\examen\controlador as examen;

class controlador extends controlador_g3w2
{
        protected $datos_filtro = array('anio_academico' => "", 'periodo' => "");
        protected $pdf_hoja = "A4";
        protected $pdf_encabezado = array("", "");
        protected $pdf_encabezado_img = array("img" => "", "width" => "");
        protected $pdf_fuente = "Courier.afm";
        protected $pdf_fuente_texto = 10;
        protected $pdf_fuente_titulo = 10;
        protected $pdf_fuente_subtitulo = 12;
        protected $tiene_encabezado = true;
        protected $encabezado_reporte = "";
        /**
        * @return null
        */
        function modelo()
        {
                return null;
        }
	
	function accion__index()
	{
		$alcance_exa = $this->validate_param('examenes_historicos', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
		$alcance_cur = $this->validate_param('cursadas_historicas', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));		
		$this->add_var('alcance_examenes', $alcance_exa);
		$this->add_var('alcance_cursadas', $alcance_cur);
	}
	
	function accion__examenes()
	{
		$alcance_exa = $this->validate_param('examenes_historicos', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
		$this->add_var('alcance_examenes', $alcance_exa);
		
		$pagelet = $this->vista()->pagelet('examenes');
		kernel::renderer()->add($pagelet);
	}
	
	function accion__cursadas()
	{
		$alcance_cur = $this->validate_param('cursadas_historicas', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
		$this->add_var('alcance_cursadas', $alcance_cur);
		
		$pagelet = $this->vista()->pagelet('cursadas');
		kernel::renderer()->add($pagelet);
    	}
        
        function accion__generar_pdf (){
            
                $listado = $this->validate_param(0, 'get', validador::TIPO_TEXTO);
                $alcance = $this->validate_param(1, 'get', validador::TIPO_TEXTO, array('allowempty' => true));
                
                $parametros = array();
                $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
                $parametros['estado'] = "T";
                
                if ($alcance == "T") {
                        $parametros['alcance'] = "T";
                } else {
                        $parametros['alcance'] = "A";
                }
                
                $pdf = new generador_pdf($this->crear_ezpdf());
                
                if ($listado == 'cursada')
                {
                        $inscripciones_cursadas_rechazadas = catalogo::consultar('alumno', 'inscripciones_cursadas_rechazadas', $parametros);
                        $inscripciones_cursadas = catalogo::consultar('alumno', 'inscripciones_cursadas', $parametros);

                        $data_tabla = array_merge($inscripciones_cursadas_rechazadas, $inscripciones_cursadas);
                        pagelet_cursadas::ordenar_desc($data_tabla);
                        
                        $titulos = array (  'materia' => strtoupper(kernel::traductor()->trans("mis_inscripciones.materia")),
                                            'anio_acad' => strtoupper(kernel::traductor()->trans("mis_inscripciones.anio")),
                                            'per_lec' => strtoupper(kernel::traductor()->trans("mis_inscripciones.per_lec")),
                                            'sede' => strtoupper(kernel::traductor()->trans("mis_inscripciones.sede")),
                                            'fecha' => strtoupper(kernel::traductor()->trans("mis_inscripciones.fecha_inscripcion")),
                                            'comision' => strtoupper(kernel::traductor()->trans("mis_inscripciones.comision")),
                                            'turno' => strtoupper(kernel::traductor()->trans("mis_inscripciones.turno")),
                                            'catedra' => strtoupper(kernel::traductor()->trans("mis_inscripciones.catedra")),
                                            'estado' => strtoupper(kernel::traductor()->trans("mis_inscripciones.estado")),
                        );
                        
                        $pdf->set_nombre_archivo('Lista_Cursadas');
                        $titulo_tabla = "<u><b>".(kernel::traductor()->trans("mis_inscripciones.titulo_pdf_cursadas"))."</b></u>";
                        
                }elseif ($listado == 'examen') {
                       
                        $inscripciones_examen_rechazadas = catalogo::consultar('alumno', 'inscripciones_examen_rechazadas', $parametros);
                        $inscripciones_examenes = catalogo::consultar('alumno', 'inscripciones_examenes', $parametros);
                        
                        $data_tabla = array_merge($inscripciones_examen_rechazadas, $inscripciones_examenes);
                        pagelet_examenes::ordenar_desc($data_tabla);
                        
                        $titulos = array (  'materia' => strtoupper(kernel::traductor()->trans("mis_inscripciones.materia")),
                                            'anio' => strtoupper(kernel::traductor()->trans("mis_inscripciones.anio")),
                                            'turno' => strtoupper(kernel::traductor()->trans("mis_inscripciones.turno")),
                                            'MESA_EXAMEN' => strtoupper(kernel::traductor()->trans("mis_inscripciones.mesa")),
                                            'sede' => strtoupper(kernel::traductor()->trans("mis_inscripciones.sede")),
                                            'fecha_dia' => strtoupper(kernel::traductor()->trans("mis_inscripciones.fecha_examen_dia")),
                                            'fecha_hora' => strtoupper(kernel::traductor()->trans("mis_inscripciones.fecha_examen_hora")),
                                            'fecha_inscr' => strtoupper(kernel::traductor()->trans("mis_inscripciones.fecha_inscripcion")),
                                            'tipo' => strtoupper(kernel::traductor()->trans("mis_inscripciones.tipo")),
                                            'estado' => strtoupper(kernel::traductor()->trans("mis_inscripciones.estado")),
                                            'ORDEN_INSC' => strtoupper(kernel::traductor()->trans("mis_inscripciones.orden"))
                        );
                        $pdf->set_nombre_archivo('Lista_Cursadas');
                        $titulo_tabla = "<u><b>".(kernel::traductor()->trans("mis_inscripciones.titulo_pdf_examenes"))."</b></u>";
                }
                
                $pdf->set_font($this->pdf_fuente);
                $pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 500, 'width' => 800, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => array()));
                $pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 800, 'width' => 500, 'spacing' => 1.5));
                $pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
                $pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
                $pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
                $pdf->set_tiene_encabezado($this->tiene_encabezado);
                
                $encabezado = guarani::ua()->get_nombre_institucion()."\n".guarani::ua()->get_nombre()."\n";
                $logo = kernel::localizador()->encontrar_img('www/img','logo.png');
                
                $datos_encabezado = array(
                'cant_columnas' => 1,
                'datos' => array(
                    0 => '<b>'. strtoupper(kernel::traductor()->trans("resumen_cursada.comision.encabezado.alumno")).':</b> '.guarani::persona()->get_nombre(),
                    1 => '<b>'. strtoupper(kernel::traductor()->trans("resumen_cursada.comision.encabezado.legajo")).':</b> '.guarani::persona()->get_id_legajo_activo() 
                    )
                );
                
                $pdf->set_encabezado_tabla($datos_encabezado);
                
                $this->pdf_encabezado = array($encabezado, $titulo_tabla, 110);
                $this->pdf_encabezado_img = array('img'=>$logo['path'],'width' => '100');

                $pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
                $pdf->set_encabezado_img($this->pdf_encabezado_img["img"], $this->pdf_encabezado_img["width"]);
                $this->pdf_encabezado_img = array('img'=>$logo['path'],'width' => '100');
                
                $pdf->agregar_tabla($data_tabla, $titulos, '');
                $pdf->generar();
        }
        
        function accion__generar_xls(){
            
                $listado = $this->validate_param(0, 'get', validador::TIPO_TEXTO);
                $alcance = $this->validate_param(1, 'get', validador::TIPO_TEXTO, array('allowempty' => true));
                
                $parametros = array();
                $parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
                $parametros['estado'] = "T";
                
                if ($alcance == "T") {
                        $parametros['alcance'] = "T";
                } else {
                        $parametros['alcance'] = "A";
                }
                $xls = new generador_excel();
                $estilo_titulo = array('font' => array('bold' => true), );
                
                if ($listado == 'cursada')
                {
                        $inscripciones_cursadas_rechazadas = catalogo::consultar('alumno', 'inscripciones_cursadas_rechazadas', $parametros);
                        $inscripciones_cursadas = catalogo::consultar('alumno', 'inscripciones_cursadas', $parametros);

                        $data_tabla = array_merge($inscripciones_cursadas_rechazadas, $inscripciones_cursadas);
                        pagelet_cursadas::ordenar_desc($data_tabla);
                        
                        $titulos = array (  'materia' => strtoupper(kernel::traductor()->trans("mis_inscripciones.materia")),
                                            'anio_acad' => strtoupper(kernel::traductor()->trans("mis_inscripciones.anio")),
                                            'per_lec' => strtoupper(kernel::traductor()->trans("mis_inscripciones.per_lec")),
                                            'sede' => strtoupper(kernel::traductor()->trans("mis_inscripciones.sede")),
                                            'fecha' => strtoupper(kernel::traductor()->trans("mis_inscripciones.fecha_inscripcion")),
                                            'comision' => strtoupper(kernel::traductor()->trans("mis_inscripciones.comision")),
                                            'turno' => strtoupper(kernel::traductor()->trans("mis_inscripciones.turno")),
                                            'catedra' => strtoupper(kernel::traductor()->trans("mis_inscripciones.catedra")),
                                            'estado' => strtoupper(kernel::traductor()->trans("mis_inscripciones.estado")),
                                         );
                        
                        $xls->agregar_texto_estilos(strtoupper(kernel::traductor()->trans("mis_inscripciones.cursadas")), 1, $estilo_titulo);
                        $xls->set_nombre_archivo('ListaCursadas');
                        
                }elseif ($listado == 'examen') {
                       
                        $inscripciones_examen_rechazadas = catalogo::consultar('alumno', 'inscripciones_examen_rechazadas', $parametros);
                        $inscripciones_examenes = catalogo::consultar('alumno', 'inscripciones_examenes', $parametros);
                        $examenes = array_merge($inscripciones_examen_rechazadas, $inscripciones_examenes);
                        pagelet_examenes::ordenar_desc($examenes);
                        
                        $titulos = array (  'materia' => strtoupper(kernel::traductor()->trans("mis_inscripciones.materia")),
                                            'anio' => strtoupper(kernel::traductor()->trans("mis_inscripciones.anio")),
                                            'turno' => strtoupper(kernel::traductor()->trans("mis_inscripciones.turno")),
                                            'MESA_EXAMEN' => strtoupper(kernel::traductor()->trans("mis_inscripciones.mesa")),
                                            'sede' => strtoupper(kernel::traductor()->trans("mis_inscripciones.sede")),
                                            'fecha_dia' => strtoupper(kernel::traductor()->trans("mis_inscripciones.fecha_examen_dia")),
                                            'fecha_hora' => strtoupper(kernel::traductor()->trans("mis_inscripciones.fecha_examen_hora")),
                                            'fecha_inscr' => strtoupper(kernel::traductor()->trans("mis_inscripciones.fecha_inscripcion")),
                                            'tipo' => strtoupper(kernel::traductor()->trans("mis_inscripciones.tipo")),
                                            'estado' => strtoupper(kernel::traductor()->trans("mis_inscripciones.estado")),
                                            'ORDEN_INSC' => strtoupper(kernel::traductor()->trans("mis_inscripciones.orden"))
                        );
                        foreach ($examenes as $examen ){
                            $fila_tabla = array_intersect_key($examen, $titulos);
                            $data_tabla [] = $fila_tabla;
                        }
                        
                        $xls->agregar_texto_estilos(strtoupper(kernel::traductor()->trans("mis_inscripciones.examenes")), 1, $estilo_titulo);
                        $xls->set_nombre_archivo('ListaExamenes');
                }
                $xls->agregar_texto_sin_enter(guarani::ua()->get_nombre_institucion(), 1);
                $xls->agregar_texto(guarani::ua()->get_nombre(), 1);
                
                $xls->agregar_texto_sin_enter(strtoupper(kernel::traductor()->trans("resumen_cursada.comision.encabezado.alumno")).': '.guarani::persona()->get_nombre(), 1);
                $xls->agregar_texto_sin_enter(strtoupper(kernel::traductor()->trans("resumen_cursada.comision.encabezado.legajo")).': '.guarani::persona()->get_id_legajo_activo(), 1);
                
                $xls->agregar_tabla($data_tabla, $titulos);
                $xls->generar();
        }
        
        protected function crear_ezpdf() 
        {
            require_once "ezpdf/class.ezpdf.php";
            $instancia = new \Cezpdf($this->pdf_hoja, 'landscape');
            return $instancia;
        }
        
        function accion__generar_comprobante_examen()
        {
                $url_transaccion = $this->validate_param('transaccion', 'get', validador::TIPO_ALPHANUM);
                $historico = $this->validate_param('historico', 'get', validador::TIPO_INT, array('allowempty' => true));

                if ($historico){

                        $examen = new examen();
                        $inscripcion_examen = $examen->modelo()->info__comprobante_historico($url_transaccion);
                        $inscripcion_examen['url_nro_transaccion'] = $url_transaccion;

                } else {

                        $parametros = array('nro_inscripcion' => kernel::persona()->get_nro_inscripcion(),
                                'alcance' => ($this->get_var('alcance_examenes', 'A') == "T") ? "T" : "A",
                                'estado' => "T");

                        $inscripciones_examenes = catalogo::consultar('alumno', 'inscripciones_examenes', $parametros);

                        if (!empty($inscripciones_examenes)) {

                                $key = $this->searchForId($url_transaccion ,$inscripciones_examenes);

                                if ($key !== null){
                                        $inscripcion_examen = $inscripciones_examenes[$key];
                                }
                        }
                }

                $datos = array(
                                'LEGAJO' => $inscripcion_examen['LEGAJO'],
                                'NOMBRE_ALUMNO' => $inscripcion_examen['NOMBRE_ALUMNO'],
                                'NOMBRE_CARRERA' => $inscripcion_examen['NOMBRE_CARRERA'],
                                'CARRERA' => $inscripcion_examen['CARRERA'],
                                'FECHA_INSCRIPCION' => $inscripcion_examen['FECHA_INSCRIPCION'],
                                'NOMBRE_MATERIA' => $inscripcion_examen['NOMBRE_MATERIA'],
                                'ANIO_ACADEMICO' => $inscripcion_examen['ANIO_ACADEMICO'],
                                'CATEDRA' => $inscripcion_examen['CATEDRA'],
                                'TIPO_INSC_DESC' => $inscripcion_examen['TIPO_INSC_DESC'],
                                'TURNO_EXAMEN' => $inscripcion_examen['TURNO_EXAMEN'],
                                'MESA_EXAMEN' => $inscripcion_examen['MESA_EXAMEN'],
                                'ESTADO_INSCRIPCION' => $inscripcion_examen['ESTADO_INSCRIPCION'],
                                'ORDEN_INSC' => $inscripcion_examen['ORDEN_INSC'],
                                'NRO_TRANSACCION' => $inscripcion_examen['NRO_TRANSACCION']

                        );

                examen::generar_comprobante($accion = "", $datos);
        }

        function searchForId($id, $array) {
                foreach ($array as $key => $val) {
                        if ($val['url_nro_transaccion'] === $id) {
                                return $key;
                        }
                }
                return null;
        }
}
?>