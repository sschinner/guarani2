-- Control para maxima cantidad de certificados pedidos por Año Academico.
CREATE PROCEDURE verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR RETORNO

ON EXCEPTION 


END EXCEPTION WITH RESUME;

-- El control es sobre la persona

insert into par_implem_control (stored_procedure, parametros) values ("ctr820_MaxCantCert", "s,s,n");
insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (82001, "ctr820_MaxCantCert", "Controla Persona NO excedio cantidad Certificado.", "Controla si la Persona NO excedio la cantidad de Certificados pedidos permitida.", null);
insert into par_cont_x_punto (punto_de_control, control) values (25, 82001);
execute procedure sp_confcont_cont (25, 82001);
	
END
END PROCEDURE;

EXECUTE PROCEDURE verifica_datos();
DROP PROCEDURE verifica_datos();

CREATE PROCEDURE verifica_objeto()

BEGIN

	IF EXISTS (SELECT procid

			FROM sysprocedures

			WHERE procname = 'ctr820_maxcantcert') THEN

		DROP PROCEDURE ctr820_MaxCantCert;

	END IF;		

END

END PROCEDURE;

EXECUTE PROCEDURE verifica_objeto();

DROP PROCEDURE verifica_objeto();


-- **************************************************************************
-- Control: ctr820_MaxCantCert
-- Version 1.7.0
--
-- Controla que no se supere la maxima cantidad de Certificados de Historia academica pedidos, definidos para el Año academico.
-- **************************************************************************

-- Creating procedure
CREATE PROCEDURE "dba".ctr820_MaxCantCert ( pUnidadAcademica  LIKE sga_alumnos.unidad_academica,
                                     pNroInscripcion   LIKE sga_alumnos.nro_inscripcion,
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

  -- vars locales
  DEFINE vcCertificado    LIKE sga_certificados.certificado;
  DEFINE vcCertifNombre   LIKE sga_certificados.nombre;
  DEFINE viCantidadImp Integer;
  DEFINE viCantidadNoImp Integer;
  DEFINE vcAnioAcademico varchar(4);
  DEFINE vdFechaInicio DATE;
  DEFINE vdFechaFin DATE;

BEGIN


   -- inicializo con OK, porque puede ser que termine sin llegar al final
   LET iStatus = 1;
   LET vcMsg = '800320';
   

IF pCertificado <> 100 THEN
   
	-- Selecciono el Anio Academico Actual.

	SELECT  YEAR (fecha_inicio), fecha_inicio, fecha_fin INTO vcAnioAcademico, vdFechaInicio, vdFechaFin 
		FROM sga_anio_academico
		WHERE TODAY BETWEEN fecha_inicio AND fecha_fin;

	-- selecciono la cantidad de certificados pedidos impresos de la persona o pendientes de impresión.

	SELECT 
		  	sga_certif_pedidos.certificado,
		SUM (sga_certif_pedidos.copias_impresas)
	     INTO vcCertificado, viCantidadImp
	     
	     FROM sga_certif_pedidos
	     WHERE sga_certif_pedidos.unidad_academica = pUnidadAcademica
	     	AND sga_certif_pedidos.nro_inscripcion  = pNroInscripcion
		AND sga_certif_pedidos.certificado = pCertificado
		AND DATE(sga_certif_pedidos.fecha_de_pedido) between  vdFechaInicio AND vdFechaFin 
	     
	GROUP BY sga_certif_pedidos.certificado;


	SELECT 
		  	sga_certif_pedidos.certificado,
		SUM (sga_certif_pedidos.copias_pedidas)
	    INTO vcCertificado, viCantidadNoImp
	     
	     FROM sga_certif_pedidos
	     WHERE sga_certif_pedidos.unidad_academica = pUnidadAcademica
	     	AND sga_certif_pedidos.nro_inscripcion  = pNroInscripcion
		AND sga_certif_pedidos.certificado = pCertificado
		AND DATE(sga_certif_pedidos.fecha_de_pedido) between vdFechaInicio AND vdFechaFin
		AND sga_certif_pedidos.fecha_de_emision Is Null
	       
	GROUP BY sga_certif_pedidos.certificado;

	IF viCantidadNoImp IS NULL THEN
		LET viCantidadNoImp = 0;
	END IF;

	-- averiguo el nombre del certificado.
	SELECT sga_certificados.nombre
	 INTO vcCertifNombre
	 FROM sga_certificados
	WHERE sga_certificados.certificado = vcCertificado ; 

	-- verifico que no exceda la cantidad de certificados.

	IF (viCantidadImp + viCantidadNoImp) >= (Select max_copias 
					From sga_certificados 
					where certificado = pCertificado )
	 THEN
		  LET iStatus = -1 ;
		  LET vcMsg = '820001';
		  RETURN iStatus, vcMsg ;
	END IF;

END IF;
       
RETURN iStatus, vcMsg ;
   
END;

END PROCEDURE;
-- ********************** FIN DEL PROCEDURE ctr820_MaxCantCert**********************

 
