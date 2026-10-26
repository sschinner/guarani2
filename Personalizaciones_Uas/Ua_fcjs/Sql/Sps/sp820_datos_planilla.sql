CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_datos_planilla') THEN
		DROP PROCEDURE sp820_datos_planilla;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Procedure: sp820_datos_planilla
-- Versión 2.03.0
-- Ultima Modificacion: V2.6.0, 2.9.1, 2.9.2
-- Devuelve los datos que corresponden a la planilla de asistencia, todos o menos los que quedaron libres por inasistencias
-- pestado_asistencia = L - Libre / T - Todos
-- *******************************************************************************
-- DROP PROCEDURE "dba".sp820_datos_planilla;
CREATE PROCEDURE "dba".sp820_datos_planilla ( 
	pcomision like sga_comisiones.comision, 
	psubcomision like sga_subcomisiones.subcomision, 
	pfecha varchar(10), 
	pCantClases int, 
	pestado_asistencia char(1),
	pTipoClase varchar(5)) 
	
RETURNING integer, date, varchar(5),varchar(255), varchar(5), varchar(255), varchar(15), varchar(15), 
	varchar(10), integer, varchar(20), varchar(255), varchar(255), varchar(62),
	varchar(5), varchar(5), varchar(15), date, date, date, date, date, decimal(5,2), integer, varchar(15), varchar(5), varchar(255) ;


DEFINE vFecha	date;
DEFINE v_materia_nombre	LIKE sga_materias.nombre;
DEFINE v_comision_nombre	LIKE sga_comisiones.nombre;
DEFINE v_carrera_nombre	LIKE sga_carreras.nombre;
DEFINE v_catedra	LIKE sga_comisiones.catedra;
DEFINE v_docentes	varchar(255);
DEFINE v_alumno	varchar(62);
DEFINE v_aula	varchar(255);
DEFINE v_turno	varchar(10);
DEFINE v_fecha1, v_fecha2, v_fecha3, v_fecha4, v_fecha5	date; 
DEFINE v_legajo	LIKE sga_alumnos.legajo;
DEFINE v_acumuladas LIKE sga_inasis_acum.cant_acumuladas;
DEFINE v_tramo LIKE sga_inasis_tramos.tramo;
DEFINE v_anio_academico LIKE sga_comisiones.anio_academico;
DEFINE v_periodo_lectivo LIKE sga_comisiones.periodo_lectivo;
DEFINE v_ua LIKE sga_comisiones.unidad_academica;
DEFINE v_materia LIKE sga_comisiones.materia;
DEFINE v_carrera,v_carrera_com LIKE sga_comisiones.carrera;
DEFINE v_estado	char(1);
DEFINE v_sub_nombre LIKE sga_subcomisiones.nombre;
DEFINE v_sede LIKE sga_sedes.sede;
DEFINE v_nomsede LIKE sga_sedes.nombre;
DEFINE vc_apellido like sga_personas.apellido;
DEFINE vc_nombres like sga_personas.nombres;


BEGIN

-- pestado_asistencia = L - Libre / T - Todos
LET v_sub_nombre = null;
LET vFecha = to_date(pFecha, "%d-%m-%Y");  -- La fecha viene en este formato: dd-mm-yyyy

IF TRIM(pTipoClase) = '' THEN
   LET pTipoClase = NULL;
END IF;

-- Recupero datos de la comision.
SELECT dba.sga_comisiones.nombre,
 	dba.sga_comisiones.anio_academico, 
 	dba.sga_comisiones.periodo_lectivo, 
	dba.sga_comisiones.materia,
	dba.sga_materias.nombre,
	dba.sga_comisiones.unidad_academica,
	dba.sga_comisiones.carrera,
	dba.sga_comisiones.catedra,
	dba.sga_comisiones.turno,
	dba.sga_sedes.nombre,
	dba.sga_sedes.sede
INTO v_comision_nombre,
     v_anio_academico, 
     v_periodo_lectivo,
     v_materia,
     v_materia_nombre,
     v_ua,
     v_carrera_com,
     v_catedra,
     v_turno,
     v_nomsede,
     v_sede
FROM 
	dba.sga_comisiones,   
	dba.sga_materias,
	dba.sga_sedes
