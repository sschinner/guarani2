<?php
namespace siu\operaciones\asistencias;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\modelo\entidades\persona;

class pagelet_lista_materias extends pagelet
{
	public $filtros = array('materia' => "", 'per_lect'=> "", 'docente'=> "");
	public $perfil_activo;
	
    function get_nombre()
    {
        return 'lista_materias';
    }
	
	function get_lista_comisiones()
	{
		if (!isset($this->perfil_activo)){
			$this->perfil_activo = kernel::persona()->get_id_perfil_activo();
		}
		
		if($this->perfil_activo == persona::PERFIL_BEDELIA)
		{	
			$filtros = $this->get_filtros();
			$this->controlador->modelo()->filtros = $filtros;
			$comisiones = $this->controlador->modelo()->get_lista_comisiones_filtro($filtros);
		} else
		{
			$comisiones = $this->controlador->modelo()->get_lista_comisiones();
		}

		$rs	= array();
		foreach ($comisiones as $comision) {
		//while ($comision = next($raw)) {
			$mat = $comision['MATERIA'];
			$rs[$mat]['MATERIA'] = $mat;
            $rs[$mat]['NOMBRE'] = $comision['MATERIA_NOMBRE'];
			
			$com = $comision['COMISION'];
			$rs[$mat]['COMISIONES'][$com]['COMISION'] = $com;
            $rs[$mat]['COMISIONES'][$com]['NOMBRE'] = $comision['COMISION_NOMBRE'];
            $rs[$mat]['COMISIONES'][$com]['CANT_INSCRIPTOS'] = $comision['CANT_INSCRIPTOS'];
			$rs[$mat]['COMISIONES'][$com]['ANIO_ACADEMICO'] = $comision['ANIO_ACADEMICO'];
            $rs[$mat]['COMISIONES'][$com]['PERIODO_LECTIVO'] = $comision['PERIODO_LECTIVO'];
            $rs[$mat]['COMISIONES'][$com]['CATEDRA'] = $comision['CATEDRA'];
            $rs[$mat]['COMISIONES'][$com]['TURNO'] = $comision['TURNO'];
            $rs[$mat]['COMISIONES'][$com]['SEDE'] = $comision['SEDE'];
            $rs[$mat]['COMISIONES'][$com]['SEDE_NOMBRE'] = $comision['SEDE_NOMBRE'];
            $rs[$mat]['COMISIONES'][$com]['ID'] = $comision[catalogo::id];
			$rs[$mat]['COMISIONES'][$com]['URL_LIBRES'] = kernel::vinculador()->crear('asistencias', 'libres', array('ID' => $comision[catalogo::id]));
			$rs[$mat]['COMISIONES'][$com]['URL_PLANILLA'] = kernel::vinculador()->crear('asistencias', 'planilla', array('ID' => $comision[catalogo::id], 'SUBCO'=>'', 'TIPO_CLASE'=>''));
			$rs[$mat]['COMISIONES'][$com]['CANT_LIBRES'] = $comision['CANT_LIBRES'];
			$rs[$mat]['COMISIONES'][$com]['CNT_SUBCOMISIONES'] = $comision['CNT_SUBCOMISIONES'];
		}
		return $rs;
	}
	
