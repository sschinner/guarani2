<?php

namespace siu\modelo\transacciones;

use kernel\kernel;
use siu\modelo\datos\catalogo;
use siu\errores\error_guarani;

class mensajes extends transaccion
{
	protected $operacion = 'mat000xxxx';
	protected $evento = '2';
	protected $opcion_mesa = array();
	protected $opcion_comision = array();

	//-------------------------------------------------------------------
	// RECIBIDOS
	//-------------------------------------------------------------------
	
	function get_cant_mensajes()
	{
		$cant = catalogo::consultar(	'mensajes', 'get_cant_mensajes',
									array(	'nro_inscripcion' => $this->nro_inscripcion ));		
		return $cant;
	}
	
	function get_mensajes_recibidos()
	{
		$mensajes_generales = catalogo::consultar(	'mensajes',
													'get_mensajes_recibidos_vigentes',
													array('nro_inscripcion'=> $this->nro_inscripcion
														 )
												);
		return $mensajes_generales;
	}
    
	function evt__leer_mensaje($url)
	{
		$mensajes = $this->get_mensajes_recibidos();
		$anuncio = $mensajes[$url]['ANUNCIO'];
		$datos = catalogo::consultar(	'mensajes',
										'leer_mensaje',
										 array(	'anuncio'=> $anuncio,
												'nro_inscripcion'=>$this->nro_inscripcion));
		return $datos;		
	}
	
	function evt__leer_mensaje_enviado($url)
	{
		$mensajes = $this->get_mensajes_enviados();
		$anuncio = $mensajes[$url]['ANUNCIO'];
		$datos = catalogo::consultar(	'mensajes',
										'leer_mensaje',
										 array(	'anuncio'=> $anuncio,
												'nro_inscripcion'=>$this->nro_inscripcion));
		return $datos;		
	}
	
	function get_datos_adjunto($url_anuncio, $url_adjunto)
	{
		$mensajes = $this->get_mensajes_recibidos();
		if(isset($mensajes[$url_anuncio]['ADJUNTOS'][$url_adjunto])) {
			return $mensajes[$url_anuncio]['ADJUNTOS'][$url_adjunto];
		} else {
			throw new error_guarani('MENSAJES: No existe el adjunto solicitado');
		}
	}
	
	//-------------------------------------------------------------------
	// DOCENTE: ENVIADOS
	//-------------------------------------------------------------------
	
	function get_mesas_y_comisiones()
	{
		$datos['comisiones'] = catalogo::consultar(	'docente',
											'lista_comisiones',
											array('nro_inscripcion'=> $this->nro_inscripcion)
										);
		
		$datos['mesas'] = catalogo::consultar(	'docente',
									'lista_mesas',
								    array('nro_inscripcion'=> $this->nro_inscripcion)
									);

		$nuevo = array();
        foreach($datos['comisiones'] as $key => $dato) {
            if ($dato['CANTIDAD_INSCR'] > 0){
				$dato['ALUMNOS'] = catalogo::consultar(	'docente',
											'alum_inscriptos_comision',
											array('comision'=> $dato['COMISION'])
										);
				
				foreach($dato['ALUMNOS'] as &$alumno)
				{
					$alumno['NRO_INSCRIPCION']= catalogo::consultar(	'alumno',
																	'get_nro_inscripcion',
																	array('carrera'=> $alumno['CARRERA_COD'], 'legajo'=> $alumno['LEGAJO'])
																);
				};
				$dato['DOCENTES'] = catalogo::consultar(	'comisiones',
											'get_docentes_comision',
											array('comision'=> $dato['COMISION'])
										);
                $nuevo['comisiones'][$key] = $dato;
            }            
		}
        
        foreach($datos['mesas'] as $key => $dato) {
            if ($dato['CANTIDAD_INSCR'] > 0){
				$dato['ALUMNOS'] = catalogo::consultar(	'docente',
											'alum_inscriptos_examen',
											array(	'materia'		=>	$dato['MATERIA'], 
													'anio_academico'=>	$dato['ANIO_ACADEMICO'], 
													'turno_examen'	=>	$dato['TURNO_EXAMEN'], 
													'mesa_examen'	=>	$dato['MESA_EXAMEN'], 
													'llamado'		=>	$dato['LLAMADO'])
										);
				foreach($dato['ALUMNOS'] as &$alumno)
				{
					$alumno['NRO_INSCRIPCION']= catalogo::consultar(	'alumno',
																	'get_nro_inscripcion',
																	array('carrera'=> $alumno['CARRERA'], 'legajo'=> $alumno['LEGAJO'])
																);
				};
				
				$dato['DOCENTES'] = catalogo::consultar(	'mesa_examen',
											'get_docentes_mesa_examen',
											array(	'materia'		=>	$dato['MATERIA'], 
													'anio_academico'=>	$dato['ANIO_ACADEMICO'], 
													'turno_examen'	=>	$dato['TURNO_EXAMEN'], 
													'mesa_examen'	=>	$dato['MESA_EXAMEN'], 
													'llamado'		=>	$dato['LLAMADO'])
										);				
                $nuevo['mesas'][$key] = $dato;
            }            
		}
        
		return $nuevo;		
	}
	
