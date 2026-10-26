DROP PROCEDURE "dba".pu_regaluacontrol;
CREATE PROCEDURE "dba".pu_regaluacontrol(
	pUnidadAcademica   LIKE sga_materias.unidad_academica,
	pCarrera           LIKE sga_alumnos.carrera,
	pLegajo            LIKE sga_alumnos.legajo,
	pRegular           LIKE sga_alumnos.regular,
	pAnioAcademico     LIKE sga_anio_academico.anio_academico )

	RETURNING smallint;

	-- Variables para el manejo de excepciones
	DEFINE SQLErr             integer;
	DEFINE ISAMError          integer;
	DEFINE errorInfo          varchar(76);

	-- Si hay algun error
	ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
		RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
	END EXCEPTION;
BEGIN
	        -- No toma en cuenta a los prorrogados para años posteriores al que se está controlando
                                IF EXISTS (SELECT ''
		             FROM sga_perdidas_regul
		            WHERE sga_perdidas_regul.unidad_academica = pUnidadAcademica
		              AND sga_perdidas_regul.carrera = pCarrera
		              AND sga_perdidas_regul.legajo = pLegajo
		              AND sga_perdidas_regul.anio_rehab > pAnioAcademico
		              AND sga_perdidas_regul.tipo_rehab = 'P') THEN
			RETURN -1;
		END IF;
	
                             

                   RETURN 1;

END;
END PROCEDURE;
                                                                                                                                                                                                                                         
