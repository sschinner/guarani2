-- **************************************************************************
-- Control: ctr820_AcDatCeSe
-- Version: 2.05.2

-- Verifica la sede del alumno
-- **************************************************************************
CREATE PROCEDURE "dba".verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR RETORNO
ON EXCEPTION 

END EXCEPTION WITH RESUME;

INSERT INTO par_implem_control (stored_procedure, parametros) VALUES ('ctr820_AcDatCeSe', 's,s,s,s');
INSERT INTO par_controles (control, stored_procedure, desc_abreviada, descripcion) VALUES (82056, 'ctr820_AcDatCeSe', 'Controla la sede de la persona que intenta actualizar datos', 'Controla la sede de la persona que intenta actualizar datos');
INSERT INTO par_cont_x_punto (punto_de_control, control) VALUES (2, 82056);

Execute Procedure  sp_ConfCont_Cont (2, 82056) ;
	
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_datos();
DROP PROCEDURE "dba".verifica_datos();

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_acdatcese') THEN
		DROP PROCEDURE ctr820_acdatcese;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".ctr820_AcDatCeSe ( 	pUnidadAcademica LIKE sga_personas.unidad_academica,
                                        			pNroInscripcion          	LIKE sga_alumnos.nro_inscripcion,
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



   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET iStatus = -1 ;
      LET vcMsg = '800321,' || 'ctr820_AcDatCeSe,' || sql_err || ' - '  || error_info ;

      RETURN iStatus, vcMsg;
   END EXCEPTION;

BEGIN

   -- seteo los valores default
   LET iStatus = 1;
   LET vcMsg = '800320';

   LET vc_Sede = NULL;

   IF EXISTS (SELECT '*' FROM sga_personas per
			JOIN sga_alumnos alu
				on per.nro_inscripcion = alu.nro_inscripcion
				and per.unidad_academica = alu.unidad_academica
			      WHERE per.unidad_academica = pUnidadAcademica
				AND per.nro_inscripcion = pNroInscripcion
				AND alu.sede = '00001') THEN
	
   -- La sede del alumno no permite la actualización de datos censales vía Gurani, el control falla.
   -- Por el momento no importa la calidad en la que este el alumno en la carrera
	      	LET iStatus = -1;
		LET vcMsg = '82003002,'; 
   END IF;

   RETURN iStatus, vcMsg ;
END;
END PROCEDURE;
-- ************************ Fin Control "dba".ctr820_AcDatCeSe  ***********************

-- *****************************************************************************
-- Permisos del Control "dba".ctr820_AcDatCeSe  
-- *****************************************************************************
revoke execute on "dba".ctr820_AcDatCeSe  from public;
grant execute on "dba".ctr820_AcDatCeSe  to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_AcDatCeSe  to internet; -- Rol de usuario de Internet