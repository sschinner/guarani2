-- MODIFICAR EL CONTROL PARA QUE DADA UNA INSCRIPCION, CONTROLE CON LAS INSCRIPCIONES DE MAS ALTA PRIORIDAD ACEPTADAS

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_superph') THEN
		DROP PROCEDURE ctr820_superph;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 1.6.0
-- Control: ctr_superphoraria
--
-- Controla si la persona está inscripta en comisiones con horarios superpuestos.
-- *****************************************************************************

CREATE PROCEDURE "dba".ctr820_superph (
                pUnidadAcademica LIKE sga_alumnos.unidad_academica,
                pCarrera         LIKE sga_alumnos.carrera,
                pLegajo          LIKE sga_alumnos.legajo,
                pComision        LIKE sga_comisiones.comision)

      RETURNING smallint,     -- status
                varchar(255); -- <mensaje, parametros>

   -- vars para la respuesta
   DEFINE iStatus   smallint;      -- status
   DEFINE vcMsg     varchar(255);  -- mensaje y parametros

   -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err  integer;
   DEFINE error_info        varchar(76);
   DEFINE vcUserError       varchar(10);

   -- Variables locales
   DEFINE vNroInscripcion    LIKE sga_personas.nro_inscripcion;

   DEFINE vInicioCom         LIKE sga_asignaciones.fecha_asign_desde;
   DEFINE vFinCom            LIKE sga_asignaciones.fecha_asign_hasta;
   DEFINE vDiaCom            LIKE sga_asignaciones.dia_semana;
   DEFINE vDesdeCom          LIKE sga_asignaciones.hs_comienzo_clase;
   DEFINE vHastaCom          LIKE sga_asignaciones.hs_finaliz_clase;

   DEFINE vOtraComision      LIKE sga_comisiones.comision;
   DEFINE vOtraComNom        LIKE sga_comisiones.nombre;
   DEFINE vInicioOtra        LIKE sga_asignaciones.fecha_asign_desde;
   DEFINE vFinOtra           LIKE sga_asignaciones.fecha_asign_hasta;
   DEFINE vDiaOtra           LIKE sga_asignaciones.dia_semana;
   DEFINE vDesdeOtra         LIKE sga_asignaciones.hs_comienzo_clase;
   DEFINE vHastaOtra         LIKE sga_asignaciones.hs_finaliz_clase;

   -- Bloque de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET iStatus = -1 ;
      LET vcMsg = '800321' || ',' || 'supeposición horaria' || ',' || sql_err || ' - '  || error_info ;
      RETURN iStatus, vcMsg;
   END EXCEPTION;

BEGIN
   -- seteo los valores default
   LET iStatus = 1 ;
   LET vcMsg   = 'OK';

   -- Busca el número de inscripción de la persona
   SELECT nro_inscripcion
     INTO vNroInscripcion
     FROM sga_alumnos
    WHERE unidad_academica = pUnidadAcademica
      AND carrera = pCarrera
      AND legajo = pLegajo;

   -- Busca todos los días y horarios de la comisión elegida
   FOREACH
    SELECT fecha_asign_desde,
           fecha_asign_hasta,
           dia_semana,
           hs_comienzo_clase,
           hs_finaliz_clase
      INTO vInicioCom,
           vFinCom,
           vDiaCom,
           vDesdeCom,
           vHastaCom
      FROM sga_asign_clases, sga_asignaciones
     WHERE sga_asign_clases.comision = pComision
       AND sga_asign_clases.asignacion = sga_asignaciones.asignacion

      -- Busca los horarios de las otras comisiones en las que está inscripto
      -- y que se superponen con las fechas de inicio y fin de la comisión elegida
      FOREACH
       SELECT sga_asign_clases.comision,
              sga_asignaciones.fecha_asign_desde,
              sga_asignaciones.fecha_asign_hasta,
              sga_asignaciones.dia_semana,
              sga_asignaciones.hs_comienzo_clase,
              sga_asignaciones.hs_finaliz_clase
          INTO vOtraComision, vInicioOtra, vFinOtra, vDiaOtra, vDesdeOtra, vHastaOtra
         FROM sga_asign_clases, sga_asignaciones, aux_insc_cursadas , sga_alumnos -- , sga_comisiones
        WHERE sga_asign_clases.comision <> pComision
          AND sga_asign_clases.asignacion = sga_asignaciones.asignacion

          AND sga_asign_clases.comision = aux_insc_cursadas.comision

	-- ************************************************************************************
	-- U820 VERIFICA SI EXISTE ALGUNA INSCRIPCION DE MAYOR PRIORIDAD Y QUE HAYA INGRESADO EL ALUMNO. SI ES ASI DEVUELVE SUPERPOSICION

	AND aux_insc_cursadas.ingreso = 'S'
	AND aux_insc_cursadas.fecha_inscripcion < (select fecha_inscripcion from aux_insc_cursadas where comision = pComision and legajo = pLegajo)
	-- ************************************************************************************

          AND aux_insc_cursadas.unidad_academica = sga_alumnos.unidad_academica
          AND aux_insc_cursadas.carrera = sga_alumnos.carrera
          AND aux_insc_cursadas.legajo = sga_alumnos.legajo
          AND sga_alumnos.unidad_academica = pUnidadAcademica
          AND sga_alumnos.nro_inscripcion = vNroInscripcion

          AND sga_asignaciones.dia_semana = vDiaCom

          AND ( (sga_asignaciones.fecha_asign_desde >= vInicioCom
                 AND sga_asignaciones.fecha_asign_desde <= vFinCom)
              OR (vInicioCom >= sga_asignaciones.fecha_asign_desde
                 AND vInicioCom <= sga_asignaciones.fecha_asign_hasta) )

          AND ( (sga_asignaciones.hs_comienzo_clase >= vDesdeCom
                 AND sga_asignaciones.hs_comienzo_clase < vHastaCom)
              OR (vDesdeCom >= sga_asignaciones.hs_comienzo_clase
                 AND vDesdeCom < sga_asignaciones.hs_finaliz_clase))
          
          
          SELECT sga_comisiones.nombre INTO vOtraComNom  FROM sga_comisiones WHERE comision = vOtraComision;
          
          -- Si se superponen, devuelve el mensaje
          LET vcUserError = '800378';
          LET iStatus     = -1;
          LET vcMsg       = vcUserError || ',' || vOtraComNom || ',' || sp_nombreDiaSemana(vDiaCom);
          RETURN iStatus, vcMsg;
      END FOREACH;
   END FOREACH;
RETURN iStatus, vcMsg; 
END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".ctr820_superph ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".ctr820_superph 
-- *****************************************************************************
revoke execute on "dba".ctr820_superph from public;
grant execute on "dba".ctr820_superph to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_superph to internet; -- Rol de usuario de Internet

-- *************************** Pruebas de ejecucion **********************************
-- execute PROCEDURE "dba".ctr820_superph ('FCJS', '2', '10523730-9', 1531);