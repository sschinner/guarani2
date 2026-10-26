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
		varchar(25), 		-- Nro. Documento
		varchar(5), 		-- Carrera
		varchar(255), 		-- Nombre Carrera
		varchar(5), 		-- Plan
		varchar(5), 		-- Titulo
		varchar(255), 		-- Nombre Titulo
		varchar(5),		-- Orientacion
		varchar(255),		-- Nombre Orientacion
		varchar (5),		-- Estado Inicial del titulo
		varchar(15),            -- Nivel
		date,
		varchar(50),	        -- EMAIL	
		char(18),  	        -- TELEFONO (PROC)
		varchar(50),	        -- calle (PROC)
		varchar(5),	        -- numero (PROC)
		varchar(3),	        -- piso
		varchar(5),	        -- dpto
		varchar(100),	        -- localidad
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
LET vcTitulo = NULL;


BEGIN
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Conjunto de alumnos que aprobaron una materia entre las fechas enviadas por parámetro
-- SOLO SE CONSIDERAN LOS TITULOS DE GRADO.
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
        sga_titulos_plan,
	sga_titulos
WHERE sga_alumnos.unidad_academica = pUA   
       	AND sga_alumnos.carrera = pCarrera  

	AND sga_alumnos.calidad = 'A'
	AND vw.carrera = sga_alumnos.carrera
	AND vw.legajo = sga_alumnos.legajo
	AND vw.resultado = 'A'

	AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
	AND sga_titulos_plan.carrera = sga_alumnos.carrera
	AND sga_titulos_plan.plan = sga_alumnos.plan
	AND sga_titulos_plan.titulo = sga_titulos.titulo
	AND sga_titulos.nivel in ('GRADO', 'INTERMEDIO')
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


	FOREACH EXECUTE PROCEDURE "dba".sp_insertar_titulo (ls_UA, ls_Carrera, ls_Legajo, ls_Titulo, 'S/N', 'P') Into vcTitulo, vcPlan, vcVersion, vcOrientacion, vcCiclo, vcMateria, fpuntos

		-- El estado del trámite insertado originalmente es "-" ("No hay estado anterior" = Egresante)

    	END FOREACH; -- es un probable egresado

END FOREACH;	-- Conjunto de alumnos que aprobaron una materia entre las fechas enviadas por parámetro


-- Retorno los egresados detectados en el día
FOREACH SELECT  TRIM(sga_personas.apellido) || ', ' || TRIM(sga_personas.nombres)  nombre_alumno,
			sga_personas.tipo_documento,
			sga_personas.nro_documento,
			sga_personas.nro_inscripcion,
			sga_carreras.nombre,
			sga_titulos.nombre,
			sga_orientaciones.orientacion,
			sga_orientaciones.nombre,
			sga_titulos.nivel,
			sga_datos_censales.e_mail,
			sga_datos_censales.te_proc,
			sga_datos_censales.calle_proc,
			sga_datos_censales.numero_proc,
			sga_datos_censales.piso_proc,
			sga_datos_censales.dpto_proc,
			mug_localidades.nombre,
			sga_titulos_otorg.fecha_egreso, 
			sga_titulos_otorg.prom_general, 
			sga_titulos_otorg.prom_sin_aplazos
		INTO  ls_NombreAlumno, ls_TipoDoc,  ls_NroDoc,  vcNroInscripcion, ls_CarreraNombre,  ls_TituloNombre, ls_Orientacion, ls_OrientNombre, ls_Nivel, vemail, vtel_proc, vcalle_proc, vnumero_proc, vpiso_proc, vdpto_proc, vloc_proc, dFechaEgresoFinal, fPromGral, fPromSinAplazos     
		FROM sga_alumnos, 
			sga_personas,
			sga_carreras,
			sga_titulos_otorg,
			sga_titulos,
			sga_titulos_plan,
			sga_orientaciones,
			sga_orie_tit_otorg, 
			sga_datos_censales,
			OUTER mug_localidades
		WHERE sga_alumnos.unidad_academica = pUA
			AND sga_alumnos.carrera = pCarrera

			AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica
			AND sga_carreras.carrera 	    = sga_alumnos.carrera
			AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
			AND sga_personas.nro_inscripcion = sga_alumnos.nro_inscripcion
			AND sga_titulos.unidad_academica = sga_alumnos.unidad_academica
			AND sga_titulos.titulo 	= sga_titulos_otorg.titulo
			AND sga_alumnos.nro_inscripcion = sga_titulos_otorg.nro_inscripcion
			AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
			AND sga_titulos_plan.carrera 		= sga_alumnos.carrera
			AND sga_titulos_plan.plan 		= sga_alumnos.plan
			AND sga_titulos_plan.titulo		 = sga_titulos.titulo
			AND sga_orientaciones.unidad_academica = sga_alumnos.unidad_academica
			AND sga_orientaciones.carrera 	= sga_alumnos.carrera
			AND sga_orientaciones.plan 		= sga_alumnos.plan
			AND sga_orientaciones.titulo 		= sga_titulos.titulo  
			AND sga_orientaciones.orientacion 	= sga_orie_tit_otorg.orientacion
			AND sga_datos_censales.nro_inscripcion = sga_personas.nro_inscripcion
			AND sga_datos_censales.fecha_actualiz = (select max(fecha_actualiz) from sga_datos_censales where nro_inscripcion = sga_personas.nro_inscripcion)
			AND sga_titulos_otorg.fecha_egreso BETWEEN dFDesde AND dFHasta
			AND sga_orie_tit_otorg.unidad_academica = sga_titulos_otorg.unidad_academica
			AND sga_orie_tit_otorg.nro_inscripcion = sga_titulos_otorg.nro_inscripcion
			AND sga_orie_tit_otorg.titulo = sga_titulos_otorg.titulo
			AND sga_datos_censales.loc_per_lect = mug_localidades.localidad
						

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

END FOREACH;


END;
END PROCEDURE;
-- **************************** FIN PROCEDURE sp_posibles_egres ****************************
revoke execute on "dba".sp820_posibles_eg from public;
grant execute on "dba".sp820_posibles_eg to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_posibles_eg to internet; -- Rol de usuario de Internet

