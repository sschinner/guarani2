CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_service_ui_datos_censales') THEN
		DROP PROCEDURE web_service_ui_datos_censales;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *************** COMIENZO DEL PROCEDURE web_service_ui_datos_censales ***************
-- ************************************************************************
-- SP Actualiza y/o inserta los datos censales de una persona
-- ************************************************************************
-- DROP PROCEDURE "dba".web_service_ui_datos_censales;

--select * from sga_personas where nro_inscripcion ='4121'

-- select * from u820_datos_cen_aux where nro_inscripcion ='4120'
      
-- execute procedure web_service_ui_datos_censales(54,0,'29349542'," SET estado_civil= '3' , e_mail='lj8898989898jas@gmail.com' ",'','','');

CREATE PROCEDURE "dba".web_service_ui_datos_censales(pPaisDocumento LIKE sga_personas.pais_documento,
	pTipoDocumento LIKE sga_personas.tipo_documento,
	pNroDocumento LIKE sga_personas.nro_documento,setSgaDatosCensales char(3000),setSgaDatosCensalesAux char(3000),setSga820DatosCensalesAux char(3000), setSgaPersonas char(3000))
	Returning INT, CHAR(4000);
-- Descripcion de Return:
-- INT:	0 - OK
--	-1 - Error
-- CHAR(4000): string con la descripcion del error
	
DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(100);
DEFINE vcUserError		varchar(100);
DEFINE iStatus			int;
DEFINE vcMsg			char(4000);
DEFINE iExiste_trab_alum	int;

DEFINE cust_qry CHAR(4000);
DEFINE l_cust_num INTEGER;
DEFINE vctabla_update varchar(255);
DEFINE  po_cd_act_sect          char(2);
DEFINE anro_inscripcion varchar(10);

  -- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info || ' en la sentancia ' || cust_qry   ;
      SET TRIGGERS FOR sga_datos_censales enabled;
      --ROLLBACK WORK;
      RETURN iStatus, vcMsg;
END EXCEPTION;
--------------------------------------------------

on exception in (-206)
       -- Tabla no existe continuo el proceso	
end exception with resume;
	DROP TABLE tmp_update_datos;

LET anro_inscripcion = '';
LET iStatus = 0;
LET vcMsg = 'OK, Datos Censales actualizados correctamente ';

-- Verifico que la persona exista.
SELECT nro_inscripcion INTO anro_inscripcion 
	FROM sga_personas 
	WHERE nro_documento = pNroDocumento
	AND tipo_documento = pTipoDocumento
	AND pais_documento = pPaisDocumento;

IF ( anro_inscripcion IS NULL ) THEN
	LET vcMsg = 'El Alumno  '  || pNroDocumento || '  es inexistente - Verifique';
	LET iStatus = -1;
	RETURN iStatus, vcMsg;
END IF;

IF(setSgaPersonas != '')THEN
	LET cust_qry = "UPDATE sga_personas " || setSgaPersonas || " WHERE nro_inscripcion = '" || anro_inscripcion || "' ";
	
	EXECUTE IMMEDIATE cust_qry ;
	
END IF;

IF(setSgaDatosCensales != '')THEN
	LET cust_qry = " UPDATE sga_datos_censales " || setSgaDatosCensales || " WHERE nro_inscripcion = '" || anro_inscripcion || "'  AND fecha_relevamiento = (Select max(fecha_relevamiento)  From sga_datos_censales Where nro_inscripcion = '" || anro_inscripcion || "' )";

	EXECUTE IMMEDIATE cust_qry ;
END IF;

IF(setSgaDatosCensalesAux != '')THEN	
	LET cust_qry = "UPDATE sga_datos_cen_aux " || setSgaDatosCensalesAux ||	" WHERE nro_inscripcion = '" || anro_inscripcion || "'" ||  " AND fecha_relevamiento = (Select max(fecha_relevamiento) From sga_datos_censales Where nro_inscripcion = '" || anro_inscripcion || "')";

	EXECUTE IMMEDIATE cust_qry ;
END IF;

IF(setSga820DatosCensalesAux != '')THEN
	LET cust_qry =	"UPDATE u820_datos_cen_aux " ||	setSga820DatosCensalesAux ||	" WHERE nro_inscripcion = '" || anro_inscripcion || "'" ||  " AND fecha_relevamiento = (Select max(fecha_relevamiento) From sga_datos_censales Where nro_inscripcion = '" || anro_inscripcion || "')";
	
	EXECUTE IMMEDIATE cust_qry ;
END IF;

RETURN iStatus, vcMsg;

END PROCEDURE;

-- *************** FIN DEL PROCEDURE "dba".web_ser_insc_asp ***************
revoke execute on "dba".web_service_ui_datos_censales from public;
grant execute on "dba".web_service_ui_datos_censales to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_service_ui_datos_censales to internet; -- Rol de usuario de Internet

