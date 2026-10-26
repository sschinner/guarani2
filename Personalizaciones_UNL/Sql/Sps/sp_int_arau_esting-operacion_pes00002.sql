Execute procedure dba.sui_operaciones( 'pes00002', 'Información Nominal de Estudiantes de Ingreso', 'Nominal de Estudiantes de Ingreso', null );
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Ventana w_int_arau_estudiantes_ingreso
-- Version 2.9.0
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Begin;
set constraints all deferred;
DELETE FROM dba.acc_operacion_mod WHERE modulo = '00000070' and operacion = 'pes00002';
DELETE FROM acc_ventanas WHERE ventana = 'w_int_arau_estudiantes_ingreso';


INSERT INTO acc_ventanas (ventana) values ('w_int_arau_estudiantes_ingreso');

-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Operacion: pes00002
-- Version: 2.9.0
-- *******************************************************************************


INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior ) VALUES ( 'pes00002', 1, 'w_int_arau_estudiantes_ingreso', 'd_int_arau_estudiantes_ingreso', 'N' );

INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'pes00002', 'C' );

Commit;

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_int_arau_esting') THEN
		DROP PROCEDURE sp_int_arau_esting;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SIU-GUARANI 
-- Version: 2.9.0
-- Stored Procedure: sp_int_arau_esting
-- Fecha: Mayo 2014
--
-- Recupera alumnos inscriptos con/sin legajo generado a carrera en un año academico que tengan asignado un titulo araucano.
-- El codigo de institucion araucano lo saca de la sede, y si no esta cargado lo saca de la unidad academica del alumno.
-- No se informan los alumnos de las carreras que tengan asociado un ciclo básico comun, ya que los alumnos de estas carreras
-- seran informados como ingresantes en el ciclo básico comun (si ingresaron en el año a informar).
--
-- Titulos de nivel = GRADO (final)
-- Títulos con código de titulo araucano asignado
--  Solo se informan estos tipos de titulo:
--      G	Título de Grado Universitario
--      P	Pre-Grado
--      S	Postítulo
-- Estos no se informan:
-- D	Doctorado
-- M	Maestría
-- E	Especialización
-- T	Terciario
-- O	Posgrado
-- 
-- Los titulos segun Araucano a informar son:
-- "CC";"Ciclo Básico Común";"G"
-- "CCC";"Ciclo de Complementación Curricular";"G"
-- "CL";"Ciclo de Licenciatura";"G"
-- "CP";"Ciclo de Profesorado";"G"
-- "CS";"Ciclo Superior";"G"
-- "CT";"Ciclo de Traductorado";"G"
-- "G";"Grado";"G"
-- "P";"Otros Pregrados";"E"
-- "PT";"Postítulo";"G"
--  "TI";"Técnico Instrumental";"E"
-- "TINT";"Título Intermedio";"E"
-- U820 Corrección de los campos Requisitos Administrativos; Requisitos Académicos y Condición final de ingreso
-- Esta modificación se realiza para contmplar particularidades de la UNL, en lo que respecta a generación de legajo y condiciones de Ingreso
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- DROP PROCEDURE dba.sp_int_arau_esting (integer);
CREATE PROCEDURE dba.sp_int_arau_esting (pAnioAcademico LIKE sga_anio_academico.anio_academico)
 RETURNING Integer, varchar(15), varchar(15), Integer, varchar(10), varchar(10), Integer,Integer,Integer,Integer, Integer, varchar(10);

