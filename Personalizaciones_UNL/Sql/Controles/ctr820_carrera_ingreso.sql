-- Control de carrera de Ingreso Centralizado
-- Verificar el alta del grupo carrera ING01


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_carrera_ingreso') THEN
		DROP PROCEDURE ctr820_carrera_ingreso;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- EXECUTE PROCEDURE dba.ctr820_carrera_ingreso('EXTBI');

-- Procedimiento para verificar si la carrera pertenece al grupo de carreras cuyo ingreso se gestiona centralizadamente por UNL
-- Carreras cuya gestión esta vinculada a Legajo Digital
-- Grupo carrera 'ING01': carreras de ingreso centralizado gestionado por UNL
-- DROP PROCEDURE dba.ctr820_carrera_ingreso;
CREATE PROCEDURE dba.ctr820_carrera_ingreso(
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
		LET vcMsg = '800321,ctr820_carrera_ingreso,' || sql_err || ' - '  || error_info ;
		RETURN iStatus;
	END EXCEPTION;      

BEGIN

	-- Inicia las variables
	LET iStatus = 'f' ;
	LET vcMsg = 'OK';

IF EXISTS (SELECT '*' FROM sga_carreras c
		JOIN sga_carreras_grupo cg
			on c.carrera = cg.carrera 
			and c.unidad_academica = cg.unidad_academica
		JOIN sga_grupos_carrera gg
			on cg.unidad_academica = gg.unidad_academica
			and cg.grupo_carrera = gg.grupo_carrera
WHERE c.carrera = pCarrera
and gg.grupo_carrera = 'ING01') THEN

	LET iStatus = 't';

END IF;

RETURN iStatus;

END;
END PROCEDURE;
-- ************************* Procedure ctr820_carrera_ingreso ****************************
revoke execute on "dba".ctr820_carrera_ingreso from public;
grant execute on "dba".ctr820_carrera_ingreso to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_carrera_ingreso to internet; -- Rol de usuario de Internet

