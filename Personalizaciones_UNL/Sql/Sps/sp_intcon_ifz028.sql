CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_intcon_ifz028') THEN
		DROP PROCEDURE sp_intcon_ifz028;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".sp_intcon_ifz028( pUnidadAcademica VARCHAR(5), pCarrera VARCHAR(5), pMateria VARCHAR(5), pAnioDesde INTEGER, pAnioHasta INTEGER)

       RETURNING VARCHAR(5),   -- unidad_academica
                 VARCHAR(5),   -- materia
               VARCHAR(60),  -- nombre materia
                 INTEGER,      -- anio
                 INTEGER,      -- Cantidad de Alumnos inscriptos a cursar materias
                 INTEGER,      -- Cantidad de alumnos que aprobaron la cursada
                 INTEGER,      -- Cantidad de alumnos que quedaron libres en la cursada
                 INTEGER,      -- Cantidad de alumnos que abandonaron la cursada
                 INTEGER,      -- Cantidad de alumnos que reprobaron la cursada
                 INTEGER,      -- Cantidad de alumnos que promocionaron la cursada (sin examen final) ????
                VARCHAR(5),   -- carrera
	VARCHAR(255), -- nombre de la carrera
	VARCHAR(10), -- cursante o recursante
	VARCHAR(5); -- plan

-- Variables locales
DEFINE iAnio             INTEGER;
DEFINE cnt_inscriptos    INTEGER;
DEFINE cnt_aprobados     INTEGER;
DEFINE cnt_libres     INTEGER;
DEFINE cnt_abandono     INTEGER;
DEFINE cnt_reprobados    INTEGER;
DEFINE cnt_promovidos    INTEGER;
DEFINE cnt_ausentes      INTEGER;
DEFINE vNombreMateria    LIKE sga_materias.nombre;
define vc_nombre_carrera VARCHAR(255);
define vc_cursante VARCHAR(10);
define vc_plan varchar(5);

