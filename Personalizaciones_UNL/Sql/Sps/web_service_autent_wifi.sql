CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_autent_wifi') THEN
		DROP PROCEDURE web_serv_autent_wifi;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Par�metros de WS: unidad academica; tipo documento; nro. documento; password guaran� en MD5; 
-- Criterios: se verifica que el tipo documento y nro. documento y clave corresponda a un usuario Alumno valido en guaran�; se verifican condiciones SUR1/SUR2.


CREATE PROCEDURE "dba".web_serv_autent_wifi(ptipo_documento integer, pnro_documento varchar(20), pclave  varchar(32))
RETURNING
integer, -- codigo retorno
varchar(255);   -- mensaje


DEFINE vi_codigo_ret integer;
DEFINE vcMsg varchar(255);   -- mensaje y parametros
DEFINE isam_err integer;
DEFINE vcPwdDefault 	LIKE aca_usuarios_ag.clave;


-- blk de excepciones
ON EXCEPTION SET vi_codigo_ret , isam_err, vcMsg
   RETURN  vi_codigo_ret , vcMsg;
END EXCEPTION;

BEGIN

LET vi_codigo_ret = 0;
LET vcMsg = 'OK';


-- ***************************************
-- Se consideran Egresados que tengan SUR2 hecho para el caso de reci�n recibidos
-- ***************************************
IF NOT EXISTS (SELECT '*'FROM sga_personas per
		join sga_carrera_aspira asp
			on per.nro_inscripcion = asp.nro_inscripcion
		join sga_periodo_insc perinsc
			on asp.periodo_inscripcio = perinsc.periodo_inscripcio 
			and asp.situacion_asp in ( 'IL', 'IC')
		join sga_alumnos alu
			on asp.nro_inscripcion = alu.nro_inscripcion
			and asp.carrera = alu.carrera
			and alu.regular = 'S'
			and alu.calidad IN ( 'A', 'E')
WHERE tipo_documento = ptipo_documento
	AND nro_documento = pnro_documento) THEN
		LET vcMsg = "La persona no esta registrada en ninguna carrera de la Facultad";
		LET vi_codigo_ret = -1;
		RETURN vi_codigo_ret, vcMsg ;
END IF;

-- ***************************************
-- Alumnos que hicieron el SUR 2 en el presente a�o
-- ***************************************
IF NOT EXISTS (SELECT '*' from sga_reinscripcion r 
	join sga_alumnos a
		on a.legajo = r.legajo 
		and a.carrera = r.carrera 

	join sga_personas p
		on p.nro_inscripcion = a.nro_inscripcion	  
where r.anio_academico = YEAR(today)
	and a.calidad in ('A', 'E') 
	and p.tipo_documento = ptipo_documento
	and p.nro_documento = pnro_documento) THEN

	-- ***************
	-- Ingresantes 
	-- ***************

	IF EXISTS (SELECT '*' from sga_periodo_insc pi
		join sga_carrera_aspira car 
			on pi.periodo_inscripcio = car.periodo_inscripcio

		join sga_personas p
			on p.nro_inscripcion = car.nro_inscripcion 	
	
	where pi.anio_academico = YEAR(today) 
		and car.situacion_asp in( 'IL', 'IC')
		and p.tipo_documento = ptipo_documento
		and p.nro_documento = pnro_documento) THEN

		LET vcMsg = "OK" ;
		LET vi_codigo_ret = 0;
		
	ELSE
		-- Verificado que es alumno, el mismo al no ser Ingresante, no ha hecho la Reinscripci�n Anual.
		LET vcMsg = "El alumno no ha realizado la Reinscripci�n Anual";
		LET vi_codigo_ret = -2;
		RETURN vi_codigo_ret, vcMsg ;
	END IF;			

END IF;

-- Esta comprobaci�n se realiza para el caso que por alg�n error no tenga generado el usuario
IF NOT EXISTS (SELECT '*' FROM aca_usuarios_ag ag
			join sga_personas per
				on ag.nro_inscripcion = per.nro_inscripcion 

			WHERE per.tipo_documento = ptipo_documento
				AND per.nro_documento = pnro_documento) THEN 
	
			LET vcMsg = "Usuario o Clave Incorrectos";
			LET vi_codigo_ret = -3;
ELSE
	SELECT clave Into vcMsg
		FROM aca_usuarios_ag ag
			join sga_personas per
				on ag.nro_inscripcion = per.nro_inscripcion 
			WHERE per.tipo_documento = ptipo_documento
				AND per.nro_documento = pnro_documento;
	-- Verificaci�n de clave propuesta trivial
	LET vcPwdDefault = (select lpad (nro_documento, 5)
		                  	from  sga_personas
				where sga_personas.nro_documento = pnro_documento
					and sga_personas.tipo_documento = ptipo_documento); 

	LET vcPwdDefault 	= sp_md5(vcPwdDefault);

	IF vcPwdDefault = pclave THEN
		-- LET vcMsg = "Clave Trivial - Debe resetear la clave en Guaran�";
		LET vi_codigo_ret = -4;
	END IF;
			
END IF;

RETURN vi_codigo_ret, vcMsg ;

END;

END PROCEDURE;

-- Casos de prueba
{


execute PROCEDURE "dba".web_serv_autent_wifi ( 0, 301719552 , 'clave'); -- No existe la persona NO OK
execute PROCEDURE "dba".web_serv_autent_wifi ( 0, 30171912 , 'clave'); -- Schinner NO OK - Falta Sur 2

execute PROCEDURE "dba".web_serv_autent_wifi ( 0, 34398709 , '3866d9acebec338bdea63aea924df2c3'); -- DOC Longhi OK Clave propuesta no es la trivial
execute PROCEDURE "dba".web_serv_autent_wifi ( 0, 34398709 , 'aa6a8423fe25c40bb4dcec8ccf33b0c1'); -- DOC Longhi OK  Clave propuesta es la trivial

execute PROCEDURE "dba".web_serv_autent_wifi ( 0, 32058518, '665c3e4f7a8520f4a4a5e98a2c4401b5'); -- ALU Lucero OK Clave propuesta no es la trivial
execute PROCEDURE "dba".web_serv_autent_wifi ( 0, 32058518, '242c1eebf6c9cd4523eb187d543a65b5'); -- ALU Lucero OK Clave propuesta es la trivial

execute PROCEDURE "dba".web_serv_autent_wifi ( 0, 36737352, '406373bf5f5b187bc4aaddff066d5282'); -- ALU OK Clave propuesta es la trivial


 }



-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_autent_wifi 
-- *****************************************************************************
revoke execute on "dba".web_serv_autent_wifi from public;
grant execute on "dba".web_serv_autent_wifi to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_autent_wifi to internet; -- Rol de usuario de Internet