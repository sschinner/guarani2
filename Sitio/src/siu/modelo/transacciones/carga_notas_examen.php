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

class carga_notas_examen extends transaccion
{
	protected $operacion = 'exa00033';
	protected $evento = '14';
	protected $request_cabecera; 
	
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
		return catalogo::consultar('carga_notas_examen', 'lista_actas_abiertas_docente', $parametros);
	}
	
	function info__porcentaje_carga_notas($acta, $tipo_acta)
	{
		$parametros = array('acta' => $acta,
							'tipo_acta' => $tipo_acta);
		return catalogo::consultar('carga_notas_examen', 'porcentaje_carga_notas_acta_examen', $parametros);
	}
	
	function info__acta_cabecera($seleccion)
	{
		if (!isset($this->request_cabecera)) {
			$datos = $this->get_opcion_enviada($seleccion,'info__actas_abiertas');
			$parametros = array('acta' => $datos['ACTA'],
								'tipo_acta' => $datos['TIPO_ACTA']);
			$this->request_cabecera = catalogo::consultar('carga_notas_examen', 'acta_cabecera', $parametros);
		}
		return $this->request_cabecera;
	}

	function info__acta_folio($seleccion, $folio)
	{
		$datos = $this->get_opcion_enviada($seleccion,'info__actas_abiertas');
		$cab = $this->info__acta_cabecera($seleccion);
		kernel::log()->add_debug('cab',$datos);
		// Control folio
		if(($folio < 0) || ($folio > $cab['FOLIOS'])) {
			throw new error_guarani('Folio fuera de rango');
		}
		$parametros = array('acta' => $datos['ACTA'],
							'tipo_acta' => $datos['TIPO_ACTA'],
							'folio' => $folio);
		return catalogo::consultar('carga_notas_examen', 'acta_folio', $parametros);        
	}

	function info__busqueda_alumno($acta, $term)
	{
		$datos = $this->get_opcion_enviada($acta, 'info__actas_abiertas');
		$parametros = array(
			'acta'	=> $datos['ACTA'],
			'term'	=> utf8_decode($term)
		);
		return catalogo::consultar('carga_notas_examen', 'busqueda_alumno', $parametros);
	}
	
	function info__escala_notas($escala_notas)
	{
		$parametros = array('escala_notas' => $escala_notas);		
		return catalogo::consultar('sistema', 'escala_notas', $parametros);
	}	

	function info__examenes($materia, $carrera, $legajo)
	{
		$datos['alumno'] = catalogo::consultar('carga_notas_examen', 'get_datos_ficha', array('carrera' => $carrera, 'legajo' => $legajo));
		$datos['ficha'] = catalogo::consultar('alumno', 'get_datos_ultima_cursada_materia', array('carrera' => $carrera, 'legajo' => $legajo, 'materia' => $materia));
		return $datos;
	}

	//---------------------------------------------
	//	EVENTOS
	//---------------------------------------------

	function evt__procesar_folio($seleccion, $renglones)
	{
		$acta_cab = $this->get_opcion_enviada($seleccion,'info__actas_abiertas');
		$cab = $this->info__acta_cabecera($seleccion);
		$error = new error_guarani_procesar_renglones('Error NOTAS');
		$hay_renglones_actualizados = false;
        foreach($renglones as $renglon) {
			try {
				$renglon['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
				$renglon['tipo_acta'] = $acta_cab['TIPO_ACTA'];
				$renglon['acta'] = $acta_cab['ACTA'];
				$escala_nota = $cab['ESCALA_NOTAS'];
				if ($renglon['RESULTADO'] == "")
				{
					if (!empty($renglon['NOTA']))
					{
						$parametros = array('escala_nota' => $escala_nota, 'nota' => $renglon['NOTA']);
						$renglon['RESULTADO'] = catalogo::consultar('carga_notas_examen', 'get_resultado_nota', $parametros);
					}
					else
					{
						$renglon['RESULTADO'] = "U";
						$renglon['NOTA_DESCRIPION'] = "";
						$renglon['NOTA_CONCEPTO'] = "";
					}
				}
				
				if($renglon['FECHA'] == "")
				{
					$error_nota = true;
					$error->add_renglon($renglon['RENGLON'], "Debe ingresar la fecha", $renglon);	
				}	
				elseif($renglon['RESULTADO'] == "")
				{
					$error_nota = true;
					$error->add_renglon($renglon['RENGLON'], "La nota y resultado no puede ser vacíos", $renglon);	
				}	
				else
				{
					$ok = catalogo::consultar('carga_notas_examen', 'guardar_renglon', $renglon);
					if($ok[0]==1) {
						$hay_renglones_actualizados = true;
					} else {
						$error->add_renglon($renglon['RENGLON'], $ok[1], $renglon);
						//kernel::log()->add_error(new error_guarani($ok[1]));					
					}					
				}				

			} catch (error_kernel $e) {
				$error->add_renglon($renglon['RENGLON'], $e->getMessage(), $renglon);
				//kernel::log()->add_error($e);
			}
		}
		if ($hay_renglones_actualizados){
			$parametros = array('tipo_acta' => $acta_cab['TIPO_ACTA'],
								'acta' => $acta_cab['ACTA']);
			$ok = catalogo::consultar('carga_notas_examen', 'actualizar_acta', $parametros);
			catalogo::limpiar_cache('carga_notas_examen', 'porcentaje_carga_notas_acta_examen', $parametros);
		}
		if($error->hay_renglones()) {
			throw $error;
		}
    }
}

?>