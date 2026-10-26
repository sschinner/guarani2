Execute procedure dba.sui_operaciones( 'pes00001', 'Información Nominal de alumnos Siu-Araucano', 'Alumnos Nominal Araucano 2014', null );

Begin;
set constraints all deferred;
DELETE FROM dba.acc_operacion_mod WHERE modulo = '00000070' and operacion = 'pes00001';
DELETE FROM acc_ventanas WHERE ventana = 'w_int_arau_nominal';

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Ventana w_int_arau_nominal
-- Version 2.8.0
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
INSERT INTO acc_ventanas (ventana) values ('w_int_arau_nominal');
-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Operacion: pes00001
-- Version: 2.8.0
-- *******************************************************************************


INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior ) VALUES ( 'pes00001', 1, 'w_int_arau_nominal', 'd_int_arau_alumnos_nominales, d_int_arau_alumnos_nominales_materias, d_int_arau_alumnos_nominales_cc, d_int_arau_alumnos_nominales_materias_cc', 'N' );

INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'pes00001', 'C' );
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Operacion: pes00001
-- Módulo: 00000070 - Interfaces
-- Version: 2.8.0
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
INSERT INTO dba.acc_operacion_mod ( modulo, operacion, submodulo, orden ) VALUES ( '00000070', 'pes00001', 'Guar_Ara', 86);
-- *******************************************************************************
-- Tabla int_arau_nominal
-- Version: 2.8.0
-- Registra alumnos Nuevos Inscriptos y Reinscriptos en un año académico y título aracauno
-- El titulo corresponde al plan de estudios que estaba el alumno al finalizar el año academico
-- a evaluar, es decir al 31/3
-- *******************************************************************************

Commit;

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN

IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'int_arau_nominal') THEN
-- DROP TABLE int_arau_nominal;

CREATE TABLE int_arau_nominal (
       anio_academico       integer NOT NULL,
       unidad_academica     varchar(5) NOT NULL,
       carrera              varchar(5) NOT NULL,
       legajo		        varchar(15) NOT NULL,
       plan                 varchar(5),
       version                varchar(5),
       tipo_documento       integer NOT NULL,
       nro_documento        varchar(15) NOT NULL,
       genero               integer ,
       fecha_nacimiento     varchar(8) ,
       instituc_araucano    integer ,
       titulo_araucano      integer ,
       anio_ingreso         integer 
);


ALTER TABLE int_arau_nominal
       ADD CONSTRAINT PRIMARY KEY (ANIO_ACADEMICO, UNIDAD_ACADEMICA, CARRERA, LEGAJO)
              CONSTRAINT pk_arau_nominal;


-- REVOKE ALL ON int_arau_nominal FROM public;
GRANT ALL ON  int_arau_nominal TO public;
-- *********** Fin del script de la tabla int_arau_nominal **********

END IF;
 -- *******************************************************************************
-- Tabla int_arau_nominalcc
-- Version: 2.8.0
-- Registra alumnos Nuevos Inscriptos y Reinscriptos para un año académico en una carrera de Ciclo Comun que no estan
-- en una carrera de grado y donde el Ciclo Comun NO tiene un titulo araucano asociado
-- *******************************************************************************

IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'int_arau_nominalcc') THEN

-- DROP TABLE int_arau_nominalcc;
CREATE TABLE int_arau_nominalcc (
       anio_academico       integer NOT NULL,
       unidad_academica     varchar(5) NOT NULL,
       carrera              varchar(5) NOT NULL,
       legajo		        varchar(15) NOT NULL,
       plan                 varchar(5),
       version                varchar(5),
       tipo_documento       integer NOT NULL,
       nro_documento        varchar(15) NOT NULL,
       genero               integer,
       fecha_nacimiento     varchar(8),
       instituc_araucano    integer ,
       anio_ingreso         integer 
);


ALTER TABLE int_arau_nominalcc
       ADD CONSTRAINT PRIMARY KEY (ANIO_ACADEMICO, UNIDAD_ACADEMICA, CARRERA, LEGAJO)
              CONSTRAINT pk_arau_nominalcc;


-- REVOKE ALL ON int_arau_nominalcc FROM public;
GRANT ALL ON  int_arau_nominalcc TO public;

-- *********** Fin del script de la tabla int_arau_nominalcc **********
END IF;

 -- *******************************************************************************
-- Tabla int_arau_nominalm
-- Version: 2.8.0
-- Registra materias aprobadas de alumnos Nuevos Inscriptos y Reinscriptos en un año académico y título Aracauno
-- Relacionado con tabla int_arau_nominal
-- *******************************************************************************


IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'int_arau_nominalm') THEN

