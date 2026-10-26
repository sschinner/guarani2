CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sincroniza_datos_censales_alumno') THEN
		DROP PROCEDURE "dba".sincroniza_datos_censales_alumno;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();





--execute procedure "dba".sincroniza_datos_censales_alumno(54,0,'29349542'," SET estado_civil= '2' , e_mail='lscsdcssd@gmail.com' ",'','','');

CREATE PROCEDURE "dba".sincroniza_datos_censales_alumno (pPaisDocumento LIKE sga_personas.pais_documento,
	pTipoDocumento LIKE sga_personas.tipo_documento,
	pNroDocumento LIKE sga_personas.nro_documento,setSgaDatosCensales char(3000),setSgaDatosCensalesAux char(3000),setSga820DatosCensalesAux char(3000), setSgaPersonas char(3000))
	Returning INT, CHAR(15000);


DEFINE vc_database varchar(250);
DEFINE iStatus			int;
DEFINE vcMsg			char(15000);
DEFINE cust_qry  	char(15000);

DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(100);
DEFINE vcUserError		varchar(100);
DEFINE iExiste_trab_alum	int;

 -- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info || ' en la sentancia  ' || vc_database || '   ' || cust_qry   ;
      SET TRIGGERS FOR sga_datos_censales enabled;
      --ROLLBACK WORK;
      RETURN iStatus, vcMsg;
END EXCEPTION;


LET iStatus = NULL;
LET  vcMsg = NULL;

  -- Loop de base de datos

FOREACH Select name INTO vc_database
	from sysmaster:sysdatabases where name not in ('sysmaster', 'sysutils', 'sysuser', 'sysadmin', 
		'alumnado_lm', 'alumnado_eis','alumnado_fcv', 'alumnado_fca',
		'alumnado_eua', 'alumnado_fiq','alumnado_euaa','alumnado_fhuc', 
		'alumnado_fbcb', 'alumnado_ess', 'alumnado_fich', 
		'alumnado_fadu',
		'alumnado_fce',
		'alumnado_fcjs',
		'alumnado_fcm',
		'alumnado_ism',
		'posgrado_fadu',
		'cemed_secgral',
		'convenios_fcjs',
		'escuela_fcjs',
		'cemed_extension') order by name
	
LET cust_qry = NULL;
LET vc_database = trim(vc_database);

SET ROLE guarani;

		LET cust_qry = 'execute procedure  ' || vc_database || ':dba.web_service_ui_datos_censales("' || pPaisDocumento || '", "' || pTipoDocumento || '", "' || pNroDocumento  || '", "' || setSgaDatosCensales || '", "' || setSgaDatosCensalesAux || '", "' || setSga820DatosCensalesAux|| '", "' || setSgaPersonas || '" ) ;' ;


PREPARE stmt_id FROM cust_qry;

	-- Declare the cursor for the prepared "statement_id"
	-- get the cursor handle "cust_cur"

	DECLARE cust_cur cursor FOR stmt_id;

           -- Open the declared cursor using handle "cust_cur"
           -- Supply the first_name as an input. This will be
           -- substituted in the place of "?" in the query

	   OPEN cust_cur;

	   WHILE (1 = 1)

                -- Fetch a row from the cursor "cust_cur" and store
                -- the returned column values to the SPL variables

		FETCH cust_cur INTO iStatus, vcMsg; 

              		IF (SQLCODE != 100) THEN
			-- RETURN vc_ua, vc_apellido, vc_nombres, vc_dni, vc_carrera_nombre, vc_tipo WITH RESUME;
			RETURN iStatus, vcMsg WITH RESUME;
		ELSE
                		   -- break the while loop
		  	 EXIT;
		END IF

	   END WHILE

           -- Close the cursor "cust_cur"

	   CLOSE cust_cur;

           -- Free the resources allocated for cursor "cust_cur"

           FREE cust_cur ;

           -- Free the resources allocated for statement "statement_id"

           FREE stmt_id ;

				

END FOREACH;

END PROCEDURE;




grant execute on "dba".sincroniza_datos_censales_alumno to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sincroniza_datos_censales_alumno to internet; -- Rol de usuario de Internet
grant execute on "dba".sincroniza_datos_censales_alumno to public; -- Rol de usuario de Internet

grant execute on "dba".web_service_ui_datos_censales to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_service_ui_datos_censales to internet; -- Rol de usuario de Internet
grant execute on "dba".web_service_ui_datos_censales to public; -- Rol de usuario de Internet

