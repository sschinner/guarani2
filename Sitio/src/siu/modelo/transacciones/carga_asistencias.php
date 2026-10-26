<?php
namespace siu\modelo\transacciones;

use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\errores\error_guarani;
use siu\errores\error_guarani_procesar_renglones;
use \siu\modelo\datos\util;
use siu\modelo\entidades\persona;

class carga_asistencias extends transaccion
{
	protected $operacion = 'curxxxxx';
	protected $evento = 'xx';
	public $filtros = array('materia' => "", 'per_lect'=> "", 'docente'=> "");

	//---------------------------------------------
	//	Manejo OPCIONES
	//---------------------------------------------	

	protected function get_comision_enviada($seleccion)
	{
		if (!isset($this->opciones_enviadas_com)) {
			$perfil_activo = kernel::persona()->get_id_perfil_activo();
			if($perfil_activo == persona::PERFIL_BEDELIA)
			{	
				$this->opciones_enviadas_com = $this->get_lista_comisiones_filtro($this->filtros);
			} else
			{
				$this->opciones_enviadas_com = $this->get_lista_comisiones();
			}

		}
		kernel::log()->add_debug('lolololololo', $seleccion);
		kernel::log()->add_debug('', $this->opciones_enviadas_com);
		foreach($this->opciones_enviadas_com as $opcion) {
			if($opcion[catalogo::id] == $seleccion){
				return $opcion;
			}
		}
		throw new error_guarani('COMISION invalida');
	}		

	protected function get_clase_enviada($seleccion_clase, $seleccion_comision, $filas)
	{
		if (!isset($this->opciones_enviadas)) {
			$this->opciones_enviadas = $this->get_clases_comision($seleccion_comision, $filas);
		}

		foreach($this->opciones_enviadas['clases'] as $opcion) {
			if(isset($opcion[catalogo::id]) && $opcion[catalogo::id] == $seleccion_clase){
				return $opcion;
			}
		}
		throw new error_guarani('CLASE invalida');		
	}		
	
	//---------------------------------------------
	//	LISTA CLASES
	//---------------------------------------------
	
	function get_lista_comisiones() 
	{
		$parametros = array('legajo' => kernel::persona()->get_legajo_docente());
		return catalogo::consultar('carga_asistencias', 'listado_comisiones_docente', $parametros);
	}
	
	function get_lista_comisiones_filtro($filtros) 
	{
		return catalogo::consultar('carga_asistencias', 'listado_comisiones_filtro', $filtros);
	}
	
	function get_comision($seleccion) 
	{
		return $this->get_comision_enviada($seleccion);
	}
	
	function info__lista_clases()
	{
		
		$parametros = array('legajo' => kernel::persona()->get_legajo_docente());
		$comisiones = catalogo::consultar('carga_asistencias', 'listado_comisiones_docente', $parametros);
		
		$clases = array();
		foreach ($comisiones as $key => $comision) {
			$parametros['comision'] = $comision['COMISION'];
			$parametros['filas'] = 3;
			if ($comision['CNT_SUBCOMISIONES'] > 0) {
				//$comisiones[$key]['CLASES'] = catalogo::consultar('carga_asistencias', 'get_clases_subcomisiones_docente', $parametros);
				$datos = catalogo::consultar('carga_asistencias', 'get_clases_subcomisiones_docente', $parametros);
				$clases = array_merge($clases, $datos);
			} else {
				//$comisiones[$key]['CLASES'] = catalogo::consultar('carga_asistencias', 'get_clases_comisiones_docente', $parametros);
				$datos = catalogo::consultar('carga_asistencias', 'get_clases_comisiones_docente', $parametros);
				$clases = array_merge($clases, $datos);

			}
		}
		return $clases;
	}
	
	function get_clases_comision($seleccion_comision, $cant)
	{
		//kernel::log()->add_debug('seleccion comision', $seleccion_comision);
		$comision = $this->get_comision_enviada($seleccion_comision);
		$parametros = array();
		$resultado = array();
		$parametros['comision'] = $comision['COMISION'];
		$parametros['filas'] = $cant;
		$parametros['legajo'] = null;

		if ($comision['CNT_SUBCOMISIONES'] > 0) {
			
			$perfil_activo = kernel::persona()->get_id_perfil_activo();
			
			if($perfil_activo == persona::PERFIL_DOCENTE) $parametros['legajo'] = kernel::persona()->get_legajo_docente();
			
			$resultado['clases'] = catalogo::consultar('carga_asistencias', 'get_clases_subcomisiones_docente', $parametros);
		} else {
			$resultado['clases'] = catalogo::consultar('carga_asistencias', 'get_clases_comisiones_docente', $parametros);
		}
		$param['comision_id'] = $seleccion_comision;
		$param['filas'] = $parametros['filas'];
		foreach ($resultado['clases'] as $key => $clase) {
			$param['clase_id'] = $clase[catalogo::id];
			$resultado['clases'][$key]['URL_EDITAR'] = kernel::vinculador()->crear('asistencias', 'editar', $param);
			$resultado['clases'][$key]['DIA_SEMANA_DESC'] = kernel::traductor()->trans('dia_semana'.$clase['DIA_SEMANA']);
		}
		
		return $resultado;
	}
	
