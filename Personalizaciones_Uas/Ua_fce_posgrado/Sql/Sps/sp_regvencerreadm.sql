DROP PROCEDURE "dba".sp_regvencerreadm;
CREATE PROCEDURE "dba".sp_regvencerreadm(

	pUnidadAcademica   LIKE sga_alumnos.unidad_academica,

	pCarrera           LIKE sga_alumnos.carrera,

	pLegajo            LIKE sga_alumnos.legajo,

	pFechaBaja         LIKE sga_perdidas_regul.fecha_baja DEFAULT NULL,

	pNroResolBaja      LIKE sga_perdidas_regul.nro_resol_baja DEFAULT NULL)



	RETURNING smallint,          -- Status: 1 bien, -1 error

	          varchar(255);      -- Mensaje



	-- Variables locales

	DEFINE vUnidadAcademica   LIKE sga_alumnos.unidad_academica;

	DEFINE vCarrera           LIKE sga_alumnos.carrera;

	DEFINE vLegajo            LIKE sga_alumnos.legajo;

	DEFINE vAnioRehab         LIKE sga_alumnos.unidad_academica;

	DEFINE vResultado         integer;

	DEFINE vCantidad          integer;



	DEFINE vMotivoVencim      char(1);

	DEFINE vMotivoCumplio     char(1);



	DEFINE vStatus            integer;

	DEFINE vMensaje           varchar(255);



	-- Variables para el manejo de excepciones

	DEFINE SQLErr             integer;

	DEFINE ISAMError          integer;

	DEFINE errorInfo          varchar(76);



	-- Si hay algun error

	ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        

		LET vStatus = -1;

		LET vMensaje = '800385' || ',' || SQLErr || ' - ' || ISAMError || ' - ' || errorInfo|| ' - ' || pUnidadAcademica || ' - ' || pCarrera || ' - ' ||pLegajo  ;

		RETURN vStatus, vMensaje;



--		RAISE EXCEPTION SQLErr, ISAMError, errorInfo;

	END EXCEPTION;

BEGIN

	LET vResultado = 0;

	LET vCantidad = 0;

	LET vMotivoVencim = 'V';

	LET vMotivoCumplio = 'C';

	IF pFechaBaja IS NULL THEN

		LET pFechaBaja = TODAY;

	END IF;



	EXECUTE PROCEDURE b_regcontrolarvenc (pUnidadAcademica, pCarrera, pLegajo)

	   INTO vUnidadAcademica, vCarrera, vLegajo, vResultado;
              
                 --     LET vUnidadAcademica= pUnidadAcademica;
                 --  LET vCarrera= pCarrera;
                --   LET vLegajo= pLegajo;
                  -- LET vResultado= -1;

	-- Busca el año académico y el mayor número de pérdida de regularidad, para insertar la siguiente

	SELECT sga_perdidas_regul.anio_rehab,

	       sga_perdidas_regul.perdida_regul

	  INTO vAnioRehab,

	       vCantidad

	  FROM sga_perdidas_regul

	 WHERE sga_perdidas_regul.unidad_academica = vUnidadAcademica

	   AND sga_perdidas_regul.carrera = vCarrera

	   AND sga_perdidas_regul.legajo = vLegajo

	   AND sga_perdidas_regul.fecha_vencim_rehab IS NOT NULL;



	IF vCantidad = 0 THEN

		LET vStatus = -1;

		LET vMensaje = '800000,No había ninguna readmisión con fecha de vencimiento para el Alumno ' || pLegajo || ' de la carrera ' || pCarrera;

		RETURN vStatus, vMensaje;

	ELSE

		LET vCantidad = vCantidad + 1;

	END IF;



	-- Si el alumno venció la readmision

	IF vResultado = 1 THEN

		-- Carga una nueva pérdida de regularidad

		-- El trigger de insert se encargará de cambiar el campo regular del alumno y de realizar

		-- las validaciones de integridad (que el alumno sea regular y que no tenga una readmisión

		-- para años académicos posteriores)

		-- Previamente, soluciona la readmisión con vencimiento

		EXECUTE PROCEDURE sp_regSolucVencim(vUnidadAcademica, vCarrera, vLegajo, vMotivoVencim);

		INSERT INTO sga_perdidas_regul

		VALUES ( vUnidadAcademica,

		         vCarrera,

		         vLegajo,

		         vAnioRehab,

		         vCantidad,

		         pFechaBaja,

		         pNroResolBaja,

		         null, null, null, null, null, -- datos de la rehabilitación

		         'N' ); -- contabiliza



		-- Carga una causa (99 - Vencimiento de readmision)

		INSERT INTO sga_det_perd_regul

		VALUES ( vUnidadAcademica,

		         vCarrera,

		         vLegajo,

		         vAnioRehab,

		         vCantidad,

		         99, --causa

		         pFechaBaja,

		         null, null, -- datos de la solución

		         'A' ); -- estado ???????????????????????



		-- Si lo paso a irregular, avisa

		RETURN 1, '800386,' || vLegajo || ',' || vCarrera; -- Se pudo pasar a irregular

	ELIF vResultado = -1 THEN

		-- Si no lo pudo pasar, avisa

		EXECUTE PROCEDURE sp_regSolucVencim(vUnidadAcademica, vCarrera, vLegajo, vMotivoCumplio);

		RETURN 1, '800000, El alumno no posee vencida su readmisión';  -- No se pudo pasar a irregular, no encontró ninguna causa

	ELSE

		-- El proceso de control devulve un valor inesperado

		LET vStatus = -1;

		LET vMensaje = '800000,No había ninguna readmisión con fecha de vencimiento para el Alumno ' || vLegajo || ' de la carrera ' || vCarrera;

		RETURN vStatus, vMensaje;

	END IF;

END;

END PROCEDURE;
                                                            
