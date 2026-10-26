CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_posibles_eg') THEN
		DROP PROCEDURE sp820_posibles_eg;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ********************************************************
-- SIU - GUARANI: Sistema de Gestion Academica
-- PROCEDURE: "dba".sp820_posibles_eg;
-- Version: 
-- Ultima version de modificacion: 2.05.2
--
-- ********************************************************
CREATE PROCEDURE "dba".sp820_posibles_eg( pUA like sga_alumnos.unidad_academica, pCarrera like sga_alumnos.carrera, pFechadesde varchar(10), pFechahasta varchar(10) )
RETURNING 	
		varchar(10),		-- Unidad Academica
		varchar(10),		-- Nro. Inscripcion
		varchar(255), 		-- Nombre
		varchar(15), 		-- Legajo
		varchar(3), 		-- Tipo Documento
		decimal(15,0), 		-- Nro. Documento
		varchar(5), 		-- Carrera
		varchar(255), 		-- Nombre Carrera
		varchar(5), 		-- Plan
		varchar(5), 		-- Titulo
		varchar(255), 		-- Nombre Titulo
		varchar(5),		-- Orientacion
		varchar(255),		-- Nombre Orientacion
		varchar (5),		-- Estado Inicial del titulo
		varchar(15),                             -- Nivel
		date,
		varchar(50),	-- EMAIL	
		char(18),  		-- TELEFONO (PROC)
		varchar(50),	-- calle (PROC)
		varchar(5),	-- numero (PROC)
		varchar(3),	-- piso
		varchar(5),	-- dpto
		varchar(100),	-- localidad
		float,			-- Promedio con aplazos
		float;			-- Promedio sin aplazos 

-- inicializaciones.
---------------------------
DEFINE iStatus             SMALLINT;
DEFINE vcMsg                 VARCHAR(255);
DEFINE sql_err              INTEGER;
DEFINE isam_err             INTEGER;
DEFINE error_info           VARCHAR(70);

DEFINE vcNroInscripcion      LIKE sga_titulos_otorg.nro_inscripcion;
DEFINE vcTitulo                VARCHAR(5);
DEFINE vcPlan                VARCHAR(5);
DEFINE vcVersion             VARCHAR(5);
DEFINE vcOrientacion         VARCHAR(5);
DEFINE vcCiclo       VARCHAR(5);
DEFINE vcMateria VARCHAR(5);
DEFINE fpuntos FLOAT;



DEFINE fPromGral             LIKE sga_titulos_otorg.prom_general;
DEFINE fPromSinAplazos       LIKE sga_titulos_otorg.prom_sin_aplazos;


DEFINE dFechaEgresoFinal     DATE;

DEFINE dFDesde DATE;
DEFINE dFHasta DATE;

DEFINE ls_Ua  		LIKE  sga_alumnos.unidad_academica;
DEFINE ls_Carrera  		LIKE  sga_alumnos.carrera;
DEFINE ls_Titulo  		LIKE  sga_titulos_plan.titulo;
DEFINE ls_Legajo  		LIKE  sga_alumnos.legajo;
DEFINE ls_Plan  		LIKE  sga_alumnos.plan;

DEFINE ls_NombreAlumno  	Varchar(255);
DEFINE ls_TipoDoc  		LIKE  sga_personas.tipo_documento;
DEFINE ls_NroDoc  		LIKE  sga_personas.nro_documento;
DEFINE ls_CarreraNombre  	LIKE  sga_carreras.nombre;
DEFINE ls_TituloNombre  	LIKE  sga_titulos.nombre;
DEFINE ls_OrientNombre 	varchar(255);
DEFINE ls_Nivel		LIKE sga_titulos.nivel;
DEFINE ls_Orientacion VARCHAR(5);

DEFINE ls_Version VARCHAR(5);

DEFINE vemail varchar(50);
DEFINE vtel_proc char(18);
DEFINE vcalle_proc varchar(50);
DEFINE vnumero_proc varchar(5);
DEFINE vpiso_proc varchar(3);
DEFINE vdpto_proc varchar(5);
DEFINE vloc_proc varchar(100);


DEFINE ls_Estado		like sga_titulos_otorg.estado;

LET dFDesde = stringToDate( pFechadesde, '%d-%m-%Y');
LET dFHasta = stringToDate( pFechahasta, '%d-%m-%Y');
LET ls_Estado = 'A';
LET dFechaEgresoFinal = to_date("01011900","%d%m%Y");
LET vcOrientacion = NULL;


BEGIN
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Conjunto de alumnos que aprobaron una materia entre las fechas enviadas por parámetro
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
FOREACH WITH HOLD SELECT 
	sga_alumnos.unidad_academica,
                sga_alumnos.carrera,
                sga_alumnos.legajo,
                sga_titulos_plan.titulo,
	sga_alumnos.nro_inscripcion,
	sga_alumnos.plan
INTO ls_UA, ls_Carrera, ls_Legajo, ls_Titulo, vcNroInscripcion, ls_Plan 
FROM vw820_hist_academ vw,
	sga_alumnos,
                sga_titulos_plan
WHERE sga_alumnos.unidad_academica = pUA   
       	AND sga_alumnos.carrera = pCarrera  

	AND sga_alumnos.calidad = 'A'
	AND vw.carrera = sga_alumnos.carrera
	AND vw.legajo = sga_alumnos.legajo
	AND vw.resultado = 'A'

	AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
	AND sga_titulos_plan.carrera = sga_alumnos.carrera
	AND sga_titulos_plan.plan = sga_alumnos.plan
	AND NOT EXISTS (SELECT legajo FROM sga_titulos_otorg  
                                                               WHERE unidad_academica = sga_alumnos.unidad_academica
                                                                     AND nro_inscripcion = sga_alumnos.nro_inscripcion
                                                                     AND titulo =  sga_titulos_plan.titulo )

