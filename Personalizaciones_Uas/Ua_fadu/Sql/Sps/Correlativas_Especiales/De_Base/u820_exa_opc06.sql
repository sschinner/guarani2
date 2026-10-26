CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_exa_opc06') THEN
		DROP PROCEDURE u820_exa_opc06;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".u820_exa_opc06(
	pUnidadAcademica 	LIKE sga_conf_controles.unidad_academica,
	pLegajo			LIKE sga_alumnos.legajo,
	pCarrera			LIKE sga_alumnos.carrera,
	pPlan			LIKE sga_alumnos.plan)

   RETURNING  	smallint,		-- status: -1 error/ 1 OK
		varchar(200);

   DEFINE resu		smallint;
   DEFINE sqlerr		integer;
   DEFINE isamerr		integer;
   DEFINE errorinfo		varchar(76);

  -- si hay algun error
  ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
      RETURN -1, errorInfo;
   END EXCEPTION;

BEGIN
	if exists(	select *
		from vw_hist_academica
		where legajo = pLegajo
			and carrera = pCarrera
			and plan = pPlan
			and materia in ("A0208", "A0205")
			and resultado = "A") then
		return 1, "";
	else
		return -1, "No tenés aprobada la materia A0208 Matemática I, ni la A0205 Matemática Básica";
	end if;

END;
END PROCEDURE;



-- execute procedure "dba".u820_exa_opc06 ("FADU", "12345678-1", "1", "1991")


-- *************** Fin del procedimiento  ******************

-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
revoke execute on "dba".u820_exa_opc06 from public;
grant execute on "dba".u820_exa_opc06 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_exa_opc06 to internet; -- Rol de usuario de Internet