CREATE PROCEDURE verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR RETORNO

ON EXCEPTION 


END EXCEPTION WITH RESUME;

-- El control es sobre la persona

insert into par_implem_control (stored_procedure, parametros) values ("ctr820_regucarrera", "s,s,s,n");
insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (820021, "ctr820_regucarrera", "Controla la regularidad de un alumno.", "Controla la regularidad de un alumno.", null);
insert into par_cont_x_punto (punto_de_control, control) values (26, 820021);
execute procedure sp_confcont_cont (26, 820021);

update sga_conf_controles set activo = 'S'
where operacion = 'agcert01'
and control in ('820021'); 
	
END
END PROCEDURE;

EXECUTE PROCEDURE verifica_datos();
DROP PROCEDURE verifica_datos();


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_regucarrera') THEN
		DROP PROCEDURE ctr820_regucarrera;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **************************************************************************
-- Control: ctr820_regucarrera
-- 
-- Controla si un alumno es regular en la carrera. Mira la tabla sga_alumnos
-- Ultima modificacion 2.08.0 
-- Se descarta verificacion para los certificados Analitico, Hist. Academica y Mat. Aprobadas
-- **************************************************************************
-- drop procedure ctr820_regucarrera;
CREATE PROCEDURE ctr820_regucarrera(	 pUnidadAcademica  LIKE sga_alumnos.unidad_academica,
                                     pCarrera          LIKE sga_alumnos.carrera,
                                     pLegajo           LIKE sga_alumnos.legajo,
                                     pCertificado      LIKE sga_certificados.certificado)
	RETURNING 	smallint, 		-- status
			varchar(255);	-- <mensaje, parametros>

  /*  Controla si el Alumno es regular en la Carrera
       devuelve:  1 - si esta OK y msg
	        -1 - no es Regular en la Carrera */	

  -- vars para la respuesta
  DEFINE iStatus 		smallint		;	-- status
  DEFINE vcMsg 		varchar(255)	;	-- mensaje y parametros

  -- vars para el manejo de excepciones
   DEFINE sql_err,isam_err 		integer		;
   DEFINE error_info 	varchar(76)	;
   DEFINE vcUserError	varchar(10) 	;

  --vars locales
   DEFINE  vcRegular LIKE sga_alumnos.regular;
   DEFINE  vcNombreCarrera LIKE sga_carreras.nombre;

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'ctr820_regucarrera' || ',' || sql_err || ' - '  || error_info ; 	
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN

   -- seteo los valores default
   LET iStatus 	= 1; 
   LET vcMsg 	= 'OK' ;   

IF (pCertificado <> 100 and pCertificado <> 9 and  pCertificado <> 5)  THEN

   SELECT regular, nombre INTO vcRegular, vcNombreCarrera
	FROM sga_alumnos, sga_carreras
	WHERE sga_alumnos.unidad_academica = pUnidadAcademica
	  AND sga_alumnos.carrera = pCarrera
	  AND sga_alumnos.legajo = pLegajo
	 AND sga_alumnos.unidad_academica = sga_carreras.unidad_academica
	 AND sga_alumnos.carrera = sga_carreras.carrera;

   IF DBINFO("sqlca.sqlErrd2") <= 0 THEN
	   LET iStatus		= -1 	;
           LET vcMsg =   '800200,(' || vcNombreCarrera || ') - (' || pLegajo || ')';
   ELSE
	IF vcRegular <> 'S' THEN
	   LET iStatus	= -1 	;
           LET vcMsg =   '800382,'|| pLegajo || ',' || vcNombreCarrera;
	END IF;
   END IF;

END IF;

RETURN iStatus, vcMsg; 
END;
END PROCEDURE;
-- **************************************************************************
revoke execute on "dba".ctr820_regucarrera from public;
grant execute on "dba".ctr820_regucarrera to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_regucarrera to internet; -- Rol de usuario de Internet

