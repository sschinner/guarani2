<?php
namespace siu\modelo\datos\db;
use siu\modelo\datos\catalogo;
use siu\modelo\datos\util;
use siu\errores\error_guarani;
use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\entidades\alumno_foto;

class carga_evaluaciones_parciales
{
	/**
	 * parametros: _ua, legajo
	 * cache: no
	 * cache_expiracion: 3600
	 * filas: n
	 */
    function listado_evaluaciones_parciales($parametros)
    {
		$sql = "SELECT
			sga_comisiones.materia,
			sga_materias.nombre as materia_nombre,
			sga_comisiones.comision,
			sga_comisiones.nombre as comision_nombre,
			sga_comisiones.anio_academico,
			sga_comisiones.periodo_lectivo,
			sga_comisiones.catedra,
			DECODE(sga_comisiones.turno,'T', 'Tarde', 'N', 'Noche', 'M', 'Mañana', 'No informa') as turno,
			sga_sedes.sede,
			sga_sedes.nombre as sede_nombre,
			(SELECT COUNT(*) FROM sga_insc_cursadas WHERE comision = sga_comisiones.comision AND estado in ('A','P','E')) as cant_inscriptos,
			CASE 
			   WHEN (sga_eval_parc.evaluacion_origen IS NOT NULL AND sga_eval_parc.evaluacion <> sga_eval_parc.evaluacion_origen) THEN
			        ((SELECT COUNT(*) FROM sga_insc_cursadas WHERE comision = sga_comisiones.comision AND estado in ('A','P','E')) -
			         (SELECT COUNT(*) FROM sga_eval_parc_alum as origen 
			           WHERE origen.comision = sga_comisiones.comision 
			             AND origen.evaluacion = sga_eval_parc.evaluacion_origen
			             AND origen.resultado = 'A')
			         )
			   ELSE (SELECT COUNT(*) FROM sga_insc_cursadas WHERE comision = sga_comisiones.comision AND estado in ('A','P','E')) 
			END as cant_inscriptos_barra,
			(SELECT COUNT(*)  
			   FROM sga_eval_parc_alum as a
			  INNER JOIN sga_insc_cursadas b ON a.unidad_academica = b.unidad_academica AND a.carrera = b.carrera AND a.legajo = b.legajo AND a.comision = b.comision
			  WHERE a.comision = sga_atr_eval_parc.comision 
			    AND a.evaluacion = sga_atr_eval_parc.evaluacion 
			    AND a.nota IS NOT NULL) as cant_con_notas,
			(SELECT COUNT(*)  FROM sga_eval_parc_alum as a 
			  WHERE a.comision = sga_atr_eval_parc.comision 
			    AND a.evaluacion = sga_atr_eval_parc.evaluacion) as total_alumnos_eval,
			sga_atr_eval_parc.evaluacion,
			sga_eval_parc.evaluacion as evaluacion_cod_tipo,
			sga_eval_parc.descripcion as evaluacion_nombre,
			sga_tipo_eval_parc.descripcion as evaluacion_tipo,
			sga_cron_eval_parc.fecha_hora as evaluacion_fecha,
			sga_periodos_lect.anio_academico,
			sga_periodos_lect.fecha_inicio
		FROM 
			sga_docentes_com,
			sga_comisiones,
			sga_periodos_lect,
			sga_materias,
			sga_sedes,
			OUTER (sga_atr_eval_parc,
				sga_eval_parc,
				sga_tipo_eval_parc,
				sga_cron_eval_parc)
			WHERE sga_docentes_com.legajo =  {$parametros['legajo']}
			--AND sga_materias.unidad_academica = {$parametros['_ua']}
			AND sga_comisiones.comision = sga_docentes_com.comision
			AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
			AND sga_materias.materia = sga_comisiones.materia
			AND sga_periodos_lect.anio_academico = sga_comisiones.anio_academico
			AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo
			AND sga_periodos_lect.fecha_inactivacion >= TODAY
			AND sga_comisiones.sede = sga_sedes.sede
			AND sga_atr_eval_parc.comision = sga_comisiones.comision
			AND sga_eval_parc.evaluacion   = sga_atr_eval_parc.evaluacion
			AND sga_tipo_eval_parc.tipo_evaluac_parc = sga_eval_parc.tipo_evaluac_parc
			AND sga_cron_eval_parc.evaluacion = sga_eval_parc.evaluacion
			AND sga_cron_eval_parc.comision   = sga_atr_eval_parc.comision

			-- No mostrar comisiones con actas de cursadas cerradas
			-- AND NOT EXISTS  (SELECT 1 FROM sga_actas_cursado	WHERE comision = sga_comisiones.comision AND estado = 'C')

			ORDER BY sga_periodos_lect.anio_academico,
					sga_periodos_lect.fecha_inicio,
					sga_materias.nombre,
					sga_comisiones.nombre,
			        sga_cron_eval_parc.fecha_hora,
					sga_atr_eval_parc.evaluacion ";
					
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		foreach(array_keys($datos) as $id) {
			//$datos[$id]['__ID__'] = catalogo::generar_id($datos[$id]['COMISION']);
			$datos[$id]['COMISION_URL'] = catalogo::generar_id($datos[$id]['COMISION']);
			if (isset($datos[$id]['EVALUACION'])){
				$id_url = catalogo::generar_id($datos[$id]['COMISION'].$datos[$id]['EVALUACION']);
				$datos[$id][catalogo::id] = $id_url;
			} else {
				$datos[$id][catalogo::id] = '';
			}
			
			if ($datos[$id]['CANT_INSCRIPTOS_BARRA'] != 0){
				$porc = $datos[$id]['CANT_CON_NOTAS'] / $datos[$id]['CANT_INSCRIPTOS_BARRA'] * 100;
                                                                        if ($porc > 100){
                                                                            $datos[$id]['PORCENTAJE_CARGA'] = 100;
                                                                        } else {
                                                                            $datos[$id]['PORCENTAJE_CARGA'] = number_format ( $porc, 0);
                                                                        }
                                                                        unset($porc);
			} else {
				$datos[$id]['PORCENTAJE_CARGA'] = 0;
			}
			
		}
		return $datos;
    }

