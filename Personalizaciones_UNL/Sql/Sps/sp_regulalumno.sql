CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_regulalumno') THEN
		DROP PROCEDURE sp_regulalumno;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *********************************************************************************
-- Procedure: sp_regulAlumno
-- Ultima modificacion: 1.11.0, 2.02.0, 2.03.0, 2.04.0, 2.05.0
--
-- Devuelve las regularidades de un alumno (Vigentes y no vigentes dependiendo del parametro).
-- Recupera TODAS las regularidades (segun parametros anteriores) del alumno en esa carrear
-- sea del plan actual o de planes anteriores, y de cualquier version, no solo la version
-- actual del plan.
-- *********************************************************************************
-- DROP PROCEDURE sp_regulAlumno;
CREATE PROCEDURE sp_regulAlumno(pUnidadAcademica LIKE sga_insc_cursadas.unidad_academica,
                                pCarrera         LIKE sga_insc_cursadas.carrera,
                                pLegajo          LIKE sga_insc_cursadas.legajo,
                                pTipoRegularidad  smallint DEFAULT 1,
                                pCursadaAprobada  smallint DEFAULT 1, 
                                pMatAprobada      smallint DEFAULT 1 )

   RETURNING  	varchar(5),		-- unidad academica
		varchar(5),		-- carrera
		varchar(15),		-- legajo
		varchar(5),		-- materia
		integer,		-- anio academico
		varchar(20),		-- periodo lectivo
		char(1),		-- resultado
		varchar(20),		-- resultado desc
		varchar(20),		-- origen de la cursada
		date,			-- fec fin vigencia regularidad
		date,			-- fec regularidad
		integer,		-- cond regularidad
		varchar(255),		-- materia nombre
		varchar(100),		-- docentes
		varchar(255),		-- carrera nombre
		integer,		-- Crédito de la materia
		varchar(5),		-- Plan de la regularizada
		char(1),		-- Si es Regularidad Vigente (S) o No Vigente (N)
		char(1),		-- Si la materia esta aprobada o no
		varchar(5),	-- Nota
		integer,		-- Acta
		varchar(15),	-- Nro Resolucion Equivalencia
		integer,	--equivalencia
		integer ;		-- escala_notas



/* Muestra todas las materias que un alumno tiene regularizadas y aquellas en las que tiene equivalencias parciales. 
pTipoRegularidad  = 1 - Reg Vigentes  /  2- Reg No vigentes  / 3 - Reg Vigentes y no Vigentes 
pCursadaAprobada  = 1 - Aprobada  /  2- Reprobada  / 3 - Aprobadas y Reprobadas
pMatAprobada       = 1 - Materias que NO esten aprobadas (por promocion, examen, equivalencia..) /  2- Materias que esten Aprobadas  / 3 - Aprobada o no  */

   -- var's para el manejo de excepciones
   DEFINE sql_err              integer;
   DEFINE isam_err             integer;
   DEFINE error_info           varchar(76);
   DEFINE v_user_error         varchar(10);

   DEFINE vcMateria            LIKE sga_materias.materia;
   DEFINE vcComision           LIKE sga_comisiones.comision;
   DEFINE iAnioAcademico       LIKE sga_periodos_lect.anio_academico;
   DEFINE vcPeriodoLectivo     LIKE sga_periodos_lect.periodo_lectivo;
   DEFINE vcResultado, vcResultadoDesc     varchar(20);
   DEFINE vcOrigen             char(20);
   DEFINE dFinVigRegularidad   LIKE sga_det_acta_curs.fin_vigencia_regul;
   DEFINE dFecRegularidad      LIKE sga_det_acta_curs.fecha_regularidad;
   DEFINE dCondRegularidad     LIKE sga_det_acta_curs.cond_regularidad;
   DEFINE vcMateriaDesc        LIKE sga_atrib_mat_plan.nombre_materia;
   DEFINE vcDocentes           varchar(255);
   DEFINE vcCarreraDesc        LIKE sga_carreras.nombre;
   DEFINE existen_materias, vcVigente, vcAprobada  char(1);
   DEFINE vcCredito		LIKE sga_atrib_mat_plan.credito;
   DEFINE vcPlanReg 		LIKE sga_planes.plan;
   DEFINE vcNota           LIKE sga_det_acta_curs.nota;
   DEFINE vcActa         LIKE sga_det_acta_curs.acta;
   DEFINE vcActaPromocion         LIKE sga_actas_promo.acta;
   DEFINE vcNroResolucion   LIKE sga_equiv_operac.nro_resolucion;
   DEFINE iEquivalencia	LIKE sga_equiv_otorgada.equivalencia;
   DEFINE iEscalaNotas	INTEGER;


