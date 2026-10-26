-- *************************************************************************************
-- Verifico que se haya corrido script anterior
EXECUTE PROCEDURE sp_soy_dba();
-- EXECUTE PROCEDURE sp_validar_scripts('CNV2.09.4', 11);
EXECUTE PROCEDURE sp_validar_scripts('UNL2.09.4.1', 3);
--
-- *************************************************************************************

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.5
-- Tabla sga_titulos_resol
-- Registra las resoluciones ministeriales y coneau de los titulos x plan de estudios.
-- *******************************************************************************
-- DROP TABLE sga_titulos_resol;
CREATE TABLE sga_titulos_resol (
       titulo_resolucion    SERIAL(1) NOT NULL,
       unidad_academica     varchar(5) NOT NULL,
       carrera              varchar(5) NOT NULL,
       plan                 varchar(5) NOT NULL,
       titulo               varchar(5) NOT NULL,
	   tipo_resolucion      char(1) NOT NULL,
       nro_resolucion       varchar(100) NOT NULL, 
	   fecha_ent_vigencia   DATE NOT NULL 
);


ALTER TABLE sga_titulos_resol
       ADD CONSTRAINT PRIMARY KEY (titulo_resolucion) CONSTRAINT pk_titulos_resol;

revoke all on sga_titulos_resol from public;
-- *********** Fin del script de la tabla sga_titulos_resol **********

-- *******************************************************************************
-- Tabla de Auditoria log_titulos_resol
-- *******************************************************************************
-- DROP TABLE log_titulos_resol;
CREATE TABLE log_titulos_resol (
          logid SERIAL(1),
		  titulo_resolucion integer,
          unidad_academica varchar(5),
          carrera varchar(5),
          plan varchar(5),
          titulo varchar(5),
		  tipo_resolucion char(1),
          nro_resolucion varchar(100), 
		  fecha_ent_vigencia date,
		  usuario varchar(8) DEFAULT USER NOT NULL,
          fecha_act  DATETIME YEAR TO SECOND DEFAULT CURRENT YEAR TO SECOND  NOT NULL,
          oper CHAR(1) NOT NULL
);

ALTER TABLE log_titulos_resol
      ADD CONSTRAINT PRIMARY KEY ( logid );

revoke all on log_titulos_resol from public;
-- *********** Fin de tabla de auditoria de sga_titulos_resol ***********


GRANT ALL ON sga_titulos_resol TO public;


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.5
-- Ultima version de modificacion:
-- Tabla sga_titulos_resol
-- Procedure spu_titulos_resol (asociado al trigger de UPDATE)
-- *******************************************************************************
-- DROP PROCEDURE spu_titulos_resol ;
CREATE PROCEDURE spu_titulos_resol (
       o_titulo_resolucion like sga_titulos_resol.titulo_resolucion,
       o_unidad_academica like sga_titulos_resol.unidad_academica,
       o_carrera like sga_titulos_resol.carrera,
       o_plan like sga_titulos_resol.plan,
       o_titulo like sga_titulos_resol.titulo,
       o_tipo_resolucion like sga_titulos_resol.tipo_resolucion,
       o_nro_resolucion like sga_titulos_resol.nro_resolucion,
       o_fecha_ent_vigencia like sga_titulos_resol.fecha_ent_vigencia,
       n_titulo_resolucion like sga_titulos_resol.titulo_resolucion,
       n_unidad_academica like sga_titulos_resol.unidad_academica,
       n_carrera like sga_titulos_resol.carrera,
       n_plan like sga_titulos_resol.plan,
       n_titulo like sga_titulos_resol.titulo,
       n_tipo_resolucion like sga_titulos_resol.tipo_resolucion,
       n_nro_resolucion like sga_titulos_resol.nro_resolucion,
       n_fecha_ent_vigencia like sga_titulos_resol.fecha_ent_vigencia)
BEGIN

   -- Carga la tabla de log para auditoria
   INSERT INTO log_titulos_resol (
     titulo_resolucion,
     unidad_academica,
     carrera,
     plan,
     titulo,
     tipo_resolucion,
     nro_resolucion,
     fecha_ent_vigencia,
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_titulo_resolucion,
     n_unidad_academica,
     n_carrera,
     n_plan,
     n_titulo,
     n_tipo_resolucion,
     n_nro_resolucion,
     n_fecha_ent_vigencia,
     User,
     Current year to Second,
     'U');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de UPDATE de sga_titulos_resol **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.04.0
-- Tabla sga_titulos_resol
-- Trigger de Update tu_titulos_resol
-- *******************************************************************************
-- DROP TRIGGER tu_titulos_resol ;
CREATE TRIGGER tu_titulos_resol UPDATE on sga_titulos_resol
referencing old as old new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spu_titulos_resol (
     old.titulo_resolucion,
     old.unidad_academica,
     old.carrera,
     old.plan,
     old.titulo,
     old.tipo_resolucion,
     old.nro_resolucion,
     old.fecha_ent_vigencia,
     new.titulo_resolucion,
     new.unidad_academica,
     new.carrera,
     new.plan,
     new.titulo,
     new.tipo_resolucion,
     new.nro_resolucion,
     new.fecha_ent_vigencia
	 )

);
-- ********** Fin del trigger de Update tu_titulos_resol **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.5
-- Tabla sga_titulos_resol
-- Procedure spi_titulos_resol (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE spi_titulos_resol ;
CREATE PROCEDURE spi_titulos_resol (
       n_titulo_resolucion like sga_titulos_resol.titulo_resolucion,
       n_unidad_academica like sga_titulos_resol.unidad_academica,
       n_carrera like sga_titulos_resol.carrera,
       n_plan like sga_titulos_resol.plan,
       n_titulo like sga_titulos_resol.titulo,
       n_tipo_resolucion like sga_titulos_resol.tipo_resolucion,
       n_nro_resolucion like sga_titulos_resol.nro_resolucion,
       n_fecha_ent_vigencia like sga_titulos_resol.fecha_ent_vigencia)
BEGIN


   -- Carga la tabla de log para auditoria
   INSERT INTO log_titulos_resol (
     titulo_resolucion,
     unidad_academica,
     carrera,
     plan,
     titulo,
     tipo_resolucion,
     nro_resolucion,
     fecha_ent_vigencia,
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_titulo_resolucion,
     n_unidad_academica,
     n_carrera,
     n_plan,
     n_titulo,
     n_tipo_resolucion,
     n_nro_resolucion,
     n_fecha_ent_vigencia,
     User,
     Current year to Second,
     'I');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de INSERT de sga_titulos_resol **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.5
-- Tabla sga_titulos_resol
-- Trigger de Insert ti_titulos_resol
-- *******************************************************************************
-- DROP TRIGGER ti_titulos_resol ;
CREATE TRIGGER ti_titulos_resol INSERT on sga_titulos_resol
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_titulos_resol (
     new.titulo_resolucion,
     new.unidad_academica,
     new.carrera,
     new.plan,
     new.titulo,
     new.tipo_resolucion,
     new.nro_resolucion,
     new.fecha_ent_vigencia) 	 
);
-- ********** Fin del trigger de Insert ti_titulos_resol **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.9.5
-- Tabla sga_titulos_resol
-- Procedure spd_titulos_resol (asociado al trigger de DELETE)
-- *******************************************************************************
-- DROP PROCEDURE spd_titulos_resol ;
CREATE PROCEDURE spd_titulos_resol (
       o_titulo_resolucion like sga_titulos_resol.titulo_resolucion,
       o_unidad_academica like sga_titulos_resol.unidad_academica,
       o_carrera like sga_titulos_resol.carrera,
       o_plan like sga_titulos_resol.plan,
       o_titulo like sga_titulos_resol.titulo,
       o_tipo_resolucion like sga_titulos_resol.tipo_resolucion,
       o_nro_resolucion like sga_titulos_resol.nro_resolucion,
       o_fecha_ent_vigencia like sga_titulos_resol.fecha_ent_vigencia)
BEGIN

   -- Carga la tabla de log para auditoria
   INSERT INTO log_titulos_resol (
     titulo_resolucion,
     unidad_academica,
     carrera,
     plan,
     titulo,
     tipo_resolucion,
     nro_resolucion,
     fecha_ent_vigencia,
     usuario,
     fecha_act,
     oper)
   VALUES (
     o_titulo_resolucion,
     o_unidad_academica,
     o_carrera,
     o_plan,
     o_titulo,
     o_tipo_resolucion,
     o_nro_resolucion,
     o_fecha_ent_vigencia,
     User,
     Current year to Second,
     'D');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de DELETE de sga_titulos_resol **********


-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.04.0
-- Tabla sga_titulos_resol
-- Trigger de Delete td_titulos_resol
-- *******************************************************************************
-- DROP TRIGGER td_titulos_resol ;
CREATE TRIGGER td_titulos_resol DELETE on sga_titulos_resol
referencing old as old
FOR EACH ROW (
   EXECUTE PROCEDURE spd_titulos_resol (
     old.titulo_resolucion,
     old.unidad_academica,
     old.carrera,
     old.plan,
     old.titulo,
     old.tipo_resolucion,
     old.nro_resolucion,
     old.fecha_ent_vigencia
     ) 	 
);
-- ********** Fin del trigger de Delete td_titulos_resol **********

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Tabla: sga_titulos_resol
-- Campo: tipo_resolucion
-- Valores: M = Resolución Ministerial / C = Resolución de CONEAU / N = Normativa de la institucion.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ALTER TABLE sga_titulos_resol
       ADD CONSTRAINT CHECK (tipo_resolucion IN ('M', 'C', 'N'))
       CONSTRAINT ck_titulos_resol_tipo;
	   

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Tabla sga_personas
-- Se agregan campos relacionados con el titulo secundario y la situacion de convalidacion y nro de resolucion
-- para el caso de titulos de instituciones extranjeras
-- tit_sec_sit_conv: 1 = Convalidado 2 = Revalidado 3 = No Revalidado-Convalidado 4 = Reconocimiento 5 = Convalidación provisoria 
-- tit_sec_nro_resol = Nro de resolucion de convalidacion o revalidacion de titulos secundarios extranjeros.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   
ALTER TABLE sga_personas ADD tit_sec_sit_conv integer;
ALTER TABLE sga_personas ADD tit_sec_nro_resol varchar(100);

ALTER TABLE log_personas ADD tit_sec_sit_conv integer;
ALTER TABLE log_personas ADD tit_sec_nro_resol varchar(100);	   


DROP PROCEDURE spd_personas ;
DROP PROCEDURE spi_personas ;
DROP PROCEDURE spu_personas ;

DROP TRIGGER td_personas ;
DROP TRIGGER ti_personas ;
DROP TRIGGER tu_personas ;

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.0, 2.08.0, 2.09.0,  2.9.5
-- Tabla sga_personas
-- Procedure spd_personas (asociado al trigger de DELETE)
-- *******************************************************************************
-- DROP PROCEDURE spd_personas ;
CREATE PROCEDURE spd_personas (
       o_unidad_academica like sga_personas.unidad_academica,
       o_nro_inscripcion like sga_personas.nro_inscripcion,
       o_fecha_inscripcio like sga_personas.fecha_inscripcion,
       o_apellido like sga_personas.apellido,
       o_nombres like sga_personas.nombres,
       o_pais_documento like sga_personas.pais_documento,
       o_tipo_documento like sga_personas.tipo_documento,
       o_nro_documento like sga_personas.nro_documento,
       o_numero_cuil like sga_personas.numero_cuil,
       o_sexo like sga_personas.sexo,
       o_fecha_nacimiento like sga_personas.fecha_nacimiento,
       o_nacionalidad like sga_personas.nacionalidad,
       o_loc_nacimiento like sga_personas.loc_nacimiento,
       o_colegio_secundar like sga_personas.colegio_secundario,
       o_titulo_secundari like sga_personas.titulo_secundario,
       o_anio_egreso_sec like sga_personas.anio_egreso_sec,
       o_orient_voc_rec like sga_personas.orient_voc_rec,
       o_ent_emisora_ci like sga_personas.ent_emisora_ci,
       o_nro_ci like sga_personas.nro_ci,
       o_pais_emisor_pasa like sga_personas.pais_emisor_pasap,
       o_nro_pasap like sga_personas.nro_pasap,
       o_grupo_sanguineo like sga_personas.grupo_sanguineo,
       o_factor_sanguineo like sga_personas.factor_sanguineo,
       o_alta_serv_milita like sga_personas.alta_serv_militar,
       o_baja_serv_milita like sga_personas.baja_serv_militar,
       o_apellido_padre like sga_personas.apellido_padre,
       o_nombres_padre like sga_personas.nombres_padre,
       o_apellido_madre like sga_personas.apellido_madre,
       o_nombres_madre like sga_personas.nombres_madre,
       o_aborigen like sga_personas.aborigen,
       o_fecha_ingreso_pa like sga_personas.fecha_ingreso_pais,
       o_fecha_dni_otorg like sga_personas.fecha_dni_otorg,
       o_fecha_dni_venc like sga_personas.fecha_dni_venc,
       o_fecha_respre_oto like sga_personas.fecha_respre_otorg,
       o_fecha_respre_ven like sga_personas.fecha_respre_venc,
       o_residencia like sga_personas.residencia,
       o_apellido_elegido like sga_personas.apellido_elegido,
       o_nombre_elegido like sga_personas.nombre_elegido,
       o_vive like sga_personas.vive,
       o_id_imagen like sga_personas.id_imagen,
	   o_tit_sec_sit_conv like sga_personas.tit_sec_sit_conv,
	   o_tit_sec_nro_resol like sga_personas.tit_sec_nro_resol)
BEGIN

   -- No se puede borrar de sga_personas si existe en u806f_req_cump
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_personas si existe en u806f_carrera_asp
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_personas si existe en sga_tesis_tutores
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_personas si existe en gde_encues_rpta
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_personas si existe en gde_encues_persona
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_personas si existe en gda_anun_conf_pers
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_personas si existe en gda_anuncios_log
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_personas si existe en sga_personas_foto
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_personas si existe en mco_cpt_matricula
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_personas si existe en sga_encuesta_egre
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_personas si existe en aca_usuarios_ag
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_personas si existe en sga_docentes
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_personas si existe en sga_certif_pedidos
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede borrar de sga_personas si existe en sga_titulos_otorg
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT


   IF EXISTS (SELECT '' 
                FROM sga_alumnos		
               WHERE sga_alumnos.unidad_academica = O_UNIDAD_ACADEMICA
                 AND sga_alumnos.nro_inscripcion = O_NRO_INSCRIPCION) THEN
       -- Error
       raise exception -746,0,'No se puede dar de baja la persona porque es Alumno.';
   END IF;

   -- Solo permito dar de baja a la persona si la situacion es: 'AC', 'RF'
   IF (SELECT COUNT(*)   FROM sga_carrera_aspira
               WHERE sga_carrera_aspira.unidad_academica = O_UNIDAD_ACADEMICA
                  AND sga_carrera_aspira.nro_inscripcion  = O_NRO_INSCRIPCION
	  AND sga_carrera_aspira.situacion_asp NOT IN ('AC','RF') ) > 0  THEN

	-- Permito borrar la persona:
	-- RF	Aspirante no aceptado en el período de inscripción.
	-- AC	Aspirante a carrera.	

	-- No permito si esta en esta situacion:
	-- RR	Alumno Rechazado en el período Insc. al no cumplir req. Oblig.
	-- RC	Alumno Rechazado por Cambio de Carrera.
	-- RA	Alumno Rechazado por Abandono de Carrera.
	-- IL	Alumno con legajo ya generado en la carrera.	
	-- IC	Alumno Condicional al no cumplir todos los requisitos Oblig.	

	raise exception -746,0,'No se puede dar de baja la persona porque tiene inscripción a carreras.';
   END IF;

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_hist_req_cump (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_hist_req_cump
    WHERE sga_hist_req_cump.unidad_academica = o_unidad_academica
      AND sga_hist_req_cump.nro_inscripcion = o_nro_inscripcion;

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_req_cumplidos (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_req_cumplidos
    WHERE sga_req_cumplidos.unidad_academica = o_unidad_academica
      AND sga_req_cumplidos.nro_inscripcion = o_nro_inscripcion;

   -- No se puede borrar de sga_personas si existe en sga_alumnos
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_carrera_aspira (PARENT DELETE CASCADE)
   -- *****  ESTA ANTES QUE LA TABLA DE MOVIMIENTOS, PORQUE LA BAJA DE INSCRIPCION ********
   -- *****  A UNA CARRERA INSERTA UN REGISTRO EN LA TABLA SGA_MOVIMIENTOS         ********
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_carrera_aspira
    WHERE sga_carrera_aspira.unidad_academica = o_unidad_academica
      AND sga_carrera_aspira.nro_inscripcion = o_nro_inscripcion;

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_movimientos (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_movimientos
    WHERE sga_movimientos.unidad_academica = o_unidad_academica
      AND sga_movimientos.nro_inscripcion = o_nro_inscripcion;

   -- No se puede borrar de sga_personas si existe en sga_sancion_pers
   -- (PARENT DELETE RESTRICT) Este control lo lleva el CONSTRAINT

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_sancion_pers (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_sancion_pers
    WHERE sga_sancion_pers.unidad_academica = o_unidad_academica
      AND sga_sancion_pers.nro_inscripcion = o_nro_inscripcion;

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_datos_censales (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_datos_censales
    WHERE sga_datos_censales.unidad_academica = o_unidad_academica
      AND sga_datos_censales.nro_inscripcion = o_nro_inscripcion;

   -------------------------------------------------------------------------------- 
   -- Datos de salud
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_datos_salud
    WHERE unidad_academica = o_unidad_academica
      AND nro_inscripcion = o_nro_inscripcion;

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_turnos_insc (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_turnos_insc
    WHERE sga_turnos_insc.unidad_academica = o_unidad_academica
      AND sga_turnos_insc.nro_inscripcion = o_nro_inscripcion;

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla aca_usuarios_ag (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM gda_anun_conf_pers
    WHERE unidad_academica = o_unidad_academica AND
          nro_inscripcion = o_nro_inscripcion ;

   DELETE FROM aca_tipos_usuar_ag
    WHERE unidad_academica = o_unidad_academica AND
          nro_inscripcion = o_nro_inscripcion ;

   DELETE FROM aca_usuarios_ag
    WHERE unidad_academica = o_unidad_academica AND
          nro_inscripcion = o_nro_inscripcion ;


   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_actuacion_prof (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_actuacion_prof
    WHERE unidad_academica = o_unidad_academica AND
          nro_inscripcion = o_nro_inscripcion ;

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_actuacion_doc (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_actuacion_doc
    WHERE unidad_academica = o_unidad_academica AND
          nro_inscripcion = o_nro_inscripcion ;


   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_formacion_acad (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_formacion_acad
    WHERE unidad_academica = o_unidad_academica AND
          nro_inscripcion = o_nro_inscripcion ;

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_personas_doc (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_personas_doc
    WHERE unidad_academica = o_unidad_academica AND
          nro_inscripcion = o_nro_inscripcion ;

   -- Fotos de la persona
   DELETE FROM sga_personas_foto
    WHERE unidad_academica = o_unidad_academica AND
          nro_inscripcion = o_nro_inscripcion ;

   -------------------------------------------------------------------------------- 
   -- Datos de Acceso
   -------------------------------------------------------------------------------- 
   DELETE FROM aca_usuarios_token
    WHERE unidad_academica = o_unidad_academica AND
          nro_inscripcion = o_nro_inscripcion ;

   DELETE FROM acc_login_externos
    WHERE unidad_academica = o_unidad_academica AND
          nro_inscripcion = o_nro_inscripcion ;

   -- Carga la tabla de log para auditoria
   INSERT INTO log_personas (
     unidad_academica,
     nro_inscripcion,
     fecha_inscripcion,
     apellido,
     nombres,
     pais_documento,
     tipo_documento,
     nro_documento,
     numero_cuil,
     sexo,
     fecha_nacimiento,
     nacionalidad,
     loc_nacimiento,
     colegio_secundario,
     titulo_secundario,
     anio_egreso_sec,
     orient_voc_rec,
     ent_emisora_ci,
     nro_ci,
     pais_emisor_pasap,
     nro_pasap,
     grupo_sanguineo,
     factor_sanguineo,
     alta_serv_militar,
     baja_serv_militar,
     apellido_padre,
     nombres_padre,
     apellido_madre,
     nombres_madre,
     aborigen,
     fecha_ingreso_pais,
     fecha_dni_otorg,
     fecha_dni_venc,
     fecha_respre_otorg,
     fecha_respre_venc,
     residencia,
     apellido_elegido,
     nombre_elegido,
     vive,
     id_imagen,
     tit_sec_sit_conv,
     tit_sec_nro_resol,
     usuario,
     fecha_act,
     oper)
   VALUES (
     o_unidad_academica,
     o_nro_inscripcion,
     o_fecha_inscripcio,
     o_apellido,
     o_nombres,
     o_pais_documento,
     o_tipo_documento,
     o_nro_documento,
     o_numero_cuil,
     o_sexo,
     o_fecha_nacimiento,
     o_nacionalidad,
     o_loc_nacimiento,
     o_colegio_secundar,
     o_titulo_secundari,
     o_anio_egreso_sec,
     o_orient_voc_rec,
     o_ent_emisora_ci,
     o_nro_ci,
     o_pais_emisor_pasa,
     o_nro_pasap,
     o_grupo_sanguineo,
     o_factor_sanguineo,
     o_alta_serv_milita,
     o_baja_serv_milita,
     o_apellido_padre,
     o_nombres_padre,
     o_apellido_madre,
     o_nombres_madre,
     o_aborigen,
     o_fecha_ingreso_pa,
     o_fecha_dni_otorg,
     o_fecha_dni_venc,
     o_fecha_respre_oto,
     o_fecha_respre_ven,
     o_residencia,
     o_apellido_elegido,
     o_nombre_elegido,
     o_vive,
     o_id_imagen,
     o_tit_sec_sit_conv,
     o_tit_sec_nro_resol,
     User,
     Current year to Second,
     'D');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de DELETE de sga_personas **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_personas
-- Procedure personalizado uad_personas (asociado al trigger de DELETE)
-- *******************************************************************************
-- DROP PROCEDURE uad_personas ;
-- CREATE PROCEDURE uad_personas (
--        o_unidad_academica like sga_personas.unidad_academica,
--        o_nro_inscripcion like sga_personas.nro_inscripcion,
--        o_fecha_inscripcio like sga_personas.fecha_inscripcion,
--        o_apellido like sga_personas.apellido,
--        o_nombres like sga_personas.nombres,
--        o_pais_documento like sga_personas.pais_documento,
--        o_tipo_documento like sga_personas.tipo_documento,
--        o_nro_documento like sga_personas.nro_documento,
--        o_numero_cuil like sga_personas.numero_cuil,
--        o_sexo like sga_personas.sexo,
--        o_fecha_nacimiento like sga_personas.fecha_nacimiento,
--        o_nacionalidad like sga_personas.nacionalidad,
--        o_loc_nacimiento like sga_personas.loc_nacimiento,
--        o_colegio_secundar like sga_personas.colegio_secundario,
--        o_titulo_secundari like sga_personas.titulo_secundario,
--        o_anio_egreso_sec like sga_personas.anio_egreso_sec,
--        o_orient_voc_rec like sga_personas.orient_voc_rec,
--        o_ent_emisora_ci like sga_personas.ent_emisora_ci,
--        o_nro_ci like sga_personas.nro_ci,
--        o_pais_emisor_pasa like sga_personas.pais_emisor_pasap,
--        o_nro_pasap like sga_personas.nro_pasap,
--        o_grupo_sanguineo like sga_personas.grupo_sanguineo,
--        o_factor_sanguineo like sga_personas.factor_sanguineo,
--        o_alta_serv_milita like sga_personas.alta_serv_militar,
--        o_baja_serv_milita like sga_personas.baja_serv_militar,
--        o_apellido_padre like sga_personas.apellido_padre,
--        o_nombres_padre like sga_personas.nombres_padre,
--        o_apellido_madre like sga_personas.apellido_madre,
--        o_nombres_madre like sga_personas.nombres_madre,
--        o_aborigen like sga_personas.aborigen,
--        o_fecha_ingreso_pa like sga_personas.fecha_ingreso_pais,
--        o_fecha_dni_otorg like sga_personas.fecha_dni_otorg,
--        o_fecha_dni_venc like sga_personas.fecha_dni_venc,
--        o_fecha_respre_oto like sga_personas.fecha_respre_otorg,
--        o_fecha_respre_ven like sga_personas.fecha_respre_venc,
--        o_residencia like sga_personas.residencia,
--        o_apellido_elegido like sga_personas.apellido_elegido,
--        o_nombre_elegido like sga_personas.nombre_elegido,
--        o_vive like sga_personas.vive,
--        o_id_imagen like sga_personas.id_imagen)
-- BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
-- END;
-- END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de DELETE de sga_personas ****
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.0, 2.08.0
-- Tabla sga_personas
-- Trigger de Delete td_personas
-- *******************************************************************************
-- DROP TRIGGER td_personas ;
CREATE TRIGGER td_personas DELETE on sga_personas
referencing old as old
FOR EACH ROW (
   EXECUTE PROCEDURE spd_personas (
     old.unidad_academica,
     old.nro_inscripcion,
     old.fecha_inscripcion,
     old.apellido,
     old.nombres,
     old.pais_documento,
     old.tipo_documento,
     old.nro_documento,
     old.numero_cuil,
     old.sexo,
     old.fecha_nacimiento,
     old.nacionalidad,
     old.loc_nacimiento,
     old.colegio_secundario,
     old.titulo_secundario,
     old.anio_egreso_sec,
     old.orient_voc_rec,
     old.ent_emisora_ci,
     old.nro_ci,
     old.pais_emisor_pasap,
     old.nro_pasap,
     old.grupo_sanguineo,
     old.factor_sanguineo,
     old.alta_serv_militar,
     old.baja_serv_militar,
     old.apellido_padre,
     old.nombres_padre,
     old.apellido_madre,
     old.nombres_madre,
     old.aborigen,
     old.fecha_ingreso_pais,
     old.fecha_dni_otorg,
     old.fecha_dni_venc,
     old.fecha_respre_otorg,
     old.fecha_respre_venc,
     old.residencia,
     old.apellido_elegido,
     old.nombre_elegido,
     old.vive,
     old.id_imagen,
     old.tit_sec_sit_conv,
     old.tit_sec_nro_resol)
--,

--   EXECUTE PROCEDURE uad_personas (
--     old.unidad_academica,
--     old.nro_inscripcion,
--     old.fecha_inscripcion,
--     old.apellido,
--     old.nombres,
--     old.pais_documento,
--     old.tipo_documento,
--     old.nro_documento,
--     old.numero_cuil,
--     old.sexo,
--     old.fecha_nacimiento,
--     old.nacionalidad,
--     old.loc_nacimiento,
--     old.colegio_secundario,
--     old.titulo_secundario,
--     old.anio_egreso_sec,
--     old.orient_voc_rec,
--     old.ent_emisora_ci,
--     old.nro_ci,
--     old.pais_emisor_pasap,
--     old.nro_pasap,
--     old.grupo_sanguineo,
--     old.factor_sanguineo,
--     old.alta_serv_militar,
--     old.baja_serv_militar,
--     old.apellido_padre,
--     old.nombres_padre,
--     old.apellido_madre,
--     old.nombres_madre,
--     old.aborigen,
--     old.fecha_ingreso_pais,
--     old.fecha_dni_otorg,
--     old.fecha_dni_venc,
--     old.fecha_respre_otorg,
--     old.fecha_respre_venc,
--     old.residencia,
--     old.apellido_elegido,
--     old.nombre_elegido,
--     old.vive,
--     old.id_imagen)
);
-- ********** Fin del trigger de Delete td_personas **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.0, 2.08.0,  2.9.5
-- Tabla sga_personas
-- Procedure spu_personas (asociado al trigger de UPDATE)
-- *******************************************************************************
-- DROP PROCEDURE spu_personas ;
CREATE PROCEDURE spu_personas (
       o_unidad_academica like sga_personas.unidad_academica,
       o_nro_inscripcion like sga_personas.nro_inscripcion,
       o_fecha_inscripcio like sga_personas.fecha_inscripcion,
       o_apellido like sga_personas.apellido,
       o_nombres like sga_personas.nombres,
       o_pais_documento like sga_personas.pais_documento,
       o_tipo_documento like sga_personas.tipo_documento,
       o_nro_documento like sga_personas.nro_documento,
       o_numero_cuil like sga_personas.numero_cuil,
       o_sexo like sga_personas.sexo,
       o_fecha_nacimiento like sga_personas.fecha_nacimiento,
       o_nacionalidad like sga_personas.nacionalidad,
       o_loc_nacimiento like sga_personas.loc_nacimiento,
       o_colegio_secundar like sga_personas.colegio_secundario,
       o_titulo_secundari like sga_personas.titulo_secundario,
       o_anio_egreso_sec like sga_personas.anio_egreso_sec,
       o_orient_voc_rec like sga_personas.orient_voc_rec,
       o_ent_emisora_ci like sga_personas.ent_emisora_ci,
       o_nro_ci like sga_personas.nro_ci,
       o_pais_emisor_pasa like sga_personas.pais_emisor_pasap,
       o_nro_pasap like sga_personas.nro_pasap,
       o_grupo_sanguineo like sga_personas.grupo_sanguineo,
       o_factor_sanguineo like sga_personas.factor_sanguineo,
       o_alta_serv_milita like sga_personas.alta_serv_militar,
       o_baja_serv_milita like sga_personas.baja_serv_militar,
       o_apellido_padre like sga_personas.apellido_padre,
       o_nombres_padre like sga_personas.nombres_padre,
       o_apellido_madre like sga_personas.apellido_madre,
       o_nombres_madre like sga_personas.nombres_madre,
       o_aborigen like sga_personas.aborigen,
       o_fecha_ingreso_pa like sga_personas.fecha_ingreso_pais,
       o_fecha_dni_otorg like sga_personas.fecha_dni_otorg,
       o_fecha_dni_venc like sga_personas.fecha_dni_venc,
       o_fecha_respre_oto like sga_personas.fecha_respre_otorg,
       o_fecha_respre_ven like sga_personas.fecha_respre_venc,
       o_residencia like sga_personas.residencia,
       o_apellido_elegido like sga_personas.apellido_elegido,
       o_nombre_elegido like sga_personas.nombre_elegido,
       o_vive like sga_personas.vive,
       o_id_imagen like sga_personas.id_imagen,
	   o_tit_sec_sit_conv like sga_personas.tit_sec_sit_conv,
	   o_tit_sec_nro_resol like sga_personas.tit_sec_nro_resol,
       n_unidad_academica like sga_personas.unidad_academica,
       n_nro_inscripcion like sga_personas.nro_inscripcion,
       n_fecha_inscripcio like sga_personas.fecha_inscripcion,
       n_apellido like sga_personas.apellido,
       n_nombres like sga_personas.nombres,
       n_pais_documento like sga_personas.pais_documento,
       n_tipo_documento like sga_personas.tipo_documento,
       n_nro_documento like sga_personas.nro_documento,
       n_numero_cuil like sga_personas.numero_cuil,
       n_sexo like sga_personas.sexo,
       n_fecha_nacimiento like sga_personas.fecha_nacimiento,
       n_nacionalidad like sga_personas.nacionalidad,
       n_loc_nacimiento like sga_personas.loc_nacimiento,
       n_colegio_secundar like sga_personas.colegio_secundario,
       n_titulo_secundari like sga_personas.titulo_secundario,
       n_anio_egreso_sec like sga_personas.anio_egreso_sec,
       n_orient_voc_rec like sga_personas.orient_voc_rec,
       n_ent_emisora_ci like sga_personas.ent_emisora_ci,
       n_nro_ci like sga_personas.nro_ci,
       n_pais_emisor_pasa like sga_personas.pais_emisor_pasap,
       n_nro_pasap like sga_personas.nro_pasap,
       n_grupo_sanguineo like sga_personas.grupo_sanguineo,
       n_factor_sanguineo like sga_personas.factor_sanguineo,
       n_alta_serv_milita like sga_personas.alta_serv_militar,
       n_baja_serv_milita like sga_personas.baja_serv_militar,
       n_apellido_padre like sga_personas.apellido_padre,
       n_nombres_padre like sga_personas.nombres_padre,
       n_apellido_madre like sga_personas.apellido_madre,
       n_nombres_madre like sga_personas.nombres_madre,
       n_aborigen like sga_personas.aborigen,
       n_fecha_ingreso_pa like sga_personas.fecha_ingreso_pais,
       n_fecha_dni_otorg like sga_personas.fecha_dni_otorg,
       n_fecha_dni_venc like sga_personas.fecha_dni_venc,
       n_fecha_respre_oto like sga_personas.fecha_respre_otorg,
       n_fecha_respre_ven like sga_personas.fecha_respre_venc,
       n_residencia like sga_personas.residencia,
       n_apellido_elegido like sga_personas.apellido_elegido,
       n_nombre_elegido like sga_personas.nombre_elegido,
       n_vive like sga_personas.vive,
       n_id_imagen like sga_personas.id_imagen,
	   n_tit_sec_sit_conv like sga_personas.tit_sec_sit_conv,
	   n_tit_sec_nro_resol like sga_personas.tit_sec_nro_resol)
BEGIN
   -------------------------------------------------------------------------------- 
   -- Impide que se modifique la clave primaria de un registro 
   -------------------------------------------------------------------------------- 
   IF o_unidad_academica <> n_unidad_academica OR
      o_nro_inscripcion <> n_nro_inscripcion  THEN
      raise exception -746,0,'No se puede modificar la clave primaria de un registro.';
   END IF;



   -- No se puede insertar en sga_personas si no existe en sga_titulos_sec
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en mug_paises
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en sga_orient_voc_rec
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en sga_coleg_sec
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en mug_localidades
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en mdp_nacionalidades
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en mdp_tipo_documento
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT


   -- Carga la tabla de log para auditoria
   INSERT INTO log_personas (
     unidad_academica,
     nro_inscripcion,
     fecha_inscripcion,
     apellido,
     nombres,
     pais_documento,
     tipo_documento,
     nro_documento,
     numero_cuil,
     sexo,
     fecha_nacimiento,
     nacionalidad,
     loc_nacimiento,
     colegio_secundario,
     titulo_secundario,
     anio_egreso_sec,
     orient_voc_rec,
     ent_emisora_ci,
     nro_ci,
     pais_emisor_pasap,
     nro_pasap,
     grupo_sanguineo,
     factor_sanguineo,
     alta_serv_militar,
     baja_serv_militar,
     apellido_padre,
     nombres_padre,
     apellido_madre,
     nombres_madre,
     aborigen,
     fecha_ingreso_pais,
     fecha_dni_otorg,
     fecha_dni_venc,
     fecha_respre_otorg,
     fecha_respre_venc,
     residencia,
     apellido_elegido,
     nombre_elegido,
     vive,
     id_imagen,
     tit_sec_sit_conv,
     tit_sec_nro_resol,
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_unidad_academica,
     n_nro_inscripcion,
     n_fecha_inscripcio,
     n_apellido,
     n_nombres,
     n_pais_documento,
     n_tipo_documento,
     n_nro_documento,
     n_numero_cuil,
     n_sexo,
     n_fecha_nacimiento,
     n_nacionalidad,
     n_loc_nacimiento,
     n_colegio_secundar,
     n_titulo_secundari,
     n_anio_egreso_sec,
     n_orient_voc_rec,
     n_ent_emisora_ci,
     n_nro_ci,
     n_pais_emisor_pasa,
     n_nro_pasap,
     n_grupo_sanguineo,
     n_factor_sanguineo,
     n_alta_serv_milita,
     n_baja_serv_milita,
     n_apellido_padre,
     n_nombres_padre,
     n_apellido_madre,
     n_nombres_madre,
     n_aborigen,
     n_fecha_ingreso_pa,
     n_fecha_dni_otorg,
     n_fecha_dni_venc,
     n_fecha_respre_oto,
     n_fecha_respre_ven,
     n_residencia,
     n_apellido_elegido,
     n_nombre_elegido,
     n_vive,
     n_id_imagen,
     n_tit_sec_sit_conv,
     n_tit_sec_nro_resol,
     User,
     Current year to Second,
     'U');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de UPDATE de sga_personas **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_personas
-- Procedure personalizado uau_personas (asociado al trigger de UPDATE)
-- *******************************************************************************
-- DROP PROCEDURE uau_personas ;
-- CREATE PROCEDURE uau_personas (
--        o_unidad_academica like sga_personas.unidad_academica,
--        o_nro_inscripcion like sga_personas.nro_inscripcion,
--        o_fecha_inscripcio like sga_personas.fecha_inscripcion,
--        o_apellido like sga_personas.apellido,
--        o_nombres like sga_personas.nombres,
--        o_pais_documento like sga_personas.pais_documento,
--        o_tipo_documento like sga_personas.tipo_documento,
--        o_nro_documento like sga_personas.nro_documento,
--        o_numero_cuil like sga_personas.numero_cuil,
--        o_sexo like sga_personas.sexo,
--        o_fecha_nacimiento like sga_personas.fecha_nacimiento,
--        o_nacionalidad like sga_personas.nacionalidad,
--        o_loc_nacimiento like sga_personas.loc_nacimiento,
--        o_colegio_secundar like sga_personas.colegio_secundario,
--        o_titulo_secundari like sga_personas.titulo_secundario,
--        o_anio_egreso_sec like sga_personas.anio_egreso_sec,
--        o_orient_voc_rec like sga_personas.orient_voc_rec,
--        o_ent_emisora_ci like sga_personas.ent_emisora_ci,
--        o_nro_ci like sga_personas.nro_ci,
--        o_pais_emisor_pasa like sga_personas.pais_emisor_pasap,
--        o_nro_pasap like sga_personas.nro_pasap,
--        o_grupo_sanguineo like sga_personas.grupo_sanguineo,
--        o_factor_sanguineo like sga_personas.factor_sanguineo,
--        o_alta_serv_milita like sga_personas.alta_serv_militar,
--        o_baja_serv_milita like sga_personas.baja_serv_militar,
--        o_apellido_padre like sga_personas.apellido_padre,
--        o_nombres_padre like sga_personas.nombres_padre,
--        o_apellido_madre like sga_personas.apellido_madre,
--        o_nombres_madre like sga_personas.nombres_madre,
--        o_aborigen like sga_personas.aborigen,
--        o_fecha_ingreso_pa like sga_personas.fecha_ingreso_pais,
--        o_fecha_dni_otorg like sga_personas.fecha_dni_otorg,
--        o_fecha_dni_venc like sga_personas.fecha_dni_venc,
--        o_fecha_respre_oto like sga_personas.fecha_respre_otorg,
--        o_fecha_respre_ven like sga_personas.fecha_respre_venc,
--        o_residencia like sga_personas.residencia,
--        o_apellido_elegido like sga_personas.apellido_elegido,
--        o_nombre_elegido like sga_personas.nombre_elegido,
--        o_vive like sga_personas.vive,
--        o_id_imagen like sga_personas.id_imagen,
--        n_unidad_academica like sga_personas.unidad_academica,
--        n_nro_inscripcion like sga_personas.nro_inscripcion,
--        n_fecha_inscripcio like sga_personas.fecha_inscripcion,
--        n_apellido like sga_personas.apellido,
--        n_nombres like sga_personas.nombres,
--        n_pais_documento like sga_personas.pais_documento,
--        n_tipo_documento like sga_personas.tipo_documento,
--        n_nro_documento like sga_personas.nro_documento,
--        n_numero_cuil like sga_personas.numero_cuil,
--        n_sexo like sga_personas.sexo,
--        n_fecha_nacimiento like sga_personas.fecha_nacimiento,
--        n_nacionalidad like sga_personas.nacionalidad,
--        n_loc_nacimiento like sga_personas.loc_nacimiento,
--        n_colegio_secundar like sga_personas.colegio_secundario,
--        n_titulo_secundari like sga_personas.titulo_secundario,
--        n_anio_egreso_sec like sga_personas.anio_egreso_sec,
--        n_orient_voc_rec like sga_personas.orient_voc_rec,
--        n_ent_emisora_ci like sga_personas.ent_emisora_ci,
--        n_nro_ci like sga_personas.nro_ci,
--        n_pais_emisor_pasa like sga_personas.pais_emisor_pasap,
--        n_nro_pasap like sga_personas.nro_pasap,
--        n_grupo_sanguineo like sga_personas.grupo_sanguineo,
--        n_factor_sanguineo like sga_personas.factor_sanguineo,
--        n_alta_serv_milita like sga_personas.alta_serv_militar,
--        n_baja_serv_milita like sga_personas.baja_serv_militar,
--        n_apellido_padre like sga_personas.apellido_padre,
--        n_nombres_padre like sga_personas.nombres_padre,
--        n_apellido_madre like sga_personas.apellido_madre,
--        n_nombres_madre like sga_personas.nombres_madre,
--        n_aborigen like sga_personas.aborigen,
--        n_fecha_ingreso_pa like sga_personas.fecha_ingreso_pais,
--        n_fecha_dni_otorg like sga_personas.fecha_dni_otorg,
--        n_fecha_dni_venc like sga_personas.fecha_dni_venc,
--        n_fecha_respre_oto like sga_personas.fecha_respre_otorg,
--        n_fecha_respre_ven like sga_personas.fecha_respre_venc,
--        n_residencia like sga_personas.residencia,
--        n_apellido_elegido like sga_personas.apellido_elegido,
--        n_nombre_elegido like sga_personas.nombre_elegido,
--        n_vive like sga_personas.vive,
--        n_id_imagen like sga_personas.id_imagen)
-- BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
-- END;
-- END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de UPDATE de sga_personas ****
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.0
-- Tabla sga_personas
-- Trigger de Update tu_personas
-- *******************************************************************************
-- DROP TRIGGER tu_personas ;
CREATE TRIGGER tu_personas UPDATE on sga_personas
referencing old as old new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spu_personas (
     old.unidad_academica,
     old.nro_inscripcion,
     old.fecha_inscripcion,
     old.apellido,
     old.nombres,
     old.pais_documento,
     old.tipo_documento,
     old.nro_documento,
     old.numero_cuil,
     old.sexo,
     old.fecha_nacimiento,
     old.nacionalidad,
     old.loc_nacimiento,
     old.colegio_secundario,
     old.titulo_secundario,
     old.anio_egreso_sec,
     old.orient_voc_rec,
     old.ent_emisora_ci,
     old.nro_ci,
     old.pais_emisor_pasap,
     old.nro_pasap,
     old.grupo_sanguineo,
     old.factor_sanguineo,
     old.alta_serv_militar,
     old.baja_serv_militar,
     old.apellido_padre,
     old.nombres_padre,
     old.apellido_madre,
     old.nombres_madre,
     old.aborigen,
     old.fecha_ingreso_pais,
     old.fecha_dni_otorg,
     old.fecha_dni_venc,
     old.fecha_respre_otorg,
     old.fecha_respre_venc,
     old.residencia,
     old.apellido_elegido,
     old.nombre_elegido,
     old.vive,
     old.id_imagen,
     old.tit_sec_sit_conv,
     old.tit_sec_nro_resol,
     new.unidad_academica,
     new.nro_inscripcion,
     new.fecha_inscripcion,
     new.apellido,
     new.nombres,
     new.pais_documento,
     new.tipo_documento,
     new.nro_documento,
     new.numero_cuil,
     new.sexo,
     new.fecha_nacimiento,
     new.nacionalidad,
     new.loc_nacimiento,
     new.colegio_secundario,
     new.titulo_secundario,
     new.anio_egreso_sec,
     new.orient_voc_rec,
     new.ent_emisora_ci,
     new.nro_ci,
     new.pais_emisor_pasap,
     new.nro_pasap,
     new.grupo_sanguineo,
     new.factor_sanguineo,
     new.alta_serv_militar,
     new.baja_serv_militar,
     new.apellido_padre,
     new.nombres_padre,
     new.apellido_madre,
     new.nombres_madre,
     new.aborigen,
     new.fecha_ingreso_pais,
     new.fecha_dni_otorg,
     new.fecha_dni_venc,
     new.fecha_respre_otorg,
     new.fecha_respre_venc,
     new.residencia,
     new.apellido_elegido,
     new.nombre_elegido,
     new.vive,
     new.id_imagen,
     new.tit_sec_sit_conv,
     new.tit_sec_nro_resol)
--,

{
 EXECUTE PROCEDURE sp_qui_datos_per (
     old.unidad_academica,
     old.nro_inscripcion,
     old.fecha_inscripcion,
     old.apellido,
     old.nombres,
     old.tipo_documento,
     old.nro_documento,
     old.sexo,
     old.fecha_nacimiento,
     old.nacionalidad,
     old.loc_nacimiento,
     old.nro_ci,
     old.nro_pasap,
     new.unidad_academica,
     new.nro_inscripcion,
     new.fecha_inscripcion,
     new.apellido,
     new.nombres,
     new.tipo_documento,
     new.nro_documento,
     new.sexo,
     new.fecha_nacimiento,
     new.nacionalidad,
     new.loc_nacimiento,
     new.nro_ci,
     new.nro_pasap,
     'U')
--,
}


--   EXECUTE PROCEDURE uau_personas (
--     old.unidad_academica,
--     old.nro_inscripcion,
--     old.fecha_inscripcion,
--     old.apellido,
--     old.nombres,
--     old.pais_documento,
--     old.tipo_documento,
--     old.nro_documento,
--     old.numero_cuil,
--     old.sexo,
--     old.fecha_nacimiento,
--     old.nacionalidad,
--     old.loc_nacimiento,
--     old.colegio_secundario,
--     old.titulo_secundario,
--     old.anio_egreso_sec,
--     old.orient_voc_rec,
--     old.ent_emisora_ci,
--     old.nro_ci,
--     old.pais_emisor_pasap,
--     old.nro_pasap,
--     old.grupo_sanguineo,
--     old.factor_sanguineo,
--     old.alta_serv_militar,
--     old.baja_serv_militar,
--     old.apellido_padre,
--     old.nombres_padre,
--     old.apellido_madre,
--     old.nombres_madre,
--     old.aborigen,
--     old.fecha_ingreso_pais,
--     old.fecha_dni_otorg,
--     old.fecha_dni_venc,
--     old.fecha_respre_otorg,
--     old.fecha_respre_venc,
--     old.residencia,
--     old.apellido_elegido,
--     old.nombre_elegido,
--     old.vive,
--     old.id_imagen,
--     new.unidad_academica,
--     new.nro_inscripcion,
--     new.fecha_inscripcion,
--     new.apellido,
--     new.nombres,
--     new.pais_documento,
--     new.tipo_documento,
--     new.nro_documento,
--     new.numero_cuil,
--     new.sexo,
--     new.fecha_nacimiento,
--     new.nacionalidad,
--     new.loc_nacimiento,
--     new.colegio_secundario,
--     new.titulo_secundario,
--     new.anio_egreso_sec,
--     new.orient_voc_rec,
--     new.ent_emisora_ci,
--     new.nro_ci,
--     new.pais_emisor_pasap,
--     new.nro_pasap,
--     new.grupo_sanguineo,
--     new.factor_sanguineo,
--     new.alta_serv_militar,
--     new.baja_serv_militar,
--     new.apellido_padre,
--     new.nombres_padre,
--     new.apellido_madre,
--     new.nombres_madre,
--     new.aborigen,
--     new.fecha_ingreso_pais,
--     new.fecha_dni_otorg,
--     new.fecha_dni_venc,
--     new.fecha_respre_otorg,
--     new.fecha_respre_venc,
--     new.residencia,
--     new.apellido_elegido,
--     new.nombre_elegido,
--     new.vive, 
--     new.id_imagen)

);
-- ********** Fin del trigger de Update tu_personas **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.0, 2.08.0,  2.9.5
-- Tabla sga_personas
-- Procedure spi_personas (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE spi_personas ;
CREATE PROCEDURE spi_personas (
       n_unidad_academica like sga_personas.unidad_academica,
       n_nro_inscripcion like sga_personas.nro_inscripcion,
       n_fecha_inscripcio like sga_personas.fecha_inscripcion,
       n_apellido like sga_personas.apellido,
       n_nombres like sga_personas.nombres,
       n_pais_documento like sga_personas.pais_documento,
       n_tipo_documento like sga_personas.tipo_documento,
       n_nro_documento like sga_personas.nro_documento,
       n_numero_cuil like sga_personas.numero_cuil,
       n_sexo like sga_personas.sexo,
       n_fecha_nacimiento like sga_personas.fecha_nacimiento,
       n_nacionalidad like sga_personas.nacionalidad,
       n_loc_nacimiento like sga_personas.loc_nacimiento,
       n_colegio_secundar like sga_personas.colegio_secundario,
       n_titulo_secundari like sga_personas.titulo_secundario,
       n_anio_egreso_sec like sga_personas.anio_egreso_sec,
       n_orient_voc_rec like sga_personas.orient_voc_rec,
       n_ent_emisora_ci like sga_personas.ent_emisora_ci,
       n_nro_ci like sga_personas.nro_ci,
       n_pais_emisor_pasa like sga_personas.pais_emisor_pasap,
       n_nro_pasap like sga_personas.nro_pasap,
       n_grupo_sanguineo like sga_personas.grupo_sanguineo,
       n_factor_sanguineo like sga_personas.factor_sanguineo,
       n_alta_serv_milita like sga_personas.alta_serv_militar,
       n_baja_serv_milita like sga_personas.baja_serv_militar,
       n_apellido_padre like sga_personas.apellido_padre,
       n_nombres_padre like sga_personas.nombres_padre,
       n_apellido_madre like sga_personas.apellido_madre,
       n_nombres_madre like sga_personas.nombres_madre,
       n_aborigen like sga_personas.aborigen,
       n_fecha_ingreso_pa like sga_personas.fecha_ingreso_pais,
       n_fecha_dni_otorg like sga_personas.fecha_dni_otorg,
       n_fecha_dni_venc like sga_personas.fecha_dni_venc,
       n_fecha_respre_oto like sga_personas.fecha_respre_otorg,
       n_fecha_respre_ven like sga_personas.fecha_respre_venc,
       n_residencia like sga_personas.residencia,
       n_apellido_elegido like sga_personas.apellido_elegido,
       n_nombre_elegido like sga_personas.nombre_elegido,
       n_vive like sga_personas.vive,
       n_id_imagen like sga_personas.id_imagen,
	   n_tit_sec_sit_conv like sga_personas.tit_sec_sit_conv,
	   n_tit_sec_nro_resol like sga_personas.tit_sec_nro_resol)
BEGIN

   -- No se puede insertar en sga_personas si no existe en sga_titulos_sec
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en sga_entes_emis_ci
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en mug_paises
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en sga_orient_voc_rec
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en sga_coleg_sec
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en mug_localidades
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en mdp_nacionalidades
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en mdp_tipo_documento
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_personas si no existe en sga_unidades_acad
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

  ----------------------------------------------------------------------------------
  -- Inserta en sga_datos Censales un registro vacio
  ----------------------------------------------------------------------------------
  INSERT INTO sga_datos_censales (unidad_academica, nro_inscripcion, fecha_relevamiento )  
	VALUES (N_UNIDAD_ACADEMICA, N_NRO_INSCRIPCION, N_FECHA_INSCRIPCIO);  

  INSERT INTO sga_datos_cen_aux (unidad_academica, nro_inscripcion, fecha_relevamiento )  
	VALUES (N_UNIDAD_ACADEMICA, N_NRO_INSCRIPCION, N_FECHA_INSCRIPCIO);  

  INSERT INTO sga_datos_cen_aux2 (unidad_academica, nro_inscripcion, fecha_relevamiento )  
	VALUES (N_UNIDAD_ACADEMICA, N_NRO_INSCRIPCION, N_FECHA_INSCRIPCIO);  

  -- Foto de la persona
  INSERT INTO sga_personas_foto (unidad_academica, nro_inscripcion) 
  VALUES (n_unidad_academica, n_nro_inscripcion);
  
   -- Carga la tabla de log para auditoria
   INSERT INTO log_personas (
     unidad_academica,
     nro_inscripcion,
     fecha_inscripcion,
     apellido,
     nombres,
     pais_documento,
     tipo_documento,
     nro_documento,
     numero_cuil,
     sexo,
     fecha_nacimiento,
     nacionalidad,
     loc_nacimiento,
     colegio_secundario,
     titulo_secundario,
     anio_egreso_sec,
     orient_voc_rec,
     ent_emisora_ci,
     nro_ci,
     pais_emisor_pasap,
     nro_pasap,
     grupo_sanguineo,
     factor_sanguineo,
     alta_serv_militar,
     baja_serv_militar,
     apellido_padre,
     nombres_padre,
     apellido_madre,
     nombres_madre,
     aborigen,
     fecha_ingreso_pais,
     fecha_dni_otorg,
     fecha_dni_venc,
     fecha_respre_otorg,
     fecha_respre_venc,
     residencia,
     apellido_elegido,
     nombre_elegido,
     vive,
     id_imagen,
     tit_sec_sit_conv,
     tit_sec_nro_resol,
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_unidad_academica,
     n_nro_inscripcion,
     n_fecha_inscripcio,
     n_apellido,
     n_nombres,
     n_pais_documento,
     n_tipo_documento,
     n_nro_documento,
     n_numero_cuil,
     n_sexo,
     n_fecha_nacimiento,
     n_nacionalidad,
     n_loc_nacimiento,
     n_colegio_secundar,
     n_titulo_secundari,
     n_anio_egreso_sec,
     n_orient_voc_rec,
     n_ent_emisora_ci,
     n_nro_ci,
     n_pais_emisor_pasa,
     n_nro_pasap,
     n_grupo_sanguineo,
     n_factor_sanguineo,
     n_alta_serv_milita,
     n_baja_serv_milita,
     n_apellido_padre,
     n_nombres_padre,
     n_apellido_madre,
     n_nombres_madre,
     n_aborigen,
     n_fecha_ingreso_pa,
     n_fecha_dni_otorg,
     n_fecha_dni_venc,
     n_fecha_respre_oto,
     n_fecha_respre_ven,
     n_residencia,
     n_apellido_elegido,
     n_nombre_elegido,
     n_vive,
     n_id_imagen,
     n_tit_sec_sit_conv,
     n_tit_sec_nro_resol,
     User,
     Current year to Second,
     'I');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de INSERT de sga_personas **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_personas
-- Procedure personalizado uai_personas (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE uai_personas ;
-- CREATE PROCEDURE uai_personas (
--        n_unidad_academica like sga_personas.unidad_academica,
--        n_nro_inscripcion like sga_personas.nro_inscripcion,
--        n_fecha_inscripcio like sga_personas.fecha_inscripcion,
--        n_apellido like sga_personas.apellido,
--        n_nombres like sga_personas.nombres,
--        n_pais_documento like sga_personas.pais_documento,
--        n_tipo_documento like sga_personas.tipo_documento,
--        n_nro_documento like sga_personas.nro_documento,
--        n_numero_cuil like sga_personas.numero_cuil,
--        n_sexo like sga_personas.sexo,
--        n_fecha_nacimiento like sga_personas.fecha_nacimiento,
--        n_nacionalidad like sga_personas.nacionalidad,
--        n_loc_nacimiento like sga_personas.loc_nacimiento,
--        n_colegio_secundar like sga_personas.colegio_secundario,
--        n_titulo_secundari like sga_personas.titulo_secundario,
--        n_anio_egreso_sec like sga_personas.anio_egreso_sec,
--        n_orient_voc_rec like sga_personas.orient_voc_rec,
--        n_ent_emisora_ci like sga_personas.ent_emisora_ci,
--        n_nro_ci like sga_personas.nro_ci,
--        n_pais_emisor_pasa like sga_personas.pais_emisor_pasap,
--        n_nro_pasap like sga_personas.nro_pasap,
--        n_grupo_sanguineo like sga_personas.grupo_sanguineo,
--        n_factor_sanguineo like sga_personas.factor_sanguineo,
--        n_alta_serv_milita like sga_personas.alta_serv_militar,
--        n_baja_serv_milita like sga_personas.baja_serv_militar,
--        n_apellido_padre like sga_personas.apellido_padre,
--        n_nombres_padre like sga_personas.nombres_padre,
--        n_apellido_madre like sga_personas.apellido_madre,
--        n_nombres_madre like sga_personas.nombres_madre,
--        n_aborigen like sga_personas.aborigen,
--        n_fecha_ingreso_pa like sga_personas.fecha_ingreso_pais,
--        n_fecha_dni_otorg like sga_personas.fecha_dni_otorg,
--        n_fecha_dni_venc like sga_personas.fecha_dni_venc,
--        n_fecha_respre_oto like sga_personas.fecha_respre_otorg,
--        n_fecha_respre_ven like sga_personas.fecha_respre_venc,
--        n_residencia like sga_personas.residencia,
--        n_apellido_elegido like sga_personas.apellido_elegido,
--        n_nombre_elegido like sga_personas.nombre_elegido,
--        n_vive like sga_personas.vive,
--        n_id_imagen like sga_personas.id_imagen)
-- BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
-- END;
-- END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de INSERT de sga_personas ****
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.0
-- Tabla sga_personas
-- Trigger de Insert ti_personas
-- *******************************************************************************
-- DROP TRIGGER ti_personas ;
CREATE TRIGGER ti_personas INSERT on sga_personas
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_personas (
     new.unidad_academica,
     new.nro_inscripcion,
     new.fecha_inscripcion,
     new.apellido,
     new.nombres,
     new.pais_documento,
     new.tipo_documento,
     new.nro_documento,
     new.numero_cuil,
     new.sexo,
     new.fecha_nacimiento,
     new.nacionalidad,
     new.loc_nacimiento,
     new.colegio_secundario,
     new.titulo_secundario,
     new.anio_egreso_sec,
     new.orient_voc_rec,
     new.ent_emisora_ci,
     new.nro_ci,
     new.pais_emisor_pasap,
     new.nro_pasap,
     new.grupo_sanguineo,
     new.factor_sanguineo,
     new.alta_serv_militar,
     new.baja_serv_militar,
     new.apellido_padre,
     new.nombres_padre,
     new.apellido_madre,
     new.nombres_madre,
     new.aborigen,
     new.fecha_ingreso_pais,
     new.fecha_dni_otorg,
     new.fecha_dni_venc,
     new.fecha_respre_otorg,
     new.fecha_respre_venc,
     new.residencia,
     new.apellido_elegido,
     new.nombre_elegido,
     new.vive,
     new.id_imagen,
     new.tit_sec_sit_conv,
     new.tit_sec_nro_resol)
--,

{-- Dato para interfaz con SIU-QUILMES.
 EXECUTE PROCEDURE sp_qui_datos_per (
     new.unidad_academica,
     new.nro_inscripcion,
     new.fecha_inscripcion,
     new.apellido,
     new.nombres,
     new.tipo_documento,
     new.nro_documento,
     new.sexo,
     new.fecha_nacimiento,
     new.nacionalidad,
     new.loc_nacimiento,
     new.nro_ci,
     new.nro_pasap,
     new.unidad_academica,
     new.nro_inscripcion,
     new.fecha_inscripcion,
     new.apellido,
     new.nombres,
     new.tipo_documento,
     new.nro_documento,
     new.sexo,
     new.fecha_nacimiento,
     new.nacionalidad,
     new.loc_nacimiento,
     new.nro_ci,
     new.nro_pasap,
     'I')
--,
}

--   EXECUTE PROCEDURE uai_personas (
--     new.unidad_academica,
--     new.nro_inscripcion,
--     new.fecha_inscripcion,
--     new.apellido,
--     new.nombres,
--     new.pais_documento,
--     new.tipo_documento,
--     new.nro_documento,
--     new.numero_cuil,
--     new.sexo,
--     new.fecha_nacimiento,
--     new.nacionalidad,
--     new.loc_nacimiento,
--     new.colegio_secundario,
--     new.titulo_secundario,
--     new.anio_egreso_sec,
--     new.orient_voc_rec,
--     new.ent_emisora_ci,
--     new.nro_ci,
--     new.pais_emisor_pasap,
--     new.nro_pasap,
--     new.grupo_sanguineo,
--     new.factor_sanguineo,
--     new.alta_serv_militar,
--     new.baja_serv_militar,
--     new.apellido_padre,
--     new.nombres_padre,
--     new.apellido_madre,
--     new.nombres_madre,
--     new.aborigen,
--     new.fecha_ingreso_pais,
--     new.fecha_dni_otorg,
--     new.fecha_dni_venc,
--     new.fecha_respre_otorg,
--     new.fecha_respre_venc,
--     new.residencia,
--     new.apellido_elegido,
--     new.nombre_elegido,
--     new.vive,
--     new.id_imagen)
);
-- ********** Fin del trigger de Insert ti_personas **********


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Tabla sga_formacion_acad
-- Nuevo campo: titulo_ant_revconv  (indica si el titulo esta revalidado/convalidado por el ministerio.)
-- 1 = Convalidado 2 = Revalidado 3 = No Revalidado-Convalidado 4 = Reconocimiento 5 = Convalidación provisoria 
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ALTER TABLE sga_formacion_acad MODIFY NRO_RESOL_MINISTERIO VARCHAR(100); 
ALTER TABLE log_formacion_acad MODIFY NRO_RESOL_MINISTERIO VARCHAR(100); 

-- Agrega en la tabla de titulos anteriores habilitantes del alumno el dato de si esta convalidado/revalidado etc..
ALTER TABLE sga_formacion_acad ADD TITULO_ANT_REVCONV INTEGER; 
ALTER TABLE log_formacion_acad ADD TITULO_ANT_REVCONV INTEGER; 

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Tabla sga_formacion_acad
-- campo: titulo_ant_revconv  (indica si el titulo esta revalidado/convalidado por el ministerio.)
-- 1 = Convalidado 2 = Revalidado 3 = No Revalidado-Convalidado 4 = Reconocimiento 5 = Convalidación provisoria 
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ALTER TABLE sga_formacion_acad
    ADD CONSTRAINT CHECK (titulo_ant_revconv IN (1,2,3,4,5))
    CONSTRAINT ck_formacad_titant;

	
DROP TRIGGER td_formacion_acad ;
DROP TRIGGER ti_formacion_acad ;
DROP TRIGGER tu_formacion_acad ;	
DROP PROCEDURE spd_formacion_acad ;
DROP PROCEDURE spi_formacion_acad ;
DROP PROCEDURE spu_formacion_acad ;
	
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.0, 2.9.4
-- Tabla sga_formacion_acad
-- Procedure spd_formacion_acad (asociado al trigger de DELETE)
-- *******************************************************************************
-- DROP PROCEDURE spd_formacion_acad ;
CREATE PROCEDURE spd_formacion_acad (
       o_formacion_acad like sga_formacion_acad.formacion_acad,
       o_unidad_academica like sga_formacion_acad.unidad_academica,
       o_nro_inscripcion like sga_formacion_acad.nro_inscripcion,
       o_titulo_superior like sga_formacion_acad.titulo_superior,
       o_titulo_sup_prein like sga_formacion_acad.titulo_sup_prein,
       o_institucion like sga_formacion_acad.institucion,
       o_institucion_prei like sga_formacion_acad.institucion_prein,
       o_fecha_ingreso like sga_formacion_acad.fecha_ingreso,
       o_fecha_egreso like sga_formacion_acad.fecha_egreso,
       o_titulo_tesis like sga_formacion_acad.titulo_tesis,
       o_director_tesis like sga_formacion_acad.director_tesis,
       o_categoria_coneau like sga_formacion_acad.categoria_coneau,
       o_duracion_teorica like sga_formacion_acad.duracion_teorica,
       o_nro_resol_minist like sga_formacion_acad.nro_resol_ministerio,
       o_titulo_ant_revco like sga_formacion_acad.titulo_ant_revconv)
BEGIN

   -- Relacion de la tabla sga_formacion_acad contra si misma.
   -- Fuerza la creación del trigger desde Erwin

   -- Carga la tabla de log para auditoria
   INSERT INTO log_formacion_acad (
     formacion_acad,
     unidad_academica,
     nro_inscripcion,
     titulo_superior,
     titulo_sup_prein,
     institucion,
     institucion_prein,
     fecha_ingreso,
     fecha_egreso,
     titulo_tesis,
     director_tesis,
     categoria_coneau,
     duracion_teorica,
     nro_resol_ministerio,
     titulo_ant_revconv,
     usuario,
     fecha_act,
     oper)
   VALUES (
     o_formacion_acad,
     o_unidad_academica,
     o_nro_inscripcion,
     o_titulo_superior,
     o_titulo_sup_prein,
     o_institucion,
     o_institucion_prei,
     o_fecha_ingreso,
     o_fecha_egreso,
     o_titulo_tesis,
     o_director_tesis,
     o_categoria_coneau,
     o_duracion_teorica,
     o_nro_resol_minist,
     o_titulo_ant_revco,
     User,
     Current year to Second,
     'D');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de DELETE de sga_formacion_acad **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_formacion_acad
-- Procedure personalizado uad_formacion_acad (asociado al trigger de DELETE)
-- *******************************************************************************
-- DROP PROCEDURE uad_formacion_acad ;
-- CREATE PROCEDURE uad_formacion_acad (
--        o_formacion_acad like sga_formacion_acad.formacion_acad,
--        o_unidad_academica like sga_formacion_acad.unidad_academica,
--        o_nro_inscripcion like sga_formacion_acad.nro_inscripcion,
--        o_titulo_superior like sga_formacion_acad.titulo_superior,
--        o_titulo_sup_prein like sga_formacion_acad.titulo_sup_prein,
--        o_institucion like sga_formacion_acad.institucion,
--        o_institucion_prei like sga_formacion_acad.institucion_prein,
--        o_fecha_ingreso like sga_formacion_acad.fecha_ingreso,
--        o_fecha_egreso like sga_formacion_acad.fecha_egreso,
--        o_titulo_tesis like sga_formacion_acad.titulo_tesis,
--        o_director_tesis like sga_formacion_acad.director_tesis,
--        o_categoria_coneau like sga_formacion_acad.categoria_coneau,
--        o_duracion_teorica like sga_formacion_acad.duracion_teorica,
--        o_nro_resol_minist like sga_formacion_acad.nro_resol_ministerio,
--        o_titulo_ant_revco like sga_formacion_acad.titulo_ant_revconv)
-- BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
-- END;
-- END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de DELETE de sga_formacion_acad ****
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.0
-- Tabla sga_formacion_acad
-- Trigger de Delete td_formacion_acad
-- *******************************************************************************
-- DROP TRIGGER td_formacion_acad ;
CREATE TRIGGER td_formacion_acad DELETE on sga_formacion_acad
referencing old as old
FOR EACH ROW (
   EXECUTE PROCEDURE spd_formacion_acad (
     old.formacion_acad,
     old.unidad_academica,
     old.nro_inscripcion,
     old.titulo_superior,
     old.titulo_sup_prein,
     old.institucion,
     old.institucion_prein,
     old.fecha_ingreso,
     old.fecha_egreso,
     old.titulo_tesis,
     old.director_tesis,
     old.categoria_coneau,
     old.duracion_teorica,
     old.nro_resol_ministerio,
     old.titulo_ant_revconv)
--,

--   EXECUTE PROCEDURE uad_formacion_acad (
--     old.formacion_acad,
--     old.unidad_academica,
--     old.nro_inscripcion,
--     old.titulo_superior,
--     old.titulo_sup_prein,
--     old.institucion,
--     old.institucion_prein,
--     old.fecha_ingreso,
--     old.fecha_egreso,
--     old.titulo_tesis,
--     old.director_tesis,
--     old.categoria_coneau,
--     old.duracion_teorica,
--     old.nro_resol_ministerio,
--     old.titulo_ant_revconv)
);
-- ********** Fin del trigger de Delete td_formacion_acad **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.0, 2.9.4
-- Tabla sga_formacion_acad
-- Procedure spu_formacion_acad (asociado al trigger de UPDATE)
-- *******************************************************************************
-- DROP PROCEDURE spu_formacion_acad ;
CREATE PROCEDURE spu_formacion_acad (
       o_formacion_acad like sga_formacion_acad.formacion_acad,
       o_unidad_academica like sga_formacion_acad.unidad_academica,
       o_nro_inscripcion like sga_formacion_acad.nro_inscripcion,
       o_titulo_superior like sga_formacion_acad.titulo_superior,
       o_titulo_sup_prein like sga_formacion_acad.titulo_sup_prein,
       o_institucion like sga_formacion_acad.institucion,
       o_institucion_prei like sga_formacion_acad.institucion_prein,
       o_fecha_ingreso like sga_formacion_acad.fecha_ingreso,
       o_fecha_egreso like sga_formacion_acad.fecha_egreso,
       o_titulo_tesis like sga_formacion_acad.titulo_tesis,
       o_director_tesis like sga_formacion_acad.director_tesis,
       o_categoria_coneau like sga_formacion_acad.categoria_coneau,
       o_duracion_teorica like sga_formacion_acad.duracion_teorica,
       o_nro_resol_minist like sga_formacion_acad.nro_resol_ministerio,
       o_titulo_ant_revco like sga_formacion_acad.titulo_ant_revconv,
       n_formacion_acad like sga_formacion_acad.formacion_acad,
       n_unidad_academica like sga_formacion_acad.unidad_academica,
       n_nro_inscripcion like sga_formacion_acad.nro_inscripcion,
       n_titulo_superior like sga_formacion_acad.titulo_superior,
       n_titulo_sup_prein like sga_formacion_acad.titulo_sup_prein,
       n_institucion like sga_formacion_acad.institucion,
       n_institucion_prei like sga_formacion_acad.institucion_prein,
       n_fecha_ingreso like sga_formacion_acad.fecha_ingreso,
       n_fecha_egreso like sga_formacion_acad.fecha_egreso,
       n_titulo_tesis like sga_formacion_acad.titulo_tesis,
       n_director_tesis like sga_formacion_acad.director_tesis,
       n_categoria_coneau like sga_formacion_acad.categoria_coneau,
       n_duracion_teorica like sga_formacion_acad.duracion_teorica,
       n_nro_resol_minist like sga_formacion_acad.nro_resol_ministerio,
       n_titulo_ant_revco like sga_formacion_acad.titulo_ant_revconv)
BEGIN
   -------------------------------------------------------------------------------- 
   -- Impide que se modifique la clave primaria de un registro 
   -------------------------------------------------------------------------------- 
   IF o_formacion_acad <> n_formacion_acad  THEN
      raise exception -746,0,'No se puede modificar la clave primaria de un registro.';
   END IF;

   -- No se puede insertar en sga_formacion_acad si no existe en sga_titulos_super
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_formacion_acad si no existe en sga_instituciones
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_formacion_acad si no existe en sga_personas
   -- (CHILD UPDATE RESTRICT) Este control lo lleva el CONSTRAINT


   -- Carga la tabla de log para auditoria
   INSERT INTO log_formacion_acad (
     formacion_acad,
     unidad_academica,
     nro_inscripcion,
     titulo_superior,
     titulo_sup_prein,
     institucion,
     institucion_prein,
     fecha_ingreso,
     fecha_egreso,
     titulo_tesis,
     director_tesis,
     categoria_coneau,
     duracion_teorica,
     nro_resol_ministerio,
     titulo_ant_revconv,
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_formacion_acad,
     n_unidad_academica,
     n_nro_inscripcion,
     n_titulo_superior,
     n_titulo_sup_prein,
     n_institucion,
     n_institucion_prei,
     n_fecha_ingreso,
     n_fecha_egreso,
     n_titulo_tesis,
     n_director_tesis,
     n_categoria_coneau,
     n_duracion_teorica,
     n_nro_resol_minist,
     n_titulo_ant_revco,
     User,
     Current year to Second,
     'U');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de UPDATE de sga_formacion_acad **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_formacion_acad
-- Procedure personalizado uau_formacion_acad (asociado al trigger de UPDATE)
-- *******************************************************************************
-- DROP PROCEDURE uau_formacion_acad ;
-- CREATE PROCEDURE uau_formacion_acad (
--        o_formacion_acad like sga_formacion_acad.formacion_acad,
--        o_unidad_academica like sga_formacion_acad.unidad_academica,
--        o_nro_inscripcion like sga_formacion_acad.nro_inscripcion,
--        o_titulo_superior like sga_formacion_acad.titulo_superior,
--        o_titulo_sup_prein like sga_formacion_acad.titulo_sup_prein,
--        o_institucion like sga_formacion_acad.institucion,
--        o_institucion_prei like sga_formacion_acad.institucion_prein,
--        o_fecha_ingreso like sga_formacion_acad.fecha_ingreso,
--        o_fecha_egreso like sga_formacion_acad.fecha_egreso,
--        o_titulo_tesis like sga_formacion_acad.titulo_tesis,
--        o_director_tesis like sga_formacion_acad.director_tesis,
--        o_categoria_coneau like sga_formacion_acad.categoria_coneau,
--        o_duracion_teorica like sga_formacion_acad.duracion_teorica,
--        o_nro_resol_minist like sga_formacion_acad.nro_resol_ministerio,
--        o_titulo_ant_revco like sga_formacion_acad.titulo_ant_revconv,
--        n_formacion_acad like sga_formacion_acad.formacion_acad,
--        n_unidad_academica like sga_formacion_acad.unidad_academica,
--        n_nro_inscripcion like sga_formacion_acad.nro_inscripcion,
--        n_titulo_superior like sga_formacion_acad.titulo_superior,
--        n_titulo_sup_prein like sga_formacion_acad.titulo_sup_prein,
--        n_institucion like sga_formacion_acad.institucion,
--        n_institucion_prei like sga_formacion_acad.institucion_prein,
--        n_fecha_ingreso like sga_formacion_acad.fecha_ingreso,
--        n_fecha_egreso like sga_formacion_acad.fecha_egreso,
--        n_titulo_tesis like sga_formacion_acad.titulo_tesis,
--        n_director_tesis like sga_formacion_acad.director_tesis,
--        n_categoria_coneau like sga_formacion_acad.categoria_coneau,
--        n_duracion_teorica like sga_formacion_acad.duracion_teorica,
--        n_nro_resol_minist like sga_formacion_acad.nro_resol_ministerio,
--        n_titulo_ant_revco like sga_formacion_acad.titulo_ant_revconv)
-- BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
-- END;
-- END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de UPDATE de sga_formacion_acad ****
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.0
-- Tabla sga_formacion_acad
-- Trigger de Update tu_formacion_acad
-- *******************************************************************************
-- DROP TRIGGER tu_formacion_acad ;
CREATE TRIGGER tu_formacion_acad UPDATE on sga_formacion_acad
referencing old as old new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spu_formacion_acad (
     old.formacion_acad,
     old.unidad_academica,
     old.nro_inscripcion,
     old.titulo_superior,
     old.titulo_sup_prein,
     old.institucion,
     old.institucion_prein,
     old.fecha_ingreso,
     old.fecha_egreso,
     old.titulo_tesis,
     old.director_tesis,
     old.categoria_coneau,
     old.duracion_teorica,
     old.nro_resol_ministerio,
     old.titulo_ant_revconv,
     new.formacion_acad,
     new.unidad_academica,
     new.nro_inscripcion,
     new.titulo_superior,
     new.titulo_sup_prein,
     new.institucion,
     new.institucion_prein,
     new.fecha_ingreso,
     new.fecha_egreso,
     new.titulo_tesis,
     new.director_tesis,
     new.categoria_coneau,
     new.duracion_teorica,
     new.nro_resol_ministerio,
     new.titulo_ant_revconv)
--,

--   EXECUTE PROCEDURE uau_formacion_acad (
--     old.formacion_acad,
--     old.unidad_academica,
--     old.nro_inscripcion,
--     old.titulo_superior,
--     old.titulo_sup_prein,
--     old.institucion,
--     old.institucion_prein,
--     old.fecha_ingreso,
--     old.fecha_egreso,
--     old.titulo_tesis,
--     old.director_tesis,
--     old.categoria_coneau,
--     old.duracion_teorica,
--     old.nro_resol_ministerio, 
--     old.titulo_ant_revconv,
--     new.formacion_acad,
--     new.unidad_academica,
--     new.nro_inscripcion,
--     new.titulo_superior,
--     new.titulo_sup_prein,
--     new.institucion,
--     new.institucion_prein,
--     new.fecha_ingreso,
--     new.fecha_egreso,
--     new.titulo_tesis,
--     new.director_tesis,
--     new.categoria_coneau,
--     new.duracion_teorica,
--     new.nro_resol_ministerio,
--     new.titulo_ant_revconv)

);
-- ********** Fin del trigger de Update tu_formacion_acad **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.0, 2.9.4
-- Tabla sga_formacion_acad
-- Procedure spi_formacion_acad (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE spi_formacion_acad ;
CREATE PROCEDURE spi_formacion_acad (
       n_formacion_acad like sga_formacion_acad.formacion_acad,
       n_unidad_academica like sga_formacion_acad.unidad_academica,
       n_nro_inscripcion like sga_formacion_acad.nro_inscripcion,
       n_titulo_superior like sga_formacion_acad.titulo_superior,
       n_titulo_sup_prein like sga_formacion_acad.titulo_sup_prein,
       n_institucion like sga_formacion_acad.institucion,
       n_institucion_prei like sga_formacion_acad.institucion_prein,
       n_fecha_ingreso like sga_formacion_acad.fecha_ingreso,
       n_fecha_egreso like sga_formacion_acad.fecha_egreso,
       n_titulo_tesis like sga_formacion_acad.titulo_tesis,
       n_director_tesis like sga_formacion_acad.director_tesis,
       n_categoria_coneau like sga_formacion_acad.categoria_coneau,
       n_duracion_teorica like sga_formacion_acad.duracion_teorica,
       n_nro_resol_minist like sga_formacion_acad.nro_resol_ministerio,
       n_titulo_ant_revco like sga_formacion_acad.titulo_ant_revconv)
BEGIN

   -- No se puede insertar en sga_formacion_acad si no existe en sga_titulos_super
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_formacion_acad si no existe en sga_instituciones
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT

   -- No se puede insertar en sga_formacion_acad si no existe en sga_personas
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT


   -- Carga la tabla de log para auditoria
   INSERT INTO log_formacion_acad (
     formacion_acad,
     unidad_academica,
     nro_inscripcion,
     titulo_superior,
     titulo_sup_prein,
     institucion,
     institucion_prein,
     fecha_ingreso,
     fecha_egreso,
     titulo_tesis,
     director_tesis,
     categoria_coneau,
     duracion_teorica,
     nro_resol_ministerio,
     titulo_ant_revconv,
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_formacion_acad,
     n_unidad_academica,
     n_nro_inscripcion,
     n_titulo_superior,
     n_titulo_sup_prein,
     n_institucion,
     n_institucion_prei,
     n_fecha_ingreso,
     n_fecha_egreso,
     n_titulo_tesis,
     n_director_tesis,
     n_categoria_coneau,
     n_duracion_teorica,
     n_nro_resol_minist,
     n_titulo_ant_revco,
     User,
     Current year to Second,
     'I');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de INSERT de sga_formacion_acad **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_formacion_acad
-- Procedure personalizado uai_formacion_acad (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE uai_formacion_acad ;
-- CREATE PROCEDURE uai_formacion_acad (
--        n_formacion_acad like sga_formacion_acad.formacion_acad,
--        n_unidad_academica like sga_formacion_acad.unidad_academica,
--        n_nro_inscripcion like sga_formacion_acad.nro_inscripcion,
--        n_titulo_superior like sga_formacion_acad.titulo_superior,
--        n_titulo_sup_prein like sga_formacion_acad.titulo_sup_prein,
--        n_institucion like sga_formacion_acad.institucion,
--        n_institucion_prei like sga_formacion_acad.institucion_prein,
--        n_fecha_ingreso like sga_formacion_acad.fecha_ingreso,
--        n_fecha_egreso like sga_formacion_acad.fecha_egreso,
--        n_titulo_tesis like sga_formacion_acad.titulo_tesis,
--        n_director_tesis like sga_formacion_acad.director_tesis,
--        n_categoria_coneau like sga_formacion_acad.categoria_coneau,
--        n_duracion_teorica like sga_formacion_acad.duracion_teorica,
--        n_nro_resol_minist like sga_formacion_acad.nro_resol_ministerio,
--        n_titulo_ant_revco like sga_formacion_acad.titulo_ant_revconv)
-- BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
-- END;
-- END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de INSERT de sga_formacion_acad ****
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.0
-- Tabla sga_formacion_acad
-- Trigger de Insert ti_formacion_acad
-- *******************************************************************************
-- DROP TRIGGER ti_formacion_acad ;
CREATE TRIGGER ti_formacion_acad INSERT on sga_formacion_acad
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_formacion_acad (
     new.formacion_acad,
     new.unidad_academica,
     new.nro_inscripcion,
     new.titulo_superior,
     new.titulo_sup_prein,
     new.institucion,
     new.institucion_prein,
     new.fecha_ingreso,
     new.fecha_egreso,
     new.titulo_tesis,
     new.director_tesis,
     new.categoria_coneau,
     new.duracion_teorica,
     new.nro_resol_ministerio,
     new.titulo_ant_revconv)
--,

--   EXECUTE PROCEDURE uai_formacion_acad (
--     new.formacion_acad,
--     new.unidad_academica,
--     new.nro_inscripcion,
--     new.titulo_superior,
--     new.titulo_sup_prein,
--     new.institucion,
--     new.institucion_prein,
--     new.fecha_ingreso,
--     new.fecha_egreso,
--     new.titulo_tesis,
--     new.director_tesis,
--     new.categoria_coneau,
--     new.duracion_teorica,
--     new.nro_resol_ministerio,
--     new.titulo_ant_revconv)
);
-- ********** Fin del trigger de Insert ti_formacion_acad **********
	




-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Tabla sga_titulos_plan
-- Nuevo campo: resol_ministerial, resol_coneau y normativa_instit  (Campos para informar a SIDCer)
-- Es el nro de resolucion ministerial y resoluciones modificatorias relacionadas con el titulo y plan de estudios
-- Dato a informar en el analítico
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ALTER TABLE sga_titulos_plan ADD RESOL_MINISTERIAL  VARCHAR(200) ; 
ALTER TABLE sga_titulos_plan ADD RESOL_CONEAU  VARCHAR(200) ; 
ALTER TABLE sga_titulos_plan ADD NORMATIVA_INSTIT   VARCHAR(200) ; 

ALTER TABLE log_titulos_plan ADD RESOL_MINISTERIAL  VARCHAR(200) ; 
ALTER TABLE log_titulos_plan ADD RESOL_CONEAU  VARCHAR(200) ; 
ALTER TABLE log_titulos_plan ADD NORMATIVA_INSTIT   VARCHAR(200) ; 

DROP TRIGGER ti_titulos_plan;
DROP TRIGGER td_titulos_plan;
DROP TRIGGER tu_titulos_plan;

DROP PROCEDURE spi_titulos_plan;
DROP PROCEDURE spd_titulos_plan;
DROP PROCEDURE spu_titulos_plan;

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.04.0, 2.9.4,2.9.5
-- Tabla sga_titulos_plan
-- Procedure spd_titulos_plan (asociado al trigger de DELETE)
-- *******************************************************************************
-- DROP PROCEDURE spd_titulos_plan ;
CREATE PROCEDURE spd_titulos_plan (
       o_unidad_academica like sga_titulos_plan.unidad_academica,
       o_carrera like sga_titulos_plan.carrera,
       o_plan like sga_titulos_plan.plan,
       o_titulo like sga_titulos_plan.titulo,
       o_tiene_orient like sga_titulos_plan.tiene_orient,
       o_elige_orient like sga_titulos_plan.elige_orient,
       o_total_cred_egres like sga_titulos_plan.total_cred_egreso,
       o_calculo_egreso like sga_titulos_plan.calculo_egreso,
       o_suma_cred_act_ex like sga_titulos_plan.suma_cred_act_ext,
       o_resol_minist like sga_titulos_plan.resol_ministerial,
       o_resol_coneau like sga_titulos_plan.resol_coneau,
       o_normativa_instit like sga_titulos_plan.normativa_instit)
BEGIN

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_areas_x_titulo (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_areas_x_titulo
    WHERE sga_areas_x_titulo.unidad_academica = o_unidad_academica
      AND sga_areas_x_titulo.carrera = o_carrera
      AND sga_areas_x_titulo.plan = o_plan
      AND sga_areas_x_titulo.titulo = o_titulo;

   -------------------------------------------------------------------------------- 
   -- Borra en cascada los registros de la tabla sga_orientaciones (PARENT DELETE CASCADE)
   -------------------------------------------------------------------------------- 
   DELETE FROM sga_orientaciones
    WHERE sga_orientaciones.unidad_academica = o_unidad_academica
      AND sga_orientaciones.carrera = o_carrera
      AND sga_orientaciones.plan = o_plan
      AND sga_orientaciones.titulo = o_titulo;


   -- Carga la tabla de log para auditoria
   INSERT INTO log_titulos_plan (
     unidad_academica,
     carrera,
     plan,
     titulo,
     tiene_orient,
     elige_orient,
     total_cred_egreso,
     calculo_egreso,
     suma_cred_act_ext,
     resol_ministerial,
     resol_coneau,	 
     normativa_instit, 	 
     usuario,
     fecha_act,
     oper)
   VALUES (
     o_unidad_academica,
     o_carrera,
     o_plan,
     o_titulo,
     o_tiene_orient,
     o_elige_orient,
     o_total_cred_egres,
     o_calculo_egreso,
     o_suma_cred_act_ex,
     o_resol_minist,
     o_resol_coneau,
     o_normativa_instit, 	 
     User,
     Current year to Second,
     'D');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de DELETE de sga_titulos_plan **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_titulos_plan
-- Procedure personalizado uad_titulos_plan (asociado al trigger de DELETE)
-- *******************************************************************************
-- DROP PROCEDURE uad_titulos_plan ;
-- CREATE PROCEDURE uad_titulos_plan (
--        o_unidad_academica like sga_titulos_plan.unidad_academica,
--        o_carrera like sga_titulos_plan.carrera,
--        o_plan like sga_titulos_plan.plan,
--        o_titulo like sga_titulos_plan.titulo,
--        o_tiene_orient like sga_titulos_plan.tiene_orient,
--        o_elige_orient like sga_titulos_plan.elige_orient,
--        o_total_cred_egres like sga_titulos_plan.total_cred_egreso,
--        o_calculo_egreso like sga_titulos_plan.calculo_egreso,
--        o_suma_cred_act_ex like sga_titulos_plan.suma_cred_act_ext
--        o_resol_minist like sga_titulos_plan.resol_ministerial,
--        o_resol_coneau like sga_titulos_plan.resol_coneau,
--        o_normativa_instit like sga_titulos_plan.normativa_instit)
-- BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
-- END;
-- END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de DELETE de sga_titulos_plan ****

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.04.0
-- Tabla sga_titulos_plan
-- Trigger de Delete td_titulos_plan
-- *******************************************************************************
-- DROP TRIGGER td_titulos_plan ;
CREATE TRIGGER td_titulos_plan DELETE on sga_titulos_plan
referencing old as old
FOR EACH ROW (
   EXECUTE PROCEDURE spd_titulos_plan (
     old.unidad_academica,
     old.carrera,
     old.plan,
     old.titulo,
     old.tiene_orient,
     old.elige_orient,
     old.total_cred_egreso,
     old.calculo_egreso,
     old.suma_cred_act_ext,
     old.resol_ministerial,
     old.resol_coneau,
     old.normativa_instit
     ) 	 
--,

--   EXECUTE PROCEDURE uad_titulos_plan (
--     old.unidad_academica,
--     old.carrera,
--     old.plan,
--     old.titulo,
--     old.tiene_orient,
--     old.elige_orient,
--     old.total_cred_egreso,
--     old.calculo_egreso,
--     old.suma_cred_act_ext,
--     old.resol_ministerial,
--     old.resol_coneau,
--     old.normativa_instit) 	 
);
-- ********** Fin del trigger de Delete td_titulos_plan **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.04.0, 2.9.4,2.9.5
-- Tabla sga_titulos_plan
-- Procedure spi_titulos_plan (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE spi_titulos_plan ;
CREATE PROCEDURE spi_titulos_plan (
       n_unidad_academica like sga_titulos_plan.unidad_academica,
       n_carrera like sga_titulos_plan.carrera,
       n_plan like sga_titulos_plan.plan,
       n_titulo like sga_titulos_plan.titulo,
       n_tiene_orient like sga_titulos_plan.tiene_orient,
       n_elige_orient like sga_titulos_plan.elige_orient,
       n_total_cred_egres like sga_titulos_plan.total_cred_egreso,
       n_calculo_egreso like sga_titulos_plan.calculo_egreso,
       n_suma_cred_act_ex like sga_titulos_plan.suma_cred_act_ext,
       n_resol_minist like sga_titulos_plan.resol_ministerial,
       n_resol_coneau like sga_titulos_plan.resol_coneau,
       n_normativa_instit like sga_titulos_plan.normativa_instit)
BEGIN

   -------------------------------------------------------------------------------- 
   -- Inserta las áreas del plan para el título ingresado
   -------------------------------------------------------------------------------- 
   INSERT INTO sga_areas_x_titulo (
          unidad_academica,
          carrera,
          plan,
          titulo,
          version,
          area,
          puntaje_requerido)
   SELECT n_unidad_academica,
          n_carrera,
          n_plan,
          n_titulo,
          sga_atri_area_plan.version,
          sga_atri_area_plan.area,
          0
     FROM sga_atri_area_plan
    WHERE sga_atri_area_plan.unidad_academica = n_unidad_academica
      AND sga_atri_area_plan.carrera = n_carrera
      AND sga_atri_area_plan.plan = n_plan;

   -- No se puede insertar en sga_titulos_plan si no existe en sga_titulos
   -- (CHILD INSERT RESTRICT) Este control lo lleva el CONSTRAINT


   -------------------------------------------------------------------------------- 
   -- Inserta la primer orientacion
   -------------------------------------------------------------------------------- 
   INSERT INTO sga_orientaciones (
           unidad_academica,
           carrera,
           plan,
           titulo,
           orientacion,
           nombre)
   VALUES (n_unidad_academica,
           n_carrera,
           n_plan,
           n_titulo,
           '0',
           'Plan basico');


   -------------------------------------------------------------------------------- 
   -- Impide que se inserte un título en un plan que haya entrado en vigencia
   -------------------------------------------------------------------------------- 
   IF EXISTS (SELECT ''
                FROM sga_planes
               WHERE sga_planes.unidad_academica = n_unidad_academica
                 AND sga_planes.carrera = n_carrera
                 AND sga_planes.plan = n_plan
                 AND sga_planes.fecha_ent_vigencia IS NOT NULL) THEN
      raise exception -746, 0, 'No se pueden agregar títulos en planes activos.';
   END IF;


   -- Carga la tabla de log para auditoria
   INSERT INTO log_titulos_plan (
     unidad_academica,
     carrera,
     plan,
     titulo,
     tiene_orient,
     elige_orient,
     total_cred_egreso,
     calculo_egreso,
     suma_cred_act_ext,
     resol_ministerial,
     resol_coneau,	 
     normativa_instit, 	 
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_unidad_academica,
     n_carrera,
     n_plan,
     n_titulo,
     n_tiene_orient,
     n_elige_orient,
     n_total_cred_egres,
     n_calculo_egreso,
     n_suma_cred_act_ex,
     n_resol_minist,
     n_resol_coneau,
     n_normativa_instit, 	 
     User,
     Current year to Second,
     'I');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de INSERT de sga_titulos_plan **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_titulos_plan
-- Procedure personalizado uai_titulos_plan (asociado al trigger de INSERT)
-- *******************************************************************************
-- DROP PROCEDURE uai_titulos_plan ;
-- CREATE PROCEDURE uai_titulos_plan (
--        n_unidad_academica like sga_titulos_plan.unidad_academica,
--        n_carrera like sga_titulos_plan.carrera,
--        n_plan like sga_titulos_plan.plan,
--        n_titulo like sga_titulos_plan.titulo,
--        n_tiene_orient like sga_titulos_plan.tiene_orient,
--        n_elige_orient like sga_titulos_plan.elige_orient,
--        n_total_cred_egres like sga_titulos_plan.total_cred_egreso,
--        n_calculo_egreso like sga_titulos_plan.calculo_egreso,
--        n_suma_cred_act_ex like sga_titulos_plan.suma_cred_act_ext,
--        n_resol_minist like sga_titulos_plan.resol_ministerial,
--        n_resol_coneau like sga_titulos_plan.resol_coneau,
--        n_normativa_instit like sga_titulos_plan.normativa_instit)
-- BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
-- END;
-- END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de INSERT de sga_titulos_plan ****
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.04.0
-- Tabla sga_titulos_plan
-- Trigger de Insert ti_titulos_plan
-- *******************************************************************************
-- DROP TRIGGER ti_titulos_plan ;
CREATE TRIGGER ti_titulos_plan INSERT on sga_titulos_plan
referencing new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spi_titulos_plan (
     new.unidad_academica,
     new.carrera,
     new.plan,
     new.titulo,
     new.tiene_orient,
     new.elige_orient,
     new.total_cred_egreso,
     new.calculo_egreso,
     new.suma_cred_act_ext,
     new.resol_ministerial,
     new.resol_coneau,
     new.normativa_instit) 	 
--,

--   EXECUTE PROCEDURE uai_titulos_plan (
--     new.unidad_academica,
--     new.carrera,
--     new.plan,
--     new.titulo,
--     new.tiene_orient,
--     new.elige_orient,
--     new.total_cred_egreso,
--     new.calculo_egreso,
--     new.suma_cred_act_ext,
--     new.resol_ministerial,
--     new.resol_coneau,
--     new.normativa_instit, 	 
);
-- ********** Fin del trigger de Insert ti_titulos_plan **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.04.0
-- Ultima versino de modificacion: 2.5.0, 2.9.4,2.9.5
-- Tabla sga_titulos_plan
-- Procedure spu_titulos_plan (asociado al trigger de UPDATE)
-- *******************************************************************************
-- DROP PROCEDURE spu_titulos_plan ;
CREATE PROCEDURE spu_titulos_plan (
       o_unidad_academica like sga_titulos_plan.unidad_academica,
       o_carrera like sga_titulos_plan.carrera,
       o_plan like sga_titulos_plan.plan,
       o_titulo like sga_titulos_plan.titulo,
       o_tiene_orient like sga_titulos_plan.tiene_orient,
       o_elige_orient like sga_titulos_plan.elige_orient,
       o_total_cred_egres like sga_titulos_plan.total_cred_egreso,
       o_calculo_egreso like sga_titulos_plan.calculo_egreso,
       o_suma_cred_act_ex like sga_titulos_plan.suma_cred_act_ext,
       o_resol_minist like sga_titulos_plan.resol_ministerial,
       o_resol_coneau like sga_titulos_plan.resol_coneau,
       o_normativa_instit like sga_titulos_plan.normativa_instit,
       n_unidad_academica like sga_titulos_plan.unidad_academica,
       n_carrera like sga_titulos_plan.carrera,
       n_plan like sga_titulos_plan.plan,
       n_titulo like sga_titulos_plan.titulo,
       n_tiene_orient like sga_titulos_plan.tiene_orient,
       n_elige_orient like sga_titulos_plan.elige_orient,
       n_total_cred_egres like sga_titulos_plan.total_cred_egreso,
       n_calculo_egreso like sga_titulos_plan.calculo_egreso,
       n_suma_cred_act_ex like sga_titulos_plan.suma_cred_act_ext,
       n_resol_minist like sga_titulos_plan.resol_ministerial,
       n_resol_coneau like sga_titulos_plan.resol_coneau,
       n_normativa_instit like sga_titulos_plan.normativa_instit)
BEGIN
   -------------------------------------------------------------------------------- 
   -- Impide que se modifique la clave primaria de un registro 
   -------------------------------------------------------------------------------- 
   IF o_unidad_academica <> n_unidad_academica OR
      o_carrera <> n_carrera OR
      o_plan <> n_plan OR
      o_titulo <> n_titulo  THEN
      raise exception -746,0,'No se puede modificar la clave primaria de un registro.';
   END IF;

   -------------------------------------------------------------------------------- 
   -- Impide que se modifique un título en un plan que haya entrado en vigencia
   -- Se permite que se cambie: 
   --	* si elige orientacion el alumno, 
   --	* cantidad de creditos para egreso del titulo de grado
   --	* si controla o no las actividades extracurriculares al solicitar el titulo de grado.
   -------------------------------------------------------------------------------- 
  IF  o_tiene_orient <>  n_tiene_orient OR o_calculo_egreso <> n_calculo_egreso THEN

   IF EXISTS (SELECT ''
                FROM sga_planes
               WHERE sga_planes.unidad_academica = n_unidad_academica
                 AND sga_planes.carrera = n_carrera
                 AND sga_planes.plan = n_plan
                 AND sga_planes.fecha_ent_vigencia IS NOT NULL) THEN
      raise exception -746, 0, 'No se pueden modificar los títulos de planes activos.';
   END IF;
  END IF;

   -- Carga la tabla de log para auditoria
   INSERT INTO log_titulos_plan (
     unidad_academica,
     carrera,
     plan,
     titulo,
     tiene_orient,
     elige_orient,
     total_cred_egreso,
     calculo_egreso,
     suma_cred_act_ext,
     resol_ministerial,
     resol_coneau,
     normativa_instit, 	 
     usuario,
     fecha_act,
     oper)
   VALUES (
     n_unidad_academica,
     n_carrera,
     n_plan,
     n_titulo,
     n_tiene_orient,
     n_elige_orient,
     n_total_cred_egres,
     n_calculo_egreso,
     n_suma_cred_act_ex,
     n_resol_minist,
     n_resol_coneau,
     n_normativa_instit, 	 
     User,
     Current year to Second,
     'U');
END;
END PROCEDURE;
-- ********** Fin del procedure asociado al trigger de UPDATE de sga_titulos_plan **********

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Tabla sga_titulos_plan
-- Procedure personalizado uau_titulos_plan (asociado al trigger de UPDATE)
-- *******************************************************************************
-- DROP PROCEDURE uau_titulos_plan ;
-- CREATE PROCEDURE uau_titulos_plan (
--        o_unidad_academica like sga_titulos_plan.unidad_academica,
--        o_carrera like sga_titulos_plan.carrera,
--        o_plan like sga_titulos_plan.plan,
--        o_titulo like sga_titulos_plan.titulo,
--        o_tiene_orient like sga_titulos_plan.tiene_orient,
--        o_elige_orient like sga_titulos_plan.elige_orient,
--        o_total_cred_egres like sga_titulos_plan.total_cred_egreso,
--        o_calculo_egreso like sga_titulos_plan.calculo_egreso,
--        o_suma_cred_act_ex like sga_titulos_plan.suma_cred_act_ext,
--        o_resol_minist like sga_titulos_plan.resol_ministerial,
--        o_resol_coneau like sga_titulos_plan.resol_coneau,
--        o_normativa_instit like sga_titulos_plan.normativa_instit,
--        n_unidad_academica like sga_titulos_plan.unidad_academica,
--        n_carrera like sga_titulos_plan.carrera,
--        n_plan like sga_titulos_plan.plan,
--        n_titulo like sga_titulos_plan.titulo,
--        n_tiene_orient like sga_titulos_plan.tiene_orient,
--        n_elige_orient like sga_titulos_plan.elige_orient,
--        n_total_cred_egres like sga_titulos_plan.total_cred_egreso,
--        n_calculo_egreso like sga_titulos_plan.calculo_egreso,
--        n_suma_cred_act_ex like sga_titulos_plan.suma_cred_act_ext,
--        n_resol_minist like sga_titulos_plan.resol_ministerial,
--        n_resol_coneau like sga_titulos_plan.resol_coneau,
--        n_normativa_instit like sga_titulos_plan.normativa_instit)
-- BEGIN
--
--   -------------------------------------------------------------------------------- 
--   -- CODIGO PERSONALIZADO
--   -------------------------------------------------------------------------------- 
--
-- END;
-- END PROCEDURE;
-- **** Fin del procedure personalizado asociado al trigger de UPDATE de sga_titulos_plan ****
-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.04.0
-- Tabla sga_titulos_plan
-- Trigger de Update tu_titulos_plan
-- *******************************************************************************
-- DROP TRIGGER tu_titulos_plan ;
CREATE TRIGGER tu_titulos_plan UPDATE on sga_titulos_plan
referencing old as old new as new
FOR EACH ROW (
   EXECUTE PROCEDURE spu_titulos_plan (
     old.unidad_academica,
     old.carrera,
     old.plan,
     old.titulo,
     old.tiene_orient,
     old.elige_orient,
     old.total_cred_egreso,
     old.calculo_egreso,
     old.suma_cred_act_ext,
     old.resol_ministerial,
     old.resol_coneau,
     old.normativa_instit, 	 
     new.unidad_academica,
     new.carrera,
     new.plan,
     new.titulo,
     new.tiene_orient,
     new.elige_orient,
     new.total_cred_egreso,
     new.calculo_egreso,
     new.suma_cred_act_ext,
     new.resol_ministerial,
     new.resol_coneau,
     new.normativa_instit
	 )
--,

--   EXECUTE PROCEDURE uau_titulos_plan (
--     old.unidad_academica,
--     old.carrera,
--     old.plan,
--     old.titulo,
--     old.tiene_orient,
--     old.elige_orient,
--     old.total_cred_egreso,
--     old.calculo_egreso,
--     old.suma_cred_act_ext,
--     old.resol_ministerial,
--     old.resol_coneau,
--     old.normativa_instit, 	 
--     new.unidad_academica,
--     new.carrera,
--     new.plan,
--     new.titulo,
--     new.tiene_orient,
--     new.elige_orient,
--     new.total_cred_egreso,
--     new.calculo_egreso,
--     new.suma_cred_act_ext,
--     new.resol_ministerial,
--     new.resol_coneau,
--     new.normativa_instit) 	 

);
-- ********** Fin del trigger de Update tu_titulos_plan **********

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión  2.9.5
-- Procedure sp_resoltituloplan
--
-- Devuelve el número de resolucion del titulo/Plan a una fecha
--
-- *****************************************************************************
-- DROP PROCEDURE sp_resoltituloplan;
CREATE PROCEDURE sp_resoltituloplan (
	pUnidadAcademica LIKE sga_titulos_resol.unidad_academica , 
	pCarrera LIKE sga_titulos_resol.carrera , 
	pPlan LIKE sga_titulos_resol.plan, 
	pTitulo LIKE sga_titulos_resol.titulo, 
	pTipoResolucion LIKE sga_titulos_resol.tipo_resolucion,
	pFecha date)

RETURNING varchar(100);

-- Variables para el manejo de excepciones
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- Variables locales para utilizar en el sp.
DEFINE vc_NroResolucion LIKE sga_titulos_resol.nro_resolucion;
DEFINE vc_Fecha DATE;

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
	RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN
LET vc_NroResolucion = NULL;
LET vc_Fecha = NULL;

SELECT max(fecha_ent_vigencia) INTO vc_Fecha
  FROM sga_titulos_resol
WHERE unidad_academica = pUnidadAcademica
  AND carrera = pCarrera
  AND plan = pPlan
  AND titulo = pTitulo
  AND tipo_resolucion = pTipoResolucion
  AND fecha_ent_vigencia <= pFecha; 

IF DBINFO('sqlca.sqlerrd2') > 0 THEN
  SELECT nro_resolucion INTO vc_NroResolucion
    FROM sga_titulos_resol
   WHERE unidad_academica = pUnidadAcademica
     AND carrera = pCarrera
     AND plan = pPlan
     AND titulo = pTitulo
     AND tipo_resolucion = pTipoResolucion
     AND fecha_ent_vigencia = vc_Fecha;
END IF;	 

RETURN vc_NroResolucion;

END;
		
END PROCEDURE;
-- ********************** Fin del procedure sp_resoltituloplan **********************

GRANT EXECUTE ON sp_resoltituloplan TO public;


-- **************************************************************************
-- Stored Procedure: sp_ted_1e
-- Version 1.7.0
-- Ultima version de modificacion: 2.02.0, 2.03.0, 2.04.0, 2.6.0, 2.9.4, 2.9.5
-- Certificado Analitico del alumno.
-- **************************************************************************

DROP PROCEDURE sp_ted_1e;
CREATE PROCEDURE sp_ted_1e ( 
	pUA like sga_titulos_otorg.unidad_academica, 
	pNroInscripcion like sga_titulos_otorg.nro_inscripcion, 
	pTitulo like sga_titulos_otorg.titulo )

RETURNING
		varchar (5),		-- Unidad Academica
		varchar (20),		-- Nro. Expediente
		varchar (15),		-- Legajo
		varchar(120),		-- Nombre Universidad
		varchar(60),		-- Nombre Facultad
		varchar (5),		-- Carrera
		varchar (255),		-- Nombre Carrera
		varchar (5),		-- Plan
		date,			-- Fecha de resolución
		varchar(15),		-- Nro. Resolución Plan
		varchar(30),		-- Apellido
		varchar(30),		-- Nombres
		integer,		-- Tipo de documento
		varchar(15),		-- Nro. de documento
		varchar (10),		-- Nro. inscripcion
		date,			-- fecha de egreso
		varchar(200),	-- Fecha de egreso en letras
		float,			-- Promedio gral
		float,			-- Promedio sin aplazos (academico)
		varchar(255),		-- Nombre del título
		varchar(5),		-- Materia
		varchar(255),		-- Nombre Materia
		date,			-- Fecha
		varchar (5),		-- Nota
		varchar(15),		-- Concepto
		varchar(10),		-- Acta

		integer, 		-- vcActaPromocion,
		varchar(15), 		-- vcResolucionHA,
		varchar(30), 		-- vcFormaAprobacion,

		integer,		-- Folio
		varchar(2), 		-- Resultado
		varchar(3),		-- Tipo Doc. Descrip.
		integer,		-- duracion real
		integer,		-- tipo de copia (original, duplicado, etc)
		varchar(15),	-- Nro Resolucion Ministeriol del Titulo
		varchar(100),	-- Nro Resolucion MINISTERIAL del Titulo x Plan de Estudios
		varchar(100),	-- Nro Resolucion CONEAU del Titulo x Plan de Estudios
		varchar(255),	-- Nombre titulo nivel anterior habilitante
		varchar(255),   -- Nombre de la institucion del titulo de nivel anterior habilitante  
		char(1),        -- Define si la institucion del titulo de nivel anterior es de origen extranjero o nacional.
		char(1),        -- Tipo de Carrera por la que obtiene el titulo.
		varchar(150);    -- Titulo Anterior habilitante - Situacion Convalidacion y Nro de Resolucion. - Solo titulos extranjeros.



DEFINE  vcExpedienteNro     varchar(20);
DEFINE  vcLegajo            varchar(15);
DEFINE  vcUnivNombre        varchar(120);
DEFINE  vcFacultadNombre    varchar(60);
DEFINE  vcCarrera           varchar(5);
DEFINE  vcCarreraNombre     varchar(255);
DEFINE  vcPlan, vcPlanHA              varchar(5);
DEFINE  vcPlanVersion, vcPlanVersionHA       varchar(5);
DEFINE  dResolucionFecha    date;
DEFINE  vcApellido          varchar(30);
DEFINE  vcNombre            varchar(30);
DEFINE  iDocTipo            integer;
DEFINE  iDocNro             varchar(15);
DEFINE  vcInscripcionNro    varchar(10);
DEFINE  dEgresoFecha, dFechaEgresoTA    date;
DEFINE  fPromGral           float;
DEFINE  fPromSinAplazos     float;
DEFINE  vcTituloNombre     varchar(255);
DEFINE  vcMateria           varchar(5);
DEFINE  vcMateriaNombre     varchar(255);
DEFINE  dFecha              date;
DEFINE  vcNota              varchar(5);
DEFINE  vcConcepto          varchar(15);
DEFINE  vcActa              varchar(10);
DEFINE  vcActaTipo          varchar(1);
DEFINE  iFolio              integer;
DEFINE  vcResultado         varchar(2);
DEFINE  vcDocTipoDescrip    varchar(3);
DEFINE  iEscalaExamen       integer;
DEFINE  vcFormaAprobacion   varchar(30);
DEFINE  vcActaPromocion     integer;
DEFINE  vcResolucionHA     varchar(15);
DEFINE	iDuracionReal	    integer;
DEFINE	iTipoCopia          integer;
DEFINE  vcResolucionPlan, vcResolucionTitulo, vcResolMinistTit varchar(15);
DEFINE  vcResolMinisterialTP, vcResolConeauTP   varchar(100);  -- Nro de resolucion ministerial y coneau del titulo en el plan de estudios.
DEFINE  vcTituloHab, vcInstitucionHab  varchar(255);
DEFINE  vcFechaEgresoLetras  varchar(200);
DEFINE  vcInstHabesExt, vcTipoTitulo char(1);
DEFINE vcTipoCarrera LIKE sga_carreras.tipo_de_carrera;
DEFINE iLocalidad integer;
DEFINE vdFechaIngreso LIKE sga_alumnos.fecha_ingreso;
DEFINE vcSexo char(1);

-- Situacion titulo anterior habilitante.
DEFINE vcSituacionConvTitAnt varchar(150);
DEFINE viSituacionConvTitAnt integer;
DEFINE vcResolConvTitAnt varchar(100);


DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(255);

ON EXCEPTION SET sql_err, isam_err, error_info
	  raise exception sql_err, isam_err, 'Error en el certificado ted1e: ' || error_info;
END EXCEPTION;

BEGIN

LET vcResolucionTitulo   = ''; -- Nro de resolucion del titulo del analítico.
LET vcResolMinistTit     = ''; -- Nro de resolucion Ministerial del titulo del analítico.
LET vcTituloHab          = ''; -- Nombre del titulo habilitante para ingreso en la carrera
LET vcInstitucionHab     = ''; -- Nombre de la institucion que otorgó el titulo habilitante para ingreso en la carrera del nivel anterior
LET vcResolMinisterialTP = ''; -- Nro de resolucion MINISTERIAL del titulo en el plan de estudios.
LET vcResolConeauTP      = ''; -- Nro de resolucion CONEAU del titulo en el plan de estudios.
LET vcFechaEgresoLetras        = '';
LET vcInstHabesExt       = 'N'; -- La institucion que otorgo el titulo habilitante no es una institucion extranjera
LET iLocalidad           = NULL;
LET vcSituacionConvTitAnt  = NULL;
LET viSituacionConvTitAnt  = NULL;
LET vcResolConvTitAnt = NULL;

--------------------------------------------------------------
-- Datos del título
--------------------------------------------------------------
 SELECT sga_titulos_otorg.carrera,
        sga_titulos_otorg.legajo,
        sga_titulos_otorg.nro_expediente,
        sga_titulos_otorg.fecha_egreso,
        sga_titulos_otorg.prom_general,
        sga_titulos_otorg.prom_sin_aplazos,
        sga_titulos_otorg.plan,
        sga_titulos_otorg.duracion_carrera,
        sga_titulos_otorg.tipo_copia
   INTO vcCarrera,
        vcLegajo,
        vcExpedienteNro,
        dEgresoFecha,
        fPromGral,
        fPromSinAplazos,
        vcPlan,
        iDuracionReal,
        iTipoCopia
   FROM sga_titulos_otorg
  WHERE sga_titulos_otorg.unidad_academica = pUA
    AND sga_titulos_otorg.titulo = pTitulo
    AND sga_titulos_otorg.nro_inscripcion = pNroInscripcion ;

	
  -- Paso la fecha de egreso a texto
  LET vcFechaEgresoLetras = sp_fecha_a_texto(dEgresoFecha, 2);
  
  
--------------------------------------------------------------
-- Descripcion de la Universidad.
--------------------------------------------------------------
 SELECT sga_unidades_acad.nombre_universidad,
        sga_unidades_acad.nombre
   INTO vcUnivNombre,
        vcFacultadNombre
   FROM sga_unidades_acad
  WHERE sga_unidades_acad.unidad_academica = pUA;


--------------------------------------------------------------
-- Descripcion de la carrera
--------------------------------------------------------------
 SELECT nombre, tipo_de_carrera
   INTO vcCarreraNombre, vcTipoCarrera
   FROM sga_carreras
  WHERE unidad_academica = pUA
    AND carrera = vcCarrera ;


--------------------------------------------------------------
-- Descripcion del Plan
--------------------------------------------------------------
 SELECT sga_planes.fecha_resolucion, sga_planes.nro_resolucion, sga_planes.version_actual
   INTO dResolucionFecha, vcResolucionPlan, vcPlanVersion
   FROM sga_planes
  WHERE sga_planes.unidad_academica = pUA
    AND sga_planes.carrera = vcCarrera
    AND sga_planes.plan = vcPlan ;

--------------------------------------------------------------
-- Datos de la persona
--------------------------------------------------------------
 SELECT apellido, nombres, tipo_documento, nro_documento, nro_inscripcion, sexo  
   INTO vcApellido, vcNombre, iDocTipo, iDocNro, vcInscripcionNro, vcSexo
   FROM sga_personas
  WHERE unidad_academica = pUA
    AND nro_inscripcion = pNroInscripcion ;

 SELECT mdp_tipo_documento.desc_abreviada
   INTO vcDocTipoDescrip
   FROM mdp_tipo_documento
  WHERE mdp_tipo_documento.tipo_documento = iDocTipo ;

--------------------------------------------------------------
-- Datos del titulo del analitico
--------------------------------------------------------------
 SELECT (CASE WHEN vcSexo = '1' THEN nombre WHEN vcSexo = '2' THEN nombre_femenino ELSE '' END), tipo_de_titulo, NVL(nro_resolucion,''), NVL(nro_res_minist,'')
   INTO vcTituloNombre, vcTipoTitulo, vcResolucionTitulo, vcResolMinistTit
   FROM sga_titulos
  WHERE unidad_academica = pUA
    AND titulo = pTitulo ;


  SELECT fecha_ingreso INTO vdFechaIngreso 
      FROM sga_alumnos
   WHERE unidad_academica = pUA
        AND carrera = vcCarrera
        AND legajo = vcLegajo;

  LET vcResolMinisterialTP = sp_resoltituloplan(pUA, vcCarrera, vcPlan, pTitulo, 'M', vdFechaIngreso); 
  LET vcResolConeauTP  = sp_resoltituloplan(pUA, vcCarrera, vcPlan, pTitulo, 'C', vdFechaIngreso); 		
	
--------------------------------------------------------------
-- Datos del titulo habilitante e Institucion (Nivel anterior)
--------------------------------------------------------------
/*
G	Título de Grado Universitario
P	Pre-Grado
T	Terciario

D	Doctorado
M	Maestría
E	Especialización
S	Postítulo
W	POSTG

TIPOS DE CARRERA
C	Carrera de grado
I	Curso de ingreso
B	Ciclo básico o común
E	Extracurriculares
V	Vocacional
R	Pre-Grado
T	Terciario
S	Postítulo
P	Posgrado

*/

-- IF vcTipoTitulo = 'G' OR vcTipoTitulo = 'P' OR vcTipoTitulo = 'T' THEN
IF vcTipoCarrera <> 'P' THEN

  -- Si no es una carrera de Posgrado entonces se informa el titulo secundario y la institucion
  SELECT sga_coleg_sec.nombre, sga_titulos_sec.descripcion, sga_coleg_sec.localidad, 
                 sga_personas.tit_sec_sit_conv, sga_personas.tit_sec_nro_resol
    INTO vcInstitucionHab, vcTituloHab, iLocalidad, viSituacionConvTitAnt, vcResolConvTitAnt
   FROM sga_personas,
        OUTER sga_coleg_sec,
        OUTER sga_titulos_sec
  WHERE sga_personas.unidad_academica     = pUA
    AND sga_personas.nro_inscripcion      = pNroInscripcion 
    AND sga_coleg_sec.colegio             = sga_personas.colegio_secundario
    AND sga_titulos_sec.titulo_secundario = sga_personas.titulo_secundario;

   IF iLocalidad IS NOT NULL THEN 
        -- Busco el pais al que pertenece el colegio si es de un pais extranjero o nacional.
        SELECT (CASE  WHEN prov.pais <> 54 THEN 'S' ELSE 'N' END) 
             INTO vcInstHabesExt
             FROM mug_localidades as l,
                        mug_dptos_partidos as dp,
                        mug_provincias as prov
            WHERE l.localidad = iLocalidad 
              AND l.dpto_partido = dp.dpto_partido
              AND prov.provincia = dp.provincia;
   END IF;

ELSE

  -- Si son carreras de posgrado se informa un titulo de grado y la institucion
  -- Toma el título con fecha de egreso mas reciente
  FOREACH SELECT 
                 sga_formacion_acad.fecha_egreso ,
                 sga_instituciones.nombre, sga_titulos_super.nombre, 
                 CASE 
                   WHEN sga_instituciones.pais IS NOT NULL AND sga_instituciones.pais <> 54 THEN 'S'  -- Es institucion extranjera
                   ELSE 'N' 
                 END,
                 titulo_ant_revconv,
                 nro_resol_ministerio
            INTO dFechaEgresoTA, vcInstitucionHab, vcTituloHab, vcInstHabesExt, viSituacionConvTitAnt, vcResolConvTitAnt
            FROM sga_formacion_acad,
                 sga_titulos_super,
                 OUTER sga_instituciones
           WHERE sga_formacion_acad.unidad_academica = pUA
                 AND sga_formacion_acad.nro_inscripcion  = pNroInscripcion 
                 AND sga_titulos_super.titulo_superior   = sga_formacion_acad.titulo_superior
                 AND sga_instituciones.institucion       = sga_formacion_acad.institucion
           ORDER BY sga_formacion_acad.fecha_egreso DESC

    -- Salgo cuando recuperó el 1er dato salgo.
    EXIT FOREACH;
  END FOREACH;  

END IF; -- Fin datos titulo anterior habilitante

IF vcInstitucionHab IS NULL THEN
   LET vcInstitucionHab = '';
END IF;
IF vcTituloHab IS NULL THEN
  LET vcTituloHab = '';
END IF;

-- Situacion de convalidacion/reconocimiento de titulo anterior habilitante cuando es de pais extranjero
IF vcInstHabesExt = 'S' THEN
   IF viSituacionConvTitAnt  = 1 THEN
         LET vcSituacionConvTitAnt = 'Convalidado' ;
   ELIF viSituacionConvTitAnt  = 2 THEN
         LET vcSituacionConvTitAnt = 'Revalidado';
   ELIF viSituacionConvTitAnt  = 3 THEN
         LET vcSituacionConvTitAnt = 'No Revalidado-Convalidado';
   ELIF viSituacionConvTitAnt  = 4 THEN
         LET vcSituacionConvTitAnt = 'Reconocimiento';
   ELIF viSituacionConvTitAnt  = 5 THEN
         LET vcSituacionConvTitAnt = 'Convalidación Provisoria';
   ELSE
         LET vcSituacionConvTitAnt = '';
   END IF;
   
   IF viSituacionConvTitAnt  <> 3 AND vcResolConvTitAnt IS NOT NULL THEN
         LET vcSituacionConvTitAnt = vcSituacionConvTitAnt || ' - ' || vcResolConvTitAnt;
   END IF;


END IF;

-- ------------------------ Fin Datos -------------------------

-- Elimino la tablas temporales!
  BEGIN

     ON EXCEPTION IN (-206)
     END EXCEPTION WITH RESUME;
     DROP TABLE  temp_mat_titulo;
  END;

-- Tabla temporal de Materias del Título-Plan-Version del alumno que son promediables
CREATE  TEMP TABLE temp_mat_titulo (materia varchar(5)) WITH NO LOG;

INSERT INTO temp_mat_titulo (materia)
SELECT DISTINCT vw_sga_mat_plan.materia
   FROM vw_sga_mat_plan,
	sga_atrib_mat_plan
    WHERE vw_sga_mat_plan.unidad_academica        = pUA
     AND vw_sga_mat_plan.carrera        = vcCarrera
     AND vw_sga_mat_plan.plan           = vcPlan
     AND vw_sga_mat_plan.version        = vcPlanVersion
     AND vw_sga_mat_plan.titulo         = ptitulo
     AND sga_atrib_mat_plan.unidad_academica = vw_sga_mat_plan.unidad_academica
     AND sga_atrib_mat_plan.carrera          = vw_sga_mat_plan.carrera
     AND sga_atrib_mat_plan.plan             = vw_sga_mat_plan.plan
     AND sga_atrib_mat_plan.version          = vw_sga_mat_plan.version
     AND sga_atrib_mat_plan.materia          = vw_sga_mat_plan.materia;

--------------------------------------------------------------
-- Barro la vista de historia academica.
-- Recupera TODAS las materias aprobadas o reprobadas por el alumno
-- de TODOS LOS PLANES de la carrera en la que el alumno tiene registro.
--------------------------------------------------------------
FOREACH SELECT
        vw_hist_academica.materia,
        vw_hist_academica.fecha,
        vw_hist_academica.nota,
        vw_hist_academica.escala_notas,
        TRIM(vw_hist_academica.forma_aprobacion),
        vw_hist_academica.tipo_acta,
        vw_hist_academica.acta,
        vw_hist_academica.acta_promocion,
        vw_hist_academica.nro_resolucion,
        vw_hist_academica.resultado,
        vw_hist_academica.plan,
        vw_hist_academica.version
   INTO vcMateria,
        dFecha,
        vcNota,
        iEscalaExamen,
        vcFormaAprobacion,
        vcActaTipo,
        vcActa,
        vcActaPromocion,
        vcResolucionHA,
        vcResultado,
        vcPlanHA,
        vcPlanVersionHA
   FROM vw_hist_academica
  WHERE vw_hist_academica.unidad_academica = pUA
    AND vw_hist_academica.carrera = vcCarrera
    AND vw_hist_academica.legajo = vcLegajo
    AND vw_hist_academica.materia IN (select materia from temp_mat_titulo)

      -- Nombre de la Materia en el Plan-Version Actual del Alumno
      SELECT sga_atrib_mat_plan.nombre_materia
        INTO vcMateriaNombre
        FROM sga_atrib_mat_plan
       WHERE sga_atrib_mat_plan.unidad_academica = pUA
         AND sga_atrib_mat_plan.carrera = vcCarrera
         AND sga_atrib_mat_plan.plan    = vcPlan
         AND sga_atrib_mat_plan.version = vcPlanVersion
         AND sga_atrib_mat_plan.materia = vcMateria ;

   -- La materia no existe en el Plan-Version Actual del Alumno
   IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
	-- Recupero el nombre de la materia en el Plan que la aprobo!
	SELECT sga_atrib_mat_plan.nombre_materia
	INTO vcMateriaNombre
	FROM sga_atrib_mat_plan
	WHERE sga_atrib_mat_plan.unidad_academica = pUA
	AND sga_atrib_mat_plan.carrera = vcCarrera
	AND sga_atrib_mat_plan.plan    = vcPlanHA
	AND sga_atrib_mat_plan.version = vcPlanVersionHA
	AND sga_atrib_mat_plan.materia = vcMateria ;
   END IF;

      -- Escala de Notas
      SELECT sga_det_escala.concepto
        INTO vcConcepto
        FROM sga_det_escala
       WHERE sga_det_escala.escala_notas = iEscalaExamen
         AND sga_det_escala.nota = vcNota ;

   LET iFolio = NULL;

   -- Aprobado por Examen
   IF   vcFormaAprobacion = 'Examen' OR vcFormaAprobacion =  'Examen equivalente' THEN
      -- Folio Examen.
      SELECT sga_detalle_acta.folio
        INTO iFolio
        FROM sga_detalle_acta
       WHERE sga_detalle_acta.unidad_academica = pUA
         AND sga_detalle_acta.tipo_acta = vcActaTipo
         AND sga_detalle_acta.acta      = vcActa
         AND sga_detalle_acta.carrera   = vcCarrera
         AND sga_detalle_acta.legajo    = vcLegajo ;
   END IF;

   -- Aprobado por Promocion
   IF   vcFormaAprobacion = 'Promoción' OR vcFormaAprobacion =  'Promoción en otra carrera' THEN
         SELECT sga_det_acta_promo.folio
           INTO iFolio
           FROM sga_det_acta_promo
          WHERE sga_det_acta_promo.unidad_academica = pUA
            AND sga_det_acta_promo.carrera   = vcCarrera
            AND sga_det_acta_promo.legajo    = vcLegajo
            AND sga_det_acta_promo.acta      = vcActaPromocion ;
  END IF;

  RETURN pUA,vcExpedienteNro,vcLegajo,vcUnivNombre,vcFacultadNombre,vcCarrera,	vcCarreraNombre, vcPlan, dResolucionFecha, vcResolucionPlan, 
         vcApellido, vcNombre, iDocTipo, iDocNro, vcInscripcionNro, dEgresoFecha, vcFechaEgresoLetras, fPromGral, fPromSinAplazos, vcTituloNombre,
         vcMateria, vcMateriaNombre, dFecha, vcNota, vcConcepto, vcActa, vcActaPromocion, vcResolucionHA, vcFormaAprobacion, iFolio, 
         vcResultado, vcDocTipoDescrip, iDuracionReal, iTipoCopia, vcResolMinistTit, vcResolMinisterialTP, vcResolConeauTP, 
         vcTituloHab, vcInstitucionHab, vcInstHabesExt, vcTipoCarrera, vcSituacionConvTitAnt
         WITH RESUME ; 

END FOREACH;

   -- Elimino la tablas temporales!
  BEGIN
     ON EXCEPTION IN (-206)
     END EXCEPTION WITH RESUME;
     DROP TABLE  temp_mat_titulo;
  END;

END;
END PROCEDURE;
-- ************************** FIN DEL PROCEDURE sp_ted_1e **************************

GRANT EXECUTE ON sp_ted_1e TO public;

-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 2.9.5
-- *******************************************************************************
Execute procedure dba.sui_ventanas( 'w_abm_resolucion_titulo_plan' );

-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 2.9.5
-- *******************************************************************************
Execute procedure dba.sui_operaciones( 'car00036', 'Alta de Resolución Ministerial por Título/Plan', null, null );
INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior ) VALUES ( 'car00036', 1, 'w_abm_lista_seleccion', 'uo_dw, dk_titulos_plan_resolucion, 10', 'N' );
INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior ) VALUES ( 'car00036', 2, 'w_abm_resolucion_titulo_plan', 'uo_dw, d_titulo_plan_resolucion, 1', 'N' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'car00036', 'C' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'car00036', 'M' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'car00036', 'A' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'car00036', 'B' );

-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 2.09.5  
-- *******************************************************************************
INSERT INTO dba.acc_operacion_mod ( modulo, operacion, submodulo, orden ) VALUES ( '00000005', 'car00036', 'Titulos', 90 );


-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
INSERT INTO app_versiones ( version, fecha_generacion, fecha_actualiz, script_corrido )
     VALUES ( "CNV2.09.5" , TODAY, CURRENT YEAR TO SECOND, 1);
-- *************************************************************************************
-- *************************************************************************************
-- Verifico que se haya corrido script anterior
EXECUTE PROCEDURE sp_soy_dba();
EXECUTE PROCEDURE sp_validar_scripts('CNV2.09.5', 1);
-- *************************************************************************************

-- **********************************************************************
-- Version: 1.3
-- Proceso: sp_crea_actaprom
-- Ultima version de modificacion: 2.03.0, 2.5.1, 2.6.1, 2.9.4, 2.9.5
--
-- Crea Acta de Promocionales
-- Solo si existe un Acta de Regulares Abierto para esta Comisión
-- Sino debe generarse 2ro el Acta de Regulares
-- 
-- Por cada inscripcion con calidad de Inscripcion = P (para promocionar)
-- actualiza el campo "promocional" en la tabla de cursadas pendientes.
-- Si alguno de estos alumnos tiene el Resultado o la Nota cargada no Genera el 
-- Acta de Promocion.
-- 
-- Recibe:   - Unidad Academica
--	     - Comision
--	     - Libro de Actas (Puede venir en Nulo)
--
-- Retorna:  Integer	- Numero de Acta de Promocionales (puede no haberse generado este Acta)
-- **********************************************************************
DROP PROCEDURE sp_crea_actaprom;
CREATE PROCEDURE sp_crea_actaprom 
   (p_unidad_academica  LIKE sga_insc_cursadas.unidad_academica,
    p_comision LIKE sga_insc_cursadas.comision ,
    p_libro    LIKE  sga_actas_cursado.libro,
    p_nro_acta	integer)
    returning integer;

  DEFINE sql_err , isam_err int;
  DEFINE error_info varchar(70);
  DEFINE cnt_insc, cnt_reng_por_folio, cnt_carreras smallint;
  DEFINE lescala_notas LIKE sga_actas_promo.escala_notas;
  DEFINE v_unidad_academica like sga_alumnos.unidad_academica;
  DEFINE v_carrera, lcarrera like sga_alumnos.carrera;
  DEFINE v_legajo like sga_alumnos.legajo;
  DEFINE v_libro_actapromo    LIKE  sga_libros_actacur.libro;
  DEFINE ifolio_prom, irenglon_prom, ifolio_reg, irenglon_reg INTEGER;
  
  on exception set sql_err, isam_err, error_info
     -- error
    Rollback Work;
    raise exception  sql_err, isam_err, error_info;
  end exception;

-- Comienzo la transaccion
BEGIN WORK;
   ---------------------------------------------------------------
   -- Controlo que no exista un Acta de Regulares o Promocionales para la Comision,
   -- o Rectificativas de Promocion
   ---------------------------------------------------------------
   IF (SELECT COUNT(*)   FROM sga_actas_cursado
	WHERE comision         = p_comision 
	 AND  estado = 'A') <> 1 THEN
	raise exception -746,0,'Debe existir un Acta de Regulares abierta para esta comisión';
   END IF;	   

   IF (SELECT COUNT(*)   FROM sga_actas_promo
	WHERE comision  = p_comision 
	 AND  estado <> 'B') > 0 THEN
	raise exception -746,0,'Ya existe un Acta de Promocionales para esta Comisión';
   END IF;	   


   -- Controlo que no existan cargados resultados y o alumnos con Notas de Promoción Cargadas
   IF (SELECT COUNT(sga_insc_cursadas.comision) FROM sga_insc_cursadas
	  WHERE sga_insc_cursadas.comision = p_comision
	    AND sga_insc_cursadas.calidad_insc = 'P'
	    AND EXISTS (SELECT '' FROM sga_curs_pendiente
			WHERE sga_curs_pendiente.unidad_academica  = sga_insc_cursadas.unidad_academica
			 AND sga_curs_pendiente.carrera  = sga_insc_cursadas.carrera
			 AND sga_curs_pendiente.legajo  = sga_insc_cursadas.legajo
			 AND sga_curs_pendiente.comision  = sga_insc_cursadas.comision
			 AND (sga_curs_pendiente.resultado IS NOT NULL AND sga_curs_pendiente.resultado = 'P')
			 )
		) > 0 THEN
	
			-- AND (sga_curs_pendiente.resultado IS NOT NULL OR sga_curs_pendiente.nota IS NOT NULL))) > 0 THEN
	raise exception -746,0,'Hay alumnos Promocionales con Resultado cargado.';
   END IF;	   

  -----------------------------------------------------------     		
  -- Selecciono la cantidad de renglones definidos por por folio para un Acta de cursados
  -----------------------------------------------------------     		
   Execute procedure sp_param_sistema ('lineas_folio_acta_cursados') INTO cnt_reng_por_folio;

  -- Error
  IF cnt_reng_por_folio IS NULL or cnt_reng_por_folio <= 0 THEN		
    raise exception -746,0,'Debe setear la cantidad de renglones por folio en los parametros';
  END IF;

  -- Recupero la Carrera y la Escala de Notas del Acta de cursados.
  -- Se supone que solamente debe existir una abierta y que fue generada anteriormente
  -- a esta, aunque no debe estar cerrada.
  SELECT carrera INTO lcarrera
	FROM sga_actas_cursado 
	WHERE unidad_academica = p_unidad_academica
	  AND comision = p_comision
	  AND estado = 'A';

    IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
        -- No debería pasar
       raise exception -746,0,'Error al recuperar la Carrera definida  en el Acta de Regulares.';
    END IF;

  -- Escala de Notas de la Comision
  LET lescala_notas = NULL;	
  SELECT escala_notas INTO lescala_notas 
	FROM sga_comisiones
	WHERE comision = p_comision;
    IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
       raise exception -746,0,'Error al recuperar la escala de notas de la comisión.';
    END IF;

   -- La escala de notas de la comision debe tener notas con resultado = P (Promoción)
   IF (SELECT COUNT(*) FROM sga_det_escala
	WHERE escala_notas = lescala_notas
	AND resultado = 'P') <= 0 THEN
	-- la escala de notas se recupero de la escala de notas de la comision
	raise exception -746,0,'La Escala de Notas de la comisión no tiene notas de Promoción.';
   END IF;

   -- *********************************  GENERO CABECERA DEL ACTA *********************************************
   IF p_libro IS NULL THEN
     	Execute procedure sp_libroactapromo(p_comision, 'P')  INTO v_libro_actapromo;
   END IF;

   IF p_nro_acta IS NULL or p_nro_acta = 0 THEN
	     -- Recupero el Nro de Acta para Actas de Promocionales
	     Execute procedure sp_nro_acta_prom(p_unidad_academica , p_comision, 'P', v_libro_actapromo)  INTO p_nro_acta;
	     IF p_nro_acta IS NULL or p_nro_acta = 0 THEN		
	         raise exception -746,0,'Error al generar el número de Acta de Promocionales.';
	     END IF;
   END IF;

      INSERT INTO sga_actas_promo
         (unidad_academica,  acta,   tipo,  comision,  carrera, libro, escala_notas,   
           fecha_generacion,  version,  version_impresa, nro_ultima_copia, renglones_folio, estado)  
         VALUES (p_unidad_academica, p_nro_acta, 'P', p_comision, lcarrera,  v_libro_actapromo, lescala_notas, 
	TODAY,  1,  0, 0, cnt_reng_por_folio, 'A');

   -- *********************************  Fin generacion cabecera del Acta *********************************************
   
   -- Actualizo el Campo promocional en Cursadas Pendientes donde en la inscripcion
   -- figura como Promocional.
   FOREACH SELECT unidad_academica, carrera, legajo 
		INTO v_unidad_academica, v_carrera, v_legajo 
		FROM sga_insc_cursadas
		WHERE sga_insc_cursadas.comision = p_comision		
		AND sga_insc_cursadas.calidad_insc = 'P'
	
	UPDATE  sga_curs_pendiente
		SET sga_curs_pendiente.promocional = 'S'
		WHERE sga_curs_pendiente.unidad_academica = v_unidad_academica 
		AND  sga_curs_pendiente.carrera = v_carrera
		AND  sga_curs_pendiente.legajo = v_legajo
		AND  sga_curs_pendiente.comision = p_comision;
   END FOREACH;

   -- Actualizo en Cursada Pendiente, todos las filas donde el campo promocional = 'S' con el nro de Acta de Promocion
   UPDATE sga_curs_pendiente
	SET acta_promocion = p_nro_acta
	WHERE  comision = p_comision
	   AND promocional = 'S';


   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- Asigno folio y renglon del acta de promocion a los alumnos promocionales
   -- Tomo el mismo orden que los alumnos del acta de cursadas.
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- Borro la tabla temporal si es que existe.
   BEGIN 
      on exception in (-206)
         -- Tabla no existe continuo el proceso	
      end exception with resume;
      DROP TABLE temp_foliado;	
   END 

   -- Recupero los alumnos promocionales
   SELECT unidad_academica, carrera, legajo,folio_regular, renglon_regular
     FROM sga_curs_pendiente  
    WHERE comision = p_comision
      AND promocional = 'S'
      AND acta_promocion = p_nro_acta 
   INTO TEMP temp_foliado WITH NO LOG;

   IF DBINFO("sqlca.sqlerrd2") > 0 THEN
      LET ifolio_prom = 1;
      LET irenglon_prom = 1;

      -- Recorro los alumnos promocionales y les asigno folio y renglon.
      FOREACH SELECT unidad_academica, carrera, legajo, folio_regular, renglon_regular
                INTO v_unidad_academica, v_carrera, v_legajo, ifolio_reg, irenglon_reg
                FROM temp_foliado
              ORDER BY folio_regular, renglon_regular

         -- Actualizo folio y renglon
         UPDATE sga_curs_pendiente
            SET folio_promocion = ifolio_prom,
                renglon_promocion = irenglon_prom
          WHERE comision = p_comision
            AND unidad_academica = v_unidad_academica
            AND carrera = v_carrera
            AND legajo = v_legajo
            AND acta_promocion = p_nro_acta; 

         -- incremento el renglon
         LET irenglon_prom = irenglon_prom + 1;

         -- evaluo el máximo de renglones por folio
	 IF cnt_reng_por_folio < irenglon_prom THEN
            LET ifolio_prom   = ifolio_prom + 1;
            LET irenglon_prom = 1;
         END IF;

      END FOREACH;
      -- Borro tabla temporal
      DROP TABLE temp_foliado;
   END IF; 
   -- ++++++++++++++++++++++++ Fin asignacion folio y renglon a alumnos del acta de promocion


-- Si todo esta correcto realizo el Commit work
COMMIT WORK;

RETURN p_nro_acta;

End procedure;
-- ******************* Fin del procedure sp_crea_actaprom **************************

GRANT EXECUTE ON sp_crea_actaprom TO public;

-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
INSERT INTO app_versiones ( version, fecha_generacion, fecha_actualiz, script_corrido )
     VALUES ( "CNV2.09.5" , TODAY, CURRENT YEAR TO SECOND, 2);
-- *************************************************************************************
-- *************************************************************************************
-- Verifico que se haya corrido script anterior
EXECUTE PROCEDURE sp_soy_dba();
EXECUTE PROCEDURE sp_validar_scripts('CNV2.09.5', 2);
-- *************************************************************************************


ALTER TABLE sga_titulos_sec MODIFY descripcion varchar(255) NOT NULL;
ALTER TABLE log_titulos_sec MODIFY descripcion varchar(255) NOT NULL;

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.7.0
-- Ultima Version de modificación 2.03.0, 2.8.0, 2.9.5
-- Procedure sp_FichAluDatPer
--
-- Modificado version xxx, para que devuelva la fecha de actualización y el último domicilio declarado.
-- 
-- Consulta los datos personales de una persona en la unidad academica.
-- *****************************************************************************

DROP PROCEDURE sp_FichAluDatPer;
CREATE PROCEDURE sp_FichAluDatPer ( pUA LIKE sga_personas.unidad_academica, pNroInscripcion LIKE sga_personas.nro_inscripcion )
       RETURNING 
		varchar(5), varchar(10), varchar(30), varchar(30), varchar(15), date, integer, decimal(15,0), 
		integer, integer, varchar(3), varchar(40), varchar(255), varchar(12), varchar(50), varchar(5), 
		varchar(3), varchar(5), varchar(3), integer, varchar(18), varchar(50), varchar(18), varchar(15), 
		varchar(100), varchar(60), varchar(30), varchar(10), varchar(100), varchar(60), varchar(60), 
		varchar(60), varchar(100), varchar(100), varchar(60), varchar(60), varchar(60);

-- Descripcion del Return:
-- varchar(5),    -- vc_UA
-- varchar(10),   -- vc_NroInscripcion
-- varchar(30),   -- vc_Apellido
-- varchar(30),   -- vc_Nombres
-- varchar(15),   -- vc_NroDocumento
-- date,          -- vd_FechaInscrip
-- integer,       -- vi_AnioIng
-- decimal(15,0), -- vc_NroCi
-- integer,       -- vc_EmisorCi
-- integer,       -- vc_TituloSec
-- varchar(3),    -- vc_TipoDocDesAbre
-- varchar(40),   -- vc_EmisorCiDesc
-- varchar(255),   -- vc_TituloSecDesc
-- varchar(12),   -- vc_fecha_actualiza
-- varchar(50),   -- vc_CallePl
-- varchar(5),    -- vc_NumeroPl
-- varchar(3),    -- vc_PisoPl
-- varchar(5),    -- vc_DptoPl
-- varchar(3),    -- vc_UnidadPl
-- integer,       -- vc_LocalidadPl

-- varchar(18),   -- vc_TelefonoPl
-- varchar(50),  --vc_E_mail
--varchar(18),  --vc_Celular_numero
--varchar(15),  --vc_Celular_compania

-- varchar(100),  -- vc_LocalidadNombre
-- varchar(60);   -- vc_ProvinciaNombre

-- varchar(30) -- nacionalidad
-- varchar(10) -- fecha de nacimiento
-- varchar(100) -- localidad nacimiento
-- varchar(60) -- dpto/partido nacimiento
-- varchar(60) -- provincia nacimiento
-- varchar(60) -- pais nacimiento

-- varchar(100) -- nombre colegio
-- varchar(100) -- localidad colegio
-- varchar(60) -- dpto/partido colegio
-- varchar(60) -- provincia colegio
-- varchar(60) -- pais colegio

-- variables.
DEFINE vc_UA              LIKE sga_personas.unidad_academica;
DEFINE vc_NroInscripcion  LIKE sga_personas.nro_inscripcion;
DEFINE vc_Apellido        LIKE sga_personas.apellido;
DEFINE vc_Nombres         LIKE sga_personas.nombres;
DEFINE vc_NroDocumento    LIKE sga_personas.nro_documento;
DEFINE vd_FechaInscrip    LIKE sga_personas.fecha_inscripcion;
DEFINE vi_AnioIng         INTEGER;
DEFINE vc_NroCi           LIKE sga_personas.nro_ci;
DEFINE vc_EmisorCi        LIKE sga_personas.ent_emisora_ci;
DEFINE vc_TituloSec       LIKE sga_personas.titulo_secundario;
DEFINE vc_TipoDocDesAbre  LIKE mdp_tipo_documento.desc_abreviada;
DEFINE vc_EmisorCiDesc    LIKE sga_entes_emis_ci.descripcion;
DEFINE vc_TituloSecDesc   LIKE sga_titulos_sec.descripcion;
DEFINE vc_fecha, vc_FechaMax   LIKE sga_datos_censales.fecha_relevamiento;

-- DEFINE vc_Periodos        LIKE sga_periodo_insc.periodo_inscripcio;
DEFINE vd_fecha_actualiza        LIKE sga_datos_censales.fecha_actualiz;
DEFINE vc_fecha_actualiza varchar(12);

DEFINE vc_CallePl         LIKE sga_datos_censales.calle_per_lect;
DEFINE vc_NumeroPl        LIKE sga_datos_censales.numero_per_lect;
DEFINE vc_PisoPl          LIKE sga_datos_censales.piso_per_lect;
DEFINE vc_DptoPl          LIKE sga_datos_censales.dpto_per_lect;
DEFINE vc_UnidadPl        LIKE sga_datos_censales.unidad_per_lect;
DEFINE vc_LocalidadPl     LIKE sga_datos_censales.loc_per_lect;

DEFINE vc_TelefonoPl      LIKE sga_datos_censales.te_per_lect;
DEFINE vc_E_mail     LIKE sga_datos_censales.e_mail;
DEFINE vc_Celular_numero LIKE sga_datos_cen_aux.celular_numero;
DEFINE vc_Celular_compania LIKE mdp_celular_comp.nombre;

DEFINE vc_LocalidadNombre LIKE mug_localidades.nombre_abreviado;
DEFINE vc_ProvinciaNombre LIKE mug_provincias.nombre;

DEFINE vc_nac_pers varchar(30);
DEFINE vi_col_sec LIKE sga_personas.colegio_secundario;
DEFINE vi_loc_nacim integer;

DEFINE vc_fecha_nac varchar(10);
DEFINE vc_loc_nacim varchar(100);
DEFINE vc_dpto_nacim varchar(60);
DEFINE vc_prov_nacim varchar(60);
DEFINE vc_pais_nacim varchar(60);

DEFINE vc_nom_coleg varchar(100);
DEFINE vc_loc_coleg varchar(100);
DEFINE vc_dpto_coleg varchar(60);
DEFINE vc_prov_coleg varchar(60);
DEFINE vc_pais_coleg varchar(60);


BEGIN

   -- inicializaciones.
   LET vc_UA              = NULL;
   LET vc_NroInscripcion  = NULL;
   LET vc_Apellido        = NULL;
   LET vc_Nombres         = NULL;
   LET vc_NroDocumento    = NULL;
   LET vd_FechaInscrip    = NULL;
   LET vc_NroCi           = NULL;
   LET vc_EmisorCi        = NULL;
   LET vc_TituloSec       = NULL;
   LET vc_TipoDocDesAbre  = NULL;
   LET vc_EmisorCiDesc    = NULL;
   LET vc_TituloSecDesc   = NULL;
   LET vc_Fecha           = NULL;
   LET vc_FechaMax       = NULL;
   LET vd_fecha_actualiza = NULL;
   LET vc_fecha_actualiza = NULL;
   

   LET vc_CallePl         = NULL;
   LET vc_NumeroPl        = NULL;
   LET vc_PisoPl          = NULL;
   LET vc_DptoPl          = NULL;
   LET vc_UnidadPl        = NULL;
   LET vc_LocalidadPl     = NULL;
   LET vc_TelefonoPl      = NULL;
   
   LET vc_E_mail  = NULL;
   LET vc_Celular_numero   = NULL;
   LET vc_Celular_compania   = NULL;

   LET vc_LocalidadNombre = NULL;
   LET vc_ProvinciaNombre = NULL;
   
   LET vc_nac_pers = NULL;

   LET vc_fecha_nac = NULL;
   LET vc_loc_nacim = NULL;
   LET vc_dpto_nacim = NULL;
   LET vc_prov_nacim = NULL;
   LET vc_pais_nacim = NULL;

   LET vc_nom_coleg = NULL;
   LET vc_loc_coleg = NULL;
   LET vc_dpto_coleg = NULL;
   LET vc_prov_coleg = NULL;
   LET vc_pais_coleg = NULL;

   -- Ultimo dato censal del alumno.
   SELECT MAX(fecha_relevamiento) INTO vc_FechaMax
     FROM sga_datos_censales
    WHERE sga_datos_censales.unidad_academica = vc_UA
      AND sga_datos_censales.nro_inscripcion =  vc_NroInscripcion;
	  
	   -- datos propios de la persona;
   SELECT sga_personas.unidad_academica,
          sga_personas.nro_inscripcion,
          sga_personas.apellido,
          sga_personas.nombres,
          sga_personas.nro_documento,
          sga_personas.fecha_inscripcion,
          sga_personas.nro_ci,
          sga_personas.ent_emisora_ci,
          sga_personas.titulo_secundario,
          mdp_tipo_documento.desc_abreviada,
          sga_personas.colegio_secundario,
          mdp_nacionalidades.descripcion,
          sga_personas.loc_nacimiento,
          to_char(sga_personas.fecha_nacimiento, "%d/%m/%Y")
     INTO vc_UA,
          vc_NroInscripcion,
          vc_Apellido,
          vc_Nombres,
          vc_NroDocumento,
          vd_FechaInscrip,
          vc_NroCi,
          vc_EmisorCi,
          vc_TituloSec,
          vc_TipoDocDesAbre,
          vi_col_sec,
          vc_nac_pers,
          vi_loc_nacim,
          vc_fecha_nac
     FROM sga_personas,
          mdp_tipo_documento,
          mdp_nacionalidades
    WHERE sga_personas.unidad_academica = pUA
      AND sga_personas.nro_inscripcion = pNroInscripcion
      AND mdp_tipo_documento.tipo_documento = sga_personas.tipo_documento
      AND mdp_nacionalidades.nacionalidad = sga_personas.nacionalidad;

   -- datos optativos de la persona;
   SELECT sga_entes_emis_ci.descripcion
     INTO vc_EmisorCiDesc
     FROM sga_entes_emis_ci
    WHERE sga_entes_emis_ci.entidad = vc_EmisorCi;

   -- datos optativos de la persona;
   SELECT sga_titulos_sec.descripcion
     INTO vc_TituloSecDesc
     FROM sga_titulos_sec
    WHERE sga_titulos_sec.titulo_secundario = vc_TituloSec;

   -- ultimo dato censal cargado con algo de domicilio;
   SELECT MAX(sga_datos_censales.fecha_relevamiento)
     INTO vc_fecha
     FROM sga_datos_censales
    WHERE sga_datos_censales.unidad_academica = vc_UA
      AND sga_datos_censales.nro_inscripcion =  vc_NroInscripcion
      AND (sga_datos_censales.calle_per_lect is not null or
          sga_datos_censales.numero_per_lect is not null or
          sga_datos_censales.piso_per_lect is not null or
          sga_datos_censales.dpto_per_lect is not null or
          sga_datos_censales.unidad_per_lect is not null or
          sga_datos_censales.loc_per_lect is not null or
          sga_datos_censales.te_per_lect is not null);

			   
  IF vc_fecha is not null THEN
   -- datos censales respecto de domicilio de procedencia
   SELECT sga_datos_censales.calle_per_lect,
          sga_datos_censales.numero_per_lect,
          sga_datos_censales.piso_per_lect,
          sga_datos_censales.dpto_per_lect,
          sga_datos_censales.unidad_per_lect,
          sga_datos_censales.loc_per_lect,
          sga_datos_censales.te_per_lect,
          -- to_char(sga_datos_censales.fecha_actualiz, "%d/%m/%Y"),
          sga_datos_censales.fecha_actualiz,
          sga_datos_censales.e_mail
     INTO vc_CallePl,
          vc_NumeroPl,
          vc_PisoPl,
          vc_DptoPl,
          vc_UnidadPl,
          vc_LocalidadPl,
          vc_TelefonoPl,
          vd_fecha_actualiza,
          vc_E_mail
     FROM sga_datos_censales
    WHERE sga_datos_censales.unidad_academica = vc_UA
      AND sga_datos_censales.nro_inscripcion = vc_NroInscripcion
      AND sga_datos_censales.fecha_relevamiento = vc_fecha;


   -- datos censales (optativos)
   SELECT mug_localidades.nombre_abreviado,  mug_provincias.nombre
     INTO vc_LocalidadNombre, vc_ProvinciaNombre
     FROM mug_localidades,
          mug_dptos_partidos,
          mug_provincias
    WHERE mug_localidades.localidad = vc_LocalidadPl
      AND mug_dptos_partidos.dpto_partido = mug_localidades.dpto_partido
      AND mug_provincias.provincia = mug_dptos_partidos.provincia;

 END IF;  -- Fin datos de domicilio de procedencia

 -- MAIL Y COMPANIA
 IF vc_FechaMax IS NOT NULL THEN  
   SELECT sga_datos_censales.e_mail, sga_datos_cen_aux.celular_numero, mdp_celular_comp.nombre
     INTO vc_E_mail, vc_Celular_numero, vc_Celular_compania
     FROM sga_datos_censales,
	      sga_datos_cen_aux, 
	      OUTER mdp_celular_comp
    WHERE sga_datos_cen_aux.unidad_academica   = vc_UA
      AND sga_datos_cen_aux.nro_inscripcion    = vc_NroInscripcion
      AND sga_datos_cen_aux.fecha_relevamiento = vc_FechaMax
      AND sga_datos_cen_aux.unidad_academica   = sga_datos_cen_aux.unidad_academica
      AND sga_datos_cen_aux.nro_inscripcion    = sga_datos_cen_aux.nro_inscripcion
      AND sga_datos_cen_aux.fecha_relevamiento = sga_datos_cen_aux.fecha_relevamiento
      AND mdp_celular_comp.celular_compania = sga_datos_cen_aux.celular_compania;
  END IF;
 
   
   -- Año de ingreso a la primer carrera.
   SELECT MIN(sga_periodo_insc.anio_academico)
     INTO vi_AnioIng
     FROM sga_carrera_aspira, sga_periodo_insc
    WHERE sga_carrera_aspira.unidad_academica = vc_UA
      AND sga_carrera_aspira.nro_inscripcion = vc_NroInscripcion
      AND sga_carrera_aspira.situacion_asp = 'IL'
      AND sga_carrera_aspira.periodo_inscripcio = sga_periodo_insc.periodo_inscripcio;
   

-- localidad de nacimiento
   select ml.nombre, md.nombre, mpr.nombre, mp.nombre
   INTO vc_loc_nacim, vc_dpto_nacim, vc_prov_nacim, vc_pais_nacim 
   FROM mug_localidades ml,
	mug_dptos_partidos md,
	mug_provincias mpr,
	mug_paises mp
   WHERE ml.localidad = vi_loc_nacim
	AND ml.dpto_partido = md.dpto_partido
	AND md.provincia = mpr.provincia
	AND mpr.pais = mp.pais;


   SELECT scs.nombre, ml.nombre, md.nombre, mpr.nombre, mp.nombre
   INTO vc_nom_coleg, vc_loc_coleg, vc_dpto_coleg, vc_prov_coleg, vc_pais_coleg
   FROM sga_coleg_sec scs,
	mug_localidades ml,
	mug_dptos_partidos md,
	mug_provincias mpr,
	mug_paises mp
   WHERE scs.colegio = vi_col_sec
	AND ml.localidad = scs.localidad
	AND ml.dpto_partido = md.dpto_partido
	AND md.provincia = mpr.provincia
	AND mpr.pais = mp.pais;



   -- devuelvo los datos.
   RETURN vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_NroDocumento, vd_FechaInscrip, vi_AnioIng, vc_NroCi, vc_EmisorCi, vc_TituloSec, vc_TipoDocDesAbre, vc_EmisorCiDesc, vc_TituloSecDesc, vc_fecha_actualiza, vc_CallePl, vc_NumeroPl, vc_PisoPl, vc_DptoPl, vc_UnidadPl, vc_LocalidadPl, vc_TelefonoPl, vc_E_mail, vc_Celular_numero, vc_Celular_compania, vc_LocalidadNombre, vc_ProvinciaNombre, vc_nac_pers, vc_fecha_nac, vc_loc_nacim, vc_dpto_nacim, vc_prov_nacim, vc_pais_nacim, 
vc_nom_coleg, vc_loc_coleg, vc_dpto_coleg, vc_prov_coleg, vc_pais_coleg;


END;
END PROCEDURE;
-- **************************  Fin del Procedure sp_FichAluDatPer **************************

GRANT EXECUTE ON sp_FichAluDatPer TO public;




-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
INSERT INTO app_versiones ( version, fecha_generacion, fecha_actualiz, script_corrido )
     VALUES ( "CNV2.09.5" , TODAY, CURRENT YEAR TO SECOND, 3);
-- *************************************************************************************
-- *************************************************************************************
-- Verifico que se haya corrido script anterior
EXECUTE PROCEDURE sp_soy_dba();
EXECUTE PROCEDURE sp_validar_scripts('CNV2.09.5', 3);
-- *************************************************************************************

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.09.5
-- Version Original: 
-- Procedure: sp_eval_orig_aprob
-- Procedure recursivo llamado desde el sp_eval_orig_aprob para poder registrar los alumnos que aprobaron
-- en las evaluaciones relacionadas.
-- Inserta los alumnos que aprobaron en la tabla temporal "_temp_aprobados"
-- *******************************************************************************

-- DROP PROCEDURE sp_eval_orig_aprob;
CREATE PROCEDURE sp_eval_orig_aprob (
	pComision LIKE sga_comisiones.comision, 
	pEvaluacion LIKE sga_eval_parc.evaluacion);

DEFINE iEvaluacionOrigen       LIKE sga_eval_parc.evaluacion_origen;

BEGIN
 LET iEvaluacionOrigen = NULL;
   
 -- Selecciono la evaluacion origen relacionada.
 SELECT evaluacion_origen INTO iEvaluacionOrigen  FROM sga_eval_parc WHERE sga_eval_parc.evaluacion = pEvaluacion;
 
 -- Si tiene evaluacion origen relacionada entonces recupero los alumnos que aprobaron. 
 IF iEvaluacionOrigen IS NOT NULL AND iEvaluacionOrigen <> pEvaluacion THEN
    INSERT INTO _temp_aprobados (carrera, legajo)
         SELECT carrera, legajo 
		   FROM sga_eval_parc_alum
          WHERE comision = pComision
            AND evaluacion = iEvaluacionOrigen
            AND resultado IN ('A','P');
	-- Llamo nuevamente a este procedure por si la evaluacion origen esta relacionada con otra. (Recuperatorio de Recuperatorio..)		
	EXECUTE PROCEDURE sp_eval_orig_aprob (pComision, iEvaluacionOrigen);
 END IF;
   
END;
END PROCEDURE;
-- ******************* FIN PROCEDURE sp_eval_orig_aprob ******************* 

GRANT EXECUTE ON sp_eval_orig_aprob TO public;

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.02.0
-- 
-- Version Original: 1.9.0, 2.9.2, 2.9.5
-- Procedure: sp_eval_parc_alum
-- 
-- Devuelve el listado de alumnos de la comision para una evaluacion
-- Si los alumnos tuvieran informacion cargada, tambien la recuperaria.
-- Esta usando el SP: sp_AluInscCom
-- 
--  * 2.04 para recuperar escala de notas de la evaluación
--  * 2.9.2 para que solo recupere alumnos que no aprobaron o estuvieron ausentes en la evaluacion relacionada.
--  * 2.9.3 Considera el resultado Promocion como un resultado aprobado para una evaluacion.         
--  * 2.9.5 En el caso de que tenga evaluaciones relacionadas encadenadas no devuelve los alumnos que aprobaron.
-- *******************************************************************************

DROP PROCEDURE sp_eval_parc_alum;
CREATE PROCEDURE sp_eval_parc_alum ( pComision LIKE sga_comisiones.comision, pEvaluacion LIKE sga_eval_parc.evaluacion )
       RETURNING varchar(5), varchar(5), varchar(255), integer, varchar(20), integer, varchar(15), integer, varchar(50), integer, varchar(30), varchar(15), varchar(15), varchar(15), varchar(5), varchar(100), varchar(15), varchar(255), varchar(16), varchar(16), varchar(20), varchar(20), varchar(20), varchar(180);


-- Descripcion del Return:
-- varchar(5),       -- vcUnidadAcademica,
-- varchar(5),       -- vcMateria,
-- varchar(255),     -- vcMateriaNombre,
-- integer,          -- vcAnio,
-- varchar(20),      -- vcPerLect,
-- integer,          -- iComision,
-- varchar(15),      -- vcComisionDesc,
-- integer,          -- vcEscalaNotas,
-- varchar(50),      -- vcEscalaNotasDesc,
-- integer,          -- vcEvaluacion,
-- varchar(30),      -- vcEvaluacionDesc,
-- varchar(15),      -- vcCatedra,
-- varchar(15),      -- vcCalidadInsc,
-- varchar(15),      -- vcEstado,
-- varchar(5),       -- vcCarrera,
-- varchar(255),     -- vcCarreraNombre,
-- varchar(15),      -- vcAlumnoLegajo,
-- varchar(100),     -- vcAlumnoNombre,
-- varchar(16),      -- vcEvaluaFechaHora,
-- varchar(16),      -- vcNota,
-- varchar(20),      -- vcResultado,
-- varchar(20),      -- vcCorregidoPor,
-- varchar(20);      -- vcObservaciones;
-- varchar(180) vcImagenAlumno;

DEFINE vcUnidadAcademica LIKE sga_comisiones.unidad_academica;
DEFINE vcMateria         LIKE sga_materias.materia;
DEFINE vcMateriaNombre   LIKE sga_materias.nombre;
DEFINE vcAnio            LIKE sga_comisiones.anio_academico;
DEFINE vcPerLect         LIKE sga_comisiones.periodo_lectivo;
DEFINE iComision         LIKE sga_comisiones.comision;
DEFINE vcComisionDesc    LIKE sga_comisiones.nombre;
DEFINE vcEscalaNotas     LIKE sga_escala_notas.escala_notas;
DEFINE vcEscalaNotasDesc LIKE sga_escala_notas.nombre;
DEFINE vcEvaluacion      LIKE sga_eval_parc.evaluacion;
DEFINE vcEvaluacionDesc  LIKE sga_eval_parc.descripcion;
DEFINE vcCatedra         LIKE sga_comisiones.catedra;
DEFINE vcCalidadInsc     VARCHAR(15);
DEFINE vcEstado          VARCHAR(15);
DEFINE vcCarrera         LIKE sga_carreras.carrera;
DEFINE vcCarreraNombre   LIKE sga_carreras.nombre;
DEFINE vcAlumnoLegajo    LIKE sga_insc_cursadas.legajo;
DEFINE vcAlumnoNombre    VARCHAR(100);
DEFINE vcDocenteNombre   VARCHAR(255);
DEFINE vcEvaluaFechaHora VARCHAR(16);  -- dd/mm/yyyy hh:mm
DEFINE vcFechaHoraCron   LIKE sga_cron_eval_parc.fecha_hora;
DEFINE vcNota            LIKE sga_eval_parc_alum.nota;
DEFINE vcResultado       VARCHAR(20);
DEFINE vcCorregidoPor    LIKE sga_eval_parc_alum.corregido_por;
DEFINE vcObservaciones   LIKE sga_eval_parc_alum.observaciones;
DEFINE vcCarrNomRed      LIKE sga_carreras.nombre_reducido;
DEFINE vcSede like sga_sedes.sede;
DEFINE vcNombreSede like sga_sedes.nombre;
DEFINE vcImagenAlumno    VARCHAR(180);
DEFINE iEvaluacionOrigen       LIKE sga_eval_parc.evaluacion_origen;
DEFINE _hay_aprobados integer;

BEGIN

   -- Inicializaciones.
   LET vcUnidadAcademica = NULL;
   LET vcMateria         = NULL;
   LET vcMateriaNombre   = NULL;
   LET vcAnio            = NULL;
   LET vcPerLect         = NULL;
   LET iComision         = NULL;
   LET vcComisionDesc    = NULL;
   LET vcEscalaNotas     = NULL;
   LET vcEscalaNotasDesc = NULL;
   LET vcEvaluacion      = NULL;
   LET vcEvaluacionDesc  = NULL;
   LET vcCatedra         = NULL;
   LET vcCalidadInsc     = NULL;
   LET vcEstado          = NULL;
   LET vcCarrera         = NULL;
   LET vcCarreraNombre   = NULL;
   LET vcAlumnoLegajo    = NULL;
   LET vcAlumnoNombre    = NULL;
   LET vcDocenteNombre   = NULL;
   LET vcEvaluaFechaHora = NULL;
   LET vcFechaHoraCron   = NULL;
   LET vcNota            = NULL;
   LET vcResultado       = NULL;
   LET vcCorregidoPor    = NULL;
   LET vcObservaciones   = NULL;
   LET vcImagenAlumno    = NULL;
   LET iEvaluacionOrigen       = NULL;
   LET _hay_aprobados = 0;

   
   -- Fecha y Hora y escala de notas y nombre de la evaluación
   SELECT sga_cron_eval_parc.fecha_hora, sga_atr_eval_parc.escala_notas, sga_escala_notas.nombre
     INTO vcFechaHoraCron, vcEscalaNotas, vcEscalaNotasDesc
     FROM sga_cron_eval_parc, sga_atr_eval_parc, sga_escala_notas
    WHERE sga_cron_eval_parc.comision   = pComision
      AND sga_cron_eval_parc.evaluacion = pEvaluacion
	and sga_cron_eval_parc.comision = sga_atr_eval_parc.comision
	and sga_cron_eval_parc.evaluacion = sga_atr_eval_parc.evaluacion
	and sga_atr_eval_parc.escala_notas = sga_escala_notas.escala_notas;
   
   -- corto la fecha para que quede dia y hora
   LET vcEvaluaFechaHora = TO_CHAR( vcFechaHoraCron, "%d/%m/%Y %H:%M");
   
   -- Selecciono la Evaluacion y evaluacion relacionada.
   SELECT evaluacion, descripcion, evaluacion_origen
     INTO vcEvaluacion, vcEvaluacionDesc, iEvaluacionOrigen
     FROM sga_eval_parc
    WHERE sga_eval_parc.evaluacion = pEvaluacion;
   
  
   -- Tabla temporal de alumnos que aprobaron la evaluacion relacionada
   BEGIN
     ON EXCEPTION IN (-206)
      -- tabla no existe. continuo. Falla el drop.
     END EXCEPTION WITH RESUME;  
      
     -- Borro tablas temporales si existen...
     DROP TABLE _temp_aprobados;
     DROP TABLE _temp_alumnos;
   END;
   CREATE TEMP TABLE _temp_aprobados (carrera varchar(5), legajo varchar(15));
   CREATE TEMP TABLE _temp_alumnos (carrera varchar(5), legajo varchar(15));

   -- Recupero los alumnos que aprobaron las evaluaciones que estan relacionadas con esta. Carga la tabla _temp_aprobados.
   EXECUTE PROCEDURE sp_eval_orig_aprob (pComision, pEvaluacion);
   SELECT COUNT(*) INTO _hay_aprobados FROM _temp_aprobados;

/*   IF iEvaluacionOrigen IS NOT NULL AND iEvaluacionOrigen <> pEvaluacion THEN
     INSERT INTO _temp_aprobados (carrera, legajo)
          SELECT carrera, legajo FROM sga_eval_parc_alum
           WHERE comision = pComision
             AND evaluacion = iEvaluacionOrigen
             AND resultado IN ('A','P');
   END IF;
*/

   -- Alumnos que estan en la evaluacion
   INSERT INTO _temp_alumnos (carrera, legajo)
        SELECT carrera, legajo 
          FROM sga_eval_parc_alum 
         WHERE comision = pComision AND evaluacion = pEvaluacion;


   -- Selecciono los datos de la Comision.
   SELECT sga_comisiones.comision,
          sga_comisiones.materia,
          sga_materias.nombre,
          sga_comisiones.anio_academico,
          sga_comisiones.periodo_lectivo,
          sga_comisiones.nombre,
          sga_comisiones.catedra
     INTO iComision,
          vcMateria,
          vcMateriaNombre,
          vcAnio,
          vcPerLect,
          vcComisionDesc,
          vcCatedra
     FROM sga_comisiones,
          sga_materias
    WHERE sga_comisiones.comision = pComision
      AND sga_materias.unidad_academica = sga_comisiones.unidad_academica
      AND sga_materias.materia = sga_comisiones.materia;


  
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- Alumnos inscriptos en la comision.
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   FOREACH EXECUTE PROCEDURE sp_AluInscCom ( pComision )
      INTO vcUnidadAcademica, vcMateria, vcMateriaNombre, vcAnio, vcPerLect, iComision, vcComisionDesc, vcCatedra, vcCalidadInsc, vcEstado, vcCarrera, vcCarreraNombre, vcAlumnoLegajo, vcAlumnoNombre, vcDocenteNombre,vcCarrNomRed, vcSede, vcNombreSede

      -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- Si tiene una evaluacion relacionada y el alumno aprobo la evaluacion anterior entonces no lo devuelvo.
      -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --  IF iEvaluacionOrigen IS NOT NULL AND iEvaluacionOrigen <> pEvaluacion THEN
      IF _hay_aprobados > 0 THEN
         IF (SELECT COUNT(*) FROM _temp_aprobados WHERE carrera = vcCarrera AND legajo = vcAlumnoLegajo) > 0 THEN

           -- Si existe el alumno en la evaluacion entonces lo borro porque en la evaluacion origen esta aprobado.
           IF (SELECT COUNT(*) FROM _temp_alumnos WHERE carrera = vcCarrera AND legajo = vcAlumnoLegajo) > 0 THEN
               DELETE FROM sga_eval_parc_alum
                WHERE unidad_academica = vcUnidadAcademica
                  AND carrera = vcCarrera 
                  AND legajo = vcAlumnoLegajo
                  AND comision = pComision 
                  AND evaluacion = pEvaluacion;
           END IF;

           -- No agrego al alumno a la evaluacion porque aprobo la evaluacion relacionada.
           CONTINUE FOREACH;
       END IF;
     END IF;  
       
       -- Traigo informacion que estuviera cargada, sino, no importa, deja nulos.
       -- EN CASO DE PROMOCIÓN, IGUALMENTE DEVUELVE COMO DESCRIPCIÓN APROBADO.
       SELECT sga_eval_parc_alum.nota,
              DECODE(sga_eval_parc_alum.resultado, 'A', 'Aprobado', 'R', 'Reprobado', 'U', 'Ausente', 'P', 'Aprobado' ),
              sga_eval_parc_alum.corregido_por,
              sga_eval_parc_alum.observaciones
         INTO vcNota, vcResultado, vcCorregidoPor, vcObservaciones
         FROM sga_eval_parc_alum
        WHERE sga_eval_parc_alum.unidad_academica = vcUnidadAcademica
          AND sga_eval_parc_alum.carrera = vcCarrera
          AND sga_eval_parc_alum.legajo = vcAlumnoLegajo
          AND sga_eval_parc_alum.comision = iComision
          AND sga_eval_parc_alum.evaluacion = vcEvaluacion;
       
       SELECT sga_personas.id_imagen 
         INTO vcImagenAlumno
         FROM sga_alumnos, sga_personas
         WHERE sga_alumnos.unidad_academica = vcUnidadAcademica
          AND sga_alumnos.carrera = vcCarrera
          AND sga_alumnos.legajo = vcAlumnoLegajo
          AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
          AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion;


       RETURN vcUnidadAcademica, vcMateria, vcMateriaNombre, vcAnio, vcPerLect, iComision, vcComisionDesc, vcEscalaNotas, vcEscalaNotasDesc, vcEvaluacion, vcEvaluacionDesc, vcCatedra, vcCalidadInsc, vcEstado, vcCarrera, vcCarreraNombre, vcAlumnoLegajo, vcAlumnoNombre, vcEvaluaFechaHora, vcNota, vcResultado, vcCorregidoPor, vcObservaciones, vcImagenAlumno WITH RESUME;
       
   END FOREACH;
   
   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- Si existe el acta de cursado, traigo los alumnos que figuran ahi y que no estan en la inscripción.
   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   IF ( SELECT COUNT(*) FROM sga_actas_cursado WHERE comision = pComision ) = 1 THEN
      
      FOREACH
       SELECT sga_curs_pendiente.unidad_academica,
              sga_curs_pendiente.carrera,
              sga_carreras.nombre,
              sga_curs_pendiente.legajo,
              TRIM(sga_personas.apellido) || ', ' || TRIM(sga_personas.nombres) as nombre_alumno,
              sga_personas.id_imagen
         INTO vcUnidadAcademica,
              vcCarrera,
              vcCarreraNombre,
              vcAlumnoLegajo,
              vcAlumnoNombre,
              vcImagenAlumno
         FROM sga_curs_pendiente,
              sga_alumnos,
              sga_personas,
              sga_carreras
        WHERE sga_curs_pendiente.comision =  pComision
          AND sga_alumnos.unidad_academica = sga_curs_pendiente.unidad_academica
          AND sga_alumnos.carrera = sga_curs_pendiente.carrera
          AND sga_alumnos.legajo  = sga_curs_pendiente.legajo
          AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
          AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion
          AND sga_carreras.unidad_academica = sga_curs_pendiente.unidad_academica
          AND sga_carreras.carrera = sga_curs_pendiente.carrera
          AND NOT EXISTS ( SELECT '' FROM sga_insc_cursadas
                                    WHERE sga_insc_cursadas.unidad_academica = sga_curs_pendiente.unidad_academica
                                      AND sga_insc_cursadas.carrera  = sga_curs_pendiente.carrera
                                      AND sga_insc_cursadas.legajo   = sga_curs_pendiente.legajo
                                      AND sga_insc_cursadas.comision = sga_curs_pendiente.comision )

      -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- Si tiene una evaluacion relacionada y el alumno aprobo la evaluacion anterior entonces no lo devuelvo.
      -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- IF iEvaluacionOrigen IS NOT NULL AND iEvaluacionOrigen <> pEvaluacion THEN
      IF _hay_aprobados > 0 THEN
         IF (SELECT COUNT(*) FROM _temp_aprobados WHERE carrera = vcCarrera AND legajo = vcAlumnoLegajo) > 0 THEN

           -- Si existe el alumno en la evaluacion entonces lo borro porque en la evaluacion origen esta aprobado.
           IF (SELECT COUNT(*) FROM _temp_alumnos WHERE carrera = vcCarrera AND legajo = vcAlumnoLegajo) > 0 THEN
               DELETE FROM sga_eval_parc_alum
                WHERE unidad_academica = vcUnidadAcademica
                  AND carrera = vcCarrera 
                  AND legajo = vcAlumnoLegajo
                  AND comision = pComision 
                  AND evaluacion = pEvaluacion;
           END IF;

           -- No agrego al alumno a la evaluacion porque aprobo la evaluacion relacionada.
           CONTINUE FOREACH;
       END IF;
     END IF;
         
         -- Traigo informacion que estuviera cargada, sino, no importa, deja nulos.
         -- EN CASO DE PROMOCIÓN, IGUALMENTE DEVUELVE COMO DESCRIPCIÓN APROBADO.
         SELECT sga_eval_parc_alum.nota,
                DECODE(sga_eval_parc_alum.resultado, 'A', 'Aprobado', 'R', 'Reprobado', 'U', 'Ausente', 'P', 'Aprobado' ),
                sga_eval_parc_alum.corregido_por,
                sga_eval_parc_alum.observaciones
           INTO vcNota, vcResultado, vcCorregidoPor, vcObservaciones
           FROM sga_eval_parc_alum
          WHERE sga_eval_parc_alum.unidad_academica = vcUnidadAcademica
            AND sga_eval_parc_alum.carrera = vcCarrera
            AND sga_eval_parc_alum.legajo = vcAlumnoLegajo
            AND sga_eval_parc_alum.comision = iComision
            AND sga_eval_parc_alum.evaluacion = vcEvaluacion;
         
         -- Pongo en nulo los datos propios de los inscriptos.
         LET vcCalidadInsc = NULL; 
         LET vcEstado      = NULL;
         
         RETURN vcUnidadAcademica, vcMateria, vcMateriaNombre, vcAnio, vcPerLect, pComision, vcComisionDesc, vcEscalaNotas, vcEscalaNotasDesc, vcEvaluacion, vcEvaluacionDesc, vcCatedra, vcCalidadInsc, vcEstado, vcCarrera, vcCarreraNombre, vcAlumnoLegajo, vcAlumnoNombre, vcEvaluaFechaHora, vcNota, vcResultado, vcCorregidoPor, vcObservaciones, vcImagenAlumno WITH RESUME;
         
         
      END FOREACH;
   END IF;

   BEGIN
     ON EXCEPTION IN (-206)
      -- tabla no existe. continuo. Falla el drop.
     END EXCEPTION WITH RESUME;  
      
     -- Borro tablas temporales si existen...
     DROP TABLE _temp_aprobados;
     DROP TABLE _temp_alumnos;
   END;
   
END;
END PROCEDURE;
-- ******************* FIN PROCEDURE sp_eval_parc_alum ******************* 


GRANT EXECUTE ON sp_eval_parc_alum TO public;


-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
INSERT INTO app_versiones ( version, fecha_generacion, fecha_actualiz, script_corrido )
     VALUES ( "CNV2.09.5" , TODAY, CURRENT YEAR TO SECOND, 4);
-- *************************************************************************************
-- *************************************************************************************
-- Verifico que se haya corrido script anterior
EXECUTE PROCEDURE sp_soy_dba();
EXECUTE PROCEDURE sp_validar_scripts('CNV2.09.5', 4);
-- *************************************************************************************

-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 2.9.5
-- *******************************************************************************
Execute procedure dba.sui_ventanas( 'w_abm_lista_conexion_db' );

-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 2.02.0, 2.9.5
-- *******************************************************************************
Execute procedure dba.sui_operaciones( 'admin005', 'Módulos - Conexiones a Bases de Datos', null, null );
INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior ) VALUES ( 'admin005', 1, 'w_abm_lista_conexion_db', 'uo_dw, dk_conexion_db, 10', 'N' );
INSERT INTO dba.acc_parametros ( operacion, orden, ventana, parametros, cierra_anterior ) VALUES ( 'admin005', 2, 'w_abm_detalle', 'uo_dw, d_conexion_db, 1', 'N' );

INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'admin005', 'C' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'admin005', 'M' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'admin005', 'A' );
INSERT INTO dba.acc_acciones_oper ( operacion, accion ) VALUES ( 'admin005', 'B' );


-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
INSERT INTO app_versiones ( version, fecha_generacion, fecha_actualiz, script_corrido )
     VALUES ( "CNV2.09.5" , TODAY, CURRENT YEAR TO SECOND, 5);
-- *************************************************************************************
-- *************************************************************************************
-- Verifico que se haya corrido script anterior
EXECUTE PROCEDURE sp_soy_dba();
EXECUTE PROCEDURE sp_validar_scripts('CNV2.09.5', 5);
-- *************************************************************************************

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Stored Procedure: sp_crearcalendcurs
-- Version 1.8
-- Ultima version de modificacion: 2.02.0, 2.7.0 (modificacion llamado al sp que recupera las fechas.., toma fecha de inicio y fin de dictado del periodo lectivo y considera la periodicidad de la banda horaria)
-- 2.9.5 (Se permite insertar clases que no existen en comisiones que ya tienen asignadas clases por otras bandas horarias)
-- Crea para una Comision, los registros dia a dia segun el Periodo Lectivo de la misma.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
DROP PROCEDURE sp_crearcalendcurs;
CREATE PROCEDURE sp_crearcalendcurs ( pComision LIKE sga_comisiones.comision )
       RETURNING INTEGER;

   -- vars para el manejo de excepciones
   DEFINE SQLErr          integer;
   DEFINE ISAMError       integer;
   DEFINE errorInfo       varchar(76);
   DEFINE vcUserError     varchar(10);

   -- vars para devolver resultado
   DEFINE iStatus         smallint;
   DEFINE vcMsg           varchar(255);

   -- vars locales
   DEFINE iAsignacion     LIKE sga_asignaciones.asignacion;
   DEFINE iDiaSemana      LIKE sga_asignaciones.dia_semana;
   DEFINE vdFechaAux      Date;
   DEFINE iAnio           LIKE sga_periodos_lect.anio_academico;
   DEFINE vcPeriodoLectivo LIKE sga_periodos_lect.periodo_lectivo;
   DEFINE vdFechaInicio   LIKE sga_periodos_lect.inicio_dictado;
   DEFINE vdFechaFin      LIKE sga_periodos_lect.fin_dictado;
   DEFINE iCantRegistros  INTEGER;
   DEFINE vdFechaDesde, vdFechaHasta  DATE;
   DEFINE vcFechaDesde, vcFechaHasta  varchar(10);
   DEFINE vPeriodicidad   LIKE sga_asign_clases.periodicidad; 
   DEFINE vcEsLaborable   CHAR(1);
   
   -- si hay algun error NO controlado
   ON EXCEPTION SET SQLErr, ISAMError, errorInfo
      RAISE EXCEPTION  SQLErr, ISAMError, errorInfo;
   END EXCEPTION;

BEGIN

   LET iCantRegistros = 0;

   SELECT inicio_dictado, fin_dictado, p.anio_academico, p.periodo_lectivo
     INTO vdFechaInicio, vdFechaFin, iAnio, vcPeriodoLectivo
     FROM sga_comisiones c, 
          sga_periodos_lect p
    WHERE c.anio_academico = p.anio_academico
      AND c.periodo_lectivo = p.periodo_lectivo
      AND c.comision = pComision;

   -- Recorro desde la Fecha de Inicio del Periodo Lectivo Hasta la Fecha de Finalizacion
   -- Por Cada Dia, verifico si 
   FOREACH SELECT a.asignacion, a.dia_semana, a.fecha_asign_desde, a.fecha_asign_hasta, ac.periodicidad
	INTO iAsignacion, iDiaSemana, vdFechaDesde, vdFechaHasta, vPeriodicidad
	FROM sga_asign_clases ac,  sga_asignaciones a
	WHERE ac.comision = pComision
	AND ac.asignacion = a.asignacion
	ORDER BY a.dia_semana, a.fecha_asign_desde

        LET vcFechaDesde = to_char(vdFechaDesde, "%d-%m-%Y");	
        LET vcFechaHasta = to_char(vdFechaHasta, "%d-%m-%Y");	

        -- Recuperara las fechas con una periodicidad semanal 	
        FOREACH EXECUTE PROCEDURE sp_get_fechas_bh(vcFechaDesde, vcFechaHasta, iDiaSemana, vPeriodicidad) INTO vdFechaAux, vcEsLaborable
            -- Solo agrego la clase si esta dentro de algun tramo definido para el período lectivo de la comisión.
	IF (SELECT count(*) 
	         FROM sga_inasis_tramos 
	       WHERE anio_academico = iAnio
	             AND periodo_lectivo = vcPeriodoLectivo
	             AND vdFechaAux BETWEEN fecha_desde AND fecha_hasta
	       ) > 0 THEN
	           IF (SELECT COUNT(comision) FROM sga_calendcursada WHERE comision = pComision AND asignacion = iAsignacion AND fecha = vdFechaAux) = 0 THEN
	              -- Inserto un registro en calendario de cursada
                              INSERT INTO sga_calendCursada (comision, asignacion, fecha, valido)  VALUES (pComision, iAsignacion, vdFechaAux, vcEsLaborable);
	              LET iCantRegistros =  iCantRegistros + 1;
	           END IF;                   
	END IF;    
        END FOREACH;  -- Fechas una asignacion

   END FOREACH;      -- Asignaciones de una comision   
  
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
  -- ATENCION: weekday() retorna         : 0 domingo, 1 Lunes, 2 Martes....6 Sabado
  --                    en sga_asignaciones es:  1 Domingo, 2Lunes, ......, 7 Sabado
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
   RETURN  iCantRegistros;
END;
END PROCEDURE;
-- ++++++++++++++++++++++++++++ Fin Procedure sp_crearcalendcurs ++++++++++++++++++++++++++++++++

GRANT EXECUTE ON sp_crearcalendcurs TO public;

-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
INSERT INTO app_versiones ( version, fecha_generacion, fecha_actualiz, script_corrido )
     VALUES ( "CNV2.09.5" , TODAY, CURRENT YEAR TO SECOND, 6);
-- *************************************************************************************
-- *************************************************************************************
-- Verifico que se haya corrido script anterior
EXECUTE PROCEDURE sp_soy_dba();
EXECUTE PROCEDURE sp_validar_scripts('CNV2.09.5', 6);
-- *************************************************************************************

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedure: sp_i_copia_com_per
-- v.2.05.0
-- Modificado 2.06.0, 2.6.4, 2.7.0, 2.9.5
-- Copia una comision generada en el periodo del año academico viejos dados como argumento,
-- para el periodo del año academico nuevo dados como argumento
-- Se copian las bandas horarias de la comision y se crean las clases (v.2.9.5)
--
-- Argumentos:	 
--   unidad_academica
--   anio_academico_origen 
--   periodo_lectivo_origen
--   anio_academico_destino
--   periodo_lectivo_destino
--	 comision a copiar
--   sede 
--		
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

DROP PROCEDURE sp_i_copia_com_per;
CREATE PROCEDURE sp_i_copia_com_per(
     p_unidad_academica LIKE sga_unidades_acad.unidad_academica
   , p_anio_aca_origen  LIKE sga_comisiones.anio_academico
   , p_periodo_origen     LIKE sga_comisiones.periodo_lectivo
   , p_anio_aca_destino LIKE sga_comisiones.anio_academico
   , p_periodo_destino    LIKE sga_comisiones.periodo_lectivo
   , p_comision_a_copia    LIKE sga_comisiones.comision
   , p_sede like sga_comisiones.sede
 )
 returning  integer, varchar(255);   -- mensaje

-- Definición de variales de la comisiones
DEFINE  v_comision             LIKE      sga_comisiones.comision          ;
DEFINE  v_unidad_academica     LIKE      sga_comisiones.unidad_academica  ;
DEFINE  v_materia              LIKE      sga_comisiones.materia           ;
DEFINE  v_anio_academico       LIKE      sga_comisiones.anio_academico 	  ;
DEFINE  v_periodo_lectivo      LIKE      sga_comisiones.periodo_lectivo   ;
DEFINE  v_nombre               LIKE      sga_comisiones.nombre            ;
DEFINE  v_catedra              LIKE      sga_comisiones.catedra           ;
DEFINE  v_escala_notas 	       LIKE      sga_comisiones.escala_notas 	  ;
DEFINE  v_grupo_carrera        LIKE      sga_comisiones.grupo_carrera 	  ;
DEFINE  v_turno                LIKE      sga_comisiones.turno             ;
DEFINE  v_letra_desde 	       LIKE      sga_comisiones.letra_desde 	  ;
DEFINE  v_letra_hasta 	       LIKE      sga_comisiones.letra_hasta 	  ;
DEFINE  v_capacidad            LIKE      sga_comisiones.capacidad         ;
DEFINE  v_insc_habilitada      LIKE      sga_comisiones.insc_habilitada   ;
DEFINE  v_carrera              LIKE      sga_comisiones.carrera           ;
DEFINE  v_plan                 LIKE      sga_comisiones.plan              ;
DEFINE v_cant_clases INTEGER;

-- Datos del docente
DEFINE v_LEGAJO                LIKE     sga_docentes_com.LEGAJO              ;
DEFINE v_RESPONSABILIDAD                LIKE     sga_docentes_com.RESPONSABILIDAD              ;
DEFINE v_HS_CONSULTA           LIKE     sga_docentes_com.HS_CONSULTA         ;
DEFINE v_HS_TUTORIA            LIKE     sga_docentes_com.HS_TUTORIA          ;
DEFINE v_HS_CLASES_TEORIC      LIKE     sga_docentes_com.HS_CLASES_TEORICAS  ;
DEFINE v_HS_CLASES_PRACTI      LIKE     sga_docentes_com.HS_CLASES_PRACTICA  ;
DEFINE v_HS_EXAMEN             LIKE     sga_docentes_com.HS_EXAMEN           ;
DEFINE v_HS_PREPARACION        LIKE     sga_docentes_com.HS_PREPARACION      ;
DEFINE v_HS_CAMPO              LIKE     sga_docentes_com.HS_CAMPO            ;
DEFINE v_HS_LABORATORIO        LIKE     sga_docentes_com.HS_LABORATORIO      ;
DEFINE  ld_fecha_inicio_pl  LIKE sga_periodos_lect.fecha_inicio;
DEFINE  ld_fecha_fin_pl  LIKE sga_periodos_lect.fecha_fin;

--  Banda Horaria
DEFINE v_ASIGNACION_vieja     LIKE      sga_asign_clases.ASIGNACION          ;
DEFINE v_ASIGNACION_nueva     LIKE      sga_asign_clases.ASIGNACION          ;
DEFINE v_TIPO_CLASE           LIKE      sga_asign_clases.TIPO_CLASE          ;
DEFINE v_CANTIDAD           LIKE      sga_asign_clases.cantidad_horas          ;

DEFINE v_DIA_SEMANA           LIKE      sga_asignaciones.DIA_SEMANA          ;
DEFINE v_FECHA_ASIGN_DES      LIKE      sga_asignaciones.FECHA_ASIGN_DESDE   ;
DEFINE v_HS_COMIENZO_CLA      LIKE      sga_asignaciones.HS_COMIENZO_CLASE   ;
DEFINE v_AULA                 LIKE      sga_asignaciones.AULA                ;
DEFINE v_EDIFICIO             LIKE      sga_asignaciones.EDIFICIO            ;
DEFINE v_TIPO_ASIGNACION      LIKE      sga_asignaciones.TIPO_ASIGNACION     ;
DEFINE v_FECHA_ASIGN_HAS      LIKE      sga_asignaciones.FECHA_ASIGN_HASTA   ;
DEFINE v_HS_FINALIZ_CLAS      LIKE      sga_asignaciones.HS_FINALIZ_CLASE    ;
DEFINE v_OBSERVACIONES        LIKE      sga_asignaciones.OBSERVACIONES       ;
DEFINE v_ESTADO               LIKE      sga_asignaciones.ESTADO              ;


-- Var auxiliares
DEFINE  li_cant_comi integer;

-- variables de error
DEFINE sql_err int;
DEFINE isam_err int;
DEFINE error_info varchar(76);

ON EXCEPTION set sql_err, isam_err, error_info
    -- Error. no realizo nada
  --   raise exception -746, 0,  'Com origen: ' || p_comision_a_copia ||  ' Materia: ' || v_materia  || ' -- Error: ' ||  sql_err || '-' || error_info ;
     raise exception -746, 0,  error_info ;
END EXCEPTION;


BEGIN

ON EXCEPTION set sql_err, isam_err, error_info
    -- Error. no realizo nada
     raise exception -746, 0, '. Com anterior: ' || p_comision_a_copia ||  ' Mat: ' || v_materia || ' Error generando comisión.';-- ||  sql_err || '-' || error_info    ;
END EXCEPTION;


LET v_materia = ''    ;
LET v_comision = 0 ;

 -- Controles
 -- El periodo origen y destino deben existir
 If (Select count(*) from sga_periodos_lect where anio_academico = p_anio_aca_origen and periodo_lectivo = p_periodo_origen ) = 0  Then
    Return -1,'El período origen no existe.';
 End if;
 If (Select count(*) from sga_periodos_lect where anio_academico = p_anio_aca_destino and periodo_lectivo = p_periodo_destino ) = 0 Then
    Return -1,'El período destino no existe.';
 End if

-- Sacar las fechas de inicio y fin del periodo lectivo.
SELECT inicio_dictado, fin_dictado
	INTO ld_fecha_inicio_pl, ld_fecha_fin_pl
	FROM sga_periodos_lect
	WHERE anio_academico = p_anio_aca_destino 
	AND periodo_lectivo = p_periodo_destino;

   
SELECT unidad_academica, materia, anio_academico, periodo_lectivo, nombre, catedra, escala_notas, grupo_carrera, turno
            , letra_desde, letra_hasta, capacidad, insc_habilitada, carrera, plan

    INTO v_unidad_academica, v_materia, v_anio_academico, v_periodo_lectivo, v_nombre, v_catedra, v_escala_notas, v_grupo_carrera,
	v_turno, v_letra_desde, v_letra_hasta, v_capacidad, v_insc_habilitada, v_carrera, v_plan

    FROM sga_comisiones
    WHERE    comision = p_comision_a_copia;


    INSERT INTO sga_comisiones (unidad_academica, materia, anio_academico, periodo_lectivo, nombre, catedra, escala_notas
            , grupo_carrera, turno, letra_desde, letra_hasta, capacidad, insc_habilitada, carrera, plan, sede)
        VALUES (v_unidad_academica, v_materia, p_anio_aca_destino, p_periodo_destino, v_nombre, v_catedra, v_escala_notas
            , v_grupo_carrera, v_turno, v_letra_desde, v_letra_hasta, v_capacidad,'S', v_carrera, v_plan, p_sede);
 
    let v_comision = dbinfo("sqlca.sqlerrd1");

END; -- generación de comision

BEGIN

ON EXCEPTION set sql_err, isam_err, error_info
    -- Error. no realizo nada
     raise exception -746, 0, 'Com anterior: ' || p_comision_a_copia ||  ' Mat: ' || v_materia || ' Error copiando docentes.';-- ||  sql_err || '-' || error_info   ;
END EXCEPTION;
   
    
    -- Cargar docentes por comision
    FOREACH
        Select LEGAJO, RESPONSABILIDAD, HS_CONSULTA, HS_TUTORIA, HS_CLASES_TEORICAS, HS_CLASES_PRACTICA
            , HS_EXAMEN, HS_PREPARACION, HS_CAMPO, HS_LABORATORIO

            INTO v_LEGAJO, v_RESPONSABILIDAD, v_HS_CONSULTA, v_HS_TUTORIA, v_HS_CLASES_TEORIC, v_HS_CLASES_PRACTI
            , v_HS_EXAMEN, v_HS_PREPARACION, v_HS_CAMPO, v_HS_LABORATORIO

        FROM sga_docentes_com
        WHERE
                comision = p_comision_a_copia

        Insert into sga_docentes_com (comision,  LEGAJO, RESPONSABILIDAD, HS_CONSULTA, HS_TUTORIA, HS_CLASES_TEORICAS
            , HS_CLASES_PRACTICA, HS_EXAMEN, HS_PREPARACION, HS_CAMPO, HS_LABORATORIO)
        values (v_comision, v_LEGAJO, v_RESPONSABILIDAD, v_HS_CONSULTA, v_HS_TUTORIA, v_HS_CLASES_TEORIC
            , v_HS_CLASES_PRACTI, v_HS_EXAMEN, v_HS_PREPARACION, v_HS_CAMPO, v_HS_LABORATORIO);


    END FOREACH;


END; -- copia de docentes

BEGIN

ON EXCEPTION set sql_err, isam_err, error_info
    -- Error. no realizo nada
     raise exception -746, 0, '. Com origen: ' || p_comision_a_copia ||  ' Mat: ' || v_materia   || ' - Banda horaria.' ||  sql_err || '-' || error_info ;
END EXCEPTION;
   

	-- ++++++++++++++++++++++++++++++++++++++++++++++++
	-- Carga la banda horaria
	-- ++++++++++++++++++++++++++++++++++++++++++++++++
	FOREACH  SELECT ASIGNACION , TIPO_CLASE, CANTIDAD_HORAS
			   INTO v_ASIGNACION_vieja, v_TIPO_CLASE, v_CANTIDAD
			   FROM sga_asign_clases
			  WHERE comision = p_comision_a_copia

        SELECT DIA_SEMANA, HS_COMIENZO_CLASE, AULA, EDIFICIO, TIPO_ASIGNACION, HS_FINALIZ_CLASE, OBSERVACIONES, ESTADO
            INTO v_DIA_SEMANA, v_HS_COMIENZO_CLA , v_AULA, v_EDIFICIO, v_TIPO_ASIGNACION, v_HS_FINALIZ_CLAS, v_OBSERVACIONES, v_ESTADO
         FROM  sga_asignaciones
         WHERE asignacion = v_ASIGNACION_vieja        ;

         -- Controlar si la asignación vieja estaba compartida.
         SELECT COUNT(DISTINCT comision) INTO li_cant_comi FROM sga_asign_clases WHERE asignacion = v_ASIGNACION_vieja;

         IF li_cant_comi =  1 THEN
      	   INSERT INTO  sga_asignaciones (DIA_SEMANA, FECHA_ASIGN_DESDE, HS_COMIENZO_CLASE, AULA
	            , EDIFICIO, TIPO_ASIGNACION, FECHA_ASIGN_HASTA, HS_FINALIZ_CLASE, OBSERVACIONES, ESTADO)
	        VALUES (v_DIA_SEMANA,  ld_fecha_inicio_pl, v_HS_COMIENZO_CLA, v_AULA
	            , v_EDIFICIO, v_TIPO_ASIGNACION,  ld_fecha_fin_pl, v_HS_FINALIZ_CLAS, v_OBSERVACIONES, v_ESTADO);

			LET v_ASIGNACION_nueva = dbinfo("sqlca.sqlerrd1");

        ELSE
			-- Buscar si la asignación ya se generó.
			SELECT max(asignacion) 	
			INTO      v_ASIGNACION_nueva
			FROM    sga_asignaciones
			WHERE DIA_SEMANA = v_DIA_SEMANA
			AND   HS_COMIENZO_CLASE = v_HS_COMIENZO_CLA 
			AND   AULA = v_AULA
			AND   EDIFICIO = v_EDIFICIO
			AND   TIPO_ASIGNACION = v_TIPO_ASIGNACION
			AND   HS_FINALIZ_CLASE = v_HS_FINALIZ_CLAS
			AND   FECHA_ASIGN_DESDE =  ld_fecha_inicio_pl
			AND   FECHA_ASIGN_HASTA =  ld_fecha_fin_pl ;
		
			--  Si no encontró la asignación la agrega.
			IF v_ASIGNACION_nueva is null  THEN
				INSERT INTO sga_asignaciones (DIA_SEMANA, FECHA_ASIGN_DESDE, HS_COMIENZO_CLASE, AULA
									, EDIFICIO, TIPO_ASIGNACION, FECHA_ASIGN_HASTA, HS_FINALIZ_CLASE, OBSERVACIONES, ESTADO)
				VALUES (v_DIA_SEMANA, ld_fecha_inicio_pl, v_HS_COMIENZO_CLA, v_AULA, 
					v_EDIFICIO, v_TIPO_ASIGNACION,  ld_fecha_fin_pl, v_HS_FINALIZ_CLAS, v_OBSERVACIONES, v_ESTADO);
		
				LET v_ASIGNACION_nueva = dbinfo("sqlca.sqlerrd1");
			END IF;

		END IF; -- li_cant_comi = 1

		-- Creo la banda horaria en la comision 
        INSERT INTO sga_asign_clases (comision, asignacion, tipo_clase, cantidad_horas)
             VALUES ( v_comision , v_asignacion_nueva, v_tipo_clase , v_cantidad );
			 

    END FOREACH;  -- Banda horaria
    -- ++++++++++++++++++++++++++++++++++++++++++++++++
END; -- banda horaria

-- Genero las clases de todas las bandas horarias de la comision.
EXECUTE PROCEDURE sp_crearcalendcurs (v_comision) INTO v_cant_clases;


RETURN 1,'OK. Se creó la comisión: ' || v_comision;

END PROCEDURE;
-- ++++++++++++++++++++++++++ FIN Procedure sp_i_copia_com_per ++++++++++++++++++++++++++

GRANT EXECUTE ON sp_i_copia_com_per  TO public;


-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
INSERT INTO app_versiones ( version, fecha_generacion, fecha_actualiz, script_corrido )
     VALUES ( "CNV2.09.5" , TODAY, CURRENT YEAR TO SECOND, 7);
-- *************************************************************************************
-- *************************************************************************************
-- Verifico que se haya corrido script anterior
EXECUTE PROCEDURE sp_soy_dba();
EXECUTE PROCEDURE sp_validar_scripts('CNV2.09.5', 7);
-- *************************************************************************************

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Tabla: gda_anuncios
-- CK: ck_anuncio_tipo
-- Valores:
--
-- U = Todos los alumnos y docentes
-- D = Todos los Docentes
-- A = Todos los alumnos
-- C = Alumnos de una Carrera
-- P = Envio a una persona
-- O = Alumnos de una Comision
-- B = Docentes de una comsion
-- X = Alumnos y Docentes de una Comision
-- M = Alumnos de una mesa de examen
-- T = Docentes de una mesa de examen
-- Y = Alumnos y Docentes de una mesa de examen
-- I = Todos los ingresantes a carreras
-- J = Ingresantes de una carrera
-- G = Grupo de alumnos y/o docentes
-- R = Si el tipo es O o M se convierte en sp_i_anuncio en R.
-- L = Alumnos que cursan en un periodo lectivo
-- N = Alumnos que cursan una materia en un periodo lectivo
-- Z = Alumnos Extranjeros  (de una o toas las carreras)
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ALTER TABLE gda_anuncios DROP CONSTRAINT ck_anuncio_tipo;
ALTER TABLE gda_anuncios
       ADD CONSTRAINT CHECK (tipo_anuncio IN ('U','D','A','P','C','O','B','X','M','T','Y','I','J','G','L','N','Z'))
              CONSTRAINT ck_anuncio_tipo;

-- *******************************************************************************
-- SIU - Sistema de Gestion de Alumnos
-- Version 2.03.0
-- Ultima Version de Modificación 2.6.0, 2.7.0, 2.8.0, 2.9.2, 2.9.5
-- PROCEDURE: sp_i_anuncio
-- 
-- Graba un anuncio de cualquier tipo
-- *******************************************************************************
DROP PROCEDURE sp_i_anuncio;
CREATE PROCEDURE sp_i_anuncio (
     pTipoAnuncio LIKE gda_anuncios.tipo_anuncio,
     pUnidadAcad  LIKE gda_anuncios.unidad_academica,
     pNroInscrip  LIKE gda_anuncios.nro_inscripcion,
     pCarrera     LIKE gda_anuncios.carrera,
     pCurso       LIKE gda_anuncios.curso,
     pFechaDesde  VARCHAR(10),
     pFechaHasta  VARCHAR(10),
     pTituloAnun  LIKE gda_anuncios.titulo_anuncio,
     pEnviaMail   LIKE gda_anuncios.enviado_por_mail,
     pEnviaSms    LIKE gda_anuncios.enviado_por_sms,
     pIntGest     LIKE gda_anuncios.INT_GESTION,
     pIntAuto     LIKE gda_anuncios.INT_AUTOGESTION,
     pIntTele     LIKE gda_anuncios.INT_TELEFONO,
     pIntInte     LIKE gda_anuncios.INT_INTERNET,
     pMensaje     LIKE gda_anuncios.mensaje,
     pLegajoDocente LIKE gda_anuncios.docente_envia,
     pTodosAlgunos LIKE gda_anuncios.todos_algunos,
     pAnioAcademico LIKE gda_anuncios.anio_academico,
     pPeriodoLectivo LIKE gda_anuncios.periodo_lectivo,
     pMateria LIKE gda_anuncios.materia,
     pSede LIKE gda_anuncios.sede)

   RETURNING INTEGER, VARCHAR(255); 
/*
Retorna:
 INTEGER,      --  0: OK / -1: Error / 0: nro de anuncio
 VARCHAR(255)  -- mensaje
*/

  DEFINE d_fecha_desde LIKE gda_anuncios.fecha_desde;
  DEFINE d_fecha_hasta LIKE gda_anuncios.fecha_hasta;
  DEFINE iStatus       INTEGER;
  DEFINE vcMsg         VARCHAR(255);
  DEFINE iAnuncio INTEGER;
  DEFINE iAnioAcademico INTEGER;
  -- DEFINE vcTipo char(1);
  DEFINE vcSede LIKE gda_anuncios.sede;
  DEFINE vcCarrera LIKE sga_carreras.carrera;
  DEFINE vEstadoEnvioMail char(1);
    
  -- Variables para el manejo de excepciones
  DEFINE sql_err    INTEGER;
  DEFINE isam_err   INTEGER;
  DEFINE error_info VARCHAR(76);


  -- bloque de excepciones
  ON EXCEPTION SET sql_err, isam_err, error_info                                        
    LET iStatus = -1 ;
    LET vcMsg = sql_err || ' , ' || error_info;
        RETURN iStatus, vcMsg;
  END EXCEPTION; 

 
BEGIN

 BEGIN

     ON EXCEPTION SET sql_err, isam_err, error_info
       -- Si entro por aca, es porque se ingreso una fecha con diferente formato o no valida.
       LET vcMsg = 'La fecha (' || pFechaDesde || ') no es una fecha válida' ;
       RETURN -1,'800000,' || vcMsg;	
      END EXCEPTION;

      IF SUBSTR(pFechaDesde,3,1) = '/' THEN
        LET d_fecha_desde = to_date(pFechaDesde, "%d/%m/%Y");
      ELIF  SUBSTR(pFechaDesde,3,1) = '-' THEN
        LET d_fecha_desde = to_date(pFechaDesde, "%d-%m-%Y");
      ELSE
        -- Error
        LET vcMsg = 'Formato de fecha desde no válido. Formato válido: dd/mm/aaaa' ;
        RETURN -1,'800000,' || vcMsg;	
      END IF;
 END;	

 BEGIN
  ON EXCEPTION SET sql_err, isam_err, error_info
    -- Si entro por aca, es porque se ingreso una fecha con diferente formato o no valida.
    LET vcMsg = 'La fecha (' || pFechaHasta || ') no es una fecha válida' ;
    RETURN -1,'800000,' || vcMsg;	
   END EXCEPTION;

  IF SUBSTR(pFechaHasta,3,1) = '/' THEN
    LET d_fecha_hasta = to_date(pFechaHasta, "%d/%m/%Y");
  ELIF  SUBSTR(pFechaHasta,3,1) = '-' THEN
    LET d_fecha_hasta = to_date(pFechaHasta, "%d-%m-%Y");
  ELSE
     -- Error
    LET vcMsg = 'Formato de fecha hasta no válido. Formato válido: dd/mm/aaaa' ;
    RETURN -1,'800000,' || vcMsg;	
  END IF;
 END;
   
 BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
     -- Si entro por aca, es porque se ingreso una fecha incorrecta.
   END EXCEPTION;

   IF d_fecha_hasta < d_fecha_desde THEN
	       -- ERROR
				LET vcMsg = 'La fecha Desde debe ser menor que Hasta' ;
				RETURN -1,'800000,' || vcMsg;	
	  ELIF d_fecha_desde < TODAY  THEN
	   	  --  ERROR
				LET vcMsg = 'La fecha Desde no debe ser menor que la Actual' ;
				RETURN -1,'800000,' || vcMsg;	
	 END IF;  	  
	     	   
   END;
   
   LET iAnuncio = NULL;
   -- IF pTipoAnuncio = 'O' OR pTipoAnuncio = 'M' THEN
   --  LET vcTipo = 'R';
   -- ELSE
   --   LET vcTipo = pTipoAnuncio;
   -- END IF;
  
   IF pSede = 'Todas' THEN
     LET vcSede = NULL;
   ELSE
     LET vcSede = pSede;
   END IF;     
   IF pCarrera = 'TODOS' THEN
     LET vcCarrera = NULL;
   ELSE
     LET vcCarrera = pCarrera;
   END IF;     

   LET vEstadoEnvioMail = 'N'; -- No se envia mail
   IF pEnviaMail = 'S' THEN
      -- Se envia el mail, debo ver si el mensaje fue enviado por el docente
      -- Si fue enviado por el docente desde autogestion, entonces marco como que ya se envio el mail
      IF pLegajoDocente IS NOT NULL THEN
         LET vEstadoEnvioMail = 'E';  -- Mail Enviado
      ELSE
         LET vEstadoEnvioMail = 'P';  -- Mail Pendiente de Envio
      END IF;
   END IF;

   -- Doy de alta el mensaje
   INSERT INTO gda_anuncios (tipo_anuncio,  unidad_academica, nro_inscripcion, carrera, curso, fecha_desde, fecha_hasta, 
       titulo_anuncio,  enviado_por_mail,  enviado_por_sms, fecha_de_registro, INT_GESTION, INT_AUTOGESTION,INT_TELEFONO, INT_INTERNET, 
       mensaje, docente_envia, todos_algunos, anio_academico, periodo_lectivo, materia, sede)
   VALUES (pTipoAnuncio, pUnidadAcad, pNroInscrip,  vcCarrera, pCurso, d_fecha_desde, d_fecha_hasta,
           pTituloAnun, pEnviaMail, pEnviaSms, CURRENT, pIntGest, pIntAuto,  pIntTele, pIntInte, 
           pMensaje, pLegajoDocente, pTodosAlgunos, pAnioAcademico, pPeriodoLectivo, pMateria, vcSede);


  LET iStatus = DBINFO("sqlca.sqlerrd1");
  LET iAnuncio = iStatus; -- DBINFO("sqlca.sqlerrd2");  -- ID del Anuncio

  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Genero los destinatarios del Mensaje
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IF pTipoAnuncio = 'Z' THEN

    -- Z: Alumnos Extranjeros
    INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT DISTINCT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_alumnos as a, sga_personas as p
        WHERE a.calidad = 'A'
         AND p.unidad_academica = a.unidad_academica
         AND p.nro_inscripcion  = a.nro_inscripcion
         AND (pCarrera = 'TODOS' OR a.carrera = pCarrera)
         AND p.nacionalidad = 2; -- Extranjero

  END IF;

  IF pTipoAnuncio = 'G' THEN
     -- G: Grupo de alumnos y/o docentes
     -- Estos se agregan por fuera de este procedure luego de que este sea ejecutado.
  END IF;
  

  IF pTipoAnuncio = 'U' THEN
    -- U: El mensaje se envia a la unidad academica (Alumnos y Docentes)
    INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, d.unidad_academica, d.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_docentes as d;

     --  Alumnos que no son docentes
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT DISTINCT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_alumnos as a
        WHERE a.calidad = 'A'
         AND a.nro_inscripcion NOT IN (SELECT nro_inscripcion FROM sga_docentes)
         AND (pSede = 'Todas' OR a.sede = pSede); 

  END IF;

  
  IF pTipoAnuncio = 'P' THEN
     -- P: El mensaje se envia a una persona
     -- Mensaje a una persona (Alumno, Docente...)
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       VALUES (iAnuncio, pUnidadAcad, pNroInscrip, vEstadoEnvioMail);
  END IF;

  IF pTipoAnuncio = 'A' THEN
    -- A: El mensaje se envia a todos los Alumnos Activos
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT distinct iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_alumnos as a
        WHERE a.calidad = 'A'
          AND (pSede = 'Todas' OR a.sede = pSede); 
  END IF;

  IF pTipoAnuncio = 'D' THEN
     -- D: Todos los docentes
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, d.unidad_academica, d.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_docentes as d;
  END IF;

  IF (pTipoAnuncio = 'O' AND pTodosAlgunos = 'T') OR pTipoAnuncio = 'X' THEN
     -- O: Alumnos inscriptos en una comision
     -- X: Alumnos y docentes de una comision (TODOS)
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM gda_cursos_com as cc,
              sga_insc_cursadas as i,
              sga_alumnos as a
        WHERE cc.curso = pCurso
          AND i.comision = cc.comision
          AND a.unidad_academica = i.unidad_academica 
          AND a.carrera          = i.carrera
          AND a.legajo           = i.legajo;
  END IF;

  IF (pTipoAnuncio = 'B' AND pTodosAlgunos = 'T') OR pTipoAnuncio = 'X' THEN
     -- B: Docentes de una comisión
     -- X: Alumnos y docentes de una comision
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, d.unidad_academica, d.nro_inscripcion, vEstadoEnvioMail 
         FROM gda_cursos_com as cc,
              sga_docentes_com as dc,
              sga_docentes as d
        WHERE cc.curso = pCurso
          AND dc.comision = cc.comision
          AND d.legajo = dc.legajo;
  END IF;

  IF pTipoAnuncio = 'L'  THEN
     -- L: Alumnos inscriptos en comisiones de un periodo lectivo
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT DISTINCT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_comisiones as cc,
                    sga_insc_cursadas as i,
                   sga_alumnos as a
        WHERE cc.anio_academico = pAnioAcademico
          AND cc.periodo_lectivo = pPeriodoLectivo
          AND i.comision = cc.comision
          AND a.unidad_academica = i.unidad_academica 
          AND a.carrera          = i.carrera
          AND a.legajo           = i.legajo
          AND (pSede = 'Todas' OR a.sede = pSede); 
  END IF;

  IF pTipoAnuncio = 'N'  THEN
     -- N: Alumnos inscriptos en comisiones de un periodo lectivo y materia
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT DISTINCT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_comisiones as cc,
              sga_insc_cursadas as i,
              sga_alumnos as a
        WHERE cc.anio_academico = pAnioAcademico
          AND cc.periodo_lectivo = pPeriodoLectivo
          AND cc.materia = pMateria 
          AND i.comision = cc.comision
          AND a.unidad_academica = i.unidad_academica 
          AND a.carrera          = i.carrera
          AND a.legajo           = i.legajo
          AND (pSede = 'Todas' OR a.sede = pSede); 
  END IF;

  IF (pTipoAnuncio = 'M' AND pTodosAlgunos = 'T') OR pTipoAnuncio = 'Y' THEN
     -- M: Alumnos inscriptos en una mesa de examen y llamado
     -- Y: Alumnos y Docentes de una mesa de examen (TODOS)
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM gda_cursos_mesa as cm,
              sga_insc_examen as i,
              sga_alumnos as a
        WHERE cm.curso = pCurso
          AND i.unidad_academica = cm.unidad_academica 
          AND i.materia          = cm.materia
          AND i.anio_academico   = cm.anio_academico
          AND i.turno_examen     = cm.turno_examen
          AND i.mesa_examen      = cm.mesa_examen
          AND i.llamado          = cm.llamado
          AND a.unidad_academica = i.unidad_academica 
          AND a.carrera          = i.carrera
          AND a.legajo           = i.legajo;
  END IF;

  IF (pTipoAnuncio = 'T' AND pTodosAlgunos = 'T') OR pTipoAnuncio = 'Y' THEN
     -- T: Docentes de una mesa de examen
     -- Y: Alumnos y Docentes de una mesa de examen (TODOS)
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, d.unidad_academica, d.nro_inscripcion, vEstadoEnvioMail 
         FROM gda_cursos_mesa as cm,
              sga_docentes_llama as dll,
              sga_docentes as d
        WHERE cm.curso = pCurso
          AND dll.unidad_academica = cm.unidad_academica 
          AND dll.materia          = cm.materia
          AND dll.anio_academico   = cm.anio_academico
          AND dll.turno_examen     = cm.turno_examen
          AND dll.mesa_examen      = cm.mesa_examen
          AND dll.llamado          = cm.llamado
          AND d.legajo = dll.legajo;
  END IF;


  IF pTipoAnuncio = 'C' THEN
    -- C: El mensaje se envia a toda una carrera
    -- Mensaje a una carrera. Alumnos activos.
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_alumnos as a
        WHERE a.unidad_academica = pUnidadAcad
          AND (pCarrera = 'TODOS' OR a.carrera = pCarrera)
          AND a.calidad = 'A'
          AND (pSede = 'Todas' OR a.sede = pSede); 
  END IF;
  
  -- I: Todos los ingresantes en todas las carreras. Alumnos Activos o Condicionales
  -- J: Ingresantes en una carrera. Alumnos Activos o Condicionales
  IF pTipoAnuncio = 'I' OR pTipoAnuncio = 'J' THEN
     LET iAnioAcademico = NULL;
     IF pAnioAcademico IS NOT NULL THEN
         LET iAnioAcademico = pAnioAcademico;
     ELSE      
       -- Busca el año académico actual
       SELECT max(anio_academico)  INTO iAnioAcademico FROM sga_anio_academico WHERE TODAY BETWEEN fecha_inicio AND fecha_fin;
     END IF;
  END IF;
  
  IF pTipoAnuncio = 'I' THEN
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT DISTINCT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_alumnos as a,
              sga_carrera_aspira as c,
              sga_periodo_insc as p
        WHERE c.unidad_academica = a.unidad_academica
          AND c.carrera = a.carrera
          AND c.nro_inscripcion = a.nro_inscripcion
          AND p.periodo_inscripcio = c.periodo_inscripcio
          AND p.anio_academico = iAnioAcademico
          AND a.calidad IN ('A', 'C')
          AND (pSede = 'Todas' OR a.sede = pSede); 
  END IF;


  IF pTipoAnuncio = 'J' THEN
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT distinct iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_alumnos as a,
              sga_carrera_aspira as c,
              sga_periodo_insc as p
        WHERE a.unidad_academica = pUnidadAcad
          AND (pCarrera = 'TODOS' OR a.carrera = pCarrera)
          AND c.unidad_academica = a.unidad_academica
          AND c.carrera = a.carrera
          AND c.nro_inscripcion = a.nro_inscripcion
          AND p.periodo_inscripcio = c.periodo_inscripcio
          AND p.anio_academico = iAnioAcademico
          AND a.calidad IN ('A', 'C')
          AND (pSede = 'Todas' OR a.sede = pSede); 
  END IF;

  -- ++++++++++++++ Fin destinatarios Mensajes ++++++++++++++

  RETURN iStatus, '800000, Anuncio creado';


END;
END PROCEDURE;
-- *************************** Fin procedure sp_i_anuncio ****************************************************


GRANT EXECUTE ON sp_i_anuncio TO public;

-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
INSERT INTO app_versiones ( version, fecha_generacion, fecha_actualiz, script_corrido )
     VALUES ( "CNV2.09.5" , TODAY, CURRENT YEAR TO SECOND, 8);
-- *************************************************************************************
-- *************************************************************************************
-- Verifico que se haya corrido script anterior
EXECUTE PROCEDURE sp_soy_dba();
EXECUTE PROCEDURE sp_validar_scripts('CNV2.09.5', 8);
-- *************************************************************************************

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedure sp_fichaluporcapro
-- Version modificación: 2.09.0, 2.9.5
-- En el caso de egresados, recupera el plan y version de plan de estudios a la fecha de egreso.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

DROP PROCEDURE sp_fichaluporcapro;
CREATE PROCEDURE sp_fichaluporcapro (
   pUnidadAcademica LIKE sga_personas.unidad_academica, 
   pNroInscripcion LIKE sga_personas.nro_inscripcion)
 
 RETURNING varchar(5), varchar(10), varchar(30), varchar(30), varchar(5), varchar(255), varchar(5), varchar(255), varchar(5), varchar(255), varchar(15), varchar(5), decimal(6,2), decimal(6,2), varchar(5);--un toco

-- retorno
-- varchar(5),   -- unidad_academica
-- varchar(10),  -- nro_inscripcion
-- varchar(30),  -- apellido
-- varchar(30),  -- nombres
-- varchar(5),   -- carrera
-- varchar(255), -- carrera_nombre
-- varchar(5), -- titulo 
-- varchar(255), -- nombre titulo
-- varchar(5), -- orientacion
-- varchar(255), -- orientacion nombre
-- varchar(15),  -- legajo
-- varchar(5),   -- plan
-- decimal(6,2), -- porcentaje de aprobacion orientacion
-- decimal(6,2), -- porcentaje de aprobacion-titulo
-- varchar(5)  -- version del plan


DEFINE vcUnidadAcademica LIKE sga_alumnos.unidad_academica; 
DEFINE vcCarrera LIKE sga_alumnos.carrera;
DEFINE vcLegajo  LIKE sga_alumnos.legajo;
DEFINE vcPlan, vcPlanAux LIKE sga_versiones_plan.plan;
DEFINE vcVersion, vcVersionAux LIKE sga_versiones_plan.version;
DEFINE vcTitulo LIKE sga_atrib_mat_orie.titulo;
DEFINE vcOrientacion LIKE sga_atrib_mat_orie.orientacion;
DEFINE vcMateria LIKE sga_atrib_mat_orie.materia;
DEFINE vdPorcentaje decimal(6,2);
DEFINE vcOrientElegida LIKE sga_atrib_mat_orie.orientacion;
DEFINE vcApellido        LIKE sga_personas.apellido;
DEFINE vcNombres         LIKE sga_personas.nombres;
DEFINE vcSexo         LIKE sga_personas.sexo;
DEFINE vcNombreCarrera LIKE sga_carreras.nombre; 
DEFINE vcNombreTitulo LIKE sga_titulos.nombre;
DEFINE vcNombreTituloF LIKE sga_titulos.nombre_femenino;
DEFINE vcNombreOrient LIKE sga_orientaciones.nombre;
DEFINE vdPorcentajeOri decimal(6,2);
DEFINE viCantMaterias integer;
DEFINE viCantMateriasOri integer;
DEFINE vcTieneOrient LIKE sga_titulos_plan.tiene_orient;
DEFINE vcResultGene char(1);
DEFINE vcCalidad char(1);
DEFINE vdtFecha Datetime Year to Second;
DEFINE vdFechaEgreso Date;

CREATE TEMP TABLE tmp_materia_porcen (
	unidad_academica varchar(5),
	carrera varchar(5),
	legajo varchar(15),
	plan varchar(5),
	version varchar(5),
	titulo varchar(5),
	orientacion varchar(5),
	materia varchar(5),
	porcentaje decimal(6,2) default 0 ) WITH NO LOG;

CREATE TEMP TABLE tmp_result_porcen (
	unidad_academica varchar(5),
	carrera varchar(5),
	legajo varchar(15),
	plan varchar(5),
	version varchar(5),
	titulo varchar(5),
	orientacion varchar(5),
	suma decimal(10,2),
	conteo integer ) WITH NO LOG;

CREATE TEMP TABLE tmp_carreras_plan (
	unidad_academica varchar(5),
	carrera varchar(5),
	legajo varchar(15),
	plan varchar(5),
	version varchar(5));

-- selecciono los datos personales de la persona.
   SELECT sga_personas.apellido,
          sga_personas.nombres,
	sga_personas.sexo
     INTO vcApellido, vcNombres, vcSexo
     FROM sga_personas
    WHERE sga_personas.unidad_academica = pUnidadAcademica
      AND sga_personas.nro_inscripcion = pNroInscripcion;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Recorro las carreras en las que se encuentra la persona
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FOREACH SELECT unidad_academica, carrera, legajo, calidad
		INTO vcUnidadAcademica, vcCarrera, vcLegajo, vcCalidad
		FROM sga_alumnos
		WHERE unidad_academica = pUnidadAcademica
		AND nro_inscripcion = pNroInscripcion
		
		
    -- Si es egresado, saco el plan y la version en base a la fecha de solicitud del titulo, sino a la fecha actual
    LET vcPlan = NULL;
    LET vcVersion = NULL;
    LET vdtFecha = NULL;
    LET vdFechaEgreso = NULL;
    IF vcCalidad = 'E' THEN
       -- Egresado. Recupero fecha de egreso, plan y version del título de nivel final - Grado
       SELECT to.fecha_egreso, plan, version 
	     INTO vdFechaEgreso, vcPlan, vcVersion
         FROM sga_titulos_otorg as to,
              sga_titulos as t
		WHERE to.unidad_academica = pUnidadAcademica
 		  AND to.nro_inscripcion = pNroInscripcion
 		  AND to.carrera = vcCarrera
 		  AND to.legajo  = vcLegajo
		  AND t.unidad_academica = to.unidad_academica
 		  AND t.titulo =  to.titulo
 		  AND t.nivel = 'GRADO';

        -- Paso la fecha de egreso a formato datetime con el ultimo minuto del dia de egreso.
        LET vdtFecha = to_date(to_char(vdFechaEgreso,'%d/%m/%Y') || ' 23:59:59', '%d/%m/%Y %H:%M:%S');
	END IF;
	
	IF vdtFecha IS NULL THEN
	   LET vdtFecha = CURRENT;  -- Fecha y hora actual
	END IF;	
	  
	IF vcPlan IS NULL OR vcVersion IS NULL THEN 
		-- Calcula el plan y la version segun la fecha actual o fecha de egreso en la carrera
		EXECUTE PROCEDURE sp_plan_de_alumno (vcUnidadAcademica, vcCarrera, vcLegajo, vdtFecha) INTO vcPlan, vcVersion;
	END IF;	
    
	
	-- Registro el plan y version del alumno en cada carrera
	INSERT INTO tmp_carreras_plan (unidad_academica, carrera, plan, version) VALUES (vcUnidadAcademica, vcCarrera, vcPlan, vcVersion);

	INSERT INTO tmp_materia_porcen (unidad_academica, carrera, legajo, plan, version, titulo, orientacion, materia)
	SELECT vmp.unidad_academica, vmp.carrera, vcLegajo, vmp.plan, vmp.version, vmp.titulo, vmp.orientacion, vmp.materia
		FROM vw_materias_plan AS vmp, 
		     sga_atrib_mat_plan AS samp
		WHERE vmp.unidad_academica = vcUnidadAcademica
			AND vmp.carrera = vcCarrera
			AND vmp.plan = vcPlan
			AND vmp.version = vcVersion
			AND vmp.relacion = 'D'
			AND vmp.unidad_academica = samp.unidad_academica
			AND vmp.carrera = samp.carrera
			AND vmp.plan = samp.plan
			AND vmp.version = samp.version
			AND vmp.materia = samp.materia
			AND obligatoria='S';

	-- por ahora solo trabajo con aprobacion de materias
	FOREACH SELECT DISTINCT titulo
		INTO vcTitulo
		FROM tmp_materia_porcen

		IF (SELECT calculo_egreso
			FROM sga_titulos_plan
			WHERE unidad_academica = vcUnidadAcademica
				AND carrera = vcCarrera
				AND plan = vcPlan
				AND titulo = vcTitulo) <>'AM' THEN

			DELETE FROM tmp_materia_porcen WHERE titulo = vcTitulo;

		END IF;

		-- si el alumno eligio orientacion debo retornar solo esa orientacion
		SELECT orientacion
			INTO vcOrientElegida 
			FROM sga_orient_alumno
			WHERE unidad_academica = vcUnidadAcademica
				AND carrera = vcCarrera
				AND legajo = vcLegajo
				AND plan = vcPlan
				AND titulo = vcTitulo;

		IF vcOrientElegida IS NOT NULL THEN 
			-- borro los datos de las orientaciones no elegidas por el alumno
			DELETE FROM tmp_materia_porcen
				WHERE unidad_academica = vcUnidadAcademica
					AND carrera = vcCarrera
					AND legajo = vcLegajo
					AND plan = vcPlan
					AND titulo = vcTitulo
					AND orientacion NOT IN ('0' ,vcOrientElegida);

		END IF;
		
	END FOREACH; -- filtro por calculo_egreso y orientacion elegida


	FOREACH SELECT titulo, orientacion, materia
		INTO vcTitulo, vcOrientacion, vcMateria
		FROM tmp_materia_porcen

		LET vdPorcentaje = 0;

		IF (SELECT tipo_materia
			FROM sga_materias
			WHERE unidad_academica = vcUnidadAcademica
				AND materia = vcMateria) = 'G' THEN

			-- si la materia es generica busco el porcentaje de aprobacion
			EXECUTE PROCEDURE sp_resultGenePorc(pUnidadAcademica, vcCarrera, vcLegajo, vcTitulo, vcOrientacion,vcMateria) INTO vcResultGene, vdPorcentaje;

		ELSE

			IF EXISTS(SELECT ''
					FROM vw_hist_academica
					WHERE unidad_academica = vcUnidadAcademica
						AND carrera = vcCarrera
						AND legajo = vcLegajo
						AND materia = vcMateria
						AND resultado = 'A') THEN

				LET vdPorcentaje = 1;

			END IF;
		END IF;

		UPDATE tmp_materia_porcen 
			SET porcentaje = vdPorcentaje
			WHERE unidad_academica = vcUnidadAcademica
				AND carrera = vcCarrera
				AND legajo = vcLegajo
				AND titulo = vcTitulo
				AND orientacion = vcOrientacion
				AND materia = vcMateria;
			
	END FOREACH; --materia
			
END FOREACH; -- carreras

-- Ahora tratamos de retornar algo...
INSERT INTO tmp_result_porcen (unidad_academica, carrera, legajo, plan, version, titulo, orientacion, suma, conteo)
SELECT unidad_academica, carrera, legajo, plan, version, titulo, orientacion, SUM(porcentaje), COUNT(*)
	FROM tmp_materia_porcen
	GROUP BY unidad_academica, carrera, legajo, plan, version, titulo, orientacion;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- para cada plan y titulo
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FOREACH SELECT DISTINCT trp.unidad_academica, trp.carrera, trp.legajo, trp.plan, trp.titulo, sc.nombre, st.nombre, st.nombre_femenino, tiene_orient, tcpv.plan, tcpv.version
		INTO vcUnidadAcademica, vcCarrera, vcLegajo, vcPlan, vcTitulo, vcNombreCarrera, vcNombreTitulo, vcNombreTituloF, vcTieneOrient, vcPlanAux, vcVersionAux
		FROM tmp_result_porcen AS  trp, 
		     sga_carreras AS sc, 
		     sga_titulos AS st, 
		     sga_titulos_plan AS stp,
		     tmp_carreras_plan as tcpv
		WHERE trp.unidad_academica = sc.unidad_academica
			AND trp.carrera = sc.carrera
			AND trp.unidad_academica = st.unidad_academica
			AND trp.titulo = st.titulo
			AND trp.unidad_academica = stp.unidad_academica
			AND trp.carrera = stp.carrera
			AND trp.plan = stp.plan
			AND trp.titulo = stp.titulo
			AND tcpv.unidad_academica = stp.unidad_academica
			AND tcpv.carrera = stp.carrera


		SELECT DISTINCT trp.orientacion, nombre, suma, conteo
			INTO vcOrientacion, vcNombreOrient, vdPorcentaje, viCantMaterias
			FROM tmp_result_porcen AS trp, sga_orientaciones AS so
			WHERE trp.unidad_academica = vcUnidadAcademica
				AND trp.carrera = vcCarrera
				AND trp.plan = vcPlan
				AND trp.titulo = vcTitulo
				AND trp.orientacion ='0'
				AND trp.unidad_academica = so.unidad_academica
				AND trp.carrera = so.carrera
				AND trp.plan = so.plan
				AND trp.titulo = so.titulo
				AND trp.orientacion = so.orientacion;

		IF vcTieneOrient = 'N' THEN
			RETURN pUnidadAcademica, pNroInscripcion, vcApellido, vcNombres, vcCarrera, vcNombreCarrera, vcTitulo, vcNombreTitulo, vcOrientacion, vcNombreOrient, vcLegajo, vcPlanAux, (vdPorcentaje/viCantMaterias*100), (vdPorcentaje/viCantMaterias*100), vcVersionAux WITH RESUME;
		ELSE
			RETURN pUnidadAcademica, pNroInscripcion, vcApellido, vcNombres, vcCarrera, vcNombreCarrera, vcTitulo, vcNombreTitulo, vcOrientacion, vcNombreOrient, vcLegajo, vcPlanAux, (vdPorcentaje/viCantMaterias*100), NULL, vcVersionAux WITH RESUME;
		END IF;


	FOREACH SELECT DISTINCT trp.orientacion, nombre, suma, conteo
			INTO vcOrientacion, vcNombreOrient, vdPorcentajeOri, viCantMateriasOri
			FROM tmp_result_porcen AS trp, sga_orientaciones AS so
			WHERE trp.unidad_academica = vcUnidadAcademica
				AND trp.carrera = vcCarrera
				AND trp.plan = vcPlan
				AND trp.titulo = vcTitulo
				AND trp.orientacion <> '0'
				AND trp.unidad_academica = so.unidad_academica
				AND trp.carrera = so.carrera
				AND trp.plan = so.plan
				AND trp.titulo = so.titulo
				AND trp.orientacion = so.orientacion

		RETURN pUnidadAcademica, pNroInscripcion, vcApellido, vcNombres, vcCarrera, vcNombreCarrera, vcTitulo, vcNombreTitulo, vcOrientacion, vcNombreOrient, vcLegajo, 
		       vcPlanAux, (vdPorcentajeOri/viCantMateriasOri*100), ((vdPorcentaje + vdPorcentajeOri)/(viCantMaterias + viCantMateriasOri)*100), vcVersionAux WITH RESUME;

	END FOREACH; -- orientacion

END FOREACH; -- plan y titulo

-- Borro tablas temporales
DROP TABLE tmp_materia_porcen;
DROP TABLE tmp_result_porcen;
DROP TABLE tmp_carreras_plan;

END PROCEDURE;
-- ++++++++++++++++++++++++++++++++++++++++++++ Fin Procedure ++++++++++++++++++++++++++


GRANT EXECUTE ON sp_fichaluporcapro TO public;

-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
INSERT INTO app_versiones ( version, fecha_generacion, fecha_actualiz, script_corrido )
     VALUES ( "CNV2.09.5" , TODAY, CURRENT YEAR TO SECOND, 9);
-- *************************************************************************************
-- *************************************************************************************
-- Verifico que se haya corrido script anterior
EXECUTE PROCEDURE sp_soy_dba();
EXECUTE PROCEDURE sp_validar_scripts('CNV2.09.5', 9);
-- *************************************************************************************

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.05.0, 2.9.1, 2.9.5
--
-- Procedure sp_i_datcen_posgra
-- Graba el dato censal de la persona para la inscripcion a posgrados para GESTION.
-- *******************************************************************************
DROP PROCEDURE sp_i_datcen_posgra ;
CREATE PROCEDURE sp_i_datcen_posgra ( 
       p_unidad_academica	LIKE dba.sga_datos_censales.unidad_academica,
       p_nro_inscripcion 	LIKE dba.sga_datos_censales.nro_inscripcion,
       p_Periodo         	LIKE dba.sga_periodo_insc.periodo_inscripcio,
       p_FechaRelev      	LIKE dba.sga_datos_censales.fecha_relevamiento,
       p_EstadoCivil     	LIKE dba.sga_datos_censales.estado_civil,
       p_TurnoPrefer     	LIKE dba.sga_datos_censales.turno_preferido,
       p_Email              LIKE dba.sga_datos_censales.e_mail,
       p_TipoVisa        	LIKE dba.sga_datos_censales.tipo_visa,
       p_OtorgVisa       	LIKE dba.sga_datos_censales.otorgamiento_visa,
       p_VencimVisa      	LIKE dba.sga_datos_censales.vencimiento_visa,
       p_TipoResidenc    	LIKE dba.sga_datos_censales.tipo_residencia,
       p_TipResPerLect   	LIKE dba.sga_datos_censales.tipo_res_per_lect,
       p_CallePerLect    	LIKE dba.sga_datos_censales.calle_per_lect,
       p_NroPerLect      	LIKE dba.sga_datos_censales.numero_per_lect,
       p_PisoPerLect     	LIKE dba.sga_datos_censales.piso_per_lect,
       p_DptoPerLect     	LIKE dba.sga_datos_censales.dpto_per_lect,
       p_UnPerLect       	LIKE dba.sga_datos_censales.unidad_per_lect,
       p_LocPerLect      	LIKE dba.sga_datos_censales.loc_per_lect,
       p_CPPerLect       	LIKE dba.sga_datos_censales.cp_per_lect,
       p_TEPerLect       	LIKE dba.sga_datos_censales.te_per_lect,
       p_AlumFliaCar     	LIKE dba.sga_datos_censales.fliares_cargo_alum,
       p_AllegTipo    		LIKE dba.sga_datos_censales.tipo_allegado,
       p_AllegApePers    	LIKE dba.sga_datos_censales.apellido_pers_alleg,
       p_AllegNomPers    	LIKE dba.sga_datos_censales.nombre_pers_alleg,
       p_AllegCallePers  	LIKE dba.sga_datos_censales.calle_pers_alleg,
       p_AllegNroPers    	LIKE dba.sga_datos_censales.nro_pers_alleg,
       p_AllegPisoPers   	LIKE dba.sga_datos_censales.piso_pers_alleg,
       p_AllegDptoPers   	LIKE dba.sga_datos_censales.dpto_pers_alleg,
       p_AllegUnPers     	LIKE dba.sga_datos_censales.unidad_pers_alleg,
       p_AllegLocPers    	LIKE dba.sga_datos_censales.loc_pers_alleg,
       p_AllegCPPers     	LIKE dba.sga_datos_censales.cp_pers_alleg,
       p_AllegTEPers     	LIKE dba.sga_datos_censales.te_pers_alleg,
       p_compania_celular 	LIKE sga_datos_cen_aux.celular_compania,
       p_numero_celular 	LIKE sga_datos_cen_aux.celular_numero,
       p_cantidad_hijos 	LIKE sga_datos_cen_aux.cant_hijos_alum,
       pObra_soc_alu        CHAR(1),
       pUnido_hecho         CHAR(1),
       pResidencia          CHAR(1),
       pResPre_Otorg        DATE,
       pResPre_Venc         DATE,
       pBarrioPerLect      varchar(60),
       pBarrioAlleg        varchar(60) 
)

    RETURNING smallint,        -- 0- OK, -1- Error, 1-Observaciones
              integer,
              varchar(255);    -- mensaje



  DEFINE iStatus        smallint;
  DEFINE vcMsg          varchar(255);

  --variables para el manejo de excepciones
  DEFINE sql_err        integer;
  DEFINE isam_err       integer;
  DEFINE error_info     varchar(76);
  DEFINE v_user_error   varchar(10);

  -- variables locales.
  DEFINE vcNivel      VARCHAR(20);
  DEFINE vd_Fecha     DATE;
  DEFINE vc_Fecha     CHAR(10);
  DEFINE vc_Rtn       CHAR(1);

  -- blk de excepciones
  ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = sql_err;
     LET vcMsg = isam_err;
     RETURN iStatus,vcMsg ,error_info;
  END EXCEPTION; 


BEGIN
  
  LET iStatus = 0;
  LET vcMsg = 'Ok';
  
  
  -- Verifico si la persona tiene algun Dato Censal cargado.
  EXECUTE PROCEDURE sp_dato_cen_valido ( p_unidad_academica, p_nro_inscripcion ) INTO vc_Rtn;
  
  IF vc_Rtn = "I" THEN
     EXECUTE PROCEDURE sp_crea_datocensal( p_Unidad_academica, p_Nro_inscripcion );
  END IF;
  
  -- busco la fecha de relevamiento a actualizar.
  SELECT MAX(fecha_relevamiento)
    INTO vd_Fecha
    FROM sga_datos_censales
   WHERE unidad_academica = p_Unidad_academica
     AND nro_inscripcion  = p_Nro_inscripcion;
 
  -- actualizo los datos personales.
  UPDATE sga_personas
     SET residencia = pResidencia
        , fecha_respre_otorg = pResPre_Otorg
        , fecha_respre_venc  = pResPre_Venc
   WHERE unidad_academica = p_unidad_academica
     AND nro_inscripcion  = p_Nro_inscripcion;
  
  -- ACTUALIZO EL DATO CENSAL ANTERIOR.
  UPDATE sga_datos_censales
     SET fecha_actualiz     = TODAY,
         estado_civil       = p_EstadoCivil,
         turno_preferido    = p_TurnoPrefer,
         e_mail             = p_Email,
         tipo_visa          = p_TipoVisa,
         otorgamiento_visa  = p_OtorgVisa,
         vencimiento_visa   = p_VencimVisa,
         tipo_residencia    = p_TipoResidenc,
         tipo_res_per_lect  = p_TipResPerLect,
         calle_per_lect     = p_CallePerLect,
         numero_per_lect    = p_NroPerLect,
         piso_per_lect      = p_PisoPerLect,
         dpto_per_lect      = p_DptoPerLect,
         unidad_per_lect    = p_UnPerLect,
         loc_per_lect       = p_LocPerLect,
         cp_per_lect        = p_CPPerLect,
         te_per_lect        = p_TEPerLect,
         fliares_cargo_alum = p_AlumFliaCar,
         tipo_allegado  = p_AllegTipo,
         apellido_pers_alleg  = p_AllegApePers,
         nombre_pers_alleg  = p_AllegNomPers,
         calle_pers_alleg   = p_AllegCallePers,
         nro_pers_alleg     = p_AllegNroPers,
         piso_pers_alleg    = p_AllegPisoPers,
         dpto_pers_alleg    = p_AllegDptoPers,
         unidad_pers_alleg  = p_AllegUnPers,
         loc_pers_alleg     = p_AllegLocPers,
         cp_pers_alleg      = p_AllegCPPers,
         te_pers_alleg      = p_AllegTEPers
   WHERE unidad_academica   = p_Unidad_academica
     AND nro_inscripcion    = p_Nro_inscripcion
     AND fecha_relevamiento = vd_Fecha;
  
  -- Hace Update;
  UPDATE sga_datos_cen_aux
     SET celular_compania = p_compania_celular,
       celular_numero   = p_numero_celular,
       cant_hijos_alum  = p_cantidad_hijos,
       barrio_per_lec   = pBarrioPerLect,
       barrio_alleg     = pBarrioAlleg
	   
   WHERE unidad_academica   = p_Unidad_academica
     AND nro_inscripcion    = p_Nro_inscripcion
     AND fecha_relevamiento = vd_Fecha; 

   -- DATO CENSAL AUXILIAR SEGUNDO.
   UPDATE sga_datos_cen_aux2
      SET alu_obra_social  = pObra_soc_alu
        , alu_est_civil_uh = pUnido_hecho
   WHERE unidad_academica   = p_Unidad_academica
     AND nro_inscripcion    = p_Nro_inscripcion
     AND fecha_relevamiento = vd_Fecha; 

     
  RETURN iStatus,0,vcMsg ;
  
END;
END PROCEDURE;
-- ********************************** Fin procedure sp_i_datcen_posgra ***********************************************

GRANT EXECUTE ON sp_i_datcen_posgra TO public;

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.05.0, 2.9.1, 2.9.5
--
-- Procedure sp_r_datcen_posgra
-- Recupera el dato censal de la persona para la inscripcion a posgrados para GESTION.
-- *******************************************************************************
DROP PROCEDURE sp_r_datcen_posgra;
CREATE PROCEDURE sp_r_datcen_posgra ( p_unidad_academica like sga_datos_censales.unidad_academica,
                                      p_nro_inscripcion like sga_datos_censales.nro_inscripcion,
                                      p_periodo like sga_periodo_insc.periodo_inscripcio )
       RETURNING  VARCHAR(5),	-- vc_UA, 1
		 VARCHAR(10),	-- vc_NroInscrip, 2
		 VARCHAR(20),	-- p_periodo, 3
		 DATE,	-- vc_FechaRelev, 4
		 INTEGER,	-- vc_EstadoCivil, 5
		 VARCHAR(20),	-- vc_TurnoPrefer, 6
		 VARCHAR(50),	-- vc_Email, 7
		 VARCHAR(20),	-- vc_TipoVisa, 8
		 DATE,	-- vc_OtorgVisa, 9
		 DATE,	-- vc_VencimVisa, 10
		 CHAR(1),	-- vc_TipoResidenc, 11
		 INTEGER,	-- vc_TipResPerLect, 12
		 VARCHAR(50),	-- vc_CallePerLect, 13
		 VARCHAR(10),	-- vc_NroPerLect, 14
		 VARCHAR(3),	-- vc_PisoPerLect, 15
		 VARCHAR(5),	-- vc_DptoPerLect, 16
		 VARCHAR(3),	-- vc_UnPerLect, 17
		 INTEGER,	-- vc_LocPerLect, 18
		 VARCHAR(100),	-- vc_LocNomPerLect, 19
		 VARCHAR(60),	-- vc_DeptoPerLect, 20
		 VARCHAR(40),	-- vc_ProvPerLect, 21 
		 VARCHAR(40),	-- vc_PaisPerLect, 22
		 VARCHAR(15),	-- vc_CPPerLect, 23
		 VARCHAR(18),	-- vc_TEPerLect, 24
		 VARCHAR(60),	-- vc_AlumFliaCar, 25
		 CHAR(1),	-- vc_AllegTipo, 26
		 VARCHAR(60),	-- vc_AllegApePers, 27
		 VARCHAR(60),	-- vc_AllegNomPers, 28
		 VARCHAR(50),	-- vc_AllegCallePers,29
		 VARCHAR(10),	-- vc_AllegNroPers, 30
		 VARCHAR(3),	-- vc_AllegPisoPers, 31
		 VARCHAR(5),	-- vc_AllegDptoPers, 32
		 VARCHAR(3),	-- vc_AllegUnPers, 33
		 INTEGER,	-- vc_AllegLocPers, 34
		 VARCHAR(100),	-- vc_AllegLocNomPers, 35
		 VARCHAR(60),	-- vc_AllegDeptoPers, 36
		 VARCHAR(40),	-- vc_AllegProvPers, 37
		 VARCHAR(40),	-- vc_AllegPaisPers, 38
		 VARCHAR(15),	-- vc_AllegCPPers, 39
		 VARCHAR(18), 	-- vc_AllegTEPers, 40
		 VARCHAR(30),	-- vc_PersonaApell, 41
		 VARCHAR(30),	-- vc_PersonaNombre 42
		 VARCHAR(18),	-- vc_NroCelular 43
		 VARCHAR(5),	-- vc_CiaCelular 44
		 INTEGER,       -- vi_CantHijos 45
		 CHAR(1),       -- vc_alu_obra_soc 46
         CHAR(1),       -- vc_alu_unidohecho 47
         DATE,          -- fecha_res_otorg 48
         DATE,          -- fecha_res_venc 49
         CHAR(1),       --  residencia 50
		 VARCHAR(60),   -- Barrio periodo lectivo 51
		 VARCHAR(60);   -- Barrio Allegado 52

DEFINE vc_UA            LIKE dba.sga_datos_censales.unidad_academica;
DEFINE vc_NroInscrip    LIKE dba.sga_datos_censales.nro_inscripcion;
DEFINE vc_Periodo       LIKE dba.sga_periodo_insc.periodo_inscripcio;
DEFINE vc_FechaRelev    LIKE dba.sga_datos_censales.fecha_relevamiento;
DEFINE vc_EstadoCivil   LIKE dba.sga_datos_censales.estado_civil;
DEFINE vc_TurnoPrefer   LIKE dba.sga_datos_censales.turno_preferido;
DEFINE vc_Email         LIKE dba.sga_datos_censales.e_mail;
DEFINE vc_TipoVisa      LIKE dba.sga_datos_censales.tipo_visa;
DEFINE vc_OtorgVisa     LIKE dba.sga_datos_censales.otorgamiento_visa;
DEFINE vc_VencimVisa    LIKE dba.sga_datos_censales.vencimiento_visa;
DEFINE vc_TipoResidenc  LIKE dba.sga_datos_censales.tipo_residencia;
DEFINE vc_TipResPerLect LIKE dba.sga_datos_censales.tipo_res_per_lect;
DEFINE vc_CallePerLect  LIKE dba.sga_datos_censales.calle_per_lect;
DEFINE vc_NroPerLect    LIKE dba.sga_datos_censales.numero_per_lect;
DEFINE vc_PisoPerLect   LIKE dba.sga_datos_censales.piso_per_lect;
DEFINE vc_DptoPerLect   LIKE dba.sga_datos_censales.dpto_per_lect;
DEFINE vc_UnPerLect     LIKE dba.sga_datos_censales.unidad_per_lect;
DEFINE vc_LocPerLect    LIKE dba.sga_datos_censales.loc_per_lect;

DEFINE vc_LocNomPerLect LIKE dba.mug_localidades.nombre;
DEFINE vc_DeptoPerLect  LIKE dba.mug_dptos_partidos.nombre;
DEFINE vc_ProvPerLect   LIKE dba.mug_provincias.nombre;
DEFINE vc_PaisPerLect   LIKE dba.mug_paises.nombre;

DEFINE vc_CPPerLect     LIKE dba.sga_datos_censales.cp_per_lect;
DEFINE vc_TEPerLect     LIKE dba.sga_datos_censales.te_per_lect;

DEFINE vc_AlumFliaCar     LIKE dba.sga_datos_censales.fliares_cargo_alum;

DEFINE vc_AllegTipo          LIKE dba.sga_datos_censales.tipo_allegado;
DEFINE vc_AllegApePers    LIKE dba.sga_datos_censales.apellido_pers_alleg;
DEFINE vc_AllegNomPers    LIKE dba.sga_datos_censales.nombre_pers_alleg;
DEFINE vc_AllegCallePers  LIKE dba.sga_datos_censales.calle_pers_alleg;
DEFINE vc_AllegNroPers    LIKE dba.sga_datos_censales.nro_pers_alleg;
DEFINE vc_AllegPisoPers   LIKE dba.sga_datos_censales.piso_pers_alleg;
DEFINE vc_AllegDptoPers   LIKE dba.sga_datos_censales.dpto_pers_alleg;
DEFINE vc_AllegUnPers     LIKE dba.sga_datos_censales.unidad_pers_alleg;

DEFINE vc_AllegLocPers    LIKE dba.sga_datos_censales.loc_pers_alleg;
DEFINE vc_AllegLocNomPers LIKE dba.mug_localidades.nombre;
DEFINE vc_AllegDeptoPers  LIKE dba.mug_dptos_partidos.nombre;
DEFINE vc_AllegProvPers   LIKE dba.mug_provincias.nombre;
DEFINE vc_AllegPaisPers   LIKE dba.mug_paises.nombre;

DEFINE vc_AllegCPPers     LIKE dba.sga_datos_censales.cp_pers_alleg;
DEFINE vc_AllegTEPers     LIKE dba.sga_datos_censales.te_pers_alleg;
DEFINE vc_PersonaApell    LIKE dba.sga_personas.apellido;
DEFINE vc_PersonaNombre   LIKE dba.sga_personas.nombres;


DEFINE dFechaFin          LIKE sga_periodo_insc.fecha_fin;
DEFINE vd_Fecha           DATE;
DEFINE vc_Count           SMALLINT;

DEFINE vc_CiaCelular      like sga_datos_cen_aux.CELULAR_COMPANIA;
DEFINE vc_NroCelular      like sga_datos_cen_aux.CELULAR_NUMERO;
DEFINE vi_CantHijos       like sga_datos_cen_aux.CANT_HIJOS_ALUM;

DEFINE vc_alu_obra_soc    CHAR(1);
DEFINE vc_alu_unidohecho  CHAR(1);
DEFINE vd_fecha_res_otorg DATE;
DEFINE vd_fecha_res_venc  DATE;
DEFINE vc_residencia      CHAR(1);
DEFINE vc_barrio_per_lec varchar(60);
DEFINE vc_barrio_alleg varchar(60);



BEGIN

   -- Inicializaciones.
   LET vc_UA               = NULL;
   LET vc_NroInscrip       = NULL;
   LET vc_Periodo          = NULL;
   LET vc_FechaRelev       = NULL;
   LET vc_EstadoCivil      = NULL;
   LET vc_TurnoPrefer      = NULL;
   LET vc_Email            = NULL;
   LET vc_TipoVisa         = NULL;
   LET vc_OtorgVisa        = NULL;
   LET vc_VencimVisa       = NULL;
   LET vc_TipoResidenc     = NULL;
   LET vc_TipResPerLect    = NULL;
   LET vc_CallePerLect     = NULL;
   LET vc_NroPerLect       = NULL;
   LET vc_PisoPerLect      = NULL;
   LET vc_DptoPerLect      = NULL;
   LET vc_UnPerLect        = NULL;
   LET vc_LocPerLect       = NULL;
   LET vc_LocNomPerLect    = NULL;
   LET vc_DeptoPerLect     = NULL;
   LET vc_ProvPerLect      = NULL;
   LET vc_PaisPerLect      = NULL;
   LET vc_CPPerLect        = NULL;
   LET vc_TEPerLect        = NULL;
   LET vc_AlumFliaCar      = NULL;
   LET vc_AllegTipo     = NULL;
   LET vc_AllegApePers     = NULL;
   LET vc_AllegNomPers     = NULL;
   LET vc_AllegCallePers   = NULL;
   LET vc_AllegNroPers     = NULL;
   LET vc_AllegPisoPers    = NULL;
   LET vc_AllegDptoPers    = NULL;
   LET vc_AllegUnPers      = NULL;
   LET vc_AllegLocPers     = NULL;
   LET vc_AllegLocNomPers  = NULL;
   LET vc_AllegDeptoPers   = NULL;
   LET vc_AllegProvPers    = NULL;
   LET vc_AllegPaisPers    = NULL;
   LET vc_AllegCPPers      = NULL;
   LET vc_AllegTEPers      = NULL;
   LET vc_PersonaApell     = NULL;
   LET vc_PersonaNombre    = NULL;
   
   LET vc_NroCelular       = NULL;
   LET vc_CiaCelular       = NULL;
   LET vi_CantHijos        = NULL;
   LET vc_alu_obra_soc     = NULL;
   LET vc_alu_unidohecho   = NULL;
   LET vd_fecha_res_otorg  = NULL;
   LET vd_fecha_res_venc   = NULL;
   LET vc_residencia       = NULL;
   LET vc_barrio_per_lec   = NULL;
   LET vc_barrio_alleg     = NULL;
   
   
   -- Recupero el nombre de la persona.
   SELECT dba.sga_personas.apellido,
	      dba.sga_personas.nombres,
	      dba.sga_personas.fecha_respre_otorg,
	      dba.sga_personas.fecha_respre_venc,
	      dba.sga_personas.residencia
     INTO vc_PersonaApell,
          vc_PersonaNombre,
          vd_fecha_res_otorg,
          vd_fecha_res_venc,
          vc_residencia
     FROM dba.sga_personas
    WHERE dba.sga_personas.unidad_academica = p_unidad_academica
      AND dba.sga_personas.nro_inscripcion = p_nro_inscripcion;
   
   
   -- Verifico si existen ya cargados DC.
   SELECT COUNT(*)
     INTO vc_Count
     FROM sga_datos_censales
    WHERE unidad_academica = p_unidad_academica
      AND nro_inscripcion = p_nro_inscripcion;
   
   -- Ya existe un dato censal.
   IF vc_Count >= 1 THEN
      
      -- Averiguo el ultimo.
      SELECT MAX(fecha_relevamiento)
        INTO vd_Fecha
        FROM sga_datos_censales
       WHERE unidad_academica = p_unidad_academica
         AND nro_inscripcion = p_nro_inscripcion;
      
      
      -- Recupero los datos.
      SELECT dba.sga_datos_censales.unidad_academica,
             dba.sga_datos_censales.nro_inscripcion,
             CURRENT YEAR TO DAY,
             dba.sga_datos_censales.estado_civil,
             dba.sga_datos_censales.turno_preferido,
             dba.sga_datos_censales.e_mail,
             dba.sga_datos_censales.tipo_visa,
             dba.sga_datos_censales.otorgamiento_visa,
             dba.sga_datos_censales.vencimiento_visa,
             dba.sga_datos_censales.tipo_residencia,
             dba.sga_datos_censales.tipo_res_per_lect,
             dba.sga_datos_censales.calle_per_lect,
             dba.sga_datos_censales.numero_per_lect,
             dba.sga_datos_censales.piso_per_lect,
             dba.sga_datos_censales.dpto_per_lect,
             dba.sga_datos_censales.unidad_per_lect,
             dba.sga_datos_censales.loc_per_lect,
             dba.sga_datos_censales.cp_per_lect,
             dba.sga_datos_censales.te_per_lect,
             dba.sga_datos_censales.fliares_cargo_alum,
             dba.sga_datos_censales.tipo_allegado,
             dba.sga_datos_censales.apellido_pers_alleg,
             dba.sga_datos_censales.nombre_pers_alleg,
             dba.sga_datos_censales.calle_pers_alleg,
             dba.sga_datos_censales.nro_pers_alleg,
             dba.sga_datos_censales.piso_pers_alleg,
             dba.sga_datos_censales.dpto_pers_alleg,
             dba.sga_datos_censales.unidad_pers_alleg,
             dba.sga_datos_censales.loc_pers_alleg,
             dba.sga_datos_censales.cp_pers_alleg,
             dba.sga_datos_censales.te_pers_alleg
        INTO vc_UA,
             vc_NroInscrip,
             vc_FechaRelev,
             vc_EstadoCivil,
             vc_TurnoPrefer,
             vc_Email,
             vc_TipoVisa,
             vc_OtorgVisa,
             vc_VencimVisa,
             vc_TipoResidenc,
             vc_TipResPerLect,
             vc_CallePerLect,
             vc_NroPerLect,
             vc_PisoPerLect,
             vc_DptoPerLect,
             vc_UnPerLect,
             vc_LocPerLect,
             vc_CPPerLect,
             vc_TEPerLect,
             vc_AlumFliaCar,
             vc_AllegTipo,
             vc_AllegApePers,
             vc_AllegNomPers,
             vc_AllegCallePers,
             vc_AllegNroPers,
             vc_AllegPisoPers,
             vc_AllegDptoPers,
             vc_AllegUnPers,
             vc_AllegLocPers,
             vc_AllegCPPers,
             vc_AllegTEPers
			 
        FROM dba.sga_datos_censales
       WHERE dba.sga_datos_censales.unidad_academica   = p_unidad_academica
         AND dba.sga_datos_censales.nro_inscripcion    = p_nro_inscripcion
         AND dba.sga_datos_censales.fecha_relevamiento = vd_Fecha;
      
      SELECT sga_datos_cen_aux.CELULAR_COMPANIA,
             sga_datos_cen_aux.CELULAR_NUMERO,
             sga_datos_cen_aux.CANT_HIJOS_ALUM,
			 sga_datos_cen_aux.barrio_per_lec,
			 sga_datos_cen_aux.barrio_alleg
			 
        INTO vc_CiaCelular,
             vc_NroCelular,
             vi_CantHijos,
			 vc_barrio_per_lec,
			 vc_barrio_alleg
        FROM sga_datos_cen_aux
       WHERE unidad_academica = p_unidad_academica
         AND nro_inscripcion  = p_nro_inscripcion
         AND fecha_relevamiento = vd_Fecha;
      
      -- Recupero Datos Censales Principales del Segundo Auxiliar.
      SELECT sga_datos_cen_aux2.alu_obra_social,    
             sga_datos_cen_aux2.alu_est_civil_uh
        INTO vc_alu_obra_soc,   
             vc_alu_unidohecho
        FROM sga_datos_cen_aux2
       WHERE sga_datos_cen_aux2.unidad_academica   = p_unidad_academica
         AND sga_datos_cen_aux2.nro_inscripcion    = p_nro_inscripcion
         AND sga_datos_cen_aux2.fecha_relevamiento = vd_Fecha;
      
   END IF;
   

   -- Recupero los datos de UG del periodo lectivo.
   IF vc_LocPerLect IS NOT NULL THEN
      
      SELECT dba.mug_localidades.nombre,
             dba.mug_dptos_partidos.nombre,
             dba.mug_provincias.nombre,
             dba.mug_paises.nombre
        INTO vc_LocNomPerLect,
             vc_DeptoPerLect,
             vc_ProvPerLect,
             vc_PaisPerLect
        FROM dba.mug_localidades,
             dba.mug_dptos_partidos,
             dba.mug_provincias,
             dba.mug_paises
       WHERE dba.mug_localidades.localidad     = vc_LocPerLect
         AND dba.mug_localidades.dpto_partido  = dba.mug_dptos_partidos.dpto_partido
         AND dba.mug_dptos_partidos.provincia  = dba.mug_provincias.provincia
         AND dba.mug_provincias.pais           = dba.mug_paises.pais;

   END IF;
   
   -- Recupero los datos de UG de la Persona Allegada.
   IF vc_AllegLocPers IS NOT NULL THEN

      SELECT dba.mug_localidades.nombre,
             dba.mug_dptos_partidos.nombre,

             dba.mug_provincias.nombre,
             dba.mug_paises.nombre
        INTO vc_AllegLocNomPers,
             vc_AllegDeptoPers,
             vc_AllegProvPers,
             vc_AllegPaisPers
        FROM dba.mug_localidades,
             dba.mug_dptos_partidos,
             dba.mug_provincias,
             dba.mug_paises
       WHERE dba.mug_localidades.localidad     = vc_AllegLocPers
         AND dba.mug_localidades.dpto_partido  = dba.mug_dptos_partidos.dpto_partido
         AND dba.mug_dptos_partidos.provincia  = dba.mug_provincias.provincia
         AND dba.mug_provincias.pais           = dba.mug_paises.pais;
      
   END IF;
   
   -- VALORES QUE TIENEN QUE FIGURAR SI NO EXISTIERA NINGUN DATO CENSAL DE LA PERSONA!   
   IF vc_UA IS NULL THEN
      LET vc_UA = p_unidad_academica;
   END IF;
   
   IF vc_NroInscrip IS NULL THEN
      LET vc_NroInscrip = p_nro_inscripcion;
   END IF;
   
   IF vc_Periodo IS NULL THEN
      LET vc_Periodo = p_periodo;
   END IF;
   

   IF vc_FechaRelev IS NULL THEN
      LET vc_FechaRelev = CURRENT YEAR TO DAY;
   END IF;
   
   RETURN vc_UA,
          vc_NroInscrip,
          p_periodo,	-- Periodo de Inscripcion o Reinscripcion a generar el dato censal.
          vc_FechaRelev,
          vc_EstadoCivil,
          vc_TurnoPrefer,
          vc_Email,
          vc_TipoVisa,
          vc_OtorgVisa,
          vc_VencimVisa,
          vc_TipoResidenc,
          vc_TipResPerLect,
          vc_CallePerLect,
          vc_NroPerLect,
          vc_PisoPerLect,
          vc_DptoPerLect,
          vc_UnPerLect,
          vc_LocPerLect,
          vc_LocNomPerLect,
          vc_DeptoPerLect, -- 20
          vc_ProvPerLect,
          vc_PaisPerLect,
          vc_CPPerLect,
          vc_TEPerLect,
          vc_AlumFliaCar,
          vc_AllegTipo,
          vc_AllegApePers,
          vc_AllegNomPers,
          vc_AllegCallePers,
          vc_AllegNroPers,  -- 30
          vc_AllegPisoPers,
          vc_AllegDptoPers,
          vc_AllegUnPers,
          vc_AllegLocPers,
          vc_AllegLocNomPers,
          vc_AllegDeptoPers,
          vc_AllegProvPers,
          vc_AllegPaisPers,
          vc_AllegCPPers,
          vc_AllegTEPers, -- 40
          vc_PersonaApell,
          vc_PersonaNombre,
          vc_NroCelular,
          vc_CiaCelular,
          vi_CantHijos, 
          vc_alu_obra_soc,   
          vc_alu_unidohecho,
          vd_fecha_res_otorg,
          vd_fecha_res_venc,
          vc_residencia,
          vc_barrio_per_lec,
          vc_barrio_alleg;
   
END;
END PROCEDURE;
-- ************************************* Fin procedure sp_r_datcen_posgra ******************************************

GRANT EXECUTE ON sp_r_datcen_posgra TO public;



-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
INSERT INTO app_versiones ( version, fecha_generacion, fecha_actualiz, script_corrido )
     VALUES ( "CNV2.09.5" , TODAY, CURRENT YEAR TO SECOND, 10);
-- *************************************************************************************
-- *************************************************************************************
-- Verifico que se haya corrido script anterior
EXECUTE PROCEDURE sp_soy_dba();
EXECUTE PROCEDURE sp_validar_scripts('CNV2.09.5', 10);
-- *************************************************************************************

ALTER TABLE gda_anuncios DROP CONSTRAINT ck_anuncio_tipo;
ALTER TABLE gda_anuncios
       ADD CONSTRAINT CHECK (tipo_anuncio IN ('U','D','A','P','C','O','B','X','M','T','Y','I','J','G','L','N','Z'))
       CONSTRAINT ck_anuncio_tipo;

-- *******************************************************************************
-- SIU - Sistema de Gestion de Alumnos
-- Version 2.03.0
-- Ultima Version de Modificación 2.6.0, 2.7.0, 2.8.0, 2.9.2, 2.9.5
-- PROCEDURE: sp_i_anuncio
-- 
-- Graba un anuncio de cualquier tipo
-- *******************************************************************************
DROP PROCEDURE sp_i_anuncio;
CREATE PROCEDURE sp_i_anuncio (
     pTipoAnuncio LIKE gda_anuncios.tipo_anuncio,
     pUnidadAcad  LIKE gda_anuncios.unidad_academica,
     pNroInscrip  LIKE gda_anuncios.nro_inscripcion,
     pCarrera     LIKE gda_anuncios.carrera,
     pCurso       LIKE gda_anuncios.curso,
     pFechaDesde  VARCHAR(10),
     pFechaHasta  VARCHAR(10),
     pTituloAnun  LIKE gda_anuncios.titulo_anuncio,
     pEnviaMail   LIKE gda_anuncios.enviado_por_mail,
     pEnviaSms    LIKE gda_anuncios.enviado_por_sms,
     pIntGest     LIKE gda_anuncios.INT_GESTION,
     pIntAuto     LIKE gda_anuncios.INT_AUTOGESTION,
     pIntTele     LIKE gda_anuncios.INT_TELEFONO,
     pIntInte     LIKE gda_anuncios.INT_INTERNET,
     pMensaje     LIKE gda_anuncios.mensaje,
     pLegajoDocente LIKE gda_anuncios.docente_envia,
     pTodosAlgunos LIKE gda_anuncios.todos_algunos,
     pAnioAcademico LIKE gda_anuncios.anio_academico,
     pPeriodoLectivo LIKE gda_anuncios.periodo_lectivo,
     pMateria LIKE gda_anuncios.materia,
     pSede LIKE gda_anuncios.sede)

   RETURNING INTEGER, VARCHAR(255); 
/*
Retorna:
 INTEGER,      --  0: OK / -1: Error / 0: nro de anuncio
 VARCHAR(255)  -- mensaje
*/

  DEFINE d_fecha_desde LIKE gda_anuncios.fecha_desde;
  DEFINE d_fecha_hasta LIKE gda_anuncios.fecha_hasta;
  DEFINE iStatus       INTEGER;
  DEFINE vcMsg         VARCHAR(255);
  DEFINE iAnuncio INTEGER;
  DEFINE iAnioAcademico INTEGER;
  -- DEFINE vcTipo char(1);
  DEFINE vcSede LIKE gda_anuncios.sede;
  DEFINE vcCarrera LIKE sga_carreras.carrera;
  DEFINE vEstadoEnvioMail char(1);
    
  -- Variables para el manejo de excepciones
  DEFINE sql_err    INTEGER;
  DEFINE isam_err   INTEGER;
  DEFINE error_info VARCHAR(76);


  -- bloque de excepciones
  ON EXCEPTION SET sql_err, isam_err, error_info                                        
    LET iStatus = -1 ;
    LET vcMsg = sql_err || ' , ' || error_info;
        RETURN iStatus, vcMsg;
  END EXCEPTION; 

 
BEGIN

 BEGIN

     ON EXCEPTION SET sql_err, isam_err, error_info
       -- Si entro por aca, es porque se ingreso una fecha con diferente formato o no valida.
       LET vcMsg = 'La fecha (' || pFechaDesde || ') no es una fecha válida' ;
       RETURN -1,'800000,' || vcMsg;	
      END EXCEPTION;

      IF SUBSTR(pFechaDesde,3,1) = '/' THEN
        LET d_fecha_desde = to_date(pFechaDesde, "%d/%m/%Y");
      ELIF  SUBSTR(pFechaDesde,3,1) = '-' THEN
        LET d_fecha_desde = to_date(pFechaDesde, "%d-%m-%Y");
      ELSE
        -- Error
        LET vcMsg = 'Formato de fecha desde no válido. Formato válido: dd/mm/aaaa' ;
        RETURN -1,'800000,' || vcMsg;	
      END IF;
 END;	

 BEGIN
  ON EXCEPTION SET sql_err, isam_err, error_info
    -- Si entro por aca, es porque se ingreso una fecha con diferente formato o no valida.
    LET vcMsg = 'La fecha (' || pFechaHasta || ') no es una fecha válida' ;
    RETURN -1,'800000,' || vcMsg;	
   END EXCEPTION;

  IF SUBSTR(pFechaHasta,3,1) = '/' THEN
    LET d_fecha_hasta = to_date(pFechaHasta, "%d/%m/%Y");
  ELIF  SUBSTR(pFechaHasta,3,1) = '-' THEN
    LET d_fecha_hasta = to_date(pFechaHasta, "%d-%m-%Y");
  ELSE
     -- Error
    LET vcMsg = 'Formato de fecha hasta no válido. Formato válido: dd/mm/aaaa' ;
    RETURN -1,'800000,' || vcMsg;	
  END IF;
 END;
   
 BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
     -- Si entro por aca, es porque se ingreso una fecha incorrecta.
   END EXCEPTION;

   IF d_fecha_hasta < d_fecha_desde THEN
	       -- ERROR
				LET vcMsg = 'La fecha Desde debe ser menor que Hasta' ;
				RETURN -1,'800000,' || vcMsg;	
	  ELIF d_fecha_desde < TODAY  THEN
	   	  --  ERROR
				LET vcMsg = 'La fecha Desde no debe ser menor que la Actual' ;
				RETURN -1,'800000,' || vcMsg;	
	 END IF;  	  
	     	   
   END;
   
   LET iAnuncio = NULL;
   -- IF pTipoAnuncio = 'O' OR pTipoAnuncio = 'M' THEN
   --  LET vcTipo = 'R';
   -- ELSE
   --   LET vcTipo = pTipoAnuncio;
   -- END IF;
  
   IF pSede = 'Todas' THEN
     LET vcSede = NULL;
   ELSE
     LET vcSede = pSede;
   END IF;     
   IF pCarrera = 'TODOS' THEN
     LET vcCarrera = NULL;
   ELSE
     LET vcCarrera = pCarrera;
   END IF;     

   LET vEstadoEnvioMail = 'N'; -- No se envia mail
   IF pEnviaMail = 'S' THEN
      -- Se envia el mail, debo ver si el mensaje fue enviado por el docente
      -- Si fue enviado por el docente desde autogestion, entonces marco como que ya se envio el mail
      IF pLegajoDocente IS NOT NULL THEN
         LET vEstadoEnvioMail = 'E';  -- Mail Enviado
      ELSE
         LET vEstadoEnvioMail = 'P';  -- Mail Pendiente de Envio
      END IF;
   END IF;

   -- Doy de alta el mensaje
   INSERT INTO gda_anuncios (tipo_anuncio,  unidad_academica, nro_inscripcion, carrera, curso, fecha_desde, fecha_hasta, 
       titulo_anuncio,  enviado_por_mail,  enviado_por_sms, fecha_de_registro, INT_GESTION, INT_AUTOGESTION,INT_TELEFONO, INT_INTERNET, 
       mensaje, docente_envia, todos_algunos, anio_academico, periodo_lectivo, materia, sede)
   VALUES (pTipoAnuncio, pUnidadAcad, pNroInscrip,  vcCarrera, pCurso, d_fecha_desde, d_fecha_hasta,
           pTituloAnun, pEnviaMail, pEnviaSms, CURRENT, pIntGest, pIntAuto,  pIntTele, pIntInte, 
           pMensaje, pLegajoDocente, pTodosAlgunos, pAnioAcademico, pPeriodoLectivo, pMateria, vcSede);


  LET iStatus = DBINFO("sqlca.sqlerrd1");
  LET iAnuncio = iStatus; -- DBINFO("sqlca.sqlerrd2");  -- ID del Anuncio

  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Genero los destinatarios del Mensaje
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IF pTipoAnuncio = 'Z' THEN

    -- Z: Alumnos Extranjeros
    INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT DISTINCT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_alumnos as a, sga_personas as p
        WHERE a.calidad = 'A'
         AND p.unidad_academica = a.unidad_academica
         AND p.nro_inscripcion  = a.nro_inscripcion
         AND (pCarrera = 'TODOS' OR a.carrera = pCarrera)
         AND p.nacionalidad = 2; -- Extranjero

  END IF;

  IF pTipoAnuncio = 'G' THEN
     -- G: Grupo de alumnos y/o docentes
     -- Estos se agregan por fuera de este procedure luego de que este sea ejecutado.
  END IF;
  

  IF pTipoAnuncio = 'U' THEN
    -- U: El mensaje se envia a la unidad academica (Alumnos y Docentes)
    INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, d.unidad_academica, d.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_docentes as d;

     --  Alumnos que no son docentes
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT DISTINCT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_alumnos as a
        WHERE a.calidad = 'A'
         AND a.nro_inscripcion NOT IN (SELECT nro_inscripcion FROM sga_docentes)
         AND (pSede = 'Todas' OR a.sede = pSede); 

  END IF;

  
  IF pTipoAnuncio = 'P' THEN
     -- P: El mensaje se envia a una persona
     -- Mensaje a una persona (Alumno, Docente...)
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       VALUES (iAnuncio, pUnidadAcad, pNroInscrip, vEstadoEnvioMail);
  END IF;

  IF pTipoAnuncio = 'A' THEN
    -- A: El mensaje se envia a todos los Alumnos Activos
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT distinct iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_alumnos as a
        WHERE a.calidad = 'A'
          AND (pSede = 'Todas' OR a.sede = pSede); 
  END IF;

  IF pTipoAnuncio = 'D' THEN
     -- D: Todos los docentes
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, d.unidad_academica, d.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_docentes as d;
  END IF;

  IF (pTipoAnuncio = 'O' AND pTodosAlgunos = 'T') OR pTipoAnuncio = 'X' THEN
     -- O: Alumnos inscriptos en una comision
     -- X: Alumnos y docentes de una comision (TODOS)
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM gda_cursos_com as cc,
              sga_insc_cursadas as i,
              sga_alumnos as a
        WHERE cc.curso = pCurso
          AND i.comision = cc.comision
          AND a.unidad_academica = i.unidad_academica 
          AND a.carrera          = i.carrera
          AND a.legajo           = i.legajo;
  END IF;

  IF (pTipoAnuncio = 'B' AND pTodosAlgunos = 'T') OR pTipoAnuncio = 'X' THEN
     -- B: Docentes de una comisión
     -- X: Alumnos y docentes de una comision
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, d.unidad_academica, d.nro_inscripcion, vEstadoEnvioMail 
         FROM gda_cursos_com as cc,
              sga_docentes_com as dc,
              sga_docentes as d
        WHERE cc.curso = pCurso
          AND dc.comision = cc.comision
          AND d.legajo = dc.legajo;
  END IF;

  IF pTipoAnuncio = 'L'  THEN
     -- L: Alumnos inscriptos en comisiones de un periodo lectivo
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT DISTINCT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_comisiones as cc,
                    sga_insc_cursadas as i,
                   sga_alumnos as a
        WHERE cc.anio_academico = pAnioAcademico
          AND cc.periodo_lectivo = pPeriodoLectivo
          AND i.comision = cc.comision
          AND a.unidad_academica = i.unidad_academica 
          AND a.carrera          = i.carrera
          AND a.legajo           = i.legajo
          AND (pSede = 'Todas' OR a.sede = pSede); 
  END IF;

  IF pTipoAnuncio = 'N'  THEN
     -- N: Alumnos inscriptos en comisiones de un periodo lectivo y materia
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT DISTINCT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_comisiones as cc,
              sga_insc_cursadas as i,
              sga_alumnos as a
        WHERE cc.anio_academico = pAnioAcademico
          AND cc.periodo_lectivo = pPeriodoLectivo
          AND cc.materia = pMateria 
          AND i.comision = cc.comision
          AND a.unidad_academica = i.unidad_academica 
          AND a.carrera          = i.carrera
          AND a.legajo           = i.legajo
          AND (pSede = 'Todas' OR a.sede = pSede); 
  END IF;

  IF (pTipoAnuncio = 'M' AND pTodosAlgunos = 'T') OR pTipoAnuncio = 'Y' THEN
     -- M: Alumnos inscriptos en una mesa de examen y llamado
     -- Y: Alumnos y Docentes de una mesa de examen (TODOS)
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM gda_cursos_mesa as cm,
              sga_insc_examen as i,
              sga_alumnos as a
        WHERE cm.curso = pCurso
          AND i.unidad_academica = cm.unidad_academica 
          AND i.materia          = cm.materia
          AND i.anio_academico   = cm.anio_academico
          AND i.turno_examen     = cm.turno_examen
          AND i.mesa_examen      = cm.mesa_examen
          AND i.llamado          = cm.llamado
          AND a.unidad_academica = i.unidad_academica 
          AND a.carrera          = i.carrera
          AND a.legajo           = i.legajo;
  END IF;

  IF (pTipoAnuncio = 'T' AND pTodosAlgunos = 'T') OR pTipoAnuncio = 'Y' THEN
     -- T: Docentes de una mesa de examen
     -- Y: Alumnos y Docentes de una mesa de examen (TODOS)
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, d.unidad_academica, d.nro_inscripcion, vEstadoEnvioMail 
         FROM gda_cursos_mesa as cm,
              sga_docentes_llama as dll,
              sga_docentes as d
        WHERE cm.curso = pCurso
          AND dll.unidad_academica = cm.unidad_academica 
          AND dll.materia          = cm.materia
          AND dll.anio_academico   = cm.anio_academico
          AND dll.turno_examen     = cm.turno_examen
          AND dll.mesa_examen      = cm.mesa_examen
          AND dll.llamado          = cm.llamado
          AND d.legajo = dll.legajo;
  END IF;


  IF pTipoAnuncio = 'C' THEN
    -- C: El mensaje se envia a toda una carrera
    -- Mensaje a una carrera. Alumnos activos.
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_alumnos as a
        WHERE a.unidad_academica = pUnidadAcad
          AND (pCarrera = 'TODOS' OR a.carrera = pCarrera)
          AND a.calidad = 'A'
          AND (pSede = 'Todas' OR a.sede = pSede); 
  END IF;
  
  -- I: Todos los ingresantes en todas las carreras. Alumnos Activos o Condicionales
  -- J: Ingresantes en una carrera. Alumnos Activos o Condicionales
  IF pTipoAnuncio = 'I' OR pTipoAnuncio = 'J' THEN
     LET iAnioAcademico = NULL;
     IF pAnioAcademico IS NOT NULL THEN
         LET iAnioAcademico = pAnioAcademico;
     ELSE      
       -- Busca el año académico actual
       SELECT max(anio_academico)  INTO iAnioAcademico FROM sga_anio_academico WHERE TODAY BETWEEN fecha_inicio AND fecha_fin;
     END IF;
  END IF;
  
  IF pTipoAnuncio = 'I' THEN
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT DISTINCT iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_alumnos as a,
              sga_carrera_aspira as c,
              sga_periodo_insc as p
        WHERE c.unidad_academica = a.unidad_academica
          AND c.carrera = a.carrera
          AND c.nro_inscripcion = a.nro_inscripcion
          AND p.periodo_inscripcio = c.periodo_inscripcio
          AND p.anio_academico = iAnioAcademico
          AND a.calidad IN ('A', 'C')
          AND (pSede = 'Todas' OR a.sede = pSede); 
  END IF;


  IF pTipoAnuncio = 'J' THEN
     INSERT INTO gda_anuncios_log (anuncio, unidad_academica, nro_inscripcion, envio_mail) 
       SELECT distinct iAnuncio, a.unidad_academica, a.nro_inscripcion, vEstadoEnvioMail 
         FROM sga_alumnos as a,
              sga_carrera_aspira as c,
              sga_periodo_insc as p
        WHERE a.unidad_academica = pUnidadAcad
          AND (pCarrera = 'TODOS' OR a.carrera = pCarrera)
          AND c.unidad_academica = a.unidad_academica
          AND c.carrera = a.carrera
          AND c.nro_inscripcion = a.nro_inscripcion
          AND p.periodo_inscripcio = c.periodo_inscripcio
          AND p.anio_academico = iAnioAcademico
          AND a.calidad IN ('A', 'C')
          AND (pSede = 'Todas' OR a.sede = pSede); 
  END IF;

  -- ++++++++++++++ Fin destinatarios Mensajes ++++++++++++++

  RETURN iStatus, '800000, Anuncio creado';


END;
END PROCEDURE;
-- *************************** Fin procedure sp_i_anuncio ****************************************************

GRANT EXECUTE ON sp_i_anuncio TO public;

-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
INSERT INTO app_versiones ( version, fecha_generacion, fecha_actualiz, script_corrido )
     VALUES ( "CNV2.09.5" , TODAY, CURRENT YEAR TO SECOND, 11);
-- *************************************************************************************
-- *************************************************************************************
-- Verifico que se haya corrido script anterior
EXECUTE PROCEDURE sp_soy_dba();
EXECUTE PROCEDURE sp_validar_scripts('CNV2.09.5', 11);
-- *************************************************************************************

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1, 2.9.5
-- Procedure sp_intcon_alu_car
--
-- Cantidad de Alumnos que cursan la carrera en un año.
-- *****************************************************************************
DROP PROCEDURE sp_intcon_alu_car;
CREATE PROCEDURE sp_intcon_alu_car (pUnidadAcademica VARCHAR(5),
                                    pCarrera         VARCHAR(5), 
                                    pAnio            INTEGER) 
       RETURNING INTEGER;  -- Cantidad de alumnos

-- Variables locales
DEFINE cnt_alumnos INTEGER;

-- Variables para el manejo de excepciones
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN
   
   LET cnt_alumnos = 0;
   
{ --Calculo con formato anterior de Araucano
     -- Nuevos inscriptos
   SELECT COUNT(*)
     INTO cnt_alumnos_nu
     FROM int_arau_nuinscrip
    WHERE unidad_academica = pUnidadAcademica
      AND carrera          = pCarrera
      AND anio_academico   = pAnio;
   
   -- Reinscriptos
   SELECT COUNT(*)
     INTO cnt_alumnos_re
     FROM int_arau_reinscrip
    WHERE unidad_academica = pUnidadAcademica
      AND carrera          = pCarrera
      AND anio_academico   = pAnio;
   
   RETURN cnt_alumnos_nu + cnt_alumnos_re ;		
   
}
   
   -- ARAUCANO NOMINAL. Nuevos inscriptos y reinscriptos. No considera los egresados
   SELECT COUNT(DISTINCT legajo)
     INTO cnt_alumnos
     FROM int_araunom_oferta
    WHERE anio_academico = pAnio
      AND carrera        = pCarrera
	  AND fecha_egreso IS NULL;
   
  
   RETURN cnt_alumnos;		
   
END;
END PROCEDURE;
-- ************************ Fin del procedure sp_intcon_alu_car ************************

GRANT EXECUTE ON sp_intcon_alu_car TO public;

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1, 2.9.5
-- Procedure sp_intcon_cnt_ingr
-- 
-- Esta contando todos los ingresantes en la unidad academica para un 
-- determinado año académico, trayendo la información que se encuentra en las tablas de interfaz con araucano.
-- Se basa en la tabla de Araucano Nominal: int_araunom_oferta
-- *****************************************************************************
DROP PROCEDURE sp_intcon_cnt_ingr;
CREATE PROCEDURE sp_intcon_cnt_ingr (pAnio INTEGER)
       RETURNING integer;    -- Cantidad de ingresantes

-- Variables locales
DEFINE cnt_ingresantes  INTEGER;

-- Variables para el manejo de excepciones
DEFINE SQLErr           INTEGER;
DEFINE ISAMError        INTEGER;
DEFINE errorInfo        VARCHAR(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN
   
   LET cnt_ingresantes = 0;
{ -- Calculo con formato anterior de Araucano.
   -- Ingresantes. cuento por persona.
   SELECT COUNT(DISTINCT legajo) INTO cnt_ingresantes
     FROM int_arau_nuinscrip
    WHERE anio_academico = pAnio;
}   
   -- Ingresantes. cuento por persona. Los que tienen año de ingreso igual al año a informar.
   SELECT COUNT(DISTINCT legajo) INTO cnt_ingresantes
     FROM int_araunom_oferta
    WHERE anio_academico = pAnio
	  AND anio_ingreso = pAnio;
   
   RETURN cnt_ingresantes;
   
END;
END PROCEDURE;
-- ************************ Fin del procedure sp_intcon_cnt_ingr ************************

GRANT EXECUTE ON sp_intcon_cnt_ingr TO public;

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1
-- Procedure cnt_alu_car_ingan
--
-- Cantidad de Alumnos que cursan la carrera en un año y que ingresaron en otro año.
-- Cursar = estan en las tablas int_arau_nuinscrip e int_arau_reinscrip..
-- *****************************************************************************
DROP PROCEDURE sp_intcon_curinan;
CREATE PROCEDURE sp_intcon_curinan (
  pUnidadAcademica varchar(5), 
  pCarrera varchar(5), 
  pAnioIngreso INTEGER, 
  pAnioCursada INTEGER)
RETURNING integer;           -- Cantidad de alumnos

-- Variables locales
DEFINE cnt_alumnos smallint;
DEFINE cnt_nuinscriptos smallint;
DEFINE cnt_reinscriptos smallint;

-- Variables para el manejo de excepciones
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN
   
   LET cnt_alumnos = 0;
{ 
   -- Esto se calculaba con el formato anterior de ARaucano
   LET cnt_nuinscriptos = 0;
   LET cnt_reinscriptos = 0;
   IF pAnioIngreso = pAnioCursada THEN
      
      SELECT COUNT(*)
        INTO cnt_nuinscriptos
        FROM int_arau_nuinscrip
       WHERE anio_academico=pAnioCursada
         AND unidad_academica=pUnidadAcademica
         AND carrera=pCarrera;
      
   END IF;
   
   SELECT COUNT(*)
     INTO cnt_reinscriptos
     FROM int_arau_reinscrip
    WHERE anio_academico=pAnioCursada
      AND unidad_academica=pUnidadAcademica
      AND carrera=pCarrera
      AND anio_ingreso=pAnioIngreso;
   
   LET cnt_alumnos=cnt_nuinscriptos + cnt_reinscriptos;
}

   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- Calculo con ARAUCANO NOMINAL
   -- No paso dato del plan de estudios.
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   EXECUTE PROCEDURE sp_intcon_curinanp (pUnidadAcademica, pCarrera, NULL, pAnioIngreso, pAnioCursada) INTO cnt_alumnos;
   
   RETURN cnt_alumnos;
   
END;
END PROCEDURE;
-- ************************ Fin del procedure sp_intcon_curinan ************************

GRANT EXECUTE ON sp_intcon_curinan TO public;

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1, 2.9.5
-- Procedure cnt_alu_cur_inganp
--
-- Cantidad de Alumnos de un plan de estudios que cursan la carrera en un año y que ingresaron en otro año.
-- *****************************************************************************
DROP PROCEDURE sp_intcon_curinanp;
CREATE PROCEDURE sp_intcon_curinanp ( 
   pUnidadAcademica VARCHAR(5),
   pCarrera         VARCHAR(5),
   pPlan            VARCHAR(5),
   pAnioIngreso     INTEGER,
   pAnioCursada     INTEGER ) 
 RETURNING INTEGER;   -- Cantidad de alumnos


-- Variables locales
DEFINE cnt_alumnos smallint;

-- Variables para el manejo de excepciones
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN

   LET cnt_alumnos = 0;

{ -- Calculo con Araucano formato anterior
   LET cnt_nuinscriptos = 0;
   LET cnt_reinscriptos = 0;
   IF pAnioIngreso = pAnioCursada THEN
      
      SELECT count(*)
        INTO cnt_nuinscriptos
        FROM int_arau_nuinscrip, sga_alumnos
       WHERE int_arau_nuinscrip.anio_academico=pAnioCursada
         AND int_arau_nuinscrip.unidad_academica=pUnidadAcademica
         AND int_arau_nuinscrip.carrera=pCarrera
         AND int_arau_nuinscrip.unidad_academica = sga_alumnos.unidad_academica
         AND int_arau_nuinscrip.carrera = sga_alumnos.carrera
         AND int_arau_nuinscrip.legajo = sga_alumnos.legajo
         AND sga_alumnos.plan = pPlan;
      
   END IF;
   
   SELECT COUNT(*)
     INTO cnt_reinscriptos
     FROM int_arau_reinscrip, sga_alumnos
    WHERE anio_academico=pAnioCursada
      AND int_arau_reinscrip.unidad_academica=pUnidadAcademica
      AND int_arau_reinscrip.carrera=pCarrera
      AND int_arau_reinscrip.anio_ingreso=pAnioIngreso
      AND int_arau_reinscrip.unidad_academica = sga_alumnos.unidad_academica
      AND int_arau_reinscrip.carrera = sga_alumnos.carrera
      AND int_arau_reinscrip.legajo = sga_alumnos.legajo
      AND sga_alumnos.plan = pPlan;
   
   LET cnt_alumnos=cnt_nuinscriptos + cnt_reinscriptos;	
}
   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- ARAUCANO NOMINAL.
   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   SELECT COUNT(DISTINCT sga_alumnos.legajo)
     INTO cnt_alumnos
     FROM int_araunom_oferta, 
	      sga_alumnos
    WHERE int_araunom_oferta.anio_academico   = pAnioCursada
      AND int_araunom_oferta.unidad_academica = pUnidadAcademica
      AND int_araunom_oferta.carrera          = pCarrera
      AND int_araunom_oferta.anio_ingreso     = pAnioIngreso
      AND sga_alumnos.unidad_academica = int_araunom_oferta.unidad_academica
      AND sga_alumnos.carrera          = int_araunom_oferta.carrera
      AND sga_alumnos.legajo           = int_araunom_oferta.legajo
      AND (pPlan IS NULL OR sga_alumnos.plan = pPlan);
   
   
   RETURN cnt_alumnos ;		
   
END;
END PROCEDURE;
-- ************************ Fin del procedure sp_intcon_curinanp ************************

GRANT EXECUTE ON sp_intcon_curinanp TO public;

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1, 2.06.2, 2.9.5
-- Procedure sp_intcon_eganineg
-- 
-- Cantidad de egresados de una carrera/plan según año de ingreso y de egreso
-- *****************************************************************************
DROP PROCEDURE sp_intcon_eganineg;
CREATE PROCEDURE sp_intcon_eganineg( 
   pUA            VARCHAR(5),
   pcarrera       VARCHAR(5),
   pPlan          VARCHAR(5),
   panio_acad_ing INTEGER,
   panio_acad_egr INTEGER )
 RETURNING integer;


DEFINE iCantEgresados      INTEGER;
DEFINE viduracion_carrera  INTEGER;
DEFINE dFechaInicioAnio, dFechaFinAnio date;

BEGIN
   LET iCantEgresados = 0;

{  -- Este calculo es con el formato anterior de Araucano. 
   -- Si el año de egreso es igual al de ingreso entonces traigo a los egresados que se recibieron antes de la duracion teorica estimada.
   IF (panio_acad_ing = panio_acad_egr) THEN
      
      -- averiguo la duracion teorica de la carrera 
      -- y traigo todos los que egresaron en menos tiempo!
      SELECT MAX(duracion_numerica)
        INTO viduracion_carrera
        FROM sga_planes
       WHERE unidad_academica = pUA
         AND carrera          = pCarrera
         AND plan             = pPlan;
      
      
      SELECT COUNT(*)
        INTO iCantEgresados
        FROM int_arau_egres,
             sga_alumnos
       WHERE int_arau_egres.anio_academico  <= panio_acad_ing + viduracion_carrera
         AND int_arau_egres.unidad_academica = pUA
         AND int_arau_egres.carrera          = pcarrera
         AND int_arau_egres.anio_ingreso     = panio_acad_ing
         AND sga_alumnos.unidad_academica = int_arau_egres.unidad_academica
         AND sga_alumnos.carrera          = int_arau_egres.carrera
         AND sga_alumnos.legajo           = int_arau_egres.legajo
         AND sga_alumnos.plan             = pPlan;
      
   ELSE
         
         SELECT COUNT(*)
           INTO iCantEgresados
           FROM int_arau_egres,
                sga_alumnos
          WHERE int_arau_egres.anio_academico   = panio_acad_egr
            AND int_arau_egres.unidad_academica = pUA
            AND int_arau_egres.carrera          = pcarrera
            AND int_arau_egres.anio_ingreso     = panio_acad_ing
            AND sga_alumnos.unidad_academica = int_arau_egres.unidad_academica
            AND sga_alumnos.carrera          = int_arau_egres.carrera
            AND sga_alumnos.legajo           = int_arau_egres.legajo
            AND sga_alumnos.plan             = pPlan;
         
   END IF;
 }

   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- ARAUCANO NOMINAL: Calcula egresados de una carrera y plan de estudios
   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   
   LET dFechaInicioAnio = to_date('0104' || panio_acad_egr, '%d%m%Y'); 
   LET dFechaFinAnio    = to_date('3103' || panio_acad_egr + 1, '%d%m%Y'); 
   
   SELECT COUNT(DISTINCT sga_alumnos.legajo)
     INTO iCantEgresados
     FROM int_araunom_oferta,
          sga_alumnos,
          sga_titulos_plan,
          sga_titulos
    WHERE int_araunom_oferta.anio_academico   = panio_acad_egr
      AND int_araunom_oferta.unidad_academica = pUA
      AND int_araunom_oferta.carrera          = pcarrera
      AND int_araunom_oferta.anio_ingreso     = panio_acad_ing
      AND int_araunom_oferta.fecha_egreso IS NOT NULL -- Egresados en el año academico informado...
      AND to_date(int_araunom_oferta.fecha_egreso,'%Y%m%d') BETWEEN dFechaInicioAnio AND dFechaFinAnio

      AND sga_alumnos.unidad_academica = int_araunom_oferta.unidad_academica
      AND sga_alumnos.carrera          = int_araunom_oferta.carrera
      AND sga_alumnos.legajo           = int_araunom_oferta.legajo
      AND sga_alumnos.plan             = pPlan
	  
      AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
      AND sga_titulos_plan.carrera = sga_alumnos.carrera
      AND sga_titulos_plan.plan    = sga_alumnos.plan

      AND sga_titulos.unidad_academica = sga_titulos_plan.unidad_academica
      AND sga_titulos.titulo           = sga_titulos_plan.titulo
      AND sga_titulos.titulo_araucano  = int_araunom_oferta.titulo_araucano
      AND sga_titulos.nivel            = 'GRADO'; -- Titulo que hace egresar al alumno.
 
   RETURN iCantEgresados;
   
END;
END PROCEDURE;
-- *****************************************************************************


GRANT EXECUTE ON sp_intcon_eganineg TO public;

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1
-- modificado v2.06.2, 2.9.5
-- Procedure cnt_egr_an_ing_egr
-- Cantidad de egresados de una carrera que ingresaron en un año académico y egresaron en otro
-- Recibe como parámetro la ua, la carrera, el año academico de ingreso de los alumnos y el año académico de egreso
-- Se basa en ARAUCANO NOMINAL. Debe haberse corrido el proceso de Araucano para el año académico "pAnio_acad_egr"
-- Retorna:  Cantidad de egresados
-- *****************************************************************************
DROP PROCEDURE sp_intcon_eganinep;
CREATE PROCEDURE sp_intcon_eganinep( 
   pUA            VARCHAR(5),
   pCarrera       VARCHAR(5),
   pPlan          VARCHAR(5),
   pAnio_acad_ing INTEGER,
   pAnio_acad_egr INTEGER )
 RETURNING INTEGER;

DEFINE iCantEgresados integer;
DEFINE dFechaInicioAnio, dFechaFinAnio date;

BEGIN
   LET iCantEgresados = 0;

   { -- Calculo con Araucano formato anterior.
   SELECT COUNT(*)
     INTO iCantEgresados
     FROM int_arau_egres,
          sga_alumnos
    WHERE int_arau_egres.anio_academico   = pAnio_acad_egr
      AND int_arau_egres.unidad_academica = pUA
      AND int_arau_egres.carrera          = pCarrera
      AND int_arau_egres.anio_ingreso     = pAnio_acad_ing
      AND sga_alumnos.unidad_academica = int_arau_egres.unidad_academica
      AND sga_alumnos.carrera          = int_arau_egres.carrera
      AND sga_alumnos.legajo           = int_arau_egres.legajo
      AND sga_alumnos.plan             = pPlan;
   }

   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- ARAUCANO NOMINAL. Cuenta alumnos egresados
   -- Realiza el distinct por si el alumno obtuvo otro titulo (intermedio) en el mismo año
   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   LET dFechaInicioAnio = to_date('0104' || pAnio_acad_egr, '%d%m%Y'); 
   LET dFechaFinAnio    = to_date('3103' || pAnio_acad_egr + 1, '%d%m%Y'); 

   SELECT COUNT(DISTINCT sga_alumnos.legajo)
     INTO iCantEgresados
     FROM int_araunom_oferta,
          sga_alumnos
    WHERE int_araunom_oferta.anio_academico   = pAnio_acad_egr
      AND int_araunom_oferta.unidad_academica = pUA
      AND int_araunom_oferta.carrera          = pCarrera
      AND int_araunom_oferta.anio_ingreso     = pAnio_acad_ing
      AND int_araunom_oferta.fecha_egreso IS NOT NULL -- Egresa el mismo año que el informado.
      AND to_date(int_araunom_oferta.fecha_egreso,'%Y%m%d') BETWEEN dFechaInicioAnio AND dFechaFinAnio
      AND sga_alumnos.unidad_academica = int_araunom_oferta.unidad_academica
      AND sga_alumnos.carrera          = int_araunom_oferta.carrera
      AND sga_alumnos.legajo           = int_araunom_oferta.legajo
      AND sga_alumnos.plan             = pPlan
      AND sga_alumnos.calidad          = 'E';  -- Egresados
   
   
  RETURN iCantEgresados;
  
END;
END PROCEDURE;
-- *****************************************************************************
GRANT EXECUTE ON sp_intcon_eganinep TO public;


-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1
-- modificado v2.06.2, 2.9.5
-- Procedure sp_intcon_egr_car
-- 
-- Egresados de una carrera en el año informado.
-- Se basa en Araucano Nominal. Debe correrse el proceso de Araucano para el año a solicitar informacion.
-- *****************************************************************************

DROP PROCEDURE sp_intcon_egr_car;
CREATE PROCEDURE sp_intcon_egr_car ( 
   pUnidadAcademica VARCHAR(5),
   pCarrera         VARCHAR(5),
   pAnio            INTEGER)
RETURNING INTEGER;   -- Cantidad de Egresados de la carrera

-- Variables locales
DEFINE cnt_egresados		integer;
DEFINE dFechaInicioAnio, dFechaFinAnio date;

-- Variables para el manejo de excepciones
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN
   LET dFechaInicioAnio = to_date('0104' || pAnio, '%d%m%Y'); 
   LET dFechaFinAnio    = to_date('3103' || pAnio + 1, '%d%m%Y'); 
   LET cnt_egresados = 0;
   
     { -- Conteo usando tablas de Araucano formato anterior. 
      SELECT COUNT(*)
        INTO cnt_egresados
        FROM int_arau_egres
       WHERE anio_academico =panio
         AND unidad_academica =punidadacademica
         AND carrera = pcarrera;
      }
	  
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
   -- ARAUCANO NOMINAL: Cuenta egresados. 
   -- Hace el DISTINCT por si en el mismo año el alumno obtuvo un titulo intermedio.   
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
   SELECT COUNT(DISTINCT sga_alumnos.legajo)
     INTO cnt_egresados
     FROM int_araunom_oferta,
	      sga_alumnos,
	      sga_titulos_plan,
	      sga_titulos
    WHERE int_araunom_oferta.anio_academico   = pAnio
      AND int_araunom_oferta.unidad_academica = pUnidadAcademica
      AND int_araunom_oferta.carrera          = pCarrera
      AND int_araunom_oferta.fecha_egreso IS NOT NULL
     AND to_date(int_araunom_oferta.fecha_egreso,'%Y%m%d') BETWEEN dFechaInicioAnio AND dFechaFinAnio
	  
      AND sga_alumnos.unidad_academica = int_araunom_oferta.unidad_academica
      AND sga_alumnos.carrera          = int_araunom_oferta.carrera
      AND sga_alumnos.legajo           = int_araunom_oferta.legajo
      -- AND sga_alumnos.calidad          = 'E';
	  
      AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
      AND sga_titulos_plan.carrera = sga_alumnos.carrera
      AND sga_titulos_plan.plan    = sga_alumnos.plan
      
      AND sga_titulos.unidad_academica = sga_titulos_plan.unidad_academica
      AND sga_titulos.titulo           = sga_titulos_plan.titulo
      AND sga_titulos.titulo_araucano  = int_araunom_oferta.titulo_araucano
	  AND sga_titulos.nivel            = 'GRADO'; -- Titulo que hace egresar al alumno.
   
   RETURN cnt_egresados;
   
END;
END PROCEDURE;
-- ************************ Fin del procedure sp_intcon_egr_car ************************

GRANT EXECUTE ON sp_intcon_egr_car TO public; 

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1, 2.9.5
-- Procedure con_cnt_ing_car
--
-- INGRESANTES en la Carrera  (Alumnos que ingresaron efectivamente a la carrera luego de aprobar
-- el mecanismo de ingreso.) -> Alumnos con legajo en guarani.
-- *****************************************************************************
DROP PROCEDURE sp_intcon_ing_car;
CREATE PROCEDURE sp_intcon_ing_car( pUnidadAcademica   VARCHAR(5),
	                                pCarrera           VARCHAR(5),
	                                pAnio              INTEGER )
       RETURNING INTEGER;   -- Cantidad de ingresantes

-- Variables locales
DEFINE cnt_ingresantes smallint;

-- Variables para el manejo de excepciones
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
	RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN

{
  Situacion de la persona:
	Resultado Situacion_asp
	A	AC	Aspirante a carrera.
	A	IC	Alumno Condicional al no cumplir todos los requisitos Oblig.
	I	IL	Alumno con legajo ya generado en la carrera.
	R	RF	Aspirante no aceptado en el período de inscripción.
	R	RR	Alu. Rechazado en el período Insc. al no cumplir req. Oblig.
}

   LET cnt_ingresantes = 0;

{ -- Calculo con formato anterior de ARAUCANO   
   -- Ingresantes. cuento por persona.
   SELECT COUNT(DISTINCT legajo)
     INTO cnt_ingresantes
     FROM int_arau_nuinscrip
    WHERE anio_academico   = pAnio
      AND unidad_academica = pUnidadAcademica
      AND carrera          = pCarrera;
   
}

   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
   -- Araucano Nominal: Ingresantes (año de ingreso igual al año a informar)
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
   SELECT COUNT(DISTINCT legajo)
     INTO cnt_ingresantes
     FROM int_araunom_oferta
    WHERE anio_academico   = pAnio
      AND unidad_academica = pUnidadAcademica
      AND carrera          = pCarrera
	  AND anio_ingreso     = pAnio;
   
   RETURN cnt_ingresantes ;

END;
END PROCEDURE;
-- ************************ Fin del procedure sp_intcon_ing_car ************************

GRANT EXECUTE ON sp_intcon_ing_car TO public;

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1, 2.9.5
-- Procedure sp_intcon_tasegrcp
--
-- Calcula la tasa de Egreso de una carrera en un año academico indicado.
-- Esta tasa de egreso la calcula segun la duracion de los planes de la carrera
-- por el cual los alumnos egresaron.
--  
-- Se toma el AÑO LECTIVO y NO el Año calendario
-- Se basa en Araucano Nominal a partir de 2.9.5.
-- *****************************************************************************
DROP PROCEDURE sp_intcon_tasegrcp;
CREATE PROCEDURE sp_intcon_tasegrcp ( 
   pUnidadAcademica  VARCHAR(5),
   pCarrera          VARCHAR(5),
   pPlan             VARCHAR(5),
   pAnioEgres        INTEGER )
RETURNING INTEGER,        -- cnt egresados
          DECIMAL(6,2);   -- Tasa de Egreso


-- define vi_anio_ingreso like sga_anio_academico.anio_academico;
DEFINE vd_suma, vd_tasa_egreso DECIMAL(6,2);
DEFINE vi_cantidad, cnt_egresados, vi_ingresantes, vi_anio_ingreso INTEGER;
DEFINE dFechaInicioAnio, dFechaFinAnio date;


BEGIN
   
   BEGIN
      ON EXCEPTION IN (-206)
         -- tabla no existe contiuno
      END EXCEPTION WITH RESUME;
      DROP TABLE tmp_planes_egr;
   END
   
   CREATE TEMP TABLE tmp_planes_egr ( plan              VARCHAR(5),
                                      duracion_teorica  VARCHAR(20),
                                      duracion          DECIMAL(4,2) DEFAULT 0,   -- duracion numerica
                                      anio_ingreso      INTEGER,   -- año de ingreso segun duracion de la carrera...
                                      egresados         INTEGER DEFAULT 0,
                                      ingresantes       INTEGER DEFAULT 0,
                                      tasa_egreso_plan  DECIMAL(6,2) DEFAULT 0
                                    );
   
   
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- selecciono los distintos planes que tuvieron los egresados
   -- del año académico seleccionado
   -- la duracion debe venir en AÑOS
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

{ -- Calculo de egresados con el formato anterior de Araucano      
      INSERT INTO tmp_planes_egr (plan, duracion_teorica, duracion, egresados)
           SELECT sga_planes.plan,
                  sga_planes.duracion_teorica,
                  sga_planes.duracion_numerica,
                  COUNT(*)
             FROM int_arau_egres
                  sga_alumnos,
                  sga_planes
            WHERE int_arau_oferta.anio_academico   = pAnioEgres 
              AND int_arau_oferta.unidad_academica = pUnidadAcademica
              AND int_arau_oferta.carrera          = pcarrera
              
              AND int_arau_egres.unidad_academica = sga_alumnos.unidad_academica
              AND int_arau_egres.carrera          = sga_alumnos.carrera
              AND int_arau_egres.legajo           = sga_alumnos.legajo
              
              AND sga_alumnos.unidad_academica = sga_planes.unidad_academica
              AND sga_alumnos.carrera          = sga_planes.carrera
              AND sga_alumnos.plan             = sga_planes.plan
              AND sga_planes.plan = pPlan
              
            GROUP BY sga_planes.plan,
                     sga_planes.duracion_teorica,
                     sga_planes.duracion_numerica;
}

   LET dFechaInicioAnio = to_date('0104' || pAnioEgres, '%d%m%Y'); 
   LET dFechaFinAnio    = to_date('3103' || pAnioEgres + 1, '%d%m%Y'); 

      -- Calculo de egresados a partir de Araucano Nominal.   
	  -- Realizo el distinct porque el alumno podria estar informando mas de un titulo (intermedio + final)
      INSERT INTO tmp_planes_egr (plan, duracion_teorica, duracion, egresados)
           SELECT sga_planes.plan,
                  sga_planes.duracion_teorica,
                  sga_planes.duracion_numerica,
                  COUNT(DISTINCT sga_alumnos.legajo)
             FROM int_araunom_oferta,
                  sga_alumnos,
                  sga_planes,
                  sga_titulos_plan,
                  sga_titulos
            WHERE int_araunom_oferta.anio_academico   = pAnioEgres 
              AND int_araunom_oferta.unidad_academica = pUnidadAcademica
              AND int_araunom_oferta.carrera          = pCarrera
              AND int_araunom_oferta.fecha_egreso IS NOT NULL
              AND to_date(int_araunom_oferta.fecha_egreso,'%Y%m%d') BETWEEN dFechaInicioAnio AND dFechaFinAnio
              
              AND sga_alumnos.unidad_academica = int_araunom_oferta.unidad_academica
              AND sga_alumnos.carrera          = int_araunom_oferta.carrera
              AND sga_alumnos.legajo           = int_araunom_oferta.legajo
              -- AND sga_alumnos.calidad          = 'E'  -- Egresado
              
              AND sga_planes.unidad_academica = sga_alumnos.unidad_academica
              AND sga_planes.carrera          = sga_alumnos.carrera
              AND sga_planes.plan             = sga_alumnos.plan
              AND sga_planes.plan             = pPlan

              AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
              AND sga_titulos_plan.carrera = sga_alumnos.carrera
              AND sga_titulos_plan.plan    = sga_alumnos.plan
              
              AND sga_titulos.unidad_academica = sga_titulos_plan.unidad_academica
              AND sga_titulos.titulo           = sga_titulos_plan.titulo
              AND sga_titulos.titulo_araucano  = int_araunom_oferta.titulo_araucano
              AND sga_titulos.nivel            = 'GRADO' -- Titulo que hace egresar al alumno.
              
            GROUP BY sga_planes.plan,
                     sga_planes.duracion_teorica,
                     sga_planes.duracion_numerica;
   
   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- DURACION DEL PLAN y calculo del Año de Ingreso a la carrera
   -- AÑO DE INGRESO = AÑO DE EGRESO - DURACION TEORICA.
   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   
   -- para la duracion que es sin decimales
   UPDATE tmp_planes_egr
      SET anio_ingreso = pAnioEgres - round(duracion,0)
    WHERE duracion = round(duracion,0);
   
   -- para la duracion que es con decimales
   -- Ejemplo: 5.5 años = 6 años.
   UPDATE tmp_planes_egr
      SET anio_ingreso = pAnioEgres - round(duracion,0) + 1
    WHERE duracion <> round(duracion,0);
   
   SELECT anio_ingreso
     INTO vi_anio_ingreso
     FROM tmp_planes_egr;
   
   
   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- cuento los ingresantes para cada año de ingreso calculado
   -- calculo los ingresantes a la carrera con el proceso:
   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   EXECUTE PROCEDURE sp_intcon_curinanp (pUnidadAcademica, pCarrera, pPlan, vi_anio_ingreso, vi_anio_ingreso) INTO vi_ingresantes;
   
   UPDATE tmp_planes_egr
      SET ingresantes = vi_ingresantes;
   
   
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- calculo la tasa de egreso para cada plan.
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   UPDATE tmp_planes_egr
      SET tasa_egreso_plan = round (egresados / ingresantes*100, 2)
    WHERE ingresantes > 0;
   
   
   SELECT egresados, tasa_egreso_plan
     INTO cnt_egresados, vd_tasa_egreso
     FROM tmp_planes_egr;
   
   
   -- retorno la cantidad de egresados y la tasa de egreso = (Sumatoria de las tasas de egreso de cada plan, dividido la cantidad 
   -- de planes con los cuales egresaron los alumnos en la carrera)
   RETURN cnt_egresados, vd_tasa_egreso;
   
   BEGIN
      -- tabla no existe contiuno
      ON EXCEPTION IN (-206)
      END EXCEPTION WITH RESUME;
      -- DROP TABLE tmp_planes_egr;
   END
   
END;
END PROCEDURE;
-- ++++++++++++++++++++++++++++++++++++++++ Fin Proceso sp_intcon_tasegrcp +++++++++++++++++++++++++++++++++++

GRANT EXECUTE ON sp_intcon_tasegrcp TO public;


-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
INSERT INTO app_versiones ( version, fecha_generacion, fecha_actualiz, script_corrido )
     VALUES ( "CNV2.09.5" , TODAY, CURRENT YEAR TO SECOND, 12);

-- Sumo un minuto al ultimo script para que al controlar la version en el ingreso del sistema recupere este script y 
-- no algun script anterior que pudo quedar con la misma fecha de actualizacion
UPDATE app_versiones 
   SET fecha_actualiz = fecha_actualiz + INTERVAL(1) MINUTE TO MINUTE 
 WHERE version = "CNV2.09.5" AND script_corrido = 12;	 
-- *************************************************************************************

-- *************************************************************************************
-- Scripts personalizados UNL
-- *************************************************************************************
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedure sp_fichaluporcapro
-- Version modificación: 2.09.0, 2.9.5
-- En el caso de egresados, recupera el plan y version de plan de estudios a la fecha de egreso.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

DROP PROCEDURE sp_fichaluporcapro;
CREATE PROCEDURE sp_fichaluporcapro (
   pUnidadAcademica LIKE sga_personas.unidad_academica, 
   pNroInscripcion LIKE sga_personas.nro_inscripcion)
 
 RETURNING varchar(5), varchar(10), varchar(30), varchar(30), varchar(5), varchar(255), varchar(5), varchar(255), varchar(5), varchar(255), varchar(15), varchar(5), decimal(6,2), decimal(6,2), varchar(5);--un toco

-- retorno
-- varchar(5),   -- unidad_academica
-- varchar(10),  -- nro_inscripcion
-- varchar(30),  -- apellido
-- varchar(30),  -- nombres
-- varchar(5),   -- carrera
-- varchar(255), -- carrera_nombre
-- varchar(5), -- titulo 
-- varchar(255), -- nombre titulo
-- varchar(5), -- orientacion
-- varchar(255), -- orientacion nombre
-- varchar(15),  -- legajo
-- varchar(5),   -- plan
-- decimal(6,2), -- porcentaje de aprobacion orientacion
-- decimal(6,2), -- porcentaje de aprobacion-titulo
-- varchar(5)  -- version del plan


DEFINE vcUnidadAcademica LIKE sga_alumnos.unidad_academica; 
DEFINE vcCarrera LIKE sga_alumnos.carrera;
DEFINE vcLegajo  LIKE sga_alumnos.legajo;
DEFINE vcPlan, vcPlanAux LIKE sga_versiones_plan.plan;
DEFINE vcVersion, vcVersionAux LIKE sga_versiones_plan.version;
DEFINE vcTitulo LIKE sga_atrib_mat_orie.titulo;
DEFINE vcOrientacion LIKE sga_atrib_mat_orie.orientacion;
DEFINE vcMateria LIKE sga_atrib_mat_orie.materia;
DEFINE vdPorcentaje decimal(6,2);
DEFINE vcOrientElegida LIKE sga_atrib_mat_orie.orientacion;
DEFINE vcApellido        LIKE sga_personas.apellido;
DEFINE vcNombres         LIKE sga_personas.nombres;
DEFINE vcSexo         LIKE sga_personas.sexo;
DEFINE vcNombreCarrera LIKE sga_carreras.nombre; 
DEFINE vcNombreTitulo LIKE sga_titulos.nombre;
DEFINE vcNombreTituloF LIKE sga_titulos.nombre_femenino;
DEFINE vcNombreOrient LIKE sga_orientaciones.nombre;
DEFINE vdPorcentajeOri decimal(6,2);
DEFINE viCantMaterias integer;
DEFINE viCantMateriasOri integer;
DEFINE vcTieneOrient LIKE sga_titulos_plan.tiene_orient;
DEFINE vcResultGene char(1);
DEFINE vcCalidad char(1);
DEFINE vdtFecha Datetime Year to Second;
DEFINE vdFechaEgreso Date;

CREATE TEMP TABLE tmp_materia_porcen (
	unidad_academica varchar(5),
	carrera varchar(5),
	legajo varchar(15),
	plan varchar(5),
	version varchar(5),
	titulo varchar(5),
	orientacion varchar(5),
	materia varchar(5),
	porcentaje decimal(6,2) default 0 ) WITH NO LOG;

CREATE TEMP TABLE tmp_result_porcen (
	unidad_academica varchar(5),
	carrera varchar(5),
	legajo varchar(15),
	plan varchar(5),
	version varchar(5),
	titulo varchar(5),
	orientacion varchar(5),
	suma decimal(10,2),
	conteo integer ) WITH NO LOG;

CREATE TEMP TABLE tmp_carreras_plan (
	unidad_academica varchar(5),
	carrera varchar(5),
	legajo varchar(15),
	plan varchar(5),
	version varchar(5));

-- selecciono los datos personales de la persona.
   SELECT sga_personas.apellido,
          sga_personas.nombres,
	sga_personas.sexo
     INTO vcApellido, vcNombres, vcSexo
     FROM sga_personas
    WHERE sga_personas.unidad_academica = pUnidadAcademica
      AND sga_personas.nro_inscripcion = pNroInscripcion;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Recorro las carreras en las que se encuentra la persona
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FOREACH SELECT unidad_academica, carrera, legajo, calidad
		INTO vcUnidadAcademica, vcCarrera, vcLegajo, vcCalidad
		FROM sga_alumnos
		WHERE unidad_academica = pUnidadAcademica
		AND nro_inscripcion = pNroInscripcion
		
		
    -- Si es egresado, saco el plan y la version en base a la fecha de solicitud del titulo, sino a la fecha actual
    LET vcPlan = NULL;
    LET vcVersion = NULL;
    LET vdtFecha = NULL;
    LET vdFechaEgreso = NULL;
    IF vcCalidad = 'E' THEN
       -- Egresado. Recupero fecha de egreso, plan y version del título de nivel final - Grado
       SELECT to.fecha_egreso, plan, version 
	     INTO vdFechaEgreso, vcPlan, vcVersion
         FROM sga_titulos_otorg as to,
              sga_titulos as t
		WHERE to.unidad_academica = pUnidadAcademica
 		  AND to.nro_inscripcion = pNroInscripcion
 		  AND to.carrera = vcCarrera
 		  AND to.legajo  = vcLegajo
		  AND t.unidad_academica = to.unidad_academica
 		  AND t.titulo =  to.titulo
 		  AND t.nivel = 'GRADO';

        -- Paso la fecha de egreso a formato datetime con el ultimo minuto del dia de egreso.
        LET vdtFecha = to_date(to_char(vdFechaEgreso,'%d/%m/%Y') || ' 23:59:59', '%d/%m/%Y %H:%M:%S');
	END IF;
	
	IF vdtFecha IS NULL THEN
	   LET vdtFecha = CURRENT;  -- Fecha y hora actual
	END IF;	
	  
	IF vcPlan IS NULL OR vcVersion IS NULL THEN 
		-- Calcula el plan y la version segun la fecha actual o fecha de egreso en la carrera
		EXECUTE PROCEDURE sp_plan_de_alumno (vcUnidadAcademica, vcCarrera, vcLegajo, vdtFecha) INTO vcPlan, vcVersion;
	END IF;	
    
	
	-- Registro el plan y version del alumno en cada carrera
	INSERT INTO tmp_carreras_plan (unidad_academica, carrera, plan, version) VALUES (vcUnidadAcademica, vcCarrera, vcPlan, vcVersion);

	INSERT INTO tmp_materia_porcen (unidad_academica, carrera, legajo, plan, version, titulo, orientacion, materia)
	SELECT vmp.unidad_academica, vmp.carrera, vcLegajo, vmp.plan, vmp.version, vmp.titulo, vmp.orientacion, vmp.materia
		FROM vw_materias_plan AS vmp, 
		     sga_atrib_mat_plan AS samp
		WHERE vmp.unidad_academica = vcUnidadAcademica
			AND vmp.carrera = vcCarrera
			AND vmp.plan = vcPlan
			AND vmp.version = vcVersion
			AND vmp.relacion = 'D'
			AND vmp.unidad_academica = samp.unidad_academica
			AND vmp.carrera = samp.carrera
			AND vmp.plan = samp.plan
			AND vmp.version = samp.version
			AND vmp.materia = samp.materia
			AND obligatoria='S';

	-- por ahora solo trabajo con aprobacion de materias
	FOREACH SELECT DISTINCT titulo
		INTO vcTitulo
		FROM tmp_materia_porcen

		IF (SELECT calculo_egreso
			FROM sga_titulos_plan
			WHERE unidad_academica = vcUnidadAcademica
				AND carrera = vcCarrera
				AND plan = vcPlan
				AND titulo = vcTitulo) <>'AM' THEN

			DELETE FROM tmp_materia_porcen WHERE titulo = vcTitulo;

		END IF;

		-- si el alumno eligio orientacion debo retornar solo esa orientacion
		SELECT orientacion
			INTO vcOrientElegida 
			FROM sga_orient_alumno
			WHERE unidad_academica = vcUnidadAcademica
				AND carrera = vcCarrera
				AND legajo = vcLegajo
				AND plan = vcPlan
				AND titulo = vcTitulo;

		IF vcOrientElegida IS NOT NULL THEN 
			-- borro los datos de las orientaciones no elegidas por el alumno
			DELETE FROM tmp_materia_porcen
				WHERE unidad_academica = vcUnidadAcademica
					AND carrera = vcCarrera
					AND legajo = vcLegajo
					AND plan = vcPlan
					AND titulo = vcTitulo
					AND orientacion NOT IN ('0' ,vcOrientElegida);

		END IF;
		
	END FOREACH; -- filtro por calculo_egreso y orientacion elegida


	FOREACH SELECT titulo, orientacion, materia
		INTO vcTitulo, vcOrientacion, vcMateria
		FROM tmp_materia_porcen

		LET vdPorcentaje = 0;

		IF (SELECT tipo_materia
			FROM sga_materias
			WHERE unidad_academica = vcUnidadAcademica
				AND materia = vcMateria) = 'G' THEN

			-- si la materia es generica busco el porcentaje de aprobacion
			EXECUTE PROCEDURE sp_resultGenePorc(pUnidadAcademica, vcCarrera, vcLegajo, vcTitulo, vcOrientacion,vcMateria) INTO vcResultGene, vdPorcentaje;


			-- U820 - Personalización UNL: la genérica se considera aprobada total o no.
			IF vcResultGene = 'R' THEN
				LET vdPorcentaje = 0;
			END IF;	

		ELSE

			IF EXISTS(SELECT ''
					FROM vw_hist_academica
					WHERE unidad_academica = vcUnidadAcademica
						AND carrera = vcCarrera
						AND legajo = vcLegajo
						AND materia = vcMateria
						AND resultado = 'A') THEN

				LET vdPorcentaje = 1;

			END IF;
		END IF;

		UPDATE tmp_materia_porcen 
			SET porcentaje = vdPorcentaje
			WHERE unidad_academica = vcUnidadAcademica
				AND carrera = vcCarrera
				AND legajo = vcLegajo
				AND titulo = vcTitulo
				AND orientacion = vcOrientacion
				AND materia = vcMateria;
			
	END FOREACH; --materia
			
END FOREACH; -- carreras

-- Ahora tratamos de retornar algo...
INSERT INTO tmp_result_porcen (unidad_academica, carrera, legajo, plan, version, titulo, orientacion, suma, conteo)
SELECT unidad_academica, carrera, legajo, plan, version, titulo, orientacion, SUM(porcentaje), COUNT(*)
	FROM tmp_materia_porcen
	GROUP BY unidad_academica, carrera, legajo, plan, version, titulo, orientacion;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- para cada plan y titulo
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FOREACH SELECT DISTINCT trp.unidad_academica, trp.carrera, trp.legajo, trp.plan, trp.titulo, sc.nombre, st.nombre, st.nombre_femenino, tiene_orient, tcpv.plan, tcpv.version
		INTO vcUnidadAcademica, vcCarrera, vcLegajo, vcPlan, vcTitulo, vcNombreCarrera, vcNombreTitulo, vcNombreTituloF, vcTieneOrient, vcPlanAux, vcVersionAux
		FROM tmp_result_porcen AS  trp, 
		     sga_carreras AS sc, 
		     sga_titulos AS st, 
		     sga_titulos_plan AS stp,
		     tmp_carreras_plan as tcpv
		WHERE trp.unidad_academica = sc.unidad_academica
			AND trp.carrera = sc.carrera
			AND trp.unidad_academica = st.unidad_academica
			AND trp.titulo = st.titulo
			AND trp.unidad_academica = stp.unidad_academica
			AND trp.carrera = stp.carrera
			AND trp.plan = stp.plan
			AND trp.titulo = stp.titulo
			AND tcpv.unidad_academica = stp.unidad_academica
			AND tcpv.carrera = stp.carrera


		SELECT DISTINCT trp.orientacion, nombre, suma, conteo
			INTO vcOrientacion, vcNombreOrient, vdPorcentaje, viCantMaterias
			FROM tmp_result_porcen AS trp, sga_orientaciones AS so
			WHERE trp.unidad_academica = vcUnidadAcademica
				AND trp.carrera = vcCarrera
				AND trp.plan = vcPlan
				AND trp.titulo = vcTitulo
				AND trp.orientacion ='0'
				AND trp.unidad_academica = so.unidad_academica
				AND trp.carrera = so.carrera
				AND trp.plan = so.plan
				AND trp.titulo = so.titulo
				AND trp.orientacion = so.orientacion;

		IF vcTieneOrient = 'N' THEN
			RETURN pUnidadAcademica, pNroInscripcion, vcApellido, vcNombres, vcCarrera, vcNombreCarrera, vcTitulo, vcNombreTitulo, vcOrientacion, vcNombreOrient, vcLegajo, vcPlanAux, (vdPorcentaje/viCantMaterias*100), (vdPorcentaje/viCantMaterias*100), vcVersionAux WITH RESUME;
		ELSE
			RETURN pUnidadAcademica, pNroInscripcion, vcApellido, vcNombres, vcCarrera, vcNombreCarrera, vcTitulo, vcNombreTitulo, vcOrientacion, vcNombreOrient, vcLegajo, vcPlanAux, (vdPorcentaje/viCantMaterias*100), NULL, vcVersionAux WITH RESUME;
		END IF;


	FOREACH SELECT DISTINCT trp.orientacion, nombre, suma, conteo
			INTO vcOrientacion, vcNombreOrient, vdPorcentajeOri, viCantMateriasOri
			FROM tmp_result_porcen AS trp, sga_orientaciones AS so
			WHERE trp.unidad_academica = vcUnidadAcademica
				AND trp.carrera = vcCarrera
				AND trp.plan = vcPlan
				AND trp.titulo = vcTitulo
				AND trp.orientacion <> '0'
				AND trp.unidad_academica = so.unidad_academica
				AND trp.carrera = so.carrera
				AND trp.plan = so.plan
				AND trp.titulo = so.titulo
				AND trp.orientacion = so.orientacion

		RETURN pUnidadAcademica, pNroInscripcion, vcApellido, vcNombres, vcCarrera, vcNombreCarrera, vcTitulo, vcNombreTitulo, vcOrientacion, vcNombreOrient, vcLegajo, 
		       vcPlanAux, (vdPorcentajeOri/viCantMateriasOri*100), ((vdPorcentaje + vdPorcentajeOri)/(viCantMaterias + viCantMateriasOri)*100), vcVersionAux WITH RESUME;

	END FOREACH; -- orientacion

END FOREACH; -- plan y titulo

-- Borro tablas temporales
DROP TABLE tmp_materia_porcen;
DROP TABLE tmp_result_porcen;
DROP TABLE tmp_carreras_plan;

END PROCEDURE;
-- ++++++++++++++++++++++++++++++++++++++++++++ Fin Procedure ++++++++++++++++++++++++++


GRANT EXECUTE ON sp_fichaluporcapro TO public;


DROP PROCEDURE sp_FichAluDatPer;
CREATE PROCEDURE sp_FichAluDatPer ( pUA LIKE sga_personas.unidad_academica, pNroInscripcion LIKE sga_personas.nro_inscripcion )
       RETURNING 
		varchar(5), varchar(10), varchar(30), varchar(30), varchar(15), date, integer, decimal(15,0), 
		integer, integer, varchar(3), varchar(40), varchar(255), varchar(12), varchar(50), varchar(5), 
		varchar(3), varchar(5), varchar(3), integer, varchar(18), varchar(50), varchar(18), varchar(15), 
		varchar(100), varchar(60), varchar(30), varchar(10), varchar(100), varchar(60), varchar(60), 
		varchar(60), varchar(100), varchar(100), varchar(60), varchar(60), varchar(60);

-- Descripcion del Return:
-- varchar(5),    -- vc_UA
-- varchar(10),   -- vc_NroInscripcion
-- varchar(30),   -- vc_Apellido
-- varchar(30),   -- vc_Nombres
-- varchar(15),   -- vc_NroDocumento
-- date,          -- vd_FechaInscrip
-- integer,       -- vi_AnioIng
-- decimal(15,0), -- vc_NroCi
-- integer,       -- vc_EmisorCi
-- integer,       -- vc_TituloSec
-- varchar(3),    -- vc_TipoDocDesAbre
-- varchar(40),   -- vc_EmisorCiDesc
-- varchar(255),   -- vc_TituloSecDesc
-- varchar(12),   -- vc_fecha_actualiza
-- varchar(50),   -- vc_CallePl
-- varchar(5),    -- vc_NumeroPl
-- varchar(3),    -- vc_PisoPl
-- varchar(5),    -- vc_DptoPl
-- varchar(3),    -- vc_UnidadPl
-- integer,       -- vc_LocalidadPl

-- varchar(18),   -- vc_TelefonoPl
-- varchar(50),  --vc_E_mail
--varchar(18),  --vc_Celular_numero
--varchar(15),  --vc_Celular_compania

-- varchar(100),  -- vc_LocalidadNombre
-- varchar(60);   -- vc_ProvinciaNombre

-- varchar(30) -- nacionalidad
-- varchar(10) -- fecha de nacimiento
-- varchar(100) -- localidad nacimiento
-- varchar(60) -- dpto/partido nacimiento
-- varchar(60) -- provincia nacimiento
-- varchar(60) -- pais nacimiento

-- varchar(100) -- nombre colegio
-- varchar(100) -- localidad colegio
-- varchar(60) -- dpto/partido colegio
-- varchar(60) -- provincia colegio
-- varchar(60) -- pais colegio

-- variables.
DEFINE vc_UA              LIKE sga_personas.unidad_academica;
DEFINE vc_NroInscripcion  LIKE sga_personas.nro_inscripcion;
DEFINE vc_Apellido        LIKE sga_personas.apellido;
DEFINE vc_Nombres         LIKE sga_personas.nombres;
DEFINE vc_NroDocumento    LIKE sga_personas.nro_documento;
DEFINE vd_FechaInscrip    LIKE sga_personas.fecha_inscripcion;
DEFINE vi_AnioIng         INTEGER;
DEFINE vc_NroCi           LIKE sga_personas.nro_ci;
DEFINE vc_EmisorCi        LIKE sga_personas.ent_emisora_ci;
DEFINE vc_TituloSec       LIKE sga_personas.titulo_secundario;
DEFINE vc_TipoDocDesAbre  LIKE mdp_tipo_documento.desc_abreviada;
DEFINE vc_EmisorCiDesc    LIKE sga_entes_emis_ci.descripcion;
DEFINE vc_TituloSecDesc   LIKE sga_titulos_sec.descripcion;
DEFINE vc_fecha, vc_FechaMax   LIKE sga_datos_censales.fecha_relevamiento;

-- DEFINE vc_Periodos        LIKE sga_periodo_insc.periodo_inscripcio;
DEFINE vd_fecha_actualiza        LIKE sga_datos_censales.fecha_actualiz;
DEFINE vc_fecha_actualiza varchar(12);

DEFINE vc_CallePl         LIKE sga_datos_censales.calle_per_lect;
DEFINE vc_NumeroPl        LIKE sga_datos_censales.numero_per_lect;
DEFINE vc_PisoPl          LIKE sga_datos_censales.piso_per_lect;
DEFINE vc_DptoPl          LIKE sga_datos_censales.dpto_per_lect;
DEFINE vc_UnidadPl        LIKE sga_datos_censales.unidad_per_lect;
DEFINE vc_LocalidadPl     LIKE sga_datos_censales.loc_per_lect;

DEFINE vc_TelefonoPl      LIKE sga_datos_censales.te_per_lect;
DEFINE vc_E_mail     LIKE sga_datos_censales.e_mail;
DEFINE vc_Celular_numero LIKE sga_datos_cen_aux.celular_numero;
DEFINE vc_Celular_compania LIKE mdp_celular_comp.nombre;

DEFINE vc_LocalidadNombre LIKE mug_localidades.nombre_abreviado;
DEFINE vc_ProvinciaNombre LIKE mug_provincias.nombre;

DEFINE vc_nac_pers varchar(30);
DEFINE vi_col_sec LIKE sga_personas.colegio_secundario;
DEFINE vi_loc_nacim integer;

DEFINE vc_fecha_nac varchar(10);
DEFINE vc_loc_nacim varchar(100);
DEFINE vc_dpto_nacim varchar(60);
DEFINE vc_prov_nacim varchar(60);
DEFINE vc_pais_nacim varchar(60);

DEFINE vc_nom_coleg varchar(100);
DEFINE vc_loc_coleg varchar(100);
DEFINE vc_dpto_coleg varchar(60);
DEFINE vc_prov_coleg varchar(60);
DEFINE vc_pais_coleg varchar(60);


BEGIN

   -- inicializaciones.
   LET vc_UA              = NULL;
   LET vc_NroInscripcion  = NULL;
   LET vc_Apellido        = NULL;
   LET vc_Nombres         = NULL;
   LET vc_NroDocumento    = NULL;
   LET vd_FechaInscrip    = NULL;
   LET vc_NroCi           = NULL;
   LET vc_EmisorCi        = NULL;
   LET vc_TituloSec       = NULL;
   LET vc_TipoDocDesAbre  = NULL;
   LET vc_EmisorCiDesc    = NULL;
   LET vc_TituloSecDesc   = NULL;
   LET vc_Fecha           = NULL;
   LET vc_FechaMax       = NULL;
   LET vd_fecha_actualiza = NULL;
   LET vc_fecha_actualiza = NULL;
   

   LET vc_CallePl         = NULL;
   LET vc_NumeroPl        = NULL;
   LET vc_PisoPl          = NULL;
   LET vc_DptoPl          = NULL;
   LET vc_UnidadPl        = NULL;
   LET vc_LocalidadPl     = NULL;
   LET vc_TelefonoPl      = NULL;
   
   LET vc_E_mail  = NULL;
   LET vc_Celular_numero   = NULL;
   LET vc_Celular_compania   = NULL;

   LET vc_LocalidadNombre = NULL;
   LET vc_ProvinciaNombre = NULL;
   
   LET vc_nac_pers = NULL;

   LET vc_fecha_nac = NULL;
   LET vc_loc_nacim = NULL;
   LET vc_dpto_nacim = NULL;
   LET vc_prov_nacim = NULL;
   LET vc_pais_nacim = NULL;

   LET vc_nom_coleg = NULL;
   LET vc_loc_coleg = NULL;
   LET vc_dpto_coleg = NULL;
   LET vc_prov_coleg = NULL;
   LET vc_pais_coleg = NULL;

   -- Ultimo dato censal del alumno.
   SELECT MAX(fecha_relevamiento) INTO vc_FechaMax
     FROM sga_datos_censales
    WHERE sga_datos_censales.unidad_academica = vc_UA
      AND sga_datos_censales.nro_inscripcion =  vc_NroInscripcion;
	  
	   -- datos propios de la persona;
   SELECT sga_personas.unidad_academica,
          sga_personas.nro_inscripcion,
          sga_personas.apellido,
          sga_personas.nombres,
          sga_personas.nro_documento,
          sga_personas.fecha_inscripcion,
          sga_personas.nro_ci,
          sga_personas.ent_emisora_ci,
          sga_personas.titulo_secundario,
          mdp_tipo_documento.desc_abreviada,
          sga_personas.colegio_secundario,
          mdp_nacionalidades.descripcion,
          sga_personas.loc_nacimiento,
          to_char(sga_personas.fecha_nacimiento, "%d/%m/%Y")
     INTO vc_UA,
          vc_NroInscripcion,
          vc_Apellido,
          vc_Nombres,
          vc_NroDocumento,
          vd_FechaInscrip,
          vc_NroCi,
          vc_EmisorCi,
          vc_TituloSec,
          vc_TipoDocDesAbre,
          vi_col_sec,
          vc_nac_pers,
          vi_loc_nacim,
          vc_fecha_nac
     FROM sga_personas,
          mdp_tipo_documento,
          mdp_nacionalidades
    WHERE sga_personas.unidad_academica = pUA
      AND sga_personas.nro_inscripcion = pNroInscripcion
      AND mdp_tipo_documento.tipo_documento = sga_personas.tipo_documento
      AND mdp_nacionalidades.nacionalidad = sga_personas.nacionalidad;

   -- datos optativos de la persona;
   SELECT sga_entes_emis_ci.descripcion
     INTO vc_EmisorCiDesc
     FROM sga_entes_emis_ci
    WHERE sga_entes_emis_ci.entidad = vc_EmisorCi;

   -- datos optativos de la persona;
   SELECT sga_titulos_sec.descripcion
     INTO vc_TituloSecDesc
     FROM sga_titulos_sec
    WHERE sga_titulos_sec.titulo_secundario = vc_TituloSec;

   -- ultimo dato censal cargado con algo de domicilio;
   SELECT MAX(sga_datos_censales.fecha_relevamiento)
     INTO vc_fecha
     FROM sga_datos_censales
    WHERE sga_datos_censales.unidad_academica = vc_UA
      AND sga_datos_censales.nro_inscripcion =  vc_NroInscripcion
      AND (sga_datos_censales.calle_per_lect is not null or
          sga_datos_censales.numero_per_lect is not null or
          sga_datos_censales.piso_per_lect is not null or
          sga_datos_censales.dpto_per_lect is not null or
          sga_datos_censales.unidad_per_lect is not null or
          sga_datos_censales.loc_per_lect is not null or
          sga_datos_censales.te_per_lect is not null);

			   
  IF vc_fecha is not null THEN
   -- datos censales respecto de domicilio de procedencia
   SELECT sga_datos_censales.calle_per_lect,
          sga_datos_censales.numero_per_lect,
          sga_datos_censales.piso_per_lect,
          sga_datos_censales.dpto_per_lect,
          sga_datos_censales.unidad_per_lect,
          sga_datos_censales.loc_per_lect,
          sga_datos_censales.te_per_lect,
          -- to_char(sga_datos_censales.fecha_actualiz, "%d/%m/%Y"),
          sga_datos_censales.fecha_actualiz,
          sga_datos_censales.e_mail
     INTO vc_CallePl,
          vc_NumeroPl,
          vc_PisoPl,
          vc_DptoPl,
          vc_UnidadPl,
          vc_LocalidadPl,
          vc_TelefonoPl,
          vd_fecha_actualiza,
          vc_E_mail
     FROM sga_datos_censales
    WHERE sga_datos_censales.unidad_academica = vc_UA
      AND sga_datos_censales.nro_inscripcion = vc_NroInscripcion
      AND sga_datos_censales.fecha_relevamiento = vc_fecha;

	LET vc_fecha_actualiza = day(vd_fecha_actualiza) || '/' || month(vd_fecha_actualiza) || '/' || year(vd_fecha_actualiza);

   -- datos censales (optativos)
   SELECT mug_localidades.nombre_abreviado,  mug_provincias.nombre
     INTO vc_LocalidadNombre, vc_ProvinciaNombre
     FROM mug_localidades,
          mug_dptos_partidos,
          mug_provincias
    WHERE mug_localidades.localidad = vc_LocalidadPl
      AND mug_dptos_partidos.dpto_partido = mug_localidades.dpto_partido
      AND mug_provincias.provincia = mug_dptos_partidos.provincia;

 END IF;  -- Fin datos de domicilio de procedencia

 -- MAIL Y COMPANIA
 IF vc_FechaMax IS NOT NULL THEN  
   SELECT sga_datos_censales.e_mail, sga_datos_cen_aux.celular_numero, mdp_celular_comp.nombre
     INTO vc_E_mail, vc_Celular_numero, vc_Celular_compania
     FROM sga_datos_censales,
	      sga_datos_cen_aux, 
	      OUTER mdp_celular_comp
    WHERE sga_datos_cen_aux.unidad_academica   = vc_UA
      AND sga_datos_cen_aux.nro_inscripcion    = vc_NroInscripcion
      AND sga_datos_cen_aux.fecha_relevamiento = vc_FechaMax
      AND sga_datos_cen_aux.unidad_academica   = sga_datos_cen_aux.unidad_academica
      AND sga_datos_cen_aux.nro_inscripcion    = sga_datos_cen_aux.nro_inscripcion
      AND sga_datos_cen_aux.fecha_relevamiento = sga_datos_cen_aux.fecha_relevamiento
      AND mdp_celular_comp.celular_compania = sga_datos_cen_aux.celular_compania;
  END IF;
 
   
   -- Año de ingreso a la primer carrera.
   SELECT MIN(sga_periodo_insc.anio_academico)
     INTO vi_AnioIng
     FROM sga_carrera_aspira, sga_periodo_insc
    WHERE sga_carrera_aspira.unidad_academica = vc_UA
      AND sga_carrera_aspira.nro_inscripcion = vc_NroInscripcion
      AND sga_carrera_aspira.situacion_asp = 'IL'
      AND sga_carrera_aspira.periodo_inscripcio = sga_periodo_insc.periodo_inscripcio;
   

-- localidad de nacimiento
   select ml.nombre, md.nombre, mpr.nombre, mp.nombre
   INTO vc_loc_nacim, vc_dpto_nacim, vc_prov_nacim, vc_pais_nacim 
   FROM mug_localidades ml,
	mug_dptos_partidos md,
	mug_provincias mpr,
	mug_paises mp
   WHERE ml.localidad = vi_loc_nacim
	AND ml.dpto_partido = md.dpto_partido
	AND md.provincia = mpr.provincia
	AND mpr.pais = mp.pais;


   SELECT scs.nombre, ml.nombre, md.nombre, mpr.nombre, mp.nombre
   INTO vc_nom_coleg, vc_loc_coleg, vc_dpto_coleg, vc_prov_coleg, vc_pais_coleg
   FROM sga_coleg_sec scs,
	mug_localidades ml,
	mug_dptos_partidos md,
	mug_provincias mpr,
	mug_paises mp
   WHERE scs.colegio = vi_col_sec
	AND ml.localidad = scs.localidad
	AND ml.dpto_partido = md.dpto_partido
	AND md.provincia = mpr.provincia
	AND mpr.pais = mp.pais;



   -- devuelvo los datos.
   RETURN vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_NroDocumento, vd_FechaInscrip, vi_AnioIng, vc_NroCi, vc_EmisorCi, vc_TituloSec, vc_TipoDocDesAbre, vc_EmisorCiDesc, vc_TituloSecDesc, vc_fecha_actualiza, vc_CallePl, vc_NumeroPl, vc_PisoPl, vc_DptoPl, vc_UnidadPl, vc_LocalidadPl, vc_TelefonoPl, vc_E_mail, vc_Celular_numero, vc_Celular_compania, vc_LocalidadNombre, vc_ProvinciaNombre, vc_nac_pers, vc_fecha_nac, vc_loc_nacim, vc_dpto_nacim, vc_prov_nacim, vc_pais_nacim, 
vc_nom_coleg, vc_loc_coleg, vc_dpto_coleg, vc_prov_coleg, vc_pais_coleg;


END;
END PROCEDURE;
-- **************************  Fin del Procedure sp_FichAluDatPer **************************

GRANT EXECUTE ON sp_FichAluDatPer TO public;

-- Forzar la sincronizacion de Guarani UNL
-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
INSERT INTO app_versiones ( version, fecha_generacion, fecha_actualiz, script_corrido )
     VALUES ( "UNL2.09.5.1" , TODAY, CURRENT YEAR TO SECOND, 1);

-- Sumo un minuto al ultimo script para que al controlar la version en el ingreso del sistema recupere este script y 
-- no algun script anterior que pudo quedar con la misma fecha de actualizacion
UPDATE app_versiones 
   SET fecha_actualiz = fecha_actualiz + INTERVAL(1) MINUTE TO MINUTE 
 WHERE version = "UNL2.09.5.1" AND script_corrido = 1;	 



