<?php
namespace siu\operaciones\inicio_docente;

use kernel\interfaz\pagelet;
use kernel\kernel;
use siu\guarani;
use siu\modelo\datos\catalogo;

class pagelet_actas extends pagelet
{
    function get_nombre()
    {
        return 'actas';
    }
	
	function get_lista_actas_examenes()
	{
		
		$modelo_examenes = guarani::carga_notas_examen();
		$actas_examenes = $modelo_examenes->info__actas_abiertas();		

		foreach ($actas_examenes as $key => $acta) {
			$actas_examenes[$key]['LINK'] = kernel::vinculador()->crear('notas_examen', 'edicion', $acta[\siu\modelo\datos\catalogo::id]);
			$actas_examenes[$key]['PORCENTAJE'] = number_format ($modelo_examenes->info__porcentaje_carga_notas($acta['ACTA'], $acta['TIPO_ACTA']), 0);
			$fecha_acta = strtotime((str_replace("/","-",$acta['DIA'])));
			switch (true) {
				case $actas_examenes[$key]['PORCENTAJE'] == 100:
					unset($actas_examenes[$key]);
					break;
				case strtotime(catalogo::fecha_actual()) < $fecha_acta:
					unset($actas_examenes[$key]);
					break;
				case strtotime(catalogo::fecha_actual() ."-1 day") == $fecha_acta:
					$actas_examenes[$key]['DIA'] = "Ayer";
					break;
				case strtotime(catalogo::fecha_actual()) == $fecha_acta:
					$actas_examenes[$key]['DIA'] = "Hoy";
					break;
				
				
			}

		}

		return $actas_examenes;
	}
	
	function get_lista_actas_cursadas()
	{
		$modelo_cursadas = guarani::carga_notas_cursada();
		$actas_cursadas = $modelo_cursadas->info__actas_abiertas();
				
		foreach ($actas_cursadas as $key => $acta) {
			$actas_cursadas[$key]['LINK'] = kernel::vinculador()->crear('notas_cursada', 'edicion', $acta[catalogo::id]);
			$actas_cursadas[$key]['PORCENTAJE'] = number_format ($modelo_cursadas->info__porcentaje_carga_notas($acta['COMISION']), 0);
		}
		return $actas_cursadas;
	}
	
    function prepare()
    {
		$this->data = array();
		$this->data['actas_examenes'] = $this->get_lista_actas_examenes();
		$this->data['actas_cursadas'] = $this->get_lista_actas_cursadas();
		/*********************************/
		$this->data['evaluaciones'] = $this->get_lista_evaluaciones();
    }
	
	
	
	/*****
	 *  esto va en el paglet de comisiones
	 * 
	 * 
	 */
	
	function get_lista_evaluaciones()
	{
		$modelo_evaluaciones = guarani::carga_evaluaciones_parciales();
		$evaluaciones = $modelo_evaluaciones->info__lista_evaluaciones();
		$fecha_actual = catalogo::fecha_actual();
		foreach ($evaluaciones as $key => $evaluacion) {
			$fecha_evaluacion = substr($evaluacion['EVALUACION_FECHA'], 0, 8);
			$horario = substr($evaluacion['EVALUACION_FECHA'], 11, 5);
			$fecha_eva_ts = strtotime((str_replace("/","-",$evaluacion['EVALUACION_FECHA'])));
		
			
			if(strtotime($fecha_actual) >= $fecha_eva_ts){
				$evaluaciones[$key]['MOSTRAR_BARRA_PORC'] = true;
			}
			switch (true) {
				case !isset($evaluaciones[$key]['EVALUACION']):
					unset($evaluaciones[$key]);
					break;
				
				case strtotime($fecha_actual."-1 month") > $fecha_eva_ts:
					unset($evaluaciones[$key]);
					break;
				
				case strtotime($fecha_actual ."-1 day") == $fecha_eva_ts:
					$evaluaciones[$key]['EVALUACION_FECHA'] = "Ayer | ".$horario;
					break;
				
				case strtotime($fecha_actual ."+1 day") == $fecha_eva_ts:
					$evaluaciones[$key]['EVALUACION_FECHA'] = "Mañana | ".$horario;
					break;
				
				case strtotime($fecha_actual) == $fecha_eva_ts:
					$evaluaciones[$key]['EVALUACION_FECHA'] = "Hoy | ".$horario;
					break;
				
		
			}
		
			
		}
		
		return $evaluaciones;
		
	}
	
	
	
}
?>
