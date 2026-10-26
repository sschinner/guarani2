drop PROCEDURE "dba".sp820_fichAluReg;
CREATE PROCEDURE "dba".sp820_fichAluReg ( pUnidadAcademica LIKE sga_personas.unidad_academica, pNroInscripcion LIKE sga_personas.nro_inscripcion )
       RETURNING varchar(5), varchar(10), varchar(30), varchar(30), varchar(5), varchar(255), varchar(15), varchar(5), varchar(255), integer, varchar(20), char(1),varchar(20),varchar(20), date, date, integer,varchar(5), char(1), varchar(5), integer, char(1), varchar(60);

-- Descripcion del Return:
--varchar(5),   -- vc_UA, 
--varchar(10),  -- vc_NroInscripcion, 
--varchar(30),  -- vc_Apellido, 
--varchar(30),  -- vc_Nombres, 
--varchar(5),   -- vc_Carrera, 
--varchar(255), -- vc_CarreraNombre, 
--varchar(15),  -- vc_Legajo, 
--varchar(5),   -- vc_Materia, 
--varchar(255), -- vc_MateriaNombre, 
--integer       -- vc_Anio, 
--varchar(20)   -- vc_PerLect, 
--char(1)       -- vc_Resultado, 
--varchar(20)   -- vc_ResultadoDesc, 
--varchar(20)   -- vc_Origen, 
--date,         -- vd_FinVigencia, 
--date,         -- vd_Regularidad, 
--integer       -- vc_CondRegular;
-- varchar(5)   -- vc_PlanReg;
-- char(1),     -- Regularidad Vigente o No vigente
-- varchar(5),  -- Nota
-- integer,     -- Nro de Acta de regulares
-- char(1),     -- Materia Aprobada (por examen, equivalencia, promocion)
-- varchar (60), -- Descripcion de la regularidad.



-- Definición de Variables.
DEFINE vi_retorno          SMALLINT;
DEFINE vc_UA               LIKE sga_personas.unidad_academica;
DEFINE vc_NroInscripcion   LIKE sga_personas.nro_inscripcion;
DEFINE vc_apellido         LIKE sga_personas.apellido;
DEFINE vc_nombres          LIKE sga_personas.nombres;
DEFINE vc_Carrera          LIKE sga_alumnos.carrera;
DEFINE vc_CarreraNombre    LIKE sga_carreras.nombre;
DEFINE vc_CarreraNomRed    LIKE sga_carreras.nombre_reducido;
DEFINE vc_Legajo           LIKE sga_alumnos.legajo;
DEFINE vc_Materia          LIKE sga_materias.materia;
DEFINE vc_Anio             LIKE sga_anio_academico.anio_academico;
DEFINE vc_PerLect          LIKE sga_periodos_lect.periodo_lectivo;
DEFINE vc_ResultadoDesc    varchar(20);
DEFINE vc_Origen           varchar(20);
DEFINE vd_FinVigencia      LIKE sga_det_acta_curs.fin_vigencia_regul;
DEFINE vd_Regularidad      LIKE sga_det_acta_curs.fecha_regularidad;
DEFINE vd_Resultado        LIKE sga_det_acta_curs.resultado;
DEFINE vc_CondRegular      LIKE sga_det_acta_curs.cond_regularidad;
DEFINE vc_MateriaNombre    LIKE sga_atrib_mat_plan.nombre_materia;
DEFINE vc_Docentes         varchar(255);
DEFINE vc_Credito          LIKE sga_atrib_mat_plan.credito;
DEFINE vc_PlanReg          LIKE sga_planes.plan;
DEFINE vc_Resultado        char(1);
DEFINE vc_Vigente	   char(1); -- S = Vigente, N = Reg no Vigente
DEFINE vc_Aprobada	   char(1); -- S = Aprobada, N = No Aprobada
DEFINE vc_Nota          LIKE sga_det_acta_curs.nota;
DEFINE vc_Acta		LIKE sga_det_acta_curs.acta;
DEFINE vcCondRegDesc	like sga_cond_regular.descripcion;
DEFINE vc_planRegReg varchar(5);
DEFINE vc_versionReg varchar(5);

