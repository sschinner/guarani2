CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_ser_baja_req') THEN
		DROP PROCEDURE web_ser_baja_req;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- EXECUTE PROCEDURE "dba".web_ser_baja_req('FBCB','0301', 54, 0, '40160524', 'FBCB-12842', 'UNL03');

-- *************** COMIENZO DEL PROCEDURE web_ser_baja_req ***************
-- ************************************************************************
-- SP que genera una inscripcion a carrera, a partir de datos de CEMED
-- en un período dado
-- ************************************************************************
-- DROP PROCEDURE "dba".web_ser_baja_req;
      
CREATE PROCEDURE "dba".web_ser_baja_req(pUnidadAcademica LIKE sga_unidades_acad.unidad_academica,
	pCarrera LIKE sga_carreras.carrera,
	pPaisDocumento LIKE sga_personas.pais_documento,
	pTipoDocumento LIKE sga_personas.tipo_documento,
	pNroDocumento LIKE sga_personas.nro_documento,
	pNroInscripcion LIKE sga_personas.nro_inscripcion,
	pRequisito LIKE sga_requisitos.requisito
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
DEFINE vi_equivalencia	LIKE sga_mov_equiv.equivalencia;
DEFINE ls_legajo           LIKE sga_alumnos.legajo;
DEFINE _requisito_prorrogado LIKE sga_requisitos.requisito;

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
LET vi_equivalencia = NULL;
LET ls_legajo 	      = NULL;
LET _requisito_prorrogado = NULL;
------------------------------------------------------------------------------------ 
-- Obtengo datos generales de inscripcion a la carrera.

-- Obtengo la Unidad Academica.
Select unidad_academica Into aunidad_academica 
from sga_unidades_acad
where unidad_academica = pUnidadAcademica;

------------------------------------------------------------------------------------ 
-- Verifico si existe la persona como aspirante en la carrera. No interesa el estado en el que se encuentre el aspirante, el requisito se debe dar de baja.
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

LET vcMsg =  'OK' || ' - ' || pNroDocumento || ' - Se dio de baja el requisito: ' || pRequisito;			

IF anro_inscripcion is null 
THEN
    -- Error
    LET vcMsg = 'La persona no se encuentra inscripta en esta carrera';
    LET iStatus = -1;
    RETURN iStatus, vcMsg;	
END IF;

------------------------------------------------------------------------------------ 
-- Busco el requisito en la carrera 
------------------------------------------------------------------------------------ 
IF NOT EXISTS (SELECT '*' FROM sga_carrera_aspira asp
                join sga_req_cumplidos req
                on asp.nro_inscripcion = req.nro_inscripcion and asp.carrera = req.carrera
                WHERE asp.unidad_academica = aunidad_academica
                    AND asp.nro_inscripcion = anro_inscripcion
		    AND asp.carrera = pCarrera
                    AND req.requisito = pRequisito) 
THEN
    LET vcMsg = 'No existe el requisito ' || pRequisito || ' para la persona ' || pNroDocumento || ' en la carrera ' || pCarrera;
    LET iStatus = -2;
    RETURN iStatus, vcMsg;	
END IF;

-- Verifico si ya esta cumplimentado
SELECT fecha_presentacion INTO aFechaPresentacion
FROM sga_req_cumplidos req
WHERE unidad_academica = aunidad_academica
    AND nro_inscripcion = anro_inscripcion
    AND carrera = pCarrera
    AND requisito = pRequisito;

IF  (aFechaPresentacion is NULL) 
THEN
    LET vcMsg = 'La persona no tiene el requisito ' || pRequisito || ' presentado.' ;
    LET iStatus = -3;
    RETURN iStatus, vcMsg;
END IF;

-- Actualizo datos de cumplimiento del requisito
UPDATE sga_req_cumplidos 
set 
    fecha_presentacion = NULL, 	
    exceptuado = 'N',
    motivo_excep_req = NULL,
    resolucion = NULL,
    f_prorroga_hasta = NULL,
    observaciones = NULL    
WHERE unidad_academica = aunidad_academica
    AND nro_inscripcion = anro_inscripcion
    AND carrera = pCarrera
    AND requisito = pRequisito;

IF 
    -- UNL03 - Certificado de Estudios Secundarios legalizado en la UNL
    pRequisito = 'UNL15' OR    -- Fotocopia del titulo no legalizado
    pRequisito = 'UNL16' OR    -- Fotocopia del titulo legaliz. y conv. por el Min. de Ed.
    pRequisito = 'UNL17' OR    -- Fotocopia del titulo legalizado y no convalidado
    pRequisito = 'UNL18' OR    -- Fotocopia del titulo leg. y con rev. asig. form. nac.
    pRequisito = 'UNL19'       -- Fotocopia del titulo legalizado y no revalidado
THEN
    LET _requisito_prorrogado = 'UNL03';
END IF;

IF 
    -- POS01 - Fotocopia del titulo Universitario
    pRequisito = 'POS02' OR    -- Constancia de titulo Universitario en TrÃ¡mite
    pRequisito = 'POS08'       -- Fotocopia del titulo Universitario no legalizado por UNL
THEN
    LET _requisito_prorrogado = 'POS01';
END IF;

IF 
    -- UNL22 - Certificado de Estudios Terciarios legalizado en la UNL
    pRequisito = 'UNL20' OR    -- Fotocopia del Título Terciario
    pRequisito = 'UNL21'       -- Constancia de Título Terciario en Trámite
THEN
    LET _requisito_prorrogado = 'UNL22';
END IF;
         
-- y no tiene presentado el definitivo pero si prorrogado
IF EXISTS (
            SELECT requisito 
            FROM sga_req_cumplidos 
            WHERE 
                requisito = _requisito_prorrogado 
                AND fecha_presentacion IS NULL 
                AND f_prorroga_hasta IS NOT NULL
                AND nro_inscripcion = anro_inscripcion 
                AND carrera = pCarrera
                )
THEN
    -- quito la prorroga del definitivo
    UPDATE  sga_req_cumplidos
    SET     f_prorroga_hasta = NULL 
    WHERE   requisito = _requisito_prorrogado AND nro_inscripcion = anro_inscripcion AND carrera = pCarrera;
END IF;
          
-- En caso de que tenga legajo generado y cumplimente los requisitos obligatorios, se le cambia la situación del alumno a "IL".
IF EXISTS (Select '*' from sga_alumnos
            where nro_inscripcion = anro_inscripcion
            and carrera = pCarrera) 
THEN
    Select legajo INTO ls_legajo 
    from sga_alumnos
    where nro_inscripcion = anro_inscripcion
        and carrera = pCarrera;
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
		AND	sga_situacion_asp.resultado_asp in ('I', 'A');

		IF l_periodo_insc IS NOT NULL THEN
			-- Ejecutar el Sp. para saber si cumplió con todos los requisitos obligatorios. Si es así mantiene su condición actual.
	      		EXECUTE PROCEDURE sp_cumplio_req(aunidad_academica,anro_inscripcion,pCarrera,l_periodo_insc) INTO ll_result, ll_result2, ls_mensaje_result;
			IF ll_result = -1 THEN -- 'No presentó todos los req. obligatorios'.

				EXECUTE PROCEDURE sp_cumplio_req_leg (aunidad_academica,anro_inscripcion,pCarrera,l_periodo_insc) INTO ll_result, ll_result2, ls_mensaje_result;

				IF ll_result = -1 THEN
					-- no cumplio requisitos obligatorios para generar legajo
					-- Debo dar de baja el legajo. En caso de que tenga registros relacionados (según trigger td_alumnos.sql) va a dar error, que es devuelto por el SP.


					--*************************************************************************
					-- U820: INVALIDAR HA DE EQUIVALENCIAS DE LA CARRERA EN CUESTION
					-- EN CASO DE QUE TENGA OTRO TIPO DE HA, NO SE INVALIDARÁ Y QUEDARÁ A CRITERIO DEL OPERADOR
					-- SE CORTARA LA EJECUCION POR EXCEPTION: NO SE PUEDE DAR DE BAJA COMO ALUMNO
					-- sp_mov_equiv; sp_equiv_eq_equiv: determinar todas la equivalencia y borrarlas una a una.
					--*************************************************************************
					-- OBTENER TODAS LA EQUIVALENCIAS DEL ALUMNO Y BORRARLAS
					-- SE DEBEN BORRAR PARA PODER ELIMINAR AL DETALLE DEL ALUMNO Y COLOCAR LA INSCRIPCION "AC"

					FOREACH SELECT equivalencia INTO vi_equivalencia
						from sga_equiv_otorgada
						where carrera = pCarrera
							and legajo = ls_legajo
						
						--OBTENER TODAS LAS EQUIV_EQUIV DEL ALUMNO E INVALIDARLAS
						IF EXISTS (SELECT '*' FROM sga_equiv_equiv where equivalencia = vi_equivalencia) THEN
							DELETE FROM sga_equiv_equiv WHERE equivalencia = vi_equivalencia;
						END IF;

						DELETE FROM sga_equiv_otorgada WHERE equivalencia = vi_equivalencia;

					END FOREACH;
					--************************************************************************
					-- U820: INVALIDAR HA DE EQUIVALENCIAS DE LA CARRERA EN CUESTION
					-- sp_mov_equiv; sp_equiv_eq_equiv: determinar todas la equivalencia y borrarlas una a una.
					--************************************************************************

					DELETE FROM sga_lgen_hacad_alu
						WHERE unidad_academica = aunidad_academica
						AND carrera = pcarrera
						AND legajo = ls_legajo;

					DELETE FROM sga_alumnos 
						WHERE unidad_academica = aunidad_academica
						AND carrera = pcarrera
						AND nro_inscripcion = anro_inscripcion;
					LET v_retorno_situasp = 'AC';
					LET vcMsg = vcMsg || ' y se ha cambiado la condición del alumno a Aspirante';
				ELSE
					LET v_retorno_situasp = 'IC';
					LET vcMsg = vcMsg || ' y el legajo del alumno se encuentra en estado Condicional';
				END IF;
				
				UPDATE 	sga_carrera_aspira
				SET 	situacion_asp = v_retorno_situasp
				WHERE 	unidad_academica = aunidad_academica
				AND	carrera = pCarrera
				AND	nro_inscripcion = anro_inscripcion
				AND	periodo_inscripcio = l_periodo_insc;
				
			END IF;
		END IF;
	
END IF; -- es alumno

RETURN iStatus, vcMsg;

END PROCEDURE;
-- *************** FIN DEL PROCEDURE "dba".web_ser_baja_req ***************

revoke execute on "dba".web_ser_baja_req from public;
grant execute on "dba".web_ser_baja_req to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_ser_baja_req to internet; -- Rol de usuario de Internet

