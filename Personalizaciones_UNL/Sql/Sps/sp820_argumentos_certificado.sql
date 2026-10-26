CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_argumentos_certificado') THEN
		DROP PROCEDURE sp820_argumentos_certificado;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: -;

CREATE PROCEDURE "dba".sp820_argumentos_certificado(p_certif_pedido integer)
RETURNING 
integer,	-- orden
varchar(100),	-- nombre
varchar(200);	-- argumento

DEFINE vc_orden integer;
DEFINE vc_nombre varchar(100);
DEFINE vc_argumento varchar(200);

FOREACH
	SELECT cpa.orden, ca.nombre, cpa.argumento
		INTO vc_orden, vc_nombre, vc_argumento
		FROM sga_cert_ped_argum cpa
		JOIN sga_certif_pedidos cp
			ON cp.certif_pedido = cpa.certif_pedido
		JOIN sga_certif_argum ca
			ON ca.certificado = cp.certificado
			AND ca.orden = cpa.orden
		WHERE cpa.certif_pedido = p_certif_pedido

	RETURN vc_orden, vc_nombre, vc_argumento WITH RESUME;

END FOREACH;

END PROCEDURE;

-- EXECUTE PROCEDURE "dba".sp820_argumentos_certificado(); --1
-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_argumentos_certificado 
-- *****************************************************************************
revoke execute on "dba".sp820_argumentos_certificado from public;
grant execute on "dba".sp820_argumentos_certificado to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_argumentos_certificado to internet; -- Rol de usuario de Internet