/* Recupera las materias regularizadas por el alumno hasta la fecha. */

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
   END EXCEPTION;     

BEGIN

/********* Recupera la Historia Academica *******************/
 BEGIN    
     on exception in (-206)
       -- Tabla no existe continuo el proceso	
      end exception with resume;
      DROP TABLE tmp_hist_acad_mat;
 END;
 LET existen_materias = 'N';

 SELECT materia, resultado 
   FROM vw_hist_academica 
  WHERE unidad_academica = pUnidadAcademica 
    AND carrera          = pCarrera 
    AND legajo           = pLegajo
   INTO TEMP  tmp_hist_acad_mat WITH NO LOG;
  IF DBINFO("sqlca.sqlerrd2") > 0 THEN
      LET existen_materias = 'S';
  END IF;
 /******************************************************************/

   LET vcMateria           = NULL;
   LET vcComision          = NULL;
   LET iAnioAcademico      = NULL;
   LET vcPeriodoLectivo    = NULL;
   LET vcResultado         = NULL;
   LET dFinVigRegularidad  = NULL;
   LET dFecRegularidad     = NULL;
   LET dCondRegularidad    = NULL;
   LET vcMateriaDesc       = NULL;
   LET vcDocentes          = NULL;
   LET vcCarreraDesc       = NULL;
   LET vcCredito           = NULL;
   LET vcVigente           = NULL;
   LET vcAprobada          = NULL;
   LET vcNota	 	   	   = NULL;
   LET vcActa 		   	   = NULL;
   LET vcNroResolucion	   = NULL;
   LET iEquivalencia	   = NULL;
   LET iEscalaNotas		   = NULL;
   

  -- selecciono nombre de la carrera	
  SELECT  sga_carreras.nombre INTO vcCarreraDesc
	FROM sga_carreras
	where sga_carreras.unidad_academica = pUnidadAcademica
         AND sga_carreras.carrera          = pCarrera;

   -- Recupera regularidades aprobadas y reprobadas
   -- vencidas y no vencidas
   FOREACH
      SELECT {+ ordered } 
             sga_cursadas.materia,
             sga_cursadas.comision,
             sga_cursadas.resultado,
             -- ************************************************************************************************
             -- U820 Se devuelve la condición específica de regularidad
	     sga_cond_regular.descripcion,
             -- DECODE( sga_cursadas.resultado, 'P', 'Aprobado', 'A','Aprobado', 'R', 'Reprobado', 'U','Libre'),
             -- ************************************************************************************************
             DECODE( sga_cursadas.origen, 'P', 'Promocionada', 'C', 'Cursada', 'E', 'Equivalencia', 'EE', 'Equiv. Equivalente', 'CE', 'Cursada Equiv.' ),
             sga_cursadas.fin_vigencia_regul,
             sga_cursadas.fecha_regularidad,
             sga_cursadas.cond_regularidad,
             sga_atrib_mat_plan.nombre_materia,
             sp_docentes_com ( sga_cursadas.comision ) docentes,
             sga_atrib_mat_plan.credito,
             sga_cursadas.plan,
             sga_cursadas.acta_regular,
             sga_cursadas.acta_promocion,
             sga_cursadas.nota,
             sga_cursadas.nro_resolucion,
             sga_cursadas.equivalencia,
			 sga_cursadas.escala_notas
        INTO vcMateria,
             vcComision,
             vcResultado,
             vcResultadoDesc,
             vcOrigen,
             dFinVigRegularidad,
             dFecRegularidad,
             dCondRegularidad,
             vcMateriaDesc,
             vcDocentes,
             vcCredito,
             vcPlanReg, 
             vcActa,
             vcActaPromocion,
             vcNota,
             vcNroResolucion,
             iEquivalencia,
			 iEscalaNotas

        FROM sga_alumnos,
             sga_planes,
             sga_cursadas,
             sga_atrib_mat_plan,
		sga_cond_regular

       WHERE sga_alumnos.unidad_academica = pUnidadAcademica
         AND sga_alumnos.carrera          = pCarrera
         AND sga_alumnos.legajo           = pLegajo

         AND sga_planes.unidad_academica = sga_alumnos.unidad_academica 
         AND sga_planes.carrera          = sga_alumnos.carrera 
         AND sga_planes.plan             = sga_alumnos.plan 

         AND sga_cursadas.unidad_academica   = sga_alumnos.unidad_academica  
         AND sga_cursadas.carrera            = sga_alumnos.carrera  
         AND sga_cursadas.legajo             = sga_alumnos.legajo  

         AND sga_atrib_mat_plan.unidad_academica = sga_alumnos.unidad_academica 
         AND sga_atrib_mat_plan.carrera          = sga_alumnos.carrera 
         AND sga_atrib_mat_plan.plan             = sga_cursadas.plan 
         AND sga_atrib_mat_plan.version          = sga_cursadas.version
         AND sga_atrib_mat_plan.materia          = sga_cursadas.materia
	     AND sga_cursadas.cond_regularidad 	= sga_cond_regular.cond_regularidad

       ORDER BY sga_cursadas.fecha_regularidad, sga_cursadas.materia

 --            sga_atrib_mat_plan.nombre_reducido,

	IF vcOrigen = 'Cursada'  or vcOrigen = 'Cursada Equiv.' THEN
		-- El dato del acta esta en vcActa
		LET vcNroResolucion = NULL;
	ELIF vcOrigen = 'Promocionada' THEN
		LET vcActa = vcActaPromocion;
		LET vcNroResolucion = NULL;
	ELSE
		-- Cursada parcial equivalente...
		LET vcActa = NULL;  -- Setear el Nro de Resolucion.
	END IF

        -- saque la comision del query porque no traia las equivalencias!!!
        LET iAnioAcademico      = NULL;
        LET vcPeriodoLectivo    = NULL;

        SELECT anio_academico, periodo_lectivo
          INTO iAnioAcademico, vcPeriodoLectivo
          FROM sga_comisiones
         WHERE comision = vcComision;


      LET vcAprobada    = 'N';
      IF existen_materias = 'S' THEN
	IF (SELECT COUNT(*) FROM  tmp_hist_acad_mat
		WHERE materia = vcMateria
		AND resultado = 'A') > 0 THEN
		LET vcAprobada  = 'S';
	END IF;
    END IF;	

	-- Verifico si es vigente o no por la regularidad y el resultado Ausente
	-- IF  (dFinVigRegularidad IS NULL OR dFinVigRegularidad >= TODAY) and (vcResultado = 'A' or vcResultado = 'P') THEN
	IF  (dFinVigRegularidad IS NULL OR dFinVigRegularidad >= TODAY)  THEN
		LET vcVigente = 'S';
	ELSE
		LET vcVigente = 'N';
	END IF;
         	
         IF  ((vcVigente = 'S' AND pTipoRegularidad = 1)  OR (vcVigente = 'N' AND pTipoRegularidad = 2)  OR pTipoRegularidad = 3) AND
              ((vcAprobada = 'N'  AND pMatAprobada = 1) OR (vcAprobada = 'S'  AND pMatAprobada = 2) OR  pMatAprobada = 3 )   and
              (((vcResultado = 'A'  OR vcResultado = 'P') AND pCursadaAprobada = 1) OR (vcResultado = 'R'  AND pCursadaAprobada = 2) OR  pCursadaAprobada = 3 )   THEN

	RETURN pUnidadAcademica, pCarrera,pLegajo,vcMateria, iAnioAcademico, vcPeriodoLectivo, vcResultado,  vcResultadoDesc, vcOrigen, dFinVigRegularidad, dFecRegularidad, dCondRegularidad, vcMateriaDesc, vcDocentes,  vcCarreraDesc,   vcCredito, vcPlanReg, vcVigente, vcAprobada, vcNota, vcActa, vcNroResolucion, iEquivalencia, iEscalaNotas  WITH RESUME;
        END IF;
END FOREACH ;
   
   
   BEGIN
      on exception in (-206)
       -- Tabla no existe continuo el proceso	
      end exception with resume;
      DROP TABLE tmp_hist_acad_mat;
   END;

END;
END PROCEDURE;
-- ********************* FIN PROCEDURE sp_regulAlumno *********************

revoke execute on "dba".sp_regulalumno from public;

grant execute on "dba".sp_regulalumno to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp_regulalumno to internet; -- Usuario de internet