-- DROP TABLE int_arau_nominalm;
CREATE TABLE int_arau_nominalm (
       idmateria            SERIAL NOT NULL,	
       
       anio_academico       integer NOT NULL,
       unidad_academica     varchar(5) NOT NULL,
       carrera              varchar(5) NOT NULL,
       legajo		        varchar(15) NOT NULL,

       tipo_documento       integer NOT NULL,
       nro_documento        varchar(15) NOT NULL,
       instituc_araucano    integer,
       titulo_araucano      integer,
       fecha_aprobacion		varchar(10),
       materia_codigo		varchar(10),
       materia_nombre		varchar(255),
       carga_horaria		Integer,
       obligatoria		Integer,
       forma_aprobacion		Integer,
       libro				Varchar(100),
       acta					Varchar(30),
       folio_fisico			Integer,
       expediente			Varchar(30)
);


ALTER TABLE int_arau_nominalm
       ADD CONSTRAINT PRIMARY KEY (idmateria) CONSTRAINT pk_arau_nominalm;

GRANT ALL ON int_arau_nominalm TO public;

-- *********** Fin del script de la tabla int_arau_nominalm **********
END IF;

 -- *******************************************************************************
-- Tabla int_arau_nomi_cc_m
-- Version: 2.8.0
-- Registra materias aprobadas de alumnos Nuevos Inscriptos y Reinscriptos en un año académico 
-- Alumnos que estan solo en Ciclos Comunes sin título Aracauno
-- Relacionado con tabla int_arau_nominalcc
-- *******************************************************************************

IF NOT EXISTS (SELECT tabname
			FROM systables
			WHERE tabname = 'int_arau_nomi_cc_m') THEN

-- DROP TABLE int_arau_nomi_cc_m;
CREATE TABLE int_arau_nomi_cc_m (
       idmateria            SERIAL NOT NULL,	
       anio_academico       integer NOT NULL,
       unidad_academica     varchar(5) NOT NULL,
       carrera              varchar(5) NOT NULL,
       legajo		        varchar(15) NOT NULL,

       tipo_documento       integer NOT NULL,
       nro_documento        varchar(15) NOT NULL,
       instituc_araucano    integer,
       fecha_aprobacion		varchar(10),
       materia_codigo		varchar(10),
       materia_nombre		varchar(255),
       carga_horaria		Integer,
       obligatoria		Integer,
       forma_aprobacion		Integer,
       libro				Varchar(100),
       acta					Varchar(30),
       folio_fisico			Integer,
       expediente			Varchar(30)
);


ALTER TABLE int_arau_nomi_cc_m
       ADD CONSTRAINT PRIMARY KEY (idmateria) CONSTRAINT pk_arau_nomi_cc_m;

GRANT ALL ON int_arau_nomi_cc_m TO public;

-- *********** Fin del script de la tabla int_arau_nomi_cc_m **********

 ALTER TABLE int_arau_nominal
	ADD CONSTRAINT FOREIGN KEY (unidad_academica, carrera, legajo)
	REFERENCES sga_alumnos CONSTRAINT fk_intaraunomi_alu;
	
END IF;
END
END PROCEDURE;


EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- SIU-GUARANI
-- Version: 2.7.0 y superior 
-- Stored Procedure: sp_int_arau_nomi
-- Fecha: Abril 2013
-- Proceso que carga datos en las tablas int_arau_nominal e int_arau_nominalm
-- Recupera alumnos Nuevos Inscriptos y Reinscriptos (segun Araucano) de un año academico por cada titulo araucano.
-- Tambien registra las materias aprobadas en el año académico de esos alumnos por cada titulo araucano.
-- El codigo de institucion araucano lo saca de la sede, y si no esta cargado lo saca de la unidad academica del alumno.
--
-- Abril 2014: Las materias aprobadas las busca en el año académico a informar. Del 01/04/T al 31/04/T+1
--                  T = Año académico a informar
--  Idem cuadro 16 de Araucano             
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_int_arau_nomi') THEN
		DROP PROCEDURE sp_int_arau_nomi;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP PROCEDURE "dba".sp_int_arau_nomi (integer);
CREATE PROCEDURE dba.sp_int_arau_nomi (pAnioAcademico LIKE sga_anio_academico.anio_academico)
   RETURNING INTEGER;
 
DEFINE ld_FechaIni, ld_FechaIniAA LIKE sga_anio_academico.fecha_inicio;
DEFINE ld_FechaFin, ld_FechaFinAA LIKE sga_anio_academico.fecha_fin;
DEFINE ls_FechaIni VARCHAR(10);
DEFINE ls_FechaFin VARCHAR(10);
DEFINE li_AnioSig  INTEGER;
DEFINE cant_alumnos INTEGER;

DEFINE vUnidadAcademica varchar(5);
DEFINE vCarrera varchar(5);
DEFINE vLegajo varchar(5);
DEFINE vPlan, vPlanAlumno varchar(5);
DEFINE vVersion varchar(5);
DEFINE vFecha   datetime Year to Second;
DEFINE vEsCicloComun char(1);
DEFINE vID varchar(30);
DEFINE vNroInscripcion  varchar(10);

-- VARIABLES PARA EL MANEJO DE EXCEPCIONES.
DEFINE SQLErr      integer;
DEFINE ISAMError   integer;
DEFINE errorInfo   varchar(76);


