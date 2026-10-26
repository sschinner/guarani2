<?php

namespace personalizacionCEMED\operaciones\inscriptos_examenes;

use kernel\kernel;
use siu\guarani;
use kernel\nucleo\controlador as controlador_base;
use kernel\util\u;
use siu\modelo\datos\catalogo;
use kernel\util\validador;
use siu\operaciones\_comun\operaciones\reporte\generador_pdf;
use siu\operaciones\_comun\operaciones\reporte\generador_excel;


class controlador extends \siu\operaciones\inscriptos_examenes\controlador
{
    
   function accion__exportar_xls_comision()
        {   
                $xls = $this->get_generador_excel();
                $this->id_registro = $this->validate_param('id', 'get', validador::TIPO_ALPHANUM);
		$this->ordenamiento = $this->validate_param('ord', 'get', validador::TIPO_ALPHANUM, array('allowempty' => true));
                
                $datos = $this->ordenar($this->get_info_comision(),$this->ordenamiento,'asc');
                
                ob_clean();
                //$xls = new generador_excel();
                $titulos = $this->get_columnas();
                $xls->set_nombre_archivo('inscripciones_examen');

                $institucion = guarani::ua()->get_nombre_institucion();
                $facultad = guarani::ua()->get_nombre();

                $xls->agregar_texto_sin_enter($institucion,1);
                $xls->agregar_texto($facultad,1);
                $estilo_titulo = array(
                        'font' => array('bold' => true),
                );
                $xls->agregar_texto_estilos('Inscripciones a ExÃ¡menes',1, $estilo_titulo);
                $xls->agregar_texto_sin_enter('Materia: '.$datos['titulos']['MATERIA_NOMBRE']." (".$datos['titulos']['MATERIA'].")",1);
                $xls->agregar_texto_sin_enter('Sede: '.$datos['titulos']['SEDE'],1);
                $xls->agregar_texto_sin_enter('AÃ±o: '.$datos['titulos']['ANIO_ACADEMICO'],1);
                $xls->agregar_texto_sin_enter('Turno: '.$datos['titulos']['TURNO_EXAMEN'],1);
                $xls->agregar_texto_sin_enter('Mesa: '.$datos['titulos']['MESA_EXAMEN'],1);
                $xls->agregar_texto_sin_enter('Llamado: '.$datos['titulos']['LLAMADO'],1);
                $xls->agregar_tabla($datos['alumnos'], $titulos);
                $xls->generar();
        } 
        
        protected function get_generador_excel()
	{
		return new generador_excel();
	}
        
        function get_columnas(){
                return array(
                        'ORDEN' => '#',
                        'LEGAJO' => 'Legajo',
                        'APELLIDO_NOMBRE' => 'Nombre',
                        'EMAIL' => 'Email', // Personalizacion UNL
                        'FECHA_INSCRIPCION' => 'Fecha Inscripción',
                        'TIPO_INSCRIPCION' => 'Calidad',
                        'ESTADO' => 'Estado',
                        'CARRERA_NOMBRE' => 'Carrera',
                        'CURSADA_ANIO_ACADEMICO' => 'Año Cur.',
                        'CURSADA_CATEDRA' => 'Cátedra Cur.'
                );
}
}