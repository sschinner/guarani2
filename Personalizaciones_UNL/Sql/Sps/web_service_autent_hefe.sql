CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_alu_autent_hefe') THEN
		DROP PROCEDURE web_serv_alu_autent_hefe;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Par�metros de WS: usuario guaran�; password guaran�; 
-- Criterios: se verifica que el usuario y clave corresponda a un usuario ALUMNO; se verifica que tenga legajo generado (condicional o definitivo)


CREATE PROCEDURE "dba".web_serv_alu_autent_hefe(pusuario varchar(20), pclave  varchar(20))
RETURNING integer; -- C�digo de respuesta


DEFINE vi_codigo_ret integer;
DEFINE vc_clave_md5 varchar(32);


LET vi_codigo_ret = 0;
LET vc_clave_md5 = NULL;

LET vc_clave_md5 = sp_md5(pclave);

IF EXISTS (SELECT '*' FROM aca_usuarios_ag ag
			join sga_personas per
				on ag.nro_inscripcion = per.nro_inscripcion 
			join sga_carrera_aspira asp
				on per.nro_inscripcion = asp.nro_inscripcion
			join sga_alumnos alu
				on asp.nro_inscripcion = alu.nro_inscripcion
				and asp.carrera = alu.carrera

			WHERE  asp.situacion_asp in ('IL', 'IC')
				AND ag.tipo_usuario = 'ALU'
				AND ag.identificacion = pusuario
				AND ag.clave = vc_clave_md5 )
		THEN 
	
			LET vi_codigo_ret = 1;
			
		ELSE
			LET vi_codigo_ret = 0;
		END IF;



RETURN vi_codigo_ret;

END PROCEDURE;

-- Casos de prueba
{
select * from aca_usuarios_ag tipo_usuario = 'DOC';
select * from sga_carrera_aspira where situacion_asp = 'AC';
select * from sga_personas where nro_inscripcion = 'FICH-7193';

Casos:
-- Autenticado
EXECUTE PROCEDURE "dba".web_serv_alu_autent_hefe("30339240", "12345"); --1
-- No autenticado por clave
EXECUTE PROCEDURE "dba".web_serv_alu_autent_hefe("30339240", "11111"); --0
-- No autenticado por identificacion
EXECUTE PROCEDURE "dba".web_serv_alu_autent_hefe("30339250", "12345"); --0
-- No autenticado por tipo de usuario <> "ALUMNO"
EXECUTE PROCEDURE "dba".web_serv_alu_autent_hefe("DOC13328324", "12345"); --0
-- No autenticado por situacion de legajo
EXECUTE PROCEDURE "dba".web_serv_alu_autent_hefe("37685688", "12345"); --0

}

-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_alu_autent_hefe 
-- *****************************************************************************
revoke execute on "dba".web_serv_alu_autent_hefe from public;
grant execute on "dba".web_serv_alu_autent_hefe to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_alu_autent_hefe to internet; -- Rol de usuario de Internet