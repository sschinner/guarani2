CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_alu_regular') THEN
		DROP PROCEDURE "dba".web_serv_alu_regular;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Procedure to dynamically constructs query `cust_qry' 
CREATE PROCEDURE "dba".web_serv_alu_regular(papellido varchar(30), pnombres varchar(30), ptipo_documento integer, pnro_documento decimal(15,0), psexo  char(1), pfecha varchar(10))
RETURNING 
--	CHAR(6000); -- prueba de return de cust_qry
	integer, -- Código de respuesta
	VARCHAR(60), -- apellido
	VARCHAR(60), -- nombre
	CHAR(400); -- Observacion

DEFINE cust_qry2 CHAR(256);

DEFINE vc_database varchar(250);

DEFINE vc_regular char(1);
DEFINE vc_apellido VARCHAR(255);
DEFINE vc_nombres VARCHAR(255);

DEFINE vi_codigo_ret integer;
DEFINE vc_apellido_ret VARCHAR(255);
DEFINE vc_nombres_ret VARCHAR(255);

DEFINE vc_ua varchar(5);

DEFINE vc_strpapellido VARCHAR(3);
DEFINE vc_strpnombres VARCHAR(3);

DEFINE vc_strapellido VARCHAR(3);
DEFINE vc_strnombres VARCHAR(3);
DEFINE vc_observacion CHAR(400);


LET vc_regular = NULL;
LET vi_codigo_ret = 999;

LET vc_apellido = NULL;
LET vc_nombres = NULL;
LET vc_apellido_ret = NULL;
LET vc_nombres_ret = NULL;
LET vc_ua = NULL;
LET vc_observacion = NULL;


--LET vc_strpapellido = SUBSTRING(UPPER(papellido) FROM 1 FOR 3);
--LET vc_strpnombres = SUBSTRING(UPPER(pnombres) FROM 1 FOR 3);

-- Mayusculas
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'Á', 'A');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'É', 'E');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'Í', 'I');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'Ó', 'O');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'Ú', 'U');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'Ä', 'A');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'Ë', 'E');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'Ï', 'I');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'Ö', 'O');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'Ü', 'U');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'À', 'A');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'È', 'E');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'Ì', 'I');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'Ò', 'O');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'Ù', 'U');
-- Minusculas
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'á', 'A');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'é', 'E');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'í', 'I');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'ó', 'O');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'ú', 'U');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'ä', 'A');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'ë', 'E');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'ï', 'I');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'ö', 'O');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'ü', 'U');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'à', 'A');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'è', 'E');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'ì', 'I');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'ò', 'O');
--LET vc_strpapellido = REPLACE (vc_strpapellido, 'ù', 'U');

--LET vc_strpapellido = REPLACE (vc_strpapellido, 'ñ', 'Ñ');
--LET vc_strpapellido = REPLACE (vc_strpapellido , "'", '-');

-- Mayusculas
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'Á', 'A');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'É', 'E');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'Í', 'I');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'Ó', 'O');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'Ú', 'U');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'Ä', 'A');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'Ë', 'E');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'Ï', 'I');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'Ö', 'O');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'Ü', 'U');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'À', 'A');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'È', 'E');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'Ì', 'I');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'Ò', 'O');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'Ù', 'U');
-- Minusculas
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'á', 'A');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'é', 'E');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'Í', 'I');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'ó', 'O');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'ú', 'U');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'ä', 'A');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'ë', 'E');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'ï', 'I');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'ö', 'O');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'ü', 'U');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'à', 'A');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'è', 'E');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'ì', 'I');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'ò', 'O');
--LET vc_strpnombres = REPLACE (vc_strpnombres, 'ù', 'U');

--LET vc_strpnombres = REPLACE (vc_strpnombres, 'ñ', 'Ñ');
--LET vc_strpnombres = REPLACE (vc_strpnombres  , "'", '-');

EXECUTE PROCEDURE "dba".sp820_WebSerAluReg(ptipo_documento, pnro_documento, psexo, pfecha) INTO vc_ua, vc_regular, vc_apellido, vc_nombres;

	LET vc_apellido = TRIM(vc_apellido);
	LET vc_nombres = TRIM(vc_nombres);

	IF (vc_regular = 'X') THEN
		-- No existe la persona
		LET vi_codigo_ret = 5;
		LET vc_observacion = "No existe la persona según tipo, numero de documento y género";				
	ELIF (vc_regular = 'D') THEN
		-- La persona no ha autorizado la difusión de sus datos
		LET vi_codigo_ret = 0;
		LET vc_observacion = "El alumno no ha autorizado la difusión de su estado de Regularidad";

	ELIF (vc_regular = 'P') THEN
		-- La persona es aspirante sin legajo
		LET vi_codigo_ret = 0;
		LET vc_observacion = "La persona es Aspirate sin legajo generado";
	ELSE

		-- Si se encontro el tipo y nro. de documento
		--LET vc_strapellido =  SUBSTRING(UPPER(vc_apellido) FROM 1 FOR 3);
		--LET vc_strnombres =  SUBSTRING(UPPER(vc_nombres) FROM 1 FOR 3);

		--LET vc_strapellido = REPLACE (vc_strapellido , 'Á', 'A');
		--LET vc_strapellido = REPLACE (vc_strapellido , 'É', 'E');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'Í', 'I');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'Ó', 'O');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'Ú', 'U');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'Ä', 'A');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'Ë', 'E');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'Ï', 'I');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'Ö', 'O');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'Ü', 'U');
--
--
--		LET vc_strapellido = REPLACE (vc_strapellido , 'À', 'A');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'È', 'E');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'Ì', 'I');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'Ò', 'O');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'Ù', 'U');
--
--		LET vc_strapellido = REPLACE (vc_strapellido , 'á', 'A');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'é', 'E');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'í', 'I');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'ó', 'O');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'ú', 'U');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'ä', 'A');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'ë', 'E');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'ï', 'I');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'ö', 'O');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'ü', 'U');
--

--		LET vc_strapellido = REPLACE (vc_strapellido , 'à', 'A');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'è', 'E');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'ì', 'I');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'ò', 'O');
--		LET vc_strapellido = REPLACE (vc_strapellido , 'ù', 'U');
--
--		LET vc_strapellido = REPLACE (vc_strapellido , 'ñ', 'Ñ');
--		LET vc_strapellido = REPLACE (vc_strapellido , "'", '-');

--		LET vc_strnombres = REPLACE (vc_strnombres  , 'Á', 'A');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'É', 'E');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'Í', 'I');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'Ó', 'O');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'Ú', 'U');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'Ä', 'A');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'Ë', 'E');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'Ï', 'I');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'Ö', 'O');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'Ü', 'U');
--
--
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'À', 'A');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'È', 'E');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'Ì', 'I');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'Ò', 'O');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'Ù', 'U');
--
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'á', 'A');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'é', 'E');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'í', 'I');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'ó', 'O');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'ú', 'U');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'ä', 'A');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'ë', 'E');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'ï', 'I');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'ö', 'O');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'ü', 'U');
--
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'à', 'A');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'è', 'E');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'ì', 'I');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'ò', 'O');
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'ù', 'U');
--
--		LET vc_strnombres = REPLACE (vc_strnombres  , 'ñ', 'Ñ');
--		LET vc_strnombres = REPLACE (vc_strnombres  , "'", '-');
--

		IF vc_regular = 'S' THEN
			-- Verificar condiciones a y b
			--IF vc_strapellido = vc_strpapellido AND vc_strnombres = vc_strpnombres THEN
				   LET vi_codigo_ret = 6;
			--ELSE 
			--	   LET vi_codigo_ret = 7;
			--	   LET vc_observacion = "Diferencia en Apellido y/o Nombres";
			--END IF;

		ELSE
			--IF vc_strapellido = vc_strpapellido AND vc_strnombres = vc_strpnombres THEN
				  LET vi_codigo_ret = 8;
				  LET vc_observacion = "Debe verificar la Reinscripción Anual y/o Estado del Alumno";
			--ELSE 
			--	  LET vi_codigo_ret = 9;
			--	  LET vc_observacion = "Debe verificar la Reinscripcion Anual y/o Estado del Alumno";
			--END IF;
		END IF;
		
	END IF

INSERT INTO u820_ped_bol_est 
(APELLIDO_PARAM, NOMBRES_PARAM, TIPO_DOCUMENTO_PARAM,	NRO_DOCUMENTO_PARAM, SEXO_PARAM, FECHA_PARAM, 	RETORNO_BD, APELLIDO_BD, NOMBRES_BD, OBSERVACION_BD, FECHA_RELEVAMIENTO)
VALUES (papellido, pnombres, ptipo_documento, pnro_documento, psexo, pfecha, vi_codigo_ret, vc_apellido, vc_nombres, vc_observacion, Current year to Second);

RETURN vi_codigo_ret, vc_apellido, vc_nombres, vc_observacion WITH RESUME;

END PROCEDURE;

-- *****************************************************************************
revoke execute on "dba".web_serv_alu_regular from public;
grant execute on "dba".web_serv_alu_regular to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_alu_regular to internet; -- Rol de usuario de Internet
