<?php
namespace siu\modelo\datos\db;
use kernel\kernel;
use kernel\util\db\db;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\util\caracteres_especiales;
use \siu\modelo\entidades;

class usuario_anonimo {


    /**
     * Devuelve materias de los planes de una carrera o todas las materias de la base
     * parametros: _ua, materia, carrera, plan
     * no_quote: materia
     * cache: memoria
     * filas: n
     */
    function lista_materias_carrera($parametros)
    {
        $filtro_materia = '';

        if ($parametros['materia'] != ""){
            $termino = strtolower($parametros['materia']);
            $term_materia = kernel::db()->quote_like($termino, '%', '%');
            $term_sin_car_esp = kernel::db()->quote_like(caracteres_especiales::limpiar($termino), '%', '%');
            $filtro_materia = " AND (
                                    LOWER(sga_materias.materia) LIKE $term_materia 
                                    OR LOWER(sga_materias.nombre) LIKE $term_materia
                                    OR LOWER(sga_materias.materia) LIKE $term_sin_car_esp 
                                    OR LOWER(sga_materias.nombre) LIKE $term_sin_car_esp
                                ) 
                              ";
        }

        $filtro_plan = '';

        if ($parametros['plan'] != "''"){
            $filtro_plan = " AND sga_atrib_mat_plan.plan = {$parametros['plan']}";
        }

        // Se seleccionó una carrera. Se devuelven todas las materias de los planes de esa carrera
        if ($parametros['carrera'] != "''"){
            $sql = "SELECT DISTINCT sga_materias.unidad_academica, sga_materias.materia, sga_materias.nombre
				  FROM sga_atrib_mat_plan,
				       sga_materias
				 WHERE sga_atrib_mat_plan.unidad_academica  = {$parametros['_ua']}
				   AND sga_atrib_mat_plan.carrera = {$parametros['carrera']}
				   AND sga_materias.unidad_academica = sga_atrib_mat_plan.unidad_academica
				   AND sga_materias.materia = sga_atrib_mat_plan.materia
				   AND sga_materias.estado <> 'B'
				   $filtro_plan
				   $filtro_materia
	 		  ";
        }

        // No se seleccionó una carrera. Recupera todas las materias de la unidad academica.
        if ($parametros['carrera'] == "''"){
            $sql = "SELECT sga_materias.unidad_academica, sga_materias.materia, sga_materias.nombre
				  FROM sga_materias
				 WHERE sga_materias.unidad_academica = {$parametros['_ua']}
				   AND sga_materias.estado <> 'B'
				   $filtro_materia
	 		  ";
        }
        $datos = kernel::db()->consultar($sql);

