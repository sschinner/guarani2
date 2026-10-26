CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_agrega_solicitud_certificado100') THEN
		DROP PROCEDURE sp820_agrega_solicitud_certificado100;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- DROP PROCEDURE "dba".sp820_agrega_solicitud_certificado100;
-- Inserta un tramite de certificado analitico en el estado enviado como parametro
CREATE PROCEDURE "dba".sp820_agrega_solicitud_certificado100 (pUnidadAcademica LIKE sga_personas.unidad_academica
															, pNroDocumento LIKE sga_personas.nro_documento
															, pEstadoPago LIKE u820_pedidos_certif.estado_pago
															, pValidado LIKE u820_pedidos_certif.validado
															, pExpediente LIKE u820_pedidos_certif.validado
															, pUrlDescarga LIKE u820_pedidos_certif.validado
															, pTitulo LIKE sga_titulos.titulo
															, pTituloNombre LIKE sga_titulos.nombre
															, pMinisterio LIKE sga_cert_ped_argum.argumento
															, pCarrera LIKE sga_carreras.carrera)
	RETURNING 
		integer,	-- codigo retorno
		varchar(100); -- mensaje retorno


DEFINE vcCodigo integer;
DEFINE vcMensaje varchar(100);
DEFINE vcNroCertificado LIKE sga_certif_pedidos.certif_pedido;
DEFINE vcNroInscripcion LIKE sga_personas.nro_inscripcion;
DEFINE vcCantidad integer;
		
DEFINE sql_err	integer;
DEFINE isam_err	integer;
DEFINE error_info	varchar(76);

on exception set sql_err, isam_err, error_info
	-- error
	Rollback Work;
	raise exception  sql_err, isam_err, error_info;
end exception;

BEGIN WORK;

LET vcCodigo = 0;
LET vcMensaje = "OK - Se agrego la solicitud correctamente";

SELECT MAX(certif_pedido)
	INTO vcNroCertificado
	FROM sga_certif_pedidos;

LET vcNroCertificado = vcNroCertificado + 1;

SELECT nro_inscripcion
	INTO vcNroInscripcion
	FROM sga_personas
	WHERE nro_documento = pNroDocumento;
	
IF (vcNroInscripcion IS NOT NULL) THEN

	SELECT count(certif_pedido)
		INTO vcCantidad
		FROM sga_certif_pedidos
		WHERE certificado = 100
		AND nro_inscripcion = vcNroInscripcion
		AND copias_impresas < copias_pedidas
		AND fecha_de_emision IS NULL;
	
	IF (vcCantidad == 0) THEN
	
		INSERT INTO sga_certif_pedidos VALUES (vcNroCertificado, pUnidadAcademica, vcNroInscripcion, 100, CURRENT YEAR TO SECOND, 1, "AUTO", 3, null, null, 0);
	
		INSERT INTO u820_pedidos_certif VALUES (vcNroCertificado, pEstadoPago, pValidado, TO_CHAR(ADD_MONTHS(CURRENT, 1), "%m/%d/%Y"), vcNroCertificado, vcNroCertificado, pExpediente, pUrlDescarga, null);
	
		INSERT INTO sga_cert_ped_argum VALUES (vcNroCertificado, 1, pUnidadAcademica);
		INSERT INTO sga_cert_ped_argum VALUES (vcNroCertificado, 2, vcNroInscripcion);
		INSERT INTO sga_cert_ped_argum VALUES (vcNroCertificado, 3, pTitulo);
		INSERT INTO sga_cert_ped_argum VALUES (vcNroCertificado, 4, pTituloNombre);
		INSERT INTO sga_cert_ped_argum VALUES (vcNroCertificado, 5, pMinisterio);
		INSERT INTO sga_cert_ped_argum VALUES (vcNroCertificado, 6, pCarrera);

	ELSE 
		LET vcCodigo = -1;
		LET vcMensaje = "Error - La persona ya tiene un certificado en curso no entregado";
	END IF;
ELSE
	LET vcCodigo = -1;
	LET vcMensaje = "Error - La persona no existe";
END IF;

COMMIT WORK;

RETURN vcCodigo, vcMensaje;