ON EXCEPTION IN  (-958)
   -- Tabla temporal ya existe
END EXCEPTION with resume;


BEGIN
 -- Borro tablas temporales por si existen con el mismo nombre.
 BEGIN
  ON EXCEPTION IN  (-206)
    -- Tabla temporal no existe
  END EXCEPTION WITH RESUME;
  
  DROP TABLE tmp_alumnos;
  DROP TABLE tmp_alumnos_plan;
  DROP TABLE tmp_materias;

  DROP TABLE tmp_alumno_cc;
 END -- Borrado tablas temporales 

 
 -- *************** Tablas Temporales ********************************

 -- Tabla Temporal para acumular los alumnos con actividad académica en el año académico.
 CREATE TEMP TABLE tmp_alumnos
	( unidad_academica VARCHAR(5),
	  carrera VARCHAR(5),
	  legajo VARCHAR(15),
	  id varchar(30) 
	) WITH NO LOG;

 CREATE TEMP TABLE tmp_alumnos_plan
	( unidad_academica VARCHAR(5),
	  carrera VARCHAR(5),
	  legajo  VARCHAR(15),
	  nro_inscripcion VARCHAR(10),
	  plan    varchar(5),
	  version varchar(5),
	  id varchar(30), 
	  es_ciclo_comun char(1)
	) WITH NO LOG;

 -- Materias aprobadas por el alumno
 CREATE TEMP TABLE tmp_materias
	( forma_aprobacion   integer NOT NULL,
	  unidad_academica VARCHAR(5),
	  carrera      VARCHAR(5),
	  legajo       VARCHAR(15),
	  materia_codigo      VARCHAR(5),
	  materia_nombre VARCHAR(255),
	  fecha        VARCHAR(10),
	  plan         VARCHAR(5),
	  version      VARCHAR(5),
	  obligatoria  Integer,
	  carga_horaria Integer,
	  acta         VARCHAR(30),
	  libro        VARCHAR(100),
	  folio_fisico Integer,
	  expediente   VARCHAR(30)
	) WITH NO LOG;

 CREATE TEMP TABLE tmp_materias_titulo
	( unidad_academica VARCHAR(5),
	  carrera VARCHAR(5),
	  plan    varchar(5),
	  version   varchar(5),
	  titulo_araucano    integer,
	  materia    varchar(5)
	) WITH NO LOG;


-- Alumnos que estan en ciclos comunes y en ninguna carrera de grado asociada al ciclo comun.
-- estos se informaran en otro archivo
CREATE TEMP TABLE tmp_alumno_cc 
	( unidad_academica VARCHAR(5), 
	  carrera VARCHAR(5), 
	  legajo VARCHAR(15), 
	  id varchar(30),
	  nro_inscripcion VARCHAR(10)
	 ) WITH NO LOG;

-- **************** Fin creacion tablas temporales ****************

-- Borro datos del año academico a generar
DELETE FROM int_arau_nominal WHERE anio_academico = pAnioAcademico;
DELETE FROM int_arau_nominalcc WHERE anio_academico = pAnioAcademico;
DELETE FROM int_arau_nominalm WHERE anio_academico = pAnioAcademico;
DELETE FROM int_arau_nomi_cc_m WHERE anio_academico = pAnioAcademico;


-- Averiguo la fecha del Calendario (se buscan las materias del año anterior al informado).Idem sp_int_arau_datmat
-- SELECT fecha_inicio,fecha_fin INTO ld_FechaIniAA, ld_FechaFinAA  FROM sga_anio_academico WHERE anio_academico = pAnioAcademico - 1;

-- Abril 2014: En este pedido de Araucano, se informan las materias aprobadas durante el año académico a informar
-- SELECT fecha_inicio,fecha_fin INTO ld_FechaIniAA, ld_FechaFinAA  FROM sga_anio_academico WHERE anio_academico = pAnioAcademico;
LET ls_FechaIni = '01/04/' || pAnioAcademico;
LET ls_FechaFin = '31/03/' || pAnioAcademico + 1;
LET ld_FechaIniAA = to_date(ls_FechaIni, '%d/%m/%Y');
LET ld_FechaFinAA = to_date(ls_FechaFin, '%d/%m/%Y');


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Alumnos a informar. Plan y version del alumno en la fecha actual
-- La institucion araucano la saca de la sede del alumno y si es NULL, de la unidad academica.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Reinscriptos
INSERT INTO int_arau_nominal (
       anio_academico, 
       unidad_academica, 
       carrera, 
       legajo, 
       plan,
       version,
       tipo_documento, 
       nro_documento, 
       instituc_araucano, 
       titulo_araucano, 
       genero, 
       fecha_nacimiento,
       anio_ingreso)
