<?php
namespace siu\operaciones\inscriptos_examenes;

use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use kernel\util\validador;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;


class controlador extends \siu\operaciones\_comun\operaciones\reporte\controlador
{
        protected $id_registro;
        protected $ordenamiento;
        protected $lista_mesas;
        protected $pdf_hoja = "A4";
        protected $pdf_encabezado = array("", "");
        protected $pdf_encabezado_img = array("img" => "", "width" => "");
        protected $pdf_fuente = "Courier.afm";
        protected $pdf_fuente_texto = 10;
        protected $pdf_fuente_titulo = 10;
        protected $pdf_fuente_subtitulo = 12;
        protected $tiene_encabezado = true;
        protected $encabezado_reporte = "";	

        function accion__info_comision()
        {
                $this->id_registro = $this->validate_param('id', 'get', validador::TIPO_ALPHANUM);
                $this->ordenamiento = $this->validate_param('ord', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
                $clase = 'operaciones\inscriptos_examenes\pagelet_comision';
                $pl = kernel::localizador()->instanciar($clase, 'items');
                $this->vista()->add_pagelet($pl);
                $operacion = kernel::ruteador()->get_id_operacion();

				/* url bot?n Volver */		
                $pl->data['url_filtro'] = kernel::vinculador()->crear($operacion, 'info_comision', array('id'=>$this->id_registro, 'ord'=> null));		
                $pl->data['url_back'] = kernel::vinculador()->crear($operacion);		
                $pl->data['url_pdf'] =  kernel::vinculador()->crear('inscriptos_examenes', 'exportar_pdf_comision', array('id' => $this->id_registro, 'ord'=> $this->ordenamiento));		
                $pl->data['url_xls'] =  kernel::vinculador()->crear('inscriptos_examenes', 'exportar_xls_comision', array('id' => $this->id_registro, 'ord'=> $this->ordenamiento));	

                $pl->data['alumnos_comision'] = $this->ordenar($this->get_info_comision(),$this->ordenamiento,'asc');
        }

        function get_lista_mesas()
        {
                 if (!isset($this->lista_mesas)){
                        $parametros = array(
                                                        'nro_inscripcion' =>  kernel::persona()->get_nro_inscripcion(),
                                                        'filtro_inscripciones' => $this->vista()->pagelet('items')->filtros['filtro']
                                                    );
                        $datos = catalogo::consultar('docente', 'lista_mesas_vigentes', $parametros);			
                        $this->lista_mesas = $datos;
                    } else {
                        $datos = $this->lista_mesas;
                    }
                    return $datos;
        }

        function get_mesa($id)
        {
                $mesas = $this->get_lista_mesas();
                if (isset($mesas[$id])){
                        return $mesas[$id];
                }
        }

        function get_info_cursada($materia, $carrera, $legajo)
        {
                $notas_examen =  guarani::carga_notas_examen();
                $datos= $notas_examen->info__examenes($materia, $carrera, $legajo);
				return $datos['ficha'];
        }
		
        function get_info_comision()
        {		
                $mesa = $this->get_mesa($this->id_registro);		
                $parametros = array();
                $parametros['materia'] = $mesa['MATERIA'];
                $parametros['anio_academico'] = $mesa['ANIO_ACADEMICO'];
                $parametros['turno_examen'] = $mesa['TURNO_EXAMEN'];
                $parametros['mesa_examen'] = $mesa['MESA_EXAMEN'];
                $parametros['llamado'] = $mesa['LLAMADO'];		
                $datos = catalogo::consultar('docente', 'alum_inscriptos_examen', $parametros);
                
                foreach($datos as $key => $dato){                    
                        $datos[$key]['URL_FICHA'] = kernel::vinculador()->crear('inscriptos_examenes', 'ficha_alumno', array(
				'materia'	=> $dato['MATERIA'],
				'carrera'	=> $dato['CARRERA'],
				'legajo'	=> $dato['LEGAJO']
			));
						$datos_cursada = $this->get_info_cursada($dato['MATERIA'], $dato['CARRERA'],$dato['LEGAJO']);
						$datos[$key]['CURSADA_ANIO_ACADEMICO'] = $datos_cursada['ANIO_ACADEMICO'];
						$datos[$key]['CURSADA_CATEDRA'] = $datos_cursada['CATEDRA'];
                }
                
                $resultado = array(
                                        'titulos' => $mesa,
                                        'alumnos' => $datos
                                );
                $this->datos_consulta = $resultado;
                return $resultado;
        } 

	protected function ordenar($datos, $ordenar_por, $orden){
		switch($ordenar_por){
			case 'L':
				$columna = 'LEGAJO';
				break;
			case 'N':
				$columna = 'APELLIDO_NOMBRE';
				break;
			case 'F':
				$columna = 'FECHA_INSCRIPCION_ORD';
				break;
		}
		
		$datos_titulos = $datos['titulos'];
		$datos_alumnos = $datos['alumnos'];
		
//		if (isset($columna) && isset($orden) && array_key_exists($columna, $this->get_columnas())){
			$count = count($datos_alumnos);
			for($i=0; $i<=$count; $i++){
				for($j=$count-1; $j>$i; $j=$j-1){
					if (isset($datos_alumnos[$j][$columna]) && isset($datos_alumnos[$j-1][$columna])){
						if ($orden == "asc" && $datos_alumnos[$j][$columna] < $datos_alumnos[$j-1][$columna]){
							$tmp = $datos_alumnos[$j];
							$datos_alumnos[$j] = $datos_alumnos[$j-1];
							$datos_alumnos[$j-1] = $tmp;
							unset($tmp);
						} elseif($orden == "desc" && $datos_alumnos[$j][$columna] > $datos_alumnos[$j-1][$columna]){
							$tmp = $datos_alumnos[$j];
							$datos_alumnos[$j] = $datos_alumnos[$j-1];
							$datos_alumnos[$j-1] = $tmp;
							unset($tmp);
						}
					}
				}
			}
			
			for($i=0; $i<$count; $i++){
				$datos_alumnos[$i]['ORDEN']= $i+1;
			}
			
			$nuevo['titulos']=$datos_titulos;
			$nuevo['alumnos']=$datos_alumnos;
//		}
		return $nuevo;
	}
	
        /*Generar excel y pdf con filtros*/
        function accion__generar_pdf(){
                $filtros['filtro'] = $this->validate_param('filtro', 'get', validador::TIPO_ALPHANUM, array('allowempty' => false));
                $pagelet = $this->vista()->pagelet('items');
                $pagelet->set_filtros($filtros);
                parent::accion__generar_pdf();
        }

        function accion__generar_excel(){
                $filtros['filtro'] = $this->validate_param('filtro', 'get', validador::TIPO_ALPHANUM, array('allowempty' => false));
                $pagelet = $this->vista()->pagelet('items');
                $pagelet->set_filtros($filtros);
                parent::accion__generar_excel();
        }

        /* Exportación INFO COMISIÓN*/
        function accion__exportar_pdf_comision()
        {
                $this->id_registro = $this->validate_param('id', 'get', validador::TIPO_ALPHANUM);
				$this->ordenamiento = $this->validate_param('ord', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
                $datos = $this->ordenar($this->get_info_comision(),$this->ordenamiento,'asc');
                $pdf = new generador_pdf($this->crear_ezpdf());
                $pdf->set_font($this->pdf_fuente);
                $pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 750, 'width' => 750, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => array()));
                //$pdf->set_options(array('showHeadings'=>1, 'protectRows' => 1, 'maxWidth' => 750, 'width' => 750, 'fontSize' => $this->pdf_fuente_texto, 'shadeCol' => array(0.8,0.8,0.8),'cols' => array('LEGAJO'=> array('width'=>100), 'APELLIDO_NOMBRE'=> array('width'=>100))));
                $pdf->set_text_options(array('left'=>5, 'top' => 20, 'maxWidth' => 750, 'width' => 750));
                $pdf->set_pdf_fuente_texto($this->pdf_fuente_texto);
                $pdf->set_pdf_fuente_titulo($this->pdf_fuente_titulo);
                $pdf->set_pdf_fuente_subtitulo($this->pdf_fuente_subtitulo);
                $pdf->set_tiene_encabezado($this->tiene_encabezado);
                $pdf->set_nombre_archivo('inscripciones_examenes');

                $datos_encabezado = array(
                                          'cant_columnas' => 2,
                                          'datos' => array(0 => 'Materia: '.$datos['titulos']['MATERIA_NOMBRE']." (".$datos['titulos']['MATERIA'].")",
                                                           1 => 'Sede: '.$datos['titulos']['SEDE'],
                                                           2 => 'Año: '.$datos['titulos']['ANIO_ACADEMICO'],
                                                           3 => 'Turno: '.$datos['titulos']['TURNO_EXAMEN'],
                                                           4 => 'Mesa: '.$datos['titulos']['MESA_EXAMEN'],
                                                           5 => 'Llamado: '.$datos['titulos']['LLAMADO'],
                                                           )
                                          );

                $pdf->set_encabezado_tabla($datos_encabezado);

                $universidad = guarani::ua()->get_nombre_institucion()."\n".guarani::ua()->get_nombre()."\n";

                $logo = kernel::localizador()->encontrar_img('www/img','logo.png');

                $this->pdf_encabezado = array($universidad, '<b><u>Inscripciones a Exámenes</u></b>', 110);
                $this->pdf_encabezado_img = array('img'=>$logo['path'],'width' => '100');

                $pdf->set_encabezado($this->pdf_encabezado[0], $this->pdf_encabezado[1], $this->pdf_encabezado[2]);
                $pdf->set_encabezado_img($this->pdf_encabezado_img["img"], $this->pdf_encabezado_img["width"]);
                $pdf->agregar_texto("");

                $titulos = $this->get_columnas();
                $pdf->agregar_tabla($datos['alumnos'], $titulos, '');
                $pdf->generar();		
        }

