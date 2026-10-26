CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_int_dw_i_alu') THEN
		DROP PROCEDURE sp_int_dw_i_alu;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.2, 2.7.0, 2.9.1
-- Procedure sp_int_dw_i_alu
-- 
-- Proceso que recupera la información de ingreso de los alumnos para  el proceso de DatawareHouse.
-- Los alumnos que no pudo procesar por algun problema los registra en la tabla int_dw_debug
-- Recibe: UA, Carrera, Legajo
-- Retorna: Año de Ingreso a la carrera y el periodo de inscripcion
-- ******************************************************************************

-- EXECUTE PROCEDURE sp_int_dw_i_alu();
-- DROP PROCEDURE "dba".sp_int_dw_i_alu;
CREATE PROCEDURE "dba".sp_int_dw_i_alu()

DEFINE vc_ua                        VARCHAR(5);
DEFINE vc_carrera                   VARCHAR(5);
DEFINE vc_legajo                    VARCHAR(15);
DEFINE vc_nroinscripcion            VARCHAR(10);
DEFINE vc_plan                      VARCHAR(5);
DEFINE vc_regular                   CHAR(1);
DEFINE vi_cnt_readmision          INTEGER;
DEFINE vc_calidad                   CHAR(1);

-- Variables Auxiliares. --se usa!
DEFINE vd_aux_fecha_ingre         DATE;

-- otras cuentas.
DEFINE vi_Anio_Ingreso              SMALLINT;
DEFINE vc_Periodo_Inscrip       VARCHAR(40); -- se agrandó para incluir datos de nivelacion de famaf
DEFINE vi_cant_cambio_pla         INTEGER;
DEFINE vi_cant_aspiracion         INTEGER;
DEFINE vdec_Promedio                DECIMAL(6,2);

-- datos del plan
DEFINE vi_plan_durac_teor     VARCHAR(20);
DEFINE vi_plan_cnt_materi         INTEGER;
DEFINE vi_plan_cnt_optati        INTEGER;
DEFINE vc_plan_estado               CHAR(1);

DEFINE sql_err      integer;
DEFINE isam_err     integer;
DEFINE error_info   varchar(76);

-- Variables Totalizadoras de actividad en la carrera --no por ahora!!!!

BEGIN

-------------------------------
-- Recorro la tabla de alumnos.
-------------------------------
FOREACH
 SELECT distinct a.unidad_academica,
        a.carrera,
        a.legajo,
        a.nro_inscripcion,
        a.plan,
        a.regular,
        a.cnt_readmisiones,
        a.calidad,
        a.fecha_ingreso
   INTO vc_ua,
        vc_carrera,
        vc_legajo,
        vc_nroinscripcion,
        vc_plan,
        vc_regular,
        vi_cnt_readmision,
        vc_calidad,
        vd_aux_fecha_ingre
   FROM sga_alumnos a
   JOIN sga_carrera_aspira ca on a.nro_inscripcion = ca.nro_inscripcion and a.carrera = ca.carrera
   JOIN sga_periodo_insc pi on ca.periodo_inscripcio = pi.periodo_inscripcio
   WHERE pi.anio_academico >= 2005

 BEGIN
   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
      INSERT INTO int_dw_debug (proceso, unidad_academica, carrera, legajo, nro_inscripcion, sql_error, isam_error, error_info)
          VALUES ('sp_int_dw_i_alu',vc_ua, vc_carrera, vc_legajo, vc_nroinscripcion, sql_err, isam_err, error_info);
      CONTINUE FOREACH;
   END EXCEPTION WITH RESUME;
   
   -------------------------------------------
   -- Recupero el año de ingreso a la carrera.
   -------------------------------------------
   EXECUTE PROCEDURE sp_int_dw_dating ( vc_UA, vc_CARRERA, vc_LEGAJO ) INTO vi_Anio_Ingreso, vc_Periodo_Inscrip;
   
   IF vi_Anio_Ingreso = 9999 THEN
      LET vi_Anio_Ingreso = YEAR(vd_aux_fecha_ingre);
      LET vc_Periodo_Inscrip = 'Sin período';
   END IF;
   
   
    -----------------------------------------------------------------
   -- Recupero la cantidad de cambios de planes dentro de la carrera
   -----------------------------------------------------------------
   LET vi_cant_cambio_pla = 0;
   
   SELECT COUNT (DISTINCT plan)
     INTO vi_cant_cambio_pla
     FROM sga_cambios_plan
    WHERE unidad_academica = vc_ua
      AND carrera = vc_carrera
      AND legajo = vc_legajo;
   
   -------------------------------------------------------
   -- Recupero la cantidad de aspiraciones a esa carrera
   -------------------------------------------------------
   LET vi_cant_aspiracion = 0;
   
   SELECT COUNT(*)
     INTO vi_cant_aspiracion			
     FROM sga_carrera_aspira
    WHERE unidad_academica = vc_ua
      AND carrera = vc_carrera
      AND nro_inscripcion = vc_nroinscripcion;
   
   ----------------------------------------------------------------
   -- Calculo el promedio (para todas las materias, aprobadas o no)
   ----------------------------------------------------------------
   EXECUTE PROCEDURE sp_prom_alu_resul ( vc_ua, vc_carrera, vc_legajo, 'S') INTO vdec_Promedio;
   
   -----------------------------------------------------------------
   -- Recupero los datos correspondientes al plan actual del alumno
   -----------------------------------------------------------------
   SELECT duracion_numerica, -- antes decia duracion_numerica, ... existe???
          cnt_materias,
          cnt_optativas,
          estado
     INTO vi_plan_durac_teor,
          vi_plan_cnt_materi,
          vi_plan_cnt_optati,
          vc_plan_estado
     FROM sga_planes
    WHERE unidad_academica=vc_ua
      AND carrera=vc_carrera
      AND plan=vc_plan;
   
      ---------------------------------------------------------
      -- INGRESO LOS REGISTROS EN LA TABLA "int_dw_alumnos_red"  --
      ---------------------------------------------------------

         INSERT INTO int_dw_alumnos_red ( unidad_academica, carrera, legajo, plan, nro_inscripcion,
          regular, cnt_readmisiones, calidad, anio_ingreso, periodo_inscripcio, fecha_ingreso, cant_cambios_plan, cant_aspiraciones,
          promedio, plan_duracion_teor, plan_cnt_materias, plan_cnt_optativas, plan_estado )
         VALUES ( vc_ua, vc_carrera, vc_legajo, vc_plan, vc_nroinscripcion, 
          vc_regular, vi_cnt_readmision, vc_calidad,
          vi_Anio_Ingreso, vc_Periodo_Inscrip, vd_aux_fecha_ingre, vi_cant_cambio_pla, vi_cant_aspiracion, vdec_Promedio, 
          vi_plan_durac_teor, vi_plan_cnt_materi, vi_plan_cnt_optati, vc_plan_estado );

      END;
END FOREACH;

END;
END PROCEDURE;
-- ******************************** sp_int_dw_i_alu ********************************
revoke execute on sp_int_dw_i_alu from public;

grant execute on "dba".sp_int_dw_i_alu to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp_int_dw_i_alu to internet; -- Usuario de internet
grant execute on "dba".sp_int_dw_i_alu to gerencial_ro; -- Usuario de DWH
