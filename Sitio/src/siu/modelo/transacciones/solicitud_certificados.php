<?php
namespace siu\modelo\transacciones;

use kernel\kernel;
use siu\guarani;
use siu\errores\error_guarani;
use siu\modelo\datos\catalogo;
use siu\errores\error_guarani_usuario;
use siu\modelo\datos\util;

class solicitud_certificados extends transaccion
{
	protected $operacion = 'agcert01';
	protected $carrera;
	protected $legajo;
	protected $evento = '24';
	protected $estrategia_acceso_datos;

	function __construct($nro_inscripcion, $carrera, $legajo) 
	{
		$this->nro_inscripcion = $nro_inscripcion;	
		$this->carrera = $carrera;
		$this->legajo = $legajo;
		parent::__construct($nro_inscripcion);
	}	
	//---------------------------------------------
	//	INFO
	//---------------------------------------------

	function lista_certificados()
	{
		$parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        $datos = catalogo::consultar('certificados', 'certificados_habilitados', $parametros);
		
		if (!empty($datos)){
			$nuevo = array();
			foreach ($datos as $dato){
				if ($dato[4] == "A"){
					$nuevo[$dato[0]]['nombre'] = $dato[1];
					$nuevo[$dato[0]]['solicitud_pendiente'] = $dato[3];
					$nuevo[$dato[0]]['maximo_copias'] = $dato[2];					
					$nuevo[$dato[0]]['generacion_web'] = $dato[5];	//Manual/OnLine				
					$nuevo[$dato[0]]['vigencia'] = $dato[6];					
				}
			}
			return $nuevo;			
		} else {
			return false;
		}
	}
	
