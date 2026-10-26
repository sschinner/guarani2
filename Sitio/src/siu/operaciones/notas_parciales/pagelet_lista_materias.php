<?php
namespace siu\operaciones\notas_parciales;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\modelo\datos\catalogo;

class pagelet_lista_materias extends pagelet
{
    function get_nombre()
    {
        return 'lista_materias';
    }

    function get_lista_materias()
    {
        $raw = $this->controlador->modelo()->info__lista_evaluaciones();
        $rs = array();

		$fecha_hoy = new \DateTime();
		$fecha_hoy->setTime(0, 0, 0);
				
		foreach($raw as $materia)
		{
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
            $rs[$mat]['COMISIONES'][$com]['URL'] = $materia['COMISION_URL'];
            $rs[$mat]['COMISIONES'][$com]['FECHA_INICIO_PER'] = $materia['FECHA_INICIO'];
        
			if (empty($materia['EVALUACION'])) {
                continue;
            }
			
			$evaluacion_id = $materia[catalogo::id];
            $eva = $materia['EVALUACION'];
			$rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['ID'] = $evaluacion_id;
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['EVALUACION'] = $eva;
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['NOMBRE'] = $materia['EVALUACION_NOMBRE'];
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['TIPO'] = $materia['EVALUACION_TIPO'];
			
			$rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['FECHA'] = "";
			$rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['PUEDE_CARGAR_NOTAS'] = false;
			if (isset($materia['EVALUACION_FECHA'])){
				$rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['FECHA'] = date("d/m/Y H:i", strtotime($materia['EVALUACION_FECHA']));
				
				$fecha_evaluacion = \DateTime::createFromFormat('Y-m-d H:i:s', $materia['EVALUACION_FECHA']);
				$fecha_evaluacion->setTime(0, 0, 0);
				
				// Verifica que la fecha en que están cargando sea igual o mayor a la que está asignada en la evaluación parcial
				if ($fecha_hoy >= $fecha_evaluacion) {
					$rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['PUEDE_CARGAR_NOTAS'] = true;
				}
				
			}
			
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['PORCENTAJE_CARGA'] = $materia['PORCENTAJE_CARGA'];
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['CANT_INSCRIPTOS'] = $materia['CANT_INSCRIPTOS'];
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['URL_LISTAR'] = 
				kernel::vinculador()->crear('notas_parciales', 'listar', $evaluacion_id);
            $rs[$mat]['COMISIONES'][$com]['EVALUACIONES'][$eva]['URL_EDITAR'] = 
				kernel::vinculador()->crear('notas_parciales', 'editar', $evaluacion_id);
        }

		$cant_tipos_eval = count($this->controlador->modelo()->info__tipo_evaluacion());
		foreach($raw as $materia)
		{
			foreach($rs[$materia['MATERIA']]['COMISIONES'] as $orden => $comision)
			{
				if (isset($rs[$materia['MATERIA']]['COMISIONES'][$orden]['EVALUACIONES']))
					$rs[$materia['MATERIA']]['COMISIONES'][$orden]['COMPLETA'] = count($rs[$materia['MATERIA']]['COMISIONES'][$orden]['EVALUACIONES']) >= $cant_tipos_eval;
			}
		}
        return $rs;
    }
    
    function prepare()
    {
		$this->data = array();
		
		switch ($this->estado) {
			case 'crear_parcial':
				$this->set_template('parcial');
				break;
			default:
                $this->data = $this->get_lista_materias();
				$this->add_var_js('url_crear_evaluacion', kernel::vinculador()->crear('notas_parciales', 'crear_evaluacion'));
				$this->add_var_js('url_borrar_evaluacion', kernel::vinculador()->crear('notas_parciales', 'borrar_evaluacion'));
				$this->add_var_js('titulo_crear_parcial', kernel::traductor()->trans('crear_evaluacion_parcial'));
				$this->add_var_js('boton_crear_parcial', kernel::traductor()->trans('crear_parcial'));
				$this->add_mensaje_js('fecha_evaluacion_mayor_hoy', kernel::traductor()->trans('fecha_evaluacion_mayor_hoy'));
				// Se manda el template en una variable js para que dp se reuse para las
				// diferentes materias
				$this->add_var_js('html_popup', 
					kernel::load_template('lista_materias/popup.twig')->render(array(
						'tipo_eval' => $this->controlador->modelo()->info__tipo_evaluacion(),
						'escalas' => $this->controlador->modelo()->info__lista_escala_notas()
					))
				);
		}
    }
}
?>
