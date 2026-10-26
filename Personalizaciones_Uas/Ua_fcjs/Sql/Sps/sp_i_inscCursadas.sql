CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_i_insccursadas') THEN
		DROP PROCEDURE sp_i_inscCursadas;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Stored Procedure: sp_i_inscCursadas
-- Version: 2.8.0
-- Ultima Version de Modificacion: 2.8.0
--
-- pEstado           Estado final de la Inscripcion (Estado resultado de los controles que se ejecutaron en la eleccon de materia y comision/subcomisión)
-- pPlan             Plan Actual del Alumno
-- pVersion          Version vigente del Plan del Alumno
-- pSubcomisiones    Subcomisiones elegidas por el alumno separadas por coma. Ejemplo (subcomisiones 3 y 5):  "3,5,"
-- pCantMaxInsc       Valor del parámetro "cant_max_insc_curs_por_mat_en_per_lect"
-- pCalidad           Valor del Parámetro "inscripcion_cursada_calidad"
-- pControlarCupo     Valor del Parámetro "insc_cursada_controla_cupo_comision". Para controlar cupo en la comision y subcomision
-- pEstaEnTransaccion Indica si el procedure ya esta en una transacción o debe manejarse la transaccion aca adentro
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CREATE PROCEDURE "dba".sp_i_inscCursadas
 ( 
   pUnidadAcademica  LIKE sga_alumnos.unidad_academica,
   pCarrera          LIKE sga_alumnos.carrera,
   pLegajo           LIKE sga_alumnos.legajo,
   pNroInscripcion   LIKE sga_alumnos.nro_inscripcion,
   pComision         LIKE sga_comisiones.comision,
   pEstado           LIKE sga_insc_cursadas.estado, 
   pInterfaz         LIKE sga_insc_cursadas.interfaz,
   pMateria          LIKE sga_comisiones.materia,
   pNombreComision   LIKE sga_comisiones.nombre,
   pPlan             LIKE sga_alumnos.plan, 
   pVersion          LIKE sga_versiones_plan.version,
   pSubcomisiones    varchar(100), 
   pCantMaxInsc      smallint,
   pCalidad          char(1),  
   pControlarCupo    char(1), 
   pEstaEnTransaccion char(1) DEFAULT 'N'
 )
 RETURNING smallint, varchar(255);

/* Retorna:
     1. smallint     - status -1 Error/ 1 OK
     2. varchar(255) - mensaje
*/

   -- vars para el manejo de excepciones
   DEFINE SQLErr            integer;
   DEFINE ISAMError         integer;
   DEFINE errorInfo         varchar(76);
   DEFINE vcUserError       varchar(10);

   -- vars locales
   DEFINE iStatus           smallint;
   DEFINE vcMsg             varchar(255);
   DEFINE vcCarrera         LIKE sga_alumnos.carrera;
   DEFINE vcLegajo          LIKE sga_alumnos.legajo;
   DEFINE cCalidadInsc      LIKE sga_insc_cursadas.calidad_insc;  --R - Regular/P- Promocional
   DEFINE vcNroTransaccion  LIKE sga_insc_cursadas.nro_transaccion;
   DEFINE vcMatGenerica     LIKE sga_insc_cursadas.materia_generica;
   DEFINE dtFechaHoraActual DATETIME YEAR TO SECOND;
   DEFINE i, posinicial, long_subc, iInscCur smallint;
   DEFINE n_cant_promocion, iSubcomision, iCupo  integer;
   DEFINE s_aux, estaentransaccion char(1);
   DEFINE vcNombreSubcom    LIKE sga_subcomisiones.nombre;
   DEFINE vcEstado          LIKE sga_insc_cursadas.estado;

  -- si hay algun error
  ON EXCEPTION SET SQLErr, ISAMError, errorInfo
      IF estaentransaccion = 'S' and pEstaEnTransaccion = 'N' THEN
            ROLLBACK WORK;
      END IF;

      LET vcUserError  = '800355' ;
      LET iStatus 	  = -1;
      LET vcMsg 	  =  vcUserError || ',' || SQLErr || ' - ' || errorInfo;
      RETURN iStatus, vcMsg;
   END EXCEPTION;

