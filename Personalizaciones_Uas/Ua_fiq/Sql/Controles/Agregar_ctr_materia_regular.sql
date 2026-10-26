-- Controla si el Alumno tiene la Materia Regularizada!

CREATE PROCEDURE "dba".verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR CONTINUO

ON EXCEPTION 
END EXCEPTION WITH RESUME;

-- El control esta asociado al Punto de Control Nro4 (Alumno - Materia)


insert into par_implem_control (stored_procedure, parametros) values ("ctr_materiaregul", "s,s,s,s");

insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (82002, "ctr_materiaregul", "Controla Alumno NO haya Regularizado.", "Controla que el Alumno NO haya regularizado la  materia.", null);

insert into par_cont_x_punto (punto_de_control, control) values (4, 82002);


execute procedure sp_confcont_cont (4, 82002);

END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_datos();
DROP PROCEDURE "dba".verifica_datos();


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr_materiaregul') THEN
		DROP PROCEDURE ctr_materiaregul;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **************************************************************************
-- Control: ctr_materiaregul
-- Version 1.3
--
-- Controla si el Alumno tiene la Materia Regularizada!
--       devuelve:  1 - si esta OK         No Tiene 
--                 -1 - en otro caso       Tiene 
--
-- **************************************************************************

CREATE PROCEDURE "dba".ctr_materiaregul(pUnidadAcademica  LIKE sga_alumnos.unidad_academica,
                                  pCarrera          LIKE sga_alumnos.carrera,
                                  pLegajo           LIKE sga_alumnos.legajo,
                                  pMateria          LIKE sga_materias.materia)

	RETURNING 	smallint,       -- status
			varchar(255);   -- <mensaje, parametros>

  /*  controla el Alumno tiene o no la Materia Regularizada
       devuelve:  1 - si esta OK            no tiene la Materia Regularizada
             -1 - en otro caso       Tiene la Materia Regularizada
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
     LET vcMsg = '800321' || ',' || 'ctr_materiaregul' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN
   -- seteo los valores default
   LET iStatus		= 1 ;
   LET vcMsg		= 'OK';
   LET viCantRegul  = 0;
   
execute procedure sp_alu_reg_materia(punidadacademica, pcarrera, plegajo, pmateria, today) into viCantRegul ;

    IF ( viCantRegul > 0 )  THEN
       -- Error. Tiene la Materia Regularizada
       LET vcUserError  = '800383';
       LET iStatus 	  = -1; 
       LET vcMsg 	  =  vcUserError || ',' || pMateria || ',' || pCarrera;
       RETURN iStatus, vcMsg; 
   END IF;

RETURN iStatus, vcMsg; 
END;
END PROCEDURE;
-- ************************ Fin Control ctr_materiaaprob ***********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".ctr_materiaregul
-- *****************************************************************************
revoke execute on "dba".ctr_materiaregul from public;
grant execute on "dba".ctr_materiaregul to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr_materiaregul to internet; -- Rol de usuario de Internet