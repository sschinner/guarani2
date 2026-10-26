-- *******************************************************************************
-- Controla si la persona tiene los datos actualizados para solicitar certificados pagos de MA y HA.
-- *******************************************************************************
CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_val_cert_p2') THEN
		DROP PROCEDURE ctr820_val_cert_p2;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();

DROP PROCEDURE verifica_objeto();
-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.9.2
--
-- Procedure ctr820_val_cert_p2
-- U820
-- Controla que la persona tenga datos actualizados para solicitar certificados pagos.
-- **************************************************************************
-- drop procedure dba.ctr820_val_cert_p2;
CREATE PROCEDURE dba.ctr820_val_cert_p2( pCertifPedido  LIKE sga_certif_pedidos.certif_pedido)

RETURNING  smallint, 		-- status
           varchar(255);	-- <mensaje, parametros>


-- vars para la respuesta
DEFINE iStatus   smallint;       -- status
DEFINE vcMsg     varchar(255);   -- mensaje y parametros

-- vars para el manejo de excepciones
DEFINE sql_err      integer;
DEFINE isam_err     integer;
DEFINE error_info   varchar(76);
DEFINE vcUserError  varchar(10);

DEFINE vc_NroInscripcion   varchar(10);
DEFINE vc_UnidadAcademica   varchar(10);
DEFINE vc_mail  varchar(50);
DEFINE vc_recibe_mail  char(1);

DEFINE vcTituloSuperior varchar(255);
DEFINE vcTituloSecExt char(1);
DEFINE vcDescripcionTitSec varchar(255); 
DEFINE viTipoIngreso integer; 
DEFINE vcResolIngreso varchar(15); 
DEFINE vcResolucionNro varchar(15);
DEFINE vcPlanVersion varchar(5); 
DEFINE dResolucionFecha date;
DEFINE vc_Carrera varchar(255);
DEFINE vcDescripcionCarrera varchar(255);  
DEFINE vcLegajo varchar(15);
DEFINE vcPlan varchar(5);
DEFINE vcTipoTitulo char(1);
DEFINE vcTipoCarrera char(1);
DEFINE vcNroResConeau varchar(15);
DEFINE vcTitulo varchar(5);

   -- bloque de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      LET iStatus = -1 ;
      LET vcMsg = '800321,' || 'ctr820_val_cert_p2,' || sql_err || ' - '  || error_info ;

      RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN

-- seteo los valores default
LET iStatus = 1 ;
LET vcMsg = '' ;
LET vc_NroInscripcion    = NULL ;
LET vc_mail    = NULL ;
LET vc_recibe_mail    = NULL ;

LET vcTituloSuperior = NULL;
LET vcTituloSecExt = NULL;
LET vcDescripcionTitSec = NULL;
LET viTipoIngreso = NULL;
LET vc_UnidadAcademica = NULL;
LET vc_Carrera = NULL;
LET vcDescripcionCarrera = NULL;
LET vcTipoTitulo = NULL;
LET vcTipoCarrera = NULL;
LET vcNroResConeau = NULL;
LET vcTitulo = NULL;

-- Obtener el nro. de inscripción de la persona
SELECT nro_inscripcion, unidad_academica INTO vc_NroInscripcion, vc_UnidadAcademica
FROM sga_certif_pedidos
WHERE certif_pedido = pCertifPedido;

-- Obtener la carrera del alumno por medio de los argumentos del certificado
SELECT trim(car.carrera), alu.legajo, alu.plan, trim(car.nombre), car.tipo_de_carrera INTO vc_Carrera, vcLegajo, vcPlan, vcDescripcionCarrera, vcTipoCarrera
FROM sga_certif_pedidos ped
	join sga_cert_ped_argum arg
		on ped.certif_pedido = arg.certif_pedido
	join sga_alumnos alu
			on ped.unidad_academica = alu.unidad_academica
			and ped.nro_inscripcion = alu.nro_inscripcion

	join sga_carreras car
		on alu.carrera = car.carrera
		
WHERE ped.certif_pedido = pCertifPedido
	AND arg.orden = 2
	AND alu.carrera = trim(arg.argumento);


-- Control de mail
SELECT trim(gda.e_mail), trim(gda.recibe_mail) INTO vc_mail, vc_recibe_mail
FROM sga_personas alu
	join gda_anun_conf_pers gda
	on alu.unidad_academica = gda.unidad_academica
	and alu.nro_inscripcion = gda.nro_inscripcion
WHERE alu.unidad_academica = vc_UnidadAcademica
	AND alu.nro_inscripcion  = vc_NroInscripcion;

IF (vc_mail IS NULL OR vc_recibe_mail = 'N') THEN
	LET iStatus = -1 ;
	LET vcMsg = 'email y/o recepción; ';

END IF;


-- Control de Resolución Ministerial del Plan.
-- En caso que esta no exista, colocar la Acreditación de la CONEAU

SELECT sga_planes.fecha_resolucion,
	sga_planes.nro_resolucion,
	sga_planes.version_actual
INTO dResolucionFecha,
	vcResolucionNro,
	vcPlanVersion
FROM sga_planes
WHERE sga_planes.unidad_academica = vc_UnidadAcademica
	AND sga_planes.carrera = vc_Carrera
	AND sga_planes.plan = vcPlan;

-- Caso particular ESS: titulo intermedio y fina de la carrera 07008 con resoluciones ME diferentes.
IF (vc_UnidadAcademica = 'ESS' AND vc_Carrera = '07008' AND vcPlan = '1997' AND vcTitulo = '9') THEN
	LET vcResolucionNro = 'ME-1644/97';
END IF;


IF (vcResolucionNro IS NULL OR (vcResolucionNro NOT LIKE 'CS-%' AND vcResolucionNro NOT LIKE 'ME-%' AND vcResolucionNro NOT LIKE 'DI-%' AND vcResolucionNro NOT LIKE 'SR')) THEN
	LET iStatus = -1 ;
	LET vcMsg = 'resolución Ministerial del plan de estudios; ' || vcMsg;

END IF;


IF iStatus = -1 THEN
	LET vcMsg = 'Completar/Corregir: ' || vcMsg;
ELSE
	LET vcMsg = '800320';
END IF;

RETURN iStatus, vcMsg;

END;

END PROCEDURE;
-- ********************** Fin del procedure ctr820_val_cert_p **********************
revoke execute on "dba".ctr820_val_cert_p2 from public;
grant execute on "dba".ctr820_val_cert_p2 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_val_cert_p2 to internet; -- Rol de usuario de Internet

-- execute procedure ctr820_val_cert_p2(54457);
