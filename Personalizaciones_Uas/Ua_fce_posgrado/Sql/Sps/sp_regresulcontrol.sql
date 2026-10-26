DROP PROCEDURE "dba".sp_regresulcontrol;
CREATE PROCEDURE "dba".sp_regresulcontrol(
    pAnioAcademico LIKE sga_anio_academico.anio_academico,
    pUnidadAcademica LIKE sga_alumnos.unidad_academica,
    pCarrera LIKE sga_alumnos.carrera)

    RETURNING integer,           -- sga_anios_academicos.anio_academico
              varchar(5),        -- sga_alumnos.unidad_academica
              varchar(5),        -- sga_alumnos.carrera
              varchar(15),       -- sga_alumnos.legajo
              integer,           -- sga_causa_perd_reg.causa_perdida_reg
              varchar(10),       -- sga_personas.nro_inscripcion
              varchar(30),       -- sga_personas.apellido
              varchar(30),       -- sga_personas.nombres
              varchar(30),       -- sga_carreras.nombre_reducido
              varchar(40),       -- sga_causa_perd_reg.desc_abreviada
              date,
              varchar(50);       -- Resultado de la corrida de los controles

    -- Variables locales
    DEFINE vUnidadAcademica   LIKE sga_alumnos.unidad_academica;
    DEFINE vCarrera           LIKE sga_alumnos.carrera;
    DEFINE vLegajo            LIKE sga_alumnos.legajo;
    DEFINE vCausa             LIKE sga_causa_perd_reg.causa_perdida_reg;
    DEFINE vNroInscripcion    LIKE sga_personas.nro_inscripcion;
    DEFINE vApellido          LIKE sga_personas.apellido;
    DEFINE vNombres           LIKE sga_personas.nombres;
    DEFINE vCarNomRed         LIKE sga_carreras.nombre_reducido;
    DEFINE vDescrCausa        LIKE sga_causa_perd_reg.desc_abreviada;
    DEFINE vResultado         varchar(50);

    DEFINE fechaIngreso	date;
    DEFINE vfechaVto	date;
    DEFINE vcduracioncarr	integer;

    -- Variables para el manejo de excepciones
    DEFINE SQLErr             integer;
    DEFINE ISAMError          integer;
    DEFINE errorInfo          varchar(76);

    -- Si hay algun error
    ON EXCEPTION SET SQLErr, ISAMError, errorInfo
        RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
    END EXCEPTION;
BEGIN
    -- Busca el nombre de la carrera
    SELECT nombre_reducido
      INTO vCarNomRed
      FROM sga_carreras
     WHERE carrera = pCarrera;

    LET vResultado = 0;

    FOREACH
        -- Lee los alumnos de la carrera a los que debe controlar
        EXECUTE PROCEDURE b_regControlar(pAnioAcademico, pUnidadAcademica, pCarrera)
           INTO vUnidadAcademica,
                vCarrera,
                vLegajo,
                vCausa

        SELECT sga_personas.nro_inscripcion,
               sga_personas.apellido,
               sga_personas.nombres,
               sga_causa_perd_reg.desc_abreviada
          INTO vNroInscripcion,
               vApellido,
               vNombres,
               vDescrCausa
          FROM sga_alumnos,
               sga_personas,
               sga_causa_perd_reg
         WHERE sga_alumnos.unidad_academica = vUnidadAcademica
           AND sga_alumnos.carrera = vCarrera
           AND sga_alumnos.legajo = vLegajo
           AND sga_alumnos.unidad_academica = sga_personas.unidad_academica
           AND sga_alumnos.nro_inscripcion = sga_personas.nro_inscripcion
           AND sga_causa_perd_reg.causa_perdida_reg = vCausa;

	--------------------------------------------------
       IF vCausa = '82100' THEN	
              SELECT MDY(4, 1, MAX(anio_academico)) into fechaIngreso
	FROM sga_alumnos a
		JOIN sga_carrera_aspira ca
			JOIN sga_periodo_insc per
			ON ca.periodo_inscripcio = per.periodo_inscripcio
		  ON a.nro_inscripcion = ca.nro_inscripcion
			AND a.carrera = ca.carrera
	WHERE a.carrera = vCarrera
		and a.legajo = vLegajo; 
            SELECT  sga_planes.duracion_numerica
                  INTO  vcduracioncarr
                  FROM sga_planes
                  WHERE sga_planes.unidad_academica = pUnidadAcademica
                  AND sga_planes.carrera = vCarrera
                  AND sga_planes.estado = 'V';

            ---LET vDescrCausa = vDescrCausa || ' - ' ||  DAY(fechaIngreso) || '/ ' || MONTH(fechaIngreso)|| '/ ' || (YEAR(fechaIngreso)+vcduracioncarr);.
            LET vfechaVto = MDY(MONTH(fechaIngreso),DAY(fechaIngreso), YEAR(fechaIngreso)+vcduracioncarr);
     
       END IF; 


       RETURN pAnioAcademico, vUnidadAcademica, vCarrera, vLegajo, vCausa,
               vNroInscripcion, vApellido, vNombres, vCarNomRed, vDescrCausa, vfechaVto, vResultado WITH RESUME;
         

    END FOREACH;
END;
END PROCEDURE;
                                                                                                                 
