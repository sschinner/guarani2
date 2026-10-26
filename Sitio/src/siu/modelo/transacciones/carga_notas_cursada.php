<?php
namespace siu\modelo\transacciones;

use kernel\kernel;
use kernel\error_kernel;
use siu\guarani;
use siu\errores\error_guarani;
use siu\modelo\controles\controles;
use siu\modelo\datos\estrategias;
use siu\modelo\datos\catalogo;
use siu\errores\error_guarani_procesar_renglones;

class carga_notas_cursada extends transaccion
{
	protected $operacion = 'cur00021';
	protected $evento = '14';
	protected $cache_request_acta_cabecera = array();

	function iniciar()
	{
		//parent::iniciar();
	}
	
	//---------------------------------------------
	//	INFO
	//---------------------------------------------
	
	function info__actas_abiertas()
	{
		$parametros = array('nro_inscripcion' => $this->nro_inscripcion);
		return catalogo::consultar('carga_notas_cursada', 'lista_actas_abiertas_docente', $parametros);
	}
	
	function info__porcentaje_carga_notas($comision)
	{
		$parametros = array();
		$parametros['comision'] = $comision;
		return catalogo::consultar('carga_notas_cursada', 'porcentaje_carga_notas_comision', $parametros);
	}
	
	function info__acta_cabecera($seleccion)
	{
		//if (isset($this->cache_request_acta_cabecera[$seleccion])) {
			$datos = $this->get_opcion_enviada($seleccion,'info__actas_abiertas');
			$parametros = array('acta' => $datos['ACTA_REG']);		
			//$this->cache_request_acta_cabecera[$seleccion] = catalogo::consultar('carga_notas_cursada', 'acta_cabecera', $parametros);
			return catalogo::consultar('carga_notas_cursada', 'acta_cabecera', $parametros);
		//}
		//return $this->cache_request_acta_cabecera[$seleccion];
	}

	function info__acta_folio($seleccion, $folio)
	{
		$datos = $this->get_opcion_enviada($seleccion,'info__actas_abiertas');
		$parametros = array('acta' => $datos['ACTA_REG'],
							'folio' => $folio);
		return catalogo::consultar('carga_notas_cursada', 'acta_folio', $parametros);
	}

	function info__escala_notas($escala_notas)
	{
		$parametros = array('escala_notas' => $escala_notas);		
		return catalogo::consultar('sistema', 'escala_notas', $parametros);
	}

	function info__condiciones()
	{
		return catalogo::consultar('carga_notas_cursada', 'condiciones_regularidad');
	}

	function info__busqueda_alumno($seleccion, $term)
	{
		$datos = $this->get_opcion_enviada($seleccion,'info__actas_abiertas');
        
		$parametros = array(
			'comision'	=> $datos['COMISION'],
			'term'		=> utf8_decode($term)
		);
		return catalogo::consultar('carga_notas_cursada', 'busqueda_alumno', $parametros);
	}
	
	function info__parciales($carrera, $legajo, $comision)
	{
		$parametros = array(
			'comision'	=> $comision,
			'carrera'		=> $carrera,
			'legajo'		=> $legajo
		);
		$datos['parciales'] =  catalogo::consultar('carga_notas_cursada', 'get_datos_parciales', $parametros);
		$parametros = array(
			'carrera'		=> $carrera,
			'legajo'		=> $legajo
		);
		$datos['alumno'] = catalogo::consultar('carga_notas_cursada', 'get_datos_ficha', $parametros);
		return $datos;
	}
	
	//---------------------------------------------
	//	EVENTOS
	//---------------------------------------------