END PROCEDURE;
-- *************************** FIN PROCESO sp820_agrega_solicitud_certificado100 *************************** 
revoke execute on "dba".sp820_agrega_solicitud_certificado100 from public;
grant execute on "dba".sp820_agrega_solicitud_certificado100 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_agrega_solicitud_certificado100 to internet; -- Rol de usuario de Internet


-- alumnado_fadu
EXECUTE PROCEDURE alumnado_fadu@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FADU', '34495849', 'P', 'N', null, null, 1, 'Arquitecto', 'S', 1);
EXECUTE PROCEDURE alumnado_fadu@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FADU', '35441233', 'P', 'N', null, null, 1, 'Arquitecto', 'S', 1);

-- alumnado_ess
EXECUTE PROCEDURE alumnado_ess@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ESS', '36261867', 'P', 'N', null, null, '92', 'Licenciado en Seguridad y Salud Ocupacional', 'S', '07092');
EXECUTE PROCEDURE alumnado_ess@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ESS', '36020102', 'P', 'N', null, null, '92', 'Licenciado en Seguridad y Salud Ocupacional', 'S', '07092');
EXECUTE PROCEDURE alumnado_ess@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ESS', '33427483', 'P', 'N', null, null, '92', 'Licenciado en Seguridad y Salud Ocupacional', 'S', '07092');
EXECUTE PROCEDURE alumnado_ess@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ESS', '34591432', 'P', 'N', null, null, '92', 'Licenciado en Seguridad y Salud Ocupacional', 'S', '07092');
EXECUTE PROCEDURE alumnado_ess@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ESS', '29971341', 'P', 'N', null, null, '92', 'Licenciado en Seguridad y Salud Ocupacional', 'S', '07092');
EXECUTE PROCEDURE alumnado_ess@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ESS', '25910687', 'P', 'N', null, null, '92', 'Licenciado en Seguridad y Salud Ocupacional', 'S', '07092');
EXECUTE PROCEDURE alumnado_ess@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ESS', '31707721', 'P', 'N', null, null, '92', 'Licenciado en Seguridad y Salud Ocupacional', 'S', '07092');
EXECUTE PROCEDURE alumnado_ess@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ESS', '27971089', 'P', 'N', null, null, '92', 'Licenciado en Seguridad y Salud Ocupacional', 'S', '07092');
EXECUTE PROCEDURE alumnado_ess@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ESS', '32733008', 'P', 'N', null, null, '92', 'Licenciado en Seguridad y Salud Ocupacional', 'S', '07092');
EXECUTE PROCEDURE alumnado_ess@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ESS', '29818099', 'P', 'N', null, null, '92', 'Licenciado en Seguridad y Salud Ocupacional', 'S', '07092');
EXECUTE PROCEDURE alumnado_ess@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ESS', '26985914', 'P', 'N', null, null, '92', 'Licenciado en Seguridad y Salud Ocupacional', 'S', '07092');
EXECUTE PROCEDURE alumnado_ess@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ESS', '33508454', 'P', 'N', null, null, '92', 'Licenciado en Seguridad y Salud Ocupacional', 'S', '07092');

