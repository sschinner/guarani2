CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_prom_alu_res1') THEN
		DROP PROCEDURE sp820_prom_alu_res1;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ******************************************************
-- Lista el promedio de un alumno 
-- Ultima modificacion: Version 1.10.0
-- AHORA EL ATRIBUTO PROMEDIABLE SE SACA SIEMPRE DEL PLAN
-- ******************************************************
--DROP PROCEDURE sp820_prom_alu_res1; 
CREATE PROCEDURE "dba".sp820_prom_alu_res1(
                                    pUA      LIKE sga_alumnos.unidad_academica,
                                    pCarrera LIKE sga_alumnos.carrera,
                                    pLegajo  LIKE sga_alumnos.legajo,
                                    pTodas   char DEFAULT 'S' -- S- Aprobadas y Reprobadas / N- Solo aprobadas
                                   )
 RETURNING decimal(6,2); 

DEFINE cPromedioResolucion char(1);
DEFINE nPromedio		DECIMAL(6,2);

-- Variables para el manejo de excepciones
 DEFINE sql_err             integer;
 DEFINE isam_err          integer;
 DEFINE error_info          varchar(76);

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info

   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;


BEGIN

  -- inicializo las vars.
LET nPromedio		= NULL;
LET cPromedioResolucion = NULL;

EXECUTE PROCEDURE "dba".sp820_prom_alu_res(pUA, pCarrera, pLegajo, pTodas) INTO nPromedio, cPromedioResolucion;

RETURN nPromedio;

END;

END PROCEDURE;
-- **********************************************************************************
revoke execute on "dba".sp820_prom_alu_res1 from public;
grant execute on "dba".sp820_prom_alu_res1 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_prom_alu_res1 to internet; -- Rol de usuario de Internet

