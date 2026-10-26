-- Controla si el Alumno en las carrera ('00001', '00005', '00006', '00011', '00012', '00009') al momento de inscribirse a cursar la 7ma materia tiene aprobada dentro de las 6 anteriores (Q0012) - Taller de Lectura y Producción de Textos. 
-- A pedido de FIQ, Se evitaría que alumnos que están por recibirse, no tengan aún aprobado el Taller de Lectura y Producción de Textos.

CREATE PROCEDURE "dba".verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR CONTINUO

ON EXCEPTION 
END EXCEPTION WITH RESUME;

-- El control esta asociado al Punto de Control Nro4 (Alumno - Materia)

-- set triggers for par_implem_control disabled;
-- set constraints all deferred;

insert into par_implem_control (stored_procedure, parametros) values ("ctr820_septimaMate", "s,s,s,s");
--SELECT * FROM par_controles order by 1
insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (82001003, "ctr820_septimaMate", "Controla Alumno aprobó Taller de Lectura y Producción de Textos.", "Controla Alumno aprobó Taller de Lectura y Producción de Textos.", null);

insert into par_cont_x_punto (punto_de_control, control) values (4, 82001003);


execute procedure sp_confcont_cont (4, 82001003);

END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_datos();
DROP PROCEDURE "dba".verifica_datos();


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_septimamate') THEN
		DROP PROCEDURE ctr820_septimamate;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **************************************************************************
-- Control: ctr820_septimaMate
-- Version 1.3
--
-- Controla si el Alumno si el alumno al momento de inscribirse a cursar la 7ma materia tiene aprobada dentro de las 6 anteriores Taller de Lectura y Producción de Textos.
--       devuelve:  1 - si esta OK        Tiene 
--                 -1 - en otro caso       NO Tiene 
--
-- **************************************************************************

-- Dropping procedure
-- DROP PROCEDURE ctr820_septimaMate;

-- Creating procedure
CREATE PROCEDURE "dba".ctr820_septimaMate(pUnidadAcademica  LIKE sga_alumnos.unidad_academica,
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
   DEFINE viCantAprob integer;
  
   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'ctr820_septimaMate' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg;
   END EXCEPTION;        

BEGIN

BEGIN

on exception in (-206)
       -- Tabla no existe continuo el proceso	
end exception with resume;
	DROP TABLE aprobadasAlumno;
END;

   -- seteo los valores default
   LET iStatus		= 1 ;
   LET vcMsg		= 'OK';
   LET viCantAprob  = 0;
   
   	SELECT	carrera, legajo, materia
	FROM 	vw_hist_academica
	WHERE	legajo = plegajo
		AND carrera = pcarrera
		AND carrera IN ('00001', '00005', '00006', '00011', '00012', '00009')
		AND resultado = 'A'
		AND materia NOT IN (SELECT materia FROM u820_cursos_ing WHERE carrera = pcarrera)
	INTO TEMP	aprobadasAlumno;

	SELECT	COUNT(*) INTO viCantAprob 
	FROM 	aprobadasAlumno;
	
    IF ( viCantAprob >= 6 )  THEN
	IF NOT EXISTS (SELECT materia FROM aprobadasAlumno WHERE materia IN ('Q0012', '60015')) THEN
		-- Error. NO Tiene la Materia Taller de Lectura y Producción de Textos Aprobada.
		LET vcUserError  = '82001004';
		LET iStatus 	  = -1; 
		LET vcMsg 	  =  vcUserError || ',' || pMateria || ',' || pCarrera;
		RETURN iStatus, vcMsg; 
	END IF;
   END IF;
   -- FIN TRATAMIENTO DE EQUIVALENCIA PARCIAL.

RETURN iStatus, vcMsg; 
END;

BEGIN

on exception in (-206)
       -- Tabla no existe continuo el proceso	
end exception with resume;
	DROP TABLE aprobadasAlumno;
END;

END PROCEDURE;
-- ************************ Fin Control ctr820_septimaMate ***********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".ctr820_septimaMate
-- *****************************************************************************
revoke execute on "dba".ctr820_septimaMate from public;
grant execute on "dba".ctr820_septimaMate to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_septimaMate to internet; -- Rol de usuario de Internet