	/**
	 * parametros: 
	 * cache: memoria
	 * filas: n
	 */
    function listado_escala_notas($parametros)
    {
        $sql = "SELECT escala_notas, nombre FROM sga_escala_notas WHERE estado='A'";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;  
	}
    
	/**
	 * parametros: 
	 * cache: memoria
	 * filas: n
	 */
    function listado_tipo_evaluacion($parametros=null)
    {
        $sql = "SELECT evaluacion, descripcion_abrev FROM sga_eval_parc ORDER BY 1";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos;  
	}
	
	/**
	 * parametros: comision, evaluacion, escala_notas, fecha_hora
	 * cache: no
	 * filas: n
	 */
    function alta_evaluacion_parcial($parametros)
    {
        //$sql = "execute procedure sp_i_atrcroevalpar(12699,1,1,'2012-04-11 02:00:00)";
        $sql = "execute procedure sp_i_atrcroevalpar(	{$parametros['comision']},
														{$parametros['evaluacion']},
														{$parametros['escala_notas']},
														{$parametros['fecha_hora']})";
		//kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return util::ejecutar_procedure($sql);
	}
    
	/**
	 * parametros: comision, evaluacion
	 * cache: no
	 * filas: n
	 */
    function baja_evaluacion_parcial($parametros)
    {
        $sql = "execute procedure sp_del_EvalCronAul(	{$parametros['comision']},
														{$parametros['evaluacion']})";
		return util::ejecutar_procedure($sql);
	}
    
	//---------------------------------------------
	//	CARGA NOTAS
	//---------------------------------------------		
  
	/**
	 * parametros: escala_notas
	 * cache: memoria
	 * filas: n
	 */
    function escala_notas($parametros)
    {
        $sql = "EXECUTE PROCEDURE sp_det_escala_parc({$parametros['escala_notas']})";
		$datos = kernel::db()->consultar_fila($sql);
		return $datos;  
	}
	
	/**
	 * parametros: comision, evaluacion
	 * cache: memoria
	 * filas: n
	 */
    function evaluacion_cabecera($parametros)
    {
        //$sql = "execute procedure sp_eval_cabecera(	{$parametros['comision']},
		$sql = "execute procedure sp_eval_parc_alum(	{$parametros['comision']},
													{$parametros['evaluacion']})";
		$dato = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		//$nuevo[$id]['ID'] = sha1($dato[2]."-".$dato[10]);
		if($dato) {
			$nuevo = array();
			$nuevo['CARRERA'] = $dato[14];
			$nuevo['CARRERA_NOMBRE'] = $dato[15];
			$nuevo['MATERIA'] = $dato[1];
			$nuevo['MATERIA_NOMBRE'] = $dato[2];
			$nuevo['ANIO_ACADEMICO'] = $dato[3];
			$nuevo['PERIODO_LECTIVO'] = $dato[4];
			$nuevo['COMISION'] = $dato[5];
			$nuevo['COMISION_NOMBRE'] = $dato[6];
			$nuevo['ESCALA_NOTAS'] = $dato[7];
			$nuevo['ESCALA_NOTAS_DESC'] = $dato[8];
			$nuevo['EVALUACION'] = $dato[9];
			$nuevo['EVALUACION_DESC'] = $dato[10];
			$nuevo['CATEDRA'] = $dato[11];
			$nuevo['FECHA_HORA'] = $dato[18];		
			return $nuevo;
		} else {
			throw new error_guarani('No existen alumnos en la evaluacion parcial solicitada.');
		}
	}
	
	/**
	 * parametros: comision, evaluacion
	 * cache: no
	 * filas: n
	 */
    function evaluacion_detalle($parametros)
    {
        $sql = "execute procedure sp_eval_parc_alum(	{$parametros['comision']},
														{$parametros['evaluacion']})";
		$datos = kernel::db()->consultar($sql, db::FETCH_NUM);
		$nuevo = array();
		foreach($datos as $id => $dato) {
			$nuevo[$id]['CALIDAD'] = $dato[12];
			$nuevo[$id]['ESTADO'] = $dato[13];
			$nuevo[$id]['CARRERA'] = $dato[14];
			$nuevo[$id]['LEGAJO'] = $dato[16];
			$nuevo[$id]['NOMBRE'] = $dato[17];
			$nuevo[$id]['FECHA_HORA'] = $dato[18];
			$nuevo[$id]['NOTA'] = $dato[19];
			$nuevo[$id]['RESULTADO'] = $dato[20];
			$nuevo[$id]['CORREGIDO_POR'] = $dato[21];
			$nuevo[$id]['OBSERVACIONES'] = $dato[22];
			$nuevo[$id]['ID_IMAGEN'] = $dato[23]; //-- EN QUE PISICION VIENE?
			if (!empty($nuevo[$id]['ID_IMAGEN'])) {
				$nuevo[$id]['URL_IMAGEN'] = alumno_foto::url_imagen($nuevo[$id]['ID_IMAGEN']);
				$nuevo[$id]['URL_IMAGEN_GRANDE'] = alumno_foto::url_imagen($nuevo[$id]['ID_IMAGEN'], alumno_foto::TAMANIO_GRANDE);
			} else {
				$nuevo[$id]['URL_IMAGEN'] = kernel::vinculador()->vinculo_recurso('img/iconos/mm.png');
				$nuevo[$id]['URL_IMAGEN_GRANDE'] = kernel::vinculador()->vinculo_recurso('img/iconos/mm_grande.png');
			}
		}
		return $nuevo;	
	}

    /**
	 * parametros: _ua,		carrera, legajo, comision, evaluacion, fecha_hora, escala_notas, nota, corregido_por, observaciones
	 * cache: no
	 * param_tipo: str/20,	str/20, str/20, int,		int,		str/25,		int,		str/10,	str/40,		str/80	
	 * param_null: corregido_por, observaciones, nota
	 * filas: 1
	 */
	function guardar_renglon($parametros) 
	{
		$parametros = util::formato_null($parametros);
		$sql = " EXECUTE PROCEDURE sp_upt_evalParcAlu(  {$parametros['_ua']},
													{$parametros['carrera']},
													{$parametros['legajo']},
                                                    {$parametros['comision']},
                                                    {$parametros['evaluacion']},
                                                    {$parametros['fecha_hora']},
                                                    {$parametros['escala_notas']},
                                                    {$parametros['nota']},
                                                    {$parametros['corregido_por']},
                                                    {$parametros['observaciones']})";

		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		return $datos;
    }
}
?>
