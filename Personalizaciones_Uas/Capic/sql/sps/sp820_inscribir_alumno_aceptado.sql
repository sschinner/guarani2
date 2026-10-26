DROP PROCEDURE "dba".sp820_inscribir_alumno_aceptado;

CREATE PROCEDURE "dba".sp820_inscribir_alumno_aceptado(
	pTipoDocumento LIKE sga_personas.tipo_documento,
	pNroDocumento LIKE sga_personas.nro_documento,
	pComisionCapic LIKE sga_comisiones.comision,
    pUAcadOrigen LIKE sga_unidades_acad.unidad_academica
	)
	Returning INT;

    DEFINE aunidad_academica LIKE sga_datos_censales.unidad_academica;
    DEFINE aCarrera LIKE sga_carreras.carrera;
    DEFINE aLegajo LIKE sga_alumnos.legajo;
    DEFINE aComision LIKE sga_comisiones.comision;
    DEFINE aPlan LIKE sga_planes.plan;
    DEFINE aVersion LIKE sga_versiones_plan.version;
    
    DEFINE iStatus		int;

    LET iStatus = 0;

-- Obtengo la Unidad Academica en la que nos encontramos.
    SELECT unidad_academica INTO aunidad_academica 
        FROM sga_valor_inicial;

-- Obtengo la carrera de integración de la unidad academica
    SELECT carrera INTO aCarrera
    	FROM sga_carreras_grupo
    		WHERE grupo_carrera = 'i0001';

-- Obtengo el legajo del alumno
    SELECT UNIQUE(legajo) INTO aLegajo
        FROM sga_alumnos
            WHERE nro_inscripcion = ( SELECT nro_inscripcion FROM sga_personas
                                        WHERE tipo_documento = pTipoDocumento
                                        AND nro_documento = pNroDocumento)
            AND unidad_academica = aunidad_academica;

-- Obtengo la comision a la que debe inscribir
    SELECT comision INTO aComision
        FROM u820_capic_com
            WHERE unidad_academica = pUAcadOrigen
            AND capic_comision = pComisionCapic;

-- obtengo el plan y version del alumno
    EXECUTE PROCEDURE sp_plan_de_alumno( aunidad_academica, aCarrera, aLegajo, TODAY ) INTO aPlan, aVersion ;

-- Verifico que el alumno no este cargado previamente en la comision.
    IF NOT EXISTS (SELECT legajo FROM sga_insc_cursadas
                  		WHERE unidad_academica = aunidad_academica
    	                AND carrera = aCarrera
                        AND legajo = aLegajo
                        AND comision = aComision
            		) THEN
                    
	INSERT INTO sga_insc_cursadas (unidad_academica, carrera, legajo, comision, fecha_inscripcion, calidad_insc, plan, version, nro_transaccion, interfaz, estado) 
		VALUES (aunidad_academica,
                aCarrera,
                aLegajo,
                aComision,
                CURRENT YEAR TO SECOND,
                "R",
                aPlan,
                aVersion,
                "Insc. auto. Capic",
                "1",
                "A");
    ELSE
        LET iStatus = -1; 
    END IF; 

    RETURN iStatus;

END PROCEDURE;