	function evt__procesar_folio($seleccion, $renglones, $param_sistema)
	{
		$acta_cab = $this->info__acta_cabecera($seleccion);
		$error = new error_guarani_procesar_renglones('Error cargando notas');
		$error_acta = new \siu\errores\error_guarani_acta_cursada_cerrada('Error cargando notas - Acta no disponible');
		
		//array('asentar_notas_actas_regulares' => $asentar_notas_actas_regulares, 'cierre_parcial' => $cierre_parcial)
		//		N = No Obligatoria, O = Obligatoria, S = Sin Notas
		if ($this->acta_regular_activa($seleccion)) {
			$hay_renglones_actualizados = false;
			
			foreach($renglones as $renglon) {
				try {
					$renglon['NRO_INSCRIPCION_DOCENTE'] = kernel::persona()->get_nro_inscripcion();
					$renglon['FECHA_INICIO'] = $acta_cab['FECHA_INICIO'];
					$renglon['COMISION'] = $acta_cab['COMISION'];
					
					if(!empty($renglon['CONDICION']))
					{
						$parametros = array('condicion' => $renglon['CONDICION']);
						$resultado = catalogo::consultar('carga_notas_cursada', 'get_resultado_condicion', $parametros);
					}
					else
					{
						$resultado = "";
					}

					//	validacion sobre el renglon
					//	$param_sistema = array('asentar_notas_actas_regulares', 'cierre_parcial')
					$error_nota = false;
					
					if ($param_sistema['cierre_parcial']){ //Si está en cierre parcial
					
						if ($resultado == "P" && $renglon['PROMOCIONAL'] == "S"){ //CONTROLO PARÁMETRO cargar_notas_promocion PARA ALMUNOS PROMOCIONALES
							if ($renglon['CONDICION'] != "" && $renglon['FECHA'] != "" ){
								switch($param_sistema['cargar_notas_promocion']){
									case "O":
										if (empty($renglon['NOTA'])){
											$error_nota = true;										
											$error->add_renglon($renglon['RENGLON'], "Debe ingresar la nota de la promoción", $renglon);
										}
										break;
								}
							} else {
								$error_nota = true;
								$error->add_renglon($renglon['RENGLON'], "Debe ingresar la condición de regularidad y la fecha", $renglon);
							}
						}
					
					//Obligo a cargar todos los datos del alumno  
						if ($renglon['CONDICION'] != "" && $renglon['FECHA'] != ""){
							switch($param_sistema['asentar_notas_actas_regulares']){
								case "O":
									if (empty($renglon['NOTA']) && ($resultado != "U") ){
										$error_nota = true;										
										$error->add_renglon($renglon['RENGLON'], "Debe ingresar la nota de la regularidad", $renglon);
									}
									break;
								case "S":
									if($renglon['PROMOCIONAL'] == "S" && $param_sistema['cargar_notas_promocion'] == 'O')
									{
										$renglon['NOTA'] = $renglon['NOTA'];
									}
									else
									{
										$renglon['NOTA'] = "";
									}
									break;
							}
						} else {
							if ($renglon['CONDICION'] == "" && $renglon['FECHA'] == "" && $renglon['ASISTENCIA'] == "" && $renglon['NOTA'] == "")
							{
								$renglon['RESULTADO'] = "";
							}
							else
							{
								$error_nota = true;
								$error->add_renglon($renglon['RENGLON'], "Debe ingresar la condición de regularidad y la fecha", $renglon);								
							}
						}
					}

					if (!$error_nota){
						$ok = catalogo::consultar('carga_notas_cursada', 'guardar_renglon', $renglon);						
						if($ok[0]==1) {
							$hay_renglones_actualizados = true;
						} else {
							$error->add_renglon($renglon['RENGLON'], $ok[1], $renglon);
						}
					}
				} catch (error_kernel $e) {					
					$error->add_renglon($renglon['RENGLON'], $e->getMessage(), $renglon);
					//kernel::log()->add_error($e);
				}
			}
			if ($hay_renglones_actualizados){
				$parametros = array('comision' => $acta_cab['COMISION']);
				$ok = catalogo::consultar('carga_notas_cursada', 'actualizar_acta', $parametros);
				catalogo::limpiar_cache('carga_notas_cursada', 'porcentaje_carga_notas_comision', $parametros);
			}
			if($error->hay_renglones()) {
				throw $error;
			}			
		} else {
			throw $error_acta;
		}
    }
	
	function acta_regular_activa($acta){
		$datos = $this->get_opcion_enviada($acta,'info__actas_abiertas');
		$parametros = array('acta' => $datos['ACTA_REG']);
		
		$estado = catalogo::consultar('carga_notas_cursada', 'acta_regular_estado', $parametros);
		if ($estado){
			return true;
		}
		return false;
	}
	
}

?>