-- *******************************************************************************
-- Controla si el Alumno tiene una regularidad vigente en la materia.
-- El control esta asociado al Punto de Control Nro 4 (Alumno - Materia(Cursadas))
-- *******************************************************************************

insert into par_implem_control (stored_procedure, parametros) values ("ctrcapic01_cursada", "s,s,s,s");

insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (8209901, "ctrcapic01_cursada", "Control Capic: Regularidad Vigente", "Controla que el Alumno no tenga regularidad Vigente", null);

insert into par_cont_x_punto (punto_de_control, control) values (4, 8209901);

execute procedure sp_confcont_cont (4, 8209901);

-- **************************************************************************
-- Control: ctrcapic01_cursada
--
-- Controla si el Alumno tiene una regularidad vigente de la materia
--       devuelve:  1 - si esta OK         No Tiene 
--                 -1 - en otro caso       Tiene 
--
-- **************************************************************************

-- Dropping procedure
-- DROP PROCEDURE "dba".ctrcapic01_cursada;
 
-- Creating procedure
CREATE PROCEDURE "dba".ctrcapic01_cursada(pUnidadAcademica  LIKE sga_alumnos.unidad_academica,
                                  pCarrera          LIKE sga_alumnos.carrera,
                                  pLegajo           LIKE sga_alumnos.legajo,
                                  pMateria          LIKE sga_materias.materia)

	RETURNING 	smallint,       -- status
			varchar(255);   -- <mensaje, parametros>

  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros


  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 	integer;
   DEFINE error_info 	varchar(76);
   DEFINE vcUserError	varchar(10);


   -- variables locales
 
   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'ctrcapic01_cursada' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN
   -- seteo los valores default
   LET iStatus		= 1 ;
   LET vcMsg		= 'OK';
   
   IF EXISTS (Select "1" 
				from sga_cursadas
					where unidad_academica = pUnidadAcademica
						and carrera = pCarrera
						and legajo = pLegajo
						and materia = pMateria
						and resultado = 'A'
						and fin_vigencia_regul >= TODAY) THEN
		LET iStatus		= -1 ;
		LET vcMsg		= '8209901' || ',' || pMateria || ',' || pCarrera;
	END IF;
   
RETURN iStatus, vcMsg; 
END;
END PROCEDURE;
-- ************************ Fin Control ctrcapic01_cursada ***********************