SELECT 
       pAnioAcademico,
       i.unidad_academica,
       i.carrera,
       i.legajo,
       a.plan,
       sga_planes.version_actual,
       p.tipo_documento as tipo_documento,
       p.nro_documento as nro_documento, 
       NVL(sga_sedes.instituc_araucano,u.instituc_araucano) as instituc_araucano,
       cast(i.titulo_araucano as integer) as titulo_araucano, 
       p.sexo as sexo, 
       to_char(p.fecha_nacimiento, "%Y%m%d") as fecha_nacimiento,
       i.anio_ingreso as anio_ingreso
FROM 
    int_arau_reinscrip as i, 
    sga_alumnos as a, 
    sga_personas as p,
    sga_planes,
    sga_unidades_acad as u, 
    sga_sedes
WHERE i.anio_academico = pAnioAcademico
  AND a.unidad_academica = i.unidad_academica
  AND a.carrera = i.carrera
  AND a.legajo = i.legajo
  AND sga_planes.unidad_academica = a.unidad_academica
  AND sga_planes.carrera = a.carrera
  AND sga_planes.plan = a.plan
  AND p.unidad_academica = a.unidad_academica
  AND p.nro_inscripcion = a.nro_inscripcion
  AND i.titulo_araucano IS NOT NULL
  AND p.fecha_nacimiento IS NOT NULL
  AND u.unidad_academica = p.unidad_academica
  AND sga_sedes.sede = a.sede;


-- Nuevos Inscriptos
INSERT INTO int_arau_nominal (
       anio_academico, 
       unidad_academica, 
       carrera, 
       legajo, 
       plan,
       version,
       tipo_documento, 
       nro_documento, 
       instituc_araucano, 
       titulo_araucano, 
       genero, 
       fecha_nacimiento,
       anio_ingreso)
SELECT 
       pAnioAcademico,
       i.unidad_academica,
       i.carrera,
       i.legajo,
       a.plan,
       sga_planes.version_actual,
       p.tipo_documento,
       p.nro_documento , 
       NVL(sga_sedes.instituc_araucano,u.instituc_araucano) as instituc_araucano,
       cast(i.titulo_araucano as integer) , 
       p.sexo as sexo, 
       to_char(p.fecha_nacimiento, "%Y%m%d"),
       pAnioAcademico
FROM 
   int_arau_nuinscrip as i, 
   sga_alumnos as a, 
   sga_personas as p,
   sga_planes,
   sga_unidades_acad as u,
   sga_sedes
WHERE i.anio_academico = pAnioAcademico
  AND a.unidad_academica = i.unidad_academica
  AND a.carrera = i.carrera
  AND a.legajo = i.legajo
  AND sga_planes.unidad_academica = a.unidad_academica
  AND sga_planes.carrera = a.carrera
  AND sga_planes.plan = a.plan
  AND p.unidad_academica = a.unidad_academica
  AND p.nro_inscripcion = a.nro_inscripcion
  AND i.titulo_araucano IS NOT NULL
  AND p.fecha_nacimiento IS NOT NULL
  AND u.unidad_academica = p.unidad_academica
  AND sga_sedes.sede = a.sede;


SELECT COUNT(*) INTO cant_alumnos FROM int_arau_nominal WHERE anio_academico = pAnioAcademico;

 -- Alumnos que estan en CICLO COMUN que NO estan en alguna carrera de grado relacionada con el ciclo comun
 -- Verifica carreras de ciclo comun con carreras de grado definidas en la tabla "int_arau_car_cc"
 -- Estos alumnos se informaran a parte.
 INSERT INTO tmp_alumno_cc (unidad_academica, carrera, legajo)
     SELECT r.unidad_academica, r.carrera, r.legajo
       FROM int_arau_reinscrip as r,
            sga_alumnos as alu,
            sga_carreras as c 
      WHERE r.anio_academico = pAnioAcademico
        AND r.titulo_araucano IS NULL
        AND c.unidad_academica = r.unidad_academica
        AND c.carrera = r.carrera
        AND c.tipo_de_carrera = 'B' -- Ciclo Básico
        AND alu.unidad_academica = r.unidad_academica
        AND alu.carrera = r.carrera
        AND alu.legajo  = r.legajo
        AND NOT EXISTS (-- Que el alumno no este en una carrera de grado relacionada con el ciclo comun
                        SELECT 1 
                          FROM int_arau_nominal as b,
                               sga_alumnos as a,
                               int_arau_car_cc as iacc 
                          WHERE b.anio_academico = pAnioAcademico
                            AND a.unidad_academica = b.unidad_academica
                            AND a.carrera = b.carrera
                            AND a.legajo = b.legajo
                            AND alu.unidad_academica = a.unidad_academica
                            AND alu.nro_inscripcion  = a.nro_inscripcion
                            AND b.carrera <> r.carrera
                            AND iacc.unidad_academica   = r.unidad_academica
                            AND iacc.carrera_ciclocomun = r.carrera
                            AND b.carrera = iacc.carrera
                        );