        $nuevo = array();
        foreach ($datos as $clave => $dato){
            $nuevo[$clave] = $dato;
            $nuevo[$clave]['_ID_'] = catalogo::generar_id($dato['MATERIA']);
        }
        return $nuevo;
    }

    /**
     * parametros: _ua, carrera, plan, materia, fecha_desde, fecha_hasta, tipo_inscripcion
     * cache: no
     * filas: n
     */
    function mesas_examen_usuario_anonimo($parametros)
    {
        // Lista mesas de examen de turnos de examen vigentes o futuros que aun no finalizaron.

        // Filtros

        $filtro_materia = '';
        if ($parametros['materia'] != "''"){
            $filtro_materia = " AND sga_mesas_examen.materia = {$parametros['materia']} ";
        }

        $filtro_tipo_insc = '';
        if ($parametros['tipo_inscripcion'] != "''"){
            // Recupera siempre las mesas A - Libres y Regulares.
            $filtro_tipo_insc = " AND sga_mesas_examen.admite_libres IN ( {$parametros['tipo_inscripcion']}, 'A') ";
        }

        $filtro_fecha_desde = '';
        if ($parametros['fecha_desde'] != "''"){
            $filtro_fecha_desde = " AND sga_prestamos.fecha >= to_date({$parametros['fecha_desde']}, '%Y-%m-%d') ";
        }

        $filtro_fecha_hasta = '';
        if ($parametros['fecha_hasta'] != "''"){
            $filtro_fecha_hasta = " AND sga_prestamos.fecha <= to_date({$parametros['fecha_hasta']}, '%Y-%m-%d') ";
        }

        $filtro_carrera = '';
        if ($parametros['carrera'] != "''"){
            $filtro_carrera = " AND
                ( -- 1er caso: La carrera es igual a la carrera
                 ( sga_mesas_examen.grupo_carrera IS NULL AND
                   sga_mesas_examen.carrera IS NOT NULL AND
                   sga_mesas_examen.carrera = {$parametros['carrera']}  
                  ) OR
                  -- 2do caso: La mesa es para un grupo de carrera en particular y ese grupo contiene a la carrera
                 ( sga_mesas_examen.grupo_carrera IS NOT NULL AND 
                   sga_mesas_examen.carrera IS NULL AND
                   {$parametros['carrera']} IN (SELECT sga_carreras_grupo.carrera FROM sga_carreras_grupo WHERE sga_carreras_grupo.grupo_carrera = sga_mesas_examen.grupo_carrera)
                 ) OR
                 -- 3er caso: La carrera es NULL y el grupo carrera es NULL entonces la materia tiene que estar en el plan de la carrera.
                 (sga_mesas_examen.grupo_carrera IS NULL AND
                  sga_mesas_examen.carrera IS NULL )
                 ) AND
                   sga_mesas_examen.materia IN ( SELECT DISTINCT materia  
                                                  FROM sga_planes, sga_atrib_mat_plan
                                                 WHERE sga_planes.unidad_academica  = {$parametros['_ua']}
                                                   AND sga_planes.carrera           = {$parametros['carrera']}
                                                   AND sga_atrib_mat_plan.unidad_academica = sga_planes.unidad_academica
                                                   AND sga_atrib_mat_plan.carrera          = sga_planes.carrera
                                                   AND sga_atrib_mat_plan.plan             = sga_planes.plan
                                                   AND sga_atrib_mat_plan.version          = sga_planes.version_actual
                                                   AND sga_atrib_mat_plan.tipo_materia    <> 'G')
                  ";
        }

        $filtro_plan = '';
        if ($parametros['plan'] != "''"){
            // Si selecciono plan veo que sea una mesa para ese plan (la carrera ya se filtro arriba)...
            $filtro_plan .= " AND
                 (  -- 1er condicion: El plan esta definido en la mesa o la mesa no tiene plan definido.
                    (sga_mesas_examen.plan = {$parametros['plan']} OR sga_mesas_examen.plan IS NULL)
                    AND
                    -- 2da condicion: La mesa corresponde a una materia del plan de estudios seleccionado
                    (sga_mesas_examen.materia IN ( SELECT DISTINCT materia
                                                   FROM sga_planes, sga_atrib_mat_plan
                                                   WHERE sga_planes.unidad_academica  = {$parametros['_ua']}
                                                   AND sga_planes.carrera           = {$parametros['carrera']}
                                                   AND sga_atrib_mat_plan.plan = {$parametros['plan']}
                                                   AND sga_atrib_mat_plan.unidad_academica = sga_planes.unidad_academica
                                                   AND sga_atrib_mat_plan.carrera          = sga_planes.carrera
                                                   AND sga_atrib_mat_plan.plan             = sga_planes.plan
                                                   AND sga_atrib_mat_plan.version          = sga_planes.version_actual
                                                   AND sga_atrib_mat_plan.tipo_materia    <> 'G'
                                                 )
                    )
                 )";
        }


        // ****************************************************************************
        // Consulto el parámetro "'horas_borrar_antes_examen'"
        // ****************************************************************************
        $Horas_previas_baja_examen = 0;
        $Horas_previas_baja_examen = entidades\parametro::horas_borrar_antes_examen();
        
        // Control Nro 42 -	ctr_horasexaenbaja - Controla las hs de insc antes examen

        $sqls_ctrl_horas = "SELECT activo FROM sga_conf_controles where control = 42 and interfaz = 3 and operacion = 'exa00030'";
        $datos_ctrl_horas = kernel::db()->consultar($sqls_ctrl_horas, db::FETCH_ASSOC);
        $ctrl_horas_activo = "'".$datos_ctrl_horas[0]['ACTIVO']."'";


        // ****************************************************************************
        // Consulta de mesas de examen con fecha de publicación menor o igual a hoy y turnos de examen que no han finalizado.
        // Ordenado por nombre de materia + fecha + hora inicio
        // ****************************************************************************
        $sql = "SELECT
                    sga_mesas_examen.unidad_academica as unidad_academica,
                    sga_mesas_examen.turno_examen as turno_examen,
                    sga_turnos_examen.nombre as turno_examen_nom,
                    sga_mesas_examen.mesa_examen as mesa_examen,
                    sga_mesas_examen.anio_academico as anio_academico,
                    sga_mesas_examen.materia as materia,

                    CASE sga_mesas_examen.plan
                      WHEN NULL THEN sga_materias.nombre
                      ELSE (SELECT samp.nombre_materia
                              FROM sga_atrib_mat_plan samp, sga_planes sp
			                 WHERE samp.unidad_academica = sp.unidad_academica
				               AND samp.carrera = sp.carrera
				               AND samp.plan = sp.plan
				               AND samp.version = sp.version_actual
				               AND samp.unidad_academica = sga_mesas_examen.unidad_academica
                     		   AND samp.carrera = sga_mesas_examen.carrera
				               AND samp.plan = sga_mesas_examen.plan
				               AND samp.materia = sga_mesas_examen.materia)
                    END as materia_nombre,
                    sga_mesas_examen.catedra as catedra,
                    sga_prestamos.fecha as fecha_examen_orden,
                    sga_prestamos.hora_inicio as hora_inicio_orden,
                    to_char(sga_prestamos.fecha, '%d/%m/%Y') as fecha_examen,
                    sga_llamados_mesa.llamado as llamado,
                    sp_doc_una_mesa(sga_mesas_examen.unidad_academica, sga_mesas_examen.materia, sga_mesas_examen.anio_academico,           sga_mesas_examen.turno_examen, sga_mesas_examen.mesa_examen, sga_llamados_mesa.llamado) as docentes,
                    CASE sga_mesas_examen.admite_libres
                      WHEN 'L' THEN 'Libres'
                      WHEN 'R' THEN 'Regulares'
                      WHEN 'A' THEN 'Libres y Regulares'
                      WHEN 'T' THEN 'Tesis'
                      ELSE sga_mesas_examen.admite_libres
                    END as tipo_de_mesa,
                    to_char(sga_prestamos.hora_inicio, '%H:%M') as hora_inicio,
                    to_char(sga_prestamos.hora_finalizacion, '%H:%M') as hora_finalizacion,
                    sga_mesas_examen.observaciones as observaciones,
                    sga_mesas_examen.carrera,
                    sga_carreras.nombre as carrera_nombre,
                    sga_mesas_examen.plan as plan,
                    sga_mesas_examen.grupo_carrera as grupo_carrera,
                    sga_grupos_carrera.nombre as grupo_carrera_nom,

                    to_char(NVL(sga_exep_insc_llam.fecha_inicio, sga_fec_insc_llam.fecha_inicio), '%d/%m/%Y %H:%M') as f_inicio_insc,

                    to_char(NVL(sga_exep_insc_llam.fecha_fin, 
                                ( CASE 
                                  WHEN ( sga_fec_insc_llam.fecha_fin < (EXTEND(sga_prestamos.fecha, YEAR TO SECOND) + (NVL(sga_prestamos.hora_inicio, datetime(23:59:59) hour to second) - datetime(00:00) hour to minute))) THEN sga_fec_insc_llam.fecha_fin
                                  ELSE (EXTEND(sga_prestamos.fecha, YEAR TO SECOND) + (NVL(sga_prestamos.hora_inicio, datetime(23:59:59) hour to second) - datetime(00:00) hour to minute))
                                END )
                                ), '%d/%m/%Y %H:%M') as f_fin_insc,
                   
                    to_char(CASE 
                            WHEN {$ctrl_horas_activo} = 'S' THEN
                                 CASE
                                 WHEN
                                        (CASE 
                                           WHEN NVL({$Horas_previas_baja_examen}, 0) = 0 THEN 
                                                EXTEND(sga_prestamos.fecha, YEAR TO SECOND) + (NVL(sga_prestamos.hora_inicio, datetime(23:59:59) hour to second) - datetime(00:00) hour to minute)  -- Fecha y hora del examen. Si no hay hora de inicio pone las 23:59:00
                                           WHEN {$Horas_previas_baja_examen} >= 0 THEN 
                                                ((EXTEND(sga_prestamos.fecha, YEAR TO SECOND) + (NVL(sga_prestamos.hora_inicio, datetime(23:59:59) hour to second) - datetime(00:00) hour to minute) - {$Horas_previas_baja_examen} UNITS hour))
                                        END) > sga_fec_insc_llam.fecha_tope_bajas THEN sga_fec_insc_llam.fecha_tope_bajas
                                 ELSE
                                       (CASE 
                                          WHEN NVL({$Horas_previas_baja_examen}, 0) = 0 THEN 
                                              EXTEND(sga_prestamos.fecha, YEAR TO SECOND) + (NVL(sga_prestamos.hora_inicio, datetime(23:59:59) hour to second) - datetime(00:00) hour to minute)  -- Fecha y hora del examen. Si no hay hora de inicio pone las 23:59:00
                                          WHEN {$Horas_previas_baja_examen} >= 0 THEN 
                                            ((EXTEND(sga_prestamos.fecha, YEAR TO SECOND) + (NVL(sga_prestamos.hora_inicio, datetime(23:59:59) hour to second) - datetime(00:00) hour to minute) - {$Horas_previas_baja_examen} UNITS hour))
                                         END)
                                 END     
                            ELSE
                                CASE 
                                  WHEN sga_fec_insc_llam.fecha_tope_bajas < (EXTEND(sga_prestamos.fecha, YEAR TO SECOND) + (NVL(sga_prestamos.hora_inicio, datetime(23:59:59) hour to second) - datetime(00:00) hour to minute)) THEN sga_fec_insc_llam.fecha_tope_bajas
                                  ELSE (EXTEND(sga_prestamos.fecha, YEAR TO SECOND) + (NVL(sga_prestamos.hora_inicio, datetime(23:59:59) hour to second) - datetime(00:00) hour to minute))
                                END
                            END, '%d/%m/%Y %H:%M') as f_tope_baja_mesa,



                    
                    to_char(sga_fec_insc_llam.fecha_tope_bajas, '%d/%m/%Y %H:%M') as f_tope_bajas_llam,
				    
                    to_char(sga_llamados.fecha_inicio, '%d/%m/%Y') as f_inicio_llamado,
                    to_char(sga_llamados.fecha_fin, '%d/%m/%Y') as f_fin_llamado,
                    sga_edificios.nombre || ' - ' || sga_aulas.nombre_aula as edificio_aula
                    
               FROM 
                    sga_turnos_examen,
                    sga_mesas_examen,
                    sga_materias,
                    sga_llamados_mesa,
                    sga_llamados,
                    sga_prestamos,
                    sga_fec_insc_llam,
                    OUTER sga_carreras,
                    OUTER sga_grupos_carrera,
                    OUTER sga_exep_insc_llam,
                    OUTER (sga_edificios, sga_aulas)

              WHERE
                    sga_turnos_examen.fecha_fin         >= TODAY
                AND (sga_turnos_examen.fecha_public_mesas <= TODAY)
                AND sga_mesas_examen.unidad_academica   = {$parametros['_ua']}
                AND sga_mesas_examen.anio_academico     = sga_turnos_examen.anio_academico
                AND sga_mesas_examen.turno_examen       = sga_turnos_examen.turno_examen
                AND sga_materias.unidad_academica       = sga_mesas_examen.unidad_academica
                AND sga_materias.materia                = sga_mesas_examen.materia
                AND sga_llamados_mesa.unidad_academica  = sga_mesas_examen.unidad_academica
                AND sga_llamados_mesa.anio_academico    = sga_mesas_examen.anio_academico
                AND sga_llamados_mesa.turno_examen      = sga_mesas_examen.turno_examen
                AND sga_llamados_mesa.materia           = sga_mesas_examen.materia
                AND sga_llamados_mesa.mesa_examen       = sga_mesas_examen.mesa_examen
                AND sga_llamados_mesa.prestamo          = sga_prestamos.prestamo
                AND sga_llamados_mesa.habilitado        = 'S'

                AND sga_llamados_mesa.anio_academico    = sga_llamados.anio_academico
                AND sga_llamados_mesa.turno_examen      = sga_llamados.turno_examen
                AND sga_llamados_mesa.llamado           = sga_llamados.llamado

                AND sga_fec_insc_llam.anio_academico    = sga_llamados_mesa.anio_academico
                AND sga_fec_insc_llam.turno_examen      = sga_llamados_mesa.turno_examen
                AND sga_fec_insc_llam.llamado           = sga_llamados_mesa.llamado

                AND sga_carreras.unidad_academica       = sga_mesas_examen.unidad_academica
                AND sga_carreras.carrera                = sga_mesas_examen.carrera

                AND sga_grupos_carrera.unidad_academica = sga_mesas_examen.unidad_academica
                AND sga_grupos_carrera.grupo_carrera    = sga_mesas_examen.grupo_carrera

                AND sga_exep_insc_llam.unidad_academica = sga_llamados_mesa.unidad_academica
                AND sga_exep_insc_llam.materia          = sga_llamados_mesa.materia
                AND sga_exep_insc_llam.anio_academico   = sga_llamados_mesa.anio_academico
                AND	sga_exep_insc_llam.turno_examen     = sga_llamados_mesa.turno_examen
                AND	sga_exep_insc_llam.mesa_examen      = sga_llamados_mesa.mesa_examen
                AND sga_exep_insc_llam.llamado          = sga_llamados_mesa.llamado

                AND sga_edificios.edificio = sga_prestamos.edificio
                AND sga_aulas.edificio = sga_prestamos.edificio
                AND sga_aulas.aula = sga_prestamos.aula

                $filtro_materia
                $filtro_carrera
                $filtro_plan
                $filtro_tipo_insc
                $filtro_fecha_desde
                $filtro_fecha_hasta

          ORDER BY 7, 9, 10";

        $datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);

        return $datos;
    }

     /**
     * parametros: _ua, anio_academico, periodo_lectivo, materia, turno, sede, dia, carrera, anio_cursada
     * cache: no
     * filas: n
     */
    function horarios_cursadas($parametros)
    {
        // Lista las comisiones de un período lectivo, mostrando el aula, horario de cursada, tipo de clase, etc

        // Filtros
        $filtro_sede = '';
        if ($parametros['sede'] != "''"){
            $filtro_sede = " AND sga_comisiones.sede = {$parametros['sede']} ";
        }

        $filtro_carrera = '';
        if ($parametros['carrera'] != "''"){
            $filtro_carrera = " AND sga_comisiones.materia IN (SELECT DISTINCT materia FROM sga_atrib_mat_plan WHERE unidad_academica = {$parametros['_ua']} AND carrera = {$parametros['carrera']}) ";
        }

        $filtro_materia = '';
        if ($parametros['materia'] != "''"){
            $filtro_materia = " AND sga_comisiones.materia = {$parametros['materia']} ";
        }
        $filtro_periodo_lectivo = '';
        if ($parametros['periodo_lectivo'] != "''"){
            $filtro_periodo_lectivo = " AND sga_periodos_lect.periodo_lectivo = {$parametros['periodo_lectivo']} ";
        }

        $filtro_anio_de_cursada = '';
        if ($parametros['anio_cursada'] != "''"){
            $filtro_anio_de_cursada = " AND sga_comisiones.materia IN (SELECT DISTINCT materia FROM sga_atrib_mat_plan WHERE anio_de_cursada = {$parametros['anio_cursada']}) ";
        }

        $filtro_turno = '';
        if ($parametros['turno'] != "''"){
            $filtro_turno = " AND sga_comisiones.turno = {$parametros['turno']} ";
        }
         $filtro_dia_semana = '';
         if ($parametros['dia'] != "''"){
            $filtro_dia_semana = " AND sga_asignaciones.dia_semana = {$parametros['dia']} ";
         }

        
        // Consulta de comisiones 
        // Ordenado por: nombre_sede + fecha inicio periodo_lectivo + periodo lectivo + nombre_materia + nombre comision + dia semana + hora inicio clase
        $sql = "SELECT 
                     sga_comisiones.comision as comision, 
                     sga_comisiones.nombre as comision_nombre, 
                     sga_comisiones.periodo_lectivo as periodo_lectivo, 
                     sga_comisiones.materia as materia, 
                     sga_materias.nombre as materia_nombre,
                     sga_materias.nombre_reducido as materia_nombre_red,
                     sga_comisiones.turno as turno, 
                     DECODE(sga_comisiones.turno,'M', 'Mañana','T','Tarde','N','Noche',' ') as turno_desc,
                     sga_comisiones.sede as sede,
                     sga_sedes.nombre as sede_nombre,
                     sga_comisiones.capacidad as cupo,
                     sga_comisiones.grupo_carrera as grupo_carrera,
                     sga_comisiones.carrera as carrera,
                     sga_comisiones.plan as plan,
                     
                     -- datos de la asignacion
                     sga_asignaciones.edificio as edificio,
                     sga_asignaciones.aula as aula,
                     sga_aulas.nombre_aula as aula_nombre,
                     sga_asignaciones.dia_semana as dia_semana,
                     DECODE (sga_asignaciones.dia_semana, 1, 'Domingo', 2, 'Lunes', 3, 'Martes', 4, 'Miércoles', 5, 'Jueves', 6, 'Viernes', 7, 'Sábado') as dia_semana_desc,
                     to_char(sga_asignaciones.hs_comienzo_clase, '%H:%M') as hs_comienzo_clase,
                     to_char(sga_asignaciones.hs_finaliz_clase, '%H:%M') as hs_finaliz_clase,
                     NVL(to_char(sga_asignaciones.hs_comienzo_clase, '%H:%M'), '     ') || ' - ' || NVL(to_char(sga_asignaciones.hs_finaliz_clase, '%H:%M'),'     ') as inicio_fin_clase,
                     sga_tipo_clase.descripcion as tipo_clase_desc,
                     sga_periodos_lect.fecha_inicio as pl_fecha_inicio,
					 sga_comisiones.capacidad as cupo

                  FROM sga_periodos_lect,
                       sga_comisiones,
                       sga_materias,
                       sga_asign_clases, 
                       sga_asignaciones,
					   sga_sedes,
                       OUTER sga_tipo_clase,
                       OUTER sga_aulas
                 WHERE sga_periodos_lect.anio_academico  = {$parametros['anio_academico']}
                   AND sga_comisiones.anio_academico  = sga_periodos_lect.anio_academico
                   AND sga_comisiones.periodo_lectivo = sga_periodos_lect.periodo_lectivo
                   AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
                   AND sga_materias.materia = sga_comisiones.materia
                   AND sga_asign_clases.comision   = sga_comisiones.comision
				   AND sga_sedes.sede = sga_comisiones.sede 
                   AND sga_asignaciones.asignacion = sga_asign_clases.asignacion
                   AND sga_tipo_clase.tipo_clase = sga_asign_clases.tipo_clase
                   AND sga_aulas.edificio = sga_asignaciones.edificio
                   AND sga_aulas.aula     = sga_asignaciones.aula
                   AND sga_periodos_lect.fecha_public_com <= TODAY
                   $filtro_sede
                   $filtro_carrera
                   $filtro_periodo_lectivo
                   $filtro_materia
                   $filtro_turno
				   $filtro_dia_semana
                   $filtro_anio_de_cursada
               ORDER BY 10, 24, 3, 5, 2, 18, 20
               ";
        $datos = kernel::db()->consultar($sql, db::FETCH_ASSOC);
		$aux = array();


		foreach($datos as $dato){			
			$aux[$dato['SEDE']]['SEDE']			= $dato['SEDE']; 
			$aux[$dato['SEDE']]['SEDE_NOMBRE']	= $dato['SEDE_NOMBRE']; 
			$aux[$dato['SEDE']]['PERIODOS_LECTIVOS'][$dato['PERIODO_LECTIVO']]['PERIODO_LECTIVO']= $dato['PERIODO_LECTIVO']; 
			$aux[$dato['SEDE']]['PERIODOS_LECTIVOS'][$dato['PERIODO_LECTIVO']]['MATERIAS'][$dato['MATERIA']]['MATERIA']= $dato['MATERIA']; 
			$aux[$dato['SEDE']]['PERIODOS_LECTIVOS'][$dato['PERIODO_LECTIVO']]['MATERIAS'][$dato['MATERIA']]['MATERIA_NOMBRE']= $dato['MATERIA_NOMBRE']; 
			$aux[$dato['SEDE']]['PERIODOS_LECTIVOS'][$dato['PERIODO_LECTIVO']]['MATERIAS'][$dato['MATERIA']]['HORARIOS'][]= array(
					'COMISION'				=> $dato['COMISION'],	
					'COMISION_NOMBRE'		=> $dato['COMISION_NOMBRE'],	
					'TURNO'					=> $dato['TURNO'],	
					'TURNO_DESC'			=> $dato['TURNO_DESC'],
					'EDIFICIO'				=> $dato['EDIFICIO'],	
					'AULA'					=> $dato['AULA'],	
					'AULA_NOMBRE'			=> $dato['AULA_NOMBRE'],	
					'DIA_SEMANA'			=> $dato['DIA_SEMANA'],	
					'DIA_SEMANA_DESC'		=> $dato['DIA_SEMANA_DESC'],	
					'HS_COMIENZO_CLASE'		=> $dato['HS_COMIENZO_CLASE'],	
					'HS_COMIENZO_CLASE'		=> $dato['HS_COMIENZO_CLASE'],	
					'HS_FINALIZ_CLASE'		=> $dato['HS_FINALIZ_CLASE'],	
					'INICIO_FIN_CLASE'		=> $dato['INICIO_FIN_CLASE'],	
					'TIPO_CLASE_DESC'		=> $dato['TIPO_CLASE_DESC'],
					'PL_FECHA_INICIO'		=> $dato['PL_FECHA_INICIO'],
					'CUPO'					=> $dato['CUPO'],
			); 

		}
				
        return $aux;
    }



} 
