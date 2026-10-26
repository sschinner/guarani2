CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_ser_alta_req') THEN
		DROP PROCEDURE web_ser_alta_req;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- EXECUTE PROCEDURE "dba".web_ser_alta_req('FBCB',	'0301', 54, 0, '40160524', 'FBCB-12842', 'UNL03', 'S', '11/22/2016', 'N');

-- *************** COMIENZO DEL PROCEDURE web_ser_alta_req ***************
-- ************************************************************************
-- SP que genera una inscripcion a carrera, a partir de datos de CEMED
-- en un período dado
-- ************************************************************************
-- DROP PROCEDURE "dba".web_ser_alta_req;
      
CREATE PROCEDURE "dba".web_ser_alta_req(
    pUnidadAcademica    LIKE sga_unidades_acad.unidad_academica,
	pCarrera            LIKE sga_carreras.carrera,
	pPaisDocumento      LIKE sga_personas.pais_documento,
	pTipoDocumento      LIKE sga_personas.tipo_documento,
	pNroDocumento       LIKE sga_personas.nro_documento,
	pNroInscripcion     LIKE sga_personas.nro_inscripcion,
	pRequisito          LIKE sga_requisitos.requisito,
	pObligatorio        LIKE sga_req_cumplidos.obligatoriedad,
	pFechaPresentacion  LIKE sga_req_cumplidos.fecha_presentacion,
	pExceptuado         LIKE sga_req_cumplidos.exceptuado
)
	Returning INT,VARCHAR(255);

-- Descripcion de Parámetros:

-- Descripcion de Return:
-- INT: 	0 - OK
--	-1 - Error
-- VARCHAR(255): string con la descripcion del error
	
DEFINE aunidad_academica LIKE sga_datos_censales.unidad_academica;
DEFINE anro_inscripcion LIKE sga_personas.nro_inscripcion;
DEFINE aux_nro_inscripcion int;
DEFINE aFechaPresentacion LIKE sga_req_cumplidos.fecha_presentacion;
DEFINE l_periodo_insc     	LIKE sga_carrera_aspira.periodo_inscripcio;

DEFINE ll_result, ll_result2		Integer;
DEFINE ls_mensaje_result,ls_mensaje_result2 	varchar(255);
DEFINE v_retorno_situasp  	LIKE sga_situacion_asp.situacion_asp;

DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(80);
DEFINE vcUserError		varchar(10);
DEFINE iStatus			int;
DEFINE vcMsg			varchar(255);
DEFINE _motivo_excepcion     LIKE  sga_mot_excep_req.motivo_excep_req;

  -- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info;
      RETURN iStatus, vcMsg;
END EXCEPTION;
--------------------------------------------------


LET aunidad_academica = NULL;
LET anro_inscripcion = NULL;
LET aux_nro_inscripcion = NULL;
LET aFechaPresentacion = NULL;
LET error_info = NULL;
LET sql_err = 0;
LET isam_err = 0;
LET iStatus = 0;
LET vcMsg =  'OK - Requisito insertado correctamente';
LET _motivo_excepcion = NULL;

------------------------------------------------------------------------------------ 
-- Obtengo datos generales de inscripcion a la carrera.

-- Obtengo la Unidad Academica.
Select unidad_academica Into aunidad_academica 
from sga_unidades_acad
where unidad_academica = pUnidadAcademica;


-- Recodificación de datos
IF pExceptuado is null OR trim(pExceptuado) = '' THEN
	LET pExceptuado = 'N';
END IF; 

IF pExceptuado = 'S' THEN
    LET _motivo_excepcion = 'UNL';
END IF;

Select sit.resultado_asp
Into v_retorno_situasp
		from sga_personas per
			join sga_carrera_aspira asp on per.nro_inscripcion = asp.nro_inscripcion
			join sga_situacion_asp sit on sit.situacion_asp = asp.situacion_asp
		where per.tipo_documento = pTipoDocumento 
			and per.nro_documento = pNroDocumento
			and per.pais_documento = pPaisDocumento
			and per.unidad_academica = aunidad_academica
			and asp.carrera = pCarrera
            and asp.fecha_inscripcion = (
                SELECT max(asp.fecha_inscripcion) FROM sga_personas per
                join sga_carrera_aspira asp on per.nro_inscripcion = asp.nro_inscripcion
                where per.tipo_documento = pTipoDocumento 
                and per.nro_documento = pNroDocumento
                and per.pais_documento = pPaisDocumento
                and per.unidad_academica = aunidad_academica
                and asp.carrera = pCarrera);

IF v_retorno_situasp = 'R'
THEN
    -- Error
	LET vcMsg = 'La persona se encuentra rechazada en esta carrera';
	LET iStatus = -3;
	RETURN iStatus, vcMsg;
END IF;

------------------------------------------------------------------------------------ 
-- Verifico si existe la persona como aspirante en la carrera. No interesa el estado en el que se encuentre el aspirante, el requisito se carga.
Select max(per.nro_inscripcion) Into anro_inscripcion
		from sga_personas per
			join sga_carrera_aspira asp
			on per.nro_inscripcion = asp.nro_inscripcion
		where per.tipo_documento = pTipoDocumento 
			and per.nro_documento = pNroDocumento
			and per.pais_documento = pPaisDocumento
			and per.unidad_academica = aunidad_academica
			-- and per.nro_inscripcion = pNroInscripcion
			and asp.carrera = pCarrera
group by per.nro_inscripcion;
			

