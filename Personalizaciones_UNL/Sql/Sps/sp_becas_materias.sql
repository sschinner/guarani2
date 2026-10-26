-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.09.6
-- Procedure sp_becas_materias
--
-- Recupera información de las materias aprobadas por el alumno en un año calendario.
-- Utilizado para informar el archivo "materias.txt" de BECAS BELGRANO
-- *****************************************************************************

--  DROP PROCEDURE sp_becas_materias;
CREATE PROCEDURE sp_becas_materias(
    pUA LIKE sga_alumnos.unidad_academica,
    pCarrera         LIKE sga_alumnos.carrera,
    pLegajo          LIKE sga_alumnos.legajo,
    pAnioAcademico	Integer,
    pFechaDesde		Varchar(10),
    pFechaHasta		Varchar(10),
    pCarreraCC		Varchar(5)
)

 RETURNING
	varchar(3),		-- Tipo documento abreviado (DNI)
	varchar(15),	-- Nro de documento
	varchar(255),	-- Nombre de la materia en el plan
	char(1),		-- Periodo de Cursado: C=Cuatrimestral / A=Anual
	char(1),		-- Cursada: S=Cursada en el mismo año que se informa, N=Cursada en años anteriores, L=Rindió Libre
	varchar(10),	-- Fecha de Aprobación: dd/mm/yyyy
	char(1);		-- Curricular: Indica si la actividad es C=Curricular  u O=Optativa


  /* Muestra todas las materias que un alumno aprobó en un año calendario */
   DEFINE sql_err              integer;
   DEFINE isam_err             integer;
   DEFINE error_info           varchar(76);
   DEFINE v_user_error         varchar(10);

   DEFINE vTipoDocumento LIKE mdp_tipo_documento.desc_abreviada;
   DEFINE vNroDocumento LIKE sga_personas.nro_documento;
   DEFINE vMateria LIKE sga_materias.materia;
   DEFINE vNombreMateria LIKE sga_materias.nombre;
   DEFINE vFechaAprobacion varchar(10);
   DEFINE dFechaAprobacion DATE;
   DEFINE vPeriodoCursado char(1);
   DEFINE vPeriodoCursadoPL char(1);
   DEFINE vCursada char(1);
   DEFINE vResultado  char(1);
   DEFINE vFechaCursada Date;
   DEFINE iComision Integer;
   DEFINE vCurricular char(1);
   DEFINE vFechaDesde Date;
   DEFINE vCarreraCC like sga_carreras.carrera;
   
   DEFINE vcNota  LIKE sga_det_acta_curs.nota;


   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
   END EXCEPTION;     

BEGIN
   LET vTipoDocumento = NULL;
   LET vNroDocumento = NULL;
   LET vFechaAprobacion = NULL;
   LET dFechaAprobacion = NULL;
   LET vMateria = NULL;
   LET vNombreMateria = NULL;
   LET vPeriodoCursado = NULL;
   LET vPeriodoCursadoPL = NULL;
   LET vCursada = NULL;
   LET vFechaCursada = NULL;
   LET vCurricular = NULL;
  
  IF pCarreraCC IS NULL THEN 
      LET vCarreraCC = ''; 
  ELSE
      LET vCarreraCC = pCarreraCC;
  END IF;

  LET vFechaDesde = to_date(pFechaDesde,"%Y-%m-%d");


 -- Recupero tipo y nro de documento del alumno
 SELECT td.desc_abreviada, per.nro_documento
   INTO vTipoDocumento, vNroDocumento
  FROM sga_alumnos as a 
  JOIN sga_personas as per ON per.unidad_academica = a.unidad_academica AND per.nro_inscripcion = a.nro_inscripcion 
  JOIN mdp_tipo_documento as td ON td.tipo_documento = per.tipo_documento
  WHERE a.unidad_academica = pUA
    AND a.carrera = pCarrera
    AND a.legajo = pLegajo;	   


 -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 -- Recorro las actividades aprobadas por el alumno en la carrera 
 -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 FOREACH 
  SELECT
    v.fecha,
    atmp.nombre_materia,
    CASE plg.tipo_de_periodo WHEN 'Anual' THEN 'A' ELSE 'C' END as tipo_periodo,
    CASE atmp.tipo_materia WHEN 'O' THEN 'N' ELSE 'S' END as curricular,
	v.materia
   
    INTO dFechaAprobacion, vNombreMateria, vPeriodoCursadoPL, vCurricular, vMateria
    FROM sga_alumnos as a,
         sga_planes as p,
         sga_atrib_mat_plan as atmp,
         OUTER sga_per_lect_gen as plg,
         vw_hist_academica as v
   WHERE a.unidad_academica = pUA
       AND a.carrera = pCarrera
       AND a.legajo = pLegajo
       
       AND p.unidad_academica = a.unidad_academica
       AND p.carrera = a.carrera
       AND p.plan    = a.plan
       
      
       AND v.unidad_academica = a.unidad_academica
       AND v.carrera = a.carrera
       AND v.legajo = a.legajo
       AND resultado = 'A' 
       -- AND v.forma_aprobacion NOT IN ('Homologada', 'Otras')
       AND v.fecha BETWEEN to_date(pFechaDesde,'%Y-%m-%d') AND to_date(pFechaHasta,'%Y-%m-%d')

       AND atmp.unidad_academica = a.unidad_academica
       AND atmp.carrera = p.carrera
       AND atmp.plan    = p.plan
       AND atmp.version = p.version_actual
       AND atmp.materia = v.materia
       
       AND plg.periodo_lectivo = atmp.periodo_dictado
       AND not exists (select ''
			from u820_cursos_ing
			where unidad_academica = a.unidad_academica
				and carrera = p.carrera
				and materia = v.materia)

