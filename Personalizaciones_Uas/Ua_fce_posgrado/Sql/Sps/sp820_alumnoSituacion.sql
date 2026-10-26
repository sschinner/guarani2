drop PROCEDURE "dba".sp820_alumnoSituacion;
CREATE PROCEDURE "dba".sp820_alumnoSituacion ( pUnidadAcademica varchar(5), pCarrera varchar(5), pLegajo varchar(15), pObservacion varchar(4), pObservaciones varchar(200))
       RETURNING varchar(5), varchar(10), varchar(30), varchar(30), varchar(5), varchar(255), varchar(15), varchar(5), varchar(255), integer, varchar(20), char(1),varchar(200),varchar(20), date, date, integer,varchar(5), char(1), varchar(5), integer, char(1), varchar(100), varchar(3), varchar(15), integer, integer, decimal(4,2);

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
--varchar(20)   -- cambia vc_ResultadoDesc,   por descripcion de 200NO 
--varchar(20)   --  fecha ultima materia              era vc_Origen
--date,         -- vd_FinVigencia, 
--date,         -- vd_Regularidad, 
--integer       -- vc_CondRegular;
-- varchar(5)   --    Año reinscripcion                   era vc_PlanReg;  
-- char(1),     -- Regularidad Vigente o No vigente
-- varchar(5),  -- Calidad    - era Nota ???
-- integer,     -- Año ingreso FCE  -era Nro acta de regulares
-- char(1),     -- Materia Aprobada (por examen, equivalencia, promocion)
-- varchar (100), --  Descripcion de la regularidad. 
-- varchar(3),   -- TipoDocDesAbre   
-- varchar(15),-- NroDocumento  
-- integer, -- Aprobadas
-- integer, -- Reprobadas
-- decimal, -- PromConApla

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
--- agregado
DEFINE vc_Observaciones varchar(200);

DEFINE vc_Origen           varchar(20);
--- agregado
DEFINE vc_FechaUltima varchar(20);
DEFINE vd_FinVigencia      LIKE sga_det_acta_curs.fin_vigencia_regul;
DEFINE vd_Regularidad      LIKE sga_det_acta_curs.fecha_regularidad;
DEFINE vd_Resultado        LIKE sga_det_acta_curs.resultado;
DEFINE vc_CondRegular      LIKE sga_det_acta_curs.cond_regularidad;
DEFINE vc_MateriaNombre    LIKE sga_atrib_mat_plan.nombre_materia;
DEFINE vc_Docentes         varchar(255);
DEFINE vc_Credito          LIKE sga_atrib_mat_plan.credito;
DEFINE vc_PlanReg          LIKE sga_planes.plan;
---- agregado
DEFINE vc_AnioReinsc 	VARCHAR(5);

DEFINE vc_Resultado        char(1);
DEFINE vc_Vigente	   char(1); -- S = Vigente, N = Reg no Vigente
DEFINE vc_Aprobada	   char(1); -- S = Aprobada, N = No Aprobada
DEFINE vc_Nota          LIKE sga_det_acta_curs.nota;
---- agregado
DEFINE vc_Calidad 	VARCHAR(5);

DEFINE vc_Acta	LIKE sga_det_acta_curs.acta;
---- agregado
DEFINE vc_AnioIngreso	LIKE sga_det_acta_curs.acta;
DEFINE vcCondRegDesc	like sga_cond_regular.descripcion;
--- agregado
DEFINE vc_planRegReg varchar(5);
DEFINE vc_versionReg varchar(5);
DEFINE vc_TipoDocDesAbre     LIKE mdp_tipo_documento.desc_abreviada;
DEFINE vc_NroDocumento       VARCHAR(15);
DEFINE vi_Aprobadas INTEGER;
DEFINE vi_Reprobadas INTEGER;
DEFINE vs_PromConApla DECIMAL;


DEFINE vcCondRegDesc1	like sga_cond_regular.descripcion;
DEFINE a_fecha_ultima DATE;
DEFINE vc_FechaUltimaa varchar(20);

