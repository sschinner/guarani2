CREATE PROCEDURE "dba".verifica_objeto()

BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_alu_clave') THEN
		DROP PROCEDURE web_serv_alu_clave;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();

DROP PROCEDURE "dba".verifica_objeto();

-- Par�metros de WS: usuario guaran�; password guaran�; 

-- Criterios: obtiene la clave e inscripcion de un determinado alumno de la unidad academica


CREATE PROCEDURE "dba".web_serv_alu_clave(pusuario varchar(20))

RETURNING integer,
varchar(255),
varchar (15);

DEFINE vc_clave varchar(255);
DEFINE vc_inscripcion varchar(255);
DEFINE vi_codigo integer;

LET vc_clave = NULL;
LET vc_inscripcion = NULL;
LET vi_codigo = 0;

SELECT	clave, nro_inscripcion INTO vc_clave, vc_inscripcion 
                FROM	aca_usuarios_ag 
                WHERE	aca_usuarios_ag.identificacion= pusuario;


IF (vc_clave = 'NULL') THEN 
	LET vi_codigo = 0;
ELSE
	LET vi_codigo = 1;
END IF;
RETURN vi_codigo, vc_clave, vc_inscripcion ;

END PROCEDURE;
-- Casos de prueba

{

select * from aca_usuarios_ag tipo_usuario = 'DOC';

select * from sga_carrera_aspira where situacion_asp = 'AC';

select * from sga_personas where nro_inscripcion = 'FICH-7193';



Casos:

-- Autenticado

EXECUTE PROCEDURE "dba".web_serv_alu_clave("2934952"); --1



}


-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_alu_clave 
-- *****************************************************************************
revoke execute on "dba".web_serv_alu_clave from public;
grant execute on "dba".web_serv_alu_clave to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_alu_clave to internet; -- Rol de usuario de Internet