WHERE
	dba.sga_comisiones.comision = pcomision AND
	dba.sga_materias.unidad_academica = dba.sga_comisiones.unidad_academica AND
	dba.sga_materias.materia          = dba.sga_comisiones.materia AND
	dba.sga_comisiones.sede = dba.sga_sedes.sede;

IF v_carrera_com <> 'TODOS' THEN
	SELECT sga_carreras.nombre
	INTO v_carrera_nombre
	FROM sga_carreras
	WHERE dba.sga_carreras.unidad_academica = v_ua AND
	sga_carreras.carrera = v_carrera_com;
ELSE
	LET v_carrera_com = 'TODAS';
	LET v_carrera_nombre = 'TODAS';
END IF;

LET v_tramo = NULL;
SELECT sga_inasis_tramos.tramo
INTO v_tramo
FROM sga_inasis_tramos
WHERE sga_inasis_tramos.anio_academico = v_anio_academico and
	sga_inasis_tramos.periodo_lectivo = v_periodo_lectivo AND
	TODAY BETWEEN sga_inasis_tramos.fecha_desde AND sga_inasis_tramos.fecha_hasta;

IF ( psubcomision IS NULL ) OR ( psubcomision = '' ) THEN	
    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- Recupero clases de la comision
    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++
	EXECUTE PROCEDURE sp_docentes_com(pcomision) INTO v_docentes;
	EXECUTE PROCEDURE sp_asignac_com(pcomision, pTipoClase) INTO v_aula;
	EXECUTE PROCEDURE sp_fecha_siguiente (pcomision, vFecha, pCantClases, pTipoClase) INTO v_fecha1, v_fecha2, v_fecha3, v_fecha4, v_fecha5;

	FOREACH
		SELECT TRIM(dba.sga_personas.apellido) || ', ' || TRIM(dba.sga_personas.nombres),
		          dba.sga_alumnos.carrera,
		          dba.sga_alumnos.legajo,
		          dba.sga_inasis_acum.cant_acumuladas,
		          dba.sga_inasis_acum.estado,
			upper(dba.sga_personas.apellido),
			Upper(dba.sga_personas.nombres)
		INTO v_alumno,
		          v_carrera,
		          v_legajo,
		          v_acumuladas,
		          v_estado,
			vc_apellido,
			vc_nombres
		FROM 	--dba.sga_insc_cursadas,
			dba.sga_curs_pendiente, 
			dba.sga_alumnos,   
			dba.sga_personas,   
			OUTER dba.sga_inasis_acum   
		WHERE 	--dba.sga_insc_cursadas.comision = pcomision AND
			dba.sga_curs_pendiente.comision = pcomision AND
			--dba.sga_alumnos.unidad_academica = dba.sga_insc_cursadas.unidad_academica AND
			dba.sga_alumnos.unidad_academica = dba.sga_curs_pendiente.unidad_academica AND
			--dba.sga_alumnos.carrera = dba.sga_insc_cursadas.carrera AND
			dba.sga_alumnos.carrera = dba.sga_curs_pendiente.carrera AND
			--dba.sga_alumnos.legajo  = dba.sga_insc_cursadas.legajo AND
			dba.sga_alumnos.legajo  = dba.sga_curs_pendiente.legajo AND
			dba.sga_personas.unidad_academica = dba.sga_alumnos.unidad_academica AND
			dba.sga_personas.nro_inscripcion  = dba.sga_alumnos.nro_inscripcion AND
			--dba.sga_insc_cursadas.unidad_academica = dba.sga_inasis_acum.unidad_academica  AND
			dba.sga_curs_pendiente.unidad_academica = dba.sga_inasis_acum.unidad_academica  AND
			--dba.sga_insc_cursadas.carrera = dba.sga_inasis_acum.carrera  AND
			dba.sga_curs_pendiente.carrera = dba.sga_inasis_acum.carrera  AND
			--dba.sga_insc_cursadas.legajo = dba.sga_inasis_acum.legajo  AND
			dba.sga_curs_pendiente.legajo = dba.sga_inasis_acum.legajo  AND	
			--dba.sga_insc_cursadas.comision = dba.sga_inasis_acum.comision  AND
			dba.sga_curs_pendiente.comision = dba.sga_inasis_acum.comision  AND
			dba.sga_inasis_acum.tramo = v_tramo 
		ORDER BY 6,7

		-- Controlo aca el estado de la inasistencias, porque puede ser que el registro no exista para ese alumno.
		IF v_estado IS NULL OR pestado_asistencia = 'T' OR v_estado <> pestado_asistencia  THEN
		   RETURN pcomision, vFecha,v_carrera_com, v_carrera_nombre, v_materia, v_materia_nombre, v_comision_nombre, v_periodo_lectivo,	v_turno, v_anio_academico, v_catedra, v_docentes, v_aula, v_alumno, v_ua, v_carrera,v_legajo, v_fecha1, v_fecha2, v_fecha3, v_fecha4, v_fecha5, v_acumuladas, psubcomision, v_sub_nombre, v_sede, v_nomsede   		                    WITH RESUME;	
		END IF;
	END FOREACH;