BEGIN
   
   -- inicializaciones.
   LET vi_retorno          = 0;
   LET vc_UA               = pUnidadAcademica;
   LET vc_NroInscripcion   = NULL;
   LET vc_apellido         = NULL;
   LET vc_nombres          = NULL;
   LET vc_Carrera          = pCarrera;
   LET vc_CarreraNombre    = NULL;
   LET vc_CarreraNomRed    = NULL;
   LET vc_Legajo           = pLegajo;
   LET vc_Materia          = NULL;
   LET vc_Anio             = NULL;
   LET vc_PerLect          = NULL;
   LET vc_Resultado        = NULL;
   LET vc_ResultadoDesc    = NULL;
   LET vc_Observaciones = NULL;
 	
   LET vc_Origen           = NULL;
   LET vc_FechaUltima = NULL;		
   LET vd_FinVigencia      = NULL;
   LET vd_Regularidad      = NULL;
   LET vc_CondRegular      = NULL;
   LET vc_MateriaNombre    = NULL;
   LET vc_Docentes         = NULL;
   LET vc_PlanReg 	   = NULL;
   LET vc_AnioReinsc = NULL;
   LET vc_Vigente 	   = NULL;
   LET vc_Nota	 	   = NULL;
   LET vc_Calidad = NULL;	
   LET vc_Acta = Null;
   LET vc_AnioIngreso 		   = NULL;
   LET vcCondRegDesc	= NULL;
   LET vc_planRegReg 		= NULL;
   LET vc_versionReg 	= NULL;
   LET vc_TipoDocDesAbre    = NULL ;
   LET vc_NroDocumento      = NULL ;
   LET vi_Aprobadas      = 0 ;
   LET vi_Reprobadas      = 0 ;
   LET vs_PromConApla      = 0 ;


   -- datos personales.
   SELECT sga_personas.unidad_academica,
          sga_personas.nro_inscripcion,
          mdp_tipo_documento.desc_abreviada,
          sga_personas.nro_documento,
          sga_personas.apellido,
          sga_personas.nombres,
          sga_carreras.carrera,
          sga_carreras.nombre,
          sga_alumnos.calidad
     INTO vc_UA,
          vc_NroInscripcion,
          vc_TipoDocDesAbre,
          vc_NroDocumento,
          vc_apellido,
          vc_nombres,
          vc_carrera,
          vc_CarreraNombre,
          vc_Calidad
     FROM sga_personas,
          sga_alumnos,
	sga_carreras,
          mdp_tipo_documento
    WHERE sga_alumnos.unidad_academica = pUnidadAcademica
      AND sga_alumnos.carrera = pCarrera
      AND sga_alumnos.legajo  = pLegajo
      AND dba.sga_personas.unidad_academica = dba.sga_alumnos.unidad_academica
      AND dba.sga_personas.nro_inscripcion = dba.sga_alumnos.nro_inscripcion
      AND dba.mdp_tipo_documento.tipo_documento = dba.sga_personas.tipo_documento 
     AND dba.sga_carreras.carrera = dba.sga_alumnos.carrera;

--   14/05/2012
    select min(p.anio_academico) into vc_AnioIngreso
	from sga_alumnos a 
		join sga_carrera_aspira c 
			join sga_periodo_insc p
			on c.periodo_inscripcio = p.periodo_inscripcio
		on c.unidad_academica = a.unidad_academica
--			and c.carrera = a.carrera
			and c.nro_inscripcion = a.nro_inscripcion
-- se agrega que no considere carreras inválidas
 			and c.situacion_asp not in ('RC','RF','RR')
                where a.legajo = pLegajo
	and a.unidad_academica = pUnidadAcademica;
--	and a.calidad <> 'E';

--   14/05/2012
    select max(rei.anio_academico) into vc_AnioReinsc
	from sga_reinscripcion rei
                where rei.legajo = pLegajo and
                           rei.carrera = pCarrera;
	
--   14/05/2012
           SELECT max(fecha) into a_fecha_ultima
                       FROM vw820_hist_academ
                         WHERE
                          unidad_academica = pUnidadAcademica and
                          carrera = pCarrera and resultado = 'A' and
           	          legajo = pLegajo;
      

           LET vc_FechaUltimaa = NULL;
           IF NOT a_fecha_ultima is null  then 
                  LET vc_FechaUltimaa = a_fecha_ultima;
                  LET vc_FechaUltima = substr (vc_FechaUltimaa, 4, 3) || substr (vc_FechaUltimaa, 1, 3) || substr (vc_FechaUltimaa, 7, 4);
           end if; 
	 
LET vc_Observaciones = pObservaciones;
	 	
   ------------------------------------------   APROBADAS/REPROBADAS