	function get_lista_materias()
	{
		
		$raw = $this->controlador->modelo()->info__lista_clases();
		$rs	= array();
		while ($materia = next($raw)) {
			$mat = $materia['MATERIA'];
			$rs[$mat]['MATERIA'] = $mat;
            $rs[$mat]['NOMBRE'] = $materia['MATERIA_NOMBRE'];
			
			$com = $materia['COMISION'];
			$rs[$mat]['COMISIONES'][$com]['COMISION'] = $com;
            $rs[$mat]['COMISIONES'][$com]['NOMBRE'] = $materia['COMISION_NOMBRE'];
            $rs[$mat]['COMISIONES'][$com]['CANT_INSCRIPTOS'] = $materia['CANT_INSCRIPTOS'];
			$rs[$mat]['COMISIONES'][$com]['ANIO_ACADEMICO'] = $materia['ANIO_ACADEMICO'];
            $rs[$mat]['COMISIONES'][$com]['PERIODO_LECTIVO'] = $materia['PERIODO_LECTIVO'];
            $rs[$mat]['COMISIONES'][$com]['CATEDRA'] = $materia['CATEDRA'];
            $rs[$mat]['COMISIONES'][$com]['TURNO'] = $materia['TURNO'];
            $rs[$mat]['COMISIONES'][$com]['SEDE'] = $materia['SEDE'];
            $rs[$mat]['COMISIONES'][$com]['SEDE_NOMBRE'] = $materia['SEDE_NOMBRE'];
            $rs[$mat]['COMISIONES'][$com]['ID'] = $materia[catalogo::id];
			
			
//			if (empty($materia['EVALUACION'])) {
//                continue;
//            }
			
			
			foreach ($materia['CLASES'] as $clase) {

				$clase_id = $clase[catalogo::id];	
				$cla = $clase['CLASE'];
				$rs[$mat]['COMISIONES'][$com]['CLASES'][$cla] = $clase;
				$rs[$mat]['COMISIONES'][$com]['CLASES'][$cla]['ID'] = $clase_id;
			}
			

			/*
			
            
			$rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['ID'] = $evaluacion_id;
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['EVALUACION'] = $eva;
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['NOMBRE'] = $materia['EVALUACION_NOMBRE'];
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['TIPO'] = $materia['EVALUACION_TIPO'];
			
			$rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['FECHA'] = "";
			if (isset($materia['EVALUACION_FECHA'])){
				$rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['FECHA'] = date("d/m/Y H:i", strtotime($materia['EVALUACION_FECHA']));
			}
			
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['PORCENTAJE_CARGA'] = $materia['PORCENTAJE_CARGA'];
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['CANT_INSCRIPTOS'] = $materia['CANT_INSCRIPTOS'];
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['URL_LISTAR'] = 
				kernel::vinculador()->crear('notas_parciales', 'listar', $evaluacion_id);
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['URL_EDITAR'] = 
				kernel::vinculador()->crear('notas_parciales', 'editar', $evaluacion_id);
        }
        */
			
			
		}

		return $rs;
		
	}

    
    function prepare()
    {
		$this->data = array();
//		$this->add_var_js('mostrar_subcomisiones', kernel::traductor()->trans('asistencias.mostrar_subco'));
//		$this->add_var_js('ocultar_subcomisiones', kernel::traductor()->trans('asistencias.mostrar_subco'));
		$this->add_var_js('mostrar_clases', kernel::traductor()->trans('mostrar_clases'));
		$this->add_var_js('ocultar_clases', kernel::traductor()->trans('ocultar_clases'));
		$this->add_var_js('ver_ultimas', kernel::traductor()->trans('ver_ultimas'));
		
		switch ($this->estado) {
			case 'crear_parcial':
				$this->set_template('parcial');
				break;
			default:
                $this->data['datos'] = $this->get_lista_comisiones();
				$this->add_var_js('url_mostrar_clases', kernel::vinculador()->crear('asistencias', 'mostrar_clases'));
				$this->add_var_js('url_mostrar_subcomisiones', kernel::vinculador()->crear('asistencias', 'mostrar_subcomisiones'));
		}
		
		$this->data['url_form_filtro'] = kernel::vinculador()->crear('asistencias', 'filtrar');
		$this->add_var_js('url_autocomplete_materia', kernel::vinculador()->crear('asistencias', 'buscar_materia'));
		$this->add_var_js('url_autocomplete_docente', kernel::vinculador()->crear('asistencias', 'buscar_docente'));
		$this->perfil_activo = kernel::persona()->get_id_perfil_activo();
    }
	
	/*FILTROS PERFIL BEDELIA*/
	public function set_filtros($filtros){
		$this->filtros = array_merge($this->filtros, $filtros);
	}

	public function get_filtros(){
		return $this->filtros;
	}
	
	public function get_datos_filtros(){
		// periodo lectivo
		$pl = catalogo::consultar('unidad_academica', 'periodos_lectivos');
		$filtros['per_lec'] = array();
		foreach($pl as $periodo){
			$filtros['per_lec'][$periodo['_ID_']] = $periodo['PERIODO_LECTIVO'];
		}
		return $filtros;
	}
	
	public function get_docente($legajo){
		$datos = catalogo::consultar('unidad_academica', 'docente', array('legajo' => $legajo));
		return $datos;
	}
	
	public function get_materia($id){
		$datos = catalogo::consultar('unidad_academica', 'materia', array('materia' => $id));
		return $datos;
	}
	
}
?>