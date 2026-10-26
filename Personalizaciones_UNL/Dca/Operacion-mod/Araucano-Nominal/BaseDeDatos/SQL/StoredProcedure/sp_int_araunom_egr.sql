-- *************************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.3
-- Procedure sp_int_araunom_egr
-- Basado en el procedure "sp_int_arau_actegr"
-- 
-- Actualiza la tabla "int_araunom_egres" que contiene a los egresados de los distintos años académicos.
-- Considera como egresado del año académico al alumno que tiene el tramite iniciado
-- ya sea para un titulo de nivel intermedio o final.
-- 
-- Recibe: Año Académico
-- Retorna: Nada. Carga la tabla int_araunomegr
-- *************************************************************************************
 DROP PROCEDURE sp_int_araunom_egr;
CREATE PROCEDURE sp_int_araunom_egr( 
   pAnioAcademico LIKE sga_anio_academico.anio_academico,
   pFechaInicioAnio  varchar(10),
   pFechaFinAnio varchar(10)
 )

-- Variables Internas.
DEFINE ls_Ua              LIKE sga_alumnos.unidad_academica;
DEFINE ls_Carrera         LIKE sga_alumnos.carrera;
DEFINE ls_Legajo          LIKE sga_alumnos.legajo;
DEFINE ls_Titulo          LIKE sga_titulos.titulo;
DEFINE ls_TituloAraucano  LIKE sga_titulos.titulo_araucano;
DEFINE ls_Plan            LIKE sga_planes.plan;
DEFINE ls_Version         LIKE sga_planes.version_actual;
DEFINE ls_Orientacion     LIKE sga_orientaciones.orientacion;
DEFINE vd_FechaIngreso    LIKE sga_alumnos.fecha_ingreso;

DEFINE vd_FechaEgreso     DATE;
DEFINE ld_FechaIni        LIKE sga_anio_academico.fecha_inicio;
DEFINE ld_FechaFin        LIKE sga_anio_academico.fecha_fin;

-- VARIABLES PARA EL MANEJO DE EXCEPCIONES.
DEFINE SQLErr               INTEGER;
DEFINE ISAMError            INTEGER;
DEFINE errorInfo            VARCHAR(76);


-- SI HAY ALGÚN ERROR.
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;