SELECT 
         u820_cuenta_mat_rapido(pUnidadAcademica,pCarrera,pLegajo,"A",pla.plan,pla.version_actual),
         u820_cuenta_mat_rapido(pUnidadAcademica,pCarrera,pLegajo,"R",pla.plan,pla.version_actual),
         sp820_prom_alu_res1( pUnidadAcademica, pCarrera, pLegajo, 'S') 
    INTO vi_Aprobadas,
             vi_Reprobadas,
             vs_PromConApla
    FROM sga_planes pla        
   WHERE     
         pla.unidad_academica = pUnidadAcademica AND
         pla.carrera = pCarrera  and
         pla.estado = 'V';
         
      -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- ejecuto el SP de las regularidades para cada carrera de la persona. 
      -- Recupera: regulares vigentes y no vigentes (3) y 
      --   	   Cursadas aprobadas y reprobadas no (3)
      --   	   Materias aprobadas o no (3)
      -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ------  FOREACH EXECUTE PROCEDURE sp820_RegulAlumno ( vc_UA, vc_carrera, vc_legajo , 3, 1, 3) 
    ----------- cambio 03/10/2011 para mostrar también los libres
       FOREACH 
          EXECUTE PROCEDURE sp820_RegulAlumno ( vc_UA, vc_carrera, vc_legajo , 3, 3, 3) 
         INTO vc_UA, vc_Carrera, vc_Legajo, vc_Materia, vc_Anio, vc_PerLect, vc_Resultado, vc_ResultadoDesc, vc_Origen, vd_FinVigencia, vd_Regularidad, vc_CondRegular, vc_MateriaNombre, vc_Docentes, vcCondRegDesc1, vc_Credito,vc_PlanReg, vc_Vigente, vc_Aprobada, vc_Nota, vc_Acta, vcCondRegDesc

         -- el retorno final por cada materia.
    --         LET vi_retorno = 1;
        IF vc_Anio = pObservacion then 
--  and (pObservacion <> '0000') then
         RETURN vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_Carrera, vc_CarreraNombre, vc_Legajo, vc_Materia, vc_MateriaNombre, vc_Anio, vc_PerLect, vc_Resultado, vc_Observaciones, vc_FechaUltima, vd_FinVigencia, vd_Regularidad, vc_CondRegular, vc_AnioReinsc, vc_Vigente, vc_Calidad, vc_AnioIngreso, vc_Aprobada, vcCondRegDesc,           vc_TipoDocDesAbre,
          vc_NroDocumento, vi_Aprobadas, vi_Reprobadas, vs_PromConApla WITH RESUME;  
         LET vi_retorno = 1;
       END IF;
  
         
        END FOREACH;
      
      -- ejecuto el SP de las regularidades en Cierres Parciales para cada carrera de la persona.
      -- Muestra las regularidades con resultado, Aprobado o Reprobado, tenga o no la materia aprobada por examen, equiv, etc.
      LET vd_FinVigencia = NULL;
       FOREACH
            EXECUTE PROCEDURE sp_RegParcialAlu ( vc_UA, vc_carrera, vc_legajo ) 
                 INTO vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_Carrera, vcCondRegDesc1, vc_Legajo, vc_Materia, vc_MateriaNombre, vc_Anio, vc_PerLect, vc_Resultado, vc_ResultadoDesc, vd_Regularidad, vc_CondRegular, vc_Nota, vc_Acta, vc_planRegReg, vc_versionReg
  
     --    LET vi_retorno = 1;
       IF vc_Anio = pObservacion then
-- and pObservacion <> '0000' then  
       RETURN vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_Carrera, vc_CarreraNombre, vc_Legajo, vc_Materia, vc_MateriaNombre, vc_Anio, vc_PerLect, vc_Resultado, vc_Observaciones, vc_FechaUltima,vd_FinVigencia, vd_Regularidad, vc_CondRegular, vc_AnioReinsc, 'S', vc_Calidad, vc_AnioIngreso, 'N', 'Parcial',           vc_TipoDocDesAbre,
          vc_NroDocumento, vi_Aprobadas, vi_Reprobadas, vs_PromConApla  WITH RESUME;
         LET vi_retorno = 1;
     
       END IF;
    
           END FOREACH;
      
        
   -- si no tiene materias cursadas en ninguna carrera, devuelvo solamente los datos personales.
   IF vi_retorno = 0 THEN
  --     IF vc_Anio = pObservacion or pObservacion = '0000' then
    
--    RETURN vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_Carrera, vc_CarreraNombre, vc_Legajo, vc_Materia, vc_MateriaNombre, vc_Anio, vc_PerLect, vc_Resultado, vc_Observaciones, 
-- vc_FechaUltima, vd_FinVigencia, vd_Regularidad, vc_CondRegular,vc_AnioReinsc, 'N', vc_Calidad, vc_AnioIngreso, NULL, vcCondRegDesc,           vc_TipoDocDesAbre,
--            vc_NroDocumento, vi_Aprobadas, vi_Reprobadas, vs_PromConApla;  
      RETURN vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_Carrera, vc_CarreraNombre, vc_Legajo, NULL, NULL, ' ', NULL, NULL, vc_Observaciones, 
        vc_FechaUltima, NULL, NULL, NULL,vc_AnioReinsc, 'N', vc_Calidad, vc_AnioIngreso,  NULL, NULL, vc_TipoDocDesAbre,
          vc_NroDocumento, vi_Aprobadas, vi_Reprobadas, vs_PromConApla;  
--       END IF;
   END IF;
   
END;

END PROCEDURE;                                                                                                                                                                                                                                                          

                                                                                                                                                                                                                                                
