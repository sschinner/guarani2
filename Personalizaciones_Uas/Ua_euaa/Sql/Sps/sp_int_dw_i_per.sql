CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_int_dw_i_per') THEN
		DROP PROCEDURE sp_int_dw_i_per;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.2
-- Procedure sp_int_dw_i_per
-- 
-- proceso que recupera la información de ingreso de los alumnos para 
-- el proceso de DatawareHouse.
-- 
-- Recibe: UA, Carrera, Legajo
-- Retorna: Año de Ingreso a la carrera y el periodo de inscripcion
-- ******************************************************************************

-- EXECUTE PROCEDURE sp_int_dw_i_per();
-- DROP PROCEDURE "dba".sp_int_dw_i_per;
CREATE PROCEDURE "dba".sp_int_dw_i_per()

DEFINE vc_UA                   VARCHAR(5);
DEFINE vc_NRO_INSCRIPCION      VARCHAR(10);
DEFINE vi_TIPO_DOCUMENTO       INTEGER;
DEFINE vi_NRO_DOCUMENTO        VARCHAR(15);
DEFINE vc_SEXO                 CHAR(1);
DEFINE vd_FECHA_NAC            DATE; -- para calcular edad al ingreso
DEFINE vi_Nacionalidad         integer;
DEFINE vi_titulo_secundar    INTEGER;
DEFINE vi_anio_egreso_sec      INTEGER;
DEFINE vi_colegio_secunda   INTEGER;
DEFINE vc_orient_voc_rec       VARCHAR(20);

DEFINE vi_car_activo           SMALLINT;
DEFINE vi_car_egresado         SMALLINT;
DEFINE vi_car_aspira           SMALLINT;

DEFINE vi_CNT_READ                     INTEGER;
DEFINE vi_AnioIngreso                  INTEGER;


BEGIN


-------------------------------
-------------------------------
FOREACH

   ---------------------------------
   -- Recupero los datos personales.
   ---------------------------------
   SELECT p.unidad_academica,
          p.nro_inscripcion,
          MAX(tipo_documento),
          MAX(nro_documento),
          MAX(sexo),
          MAX(fecha_nacimiento), 
          MAX(nacionalidad),
          MAX(titulo_secundario),
          MAX(anio_egreso_sec),
          MAX(colegio_original),
          MAX(orient_voc_rec)
     INTO vc_UA,
          vc_NRO_INSCRIPCION,
          vi_TIPO_DOCUMENTO,
          vi_NRO_DOCUMENTO,
          vc_SEXO,
          vd_FECHA_NAC,
          vi_nacionalidad,
          vi_titulo_secundar,
          vi_anio_egreso_sec,
          vi_colegio_secunda,
          vc_orient_voc_rec
     FROM sga_personas p,
	outer(sga_coleg_sec cs), sga_carrera_aspira ca, sga_periodo_insc pi
     WHERE p.colegio_secundario = cs.colegio
     AND p.nro_inscripcion = ca.nro_inscripcion
     AND ca.periodo_inscripcio = pi.periodo_inscripcio
     AND pi.anio_academico >= '2005'
     GROUP BY p.unidad_academica, p.nro_inscripcion

   -----------------------------------------------------------
   -- Recupero las carreras en las que esta activa la persona.
   -----------------------------------------------------------
   LET vi_car_activo = 0;
   SELECT COUNT(*)
     INTO vi_car_activo
     FROM sga_alumnos
    WHERE sga_alumnos.unidad_academica = vc_UA
      AND sga_alumnos.nro_inscripcion = vc_NRO_INSCRIPCION
      AND sga_alumnos.calidad = 'A';
   
   -------------------------------------------------------------
   -- Recupero la cant de carreras en las que egresó la persona.
   -------------------------------------------------------------
   LET vi_car_egresado = 0;
   SELECT COUNT(*)
     INTO vi_car_egresado
     FROM sga_alumnos
    WHERE sga_alumnos.unidad_academica = vc_UA
      AND sga_alumnos.nro_inscripcion = vc_NRO_INSCRIPCION
      AND sga_alumnos.calidad = 'E';
   
   --------------------------------------------------------
   -- Recupero las carreras en las que aspiro a ser alumno.
   --------------------------------------------------------
   LET vi_car_aspira = 0;
   SELECT COUNT(DISTINCT carrera)
     INTO vi_car_aspira
     FROM sga_carrera_aspira,
          sga_personas
    WHERE sga_carrera_aspira.unidad_academica = vc_UA
      AND sga_carrera_aspira.nro_inscripcion = vc_NRO_INSCRIPCION;
   
   ---------------------------------------------------------------------------------------------------------------------------
   -- totalizo los datos en las diferentes carreras (correspondiente a los distintos alumnos q se corresponden con la persona)
   ----------------------------------------------------------------------------------------------------------------------------
   SELECT SUM(CNT_READMISIONES),
          MIN(ANIO_INGRESO)
     INTO vi_CNT_READ,  
          vi_AnioIngreso
     FROM int_dw_alumnos_red
    WHERE unidad_academica = vc_UA
      AND nro_inscripcion  = vc_NRO_INSCRIPCION ;
   
   --------------------------------------------------------
   -- Inserto los registros en la tabla...
   --------------------------------------------------------
   INSERT INTO int_dw_persona_red (UNIDAD_ACADEMICA, NRO_INSCRIPCION,
                                TIPO_DOCUMENTO,NRO_DOCUMENTO,
                                SEXO,FECHA_NACIMIENTO,nacionalidad,
                                titulo_secundario,anio_egreso_sec,
                                colegio_secundario,orient_voc_rec,
                                CARRERAS_ACTIVO,CARRERAS_EGRESADO,CARRERAS_ASPIRA,
                                CNT_READMISIONES,
                                ANIO_INGRESO )
        VALUES ( vc_UA,vc_NRO_INSCRIPCION,
                 vi_TIPO_DOCUMENTO,vi_NRO_DOCUMENTO,
                 vc_SEXO,vd_FECHA_NAC,vi_nacionalidad,
                 vi_titulo_secundar,vi_anio_egreso_sec,
                 vi_colegio_secunda,vc_orient_voc_rec,
                 vi_car_activo,vi_car_egresado,vi_car_aspira,
                 vi_CNT_READ,
                 vi_AnioIngreso );

END FOREACH; 

END;
END PROCEDURE;
-- **************************** sp_int_dw_i_per ****************************
revoke execute on "dba".sp_int_dw_i_per from public;

grant execute on "dba".sp_int_dw_i_per to guarani; -- Rol de usuarios de Gestión
grant execute on "dba".sp_int_dw_i_per to internet; -- Usuario de internet
grant execute on "dba".sp_int_dw_i_per to gerencial_ro; -- Usuario de DWH