BEGIN
   
   -- inicializaciones.
   LET vi_retorno          = 0;
   LET vc_UA               = NULL;
   LET vc_NroInscripcion   = NULL;
   LET vc_apellido         = NULL;
   LET vc_nombres          = NULL;
   LET vc_Carrera          = NULL;
   LET vc_CarreraNombre    = NULL;
   LET vc_CarreraNomRed    = NULL;
   LET vc_Legajo           = NULL;
   LET vc_Materia          = NULL;
   LET vc_Anio             = NULL;
   LET vc_PerLect          = NULL;
   LET vc_Resultado        = NULL;
   LET vc_ResultadoDesc    = NULL;
   LET vc_Origen           = NULL;
   LET vd_FinVigencia      = NULL;
   LET vd_Regularidad      = NULL;
   LET vc_CondRegular      = NULL;
   LET vc_MateriaNombre    = NULL;
   LET vc_Docentes         = NULL;
   LET vc_PlanReg 	   = NULL;
   LET vc_Vigente 	   = NULL;
   LET vc_Nota	 	   = NULL;
   LET vc_Acta 		   = NULL;
   LET vcCondRegDesc	= NULL;
   LET vc_planRegReg 		= NULL;
   LET vc_versionReg 	= NULL;

   -- selecciono los datos personales de la persona.
   SELECT sga_personas.unidad_academica,
          sga_personas.nro_inscripcion,
          sga_personas.apellido,
          sga_personas.nombres
     INTO vc_UA, vc_NroInscripcion, vc_apellido, vc_nombres
     FROM sga_personas
    WHERE sga_personas.unidad_academica = pUnidadAcademica
      AND sga_personas.nro_inscripcion = pNroInscripcion;
   
   -- selecciono las carreras en las que esta inscripta la persona.
   FOREACH SELECT sga_alumnos.carrera,
                  sga_alumnos.legajo,
                  sga_carreras.nombre_reducido
             INTO vc_carrera, vc_legajo, vc_CarreraNomRed
             FROM sga_alumnos,
                  sga_carreras
            WHERE sga_alumnos.unidad_academica = vc_UA
              AND sga_alumnos.nro_inscripcion = vc_NroInscripcion
              AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica
              AND sga_carreras.carrera = sga_alumnos.carrera
         ORDER BY sga_alumnos.carrera

      -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- ejecuto el SP de las regularidades para cada carrera de la persona. 
      -- Recupera: regulares vigentes y no vigentes (3) y 
      --   	   Cursadas aprobadas y reprobadas no (3)
      --   	   Materias aprobadas o no (3)
      -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ------  FOREACH EXECUTE PROCEDURE sp820_RegulAlumno ( vc_UA, vc_carrera, vc_legajo , 3, 1, 3) 
    ----------- cambio 03/10/2011 para mostrar también los libres
       FOREACH EXECUTE PROCEDURE sp820_RegulAlumno ( vc_UA, vc_carrera, vc_legajo , 3, 3, 3) 
         INTO vc_UA, vc_Carrera, vc_Legajo, vc_Materia, vc_Anio, vc_PerLect, vc_Resultado, vc_ResultadoDesc, vc_Origen, vd_FinVigencia, vd_Regularidad, vc_CondRegular, vc_MateriaNombre, vc_Docentes, vc_CarreraNombre,vc_Credito,vc_PlanReg, vc_Vigente, vc_Aprobada, vc_Nota, vc_Acta, vcCondRegDesc

         -- el retorno final por cada materia.
         LET vi_retorno = 1;
         RETURN vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_Carrera, vc_CarreraNomRed, vc_Legajo, vc_Materia, vc_MateriaNombre, vc_Anio, vc_PerLect, vc_Resultado, vc_ResultadoDesc, vc_Origen, vd_FinVigencia, vd_Regularidad, vc_CondRegular, vc_PlanReg, vc_Vigente, vc_Nota, vc_Acta, vc_Aprobada, vcCondRegDesc  WITH RESUME;  
         
      END FOREACH;
      
      -- ejecuto el SP de las regularidades en Cierres Parciales para cada carrera de la persona.
      -- Muestra las regularidades con resultado, Aprobado o Reprobado, tenga o no la materia aprobada por examen, equiv, etc.
      LET vd_FinVigencia = NULL;
      FOREACH EXECUTE PROCEDURE sp_RegParcialAlu ( vc_UA, vc_carrera, vc_legajo ) 
                 INTO vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_Carrera, vc_CarreraNombre, vc_Legajo, vc_Materia, vc_MateriaNombre, vc_Anio, vc_PerLect, vc_Resultado, vc_ResultadoDesc, vd_Regularidad, vc_CondRegular, vc_Nota, vc_Acta, vc_planRegReg, vc_versionReg
         
         LET vi_retorno = 1;
         RETURN vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_Carrera, vc_CarreraNomRed, vc_Legajo, vc_Materia, vc_MateriaNombre, vc_Anio, vc_PerLect, vc_Resultado, vc_ResultadoDesc, 'Cursada Provisoria',vd_FinVigencia, vd_Regularidad, vc_CondRegular, vc_PlanReg, 'S', vc_nota, vc_Acta, 'N', 'No Cerrada'  WITH RESUME;
         
      END FOREACH;
      
      -- reseteo las variables de carrera.
      LET vc_carrera = NULL;
      LET vc_legajo = NULL;

   END FOREACH;
  
   -- si no tiene materias cursadas en ninguna carrera, devuelvo solamente los datos personales.
   IF vi_retorno = 0 THEN
      RETURN vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_Carrera, vc_CarreraNombre, vc_Legajo, vc_Materia, vc_MateriaNombre, vc_Anio, vc_PerLect, vc_Resultado, vc_ResultadoDesc, vc_Origen, vd_FinVigencia, vd_Regularidad, vc_CondRegular,vc_PlanReg, 'N', NULL, NULL, NULL, vcCondRegDesc ;  
   END IF;
   
END;

END PROCEDURE                                          
