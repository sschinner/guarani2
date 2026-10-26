CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_service_requisitos_ingreso') THEN
		DROP PROCEDURE web_service_requisitos_ingreso;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: tipo_documento, nro_documento y carrera;

CREATE PROCEDURE "dba".web_service_requisitos_ingreso(ptipo_documento	LIKE dba.sga_personas.tipo_documento,
				pnro_documento	LIKE dba.sga_personas.nro_documento,
				pcarrera	LIKE dba.sga_carreras.carrera)

RETURNING varchar(10),	-- requisito
	varchar(50),	-- nombre
	varchar(15),	-- fecha
	varchar(1);	-- exceptuado

-- Variables locales del procedimiento
DEFINE vrequisito	varchar(10);
DEFINE vnombre		varchar(50);
DEFINE vfecha		varchar(15);
DEFINE vexceptuado	varchar(1);
DEFINE vnro_inscripcion LIKE sga_carrera_aspira.nro_inscripcion;

--Variables para el manejo de excepciones
DEFINE sql_err	 	integer;
DEFINE isam_err 	integer;
DEFINE error_info	varchar(76);

ON EXCEPTION SET sql_err, isam_err, error_info                                        
	RAISE EXCEPTION  sql_err, isam_err, error_info;
	END EXCEPTION;   
BEGIN

LET vrequisito	= NULL;
LET vnombre	= NULL;
LET vfecha	= NULL;
LET vexceptuado	= NULL;
LET vnro_inscripcion	= NULL;

	-- Verifico si existe la persona
	IF EXISTS (SELECT *
		FROM 	sga_carrera_aspira as ca
		JOIN	sga_personas as p ON ca.nro_inscripcion = p.nro_inscripcion
		WHERE	p.tipo_documento = ptipo_documento
			AND p.nro_documento = pnro_documento
			AND ca.carrera = pcarrera) THEN
			
		-- Obtengo el numero de inscripcion de la persona
		SELECT	FIRST 1 p.nro_inscripcion
		INTO	vnro_inscripcion
		FROM 	sga_carrera_aspira as ca
		JOIN	sga_personas as p ON ca.nro_inscripcion = p.nro_inscripcion
		WHERE	p.tipo_documento = ptipo_documento
			AND p.nro_documento = pnro_documento
			AND ca.carrera = pcarrera;
		
		-- Retorno los requisitos vinculados a la persona y exceptuados
		FOREACH 
			SELECT	DISTINCT r.requisito, r.nombre, to_char(rc.fecha_presentacion, '%d/%m/%Y'), CASE WHEN rc.exceptuado = 'S' THEN 'S' ELSE 'N' END
			INTO	vrequisito, vnombre, vfecha, vexceptuado
			FROM	sga_req_cumplidos as rc
			JOIN	sga_requisitos as r ON r.requisito = rc.requisito
			WHERE	nro_inscripcion = vnro_inscripcion
			AND 	rc.fecha_presentacion IS NOT NULL

			RETURN vrequisito, vnombre, vfecha, vexceptuado WITH RESUME;
		END FOREACH;
	END IF;

END;

END PROCEDURE;

-- Casos de prueba
{
Casos:
-- Aspirante con requisitos en la carrera
EXECUTE PROCEDURE "dba".web_service_requisitos_ingreso(0, '31862148', '03');
-- Aspirante no inscripto en la carrera
EXECUTE PROCEDURE "dba".web_service_requisitos_ingreso(0, '31862148', '02');
-- Aspirante inexistente
EXECUTE PROCEDURE "dba".web_service_requisitos_ingreso(0, '31862148888', '02');

}

-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_dat_acad_hefe 
-- *****************************************************************************
revoke execute on "dba".web_service_requisitos_ingreso from public;
grant execute on "dba".web_service_requisitos_ingreso to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_service_requisitos_ingreso to internet; -- Rol de usuario de Internet
