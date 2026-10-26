-- *******************************************************************************
-- Controla si la persona tiene las condiciones para solicitar certificado pagos.
-- El control esta asociado al Punto de Control Nro 26 (Alumno/Certificado - Un Alumno solicita un Certificado)
-- *******************************************************************************
CREATE PROCEDURE verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR RETORNO

ON EXCEPTION 

END EXCEPTION WITH RESUME;

-- El control es sobre la persona

insert into par_implem_control (stored_procedure, parametros) values ("ctr820_cert_pago", "s,s,s,n");
insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (820010, "ctr820_cert_pago", "Controla Certificado Pago", "Controla Certificado Pago", null);
insert into par_cont_x_punto (punto_de_control, control) values (26, 820010);
execute procedure sp_confcont_cont (26, 820010);	

-- Se eliminan registros de configuracion que no corresponden a la unidad academica
delete from sga_conf_controles
where unidad_academica <> (select unidad_academica from sga_valor_inicial);

update sga_conf_controles set activo = 'N'
where operacion = 'agcert01';


update sga_conf_controles set activo = 'S'
where operacion = 'agcert01'
and control in ('44', '59', '60', '68', '81', '37', '82001', '820010'); 


END
END PROCEDURE;


EXECUTE PROCEDURE verifica_datos();
DROP PROCEDURE verifica_datos();

CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_cert_pago') THEN
		DROP PROCEDURE ctr820_cert_pago;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();

DROP PROCEDURE verifica_objeto();
-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.9.2
--
-- Procedure ctr820_cert_pago
-- U820
-- Controla que la persona tenga los requisitos necesarios para solicitar este tipo de certificado
-- **************************************************************************
-- drop procedure dba.ctr820_cert_pago;
CREATE PROCEDURE dba.ctr820_cert_pago( pUnidadAcademica  LIKE sga_alumnos.unidad_academica,
                                     pCarrera          LIKE sga_alumnos.carrera,
                                     pLegajo           LIKE sga_alumnos.legajo,
                                     pCertificado      LIKE sga_certificados.certificado
                                   )

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
  DEFINE vc_mail  varchar(50);
  DEFINE vc_recibe_mail  char(1);
  DEFINE iEgresado   smallint;       -- status

   -- bloque de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      LET iStatus = -1 ;
      LET vcMsg = '800321,' || 'ctr820_cert_pago,' || sql_err || ' - '  || error_info ;

      RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN

-- seteo los valores default
LET iStatus = 1 ;
LET vcMsg = '800320' ;
LET vc_NroInscripcion    = NULL ;
LET vc_mail    = NULL ;
LET vc_recibe_mail    = NULL ;
LET iEgresado = -1;

-- Obtener el nro. de inscripción de a persona
-- datos personales.
SELECT nro_inscripcion INTO vc_NroInscripcion
FROM sga_alumnos
WHERE sga_alumnos.unidad_academica = pUnidadAcademica
	AND sga_alumnos.carrera =  pCarrera
	AND sga_alumnos.legajo  = pLegajo;

SELECT trim(gda.e_mail), trim(gda.recibe_mail) INTO vc_mail, vc_recibe_mail
FROM sga_alumnos alu
	join gda_anun_conf_pers gda
	on alu.unidad_academica = gda.unidad_academica
	and alu.nro_inscripcion = gda.nro_inscripcion
WHERE alu.unidad_academica = pUnidadAcademica
	AND alu.carrera = pCarrera
	AND alu.legajo  = pLegajo;

-- Control de título
-- execute procedure sp820_calidad_alumno (pUnidadAcademica, pCarrera,vc_NroInscripcion)  INTO iEgresado;

IF EXISTS (select a.legajo
	from sga_alumnos a 
		join sga_titulos_otorg t
			on a.legajo=t.legajo
			and a.carrera=t.carrera
		join sga_titulos tp
			on t.titulo = tp.titulo
	where      a.nro_inscripcion =  vc_NroInscripcion
		and a.carrera =  pCarrera
		and tp.nivel = 'GRADO') THEN
	LET iEgresado = 1;