/*
Integer,     -- viTipodocumento,
varchar(15), -- vcNroDocumento,
varchar(15), -- vcCuit,
Integer,     -- viSexo,
varchar(10), -- vcFechaNacimiento,
varchar(10), -- vcAltaSistema, 
Integer,     -- viInstitAraucano,
Integer,     -- viTituloAraucano,
Integer,     -- viReqAdminist,
Integer,     -- viReqAcademico,
Integer,     -- viEnCondDeIngreso,
varchar(10), -- vcFinalizCurso
*/

 
DEFINE vcUnidadAcademica varchar(5);
DEFINE vcCarrera varchar(5);
DEFINE vcNroInscripcion varchar(10);
DEFINE cant_req integer;
DEFINE viTipodocumento LIKE sga_personas.tipo_documento;
DEFINE vcNroDocumento  LIKE sga_personas.nro_documento;
DEFINE vcCuit LIKE sga_personas.numero_cuil;
DEFINE viSexo integer;


DEFINE viInstitAraucano integer;
DEFINE viTituloAraucano integer;
DEFINE viReqAcademico,viReqAdminist, viEnCondDeIngreso integer;
DEFINE vcFechaNacimiento, vcAltaSistema, vcFinalizCurso varchar(10);
DEFINE viCursoIngreso             LIKE sga_carrera_aspira.curso_ingreso;
DEFINE vcFormaCumpliCurso LIKE sga_carrera_aspira.forma_cumpli_curso;
DEFINE vdFinalizCurso           LIKE sga_carrera_aspira.fecha_finalizacion;
DEFINE viMotivoExcepCurso LIKE  sga_carrera_aspira.motivo_excep_curso;

DEFINE vd_fecha_presentac, vd_prorroga_hasta , vd_fecha_cier_reqp, vd_fecha_cier_ree, vd_fecha_testeo DATE;
DEFINE ls_periodo_insc	LIKE sga_periodo_insc.periodo_inscripcio;

DEFINE vcPlan varchar(5);

DEFINE vc_carrera_ing varchar(5);
DEFINE vc_plan_ing varchar(5);
DEFINE vc_materia_ing varchar(5);
DEFINE vcLegajo LIKE sga_alumnos.legajo;
DEFINE vc_situacion_asp varchar(2);


-- VARIABLES PARA EL MANEJO DE EXCEPCIONES.
DEFINE SQLErr      integer;
DEFINE ISAMError   integer;
DEFINE errorInfo   varchar(76);


ON EXCEPTION IN  (-958)
   -- Tabla temporal ya existe
END EXCEPTION with resume;

BEGIN

/*
Requisitos Administrativos:  
1 SI 
2 NO

Requisitos Académicos:
1 SI
2 NO
3 CONTINÚA
4 INGRESO DIRECTO
5 SIN REQUISITO ACADÉMICO

En condiciones de Ingresar
1 SI
2 NO
3 CONDICIONAL
*/

-- Recupero los alumnos nuevos inscriptos
FOREACH 
  SELECT
       sga_carrera_aspira.periodo_inscripcio, 
       sga_carrera_aspira.unidad_academica,
       sga_carrera_aspira.nro_inscripcion,
       sga_carrera_aspira.carrera,

	-- U820
	sga_carrera_aspira.situacion_asp,
	a.plan,
	a.legajo,
	-- U820

       -- Datos Personales
       p.tipo_documento,
       p.nro_documento, 
       p.numero_cuil as cuit,
       cast(p.sexo as integer) as genero, 
       to_char(p.fecha_nacimiento, "%Y%m%d") as fecha_nacimiento,
  
       -- Datos Academicos
       to_char(sga_carrera_aspira.fecha_inscripcion, "%Y%m%d") as f_alta_sistema,
       NVL(sga_sedes.instituc_araucano,u.instituc_araucano) as instituc_araucano,
       t.titulo_araucano as titulo_araucano, 
       CASE   
          WHEN sga_situacion_asp.resultado_asp = 'I' THEN 1    -- SI
          WHEN sga_situacion_asp.resultado_asp = 'R' THEN 2    -- NO
          WHEN sga_situacion_asp.resultado_asp = 'A' THEN 3    -- CONDICIONAL
          ELSE 3
       END as en_cond_de_ingreso,
       CASE 
          WHEN sga_carrera_aspira.curso_ingreso IS NULL THEN ''
          ELSE to_char(sga_carrera_aspira.fecha_finalizacion, "%Y%m%d")
       END, -- Si no existe el curso de ingreso, la fecha de finalizacion es la fecha de la inscripción a carrera
       sga_carrera_aspira.curso_ingreso,
       sga_carrera_aspira.forma_cumpli_curso,
       sga_carrera_aspira.fecha_finalizacion,
       sga_carrera_aspira.motivo_excep_curso

