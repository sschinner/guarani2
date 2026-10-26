CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_titulo_grado') THEN
		DROP PROCEDURE ctr820_titulo_grado;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- EXECUTE PROCEDURE dba.ctr820_titulo_grado('EXTBI');

-- DROP PROCEDURE dba.ctr820_titulo_grado;

CREATE PROCEDURE dba.ctr820_titulo_grado(
	pCarrera LIKE sga_carreras.carrera)
	RETURNING char(1);


	-- vars para la respuesta
	DEFINE iStatus             char(1);
	DEFINE vcMsg               varchar(255);

	-- vars para el manejo de excepciones
	DEFINE sql_err             integer;
	DEFINE isam_err            integer;
	DEFINE error_info          varchar(76);

	-- vars locales


	-- blk de excepciones
	ON EXCEPTION SET sql_err, isam_err, error_info                                        
		-- RAISE EXCEPTION  sql_err, isam_err, error_info;
		LET iStatus = 'f' ;
		LET vcMsg = '800321,ctr_titulo_grado,' || sql_err || ' - '  || error_info ;
		RETURN iStatus;
	END EXCEPTION;      

BEGIN

	-- Inicia las variables
	LET iStatus = 'f' ;
	LET vcMsg = 'OK';

IF EXISTS (SELECT '*' FROM sga_carreras WHERE carrera = pCarrera and tipo_de_carrera IN ('B', 'C')) THEN
	LET iStatus = 't';

END IF;

RETURN iStatus;

END;
END PROCEDURE;
-- ************************* Procedure ctr820_titulo_grado ****************************
revoke execute on "dba".ctr820_titulo_grado from public;
grant execute on "dba".ctr820_titulo_grado to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_titulo_grado to internet; -- Rol de usuario de Internet