-- Variables para el manejo de excepciones
DEFINE SQLErr            INTEGER;
DEFINE ISAMError         INTEGER;
DEFINE errorInfo         VARCHAR(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        

   RAISE EXCEPTION
 SQLErr, ISAMError, errorInfo;

END EXCEPTION;

BEGIN
-- busco el nombre de la materia

SELECT nombre
	INTO vNombreMateria
	FROM sga_materias
	WHERE unidad_academica = pUnidadAcademica
		AND materia = pMateria; 
-- busco el nombre de la carrera   

SELECT nombre 
	INTO vc_nombre_carrera
	FROM sga_carreras
	WHERE unidad_academica=pUnidadAcademica
		AND carrera = pCarrera;

-- dropeo las temporarias por si existen
BEGIN
on exception in (-206)
	-- tabla no existe
end exception with resume;

drop table todos_iese;
drop table agrupados_iese;

END

create temp table todos_iese (
	unidad_academica varchar(5), 
	carrera varchar(5), 
	plan varchar(5), 
	legajo varchar(15), 
	anio_academico integer, 
	fecha_inicio date, 
	resultado varchar(9), 
	cursantes varchar(10)
	) with no log;

create temp table agrupados_iese (
	anio_academico integer, 
	plan varchar(5), 
	cursantes varchar(10), 
	inscriptos integer,
	aprobados integer,
	libres integer, -- condicion de regularidad obtenida: 1
	abandono integer, -- condicion de regularidad obtenida: 2
	reprobados integer, -- condicion de regularidad obtenida: 3
	promovidos integer
	) with no log;

-- tomo todos los alumnos que me interesa procesar

insert into todos_iese
--SELECT sdac.unidad_academica, sdac.carrera, sdac.plan, legajo, sc.anio_academico, fecha_inicio, decode(sdac.resultado, 'A','Aprobado','P','Promovido','Reprobado') resultado, 'Cursante' cursantes
SELECT sdac.unidad_academica, sdac.carrera, sdac.plan, legajo, sc.anio_academico, fecha_inicio, decode(sdac.cond_regularidad, 1, 'Libre', 2, 'Abandono', 4, 'Aprobado', 5, 'Promovido',  6, 'Aprobado', 7, 'Promovido', 9, 'Aprobado', 10, 'Aprobado', 'Reprobado') resultado, 'Cursante' cursantes

	FROM sga_comisiones sc,
		sga_actas_cursado sac,
		sga_det_acta_curs sdac,
		sga_periodos_lect spl
	WHERE sc.unidad_academica = pUnidadAcademica
		AND sc.anio_academico   between pAnioDesde and pAnioHasta
		AND sc.materia          = pMateria
		AND sac.unidad_academica = sc.unidad_academica
		AND sac.comision         = sc.comision
		AND sac.estado           = 'C' -- Solo cuento las actas crradas
		AND sdac.unidad_academica = sac.unidad_academica
		AND sdac.acta             = sac.acta
		AND sdac.estado           = 'A' -- Verifico que el detalle de acta no este invalidado
		AND sdac.carrera          = pCarrera
		AND sc.anio_academico = spl.anio_academico
		AND sc.periodo_lectivo = spl.periodo_lectivo
		and not exists (   SELECT ''
			FROM sga_comisiones sc1,
				sga_actas_cursado sac1,
				sga_det_acta_curs sdac1,
				sga_periodos_lect spl1
				WHERE sc1.unidad_academica = sc.unidad_academica

				AND sc1.anio_academico <= sc.anio_academico
				AND sc1.materia          = sc.materia
				AND sac1.unidad_academica = sc1.unidad_academica
				AND sac1.comision         = sc1.comision
				AND sac1.estado           = 'C' -- Solo cuento las actas cerradas
				AND sdac1.unidad_academica = sac1.unidad_academica
				AND sdac1.acta             = sac1.acta
				AND sdac1.estado           = 'A' -- Verifico que el detalle de acta no este invalidado

				AND sdac1.carrera          = sdac.carrera
				AND sdac1.legajo = sdac.legajo
				AND sc1.anio_academico = spl1.anio_academico
				AND sc1.periodo_lectivo = spl1.periodo_lectivo
				AND spl1.fecha_inicio < spl.fecha_inicio	);

insert into todos_iese
--SELECT sdac.unidad_academica, sdac.carrera, sdac.plan, legajo, sc.anio_academico, fecha_inicio, decode(sdac.resultado, 'A','Aprobado','P','Promovido','Reprobado'), 'Recursante' 
SELECT sdac.unidad_academica, sdac.carrera, sdac.plan, legajo, sc.anio_academico, fecha_inicio, decode(sdac.cond_regularidad, 1, 'Libre', 2, 'Abandono', 4, 'Aprobado', 5, 'Promovido',  6, 'Aprobado', 7, 'Promovido', 9, 'Aprobado', 10, 'Aprobado', 'Reprobado'), 'Recursante' 
	FROM sga_comisiones sc,
		sga_actas_cursado sac,
		sga_det_acta_curs sdac,
		sga_periodos_lect spl
	WHERE sc.unidad_academica = pUnidadAcademica
		AND sc.anio_academico   between pAnioDesde and pAnioHasta
		AND sc.materia          = pMateria

		AND sac.unidad_academica = sc.unidad_academica
		AND sac.comision         = sc.comision
		AND sac.estado           = 'C' -- Solo cuento las actas cerradas
		AND sdac.unidad_academica = sac.unidad_academica
		AND sdac.acta             = sac.acta
		AND sdac.estado           = 'A' -- Verifico que el detalle de acta no este invalidado

		AND sdac.carrera          = pCarrera
		AND sc.anio_academico = spl.anio_academico
		AND sc.periodo_lectivo = spl.periodo_lectivo

		and exists (   SELECT ''
			FROM sga_comisiones sc1,
				sga_actas_cursado sac1,
				sga_det_acta_curs sdac1,
				sga_periodos_lect spl1
			WHERE sc1.unidad_academica = sc.unidad_academica
				AND sc1.anio_academico <= sc.anio_academico
				AND sc1.materia          = sc.materia
				AND sac1.unidad_academica = sc1.unidad_academica
				AND sac1.comision         = sc1.comision
				AND sac1.estado           = 'C' -- Solo cuento las actas cerradas
				AND sdac1.unidad_academica = sac1.unidad_academica
				AND sdac1.acta             = sac1.acta
				AND sdac1.estado           = 'A' -- Verifico que el detalle de acta no este invalidado
				AND sdac1.carrera          = sdac.carrera
				AND sdac1.legajo = sdac.legajo
				AND sc1.anio_academico = spl1.anio_academico
				AND sc1.periodo_lectivo = spl1.periodo_lectivo
				AND spl1.fecha_inicio < spl.fecha_inicio);

-- tomo los inscriptos puesto que salen de la tabla sga_insc_cursadas

insert into agrupados_iese (anio_academico, plan, cursantes, inscriptos)
SELECT sc.anio_academico, sic.plan, 'Cursante' , count(*)
	FROM sga_comisiones sc,
		sga_insc_cursadas sic,
		sga_periodos_lect spl
	WHERE sc.unidad_academica = pUnidadAcademica
		AND sc.anio_academico   between pAnioDesde and pAnioHasta
		AND sc.materia          = pMateria
		AND sic.unidad_academica = sc.unidad_academica
		AND sic.comision         = sc.comision
		AND sic.carrera          = pCarrera
		AND sc.anio_academico = spl.anio_academico
		AND sc.periodo_lectivo = spl.periodo_lectivo
		and not exists (   SELECT ''
			FROM sga_comisiones sc1,
				sga_actas_cursado sac1,
				sga_det_acta_curs sdac1,
				sga_periodos_lect spl1
			WHERE sc1.unidad_academica = sc.unidad_academica
				AND sc1.anio_academico <= sc.anio_academico
				AND sc1.materia          = sc.materia
				AND sac1.unidad_academica = sc1.unidad_academica
				AND sac1.comision         = sc1.comision
				AND sac1.estado           = 'C' -- Solo cuento las actas cerradas
				AND sdac1.unidad_academica = sac1.unidad_academica
				AND sdac1.acta             = sac1.acta
				AND sdac1.estado           = 'A' -- Verifico que el detalle de acta no este invalidado
				AND sdac1.carrera       = sic.carrera
				AND sdac1.legajo = sic.legajo
				AND sc1.anio_academico = spl1.anio_academico
				AND sc1.periodo_lectivo = spl1.periodo_lectivo
				AND spl1.fecha_inicio < spl.fecha_inicio	)

	GROUP BY 1,2;

insert into agrupados_iese (anio_academico, plan, cursantes, inscriptos)

SELECT sc.anio_academico, sic.plan, 'Recursante' , count(*)
	FROM sga_comisiones sc,
		sga_insc_cursadas sic,
		sga_periodos_lect spl
	WHERE sc.unidad_academica = pUnidadAcademica
		AND sc.anio_academico   between pAnioDesde and pAnioHasta
		AND sc.materia          = pMateria
		AND sic.unidad_academica = sc.unidad_academica
		AND sic.comision         = sc.comision
		AND sic.carrera          = pCarrera
		AND sc.anio_academico = spl.anio_academico
		AND sc.periodo_lectivo = spl.periodo_lectivo
		and exists (   SELECT ''
			FROM sga_comisiones sc1,
				sga_actas_cursado sac1,
				sga_det_acta_curs sdac1,
				sga_periodos_lect spl1
			WHERE sc1.unidad_academica = sc.unidad_academica
				AND sc1.anio_academico <= sc.anio_academico
				AND sc1.materia          = sc.materia
				AND sac1.unidad_academica = sc1.unidad_academica
				AND sac1.comision         = sc1.comision
				AND sac1.estado         = 'C' -- Solo cuento las actas cerradas
				AND sdac1.unidad_academica = sac1.unidad_academica
				AND sdac1.acta             = sac1.acta
				AND sdac1.estado           = 'A' -- Verifico que el detalle de acta no este invalidado
				AND sdac1.carrera          = sic.carrera
				AND sdac1.legajo = sic.legajo
				AND sc1.anio_academico = spl1.anio_academico
				AND sc1.periodo_lectivo = spl1.periodo_lectivo
				AND spl1.fecha_inicio < spl.fecha_inicio	)
	GROUP BY 1,2;

insert into agrupados_iese (anio_academico, plan, cursantes, aprobados)
SELECT anio_academico, plan, cursantes, count(legajo)
	FROM todos_iese
	WHERE resultado = 'Aprobado'
	GROUP BY anio_academico, plan, cursantes;

insert into agrupados_iese (anio_academico, plan, cursantes, libres)
SELECT anio_academico, plan, cursantes, count(legajo)
	FROM todos_iese
	WHERE resultado = 'Libre'
	GROUP BY anio_academico, plan, cursantes;

insert into agrupados_iese (anio_academico, plan, cursantes, abandono)
SELECT anio_academico, plan, cursantes, count(legajo)
	FROM todos_iese
	WHERE resultado = 'Abandono'
	GROUP BY anio_academico, plan, cursantes;
	
insert into agrupados_iese (anio_academico, plan, cursantes, reprobados)
SELECT anio_academico, plan, cursantes, count(legajo)
	FROM todos_iese
	WHERE resultado = 'Reprobado'
	GROUP BY anio_academico, plan, cursantes;

insert into agrupados_iese (anio_academico, plan, cursantes, promovidos)
SELECT anio_academico, plan, cursantes, count(legajo)
	FROM todos_iese
	WHERE resultado = 'Promovido'
	GROUP BY anio_academico, plan, cursantes;
	
FOREACH

	SELECT anio_academico, plan, cursantes, sum(inscriptos), sum(aprobados), sum(libres), sum(abandono), sum(reprobados), sum(promovidos)

		INTO iAnio, vc_plan, vc_cursante, cnt_inscriptos, cnt_aprobados, cnt_libres, cnt_abandono, cnt_reprobados, cnt_promovidos
		FROM agrupados_iese
		GROUP BY anio_academico, plan, cursantes
		ORDER BY anio_academico, cursantes

	      RETURN pUnidadAcademica, pMateria,
vNombreMateria, iAnio, cnt_inscriptos, cnt_aprobados, cnt_libres, cnt_abandono, cnt_reprobados, cnt_promovidos, pCarrera, vc_nombre_carrera, vc_cursante, vc_plan WITH RESUME;	

END FOREACH;

END;

END PROCEDURE;

-- select * from sga_cond_regular;
-- execute PROCEDURE "dba".sp_intcon_ifz028( 'FCA', '001', '10020', 2013, 2013);

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_intcon_ifz028
-- *****************************************************************************
revoke execute on "dba".sp_intcon_ifz028 from public;
grant execute on "dba".sp_intcon_ifz028 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_intcon_ifz028 to internet; -- Rol de usuario de Internet