END IF;

IF pCertificado = 100 THEN

	-- Control de título
	IF iEgresado = -1 THEN
		LET iStatus = -1;
		LET vcMsg = '820010';
	ELSE
		-- Control de Cursos modelados como carreras
		IF EXISTS (select a.legajo
		from sga_alumnos a 
			join sga_titulos_otorg t
				on a.legajo=t.legajo
				and a.carrera=t.carrera 
			join sga_titulos tit
				on tit.titulo = t.titulo
				and tit.unidad_academica = t.unidad_academica
			
		where   a.nro_inscripcion = vc_NroInscripcion
			and a.carrera = pCarrera
			and tit.tipo_de_titulo in ('B', 'C')
			and t.fecha_egreso = (select max(fecha_egreso) from sga_titulos_otorg
						where carrera = pCarrera
							and nro_inscripcion = vc_NroInscripcion
							and unidad_academica = pUnidadAcademica)) THEN

			LET iStatus = -1;
			LET vcMsg = '820012';
		END IF;
	END IF;
ELSE

	-- Control de quién puede pedir que tipos de Certificado
	IF pCertificado in (9, 5) THEN
		-- Control de pedido
		IF iEgresado = 1  THEN
			LET iStatus = -1;
			LET vcMsg = '820040';

		ELSE
			-- Control de Cursos modelados como carreras
			IF EXISTS (select a.legajo
			from sga_alumnos a 
				join sga_planes t
					on a.plan = t.plan
					and a.carrera = t.carrera 
				join sga_titulos_plan p
					on t.plan = p.plan
					and t.carrera = p.carrera
				join sga_titulos tit
					on tit.titulo = p.titulo
					and tit.unidad_academica = p.unidad_academica
			
			where   a.nro_inscripcion = vc_NroInscripcion
				and a.carrera = pCarrera
				and tit.tipo_de_titulo in ('B', 'C')
				and 
					( pUnidadAcademica <> 'FCE')
						OR
					(pUnidadAcademica = 'FCE' and pCarrera in ('0200')) -- Excepcion Bachiller FCE Grado. Se supone que el codigo de carrera es unico.
				) THEN
	
				LET iStatus = -1;
				LET vcMsg = '820012';
			END IF;
	
		END IF;
	END IF;

END IF;

-- Configuración de controles comunes
IF pCertificado in (100, 9, 5) THEN
	-- Control de configuración de mail
	IF vc_mail IS NULL OR vc_recibe_mail = 'N' THEN
		LET iStatus = -1;
		LET vcMsg = '820011';
	END IF;

END IF;


RETURN iStatus, vcMsg;

END;

END PROCEDURE;
-- ********************** Fin del procedure ctr820_cert_pago **********************
-- execute PROCEDURE dba.ctr820_cert_pago( 'FICH', 'EDC', '28074555-6', 9); -- Alumnos activo EDC: no puede
-- execute PROCEDURE dba.ctr820_cert_pago( 'FICH', 'EDC', '28074555-6', 100); -- Alumnos activo sin titulo: no puede
-- execute PROCEDURE dba.ctr820_cert_pago( 'FICH', 'MGIRH', '11933246-7', 100); -- Certificado permitido: si puede
-- execute PROCEDURE dba.ctr820_cert_pago( 'FICH', 'MGIRH', '11933246-7', 9); -- Certificado no permitido: no puede

-- execute PROCEDURE dba.ctr820_cert_pago( 'FADU', '1', '41268009-9', 9); -- Certificado HA: si puede si tiene mail y envío seteados
-- execute PROCEDURE dba.ctr820_cert_pago( 'FADU', '1', '41268009-9', 5); -- Certificado MA: si puede si tiene mail y envío seteados
-- execute PROCEDURE dba.ctr820_cert_pago( 'FADU', '1', '34360114-6', 100); -- Egresado: si puede