        function accion__exportar_xls_comision()
        {
                $this->id_registro = $this->validate_param('id', 'get', validador::TIPO_ALPHANUM);
				$this->ordenamiento = $this->validate_param('ord', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
                $datos = $this->ordenar($this->get_info_comision(),$this->ordenamiento,'asc');

                $xls = new generador_excel();
                $titulos = $this->get_columnas();
                $xls->set_nombre_archivo('inscripciones_examen');

                $institucion = guarani::ua()->get_nombre_institucion();
                $facultad = guarani::ua()->get_nombre();

                $xls->agregar_texto_sin_enter($institucion,1);
                $xls->agregar_texto($facultad,1);
                $estilo_titulo = array(
                        'font' => array('bold' => true),
                );
                $xls->agregar_texto_estilos('Inscripciones a Exámenes',1, $estilo_titulo);
                $xls->agregar_texto_sin_enter('Materia: '.$datos['titulos']['MATERIA_NOMBRE']." (".$datos['titulos']['MATERIA'].")",1);
                $xls->agregar_texto_sin_enter('Sede: '.$datos['titulos']['SEDE'],1);
                $xls->agregar_texto_sin_enter('Año: '.$datos['titulos']['ANIO_ACADEMICO'],1);
                $xls->agregar_texto_sin_enter('Turno: '.$datos['titulos']['TURNO_EXAMEN'],1);
                $xls->agregar_texto_sin_enter('Mesa: '.$datos['titulos']['MESA_EXAMEN'],1);
                $xls->agregar_texto_sin_enter('Llamado: '.$datos['titulos']['LLAMADO'],1);
                $xls->agregar_tabla($datos['alumnos'], $titulos);
                $xls->generar();
        }

        protected function crear_ezpdf(){
                $instancia = new \Cezpdf($this->pdf_hoja, 'landscape');
                return $instancia;
        }

        function get_columnas(){
                return array(
                        'ORDEN' => '#',
                        'LEGAJO' => 'Legajo',
                        'APELLIDO_NOMBRE' => 'Nombre',
                        'FECHA_INSCRIPCION' => 'Fecha Inscripción',
                        'TIPO_INSCRIPCION' => 'Calidad',
                        'ESTADO' => 'Estado',
                        'CARRERA_NOMBRE' => 'Carrera',
                        'CURSADA_ANIO_ACADEMICO' => 'Año Cur.',
                        'CURSADA_CATEDRA' => 'Cátedra Cur.'
                );
        }


        function accion__filtrar(){
                $filtros = array();
                $filtros['filtro'] = $this->validate_param('filtro', 'get', validador::TIPO_ALPHANUM, array('allowempty' => false));
                $pagelet = $this->vista()->pagelet('items');
                $pagelet->set_filtros($filtros);
                kernel::renderer()->add($pagelet);
        }

        function accion__ficha_alumno()
        {
                $materia = $this->validate_param('materia', 'get', validador::TIPO_TEXTO);
                $carrera = $this->validate_param('carrera', 'get', validador::TIPO_TEXTO);
                $legajo = $this->validate_param('legajo', 'get', validador::TIPO_TEXTO);

                $pagelet = kernel::localizador()->instanciar('operaciones\inscriptos_examenes\pagelet_ficha_alumno', 'ficha_alumno');
                
                $notas_examen =  guarani::carga_notas_examen();
                $pagelet->set_data($notas_examen->info__examenes($materia, $carrera, $legajo));
                kernel::renderer()->add($pagelet);
        }
}
?>