BEGIN
  
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Parámetros del sistema que se pasan por parámetro:
--  1. pCalidad         = EXECUTE PROCEDURE sp_param_sistema('inscripcion_cursada_calidad')
--  2. pCantMaxInsc     = EXECUTE PROCEDURE sp_param_sistema('cant_max_insc_curs_por_mat_en_per_lect') INTO iCantMaxInsc; 
--  3. pControlarCupo   = EXECUTE PROCEDURE sp_param_sistema('insc_cursada_controla_cupo_comision')
--  4. pPlan y pVersion = Plan y Version actual del alumno
--     EXECUTE PROCEDURE sp_plan_de_alumno( pUnidadAcademica, pCarrera, pLegajo, dtFechaHoraActual )
--
-- Controles Obligatorios  que fueron sacados de este proceso
-- Estos controles obligatorios no se hacen mas en este proceso:
--  (1) NO tenga aprobada la materia (la materia no se recupera en el listado de materias)
--  (2) Verifica que la comisión no tenga su acta de cursado cerrada
--  (3) Verifica que la inscripción no figure en ningún acta de promoción cerrada
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  LET iStatus  = -1;
  LET estaentransaccion = 'N';
  LET posinicial = 1;
  LET iInscCur = 0;

  -- Evaluo parámetros si vienen con valor
  IF pCalidad IS NULL THEN
     EXECUTE PROCEDURE sp_param_sistema('inscripcion_cursada_calidad') INTO pCalidad;
  END IF;
  IF pCantMaxInsc IS NULL THEN
     EXECUTE PROCEDURE sp_param_sistema('cant_max_insc_curs_por_mat_en_per_lect') INTO pCantMaxInsc; 
  END IF;
  IF pControlarCupo IS NULL THEN
     EXECUTE PROCEDURE sp_param_sistema('insc_cursada_controla_cupo_comision') INTO pControlarCupo;
  END IF;


  -- Controlo que ya no este inscripto a esta comision por otra Carrera
  FOREACH SELECT sga_alumnos.carrera
            INTO vcCarrera
            FROM sga_alumnos,
                 sga_insc_cursadas
           WHERE sga_alumnos.unidad_academica = pUnidadAcademica
             AND sga_alumnos.nro_inscripcion  = pNroInscripcion
             AND sga_alumnos.calidad IN ('A', 'P') -- Alumnos Activos o Pasivos
             AND sga_insc_cursadas.unidad_academica = sga_alumnos.unidad_academica
             AND sga_insc_cursadas.carrera          = sga_alumnos.carrera
             AND sga_insc_cursadas.legajo           = sga_alumnos.legajo
             AND sga_insc_cursadas.comision         = pComision
       LET vcUserError  = '800392' ;
       LET vcMsg        =  vcUserError  || ',' || vcCarrera ;
       RETURN iStatus, vcMsg;
  END FOREACH;

  -- cuento la cantidad de inscripciones en periodos lectivos abiertos de una persona en la misma materia.
  SELECT COUNT(sga_insc_cursadas.legajo)
    INTO iInscCur
    FROM sga_alumnos,
         sga_comisiones,
         sga_periodos_lect,
         sga_insc_cursadas
   WHERE sga_alumnos.unidad_academica  = pUnidadAcademica
     AND sga_alumnos.nro_inscripcion   = pNroInscripcion     -- no se esta tomando en cuenta la condicion del alumno
     AND sga_alumnos.calidad IN ('A', 'P') -- Alumnos Activos o Pasivos
     AND sga_comisiones.unidad_academica  = sga_alumnos.unidad_academica
     AND sga_comisiones.materia           = pMateria
     AND sga_periodos_lect.fecha_inactivacion >= TODAY
     AND sga_periodos_lect.anio_academico     = sga_comisiones.anio_academico
     AND sga_periodos_lect.periodo_lectivo    = sga_comisiones.periodo_lectivo
     AND sga_insc_cursadas.unidad_academica = sga_alumnos.unidad_academica
     AND sga_insc_cursadas.carrera          = sga_alumnos.carrera
     AND sga_insc_cursadas.legajo           = sga_alumnos.legajo
     AND sga_insc_cursadas.comision         = sga_comisiones.comision
