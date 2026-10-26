
CREATE PROCEDURE "dba".verifica_objeto()

BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_esta_inscripto') THEN
		DROP PROCEDURE web_serv_esta_inscripto ;
	END IF;		
END

END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de Sps: pcarrera varchar(8), ppais_doc integer, ptipo_doc integer, pnro_doc 
-- Objetivo: determinar si una persona se puede inscribir a una determinada carrera
-- EXECUTE PROCEDURE web_serv_esta_inscripto ('0302',54,0,'39033218');

CREATE PROCEDURE "dba".web_serv_esta_inscripto (pcarrera varchar(8), ppais_doc integer, ptipo_doc integer, pnro_doc varchar(15))
RETURNING integer, --0)  1(es alumno) o 2 (no es alumno)
	varchar (250); --1)	Mensaje


DEFINE vi_esAlumno integer;
DEFINE vc_resultado varchar (20);
DEFINE vc_mensaje varchar (250);
DEFINE vc_situacion varchar (5);
DEFINE vc_anio integer;

-- Variables para el manejo de excepciones
DEFINE sql_err 		integer;
DEFINE  isam_err		integer;
DEFINE error_Info          varchar(76);

-- Si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vc_mensaje = 'Error de procedimiento.';
      LET vi_esAlumno = 4; 
      LET vc_mensaje =  vc_mensaje || ', ' || sql_err || ' - ' || error_Info;
      SET TRIGGERS FOR sga_datos_censales enabled;
      
     RETURN vi_esAlumno,vc_mensaje ;
END EXCEPTION;


BEGIN

LET vi_esAlumno = 2;
LET vc_resultado = '0';
LET vc_mensaje = '';
LET vc_anio = NULL; 
LET vc_situacion = '';



SELECT p.nro_documento, s.descripcion,s.situacion_asp ,pi.anio_academico INTO vc_resultado, vc_mensaje , vc_situacion , vc_anio FROM sga_carrera_aspira c, sga_personas p, sga_situacion_asp  s, sga_periodo_insc pi
where p.nro_documento=pnro_doc
and c.carrera = pcarrera
and p.pais_documento=ppais_doc
and p.tipo_documento=ptipo_doc 
and p.nro_inscripcion = c.nro_inscripcion
and c.periodo_inscripcio = pi.periodo_inscripcio
and c.situacion_asp in ('IL','AC','IC')
and s.situacion_asp = c.situacion_asp;


IF vc_resultado = pnro_doc  Then
	IF (vc_situacion = 'IL'  OR vc_situacion = 'IC') THEN
 		LET vi_esAlumno = -1;
		LET vc_mensaje = vc_mensaje || " - Periodo de inscripción " || vc_anio ;
	ELIF  vc_situacion = 'AC' THEN
		LET vi_esAlumno = -2;
		LET vc_mensaje = vc_mensaje || " - Periodo de inscripción " || vc_anio ;
	END IF;
ELSE
	LET vi_esAlumno = 0;
	LET vc_mensaje = 'La persona no se encuentra inscripta en la carrera';
END IF;

RETURN vi_esAlumno,vc_mensaje ;



END;
END PROCEDURE;
-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_esta_inscripto 
-- *****************************************************************************
revoke execute on "dba".web_serv_esta_inscripto from public;
grant execute on "dba".web_serv_esta_inscripto to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_esta_inscripto to internet; -- Rol de usuario de Internet

