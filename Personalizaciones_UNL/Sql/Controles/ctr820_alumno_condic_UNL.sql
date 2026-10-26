-- *******************************************************************************
-- Controla si el Alumno condicional tiene al menos los requisitos supletorios que UNL exige para poder realizar actividad académica.
-- El control esta asociado al Punto de Control Nro 3 (El alumno elige una operación)
-- Este control debe estar activo en 'equiv002', 'exa00006', 'exa00007'
-- *******************************************************************************
CREATE PROCEDURE verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR RETORNO

ON EXCEPTION 


END EXCEPTION WITH RESUME;

-- El control es sobre la persona

insert into par_implem_control (stored_procedure, parametros) values ("ctr820_alumno_cond", "s,s,s,s");
insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (820008, "ctr820_alumno_cond", "Controla título/supletorio UNL - OK", "Controla título/supletorio UNL - OK", null);
insert into par_cont_x_punto (punto_de_control, control) values (3, 820008);
execute procedure sp_confcont_cont (3, 820008);	

-- Se eliminan registros de configuracion que no corresponden a la unidad academica
delete from sga_conf_controles
where unidad_academica <> (select unidad_academica from sga_valor_inicial);

update sga_conf_controles set activo = 'S'
where operacion in ('equiv002', 'exa00006', 'exa00007')
and control = '820008';

END
END PROCEDURE;


EXECUTE PROCEDURE verifica_datos();
DROP PROCEDURE verifica_datos();

CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_alumno_cond') THEN
		DROP PROCEDURE ctr820_alumno_cond;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();

DROP PROCEDURE verifica_objeto();
-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.0.0
--
-- Procedure ctr_alumno_condic
-- U820
-- Controla que el inscripto sea alumno condicional en los términos de la UNL. Es decir, si es aspirante
-- a carrera con situación aspirante = 'IC' (Posee legajo), no le falten requisitos
-- obligatorios/supletorios relacionados al título por cumplir.
-- **************************************************************************
-- drop procedure dba.ctr820_alumno_cond;
CREATE PROCEDURE dba.ctr820_alumno_cond(pUnidadAcademica  LIKE sga_personas.unidad_academica,
				pCarrera  	LIKE sga_carreras.carrera,
				pLegajo   	LIKE sga_alumnos.legajo,
				pOperacion 	LIKE par_puntos_x_oper.operacion)
					
RETURNING smallint,     -- status
          varchar(255); -- <mensaje, parametros>

/*
devuelve:  1 (OK) / -1 (en otro caso)
           msg
*/

   -- vars para la respuesta
   DEFINE iStatus            smallint;      -- status
   DEFINE vcMsg              varchar(255);  -- mensaje y parametros

   -- var's para el manejo de excepciones
   DEFINE sql_err, isam_err  integer;
   DEFINE error_info         varchar(76);
   DEFINE vcUserError        varchar(10);

   DEFINE vcNroInscripcion   varchar(10);

   -- bloque de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      LET iStatus = -1 ;
      LET vcMsg = '800321,' || 'ctr820_alumno_cond,' || sql_err || ' - '  || error_info ;

      RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN

   -- seteo los valores default
   LET iStatus = 1 ;
   LET vcMsg = '800320' ;

SELECT nro_inscripcion INTO vcNroInscripcion
FROM sga_alumnos WHERE carrera = pCarrera AND legajo = pLegajo;

   ---------------------------------------------------------------------------------------------------------
   -- Si existe en Carrira aspira un registro con situación aspirante = 'IC', es alumno condicional.
   ---------------------------------------------------------------------------------------------------------
   IF (SELECT 	COUNT(casp.situacion_asp)
   	FROM	sga_alumnos al,sga_carrera_aspira casp
   	WHERE	al.unidad_academica = pUnidadAcademica
   	AND	al.carrera = pCarrera
   	AND	al.legajo = pLegajo
   	AND	casp.unidad_academica = al.unidad_academica
   	AND	casp.carrera = al.carrera
   	AND	casp.nro_inscripcion = al.nro_inscripcion
   	AND	casp.situacion_asp = 'IC') > 0 THEN

	-- Verificar Si tiene algún requisito supletorio o el obligatorio presentado o exceptuado

	IF NOT EXISTS (SELECT '*' FROM sga_req_cumplidos 
				WHERE nro_inscripcion = vcNroInscripcion
				AND carrera = pCarrera
				AND requisito IN ('UNL03', 'UNL07', 'UNL15', 'UNL16', 'UNL17', 'UNL18', 'UNL19', 'POS01', 'POS02', 'POS08', 'UNL20', 'UNL21', 'UNL22')
				AND (fecha_presentacion is not null 
					OR  exceptuado = 'S')


	 ) THEN
	      
	      -- Error el inscripto a carrera es alumno condicional por falta de presentación de requisitos obligatorios según UNL.
	      LET iStatus = -1 ;
	      LET vcMsg = '800667';
	END IF;

   END IF ;	

   RETURN iStatus, vcMsg ;

END;

END PROCEDURE;
-- ********************** Fin del procedure ctr820_alumno_cond **********************