	function argumentos_certificado($nro_certificado = null)
	{
		if (!empty($nro_certificado))
		{
			$parametros['nro_certificado'] = $nro_certificado;
			$datos = catalogo::consultar('certificados', 'certificados_argumentos', $parametros);
						
			$cetificados_datos = $this->lista_certificados();

			if (isset($cetificados_datos[$nro_certificado])){				
				$resultado = array();
				$resultado['id'] = $nro_certificado;
				$resultado['nombre'] = $cetificados_datos[$nro_certificado]['nombre'];
				$resultado['solicitud_pendiente'] = $cetificados_datos[$nro_certificado]['solicitud_pendiente'];
				$resultado['maximo_copias'] = $cetificados_datos[$nro_certificado]['maximo_copias'];
				$resultado['generacion_web'] = $cetificados_datos[$nro_certificado]['generacion_web'];
				$resultado['vigencia'] = $cetificados_datos[$nro_certificado]['vigencia'];

				foreach ($datos as $clave => $valor) {
					switch ($valor[1]){
						case "unidad_academica":
							$ua_id = \siu\guarani::get_ua_id();
							$valor[3] = $ua_id;
							$ua = new \siu\modelo\entidades\unidad_academica($ua_id);
							$valor['nombre'] = "(".$ua_id.") ".$ua->get_nombre();
							break;
						case "carrera":
							$carrera_activa = kernel::persona()->get_info_carrera_activa();
							$valor['nombre'] = $carrera_activa['nombre'];
							$valor[3] = $carrera_activa['id'];
							break;
						case "legajo":
							$valor[3] = kernel::persona()->get_id_legajo_activo();
							break;
						case "nro_inscripcion":
							$valor[3] = kernel::persona()->get_nro_inscripcion();
							break;
						case "periodo_inscripcio":
							$valor[3] = kernel::persona()->get_periodo_inscripcion_activo();
							break;
					}
					$resultado['argumentos'][$clave] = $valor;
				}
				kernel::log()->add_debug('argumentos', $resultado);
				return $resultado;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}
	
	
	function invalidar_cache()
	{
		$parametros = array();
		$parametros['nro_inscripcion'] = kernel::persona()->get_nro_inscripcion();
        catalogo::limpiar_cache('certificados', 'certificados_habilitados', $parametros);
	}
	
	
	function validar_solicitud($certificado, $cantidad_copias)
	{
		$certificados = $this->lista_certificados();
		if (!isset($certificados[$certificado])) {
			throw new error_guarani_usuario(kernel::traductor()->trans('solicitud_certificado.mensaje_error_elegir'));
		} else {
			$datos_certificado = $certificados[$certificado];
			if ($cantidad_copias < 1 || $cantidad_copias > $datos_certificado['maximo_copias']  ) {
				throw new error_guarani_usuario(kernel::traductor()->trans('solicitud_certificado.mensaje_error_cantidad'));
			}
		}
		
	}
		
	//---------------------------------------------
	//	EVENTOS
	//---------------------------------------------

	function evt__solicitar($certificado, $cantidad_copias, $argumentos)
	{
		
		//$this->validar_solicitud($certificado, $cantidad_copias);
		//$this->control__solicitud_certificado($certificado);
	
		$nro_inscripcion = guarani::persona()->get_nro_inscripcion();
		kernel::db()->abrir_transaccion();
		
		$ok = catalogo::consultar('certificados', 'certificados_solicitar',
							array(		'certificado' => $certificado,
										'nro_inscripcion' => $nro_inscripcion,
										'cantidad_copias' => $cantidad_copias
								 ));

		$int_status	= -1;
		$strTrans	= "";
		$strMsg		= "";
		
		if (!empty($ok)){
			$int_status	= $ok[0];
			$strTrans	= $ok[1];
			$strMsg		= $ok[2];
		}
		if(($int_status>0)) {
				try {
					$this->guardar_filas($certificado, $int_status, $argumentos);
					kernel::db()->cerrar_transaccion();
				} catch (\Exception $e) {
					kernel::log()->add_debug('Error solicitud', $e);
					kernel::db()->abortar_transaccion();
					throw $e;
				}		
		} else {
			kernel::db()->abortar_transaccion();
			$mensaje = util::mensaje($strTrans);
			throw new error_guarani_usuario($mensaje);
		}		
	}

	protected function guardar_filas($nro_cert, $key_cert, $args_post)
	{
		$args_original = $this->argumentos_certificado($nro_cert);
		$params = array('indice_certificado' => $key_cert);
		foreach ($args_original['argumentos'] as $arg) {
			
			$params['orden'] = $arg[0];
			$tipo  = $arg[2];
			if ($arg[4] == 'S') { // es editable
				$params['valor'] = $args_post[$params['orden']];
				// validacion?   case "char": $valor = "'" . DuplicarComillasSimples($val) . "'"; break;
			} else {
				$params['valor'] = $arg[3];
			}
			unset($tipo);
				
			catalogo::consultar('certificados', 'guardar_argumentos', $params);
		}
	}
	
	//---------------------------------------------

	function control__inicial()
	{
		$proceso = $this->nuevo_proceso_control();
		//(Persona - Operación) - Una Persona elige una operación
		$proceso->agregar_punto(2, array('nro_inscripcion' => $this->nro_inscripcion,
											'operacion' => $this->operacion));
		//(Alumno - Operación) - Un Alumno elige una operación
		$proceso->agregar_punto(3, array(	'carrera' => $this->carrera,
											'legajo' => $this->legajo,
											'operacion' => $this->operacion));
		return $proceso->ejecutar();
	}	

	function control__seleccion_certificado($certificado)
	{
		$proceso = $this->nuevo_proceso_control();
		$proceso->agregar_punto(25, array(	'nro_inscripcion' => $this->nro_inscripcion,
											'certificado' => $certificado));
		return $proceso->ejecutar();
	}

	function control__solicitud_certificado($certificado)
	{
		$proceso = $this->nuevo_proceso_control();
		$proceso->agregar_punto(26, array(	'carrera' => $this->carrera,
											'legajo' => $this->legajo,
											'certificado' => $certificado));
		return $proceso->ejecutar();
	}
	
}
?>