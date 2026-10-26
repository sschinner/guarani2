DROP PROCEDURE b820_regcontrolarvenc;
CREATE PROCEDURE b820_regcontrolarvenc(

	pUnidadAcademica LIKE sga_alumnos.unidad_academica,

	pCarrera LIKE sga_alumnos.carrera,

	pLegajo LIKE sga_alumnos.legajo DEFAULT NULL)



	RETURNING varchar(5),        -- sga_alumnos.unidad_academica

	          varchar(5),        -- sga_alumnos.carrera

	          varchar(15),       -- sga_alumnos.legajo

	          integer;           -- Resultado: 1 o -1



	-- Variables locales

	DEFINE vUnidadAcademica   LIKE sga_alumnos.carrera;

	DEFINE vCarrera           LIKE sga_alumnos.carrera;

	DEFINE vLegajo            LIKE sga_alumnos.legajo;

	DEFINE vResultado         integer;

	DEFINE vFechaVencim       LIKE sga_perdidas_regul.fecha_vencim_rehab;



	-- Variables para el manejo de excepciones

	DEFINE SQLErr             integer;

	DEFINE ISAMError          integer;

	DEFINE errorInfo          varchar(76);



	-- Si hay algun error

	ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        

		RAISE EXCEPTION SQLErr, ISAMError, errorInfo;

	END EXCEPTION;

BEGIN

	-- Recupera la lista de alumnos a los que debe controlar

	FOREACH

		-- Para cada uno, ve si está vencida la prórroga

		SELECT unidad_academica,

		       carrera,

		       legajo,

                                        fecha_vencim_rehab, 
                                        case when dba.sga_perdidas_regul.fecha_vencim_rehab <= TODAY then 1
                                               else -1
                                         end

		  INTO vUnidadAcademica,

		       vCarrera,

		       vLegajo,

                                  vFechaVencim,
                                  vResultado

		  FROM sga_perdidas_regul

		 WHERE dba.sga_perdidas_regul.unidad_academica = pUnidadAcademica

		   AND dba.sga_perdidas_regul.carrera = pCarrera

		   AND (dba.sga_perdidas_regul.legajo = pLegajo OR pLegajo IS NULL)

		   AND dba.sga_perdidas_regul.fecha_vencim_rehab IS NOT NULL

  	                   ---AND dba.sga_perdidas_regul.fecha_vencim_rehab <= TODAY
                                  
                                  and dba.sga_perdidas_regul.tipo_rehab = 'P'
----------------------------------------- vResultado = 1 significa que venció el plazo

                                  If plegajo IS NULL Then
		

				RETURN vUnidadAcademica, vCarrera, vLegajo, vResultado WITH RESUME;

			

		Else 

			RETURN vUnidadAcademica, vCarrera, vLegajo, vResultado ;

		End If;



	END FOREACH;

END;

END PROCEDURE;
                                                                                     
