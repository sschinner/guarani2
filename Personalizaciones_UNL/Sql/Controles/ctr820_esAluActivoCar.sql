CREATE PROCEDURE verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR RETORNO

ON EXCEPTION 


END EXCEPTION WITH RESUME;

-- El control es sobre la persona

insert into par_implem_control (stored_procedure, parametros) values ("ctr820_alu_activo", "s,s,s,n");
insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (820050, "ctr820_alu_activo", "Controla ser alumno activo de la carrera.", "Controla ser alumno activo de la carrera.", null);
insert into par_cont_x_punto (punto_de_control, control) values (26, 820050);
execute procedure sp_confcont_cont (26, 820050);

update sga_conf_controles set activo = 'S'
where operacion = 'agcert01'
and control in ('820050'); 
	
END
END PROCEDURE;

EXECUTE PROCEDURE verifica_datos();
DROP PROCEDURE verifica_datos();


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_alu_activo') THEN
		DROP PROCEDURE ctr820_alu_activo;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.0.0
-- Procedure ctr820_alu_activo
-- 
-- Controla que un alumno esté activo en la Carrera correspondiente.
-- Verifica que la calidad del alumno sea 'A' - Activo
-- Se modifica para los certificados de HA y MA para que pueda ser solicitado por los alumnos que no esten activos o regulares
-- *****************************************************************************
-- DROP PROCEDURE ctr820_alu_activo;
CREATE PROCEDURE ctr820_alu_activo(
	 pUnidadAcademica  LIKE sga_alumnos.unidad_academica,
                                     pCarrera          LIKE sga_alumnos.carrera,
                                     pLegajo           LIKE sga_alumnos.legajo,
                                     pCertificado      LIKE sga_certificados.certificado

)
	RETURNING smallint, varchar(255);

	-- vars para la respuesta
	DEFINE iStatus             smallint;
	DEFINE vcMsg               varchar(255);
	DEFINE ls_calidad	   LIKE sga_alumnos.calidad;

	-- vars para el manejo de excepciones
	DEFINE sql_err             integer;
	DEFINE isam_err            integer;
	DEFINE error_info          varchar(76);

	-- vars locales
	DEFINE v_ua LIKE sga_alumnos.unidad_academica;
	DEFINE v_carrera LIKE sga_alumnos.carrera;
	DEFINE v_legajo LIKE sga_alumnos.legajo;  
	DEFINE v_plan LIKE sga_alumnos.plan;


	-- blk de excepciones
	ON EXCEPTION SET sql_err, isam_err, error_info                                        
		-- RAISE EXCEPTION  sql_err, isam_err, error_info;
		LET iStatus = -1 ;
		LET vcMsg = '800321,ctr820_alu_activo,' || sql_err || ' - '  || error_info ;
		RETURN iStatus, vcMsg ;
	END EXCEPTION;      

BEGIN
	-- Inicia las variables
	LET iStatus = 1 ;
	LET vcMsg = 'OK';

IF (pCertificado <> 100 and pCertificado <> 9 and  pCertificado <> 5) THEN

	-- Verifico si la Persona es Alumno Activo en la Carrera
	SELECT	Calidad
	INTO	ls_calidad
	FROM	sga_alumnos
	WHERE	unidad_academica = pUnidadAcademica
	AND	carrera = pCarrera
	AND	legajo = pLegajo;

	IF DBINFO("sqlca.sqlErrd2") <= 0 THEN
		LET iStatus		= -1 	;
		LET vcMsg =   '800200,(' || pCarrera || ') - (' || pLegajo || ')';
	ELSE

		IF ls_calidad <> 'A' THEN
			-- La Persona no es Alumno Activo en la Carrera.
			LET iStatus = -1 ;
			LET vcMsg = '800700';
		END IF;

	END IF;
END IF;

RETURN iStatus, vcMsg;

END;
END PROCEDURE;
-- ************************* Procedure ctr820_alu_activo ****************************
revoke execute on "dba".ctr820_alu_activo from public;
grant execute on "dba".ctr820_alu_activo to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_alu_activo to internet; -- Rol de usuario de Internet