-- Inserto los alumnos que SOLO estan en CICLOS COMUNES y no estan en ninguna carrera de grado asociada al ciclo comun.
-- Ciclos comunes que NO tienen un titulo araucano.
INSERT INTO int_arau_nominalcc ( 
            anio_academico, 
            unidad_academica, 
            carrera, 
            legajo, 
            plan,
            version,
            tipo_documento, 
            nro_documento, 
            genero, 
            fecha_nacimiento,
            instituc_araucano, 
            anio_ingreso)
   SELECT 
            t.anio_academico, 
            t.unidad_academica, 
            t.carrera, 
            t.legajo, 
            t.plan, 
            t.version, 
            t.tipo_documento, 
            t.nro_documento, 
            t.genero,
            t.fecha_nacimiento,
            t.instituc_araucano, 
            t.anio_academico
       FROM 
            tmp_alumno_cc as cc,
            int_arau_nominal as t
      WHERE  t.unidad_academica = cc.unidad_academica
        AND t.carrera = cc.carrera
        AND t.legajo = cc.legajo
        AND t.anio_academico = pAnioAcademico;
 


  -- ************************************************************************************************
  -- ***************  LISTA DE MATERIAS APROBADAS EN EL AÑO ACADEMICO A EVALUAR *********************
  -- ************************************************************************************************
  
  -- Materias aprobadas por PROMOCION de cursadas del año academico a evaluar
  INSERT INTO tmp_materias (forma_aprobacion, unidad_academica, carrera, legajo, materia_codigo, materia_nombre, obligatoria, carga_horaria, fecha, plan, version, acta, libro, folio_fisico)
    SELECT 
            2,
            d.unidad_academica,
            d.carrera,
            d.legajo,
            c.materia,
            NVL(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
            CASE sga_atrib_mat_plan.obligatoria
              WHEN 'S' THEN 0
              WHEN 'N' THEN 1
              ELSE 1
            END, 
            sga_atrib_mat_plan.carga_horaria_tot,
            to_char(d.fecha, "%Y%m%d"),
            d.plan, 
            d.version,
            p.acta,
            sga_libros_de_acta.nombre,
            sga_folios_promo.folio_fisico
       FROM sga_comisiones as c,
            sga_actas_promo as p,
            sga_det_acta_promo as d, 
            sga_materias,
            OUTER sga_libros_de_acta, 
            OUTER sga_folios_promo,
            OUTER sga_atrib_mat_plan
      WHERE p.comision = c.comision
        AND p.estado = 'C'
        AND d.unidad_academica = p.unidad_academica
        AND d.acta = p.acta
        AND d.rectificado = 'N'
        AND d.estado = 'A'
        AND d.resultado = 'P'  -- Promocionada
        AND d.fecha BETWEEN ld_FechaIniAA AND ld_FechaFinAA
        AND sga_materias.unidad_academica = c.unidad_academica
        AND sga_materias.materia = c.materia
        AND sga_libros_de_acta.libro = p.libro
        AND sga_folios_promo.unidad_academica = d.unidad_academica 
        AND sga_folios_promo.acta  = d.acta
        AND sga_folios_promo.folio = d.folio
        AND sga_atrib_mat_plan.unidad_academica = d.unidad_academica
        AND sga_atrib_mat_plan.carrera = d.carrera
        AND sga_atrib_mat_plan.plan    = d.plan
        AND sga_atrib_mat_plan.version = d.version
        AND sga_atrib_mat_plan.materia = c.materia;
        -- c.anio_academico = pAnioAcademico

  -- Promociones equivalentes. Promociones en otras carreras del alumno
  INSERT INTO tmp_materias (forma_aprobacion, unidad_academica, carrera, legajo, materia_codigo, materia_nombre, obligatoria, carga_horaria, fecha, plan, version, acta, libro, folio_fisico)
    SELECT 
            2,
            eq.unidad_academica,
            eq.carrera,
            eq.legajo,
            c.materia,
            NVL(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
            CASE sga_atrib_mat_plan.obligatoria
              WHEN 'S' THEN 0
              WHEN 'N' THEN 1
              ELSE 1
            END, 
            sga_atrib_mat_plan.carga_horaria_tot,
            to_char(eq.fecha, "%Y%m%d"),
            eq.plan, 
            eq.version,
            p.acta,
            sga_libros_de_acta.nombre,
            sga_folios_promo.folio_fisico
       FROM 
            sga_promo_equiv as eq,
            sga_comisiones as c,
            sga_actas_promo as p,
            sga_det_acta_promo as d, 
            sga_materias,
            OUTER sga_libros_de_acta, 
            OUTER sga_folios_promo,
            OUTER sga_atrib_mat_plan
      WHERE p.unidad_academica = eq.unidad_academica
        AND p.acta = eq.acta
        AND eq.estado = 'A' -- Activo
        AND p.comision = c.comision
        -- AND c.anio_academico = pAnioAcademico
        AND eq.fecha BETWEEN ld_FechaIniAA AND ld_FechaFinAA
        AND p.estado = 'C'
        AND d.unidad_academica = p.unidad_academica
        AND d.acta = p.acta
        AND d.carrera = eq.carrera_original
        AND d.legajo = eq.legajo_original 
        AND d.rectificado = 'N'
        AND d.estado = 'A'
        AND d.resultado = 'P'  -- Promocionada
        AND sga_materias.unidad_academica = c.unidad_academica
        AND sga_materias.materia = c.materia
        AND sga_libros_de_acta.libro = p.libro
        AND sga_folios_promo.unidad_academica = d.unidad_academica 
        AND sga_folios_promo.acta  = d.acta
        AND sga_folios_promo.folio = d.folio
        AND sga_atrib_mat_plan.unidad_academica = eq.unidad_academica
        AND sga_atrib_mat_plan.carrera = eq.carrera
        AND sga_atrib_mat_plan.plan    = eq.plan
        AND sga_atrib_mat_plan.version = eq.version
        AND sga_atrib_mat_plan.materia = c.materia;
 
  -- Materias aprobadas por EXAMEN
  INSERT INTO tmp_materias (forma_aprobacion, unidad_academica, carrera, legajo, materia_codigo, materia_nombre, obligatoria, carga_horaria, fecha, plan, version, acta, libro, folio_fisico)
    SELECT 
            CASE d.tipo_inscripcion
                 WHEN 'R' THEN 0 -- Examen Final Regular
                 WHEN 'L' THEN 1 -- Examen Libre
                 WHEN 'T' THEN 1 -- Tesis Examen Libre ?
                 ELSE 1 -- Examen Libre                 
            END, 
            d.unidad_academica,
            d.carrera,
            d.legajo,
            ae.materia,
            NVL(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
            CASE sga_atrib_mat_plan.obligatoria
              WHEN 'S' THEN 0
              WHEN 'N' THEN 1
              ELSE 1
            END, 
            sga_atrib_mat_plan.carga_horaria_tot,
            to_char(d.fecha_de_examen, "%Y%m%d"),
            d.plan,
            d.version,
            cast(d.acta as varchar(30)),
            sga_libros_de_acta.nombre,
            sga_folios.folio_fisico
            
       FROM sga_detalle_acta as d,
            sga_actas_examen as ae,
            sga_materias,  
            OUTER sga_libros_de_acta,
            OUTER sga_folios,
            OUTER sga_atrib_mat_plan
      WHERE d.fecha_de_examen BETWEEN ld_FechaIniAA AND ld_FechaFinAA
        AND d.estado = 'A'
        AND d.rectificado = 'N'
        AND d.resultado = 'A' 
        AND ae.unidad_academica = d.unidad_academica
        AND ae.acta = d.acta
        AND ae.tipo_acta = d.tipo_acta
        AND ae.estado = 'C'
        AND sga_materias.unidad_academica = ae.unidad_academica
        AND sga_materias.materia = ae.materia
        AND sga_libros_de_acta.libro = ae.libro
        AND sga_folios.unidad_academica = d.unidad_academica
        AND sga_folios.tipo_acta  = d.tipo_acta
        AND sga_folios.acta  = d.acta
        AND sga_folios.folio = d.folio
        AND sga_atrib_mat_plan.unidad_academica = d.unidad_academica
        AND sga_atrib_mat_plan.carrera = d.carrera
        AND sga_atrib_mat_plan.plan    = d.plan
        AND sga_atrib_mat_plan.version = d.version
        AND sga_atrib_mat_plan.materia = ae.materia;
  
  -- Examenes Equivalentes
  INSERT INTO tmp_materias (forma_aprobacion, unidad_academica, carrera, legajo, materia_codigo, materia_nombre, obligatoria, carga_horaria, fecha, plan, version, acta, libro, folio_fisico)
    SELECT 
            CASE d.tipo_inscripcion
                 WHEN 'R' THEN 0 -- Examen Final Regular
                 WHEN 'L' THEN 1 -- Examen Libre
                 WHEN 'T' THEN 1 -- Tesis Examen Libre ?
                 ELSE 1 -- Examen Libre                 
            END, 
            eq.unidad_academica,
            eq.carrera,
            eq.legajo,
            ae.materia,
            NVL(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
            CASE sga_atrib_mat_plan.obligatoria
              WHEN 'S' THEN 0
              WHEN 'N' THEN 1
              ELSE 1
            END, 
            sga_atrib_mat_plan.carga_horaria_tot,
            to_char(eq.fecha, "%Y%m%d"),
            eq.plan,
            eq.version,
            cast(eq.acta as varchar(30)),
            sga_libros_de_acta.nombre,
            sga_folios.folio_fisico
            
       FROM 
            sga_examenes_equiv as eq,  
            sga_detalle_acta as d,
            sga_actas_examen as ae,
            sga_materias,  
            OUTER sga_libros_de_acta,
            OUTER sga_folios,
            OUTER sga_atrib_mat_plan
  WHERE d.unidad_academica = eq.unidad_academica
        AND d.acta = eq.acta
        AND d.tipo_acta = eq.tipo_acta
        AND d.carrera = eq.carrera_original
        AND d.legajo = eq.legajo_original
        AND eq.estado = 'A'
        AND eq.fecha BETWEEN ld_FechaIniAA AND ld_FechaFinAA
        AND d.estado = 'A'
        AND d.rectificado = 'N'
        AND d.resultado = 'A' 
        AND ae.unidad_academica = d.unidad_academica
        AND ae.tipo_acta = d.tipo_acta
        AND ae.acta = d.acta
        AND ae.estado = 'C'
        AND sga_materias.unidad_academica = ae.unidad_academica
        AND sga_materias.materia = ae.materia
        AND sga_libros_de_acta.libro = ae.libro
        AND sga_folios.unidad_academica = d.unidad_academica
        AND sga_folios.tipo_acta  = d.tipo_acta
        AND sga_folios.acta  = d.acta
        AND sga_folios.folio = d.folio
        AND sga_atrib_mat_plan.unidad_academica = eq.unidad_academica
        AND sga_atrib_mat_plan.carrera = eq.carrera
        AND sga_atrib_mat_plan.plan    = eq.plan
        AND sga_atrib_mat_plan.version = eq.version
        AND sga_atrib_mat_plan.materia = ae.materia;


  -- Materias aprobadas por EQUIVALENCIA (Equivalencias Totales)
  INSERT INTO tmp_materias (forma_aprobacion, unidad_academica, carrera, legajo, materia_codigo, materia_nombre, obligatoria, carga_horaria, fecha, plan, version, expediente)
    SELECT 
            CASE sga_equiv_operac.origen
              WHEN 'E' THEN  3 -- Externa Libre
              WHEN 'S' THEN  4 -- Por Pase
              WHEN 'H' THEN  6 -- Homologada en el Plan de Estudios
              ELSE 5  -- Interna Libre (I, P, V, C)
            END,
            d.unidad_academica,
            d.carrera,
            d.legajo, 
            d.materia,
            NVL(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
            CASE sga_atrib_mat_plan.obligatoria
              WHEN 'S' THEN 0
              WHEN 'N' THEN 1
              ELSE 1
            END, 
            sga_atrib_mat_plan.carga_horaria_tot,
            to_char(d.fecha, "%Y%m%d"),
            d.plan,
            d.version,
            sga_equiv_operac.nro_resolucion
            -- NVL(sga_equiv_resol.nro_expendiente, sga_equiv_operac.nro_resolucion)
          
       FROM sga_equiv_otorgada as d,
            sga_equiv_operac,
            sga_materias,
            OUTER sga_atrib_mat_plan,
            OUTER sga_equiv_resol
      WHERE d.fecha BETWEEN ld_FechaIniAA AND ld_FechaFinAA
        AND d.resultado = 'A'
        AND d.alcance = 'T' -- Equivalencia Total
        AND d.estado = 'A'
        AND d.rectificado = 'N'
        AND sga_equiv_operac.operacion_equiv  = d.operacion_equiv
        -- AND sga_equiv_operac.aplic_automatica = 'N'
        -- AND sga_equiv_operac.origen IN ('E', 'S', 'I', 'H')
        AND sga_equiv_operac.estado = 'C'
        AND sga_equiv_resol.nro_resolucion = sga_equiv_operac.nro_resolucion
        AND sga_materias.unidad_academica = d.unidad_academica
        AND sga_materias.materia = d.materia
        AND sga_atrib_mat_plan.unidad_academica = d.unidad_academica
        AND sga_atrib_mat_plan.carrera = d.carrera
        AND sga_atrib_mat_plan.plan    = d.plan
        AND sga_atrib_mat_plan.version = d.version
        AND sga_atrib_mat_plan.materia = d.materia;


  -- Equivalencias Equivalentes. Equivalencias otorgadas en otra carrera
  INSERT INTO tmp_materias (forma_aprobacion, unidad_academica, carrera, legajo, materia_codigo, materia_nombre, obligatoria, carga_horaria, fecha, plan, version, expediente)
    SELECT 
            CASE sga_equiv_operac.origen
              WHEN 'E' THEN  3 -- Externa Libre
              WHEN 'S' THEN  4 -- Por Pase
              WHEN 'H' THEN  6 -- Homologada en el Plan de Estudios
              ELSE 5  -- Interna Libre (I, P, V, C)
            END,
            eq.unidad_academica,
            eq.carrera,
            eq.legajo, 
            d.materia,
            NVL(sga_atrib_mat_plan.nombre_materia, sga_materias.nombre),
            CASE sga_atrib_mat_plan.obligatoria
              WHEN 'S' THEN 0
              WHEN 'N' THEN 1
              ELSE 1
            END, 
            sga_atrib_mat_plan.carga_horaria_tot,
            to_char(eq.fecha, "%Y%m%d"),
            eq.plan,
            eq.version,
            sga_equiv_operac.nro_resolucion
            -- NVL(sga_equiv_resol.nro_expendiente, sga_equiv_operac.nro_resolucion)
          
       FROM 
            sga_equiv_equiv as eq,
            sga_equiv_otorgada as d,
            sga_equiv_operac,
            sga_materias,
            OUTER sga_atrib_mat_plan,
            OUTER sga_equiv_resol
  WHERE d.equivalencia = eq.equivalencia
        AND eq.estado = 'A'
        AND eq.fecha BETWEEN ld_FechaIniAA AND ld_FechaFinAA
        AND d.resultado = 'A'
        AND d.alcance = 'T' -- Equivalencia Total
        AND d.estado = 'A'
        AND d.rectificado = 'N'
        AND sga_equiv_operac.operacion_equiv  = d.operacion_equiv
        -- AND sga_equiv_operac.aplic_automatica = 'N'
        -- AND sga_equiv_operac.origen IN ('E', 'S', 'I', 'H')
        AND sga_equiv_operac.estado = 'C'
        AND sga_equiv_resol.nro_resolucion = sga_equiv_operac.nro_resolucion
        AND sga_materias.unidad_academica = d.unidad_academica
        AND sga_materias.materia = d.materia
        AND sga_atrib_mat_plan.unidad_academica = eq.unidad_academica
        AND sga_atrib_mat_plan.carrera = eq.carrera
        AND sga_atrib_mat_plan.plan    = eq.plan
        AND sga_atrib_mat_plan.version = eq.version
        AND sga_atrib_mat_plan.materia = d.materia;


CREATE INDEX  _id_temp_materias ON tmp_materias (unidad_academica, carrera, legajo);

  -- Inserto en tabla definitiva de materias aprobadas por cada titulo araucano a informar.
  -- Solo materias que pertenezcan a cada titulo a informar.
  INSERT INTO int_arau_nominalm 
          (anio_academico, unidad_academica, carrera, legajo, tipo_documento, nro_documento, instituc_araucano, titulo_araucano,
           fecha_aprobacion, materia_codigo, materia_nombre, carga_horaria, obligatoria, forma_aprobacion, libro, acta, folio_fisico, expediente)
    SELECT pAnioAcademico, a.unidad_academica, a.carrera, a.legajo, a.tipo_documento, a.nro_documento, a.instituc_araucano, a.titulo_araucano,
           t.fecha, t.materia_codigo, t.materia_nombre, t.carga_horaria, t.obligatoria, t.forma_aprobacion, t.libro, t.acta, t.folio_fisico, t.expediente
       FROM int_arau_nominal as a,
            tmp_materias as t
      WHERE a.anio_academico = pAnioAcademico
        AND a.anio_ingreso <= pAnioAcademico
        AND t.unidad_academica = a.unidad_academica
        AND t.carrera = a.carrera
        AND t.legajo  = a.legajo;

  -- Inserto en tabla definitiva de materias aprobadas por alumnos solo en ciclos comunes sin titulo araucano
  INSERT INTO int_arau_nomi_cc_m 
          (anio_academico, unidad_academica, carrera, legajo, tipo_documento, nro_documento, instituc_araucano,
           fecha_aprobacion, materia_codigo, materia_nombre, carga_horaria, obligatoria, forma_aprobacion, libro, acta, folio_fisico, expediente)
    SELECT pAnioAcademico, a.unidad_academica, a.carrera, a.legajo, a.tipo_documento, a.nro_documento, a.instituc_araucano, 
           t.fecha, t.materia_codigo, t.materia_nombre, t.carga_horaria, t.obligatoria, t.forma_aprobacion, t.libro, t.acta, t.folio_fisico, t.expediente
       FROM tmp_alumno_cc as cc,
            int_arau_nominalcc as a,
            tmp_materias as t
      WHERE a.anio_academico = pAnioAcademico
        AND a.anio_ingreso <= pAnioAcademico
        AND t.unidad_academica = a.unidad_academica
        AND t.carrera = a.carrera
        AND t.legajo  = a.legajo
        AND cc.unidad_academica = t.unidad_academica
        AND cc.carrera = t.carrera
        AND cc.legajo = t.legajo;


  -- *********************************** Fin materias aprobadas *******************************************
  
-- Borro tablas temporales
BEGIN
  ON EXCEPTION IN  (-206)
    -- Tabla temporal no existe
  END EXCEPTION WITH RESUME;
  
  DROP TABLE tmp_alumnos;
  DROP TABLE tmp_alumnos_plan;
  DROP TABLE tmp_alumno_cc;
  DROP TABLE tmp_materias_titulo;
  DROP TABLE tmp_materias;
END -- Borrado tablas temporales 

-- Retorno cantidad de alumnos
RETURN cant_alumnos;


END;
END PROCEDURE;         
-- ++++++++++++++++++++++++++++++ Fin Procedure sp_int_arau_nomi +++++++++++++++++++++++++++++

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_int_arau_nomi
-- *****************************************************************************
revoke execute on "dba".sp_int_arau_nomi from public;
grant execute on "dba".sp_int_arau_nomi to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_int_arau_nomi to internet; -- Rol de usuario de Internet