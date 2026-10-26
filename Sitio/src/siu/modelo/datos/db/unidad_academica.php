<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\util\caracteres_especiales;

class unidad_academica
{
	
	/**
	 * parametros: ua
	 * cache: memoria
	 * filas: 1
	 */
	function info($parametros)
	{
		$sql = "execute procedure sp_unidadAcademica({$parametros['ua']})";
		$datos = kernel::db()->consultar_fila($sql, db::FETCH_NUM);
		$nuevo['UNIDAD_ACADEMICA']		= $datos[0];
		$nuevo['NOMBRE']				= $datos[1];
		$nuevo['SIGLA']					= $datos[2];
		$nuevo['LOGO']					= $datos[3];
		$nuevo['NOMBRE_UNIVERSIDAD']	= $datos[4];

        $sql = "SELECT mug_localidades.nombre AS localidad_nombre
                FROM mug_localidades
                JOIN sga_unidades_acad ON (sga_unidades_acad.localidad = mug_localidades.localidad)
                WHERE sga_unidades_acad.unidad_academica = {$parametros['ua']}";
        $datos = kernel::db()->consultar_fila($sql, db::FETCH_ASSOC);
        $nuevo['LOCALIDAD']	= $datos['LOCALIDAD_NOMBRE'];
		return $nuevo;		
	}
	
