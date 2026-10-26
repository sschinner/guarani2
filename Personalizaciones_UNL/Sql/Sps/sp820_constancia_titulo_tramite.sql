CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_constancia_titulo_tramite') THEN
		DROP PROCEDURE sp820_constancia_titulo_tramite;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: hash;

CREATE PROCEDURE "dba".sp820_constancia_titulo_tramite(p_solicitud int)
RETURNING 
	int,
	varchar(255),
	varchar(255),
	varchar(255),	
	varchar(255), 	
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255),
	varchar(255);

DEFINE vc_apellido_y_nombre varchar(255);
DEFINE vc_documento_principal varchar(255);
DEFINE vc_fecha_nacimiento_alumno varchar(255);
DEFINE vc_certificado_nombre varchar(255);
DEFINE vc_nro_expediente varchar(255);
DEFINE vc_fecha_egreso_alumno varchar(255);
DEFINE vc_localidad_nombre varchar(255);
DEFINE vc_provincia_nombre varchar(255);
DEFINE vc_pais_nombre varchar(255);
DEFINE vc_nombre_institucion varchar(255);
DEFINE vc_ra_nombre varchar(255);
DEFINE vc_ra_direccion varchar(255);
DEFINE vc_ra_cp varchar(255);
DEFINE vc_ra_telefono varchar(255);
DEFINE vc_ra_email varchar(255);

DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(80);
DEFINE vcUserError		varchar(10);
DEFINE iStatus			varchar(10);
DEFINE vcMsg			varchar(100);

-- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        
      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info;
     RETURN iStatus, vc_apellido_y_nombre, vc_documento_principal, vc_fecha_nacimiento_alumno, 
	vc_certificado_nombre, vc_nro_expediente, vc_fecha_egreso_alumno, vc_localidad_nombre, 
	vc_provincia_nombre, vc_pais_nombre, vc_nombre_institucion, vc_ra_nombre, 
	vc_ra_direccion, vc_ra_cp, vc_ra_telefono, vc_ra_email;
END EXCEPTION;

BEGIN

LET iStatus = 0;
LET vc_apellido_y_nombre = null;
LET vc_documento_principal = null;
LET vc_fecha_nacimiento_alumno = null;
LET vc_certificado_nombre = null;
LET vc_nro_expediente = null;
LET vc_fecha_egreso_alumno = null;
LET vc_localidad_nombre = null;
LET vc_provincia_nombre = null;
LET vc_pais_nombre = null;
LET vc_nombre_institucion = null;
LET vc_ra_nombre = null;
LET vc_ra_direccion = null;
LET vc_ra_cp = null;
LET vc_ra_telefono = null;
LET vc_ra_email = null;

SELECT
	per.apellido || ' ' || per.nombres as apellido_y_nombre
	, mtd.desc_abreviada || ' ' || per.nro_documento as documento_principal
	, to_char(per.fecha_nacimiento,'%d/%m/%Y') as fecha_nacimiento_alumno
	, CASE per.sexo WHEN 1 THEN tit.nombre WHEN 2 THEN tit.nombre_femenino END AS certificado_nombre
	, upc.expediente AS nro_expediente
	, to_char(sto.fecha_egreso, '%d/%m/%Y') as fecha_egreso_alumno
   	, mul.nombre as localidad_nombre
	, mpr.nombre as provincia_nombre
	, mpa.nombre as pais_nombre
	, sua.nombre_universidad as nombre_institucion
	, sua.nombre as ra_nombre
	, sua.calle || ' ' || sua.numero as ra_direccion
	, sua.codigo_postal as ra_cp
	, sua.te as ra_telefono
	, sua.e_mail as ra_email
	INTO vc_apellido_y_nombre, vc_documento_principal, vc_fecha_nacimiento_alumno, 
	vc_certificado_nombre, vc_nro_expediente, vc_fecha_egreso_alumno, vc_localidad_nombre, 
	vc_provincia_nombre, vc_pais_nombre, vc_nombre_institucion, vc_ra_nombre, 
	vc_ra_direccion, vc_ra_cp, vc_ra_telefono, vc_ra_email
	FROM sga_certif_pedidos scp
	JOIN  sga_personas per ON per.nro_inscripcion = scp.nro_inscripcion
	JOIN mdp_tipo_documento mtd ON mtd.tipo_documento = per.tipo_documento
	JOIN u820_pedidos_certif_diploma upcd ON upcd.id_certif_pedido = scp.certif_pedido
	LEFT JOIN sga_titulos_otorg sto ON sto.nro_inscripcion = scp.nro_inscripcion AND sto.carrera = upcd.carrera AND sto.titulo = upcd.titulo
	JOIN sga_titulos tit ON tit.titulo = upcd.titulo
	LEFT JOIN u820_pedidos_certif upc ON upc.id_certif_pedido = scp.certif_pedido
	JOIN sga_unidades_acad sua ON sua.unidad_academica = per.unidad_academica
	LEFT JOIN mug_localidades mul ON mul.localidad = sua.localidad
	LEFT JOIN mug_dptos_partidos mdp ON mdp.dpto_partido = mul.dpto_partido
	LEFT JOIN mug_provincias mpr ON mpr.provincia = mdp.provincia
	LEFT JOIN mug_paises mpa ON mpa.pais = mpr.pais
	WHERE scp.certif_pedido = p_solicitud;


RETURN iStatus, vc_apellido_y_nombre, vc_documento_principal, vc_fecha_nacimiento_alumno, 
	vc_certificado_nombre, vc_nro_expediente, vc_fecha_egreso_alumno, vc_localidad_nombre, 
	vc_provincia_nombre, vc_pais_nombre, vc_nombre_institucion, vc_ra_nombre, 
	vc_ra_direccion, vc_ra_cp, vc_ra_telefono, vc_ra_email;

END;
END PROCEDURE;

-- EXECUTE PROCEDURE "dba".sp820_constancia_titulo_tramite(); --1
-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_constancia_titulo_tramite 
-- *****************************************************************************
revoke execute on "dba".sp820_constancia_titulo_tramite from public;
grant execute on "dba".sp820_constancia_titulo_tramite to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_constancia_titulo_tramite to internet; -- Rol de usuario de Internet