ELSE
    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    -- Recupero clases de la subcomision.
    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	EXECUTE PROCEDURE sp_docentes_subcom(pcomision, psubcomision) INTO v_docentes;
	EXECUTE PROCEDURE sp_asignac_sub(pcomision, psubcomision, pTipoClase) INTO v_aula;
	EXECUTE PROCEDURE sp_fecha_sig_sub(pcomision, psubcomision, vFecha, pCantClases, pTipoClase) INTO v_fecha1, v_fecha2, v_fecha3, v_fecha4, v_fecha5;

	SELECT sga_subcomisiones.nombre
	INTO v_sub_nombre
	FROM sga_subcomisiones
	WHERE sga_subcomisiones.comision = pcomision AND
		sga_subcomisiones.subcomision = psubcomision;

	FOREACH
		SELECT TRIM(dba.sga_personas.apellido) || ', ' || TRIM(dba.sga_personas.nombres),
		          dba.sga_alumnos.carrera,
		          dba.sga_alumnos.legajo,
		          dba.sga_inasis_acum.cant_acumuladas,
		          dba.sga_inasis_acum.estado,
			upper(dba.sga_personas.apellido),
			Upper(dba.sga_personas.nombres)
		INTO v_alumno,
		          v_carrera,
		          v_legajo,
		          v_acumuladas,
		          v_estado,
			vc_apellido,
			vc_nombres
		FROM 	dba.sga_insc_subcom,
			dba.sga_alumnos,   
			dba.sga_personas,   
			OUTER dba.sga_inasis_acum   
		WHERE 	dba.sga_insc_subcom.comision = pcomision AND
			dba.sga_insc_subcom.subcomision = psubcomision AND 
			dba.sga_alumnos.unidad_academica = dba.sga_insc_subcom.unidad_academica AND
			dba.sga_alumnos.carrera = dba.sga_insc_subcom.carrera AND
			dba.sga_alumnos.legajo  = dba.sga_insc_subcom.legajo AND
			dba.sga_personas.unidad_academica = dba.sga_alumnos.unidad_academica AND
			dba.sga_personas.nro_inscripcion  = dba.sga_alumnos.nro_inscripcion AND
			dba.sga_insc_subcom.unidad_academica = dba.sga_inasis_acum.unidad_academica  AND
			dba.sga_insc_subcom.carrera = dba.sga_inasis_acum.carrera  AND
			dba.sga_insc_subcom.legajo = dba.sga_inasis_acum.legajo  AND
			dba.sga_insc_subcom.comision = dba.sga_inasis_acum.comision AND
			dba.sga_inasis_acum.tramo = v_tramo 
		ORDER BY 6,7

		-- Controlo aca el estado de la inasistencias, porque puede ser que el registro no exista para ese alumno.
		IF v_estado IS NULL OR pestado_asistencia = 'T' OR v_estado <> pestado_asistencia  THEN
		   RETURN pcomision, vFecha,v_carrera_com, v_carrera_nombre, v_materia, v_materia_nombre, v_comision_nombre, v_periodo_lectivo, 	v_turno, v_anio_academico, v_catedra, 			   v_docentes, v_aula, v_alumno,  v_ua, v_carrera,v_legajo, v_fecha1, v_fecha2, v_fecha3, v_fecha4, v_fecha5, v_acumuladas, psubcomision, v_sub_nombre, v_sede, v_nomsede  		                   WITH RESUME;	
		END IF;
	END FOREACH;
END IF;

END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp820_datos_planilla  *******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_datos_planilla  
-- *****************************************************************************
revoke execute on "dba".sp820_datos_planilla from public;
grant execute on "dba".sp820_datos_planilla to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_datos_planilla to internet; -- Rol de usuario de Internet