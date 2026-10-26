CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_carga_datos_principales') THEN
		DROP PROCEDURE sp820_carga_datos_principales;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP PROCEDURE "dba".sp820_carga_datos_principales;
CREATE PROCEDURE "dba".sp820_carga_datos_principales(
				pUA 		LIKE sga_unidades_acad.unidad_academica,
				pLegajo		LIKE sga_alumnos.legajo,
				pCarrera	LIKE sga_alumnos.carrera,
				pPlan		LIKE sga_alumnos.plan
				)

RETURNING
		varchar(30),	-- Apellido
		varchar(30),	-- Nombres
		varchar(50),	-- Email
		integer,		-- Tipo Documento
		varchar(15),	-- Nro. Documento
		char(1),		-- Sexo
		varchar(10),	-- Fecha de Nacimiento
		varchar(128),	-- Clave de Autogestion
		varchar(255),	-- Nombre del Titulo
		varchar(255),	-- Nombre del Titulo Femenino
		int,			-- Código del Titulo
		varchar(5),	-- Unidad Academica
		int,			-- Año de Egreso
		varchar(10),	-- Fecha de Egreso
		varchar(5);	-- Responsable Académica Kolla		

DEFINE vApellido 	varchar(30);
DEFINE vNombres 	varchar(30);
DEFINE vEmail 		varchar(50);
DEFINE vTipoDoc 	integer;
DEFINE vNroDoc 		varchar(15);
DEFINE vNroInsc		varchar(15);
DEFINE vSexo 		char(1);
DEFINE vFecha 		date;
DEFINE vClave		varchar(128);
DEFINE vTitulo		varchar(5);
DEFINE vTituloNom	varchar(255);
DEFINE vTituloFem	varchar(255);
DEFINE vTituloCod	int;
DEFINE vUA			varchar(5);
DEFINE vUAKolla			varchar(5);
DEFINE vAnioEgreso	int;
DEFINE vFechaEgerso	date;


-----  VARS PARA EL MANEJO DE EXCEPCIONES
DEFINE sql_err	 	integer;
DEFINE isam_err 	integer;
DEFINE error_info	varchar(76);

ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;     

BEGIN

	LET vApellido		= null;
	LET vNombres		= null;
	LET vEmail			= null;
	LET vTipoDoc		= null;
	LET vNroDoc			= null;
	LET vSexo			= null;
	LET vFecha			= null;
	LET vClave			= null;
	LET vTitulo			= null;
	LET vTituloNom			= null;
	LET vTituloFem		= null;
	LET vTituloCod		= null;
	LET vUA				= pUA;
	LET vUAKolla				= null;
	LET vAnioEgreso		= null;
	LET vFechaEgerso	= null;
	
	-- Obtengo datos principales de la persona
	SELECT per.apellido, per.nombres, dc1.e_mail, per.tipo_documento, 
			per.nro_documento, per.sexo, per.fecha_nacimiento, per.nro_inscripcion
		INTO vApellido, vNombres, vEmail, vTipoDoc, 
			vNroDoc, vSexo, vFecha, vNroInsc
		FROM sga_personas per, sga_datos_censales dc1, sga_alumnos alu
		WHERE alu.unidad_academica = pUA
		AND alu.legajo = pLegajo
		AND alu.carrera = pCarrera
		AND alu.plan = pPlan
		AND alu.nro_inscripcion = per.nro_inscripcion
		AND alu.nro_inscripcion = dc1.nro_inscripcion
		AND dc1.fecha_relevamiento = (SELECT max(dc2.fecha_relevamiento)
										FROM sga_datos_censales dc2
										WHERE dc2.nro_inscripcion = dc1.nro_inscripcion);
	
	-- Obtengo la clave de autogestion para ingresarla a Kolla
	SELECT clave
		INTO vClave
		FROM aca_usuarios_ag
		WHERE identificacion = vNroDoc;
		
	-- Obtengo los datos referidos al titulo de egreso
	-- SELECT titulo, nombre, nombre_femenino, titulo_araucano
	-- 	INTO vTitulo, vTituloNom, vTituloFem, vTituloCod
	--	FROM sga_titulos
	--	WHERE titulo IN (SELECT titulo
	--				FROM sga_titulos_plan
	--				WHERE carrera = pCarrera
	--				AND plan = pPlan)
	--	AND nivel = 'GRADO';
	SELECT titulo, nombre, nombre_femenino, titulo_araucano
	 	INTO vTitulo, vTituloNom, vTituloFem, vTituloCod
		FROM sga_titulos
		WHERE titulo IN (SELECT titulo
					FROM sga_titulos_otorg
					WHERE carrera = pCarrera
					AND plan = pPlan
					AND legajo = pLegajo)
		AND nivel in ('GRADO','INTERMEDIO');--PARA FHUC, FIQ y FCJS HAY QUE QUITAR INTERMEDIO YA QUE EL PROCEDIMIENTO --DEVUELVE DOS FILAS EN LUGAR DE UNA


	-- Obtengo las fecha de egreso
	SELECT tit.fecha_egreso, year(tit.fecha_egreso), va.valor_inicial
		INTO vFechaEgerso, vAnioEgreso, vUAKolla
		FROM sga_titulos_otorg tit
			join u820_valor_inicial_sistema va
				on tit.unidad_academica = va.unidad_academica
			join sga_titulos titulo
				on titulo.unidad_academica  = tit.unidad_academica
				AND titulo.titulo  = tit.titulo
				AND titulo.nivel in ('GRADO','INTERMEDIO')
		WHERE tit.legajo = pLegajo
		AND tit.carrera = pCarrera
		AND tit.plan = pPlan
		AND tit.titulo = vTitulo
		AND va.campo = 'unidad_academica'
		AND va.sistema = 'Kolla';

	RETURN vApellido, vNombres, vEmail, vTipoDoc, vNroDoc, vSexo, TO_CHAR(vFecha,'%d/%m/%Y'),
			vClave, vTituloNom, vTituloFem, vTituloCod, vUA, vAnioEgreso, TO_CHAR(vFechaEgerso,'%d/%m/%Y'), vUAKolla;

END;
END PROCEDURE;
-- EXECUTE PROCEDURE "dba".sp820_carga_datos_principales('FCJS', '33078103-4', '1', '2000');

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_carga_datos_principales
-- *****************************************************************************
revoke execute on "dba".sp820_carga_datos_principales from public;
grant execute on "dba".sp820_carga_datos_principales to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_carga_datos_principales to internet; -- Rol de usuario de Internet