BEGIN
   
   LET ld_FechaIni = to_date(pFechaInicioAnio, '%d/%m/%Y');
   LET ld_FechaFin = to_date(pFechaFinAnio, '%d/%m/%Y');
   
   -- Borro egresados de la tabla
   DELETE FROM int_araunom_egres WHERE anio_academico = pAnioAcademico;

   -- Ingreso los Egresados que iniciaron el tramite entre las fechas del año.
   INSERT INTO int_araunom_egres ( anio_academico, unidad_academica, carrera, legajo, titulo, titulo_araucano, fecha_egreso, solicito_titulo)
        SELECT pAnioAcademico,
               sga_titulos_otorg.unidad_academica,
               sga_titulos_otorg.carrera,
               sga_titulos_otorg.legajo,
               sga_titulos.titulo,
               sga_titulos.titulo_araucano,
               sga_titulos_otorg.fecha_egreso,
               'S'
          FROM sga_titulos_otorg,
               sga_titulos
         WHERE sga_titulos_otorg.fecha_egreso BETWEEN ld_FechaIni AND ld_FechaFin
           AND sga_titulos_otorg.titulo = sga_titulos.titulo
           AND sga_titulos.titulo_araucano IS NOT NULL;
           -- AND sga_titulos_otorg.carrera NOT IN (SELECT carrera_ciclocomun FROM int_arau_car_cc);
   
   -- Ingreso los Egresados que NO iniciaron el tramite entre las fechas del año.
   FOREACH
    SELECT sga_alumnos.unidad_academica,
           sga_alumnos.carrera,
           sga_alumnos.legajo,
           sga_alumnos.fecha_ingreso,
           sga_titulos_plan.titulo,
           sga_titulos.titulo_araucano
      INTO ls_Ua, ls_Carrera, ls_Legajo, vd_FechaIngreso, ls_Titulo, ls_TituloAraucano
      FROM sga_alumnos,
           sga_titulos_plan,
           sga_titulos
     WHERE sga_alumnos.calidad IN ('A','P','N')
       AND sga_alumnos.fecha_ingreso < ld_FechaFin
       AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
       AND sga_titulos_plan.carrera = sga_alumnos.carrera
       AND sga_titulos_plan.plan = sga_alumnos.plan
       AND sga_titulos.unidad_academica = sga_titulos_plan.unidad_academica
       AND sga_titulos.titulo = sga_titulos_plan.titulo
       AND sga_titulos.titulo_araucano IS NOT NULL
       AND NOT EXISTS ( SELECT 1 FROM sga_titulos_otorg
                         WHERE unidad_academica = sga_alumnos.unidad_academica
                           AND nro_inscripcion = sga_alumnos.nro_inscripcion
                           AND titulo =  sga_titulos_plan.titulo 
						   -- AND fecha_egreso BETWEEN ld_FechaIni AND ld_FechaFin
					   )
       -- AND sga_alumnos.carrera NOT IN (SELECT carrera_ciclocomun FROM int_arau_car_cc)
     ORDER BY sga_alumnos.unidad_academica, sga_alumnos.carrera
      
      BEGIN
         ON EXCEPTION SET sqlerr, isamerror, errorinfo
            -- error
            -- Se agrego esta excepcion para que continue si encontro algun problema!!!	
            -- Poruqe si da error el titulo por orientacion no seleccionada, devuelve un -746	
         END EXCEPTION WITH RESUME;   
         
         -- FOREACH EXECUTE PROCEDURE sp_titulo_aprobado(ls_Ua, ls_Carrera, ls_Legajo, ls_Titulo ) INTO ls_Orientacion, ls_Plan, ls_Version 
         FOREACH EXECUTE PROCEDURE sp_titulo_aprobfec(ls_Ua, ls_Carrera, ls_Legajo, ls_Titulo, pFechaFinAnio ) INTO ls_Orientacion, ls_Plan, ls_Version 
            
            -- Verifico la fecha de Egreso si se encuentra entre la del año academico.
            EXECUTE PROCEDURE sp_fecha_egreso ( ls_Ua, ls_Carrera, ls_Legajo, ls_Titulo, ls_Plan, ls_Version, ls_Orientacion ) INTO vd_FechaEgreso;
            IF (vd_FechaEgreso <= ld_FechaFin ) AND (vd_FechaEgreso >= ld_FechaIni ) THEN
               
               -- Verifico que ya no se haya ingresado ese titulo, ya que pudo haber egresado por mas de una orientación.
               IF ( SELECT COUNT(*)
                      FROM int_araunom_egres 
                     WHERE anio_academico   = pAnioAcademico
                       AND unidad_academica = ls_UA
                       AND carrera          = ls_Carrera
                       AND legajo           = ls_Legajo
                       AND titulo_araucano  = ls_TituloAraucano ) = 0 THEN
                  
                  INSERT INTO int_araunom_egres (anio_academico, unidad_academica, carrera, legajo, titulo, titulo_araucano, fecha_egreso, solicito_titulo)
                       VALUES ( pAnioAcademico, ls_UA, ls_Carrera, ls_Legajo, ls_titulo, ls_TituloAraucano, vd_FechaEgreso, 'N' );
               END IF;
            END IF;
            
         END FOREACH;  -- titulo aprobado (orientaciones)
      END;
   END FOREACH; -- Alumnos
   
END;
END PROCEDURE;
-- ************************** fin procedure sp_int_araunom_egr **************************

GRANT EXECUTE ON sp_int_araunom_egr TO public;