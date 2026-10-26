-- *******************************************************************************
-- Controla si la persona tiene los datos actualizados para solicitar certificados pagos.
-- *******************************************************************************
CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_argum_sol_diploma') THEN
		DROP PROCEDURE sp820_argum_sol_diploma;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();

DROP PROCEDURE verifica_objeto();
-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.9.2
--
-- Procedure sp820_argum_sol_diploma
-- U820
-- Obtiene los argumentos de una solicitud de diploma digital para imprimir
-- **************************************************************************
-- drop procedure dba.sp820_argum_sol_diploma;
CREATE PROCEDURE dba.sp820_argum_sol_diploma( pCertifPedido  LIKE sga_certif_pedidos.certif_pedido)

RETURNING  varchar(10), -- UA
           	varchar(10), -- nro. inscripcion
	varchar(5); -- Titulo 


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
DEFINE vcTitulo varchar(5);


   -- bloque de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
	RAISE EXCEPTION  sql_err, isam_err, error_info;
   END EXCEPTION;        

BEGIN

-- seteo los valores default
LET iStatus = 1 ;
LET vcMsg = '' ;

LET vc_UnidadAcademica   = NULL;
LET vc_NroInscripcion    = NULL ;
LET vcTitulo = NULL;

-- Obtener llos argumento por pedido  y no por argumentos
	SELECT trim(ped.unidad_academica), ped.nro_inscripcion, tit.titulo  INTO vc_UnidadAcademica, vc_NroInscripcion, vcTitulo
	FROM sga_certif_pedidos ped
		join u820_pedidos_certif_diploma dip
			on  dip.id_certif_pedido = ped.certif_pedido
		join sga_titulos_otorg tit
			on ped.unidad_academica = tit.unidad_academica
				and ped.nro_inscripcion = tit.nro_inscripcion
		join sga_titulos tt
			on tit.titulo = tt.titulo
		join sga_carreras car
			on tit.carrera = car.carrera
		
	WHERE ped.certif_pedido = pCertifPedido
		and dip.titulo = tit.titulo;

RETURN vc_UnidadAcademica, vc_NroInscripcion, vcTitulo;
END

END PROCEDURE;
-- ********************** Fin del procedure sp820_argum_sol_diploma **********************
revoke execute on "dba".sp820_argum_sol_diploma from public;
grant execute on "dba".sp820_argum_sol_diploma to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_argum_sol_diploma to internet; -- Rol de usuario de Internet

-- execute procedure sp820_argum_sol_diploma(23965);