	/**
	 * cache: memoria
	 * filas: 1
	 */
	function periodos_lectivos()
	{
		$sql = "SELECT
					pl.periodo_lectivo,
					pl.tipo_de_periodo,
					-- pl.fecha_inicio,
					-- pl.fecha_fin,
					to_char(pl.inicio_dictado, \"%d/%m/%Y\") as f_inicio_dictado,
					to_char(pl.fin_dictado, \"%d/%m/%Y\") as f_fin_dictado,
					fi.nombre as nombre_insc,
					to_char(fi.fecha_inicio, \"%d/%m/%Y\") as f_inicio_insc,
					to_char(fi.fecha_fin, \"%d/%m/%Y\") as f_fin_insc,
					pl.orden_en_el_anio,
					fi.orden,
					pl.anio_academico as anio_academico
				FROM
				sga_anio_academico as a ,
				sga_periodos_lect as pl,
				sga_fec_insc_cur  as fi
				WHERE pl.anio_academico = a.anio_academico
				AND fi.anio_academico = pl.anio_academico
				AND fi.periodo_lectivo = pl.periodo_lectivo
				AND  a.fecha_fin > TODAY  
				ORDER BY  pl.orden_en_el_anio, fi.orden;";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		$nuevo = array();
		foreach ($datos as $clave => $dato){
			$nuevo[$clave] = $dato;
			$nuevo[$clave]['_ID_'] = catalogo::generar_id($dato['ANIO_ACADEMICO'].'-'.$dato['PERIODO_LECTIVO']);
		}
		$corte = array();	
		foreach ($nuevo as $dato){
			$corte[$dato['PERIODO_LECTIVO']]['PERIODO_LECTIVO'] = $dato['PERIODO_LECTIVO'];
			$corte[$dato['PERIODO_LECTIVO']]['TIPO_DE_PERIODO'] = $dato['TIPO_DE_PERIODO'];
			$corte[$dato['PERIODO_LECTIVO']]['F_INICIO_DICTADO'] = $dato['F_INICIO_DICTADO'];
			$corte[$dato['PERIODO_LECTIVO']]['F_FIN_DICTADO'] = $dato['F_FIN_DICTADO'];
			$corte[$dato['PERIODO_LECTIVO']]['ORDEN_EN_EL_ANIO'] = $dato['ORDEN_EN_EL_ANIO'];
			$corte[$dato['PERIODO_LECTIVO']]['ANIO_ACADEMICO'] = $dato['ANIO_ACADEMICO'];
			$corte[$dato['PERIODO_LECTIVO']]['_ID_'] = $dato['_ID_'];

			$p_insc['NOMBRE_INSC'] = $dato['NOMBRE_INSC'];
			$p_insc['F_INICIO_INSC'] = $dato['F_INICIO_INSC'];
			$p_insc['F_FIN_INSC'] = $dato['F_FIN_INSC'];
			$p_insc['ORDEN'] = $dato['ORDEN'];

			$corte[$dato['PERIODO_LECTIVO']]['PER_INSCR_CURSADAS'][] = $p_insc;
			unset($p_insc);
		}
			
		return $corte;
		
	}
	
	/**
	 * parametros: anio
	 * cache: memoria
	 * filas: 1
	 */
	function buscar_periodos_lectivos($parametros)
	{
		$sql = "SELECT
					pl.periodo_lectivo,
					pl.tipo_de_periodo,
					pl.orden_en_el_anio
				FROM
				sga_periodos_lect as pl
				WHERE pl.anio_academico = {$parametros['anio']}
				ORDER BY  pl.orden_en_el_anio;";
				
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		$nuevo = array();
		foreach ($datos as $clave => $dato){
			$nuevo[$clave]['ID'] = catalogo::generar_id($dato['PERIODO_LECTIVO']);
			$nuevo[$clave]['PERIODO_LECTIVO'] = $dato['PERIODO_LECTIVO'];
			$nuevo[$clave]['DESC'] = $dato['PERIODO_LECTIVO']." (".$dato['TIPO_DE_PERIODO'].")";
		}
		return $nuevo;
	}	
	
	/**
	 * cache: memoria
	 * filas: 1
	 */
	function turnos_examen()
	{
		$sql = "SELECT
					t.turno_examen,
					to_char(t.fecha_inicio, \"%d/%m/%Y\") as f_inicio_turno,
					to_char(t.fecha_fin, \"%d/%m/%Y\") as f_fin_turno,
					t.orden_en_el_anio,
					t.anio_academico
					FROM
					sga_anio_academico as a ,
					sga_turnos_examen as t
					WHERE t.anio_academico = a.anio_academico
					AND  a.fecha_fin > TODAY  
					ORDER BY  t.orden_en_el_anio;";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		$nuevo = array();
		foreach ($datos as $clave => $dato){
			$nuevo[$clave] = $dato;
			$nuevo[$clave]['_ID_'] = catalogo::generar_id($dato['ANIO_ACADEMICO'].'-'.$dato['TURNO_EXAMEN']);
		}
		return $nuevo;
	}
	
	
	/**
	 * cache: memoria
	 * filas: 1
	 */
	function info_turnos_examen()
	{
		$sql = "SELECT
					t.turno_examen,
					to_char(t.fecha_inicio, '%d/%m/%Y') as f_inicio_turno,
					to_char(t.fecha_fin, '%d/%m/%Y') as f_fin_turno,
					sga_llamados.llamado as llamado,
					to_char(sga_llamados.fecha_inicio, '%d/%m/%Y') as f_inicio_llamado,
					to_char(sga_llamados.fecha_fin, '%d/%m/%Y') as f_fin_llamado,
					to_char(sga_fec_insc_llam.fecha_inicio, '%d/%m/%Y %H:%M') as f_inicio_insc_llam,
                    to_char(sga_fec_insc_llam.fecha_fin, '%d/%m/%Y %H:%M') as f_fin_insc_llam,
					t.orden_en_el_anio as orden_en_el_anio,
					t.anio_academico as anio_academico
					FROM sga_anio_academico as a ,
					     sga_turnos_examen as t,
					     sga_llamados,
                         sga_fec_insc_llam
					WHERE t.anio_academico = a.anio_academico
					  AND a.fecha_fin > TODAY  
					  AND sga_llamados.anio_academico   = t.anio_academico
					  AND sga_llamados.turno_examen     = t.turno_examen
                      AND sga_fec_insc_llam.anio_academico = sga_llamados.anio_academico
                      AND sga_fec_insc_llam.turno_examen   = sga_llamados.turno_examen
                      AND sga_fec_insc_llam.llamado        = sga_llamados.llamado
					ORDER BY  2, 5;";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		$nuevo = array();
		foreach ($datos as $clave => $dato){
			$nuevo[$clave] = $dato;
			$nuevo[$clave]['_ID_'] = catalogo::generar_id($dato['ANIO_ACADEMICO'].'-'.$dato['TURNO_EXAMEN']);
		}
		$corte = array();	
		foreach ($nuevo as $dato){
			$corte[$dato['TURNO_EXAMEN']]['TURNO_EXAMEN'] = $dato['TURNO_EXAMEN'];
			$corte[$dato['TURNO_EXAMEN']]['F_INICIO_TURNO'] = $dato['F_INICIO_TURNO'];
			$corte[$dato['TURNO_EXAMEN']]['F_FIN_TURNO'] = $dato['F_FIN_TURNO'];
			$corte[$dato['TURNO_EXAMEN']]['ORDEN_EN_EL_ANIO'] = $dato['ORDEN_EN_EL_ANIO'];
			$corte[$dato['TURNO_EXAMEN']]['ANIO_ACADEMICO'] = $dato['ANIO_ACADEMICO'];
			$corte[$dato['TURNO_EXAMEN']]['_ID_'] = $dato['_ID_'];

			$llamado['LLAMADO'] = $dato['LLAMADO'];
			$llamado['F_INICIO_LLAMADO'] = $dato['F_INICIO_LLAMADO'];
			$llamado['F_FIN_LLAMADO'] = $dato['F_FIN_LLAMADO'];
			$llamado['F_INICIO_INSC_LLAM'] = $dato['F_INICIO_INSC_LLAM'];
			$llamado['F_FIN_INSC_LLAM'] = $dato['F_FIN_INSC_LLAM'];

			$corte[$dato['TURNO_EXAMEN']]['LLAMADOS'][] = $llamado;
			unset($llamado);
		}
			
		return $corte;
	}
	
	/**
	 * parametros: anio
	 * cache: memoria
	 * filas: 1
	 */
	function buscar_turnos_examen($parametros)
	{
		$sql = "SELECT
					t.turno_examen,
					t.orden_en_el_anio
					FROM
					sga_turnos_examen as t
					WHERE t.anio_academico = {$parametros['anio']}
					ORDER BY  t.orden_en_el_anio;";
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		$nuevo = array();
		foreach ($datos as $clave => $dato){
			$nuevo[$clave]['ID'] = catalogo::generar_id($dato['TURNO_EXAMEN']);
			$nuevo[$clave]['TURNO'] = $dato['TURNO_EXAMEN'];
			$nuevo[$clave]['DESC'] = $dato['TURNO_EXAMEN'];
		}
		return $nuevo;
	}

    /**
     * parametros: anio
     * cache: memoria
     * filas: 1
     */
    function buscar_turnos_examen_vigentes($parametros)
    {
        $sql = "SELECT sga_turnos_examen.turno_examen,
                       sga_turnos_examen.orden_en_el_anio,
                       sga_turnos_examen.nombre,
					   sga_turnos_examen.fecha_inicio,
					   sga_turnos_examen.fecha_fin
					FROM sga_turnos_examen
					WHERE sga_turnos_examen.anio_academico = {$parametros['anio']}
					AND sga_turnos_examen.fecha_fin >= TODAY
					ORDER BY  sga_turnos_examen.orden_en_el_anio DESC";
        $datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);

        foreach ($datos as &$dato){
            $dato['ID'] = catalogo::generar_id($dato['TURNO_EXAMEN']);
        }
        return $datos;
    }
	
	/**
	 * cache: memoria
	 * filas: n
	 */
	function anios_academicos()
	{
		$sql = "SELECT a.anio_academico 
				FROM sga_anio_academico as a 
				WHERE fecha_inicio <= TODAY
				ORDER BY anio_academico DESC";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		foreach ($datos as $clave => $dato){
			$nuevo[$clave] = $dato;
			$nuevo[$clave]['_ID_'] = catalogo::generar_id($dato['ANIO_ACADEMICO']);
		}
		return $nuevo;
	}

    /**
     * cache: memoria
     * filas: n
     */
	function anios_academicos_todos()
	{
		$sql = "SELECT anio_academico 
				FROM sga_anio_academico
				ORDER BY anio_academico DESC";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		foreach ($datos as $clave => $dato){
			$nuevo[$clave] = $dato;
			$nuevo[$clave]['_ID_'] = catalogo::generar_id($dato['ANIO_ACADEMICO']);
		}
		return $nuevo;
	}

	/**
	 * cache: memoria
	 * filas: n
	 */
	function anios_academicos_vigentes()
	{
		// Recupera anios academicos que no finalizaron
		$sql = "SELECT a.anio_academico 
				FROM sga_anio_academico as a 
				WHERE fecha_fin >= TODAY
				ORDER BY anio_academico DESC";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		foreach ($datos as $clave => $dato){
			$nuevo[$clave] = $dato;
			$nuevo[$clave]['_ID_'] = catalogo::generar_id($dato['ANIO_ACADEMICO']);
		}
		return $nuevo;
	}

	/**
	 * cache: memoria
	 * filas: n
	 */
	function anio_academico_actual()
	{
		// Recupera año académico actual
		$sql = "SELECT a.anio_academico 
				FROM sga_anio_academico as a 
				WHERE fecha_fin >= TODAY
				AND fecha_inicio <= TODAY;";
		
		$datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		return $datos[0];
	}

    /**
     * cache: memoria
     * filas: n
     */
    function anios_academicos_con_turnos_examen_vigentes()
    {
        $sql = "SELECT DISTINCT sga_anio_academico.anio_academico, sga_anio_academico.fecha_inicio
                FROM sga_anio_academico
                JOIN sga_turnos_examen ON (sga_anio_academico.anio_academico = sga_turnos_examen.anio_academico)
                WHERE sga_turnos_examen.fecha_fin >= TODAY
                ORDER BY sga_anio_academico.fecha_inicio DESC";

        $datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
        foreach ($datos as $clave => $dato){
            $nuevo[$clave] = $dato;
            $nuevo[$clave]['_ID_'] = catalogo::generar_id($dato['ANIO_ACADEMICO']);
        }
        return $nuevo;
    }
	
	/**
	* Lista de materias de la unidad académica
	* parametros: _ua, term
	* cache: memoria
	* filas: n
	*/
	function materias($parametros)
	{
        $flitro_termino = "";

        if ($parametros['term'] != "''"){

            $termino = strtolower(substr($parametros['term'], 1, -1));
            $term = kernel::db()->quote_like($termino, '%', '%');
            $term_sin_car_esp = kernel::db()->quote_like(caracteres_especiales::limpiar($termino), '%', '%');

            $flitro_termino = " AND (
                        LOWER(materia) LIKE $term OR
                        LOWER(nombre) LIKE $term OR
                        LOWER(materia) LIKE $term_sin_car_esp OR
                        LOWER(nombre) LIKE $term_sin_car_esp
                        )";
        }


        
		$sql = "SELECT unidad_academica, materia, nombre
                FROM sga_materias
                WHERE unidad_academica = {$parametros['_ua']}
                AND estado <> 'B'".$flitro_termino;

		$datos = kernel::db()->consultar($sql);

		$res = array();
		foreach ($datos as $dato){
			$paquete = array();
			$paquete['id'] = catalogo::generar_id($dato['MATERIA']);
			$paquete['materia'] = $dato['MATERIA'];
			$paquete['label'] = "({$dato['MATERIA']}) {$dato['NOMBRE']}";
			$res[] = $paquete;
		}
		return $res;
	}
	
	/**
	* Lista de docentes de la unidad académica
	* parametros: _ua, term
	* cache: memoria
	* filas: n
	*/
	function docentes($parametros)
	{
        $flitro_termino = "";

        if ($parametros['term'] != "''"){

            $termino = strtolower(substr($parametros['term'], 1, -1));
            $term = kernel::db()->quote_like($termino, '%', '%');
            $term_sin_car_esp = kernel::db()->quote_like(caracteres_especiales::limpiar($termino), '%', '%');

            $flitro_termino = " AND (
                        LOWER(sd.legajo) LIKE $term OR
                        LOWER(sp.nombres || sp.apellido) LIKE $term OR
                        LOWER(sd.legajo) LIKE $term_sin_car_esp OR
                        LOWER(sp.nombres || sp.apellido) LIKE $term_sin_car_esp
                        )";
        }

        
		$sql = "SELECT sd.unidad_academica UA, sd.legajo LEGAJO,sp.nombres || ' ' || sp.apellido NOMBRE
				  FROM sga_docentes sd, sga_personas sp	
				  WHERE sd.unidad_academica = {$parametros['_ua']}
				  AND sp.nro_inscripcion =sd.nro_inscripcion
				  AND sd.unidad_academica = sp.unidad_academica".$flitro_termino;
				 
		$datos = kernel::db()->consultar($sql);

		$res = array();
		foreach ($datos as $dato){
			$paquete = array();
			$paquete['id'] = catalogo::generar_id($dato['LEGAJO']);
			$paquete['legajo'] = $dato['LEGAJO'];
			$paquete['label'] = "({$dato['LEGAJO']}) {$dato['NOMBRE']}";
			$res[] = $paquete;
		}
		return $res;
	}

