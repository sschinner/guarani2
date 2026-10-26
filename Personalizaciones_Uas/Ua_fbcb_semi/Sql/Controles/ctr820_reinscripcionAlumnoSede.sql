CREATE PROCEDURE "dba".verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR CONTINUO

ON EXCEPTION 
END EXCEPTION WITH RESUME;


INSERT INTO par_implem_control (stored_procedure, parametros) VALUES ('ctr820_reinscaluse', 's,s,s,s');
INSERT INTO par_controles (control, stored_procedure, desc_abreviada, descripcion) VALUES (82055, 'ctr820_reinscaluse', 'Controla la sede del alumno que se intenta reinscribir', 'Controla la sede del alumno que se intenta reinscribir');
INSERT INTO par_cont_x_punto (punto_de_control, control) VALUES (3, 82055);

Execute Procedure  "dba".sp_ConfCont_Cont (3, 82055) ;

END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_datos();
DROP PROCEDURE "dba".verifica_datos();

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_reinscaluse') THEN
		DROP PROCEDURE ctr820_reinscAluSe;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();



-- **************************************************************************
-- Control: ctr820_reinscAluSede
-- Version: 2.05.2

-- Verifica la sede del alumno
-- **************************************************************************

CREATE PROCEDURE "dba".ctr820_reinscAluSe ( 	pUnidadAcademica LIKE sga_personas.unidad_academica,
                                        			pCarrera          	LIKE sga_carreras.carrera,
                                        			pLegajo           	LIKE sga_alumnos.legajo,
					pOperacion        	LIKE acc_operaciones.operacion )

	RETURNING 	smallint, 		-- status
			varchar(255);	-- <mensaje, parametros>

  -- vars para la respuesta
  DEFINE iStatus            	smallint;      -- status
  DEFINE vcMsg              	varchar(255);  -- mensaje y parametros

   -- var's para el manejo de excepciones
   DEFINE sql_err, isam_err  	integer;
   DEFINE error_info         	varchar(76);
   DEFINE vcUserError        	varchar(10);
   
   -- var's para obtener los datos del stored procedure sp_sanciones_perso
   DEFINE vc_Sede	LIKE dba.sga_alumnos.sede;
   DEFINE vc_Carrera	LIKE dba.sga_carreras.nombre;


   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET iStatus = -1 ;
      LET vcMsg = '800321,' || 'ctr820_reinscAluSe,' || sql_err || ' - '  || error_info ;

      RETURN iStatus, vcMsg;
   END EXCEPTION;

BEGIN

   -- seteo los valores default
   LET iStatus = 1;
   LET vcMsg = '800320';

   LET vc_Sede = NULL;
   LET vc_Carrera = NULL;

   SELECT nombre INTO vc_Carrera FROM sga_carreras
      WHERE unidad_academica = pUnidadAcademica
	AND carrera = pCarrera;

   SELECT sede INTO vc_Sede FROM sga_alumnos
      WHERE unidad_academica = pUnidadAcademica
	AND carrera = pCarrera
	AND legajo = pLegajo;
	
   -- La sede del alumno no permite reinscripción vía Gurani, el control falla
	IF vc_Sede = '00001' THEN
	      	LET iStatus = -1;
		LET vcMsg = '82003001,' || vc_Carrera  ; 
	END IF;

   RETURN iStatus, vcMsg ;
END;
END PROCEDURE;
-- ************************ Fin Control "dba".ctr820_reinscAluSe ***********************

-- *****************************************************************************
-- Permisos del Control "dba".ctr820_reinscAluSe 
-- *****************************************************************************
revoke execute on "dba".ctr820_reinscAluSe from public;
grant execute on "dba".ctr820_reinscAluSe to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_reinscAluSe to internet; -- Rol de usuario de Internet