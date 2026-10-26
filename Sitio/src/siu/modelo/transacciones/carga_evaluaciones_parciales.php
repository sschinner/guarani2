<?php
namespace siu\modelo\transacciones;

use kernel\kernel;
use kernel\error_kernel;
use siu\guarani;
use siu\modelo\controles\controles;
use siu\modelo\datos\catalogo;
use siu\errores\error_guarani_procesar_renglones;
use siu\errores\error_guarani;
use siu\modelo\datos\util;

class carga_evaluaciones_parciales extends transaccion
{
	protected $operacion = 'cur00021';
	protected $evento = '14';
	protected $opciones_enviadas;
	
	//---------------------------------------------
	//	Manejo OPCIONES
	//---------------------------------------------	

	protected function get_comision_enviada($seleccion)
	{
		if (!isset($this->opciones_enviadas)) {
			$this->opciones_enviadas = $this->info__lista_evaluaciones();
		}
		foreach($this->opciones_enviadas as $opcion) {
			if($opcion['COMISION_URL'] == $seleccion){
				return $opcion['COMISION'];
			}
		}
		throw new error_guarani('COMISION invalida');
	}		
	
	protected function get_evaluacion_enviada($seleccion)
	{
		if (!isset($this->opciones_enviadas)) {
			$this->opciones_enviadas = $this->info__lista_evaluaciones();
		}
		foreach($this->opciones_enviadas as $opcion) {
			if(isset($opcion[catalogo::id]) && $opcion[catalogo::id] == $seleccion){
				return $opcion;
			}
		}
		throw new error_guarani('EVALUACION invalida');		
	}		

	//---------------------------------------------
	//	LISTA EVALUACIONES
	//---------------------------------------------
    
	function info__lista_evaluaciones()
	{
		$parametros = array('legajo' => kernel::persona()->get_legajo_docente());
		return catalogo::consultar('carga_evaluaciones_parciales', 'listado_evaluaciones_parciales', $parametros);
	}

	//---------------------------------------------
	//	ABM EVALUACION
	//---------------------------------------------	

	function info__lista_escala_notas()
	{
		return catalogo::consultar('carga_evaluaciones_parciales', 'listado_escala_notas',null);
	}
	
	function info__tipo_evaluacion()
	{
		return catalogo::consultar('carga_evaluaciones_parciales', 'listado_tipo_evaluacion',null);
	}

	/**
	 * @param type $comision
	 * @param type $tipo_evaluacion
	 * @param type $escala_notas
	 * @param string $fecha AAAA-MM-DD
	 * @param type $hora 
	 */
	function alta_evaluacion_parcial($seleccion_comision, $evaluacion, $escala_notas, $fecha, $hora)
	{
		// Control derechos
		$fecha_hora = "$fecha $hora"; //'2012-04-11 02:00:00'
		$parametros = array();
		$parametros['comision'] = $this->get_comision_enviada($seleccion_comision);
		$parametros['evaluacion'] = $evaluacion;
		$parametros['escala_notas'] = $escala_notas;
		$parametros['fecha_hora'] = $fecha_hora;
		$msg = catalogo::consultar('carga_evaluaciones_parciales', 'alta_evaluacion_parcial', $parametros);
		$this->invalidar_listado_evaluaciones();
		return $msg;
	}
	
	/**
	 * @param type $comision
	 * @param type $tipo_evaluacion
	 */
	function baja_evaluacion_parcial($seleccion)
	{
		//@todo: Control derechos!
		$datos_eval = $this->get_evaluacion_enviada($seleccion);
		$parametros = array();
		$parametros['comision'] = $datos_eval['COMISION'];
		$parametros['evaluacion'] = $datos_eval['EVALUACION'];
		catalogo::consultar('carga_evaluaciones_parciales', 'baja_evaluacion_parcial',$parametros);
		$this->invalidar_listado_evaluaciones();
	}
	
	function invalidar_listado_evaluaciones()
	{
		$parametros2 = array('legajo' => kernel::persona()->get_legajo_docente());
		return catalogo::limpiar_cache('carga_evaluaciones_parciales', 'listado_evaluaciones_parciales', $parametros2);
	}
	
	//---------------------------------------------
	//	CARGA NOTAS
	//---------------------------------------------	
	
	function info__escala_notas($escala_notas)
	{
		$parametros = array('escala_notas' => $escala_notas);
		//return catalogo::consultar('carga_evaluaciones_parciales', 'escala_notas', $parametros);
		return catalogo::consultar('sistema', 'escala_notas', $parametros);
	}	
	
	function info__evaluacion_cabecera($seleccion)
	{
		// Control derechos
		$parametros = array();
		$datos_eval = $this->get_evaluacion_enviada($seleccion);
		$parametros['comision'] = $datos_eval['COMISION'];
		$parametros['evaluacion'] = $datos_eval['EVALUACION'];
		return catalogo::consultar('carga_evaluaciones_parciales', 'evaluacion_cabecera',$parametros);
	}	

	function info__evaluacion_detalle($seleccion)
	{
		// Control derechos
		$parametros = array();
		$datos_eval = $this->get_evaluacion_enviada($seleccion);
		$parametros['comision'] = $datos_eval['COMISION'];
		$parametros['evaluacion'] = $datos_eval['EVALUACION'];
		return catalogo::consultar('carga_evaluaciones_parciales', 'evaluacion_detalle',$parametros);
	}

	function evt__procesar_evaluaciones($seleccion, $renglones)
	{
		$datos = $this->info__evaluacion_cabecera($seleccion);		
		$error = new error_guarani_procesar_renglones('Error cargando notas');
		
        foreach($renglones as $k=>$renglon) {
			try {
				$renglon['CARRERA'] = $renglon['CARRERA'];
				$renglon['LEGAJO'] = $renglon['LEGAJO'];
				$renglon['COMISION'] = $datos['COMISION'];
				$renglon['EVALUACION'] = $datos['EVALUACION'];
				$renglon['FECHA_HORA'] = $datos['FECHA_HORA'];
				$renglon['ESCALA_NOTAS'] = $datos['ESCALA_NOTAS'];				
				
//				kernel::log()->add_debug('renglon '.$k,$renglon);
				$ok = catalogo::consultar('carga_evaluaciones_parciales', 'guardar_renglon', $renglon);
				if($ok[0]!=1) {
					$error->add_renglon($renglon['RENGLON'], util::mensaje($ok[1]), $renglon);
					kernel::log()->add_debug("RENG_ERROR", $ok);
					kernel::log()->add_error(new error_guarani($ok[1]));	
				}
			} catch (error_kernel $e) {
				$error->add_renglon($renglon['RENGLON'], $e->getMessage(), $renglon);
				kernel::log()->add_error($e);
			}
		}
		if($error->hay_renglones()) {
			throw $error;
		}
    }
}

?>