    /**
     * Devuelve un docente de la unidad académica
     * parametros: _ua, legajo
     * cache: memoria
     * filas: 1
     */
    function docente($parametros)
    {
        $sql = "SELECT sd.unidad_academica UA, sd.legajo LEGAJO, sp.nombres || ' ' || sp.apellido NOMBRE
                FROM sga_docentes sd, sga_personas sp
                WHERE sd.unidad_academica = {$parametros['_ua']}
				AND sp.nro_inscripcion =sd.nro_inscripcion
				AND sd.unidad_academica = sp.unidad_academica
                AND sd.legajo = {$parametros['legajo']}
			  ";

        $datos = kernel::db()->consultar_fila($sql);

        $datos['_ID_'] = catalogo::generar_id($datos['LEGAJO']);
        $datos['LABEL'] = "({$datos['LEGAJO']}) {$datos['NOMBRE']}";

        return $datos;
    }

	/**
	* Devuelve una materia de la unidad académica
	* parametros: _ua, materia
	* cache: memoria
	* filas: 1
	*/
	function materia($parametros)
	{
		$sql = "SELECT unidad_academica, materia, nombre
				  FROM sga_materias
				 WHERE unidad_academica = {$parametros['_ua']} 
				   AND materia = {$parametros['materia']}
	 		  ";

		$datos = kernel::db()->consultar_fila($sql);
        $datos['_ID_'] = catalogo::generar_id($datos['MATERIA']);
        $datos['LABEL'] = "({$datos['MATERIA']}) {$datos['NOMBRE']}";

		return $datos;
	}