UNION
  -- Materias del Ciclo Basico Comun que no estan en el plan de estudios de la carrera.
  SELECT
    vw.fecha,
    atmp.nombre_materia,
    CASE plg.tipo_de_periodo WHEN 'Anual' THEN 'A' ELSE 'C' END as tipo_periodo,
    CASE atmp.tipo_materia WHEN 'O' THEN 'N' ELSE 'S' END as curricular,
	vw.materia 
 FROM sga_alumnos as a,
      sga_alumnos as b,
     sga_planes as p,
     sga_atrib_mat_plan as atmp,
     OUTER sga_per_lect_gen as plg,
      vw_hist_academica as vw 
 WHERE a.unidad_academica = pUA
   AND a.carrera = pCarrera
   AND a.legajo  = pLegajo

   AND b.unidad_academica = a.unidad_academica
   AND b.nro_inscripcion  = a.nro_inscripcion
   AND b.carrera          = vCarreraCC

   AND p.unidad_academica = b.unidad_academica
   AND p.carrera = b.carrera
   AND p.plan    = b.plan

   AND atmp.unidad_academica = p.unidad_academica
   AND atmp.carrera = p.carrera
   AND atmp.plan    = p.plan
   AND atmp.version = p.version_actual
			
   AND plg.periodo_lectivo = atmp.periodo_dictado

   AND vw.unidad_academica = b.unidad_academica
   AND vw.carrera          = b.carrera
   AND vw.legajo           = b.legajo
   AND vw.materia          = atmp.materia
   AND vw.resultado = 'A' 
   -- AND vw.forma_aprobacion NOT IN ('Homologada', 'Otras')
   AND vw.fecha BETWEEN to_date(pFechaDesde,'%Y-%m-%d') AND to_date(pFechaHasta,'%Y-%m-%d')
   AND vw.materia NOT IN (SELECT vw2.materia
						  FROM sga_alumnos as c,
	                           sga_planes as p,
                   			 sga_atrib_mat_plan as atmp,
                     	       vw_hist_academica as vw2
						WHERE c.unidad_academica = pUA
						AND c.carrera = pCarrera
						AND c.legajo = pLegajo
						AND p.unidad_academica = c.unidad_academica
						AND p.carrera = c.carrera
						AND p.plan    = c.plan
						AND atmp.unidad_academica = p.unidad_academica
						AND atmp.carrera = p.carrera
						AND atmp.plan    = p.plan
						AND atmp.version = p.version_actual

						AND vw2.unidad_academica = c.unidad_academica
						AND vw2.carrera = c.carrera
						AND vw2.legajo  = c.legajo
						AND vw2.materia = atmp.materia
						AND vw2.resultado = 'A')
   AND not exists (select ''
		from u820_cursos_ing
		where unidad_academica = b.unidad_academica
			and carrera = b.carrera
			and materia = vw.materia)
    ORDER BY 1
 
    -- Fecha de aprobacion
    LET vFechaAprobacion = to_char(dFechaAprobacion,'%d-%m-%Y');
	
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Recupero ultima cursada de la actividad (aprobada/promocionada)
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	LET vFechaCursada = NULL;
	LET vCursada = 'L'; -- No fue cursada.
	LET iComision = NULL;

	FOREACH SELECT fecha_regularidad, comision 
	          INTO vFechaCursada, iComision
	          FROM sga_cursadas
			 WHERE unidad_academica = pUA 
			   AND carrera = pCarrera 
			   AND legajo = pLegajo 
			   AND materia = vMateria 
			   AND resultado IN ('A','P')
			   AND comision IS NOT NULL
			 ORDER BY fecha_regularidad DESC
		EXIT FOREACH;	   
	END FOREACH;
	
	IF vFechaCursada IS NULL THEN 
	   LET vCursada = 'L'; -- No fue cursada.
	ELSE 
	   IF vFechaCursada >= vFechaDesde THEN 
	       LET vCursada = 'S'; -- Cursada durante el año a evaluar
	   ELSE 
	       LET vCursada = 'N';  -- Cursada en algun año anterior
	   END IF;
	END IF;
	
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Tipo de Periodo lectivo en que la cursó
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	IF iComision IS NOT NULL THEN 
	   -- Si la cursó, busco el tipo de periodo lectivo en que la cursó
	   SELECT CASE pl.tipo_de_periodo WHEN 'Anual' THEN 'A' ELSE 'C' END
	     INTO vPeriodoCursado
	     FROM sga_comisiones as c
	     JOIN sga_periodos_lect as pl ON pl.anio_academico = c.anio_academico AND pl.periodo_lectivo = c.periodo_lectivo 
	     WHERE c.comision = iComision;
	END IF; 
	
	IF vPeriodoCursado IS NULL THEN 
	   LET vPeriodoCursado = NVL(vPeriodoCursadoPL, 'C'); -- Por defecto el del plan de estudios y si no esta cargado se devuelve como cuatrimestral.
	END IF;
	
    RETURN vTipoDocumento, vNroDocumento, vNombreMateria, vPeriodoCursado, vCursada, vFechaAprobacion, vCurricular WITH RESUME ;
   END FOREACH ;

  
END;
END PROCEDURE;
-- ********************* FIN PROCEDURE sp_becas_materias *********************

GRANT EXECUTE ON sp_becas_materias TO public;


select * from sga_atrib_mat_plan;
