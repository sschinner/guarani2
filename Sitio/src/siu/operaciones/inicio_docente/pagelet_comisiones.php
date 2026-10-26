<?php
namespace siu\operaciones\inicio_docente;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;
use siu\modelo\datos\catalogo;

class pagelet_comisiones extends pagelet
{
	const cant_comisiones_visibles = 5;
	
	const dias_a_mostrar_clases = 1;
	const dias_a_mostrar_evaluaciones = 1;
	
    function get_nombre()
    {
        return 'comisiones';
    }
	
	function get_lista_evaluaciones()
	{
		$modelo_evaluaciones = guarani::carga_evaluaciones_parciales();
		
		$evaluaciones = $modelo_evaluaciones->info__lista_evaluaciones();
		$fecha_actual = catalogo::fecha_actual();
		foreach ($evaluaciones as $key => $evaluacion) {
			$fecha_evaluacion =	date("d/m/Y", strtotime($evaluacion['EVALUACION_FECHA']));
			$horario = substr($evaluacion['EVALUACION_FECHA'], 11, 5);
			$horario = date("H:i", strtotime($evaluacion['EVALUACION_FECHA']));
			$evaluaciones[$key]['EVALUACION_FECHA'] = $fecha_evaluacion;
			$evaluaciones[$key]['HORARIO'] = $horario;
			$fecha_eva_ts = strtotime((str_replace("/","-",$evaluacion['EVALUACION_FECHA'])));
			$evaluaciones[$key]['TS'] = $fecha_eva_ts;
			$evaluaciones[$key]['TIPO'] = 'EVALUACION';
			if ($evaluaciones[$key]['EVALUACION_TIPO'] == 'Recuperatorio') {
				$evaluaciones[$key]['TIPO_ABREV'] = 'ER';
			} 
			if ($evaluaciones[$key]['EVALUACION_TIPO'] == 'Parcial') {
				$evaluaciones[$key]['TIPO_ABREV'] = 'EP';
			} 
			
			if(strtotime($fecha_actual) >= $fecha_eva_ts){
				$evaluaciones[$key]['MOSTRAR_BARRA_PORC'] = true;
				$evaluaciones[$key]['LINK'] = kernel::vinculador()->crear('notas_parciales', 'editar', $evaluacion[catalogo::id]);
			}
			
			switch (true) {
				case !isset($evaluacion['EVALUACION']):
					unset($evaluaciones[$key]);
					continue;
					break;
				case $evaluacion['CANT_INSCRIPTOS'] == 0 :
					unset($evaluaciones[$key]);
					continue;
					break;
				// Evaluaciones del último mes
				case strtotime($fecha_actual."-".self::dias_a_mostrar_evaluaciones." day") > $fecha_eva_ts:
					unset($evaluaciones[$key]);
					continue;
					break;
				
				case strtotime($fecha_actual ."-1 day") == $fecha_eva_ts:
					$evaluaciones[$key]['EVALUACION_FECHA'] = "Ayer";
					break;
				
				case strtotime($fecha_actual ."+1 day") == $fecha_eva_ts:
					$evaluaciones[$key]['EVALUACION_FECHA'] = "Mañana";
					break;
				
				case strtotime($fecha_actual) == $fecha_eva_ts:
					$evaluaciones[$key]['EVALUACION_FECHA'] = "Hoy";
					break;
			}
		}
		return $evaluaciones;
		
	}
	
	function get_cant_comisiones_visibles()
    {
        return self::cant_comisiones_visibles;		
    }
	
	
	function get_lista_clases()
	{
		
		$clases = guarani::carga_asistencias()->info__lista_clases();
		$fecha_actual = catalogo::fecha_actual();
		
		foreach ($clases as $key => $clase) {
			$fecha_cla_ts = strtotime((str_replace("/","-",$clase['FECHA_CLASE'])));
			$clases[$key]['TS'] = $fecha_cla_ts;
			$clases[$key]['TIPO'] = 'CLASE';
			
			$horario = $clase['HS_COMIENZO_CLASE'].'-'.$clase['HS_FINALIZ_CLASE'];
                    
			$clases[$key]['FECHA_CLASE'] = $clase['FECHA_CLASE'];
			$clases[$key]['HORARIO'] = $horario;
			if ($clases[$key]['TIPO_CLASE'] == 'Teórico/Práctico') {
				$clases[$key]['TIPO_ABREV'] = 'CTP';
			} 
			
			if ($clases[$key]['TIPO_CLASE'] == 'Práctico') {
				$clases[$key]['TIPO_ABREV'] = 'CP';
			} 
			
			if ($clases[$key]['TIPO_CLASE'] == 'Teórico') {
				$clases[$key]['TIPO_ABREV'] = 'CT';
			} 
	
			switch (true) {
				// Clases de los últimos 5 dias
				case strtotime($fecha_actual."-".self::dias_a_mostrar_clases." day") > $fecha_cla_ts:
					unset($clases[$key]);
					break;
				
				case strtotime($fecha_actual ."-1 day") == $fecha_cla_ts:
					$clases[$key]['FECHA_CLASE'] = "Ayer";
					break;
				
				case strtotime($fecha_actual ."+1 day") == $fecha_cla_ts:
					$clases[$key]['FECHA_CLASE'] = "Mañana";
					break;
				
				case strtotime($fecha_actual) == $fecha_cla_ts:
					$clases[$key]['FECHA_CLASE'] = "Hoy";
					break;
			}
		
		}
		return $clases;
	}
	
  
	
    function prepare()
    {
		$evaluaciones = $this->get_lista_evaluaciones();
		$clases = $this->get_lista_clases();
		$data = array_merge($evaluaciones, $clases);
		
		$timestamp = array();
		foreach ($data as $key => $fila) {
			$timestamp[$key] = $fila['TS'];
		}		
		array_multisort($timestamp, SORT_DESC, $data);
		$this->data['items'] = $data;
	
		$this->add_var_js('ver_mas', kernel::traductor()->trans('ver_mas'));
		$this->add_var_js('ocultar', kernel::traductor()->trans('ocultar'));
    }
}
?>