	function info__clase_cabecera($seleccion_clase, $seleccion_comision, $filas)
	{
		// Control derechos
	
		$datos_comision = $this->get_comision_enviada($seleccion_comision);
		$datos_clase = $this->get_clase_enviada($seleccion_clase, $seleccion_comision, $filas);
		$datos_clase['MATERIA'] = $datos_comision['MATERIA'];
		$datos_clase['MATERIA_NOMBRE'] = $datos_comision['MATERIA_NOMBRE'];
		
		return $datos_clase;
	}	
	
	function info__clase_detalle($seleccion_clase, $seleccion_comision, $filas)
	{
		// Control derechos
		$parametros = array();
		$datos_clase = $this->get_clase_enviada($seleccion_clase, $seleccion_comision, $filas);
		$parametros['clase'] = $datos_clase['CLASE'];
		return catalogo::consultar('carga_asistencias', 'clase_detalle', $parametros);
	}
        
        function info__tipos_clase_comision($id_comision){
                $parametros = array ();
                $parametros['id_comision'] = $id_comision;
                return catalogo::consultar('carga_asistencias', 'tipo_clase_comision', $parametros);
        }
        
        function get_tipo_clase_desc($tipo_clase){
                $parametros = array ();
                $parametros['tipo_clase'] = $tipo_clase;
				$dato = catalogo::consultar('carga_asistencias', 'tipo_clase_desc', $parametros);
                return $dato;
        }
	
	function get_datos_alumno_clase($seleccion_clase, $seleccion_comision, $filas, $url_alumno)
	{
		$clases = $this->info__clase_detalle($seleccion_clase, $seleccion_comision, $filas);
		foreach($clases as $clase){
			if($clase[catalogo::id]==$url_alumno){
				return $clase;
			}
		}
		throw new error_guarani('Clase invalida');
	}
	
	function grabar($seleccion_clase, $seleccion_comision, $filas, $alumnos)
	{
		$error = new error_guarani_procesar_renglones('Error cargando notas');
		$hay_renglones_actualizados = false;		
		foreach ($alumnos as $id => $alumno){
			try {
			$datos_clase = $this->get_datos_alumno_clase($seleccion_clase, $seleccion_comision, $filas, $id);
			$parametros = array();
			$parametros['carrera'] = $datos_clase['CARRERA'];
			$parametros['legajo'] = $datos_clase['LEGAJO'];
			$parametros['comision'] = $datos_clase['COMISION'];
			$parametros['clase'] = $datos_clase['CLASE'];
			$parametros['cantidad'] = $alumno['PRESENTE'];
			$ok = catalogo::consultar('carga_asistencias', 'guardar', $parametros);
			if($ok[0] == 1) {
					$hay_renglones_actualizados = true;
			} else {
				$error->add_renglon($parametros['legajo'], util::mensaje($ok[1]), $parametros);
				//kernel::log()->add_error(new error_guarani($ok[1]));
			}
			} catch (error_kernel $e) {
				$error->add_renglon($parametros['legajo'], $e->getMessage(), $parametros);
				//kernel::log()->add_error($e);				
			}			
		}
		if($error->hay_renglones()) {
			throw $error;
		}			
	}
	
	function get_planilla($seleccion)
	{
		$datos_planilla = catalogo::consultar('carga_asistencias', 'get_planilla', $seleccion);
		return $datos_planilla;
	}
        
        
	
	//---------------------------------------------
	//	TEMAS
	//---------------------------------------------
	
	function get_temas_planificados($seleccion)
	{
		
	}
	
	function grabar_temas_dictados()
	{
		
	}
	
	//---------------------------------------------
	//	ALUMNOS LIBRES
	//---------------------------------------------
	
	function listado_alumnos_libres($seleccion)
	{
		$comision = $this->get_comision_enviada($seleccion);
		$parametros = array('comision' => $comision['COMISION']);
		$alumnos = catalogo::consultar('carga_asistencias', 'listado_alumnos_libres', $parametros);
		return $alumnos;
	}

	//---------------------------------------------
	//	PLANILLA DE ASISTENCIA PARA SUBCOMISIONES
	//---------------------------------------------
	function get_subcomisiones($seleccion_comision)
	{
		$comision = $this->get_comision_enviada($seleccion_comision);
		$parametros = array('comision' => $comision['COMISION']);
		$subcomisiones = catalogo::consultar('carga_asistencias', 'get_subcomisiones', $parametros);

		foreach ($subcomisiones['subcomisiones'] as $key => $subcomision) 
		{
			$subcomisiones['subcomisiones'][$key]['URL_PLANILLA'] = kernel::vinculador()->crear('asistencias', 'planilla', array('ID' => $seleccion_comision, 'SUBCO' =>$subcomision['SUBCOMISION'], 'TIPO'=>$subcomision['TIPO_CLASE']));
		}		
		return $subcomisiones;	
		
	}
		
	
}

?>
