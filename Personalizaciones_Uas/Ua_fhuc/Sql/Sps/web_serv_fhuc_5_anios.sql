-- Procedimiento para FHUC que determina si una persona es alumno y a su vez si es regular o no
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_fhuc_5_anios') THEN
		DROP PROCEDURE web_serv_fhuc_5_anios;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".web_serv_fhuc_5_anios(pnro_documento varchar(15))

RETURNING 	varchar(5), -- 0) Es o no alumno.
			varchar(5); -- Es regular o no

DEFINE vc_regular varchar(5);
DEFINE vc_alumno varchar(5);
DEFINE vi_codigo_retorno integer;
DEFINE vc_causa varchar(20);
DEFINE vi_anio_academico integer;
DEFINE vc_legajo varchar(15);

LET vc_causa = NULL;
LET vi_codigo_retorno = NULL;
LET vc_regular = NULL;
LET vi_anio_academico = NULL;
LET vc_legajo = "";
LET vc_alumno = NULL;

BEGIN

Select a.legajo, YEAR(TODAY) AS anio INTO vc_legajo, vi_anio_academico  From sga_alumnos a, sga_personas p	
	Where a.nro_inscripcion=p.nro_inscripcion
	and p.nro_documento=pnro_documento 
	group by a.legajo;


IF (vc_legajo <> "") THEN
	LET vc_alumno='S';
ELSE
	LET vc_alumno='N';
	LET vc_regular = 'X';
	RETURN vc_alumno, vc_regular ;
END IF;

EXECUTE PROCEDURE sp820_fhuc_reg5anios('FHUC', vc_legajo, vi_anio_academico) INTO  vi_codigo_retorno, vc_causa;

IF vi_codigo_retorno = '1' THEN

	LET vc_regular = 'R';

ELSE

	LET vc_regular = 'X';

END IF;

RETURN vc_alumno,vc_regular;

END;
END PROCEDURE;

-- **************************  Fin del Procedure web_serv_fhuc_5_anios **************************

REVOKE execute ON "dba".web_serv_fhuc_5_anios FROM public;
GRANT execute ON "dba".web_serv_fhuc_5_anios to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".web_serv_fhuc_5_anios to internet; -- Rol de usuario de Internet