INTO 
  ls_periodo_insc,
   vcUnidadAcademica,
   vcNroInscripcion,
   vcCarrera,
   vc_situacion_asp,
   vcPlan,
   vcLegajo, 
   viTipodocumento,
   vcNroDocumento,
   vcCuit,
   viSexo,
   vcFechaNacimiento,
   vcAltaSistema, 
   viInstitAraucano,
   viTituloAraucano,
   viEnCondDeIngreso,
   vcFinalizCurso,
   viCursoIngreso,
   vcFormaCumpliCurso,
   vdFinalizCurso,
   viMotivoExcepCurso

FROM 
   sga_periodo_insc,    
   sga_carrera_aspira,
   sga_situacion_asp,
   sga_alumnos as a, 
   sga_personas as p,
   sga_titulos_plan as tp,
   sga_titulos as t ,
   sga_unidades_acad as u,
   sga_sedes

WHERE sga_periodo_insc.anio_academico = pAnioAcademico
  AND sga_carrera_aspira.periodo_inscripcio = sga_periodo_insc.periodo_inscripcio
  AND sga_situacion_asp.situacion_asp = sga_carrera_aspira.situacion_asp
  AND a.unidad_academica = sga_carrera_aspira.unidad_academica
  AND a.carrera          = sga_carrera_aspira.carrera
  AND a.nro_inscripcion  = sga_carrera_aspira.nro_inscripcion
  AND p.unidad_academica = a.unidad_academica
  AND p.nro_inscripcion = a.nro_inscripcion
  AND p.fecha_nacimiento IS NOT NULL
  AND sga_sedes.sede = a.sede
  AND tp.unidad_academica = a.unidad_academica
  AND tp.carrera          = a.carrera
  AND tp.plan             = a.plan
  AND t.unidad_academica = tp.unidad_academica
  AND t.titulo           = tp.titulo
  AND t.titulo_araucano IS NOT NULL
  AND t.nivel = 'GRADO'
  AND t.tipo_de_titulo IN ('G','P', 'S')
  AND u.unidad_academica = p.unidad_academica
  
  AND sga_carrera_aspira.carrera NOT IN (SELECT carrera FROM int_arau_car_cc)  -- No informar carreras que tengan ciclo basico comun