-- semipre_fbcb
EXECUTE PROCEDURE semipre_fbcb@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FBCB', '16312555', 'P', 'N', null, null, 'CLEN', 'Licenciado en Enfermería', 'S', 'CLEN');
EXECUTE PROCEDURE semipre_fbcb@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FBCB', '36444912', 'P', 'N', null, null, 'CLEN', 'Licenciado en Enfermería', 'S', 'CLEN');
EXECUTE PROCEDURE semipre_fbcb@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FBCB', '28335223', 'P', 'N', null, null, 'CLEN', 'Licenciado en Enfermería', 'S', 'CLEN');
EXECUTE PROCEDURE semipre_fbcb@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FBCB', '22602178', 'P', 'N', null, null, 'CLEN', 'Licenciado en Enfermería', 'S', 'CLEN');
EXECUTE PROCEDURE semipre_fbcb@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FBCB', '16440645', 'P', 'N', null, null, 'CLEN', 'Licenciado en Enfermería', 'S', 'CLEN');
EXECUTE PROCEDURE semipre_fbcb@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FBCB', '29984359', 'P', 'N', null, null, 'CLEN', 'Licenciado en Enfermería', 'S', 'CLEN');
EXECUTE PROCEDURE semipre_fbcb@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FBCB', '21768407', 'P', 'N', null, null, 'CLEN', 'Licenciado en Enfermería', 'S', 'CLEN');
EXECUTE PROCEDURE semipre_fbcb@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FBCB', '26650502', 'P', 'N', null, null, 'CLEN', 'Licenciado en Enfermería', 'S', 'CLEN');
EXECUTE PROCEDURE semipre_fbcb@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FBCB', '33945727', 'P', 'N', null, null, 'CLEN', 'Licenciado en Enfermería', 'S', 'CLEN');
EXECUTE PROCEDURE semipre_fbcb@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FBCB', '22929666', 'P', 'N', null, null, 'CLEN', 'Licenciado en Enfermería', 'S', 'CLEN');
EXECUTE PROCEDURE semipre_fbcb@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FBCB', '31385394', 'P', 'N', null, null, 'CLEN', 'Licenciado en Enfermería', 'S', 'CLEN');
EXECUTE PROCEDURE semipre_fbcb@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FBCB', '27626915', 'P', 'N', null, null, 'CLEN', 'Licenciado en Enfermería', 'S', 'CLEN');

-- alumnado_fcjs
EXECUTE PROCEDURE alumnado_fcjs@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FCJS', '37282500', 'P', 'N', null, null, 'ABOG', 'ABOGADO', 'S', '1');
EXECUTE PROCEDURE alumnado_fcjs@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FCJS', '33349287', 'P', 'N', null, null, 'ABOG', 'ABOGADO', 'S', '1');
EXECUTE PROCEDURE alumnado_fcjs@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FCJS', '35650342', 'P', 'N', null, null, 'ABOG', 'ABOGADO', 'S', '1');
EXECUTE PROCEDURE alumnado_fcjs@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FCJS', '34085642', 'P', 'N', null, null, 'ABOG', 'ABOGADO', 'S', '1');
EXECUTE PROCEDURE alumnado_fcjs@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FCJS', '34563447', 'P', 'N', null, null, 'ABOG', 'ABOGADO', 'S', '1');
EXECUTE PROCEDURE alumnado_fcjs@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FCJS', '27726467', 'P', 'N', null, null, 'ABOG', 'ABOGADO', 'S', '1');
EXECUTE PROCEDURE alumnado_fcjs@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FCJS', '34832569', 'P', 'N', null, null, 'ABOG', 'ABOGADO', 'S', '1');
EXECUTE PROCEDURE alumnado_fcjs@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FCJS', '30392995', 'P', 'N', null, null, 'ABOG', 'ABOGADO', 'S', '1');
EXECUTE PROCEDURE alumnado_fcjs@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FCJS', '37406993', 'P', 'N', null, null, 'ABOG', 'ABOGADO', 'S', '1');
EXECUTE PROCEDURE alumnado_fcjs@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FCJS', '34654656', 'P', 'N', null, null, 'ABOG', 'ABOGADO', 'S', '1');
EXECUTE PROCEDURE alumnado_fcjs@rectorado_csm:sp820_agrega_solicitud_certificado100 ('FCJS', '34116261', 'P', 'N', null, null, 'CICTS', 'Licenciado en Trabajo Social', 'S', '5');

-- cemed_ecm
EXECUTE PROCEDURE cemed_ecm@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ECM', '23105831', 'P', 'N', null, null, '03', 'Licenciado en Producción de Bioimágenes', 'S', '03');
EXECUTE PROCEDURE cemed_ecm@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ECM', '20882279', 'P', 'N', null, null, '03', 'Licenciado en Producción de Bioimágenes', 'S', '03');
EXECUTE PROCEDURE cemed_ecm@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ECM', '30189338', 'P', 'N', null, null, '03', 'Licenciado en Producción de Bioimágenes', 'S', '03');
EXECUTE PROCEDURE cemed_ecm@rectorado_csm:sp820_agrega_solicitud_certificado100 ('ECM', '23358408', 'P', 'N', null, null, '03', 'Licenciado en Producción de Bioimágenes', 'S', '03');