--U820 ***************************************************************
    AND sga_insc_cursadas.estado not in ("B", "R");
-- ***************************************************************

  -- si llegue al limite
  IF iInscCur >= pCantMaxInsc THEN
     LET vcUserError  = '800351' ;
     LET vcMsg        =  vcUserError || ',' || pCantMaxInsc ;
     RETURN iStatus, vcMsg;
  END IF ;


  -- seteo la calidad de Inscripcion (Regularizar o Promocionar)
  LET cCalidadInsc = 'R' ;
  LET n_cant_promocion = 0;
  IF pCalidad = 'P' THEN
      -- Verifico si la materia es Promovible
      IF (SELECT promovible
            FROM sga_materias
           WHERE sga_materias.unidad_academica = pUnidadAcademica
             AND sga_materias.materia          = pMateria) = 'S' THEN

         -- El alumno puede promover la Materia
         -- Verificar que la comision tenga definida en su escala de notas la calidad de promocion

         SELECT COUNT(*)
           INTO n_cant_promocion
           FROM sga_comisiones,
                sga_det_escala
          WHERE sga_comisiones.comision = pComision
            AND resultado = 'P'
            AND sga_comisiones.escala_notas = sga_det_escala.escala_notas;

         IF n_cant_promocion IS NULL THEN
            LET n_cant_promocion = 0;
         END IF;

         IF n_cant_promocion > 0 THEN
            LET cCalidadInsc = 'P' ;
         END IF;
      END IF;
  END IF; -- Calidad Inscripcion

  -- Defino el estado de la Inscripcion segun lo que recibio el procedure y lo que indica el parametro del sistema segun la interfaz.
  LET vcEstado = pEstado ;
  IF pEstado = 'A' THEN	-- si los controles pasaron todos OK
     -- verifico el valor del parametro del sistema que estable el estado de las Inscripciones a Cursadas
     EXECUTE PROCEDURE sp_param_sistema(pInterfaz || '_estado_final_insc_cursada')  INTO vcEstado ;
  END IF ;

  -- Abro Transacción
  IF pEstaenTransaccion = 'N' THEN
    BEGIN WORK;
    LET estaentransaccion = 'S';
  END IF;
   
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- CONTROL DE CUPO EN LA COMISION Y SUBCOMISIONES
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  IF pControlarCupo = 'S' THEN
      -- Cupo en la comision
      UPDATE sga_comisionescupo 
         SET cant_inscripciones = cant_inscripciones + 1
       WHERE comision = pComision
         AND cant_inscripciones < capacidad;
      
      IF DBINFO("sqlca.sqlerrd2") = 0 THEN
        IF pEstaenTransaccion = 'N' AND estaentransaccion = 'S' THEN
           ROLLBACK WORK;
        END IF;
        
        -- No hay cupo en la comision. No pudo actualizar el cupo.
        SELECT capacidad INTO iCupo FROM sga_comisionescupo WHERE comision = pComision;
        LET iStatus = -1 ;
        LET vcMsg = '800369' || ',' || pNombreComision || ',' || iCupo; 	
        RETURN iStatus, vcMsg;
      END IF; 
  ELSE
    -- Actualizo cantidad de inscriptos en comisiones y subcomision igualmente sin controlar el cupo
    UPDATE sga_comisionescupo  SET cant_inscripciones = cant_inscripciones + 1 WHERE comision = pComision;
  END IF;    
      
  -- Verifico cupo para las subcomisiones elegidas por el alumno
  IF pSubcomisiones IS NOT NULL AND LENGTH(TRIM(pSubcomisiones)) > 0 THEN
     LET long_subc = LENGTH(TRIM(pSubcomisiones));
     LET posinicial = 1;
     
     FOR i = 1 TO long_subc
       LET s_aux = SUBSTR(pSubcomisiones,i,1);
       IF s_aux = ','  THEN
         LET iSubComision = TRIM(SUBSTR(pSubcomisiones,posinicial, i - 1));

         IF pControlarCupo = 'S' THEN                  
             UPDATE sga_subcomcupo 
                 SET cant_inscripciones = cant_inscripciones + 1
               WHERE comision   = pComision
                AND subcomision = iSubComision
                AND cant_inscripciones < capacidad;
             
             IF DBINFO("sqlca.sqlerrd2") = 0 THEN
               IF pEstaenTransaccion = 'N' AND estaentransaccion = 'S' THEN
                 ROLLBACK WORK;
               END IF;
               -- No hay cupo en la Subcomision. No pudo actualizar el cupo.
               SELECT nombre, capacidad  INTO vcNombreSubCom, iCupo 
                   FROM sga_subcomisiones 
                  WHERE comision = pComision
                    AND subcomision = iSubcomision;
                    
               LET iStatus = -1 ;
               LET vcMsg = '800396,' || vcNombreSubCom ||  ',' || pNombreComision || ',' || iCupo; 
               RETURN iStatus, vcMsg ;
             END IF;
         ELSE
             -- Actualizo igualmente la cantidad de inscriptos si no controlo el cupo.
             UPDATE sga_subcomcupo SET cant_inscripciones = cant_inscripciones + 1 WHERE comision   = pComision AND subcomision = iSubComision;
         END IF;    
         LET posinicial = i + 1;
       END IF; -- s_aux
     END FOR; -- Fin de subcomisiones
  END IF; -- Subcomisiones  

  -- Obtengo Nro. de Transaccion segun interfase
  EXECUTE PROCEDURE sp_nroTransaccAG( ) INTO vcNroTransaccion ;

  LET vcMatGenerica = NULL ;
  LET dtFechaHoraActual = CURRENT YEAR TO SECOND;
   
  -- agrego la inscripcion
  INSERT INTO sga_insc_cursadas (unidad_academica,carrera,legajo,comision,plan,version,fecha_inscripcion,calidad_insc, materia_generica, nro_transaccion, interfaz, estado )
     VALUES ( pUnidadAcademica, pCarrera, pLegajo, pComision, pPlan, pVersion, dtFechaHoraActual, cCalidadInsc, vcMatGenerica, vcNroTransaccion, pInterfaz, vcEstado );

  -- si llego hasta aca, esta todo OK
  LET iStatus 	= 1;
  IF vcEstado = 'A' THEN
     LET vcUserError  = '800350' ;
  ELSE
     LET vcUserError  = '800353' ;
  END IF;
  LET vcMsg = vcUserError || ',' || vcNroTransaccion || ',' || to_char(dtFechaHoraActual,"%d/%m/%Y %H:%M:%S");

  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Grabo las inscripciones a subcomisiones si hay.
  -- agrego la inscripcion
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  -- Inscribo en las subcomisones elegidas por el alumno
  IF pSubcomisiones IS NOT NULL AND LENGTH(TRIM(pSubcomisiones)) > 0 THEN
    LET long_subc = LENGTH(TRIM(pSubcomisiones));

    LET posinicial = 1;
    FOR i = 1 TO long_subc
      LET s_aux = SUBSTR(pSubcomisiones,i,1);
      IF s_aux = ','  THEN
        LET iSubComision = TRIM(SUBSTR(pSubcomisiones,posinicial, i - 1));
        
        -- Inscribo a la subcomision
        INSERT INTO sga_insc_subcom (unidad_academica, carrera, legajo, comision, subcomision)
             VALUES (pUnidadAcademica, pCarrera, pLegajo, pComision, iSubComision);
        LET posinicial = i + 1;
      END IF;
    END FOR;
  END IF; -- Subcomisiones  

  -- Cierro la transacción
  IF estaentransaccion = 'S' AND pEstaenTransaccion = 'N' THEN
    COMMIT WORK; 
  END IF;

-- Retorna OK
RETURN iStatus, vcMsg;
 
END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_i_inscCursadas ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_i_inscCursadas 
-- *****************************************************************************
revoke execute on "dba".sp_i_inscCursadas from public;
grant execute on "dba".sp_i_inscCursadas to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_i_inscCursadas to internet; -- Rol de usuario de Internet