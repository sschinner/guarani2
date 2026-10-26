CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp835rg_insc_autom') THEN
		DROP PROCEDURE sp835rg_insc_autom;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.5.0
-- Procedure sp835rg_insc_autom
-- 
-- Inscribe automáticamente a los alumnos ingresantes a todas las comisones definidas en  
-- la tabla u835rg_comision_in
-- *****************************************************************************
Create Procedure "dba".sp835rg_insc_autom(
                                     p_unidad_academica   LIKE u835rg_comision_in.unidad_academica 
                                   , p_anio_academico     LIKE u835rg_comision_in.anio_academico   
	                   , p_periodo_lectivo    LIKE u835rg_comision_in.periodo_lectivo  
                                   , p_carrera            LIKE u835rg_comision_in.carrera          
                                   , vd_Fecha1 char(10)
                                   , vd_Fecha2 char(10)
        )
        returning
                  integer,
                  varchar(255);



-- DEFINE li_mesas_creadas      Integer;
-- DEFINE li_llamado_mesa       Integer;
-- DEFINE l_nro_prestamo       INTEGER;
-- DEFINE v_llamado             LIKE sga_llamados.llamado                     ;
-- DEFINE v_fecha_inicio        LIKE sga_llamados.fecha_inicio                ;
-- DEFINE v_fecha_fin           LIKE sga_llamados.fecha_fin ;
-- 
-- DEFINE v_legajo              LIKE sga_docentes_llama.legajo                ;
-- DEFINE v_rol                 LIKE sga_docentes_llama.rol                   ;

DEFINE v_comision       LIKE    u835rg_comision_in.carrera     ;
DEFINE v_legajo       LIKE    sga_alumnos.legajo             ;
DEFINE v_calidad_insc   LIKE    u835rg_comision_in.calidad_insc;
DEFINE v_escala_notas   LIKE    sga_comisiones.escala_notas;
DEFINE v_materia   LIKE    sga_comisiones.materia;
DEFINE   vcPlan         LIKE    sga_insc_cursadas.plan         ; 
DEFINE   vcVersion      LIKE    sga_insc_cursadas.version      ;
DEFINE vcNroTransaccion  LIKE sga_insc_cursadas.nro_transaccion; 



DEFINE v_cant_insc      integer;

-- variables de error
DEFINE sql_err int;
DEFINE isam_err int;
DEFINE error_info varchar(70);

DEFINE p_fecha_desde, p_fecha_hasta DATE;


ON EXCEPTION set sql_err, isam_err, error_info
    -- Error. no realizo nada
   Rollback Work;
      raise exception  sql_err, isam_err, error_info;
--    raise exception -746, 0, 'SQL error' || sql_err || ' - '|| error_info || '. Problemas al generar la mesa ' || v_mesa_examen ||  ' en la materia '|| v_materia || ' .';

   
END EXCEPTION;

BEGIN
 -- Controles
 -- NO hay alumnos
 --If (Select count(*) from sga_turnos_examen where anio_academico = p_anio_aca_origen and turno_examen = p_turno_origen ) = 0  Then
 --    Return -1,'El turno origen no existe.';
 --End if;
END;


BEGIN WORK;
   LET p_fecha_desde = TO_DATE(vd_Fecha1, "%d/%m/%Y");
   LET p_fecha_hasta = TO_DATE(vd_Fecha2, "%d/%m/%Y");
    

   LET v_cant_insc = 0;

-- Seleccionar alumnos ingresantes
    SELECT  
          sga_alumnos.unidad_academica   
         ,sga_alumnos.carrera            
         ,sga_alumnos.legajo  

    FROM sga_alumnos 

    WHERE
            unidad_academica    =   p_unidad_academica   
        and carrera             =   p_carrera 
        and fecha_ingreso       BETWEEN p_fecha_desde AND  p_fecha_hasta
    
    INTO TEMP temp_alumnos;


FOREACH
    SELECT
              	comision,
	calidad_insc
              

    INTO
              v_comision,
              v_calidad_insc

    FROM u835rg_comision_in
    WHERE    
             unidad_academica  =  p_unidad_academica
        AND  anio_academico    =  p_anio_academico  
        AND  periodo_lectivo   =  p_periodo_lectivo 
        AND  carrera           =  p_carrera         

    Select materia, escala_notas INTO v_materia, v_escala_notas from sga_comisiones where comision = v_comision;

    If v_calidad_insc = 'A' Then
        If (  SELECT count(*)  
                FROM sga_det_escala  
                WHERE      sga_det_escala.escala_notas = v_escala_notas  
                       AND sga_det_escala.resultado = 'P' ) > 0 Then
            -- Tienen Promoción 
             LET v_calidad_insc = 'P';
        Else
            -- Regulariza
            LET v_calidad_insc = 'R';
        End If;
    End If;


    -- Cargar llamdos
    FOREACH
        Select
              legajo 
            INTO
              v_legajo
        FROM temp_alumnos

        -- Controlar que no tenga la materia aprobada
        If ( SELECT count(*)  
                FROM vw_hist_academica  
                WHERE      vw_hist_academica.unidad_academica     =  p_unidad_academica 
                        AND vw_hist_academica.carrera             =  p_carrera
                        AND vw_hist_academica.legajo              =  v_legajo
                        AND vw_hist_academica.materia             =  v_materia
                        AND vw_hist_academica.resultado           in  ('A','P')     )  > 0 Then
            -- No hago nada
            Continue foreach;
        End If;


        -- obtengo el plan y version del alumno
        EXECUTE PROCEDURE sp_plan_de_alumno( p_unidad_academica, p_carrera, v_legajo , TODAY )  INTO vcPlan, vcVersion ;

IF  Not exists (select '' from sga_insc_cursadas
				where unidad_academica = p_unidad_academica and
					carrera = p_carrera and
					legajo = v_legajo and
					comision = v_comision) THEN
	-- Obtengo Nro. de Transaccion segun interfase
	EXECUTE PROCEDURE sp_nroTransaccAG( ) INTO vcNroTransaccion;
        -- Ejecutar el SP para inscribir al los alumnos
           INSERT INTO sga_insc_cursadas (  unidad_academica, 
                carrera, 
                legajo, 
                comision, 
	plan, 
                version, 
                fecha_inscripcion, 
                calidad_insc, 
                materia_generica,
                nro_transaccion, 
                interfaz, 
                estado)
                    VALUES (
    
                            p_unidad_academica, 
                            p_carrera, 
                            v_legajo, 
                            v_comision, 
                            vcPlan, 
                            vcVersion,
                            CURRENT YEAR TO SECOND, 
                            v_calidad_insc, 
                            null,
                            'AUTO-' || vcNroTransaccion, 
                            1,
                            'P') ;
   LET v_cant_insc = v_cant_insc + 1;

END IF;

END FOREACH;

END FOREACH;


DROP table temp_alumnos;

Commit Work;


RETURN 1,'Todo OK. Se realizaron: ' || v_cant_insc ||' inscripciones.';
END PROCEDURE;

-- ********************** FIN DEL PROCEDURE sp820_tesis_rep_tesis **********************
revoke execute on sp835rg_insc_autom from public;

grant execute on sp835rg_insc_autom to guarani; -- Rol de usuarios de Gestión
grant execute on sp835rg_insc_autom to internet; -- Usuario de internet