	/**
	* Lista de Actas
	* parametros: _ua, anio_academico, origen, materia, sede, turno_examen, turno_desde, turno_hasta, periodo_lectivo
	* param_null: materia, sede, turno_examen, turno_desde, turno_hasta, periodo_lectivo
	* cache: memoria
	* filas: n
	*/
	function listar_actas_gerencial($parametros)
	{
        $filtro_materia = '';
        if ($parametros['materia'] != "''"){
           $filtro_materia = " AND sga_materias.materia = {$parametros['materia']} ";
        }

        // Filtros de Actas de Cursada y Promocion
        $filtro_sede_comision = '';
        $filtro_periodo_lectivo = '';
 
        if ($parametros['sede'] != "''"){
           $filtro_sede_comision = " AND sga_comisiones.sede = {$parametros['sede']} ";
        }
        if ($parametros['periodo_lectivo'] && ($parametros['periodo_lectivo'] != "''")){
           $filtro_periodo_lectivo = " AND sga_comisiones.periodo_lectivo = {$parametros['periodo_lectivo']} ";
        }

        // Filtros de Actas de Examen
        $filtro_turno_examen = "";
        $filtro_fecha_desde = "";
        $filtro_fecha_hasta = "";
        $filtro_sede_mesa = '';

        if ($parametros['sede'] != "''"){
           $filtro_sede_mesa     = " AND sga_mesas_examen.sede = {$parametros['sede']} ";
        }
        if ($parametros['turno_examen'] && ($parametros['turno_examen'] != "''")){
           $filtro_turno_examen = " AND sga_actas_examen.turno_examen = {$parametros['turno_examen']} ";
        }
        if ($parametros['turno_desde'] != "''"){
           $filtro_fecha_desde = " AND fecha_cierre >= to_date({$parametros['turno_desde']}, '%d/%m/%Y') ";
        }
        if ($parametros['turno_hasta'] != "''"){
           $filtro_fecha_hasta = " AND fecha_cierre <= to_date({$parametros['turno_hasta']}, '%d/%m/%Y') ";
        }

		if ($parametros['origen'] == "'R'") {
            // Actas de Cursado Cerradas.
            $sql = "
		       SELECT sga_actas_cursado.unidad_academica,
		              sga_actas_cursado.acta as acta,
		              'N' as tipo_acta,
		              'Normal' as tipo_acta_desc,
		              sga_materias.materia as materia,
		              sga_materias.nombre as materia_nombre,
		              sga_comisiones.anio_academico as anio_academico,
		              sga_comisiones.periodo_lectivo as turno_periodo,
		              'Cursada' as origen,
		              sga_actas_cursado.estado as estado,
		              CASE sga_actas_cursado.estado
		                WHEN 'A' THEN 'Abierta'
		                WHEN 'C' THEN 'Cerrada'
		                WHEN 'B' THEN 'Anulada'
		              END as estado_desc,
		              to_char(sga_actas_cursado.fecha_cierre, '%d/%m/%Y') as fecha_cierre,
		              CAST(NULL as integer) as acta_rectificada,
		              sga_sedes.nombre as sede_nombre,
		              sga_comisiones.nombre as mesa_comision_nombre

			   FROM   sga_actas_cursado,
				      sga_comisiones,
				      sga_materias,
				      sga_sedes
		       WHERE  sga_actas_cursado.unidad_academica = {$parametros['_ua']}
		          AND sga_comisiones.comision = sga_actas_cursado.comision
		          AND sga_comisiones.anio_academico = {$parametros['anio_academico']}
		          AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
		          AND sga_materias.materia          = sga_comisiones.materia
		          AND sga_sedes.sede = sga_comisiones.sede
		          AND sga_actas_cursado.estado <> 'B'  -- No se muestran las anuladas
                  $filtro_materia
                  $filtro_sede_comision
                  $filtro_periodo_lectivo
			";
		}

		if ($parametros['origen'] == "'P'") {
			$sql = "
		       SELECT sga_actas_promo.unidad_academica,
		              sga_actas_promo.acta as acta,
		              sga_actas_promo.tipo as tipo_acta,
		              CASE sga_actas_promo.tipo
		                 WHEN 'N' THEN 'Normal'
		                 WHEN 'R' THEN 'Recticativa'
		              END as tipo_acta_desc,
		              sga_materias.materia as materia,
		              sga_materias.nombre as materia_nombre,
		              sga_comisiones.anio_academico as anio_academico,
		              sga_comisiones.periodo_lectivo as turno_periodo,
		              'Promoción' as origen,
		              sga_actas_promo.estado as estado,
		              CASE sga_actas_promo.estado
		                WHEN 'A' THEN 'Abierta'
		                WHEN 'C' THEN 'Cerrada'
		                WHEN 'B' THEN 'Anulada'
		              END as estado_desc,
		              to_char(sga_actas_promo.fecha_cierre, '%d/%m/%Y') as fecha_cierre,
		              sga_actas_promo.acta_referencia as acta_rectificada,
		              sga_sedes.nombre as sede_nombre,
		              sga_comisiones.nombre as mesa_comision_nombre

			   FROM   sga_actas_promo,
				      sga_comisiones,
				      sga_materias,
				      sga_sedes
		       WHERE  sga_actas_promo.unidad_academica = {$parametros['_ua']}
		          AND sga_comisiones.comision = sga_actas_promo.comision
		          AND sga_comisiones.anio_academico = {$parametros['anio_academico']}
		          AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
		          AND sga_materias.materia          = sga_comisiones.materia
		          AND sga_sedes.sede = sga_comisiones.sede
		          AND sga_actas_promo.estado <> 'B'  -- No se muestran las anuladas
                  $filtro_materia
                  $filtro_sede_comision
                  $filtro_periodo_lectivo
			";
		}

		if ($parametros['origen'] == "'E'") {
			$sql = "
		       SELECT sga_actas_examen.unidad_academica,
		              sga_actas_examen.acta as acta,
		              sga_actas_examen.tipo_acta as tipo_acta,
		              CASE sga_actas_examen.tipo_acta
		                 WHEN 'N' THEN 'Normal'
		                 WHEN 'R' THEN 'Recticativa'
		              END as tipo_acta_desc,
		              sga_materias.materia as materia,
		              sga_materias.nombre as materia_nombre,
		              sga_actas_examen.anio_academico as anio_academico,
		              sga_actas_examen.turno_examen as turno_examen,
		              'Examen' as origen,
		              sga_actas_examen.estado as estado,
		              CASE sga_actas_examen.estado
		                WHEN 'A' THEN 'Abierta'
		                WHEN 'I' THEN 'Abierta'
		                WHEN 'N' THEN 'Abierta'
		                WHEN 'C' THEN 'Cerrada'
		                WHEN 'B' THEN 'Anulada'
		              END as estado_desc,
		              to_char(sga_actas_examen.fecha_cierre, '%d/%m/%Y') as fecha_cierre,
		              sga_actas_examen.acta_referencia as acta_rectificada,
		              sga_sedes.nombre as sede_nombre,
		              sga_mesas_examen.mesa_examen as mesa_comision_nombre

			   FROM   sga_actas_examen,
				      sga_mesas_examen,
				      sga_llamados_mesa,
				      sga_prestamos,
				      sga_materias,
				      sga_sedes
		       WHERE  sga_actas_examen.unidad_academica = {$parametros['_ua']}
		          AND sga_actas_examen.anio_academico = {$parametros['anio_academico']}
		          AND sga_mesas_examen.unidad_academica = sga_actas_examen.unidad_academica
		          AND sga_mesas_examen.materia          = sga_actas_examen.materia
		          AND sga_mesas_examen.anio_academico   = sga_actas_examen.anio_academico
		          AND sga_mesas_examen.turno_examen     = sga_actas_examen.turno_examen
		          AND sga_mesas_examen.mesa_examen      = sga_actas_examen.mesa_examen

		          AND sga_llamados_mesa.unidad_academica = sga_actas_examen.unidad_academica
		          AND sga_llamados_mesa.materia          = sga_actas_examen.materia
		          AND sga_llamados_mesa.anio_academico   = sga_actas_examen.anio_academico
		          AND sga_llamados_mesa.turno_examen     = sga_actas_examen.turno_examen
		          AND sga_llamados_mesa.mesa_examen      = sga_actas_examen.mesa_examen
		          AND sga_llamados_mesa.llamado          = sga_actas_examen.llamado

		          AND sga_prestamos.prestamo = sga_llamados_mesa.prestamo

		          AND sga_materias.unidad_academica = sga_actas_examen.unidad_academica
		          AND sga_materias.materia          = sga_actas_examen.materia
		          AND sga_sedes.sede = sga_mesas_examen.sede
                  $filtro_materia
                  $filtro_sede_mesa
                  $filtro_turno_examen
                  $filtro_fecha_desde
                  $filtro_fecha_hasta
		    ";
		}

		$datos = kernel::db()->consultar($sql);
		return $datos;
	}