IF anro_inscripcion is not null THEN
	------------------------------------------------------------------------------------ 
	-- Busco el requisito en la carrera y actualizo o inserto según corresponda
	------------------------------------------------------------------------------------ 
  	IF EXISTS (SELECT '*' FROM sga_carrera_aspira asp
				join sga_req_cumplidos req
					on asp.nro_inscripcion = req.nro_inscripcion
					and asp.carrera = req.carrera
		      		WHERE asp.unidad_academica = aunidad_academica
	        			AND asp.nro_inscripcion = anro_inscripcion
		        		AND asp.carrera = pCarrera
					AND req.requisito = pRequisito) THEN

		-- Verifico si ya esta cumplimentado
		SELECT fecha_presentacion INTO aFechaPresentacion
		FROM sga_req_cumplidos req
			WHERE unidad_academica = aunidad_academica
	       			AND nro_inscripcion = anro_inscripcion
		        		AND carrera = pCarrera
				AND requisito = pRequisito;


		IF  (aFechaPresentacion is not NULL) THEN

		        -- Error
			LET vcMsg = 'La persona ya posee cargado el requisito de ingreso';
			LET iStatus = -2;
	        		-- RETURN iStatus, vcMsg;

		ELSE
		-- Actualizo datos de cumplimiento del requisito
			UPDATE sga_req_cumplidos set fecha_presentacion = pFechaPresentacion, obligatoriedad = pObligatorio, exceptuado = pExceptuado, motivo_excep_req = _motivo_excepcion
				WHERE unidad_academica = aunidad_academica
	       			AND nro_inscripcion = anro_inscripcion
	        			AND carrera = pCarrera
				AND requisito = pRequisito ;
		END IF;

	ELSE 
	-- Insert del Requisito
		INSERT INTO sga_req_cumplidos (unidad_academica, nro_inscripcion, requisito, carrera, obligatoriedad, fecha_presentacion, exceptuado, motivo_excep_req)
			values (aunidad_academica, anro_inscripcion, pRequisito, pCarrera, pObligatorio, pFechaPresentacion, pExceptuado, _motivo_excepcion);

	END IF;

	-- Actualizo datos de cumplimiento del requisito UNL07, si es que el requisito que se inserta es el UNL03
	IF pRequisito = 'UNL03' THEN
		-- Actualizo datos de cumplimiento del requisito. El registro correspondiente se asume que esta insertado ya que el mismo esta como obligatorio
			UPDATE sga_req_cumplidos set fecha_presentacion = pFechaPresentacion, exceptuado = pExceptuado
				WHERE unidad_academica = aunidad_academica
	       			AND nro_inscripcion = anro_inscripcion
	        			AND carrera = pCarrera
				AND requisito = 'UNL07' ;
	END IF;

	-- En caso de que tenga legajo generado y cumplimente los requisitos obligatorios, se le cambia la situación del alumno a "IL".

	IF EXISTS (Select '*' from sga_alumnos
				where nro_inscripcion = anro_inscripcion
				and carrera = pCarrera) THEN
		--***************************************************************
		-- Recupera la Fecha de Inscripcion en la Carrera
		-- Saco la maxima fecha, por si esta inscripto mas de una vez en la
		-- carrera (en distintos períodos de inscripcion. No debería pasar)
		--***************************************************************

		LET l_periodo_insc = NULL;

		SELECT	sga_carrera_aspira.periodo_inscripcio
			INTO  l_periodo_insc
		FROM   	sga_carrera_aspira,
			sga_situacion_asp
		WHERE 	sga_carrera_aspira.unidad_academica = aunidad_academica
		AND  	sga_carrera_aspira.carrera = pcarrera
		AND	sga_carrera_aspira.nro_inscripcion = anro_inscripcion
		AND	sga_carrera_aspira.situacion_asp = sga_situacion_asp.situacion_asp
		AND	sga_situacion_asp.resultado_asp = 'A'; -- En este punto el alumno esta como IC

		IF l_periodo_insc IS NOT NULL THEN
			-- Ejecutar el Sp. para saber si cumplió con todos los requisitos obligatorios.
	      		EXECUTE PROCEDURE sp_cumplio_req(aunidad_academica,anro_inscripcion,pCarrera,l_periodo_insc) INTO ll_result, ll_result2, ls_mensaje_result;
			IF ll_result = 1 THEN

				-- Se pasa la situación de aspirante a 'IL'(Ingresante con Legajo).
				-- Buscar el código de situacion de aspirante por default establecido, para resultado inscripto('I').
				EXECUTE PROCEDURE sp_default_sit_res('I') into v_retorno_situasp;

				-- A partir del año 2018, no se cambia la situación del legajo dependiendo de la inserción de u nuevo requisito.
				--UPDATE 	sga_carrera_aspira
				--SET 	situacion_asp = v_retorno_situasp
				--WHERE 	unidad_academica = aunidad_academica
				--AND	carrera = pCarrera
				--AND	nro_inscripcion = anro_inscripcion
				--AND	periodo_inscripcio = l_periodo_insc;
			END IF;
		END IF;
	
	END IF;


ELSE
	-- Error
	LET vcMsg = 'La persona no se encuentra inscripta en esta carrera';
	LET iStatus = -1;
	RETURN iStatus, vcMsg;	

END IF;

-- LET vcMsg = 'OK' || ' - ' || anro_inscripcion;
RETURN iStatus, vcMsg;


END PROCEDURE;
-- *************** FIN DEL PROCEDURE "dba".web_ser_alta_req ***************

revoke execute on "dba".web_ser_alta_req from public;
grant execute on "dba".web_ser_alta_req to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_ser_alta_req to internet; -- Rol de usuario de Internet

