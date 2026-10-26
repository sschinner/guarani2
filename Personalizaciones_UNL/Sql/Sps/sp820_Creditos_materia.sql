CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_creditos_materia') THEN
		DROP PROCEDURE sp820_creditos_materia;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

--Este procedimiento devuelve los cr�ditos que otorga una materia mediante sga_atrib_mat_plan.credito
--------------------------------------------------
CREATE PROCEDURE "dba".sp820_creditos_materia ( pUA LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera, pPlan LIKE sga_atrib_mat_plan.plan, pVersion LIKE sga_atrib_mat_plan.version, pMateria LIKE sga_atrib_mat_plan.materia )

	RETURNING integer

-- variables de retorno.

DEFINE vcCreditos     LIKE sga_atrib_mat_plan.credito;

-- vars para el manejo de excepciones
DEFINE SQLErr          integer;
DEFINE ISAMError       integer;
DEFINE errorInfo       varchar(76);

-- si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
   RAISE EXCEPTION  SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN

   -- Inicializaciones.
   LET vcCreditos    = NULL ;

SELECT     sga_atrib_mat_plan.credito
     INTO vcCreditos
     FROM sga_atrib_mat_plan
    WHERE sga_atrib_mat_plan.unidad_academica = pUA
	AND sga_atrib_mat_plan.carrera = pCarrera
	AND sga_atrib_mat_plan.plan = pPlan
	AND sga_atrib_mat_plan.version = pVersion
	AND sga_atrib_mat_plan.materia = pMateria;

RETURN vcCreditos;
END;
END PROCEDURE;


--execute procedure sp820_creditos_materia ('FICH','03', '1999','2', '00425')

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_creditos_materia 
-- *****************************************************************************
revoke execute on "dba".sp820_creditos_materia from public;
grant execute on "dba".sp820_creditos_materia to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_creditos_materia to internet; -- Rol de usuario de Internet