GROUP BY sga_alumnos.unidad_academica,
                sga_alumnos.carrera,
                sga_alumnos.legajo,
	sga_titulos_plan.titulo,
	sga_alumnos.nro_inscripcion,
	sga_alumnos.plan
HAVING max(fecha) BETWEEN dFDesde AND dFHasta 
ORDER BY sga_alumnos.unidad_academica, sga_alumnos.carrera


    -- Me fijo si el alumno es un egresado.
    FOREACH EXECUTE PROCEDURE sp_titulo_aprobado(ls_Ua, ls_Carrera, ls_Legajo, ls_Titulo ) INTO ls_Orientacion, ls_Plan, ls_Version 


	FOREACH EXECUTE PROCEDURE "dba".sp_insertar_titulo (ls_UA, ls_Carrera, ls_Legajo, ls_Titulo, 'S/N', 'P') Into vcTitulo, vcPlan, vcVersion, vcOrientacion, vcCiclo, vcMateria, fpuntos
	END FOREACH; -- titulos aprobados (en caso que tenga titulos intermedios)
	

		-- El estado del trámite es "-" ("No hay estado anterior" = Egresante)
		
		SELECT fecha_egreso, prom_general, prom_sin_aplazos INTO dFechaEgresoFinal, fPromGral, fPromSinAplazos 
		FROM sga_titulos_otorg 
		WHERE unidad_academica = ls_UA
			AND nro_inscripcion = vcNroInscripcion
			AND titulo = ls_Titulo;

		SELECT  TRIM(sga_personas.apellido) || ', ' || TRIM(sga_personas.nombres)  nombre_alumno,
			sga_personas.tipo_documento,
			sga_personas.nro_documento,
			sga_personas.nro_inscripcion,
			sga_carreras.nombre,
			sga_titulos.nombre,
			sga_orientaciones.nombre,
			sga_titulos.nivel,
			dba.sga_datos_censales.e_mail,
			dba.sga_datos_censales.te_proc,
			dba.sga_datos_censales.calle_proc,
			dba.sga_datos_censales.numero_proc,
			dba.sga_datos_censales.piso_proc,
			dba.sga_datos_censales.dpto_proc,
			dba.mug_localidades.nombre
		INTO  ls_NombreAlumno, ls_TipoDoc,  ls_NroDoc,  vcNroInscripcion, ls_CarreraNombre,  ls_TituloNombre, ls_OrientNombre, ls_Nivel, vemail, vtel_proc, vcalle_proc, vnumero_proc, vpiso_proc, vdpto_proc, vloc_proc     
		FROM sga_alumnos, 
			sga_personas,
			sga_carreras,
			sga_titulos,
			sga_titulos_plan,
			sga_orientaciones,
			sga_datos_censales,
			OUTER mug_localidades
		WHERE sga_alumnos.unidad_academica = ls_UA
			AND sga_alumnos.carrera = ls_Carrera
			AND sga_alumnos.legajo = ls_Legajo
			AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica
			AND sga_carreras.carrera 	    = sga_alumnos.carrera
			AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
			AND sga_personas.nro_inscripcion = sga_alumnos.nro_inscripcion
			AND sga_titulos.unidad_academica = sga_alumnos.unidad_academica
			AND sga_titulos.titulo 	= ls_Titulo
			AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
			AND sga_titulos_plan.carrera 		= sga_alumnos.carrera
			AND sga_titulos_plan.plan 		= sga_alumnos.plan
			AND sga_titulos_plan.titulo		 = sga_titulos.titulo
			AND sga_orientaciones.unidad_academica = sga_alumnos.unidad_academica
			AND sga_orientaciones.carrera 	= sga_alumnos.carrera
			AND sga_orientaciones.plan 		= sga_alumnos.plan
			AND sga_orientaciones.titulo 		= sga_titulos.titulo  
			AND sga_orientaciones.orientacion 	= ls_Orientacion
			AND sga_datos_censales.nro_inscripcion = sga_personas.nro_inscripcion
			AND sga_datos_censales.fecha_actualiz = (select max(fecha_actualiz) from sga_datos_censales where nro_inscripcion = sga_personas.nro_inscripcion)
			AND sga_datos_censales.loc_per_lect = mug_localidades.localidad;

		RETURN 
			ls_UA,
			vcNroInscripcion,
			ls_NombreAlumno, 
			ls_Legajo, 
			ls_TipoDoc, 
			ls_NroDoc, 
			ls_Carrera, 
			ls_CarreraNombre, 
			ls_Plan, 
			ls_Titulo, 
			ls_TituloNombre, 
			ls_Orientacion, 
			ls_OrientNombre ,
			ls_Estado,
			ls_Nivel,
			dFechaEgresoFinal, 
			vemail, vtel_proc, vcalle_proc, vnumero_proc, vpiso_proc, vdpto_proc, vloc_proc, fPromGral, fPromSinAplazos
			WITH RESUME;

 
    END FOREACH; -- es un egresado

END FOREACH;	-- Conjunto de alumnos que aprobaron una materia entre las fechas enviadas por parámetro

END;
END PROCEDURE;
-- **************************** FIN PROCEDURE sp_posibles_egres ****************************


-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_posibles_eg
-- *****************************************************************************
revoke execute on "dba".sp820_posibles_eg from public;
grant execute on "dba".sp820_posibles_eg to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_posibles_eg to internet; -- Rol de usuario de Internet