	function get_curso_mesa($url_mesa)
	{
		$mesa = $this->get_opcion_enviada_mesa($url_mesa);
		if (isset($mesa)){
			$resultado = catalogo::consultar(	'mensajes',
							'get_curso_mesa',
							array(	'materia'		=> $mesa['MATERIA'],
									'anio_academico'=> $mesa['ANIO_ACADEMICO'],
									'turno_examen'	=> $mesa['TURNO_EXAMEN'],
									'mesa_examen'	=> $mesa['MESA_EXAMEN'],
									'llamado'		=> $mesa['LLAMADO'],
							));
			if (isset($resultado)){
				return $resultado[0]['CURSO'];
			} else {
				throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe la comision');				
			}
		}
		return false;
	}
		
	protected function get_opcion_enviada_mesa($url_mesa)
	{
		if (!isset($this->opcion_mesa[$url_mesa])) {
			$resultado = null;
			$mesas_comisiones = $this->get_mesas_y_comisiones();
			
			foreach($mesas_comisiones['mesas'] as $mesa) {
				if($mesa[catalogo::id] == $url_mesa){
					return $mesa;
				}
			}
			if(!isset($resultado)){
				throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe la mesa');
			}
			return false;
		}
		return false;
	}
	
	function get_curso_comision($url_comision)
	{
		$comision = $this->get_opcion_enviada_comision($url_comision);
		if (isset($comision)){
			$resultado = catalogo::consultar(	'mensajes',
											'get_curso_comision',
											array(	'comision'		=> $comision
													));
			
			if (isset($resultado)){
				return $resultado[0]['CURSO'];
			} else {
				throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe la comision');				
			}
		}
		return false;
	}

	protected function get_opcion_enviada_comision($url_comision)
	{
		if (!isset($this->opcion_comision[$url_comision])) {
			$resultado = null;
			$mesas_comisiones = $this->get_mesas_y_comisiones();
			
			foreach($mesas_comisiones['comisiones'] as $comision) {
				if($comision[catalogo::id] == $url_comision){
					return $comision['COMISION'];
				}
			}
			if(!isset($resultado)){
				throw new error_guarani_seguridad('OPCIONES ENVIADAS: No existe la comision');
			}			
			return false;
		}		
		return false;
	}
	
	function get_mensajes_enviados()
	{
		$datos = catalogo::consultar('mensajes',
									'get_mensajes_enviados',
									array('legajo'=> kernel::persona()->get_legajo_docente()));
		return $datos;
	}
	
	function evt__guardar_mensaje($tipo_anuncio, $curso, $fecha_desde, $fecha_hasta, 
									$titulo, $enviar_por_mail, $enviar_por_sms, $mensaje,
									$archivos=array(), $todos_algunos, $destinatarios)
	{
		kernel::db()->abrir_transaccion();	
		$resultado = catalogo::consultar(	'mensajes',
										'guardar_mensaje',
										 array(	'tipo_anuncio'		=> $tipo_anuncio,
												'curso'				=> $curso,
												'fecha_desde'		=> $fecha_desde,
												'fecha_hasta'		=> $fecha_hasta,
												'titulo_anuncio'	=> $titulo,
												'enviado_por_mail'	=> $enviar_por_mail,
											 	'enviado_por_sms'	=> $enviar_por_sms,
												'int_gestion'		=> 'S',
												'int_autogestion'	=> 'S',
												'int_telefono'		=> 'N',
												'int_internet'		=> 'S',
												'mensaje'			=> $mensaje,
												'legajo'			=> kernel::persona()->get_legajo_docente(),
												'todos_algunos'		=> $todos_algunos,
												));
		kernel::log()->add_debug('MENSAJES resultado', $resultado);
		if($resultado[0]<0) {
			$msg = catalogo::consultar('sistema', 'mensaje',array('mensaje'=>$resultado[1]));
			kernel::db()->abortar_transaccion();
			throw new error_guarani($msg[0]);
		} else {
			$id_mensaje = $resultado[0];
			foreach($archivos as $archivo) {
				$adjunto = catalogo::consultar(	'mensajes',	'guardar_attachment',
										array(	'mensaje'=> $id_mensaje,
												'nombre_original' => $archivo['nombre_original'],
												'nombre_fs' => $archivo['nombre_fs']));
				if($adjunto[0]<0) {
					$msg = catalogo::consultar('sistema', 'mensaje',array('mensaje'=>$adjunto[1]));
					kernel::db()->abortar_transaccion();
					throw new error_guarani($msg[0]);
				}
			}

			//si se envía a algunos docentes o algunos alumnos, insertar en tabla gda_anuncios_log 
			//guardar_destinatarios
				if($todos_algunos == 'A' and !empty($destinatarios))
				{
					foreach($destinatarios as $destinatario)
					{
						$rta = catalogo::consultar(	'mensajes',	'guardar_destinatarios',
										array(	'anuncio'=> $id_mensaje,
												'nro_inscripcion' => $destinatario));
					};
					
				}
            kernel::db()->cerrar_transaccion();
            return $id_mensaje;
		}
	}

}

?>
