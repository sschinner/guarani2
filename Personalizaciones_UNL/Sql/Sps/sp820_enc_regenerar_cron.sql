CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_enc_regenerar_cron') THEN
		DROP PROCEDURE sp820_enc_regenerar_cron;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ***********************************************************************************
-- SIU-GUARANI
-- Procedure: sp820_enc_regenerar_cron
-- Version 2.09.0
-- 
-- * Genera los formularios, conceptos, elementos y encuestados relacionados con un alcance de encuesta
--   Setea el campo kolla_sincronizar = 'S' para que se re-sincronice con Kolla Nuevamente en el caso que existan formularios nuevos
--   o se hayan dado de baja formularios ya creados en kolla.
-- * Genera los encuestados de acuerdo al alcance definido.
-- * Dependiendo del campo "gde_encues_alcance.generar", es que llama al procedure correspondiente (sp_enc_crea_xxxx)
-- ***********************************************************************************
-- EXECUTE PROCEDURE dba.sp820_enc_regenerar_cron ();

CREATE PROCEDURE "dba".sp820_enc_regenerar_cron ()
 RETURNING INTEGER; -- cantidad de personas a encuestar

DEFINE iCantEncuestas integer;
DEFINE c_generar LIKE gde_encues_alcance.generar;
DEFINE c_encuestado LIKE gde_encues_alcance.encuestado;
DEFINE c1,c2,c3,c4,pAlcance integer;

BEGIN

LET pAlcance = NULL;

-- U820 ***************************************************
-- Recuperar alcance predefinido para Encuesta Egresados de Grado: id_encuesta_kolla=131 (2da. encuesta Vigente);
-- Recuperar alcance predefinido para Encuesta Egresados de Posgrado: id_encuesta_kolla=133;
-- U820 ***************************************************
FOREACH SELECT alcance INTO pAlcance
FROM gde_encuestas enc
	join gde_encues_alcance alc
	on enc.encuesta = alc.encuesta
WHERE enc.kolla_id_encuesta in (131,133,136)

-- U820 ***************************************************

 -- Recupero datos del alcance
 SELECT  generar, encuestado INTO c_generar, c_encuestado 
   FROM gde_encues_alcance WHERE alcance = pAlcance;

 -- Crea Tablas temporales
 EXECUTE PROCEDURE sp_enc_crea_tabla (pAlcance);

 IF c_generar = 'U' THEN
    -- Encuesta para Alumnos o Docentes (encuesatdo = A o D)
    -- Una encuesta por persona   
    EXECUTE PROCEDURE sp_enc_crea_u (pAlcance);

 ELIF c_generar = 'C' THEN

    -- Una encuesta por cada carrera en la que el alumno esta activo
    EXECUTE PROCEDURE sp_enc_crea_c (pAlcance);

 ELIF c_generar = 'I' OR c_generar = 'P' THEN

    -- I = Una encuesta por cada materia inscripto a cursar (inscripto/aprobada/desaprobada) (encuestado = A)
    -- P = Una encuesta por cada comision en la que estuvo el docente como docente     (encuestado = D)
    EXECUTE PROCEDURE sp_enc_crea_i (pAlcance);

 ELIF c_generar = 'A' THEN
    
    -- Una encuesta por cada materia (examen/promocion/equivalenica: Aprobada/Desaprobada...)        
    EXECUTE PROCEDURE sp_enc_crea_a (pAlcance);

 ELIF c_generar = 'D' THEN        
    -- Una encuesta por cada docente de la comision. Actuacion docente en comisiones
    EXECUTE PROCEDURE sp_enc_crea_d (pAlcance);
 
 ELIF c_generar = 'E' THEN        
    -- Una encuesta por cada docente de cada mesa de examen. Actuacion docente en mesas de examen
     EXECUTE PROCEDURE sp_enc_crea_e (pAlcance);
 
 ELIF c_generar = 'T' THEN        
    -- T = Encuesta para docentes sobre mesas de examen. Una encuesta por cada mesa de examen en la que estuvo el docente. 
    EXECUTE PROCEDURE sp_enc_crea_t(pAlcance);
 END IF;

    
 -- Borra Tablas temporales
 EXECUTE PROCEDURE sp_enc_borra_tabla();
 
 -- Verifico si se necesita resincronizar
 LET c1 = 0;
 LET c2 = 0;
 LET c3 = 0;
 LET c4 = 0;
 SELECT COUNT(*) INTO c1 FROM gde_formulario WHERE alcance = pAlcance AND generado_en_kolla = 'N';
 SELECT COUNT(*) INTO c2 FROM gde_concepto WHERE generado_en_kolla = 'N';
 SELECT COUNT(*) INTO c3 FROM gde_elemento WHERE generado_en_kolla = 'N';
 SELECT COUNT(*) INTO c4 FROM gde_tipo_elemento WHERE generado_en_kolla = 'N';

 IF (c1 + c2 + c3 + c4) > 0 THEN
           
   -- Marco el alcance para que se tenga que volver a sincronizar con Kolla	
   UPDATE gde_encues_alcance 
      SET kolla_sincronizar = 'S' 
    WHERE alcance = pAlcance;
 END IF;
  
 LET iCantEncuestas = 0;
 SELECT COUNT(*) INTO iCantEncuestas
   FROM gde_formulario as F,
        gde_encues_persona as EP
  WHERE F.formulario = EP.formulario
    AND F.estado = 'A'
    AND F.alcance = pAlcance;

 -- Retorno cantidad de encuestas a responderse...
 RETURN iCantEncuestas;
END FOREACH;

END;
END PROCEDURE;
-- +++++++++++++++++++++++++ Fin procedure sp_enc_regenerar ++++++++++++++++++