	/**
	 * parametros: _ua, anio_academico, turno_examen, carrera
	 * cache: no
	 * filas: n
	 */
	function mesas_examen($parametros)
	{
        $sql = "execute procedure sp_mesas_examen({$parametros['_ua']}, {$parametros['anio_academico']}, {$parametros['turno_examen']}, {$parametros['carrera']})";

        $datos = kernel::db()->consultar($sql, db::FETCH_NUM);

        $nuevo = array();
        $i = 0;
        foreach($datos as $dato){

            $nuevo[$i]['vc_unidad_acad'] = $dato[0];
            $nuevo[$i]['vc_turno_examen'] = $dato[1];
            $nuevo[$i]['vc_nombre_turno'] = $dato[2];
            $nuevo[$i]['vc_mesa_examen'] = $dato[3];
            $nuevo[$i]['vc_anio_acad'] = $dato[4];
            $nuevo[$i]['vc_materia'] = $dato[5];
            $nuevo[$i]['vc_nombre_mat'] = $dato[6];
            $nuevo[$i]['vc_catedra'] = $dato[7];
            $nuevo[$i]['vc_fecha'] = $dato[8];
            $nuevo[$i]['vc_llamado'] = $dato[9];
            $nuevo[$i]['vc_docentes'] = $dato[10];
            $nuevo[$i]['vc_admite_libr'] = $dato[11];
            $nuevo[$i]['vc_hora_inicio'] = $dato[12];
            $nuevo[$i]['vc_hora_fin'] = $dato[13];
            $nuevo[$i]['vc_carrera'] = $dato[14];
            $nuevo[$i]['vc_nombre_carr'] = $dato[15];
            $nuevo[$i]['vc_plan'] = $dato[16];
            $nuevo[$i]['vc_grupo_carr'] = $dato[17];
            $nuevo[$i]['vc_nombre_grup'] = $dato[18];
            $nuevo[$i]['vc_fec_inicio'] = $dato[19];
            $nuevo[$i]['vc_fec_fin'] = $dato[20];
            $nuevo[$i]['vc_fec_top'] = $dato[21];
            $nuevo[$i]['vd_llam_f_inicio'] = $dato[22];
            $nuevo[$i]['vd_llam_f_fin'] = $dato[23];

            $i++;
        }

        usort($nuevo, function($a, $b){
            $cmp_vc_nombre_mat = strcasecmp($a["vc_nombre_mat"], $b["vc_nombre_mat"]);
            $fecha_a = new \DateTime($a["vc_fecha"]);
            $fecha_b = new \DateTime($b["vc_fecha"]);
            if($fecha_a == $fecha_b){
                $cmp_vc_fecha = 0;
            }
            else{
                $cmp_vc_fecha = ($fecha_a > $fecha_b)? 1 : -1;
            }
            $cmp_vc_llamado = strcasecmp($a["vc_llamado"], $b["vc_llamado"]);
            $cmp_vc_mesa_examen = strcasecmp($a["vc_mesa_examen"], $b["vc_mesa_examen"]);

            if($cmp_vc_nombre_mat == 0){

                if($cmp_vc_fecha == 0){

                    if($cmp_vc_llamado == 0){
                        return $cmp_vc_mesa_examen;
                    }
                    else{
                        return $cmp_vc_llamado;
                    }

                }
                else{
                    return $cmp_vc_fecha;
                }

            }
            else{
                return $cmp_vc_nombre_mat;
            }
        });

        return $nuevo;
	}

}
?>