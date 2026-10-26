-- Controla si el Alumno NO tiene la Materia Regularizada!. Es decir que este control falla si la materia No esta Regularizada. A pedido de FIQ, para controlar alumnos que pueden promocionar una materia. Para ello, los alumnos deben estar regulares en la materia.

CREATE PROCEDURE "dba".verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR CONTINUO

ON EXCEPTION 
END EXCEPTION WITH RESUME;

-- El control esta asociado al Punto de Control Nro4 (Alumno - Materia)

-- set triggers for par_implem_control disabled;
-- set constraints all deferred;

insert into par_implem_control (stored_procedure, parametros) values ("ctr820_mateNOregul", "s,s,s,s");

insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (82003, "ctr820_mateNOregul", "Controla Alumno SI haya Regularizado.", "Controla que el Alumno SI haya regularizado la  materia.", null);

insert into par_cont_x_punto (punto_de_control, control) values (4, 82003);


execute procedure sp_confcont_cont (4, 82003);

END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_datos();
DROP PROCEDURE "dba".verifica_datos();


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_matenoregul') THEN
		DROP PROCEDURE ctr820_matenoregul;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **************************************************************************
-- Control: ctr_materiaNOregul
-- Version 1.3
--
-- Controla si el Alumno NO tiene la Materia Regularizada!
--       devuelve:  1 - si esta OK        Tiene 
--                 -1 - en otro caso       NO Tiene 
--
-- **************************************************************************

-- Dropping procedure
-- DROP PROCEDURE ctr820_mateNOregul;

-- Creating procedure
CREATE PROCEDURE "dba".ctr820_mateNOregul(pUnidadAcademica  LIKE sga_alumnos.unidad_academica,
                                  pCarrera          LIKE sga_alumnos.carrera,
                                  pLegajo           LIKE sga_alumnos.legajo,
                                  pMateria          LIKE sga_materias.materia)

	RETURNING 	smallint,       -- status
			varchar(255);   -- <mensaje, parametros>

  /*  controla el Alumno tiene o no la Materia Regularizada
       devuelve:  1 - si esta OK            tiene la Materia Regularizada
             -1 - en otro caso       NO Tiene la Materia Regularizada
  */

  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 	integer;
   DEFINE error_info 	varchar(76);
   DEFINE vcUserError	varchar(10);


   -- variables locales
   DEFINE viCantRegul integer;
  
   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'ctr820_matenoregul' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN
   -- seteo los valores default
   LET iStatus		= 1 ;
   LET vcMsg		= 'OK';
   LET viCantRegul  = 0;
   
   execute procedure sp_alu_reg_materia(punidadacademica, pcarrera, plegajo, pmateria, today) into viCantRegul;
	
    IF ( viCantRegul = 0 )  THEN
       -- Error. NO Tiene la Materia Regularizada por Equivalencia Parcial.
       LET vcUserError  = '820003';
       LET iStatus 	  = -1; 
       LET vcMsg 	  =  vcUserError || ',' || pMateria || ',' || pCarrera;
       RETURN iStatus, vcMsg; 
   END IF;
   -- FIN TRATAMIENTO DE EQUIVALENCIA PARCIAL.


RETURN iStatus, vcMsg; 
END;
END PROCEDURE;
-- ************************ Fin Control ctr_materiaNOregul ***********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".ctr820_mateNOregul
-- *****************************************************************************
revoke execute on "dba".ctr820_mateNOregul from public;
grant execute on "dba".ctr820_mateNOregul to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_mateNOregul to internet; -- Rol de usuario de Internet