UNION ALL

  -- Inscripciones que no tienen legajo.
  SELECT
       sga_carrera_aspira.periodo_inscripcio, 
       sga_carrera_aspira.unidad_academica,
       sga_carrera_aspira.nro_inscripcion,
       sga_carrera_aspira.carrera,
	
	-- U820
	sga_carrera_aspira.situacion_asp,
	sga_planes.plan,
	'legajo' as legajo, -- Valor ficticio
	-- U820

       -- Datos Personales
       p.tipo_documento,
       p.nro_documento, 
       p.numero_cuil as cuit,
       cast(p.sexo as integer) as genero, 
       to_char(p.fecha_nacimiento, "%Y%m%d") as fecha_nacimiento,
  
       -- Datos Academicos
       to_char(sga_carrera_aspira.fecha_inscripcion, "%Y%m%d") as f_alta_sistema,
       NVL(sga_sedes.instituc_araucano,u.instituc_araucano) as instituc_araucano,
       t.titulo_araucano as titulo_araucano, 
       CASE   
          WHEN sga_situacion_asp.resultado_asp = 'I' THEN 1    -- SI
          WHEN sga_situacion_asp.resultado_asp = 'R' THEN 2    -- NO
          WHEN sga_situacion_asp.resultado_asp = 'A' THEN 3    --  CONDICIONAL   (Aun es aspirante a carrera
          ELSE 3
       END as en_cond_de_ingreso,
       CASE 
          WHEN sga_carrera_aspira.curso_ingreso IS NULL THEN ''
          ELSE to_char(sga_carrera_aspira.fecha_finalizacion, "%Y%m%d")
       END, -- Si no existe el curso de ingreso, la fecha de finalizacion es la fecha de la inscripción a carrera
       sga_carrera_aspira.curso_ingreso,
       sga_carrera_aspira.forma_cumpli_curso,
       sga_carrera_aspira.fecha_finalizacion,
       sga_carrera_aspira.motivo_excep_curso

FROM 
   sga_periodo_insc,    
   sga_carrera_aspira,
   sga_situacion_asp,
   sga_personas as p,
   sga_planes,
   sga_titulos_plan as tp,
   sga_titulos as t ,
   sga_unidades_acad as u,
   sga_sedes

WHERE sga_periodo_insc.anio_academico = pAnioAcademico
  AND sga_carrera_aspira.periodo_inscripcio = sga_periodo_insc.periodo_inscripcio
  AND sga_carrera_aspira.situacion_asp = 'AC'   -- Aspirante a carrera
  AND sga_situacion_asp.situacion_asp = sga_carrera_aspira.situacion_asp

  AND p.unidad_academica = sga_carrera_aspira.unidad_academica
  AND p.nro_inscripcion = sga_carrera_aspira.nro_inscripcion
  AND p.fecha_nacimiento IS NOT NULL

  AND sga_sedes.sede = sga_carrera_aspira.sede

  AND sga_planes.unidad_academica = sga_carrera_aspira.unidad_academica
  AND sga_planes.carrera                    = sga_carrera_aspira.carrera
  AND sga_planes.estado = 'V'  -- Plan Vigente

  AND tp.unidad_academica = sga_planes.unidad_academica
  AND tp.carrera                    = sga_planes.carrera
  AND tp.plan                        = sga_planes.plan

  AND t.unidad_academica = tp.unidad_academica
  AND t.titulo           = tp.titulo
  AND t.titulo_araucano IS NOT NULL
  AND t.nivel = 'GRADO'
  AND t.tipo_de_titulo IN ('G','P', 'S')

  AND u.unidad_academica = p.unidad_academica

  AND sga_carrera_aspira.carrera NOT IN (SELECT carrera FROM int_arau_car_cc)  -- No informar carreras que tengan ciclo basico comun

ORDER BY 1
 

   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Requisito Académico
   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  IF viCursoIngreso IS NOT NULL THEN
     IF vcFormaCumpliCurso = 'A' THEN
        LET viReqAcademico = 1; -- SI. Cumple con el curso de ingreso
     ELIF vcFormaCumpliCurso = 'E' THEN
        LET viReqAcademico = 4; -- INGRESO DIRECTO. Exceptuado del curso de ingreso...
     ELIF vcFormaCumpliCurso = 'N' THEN
        LET viReqAcademico = 2; -- NO. No cumplió con el curso de ingreso
     ELIF vcFormaCumpliCurso IS NULL THEN
        LET viReqAcademico = 3; -- Continúa con el curso de ingreso
     END IF;
  ELSE

	-- U820 Se controla requisito académico también de los alumnos IC
	IF (vc_situacion_asp in('IC', 'IL')) THEN
		-- LET viReqAcademico = 5; -- SIN REQUISITO ACADEMICO
		-- U820 Si le falta algún curso de ingreso declarado en la tabla correspondiente, es Continua=3
		LET viReqAcademico = 1; -- SI. Cumple con el curso de ingreso
		foreach	select carrera, plan, materia into vc_carrera_ing, vc_plan_ing, vc_materia_ing
			from u820_cursos_ing
			-- where obligatoria = 'S'
			where carrera = vcCarrera
				and plan = vcPlan

			IF NOT EXISTS (Select * from vw_hist_academica
					where carrera = vcCarrera
						and plan = vcplan
						and materia = vc_materia_ing
						and legajo = vcLegajo
						and resultado = 'A'
						) THEN
				LET viReqAcademico = 3; -- Continúa con el curso de ingreso 
				EXIT FOREACH;
			END IF;

		end foreach;
		

	ELSE
	        LET viReqAcademico = 2; -- NO. No cumplió con el curso de ingreso


	END IF;
  END IF;

   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- Requisito Administrativo
   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   LET viReqAdminist = 2; -- Por default seteo que SI cumple con los requisitos administrativos
   
   --IF viEnCondDeIngreso = 1 then
   -- Si es alumno con legajo, entonces cumplio los requisitos. no debo evaluarlos...
   -- U820 Controlo Certificado de título legalizado por UNL.
   IF (vc_situacion_asp in('IC', 'IL')) THEN
	LET viReqAdminist = 1;
	IF NOT EXISTS (Select '*' from sga_req_cumplidos
				where carrera = vcCarrera
				and nro_inscripcion = vcNroInscripcion) THEN
		LET viReqAdminist = 2;
	END IF;

   ELSE   

   ---------------------------------------------------------------------------------------------------------
   -- Controlar si estan todos los requisitos de la carrera obligatorios del alumno presentados .
   ---------------------------------------------------------------------------------------------------------
   FOREACH SELECT fecha_presentacion, f_prorroga_hasta , spi.fecha_cierre_req, date(sfer.fecha_cierre_req)
	INTO vd_fecha_presentac, vd_prorroga_hasta, vd_fecha_cier_reqp, vd_fecha_cier_ree
	FROM 
	    sga_req_cumplidos as src, 
		sga_periodo_insc as spi, 
		sga_requisitos_car srca,
		OUTER sga_fec_excep_req as sfer
	WHERE 
	    src.unidad_academica  = vcUnidadAcademica
		and src.nro_inscripcion = vcNroInscripcion
		and src.carrera = vcCarrera
		and spi.periodo_inscripcio	= ls_periodo_insc
		and sfer.periodo_inscripcio = ls_periodo_insc
		and src.requisito 		= sfer.requisito
		and (src.exceptuado IS NULL OR src.exceptuado <>'S')
		and src.unidad_academica = srca.unidad_academica
		and src.carrera = srca.carrera
		and src.requisito = srca.requisito

    
    	-- Si la prorroga no es nula va la prorroga
    	IF vd_prorroga_hasta IS NOT NULL THEN
    		LET vd_fecha_testeo = vd_prorroga_hasta;
    	ELSE
    		-- Recupero la fecha fin de presentacion del requisito
    		IF vd_fecha_cier_ree IS NOT NULL THEN
    			LET vd_fecha_testeo = vd_fecha_cier_ree;
    		ELSE
    			LET vd_fecha_testeo = vd_fecha_cier_reqp;
    		END IF;
    	END IF;
    
    	-- si la fecha a testear es igual o posterior a hoy no hago nada
    	IF vd_fecha_testeo >= TODAY then
    		continue foreach;
    	END IF
    
    	-- aca llego si la fecha de presentacion es anterior a hoy
    	-- si no lo presentó O si lo presentó fuera de término
    	IF vd_fecha_presentac IS NULL OR (vd_fecha_presentac > vd_fecha_testeo) THEN
    		LET viReqAdminist = 2; -- NO cumple con los requisitos administrativos
    		exit foreach;
    	END IF

    END FOREACH;  -- Requisitos de la carrera
      
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++  
    -- Requisitos de la UA
    -- +++++++++++++++++++++++++++++++++++++++++++++++++++++  
    IF viReqAdminist = 1 THEN

       FOREACH SELECT fecha_presentacion, f_prorroga_hasta , spi.fecha_cierre_req, date(sfer.fecha_cierre_req)
       	INTO vd_fecha_presentac, vd_prorroga_hasta, vd_fecha_cier_reqp, vd_fecha_cier_ree
       	FROM 
       		sga_req_cumplidos as src, 
       		sga_periodo_insc as spi, 
       		sga_requisitos_ua sru,
       		OUTER sga_fec_excep_req as sfer
       	WHERE
       	    src.unidad_academica  = vcUnidadAcademica
       		and src.nro_inscripcion = vcNroInscripcion
       		and src.carrera         = vcCarrera
       		and spi.periodo_inscripcio	= ls_periodo_insc
       
       		and sfer.periodo_inscripcio = ls_periodo_insc
       		and src.requisito	= sfer.requisito
       
       		and (src.exceptuado IS NULL OR src.exceptuado <>'S')
       
       		and src.unidad_academica = sru.unidad_academica
       		and src.requisito = sru.requisito
       
       	-- Si la prorroga no es nula va la prorroga
       	IF vd_prorroga_hasta IS NOT NULL THEN
       		LET vd_fecha_testeo = vd_prorroga_hasta;
       	ELSE
       		-- Recupero la fecha fin de presentacion del requisito
       		IF vd_fecha_cier_ree IS NOT NULL THEN
       			LET vd_fecha_testeo = vd_fecha_cier_ree;
       		ELSE
       			LET vd_fecha_testeo = vd_fecha_cier_reqp;
       		END IF;
       	END IF;
       
       	-- si la fecha a testear es igual o posterior a hoy no hago nada
       	IF vd_fecha_testeo >= TODAY then
       		continue foreach;
       	END IF;
       
       	-- aca llego si la fecha de testeo es anterior a hoy
       	-- si no lo presentó
       	IF vd_fecha_presentac IS NULL OR (vd_fecha_presentac > vd_fecha_testeo) THEN
    		LET viReqAdminist = 2; -- NO cumple con los requisitos administrativos
       		exit foreach;
       	END IF;
       
       END FOREACH; 
    END IF; -- Requisitos de la UA
    
   END IF;  -- Requisitos Academicos

-- U820 Actualización del campo "En condiciones de Ingresar"

IF (viReqAdminist = 1 AND viReqAcademico = 1) THEN
	let viEnCondDeIngreso = 1;
END IF;

IF (viReqAdminist = 1 AND viReqAcademico = 2) THEN
	let viEnCondDeIngreso = 3;
END IF;

IF (viReqAdminist = 1 AND viReqAcademico = 3) THEN
	let viEnCondDeIngreso = 3;
END IF;

IF (viReqAdminist = 2 AND viReqAcademico = 1) THEN
	let viEnCondDeIngreso = 3;
END IF;

IF (viReqAdminist = 2 AND viReqAcademico = 2) THEN
	let viEnCondDeIngreso = 2;
END IF;

IF (viReqAdminist = 2 AND viReqAcademico = 3) THEN
	let viEnCondDeIngreso = 3;
END IF;

  -- Retorno al aspirante
  RETURN viTipodocumento, vcNroDocumento, vcCuit, viSexo,vcFechaNacimiento, vcAltaSistema,  viInstitAraucano, viTituloAraucano, viReqAdminist, viReqAcademico, viEnCondDeIngreso, vcFinalizCurso WITH RESUME;

END FOREACH;  -- inscriptos a carrera

END;
END PROCEDURE;         
-- ++++++++++++++++++++++++++++++ Fin Procedure sp_int_arau_esting +++++++++++++++++++++++++++++

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_int_arau_esting
-- *****************************************************************************
revoke execute on "dba".sp_int_arau_esting from public;
grant execute on "dba".sp_int_arau_esting to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_int_arau_esting to internet; -- Rol de usuario de Internet