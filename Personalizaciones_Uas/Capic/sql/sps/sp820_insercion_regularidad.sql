-- DROP PROCEDURE "dba".sp820_insercion_regularidad;

CREATE PROCEDURE "dba".sp820_insercion_regularidad(
	pTipoDoc 			LIKE sga_personas.tipo_documento,
	pNroDoc 			LIKE sga_personas.nro_documento,
	pMateria	 		LIKE sga_materias.materia,
	pCarrera	 		LIKE sga_alumnos.carrera,
	pUADestino	 		LIKE sga_personas.unidad_academica,
	pCondicionRegul		LIKE sga_det_acta_curs.resultado,
	pFechaRegul			LIKE sga_det_acta_curs.fecha_regularidad,
	pFechaFinRegul		LIKE sga_det_acta_curs.fin_vigencia_regul,
	pActaExt			LIKE sga_equiv_notasext.acta
	)

	RETURNING 
		INT,			-- Código de Error
		VARCHAR(100);	-- Mensade de error

-- Declaraciones de variables
DEFINE vcLegajo 	LIKE sga_alumnos.legajo;
DEFINE vcResol  	LIKE sga_equiv_resol.nro_resolucion;
DEFINE vcNroEquiv	LIKE sga_equiv_operac.operacion_equiv;
DEFINE vcEquival	LIKE sga_equiv_otorgada.equivalencia;
DEFINE vcUAOrigen	LIKE sga_alumnos.unidad_academica;
DEFINE vcVersion	LIKE sga_versiones_plan.version;
DEFINE vcPlan		LIKE sga_alumnos.plan;
DEFINE vcInstit		LIKE sga_instituciones.institucion;
DEFINE iStatus		INT;
DEFINE iMsj			VARCHAR(100);

-- Seteo de variables
LET vcLegajo	= NULL;
LET vcResol		= "Equiv Capic";
LET vcNroEquiv	= NULL;
LET vcEquival	= NULL;
LET vcVersion	= NULL;
LET vcUAOrigen	= NULL;
LET vcPlan		= NULL;
LET vcInstit	= NULL;
LET iStatus		= 0;
LET iMsj		= NULL;

-- Cuerpo del programa
-- Busco los datos del alumno con el tipo y nro de documento pasado como parámetro
SELECT alu.unidad_academica, alu.legajo, alu.plan
	INTO vcUAOrigen, vcLegajo, vcPlan
	FROM sga_alumnos alu, sga_personas per
	WHERE 	per.tipo_documento  = pTipoDoc
	AND 	per.nro_documento   = pNroDoc
	AND		per.nro_inscripcion = alu.nro_inscripcion
	AND 	alu.carrera         = pCarrera;
	
IF vcLegajo IS NULL THEN
	LET iStatus	= -1;
	LET iMsj    = "El tipo y nro. de documento no coincide con ninguna persona de la base de datos";
	RETURN iStatus, iMsj;
END IF;

-- Verifico que exista la resolución para otorgar la equivalencia, sino la cargo
IF NOT EXISTS(SELECT nro_resolucion 
				FROM sga_equiv_resol
				WHERE nro_resolucion = vcResol) THEN
					INSERT INTO sga_equiv_resol(nro_resolucion, fecha) VALUES (vcResol, "01/01/2008");
END IF;

-- Cargamos la variable de la institución

SELECT CASE 
		WHEN pUADestino = "FICH" 	THEN 100
		WHEN pUADestino = "FBCB" 	THEN 101
		WHEN pUADestino = "ESS" 	THEN 102
		WHEN pUADestino = "FADU" 	THEN 103
		WHEN pUADestino = "FHUC" 	THEN 104
		WHEN pUADestino = "FCM" 	THEN 105
		WHEN pUADestino = "ISM" 	THEN 106
		WHEN pUADestino = "FCJS" 	THEN 107
		WHEN pUADestino = "FCA" 	THEN 108
		WHEN pUADestino = "FCV" 	THEN 109
		WHEN pUADestino = "FCE" 	THEN 110
		WHEN pUADestino = "FIQ" 	THEN 111
	END
	INTO vcInstit
	FROM sga_personas
	WHERE 	tipo_documento  = pTipoDoc
	AND 	nro_documento   = pNroDoc;

IF NOT EXISTS(SELECT institucion
				FROM sga_instituciones
				WHERE institucion = vcInstit) THEN
			LET iStatus = -2;
			LET iMsj 	= "No se encuentra definida la institución externa";
			RETURN iStatus, iMsj;
END IF;

-- Verifico si la equivalencia no fue cargada anteriormente... En caso de que ya se haya cargado, no se carga y se termina el procedimiento...
IF EXISTS(SELECT equivalencia
				FROM sga_equiv_otorgada
				WHERE carrera = pCarrera
				AND legajo = vcLegajo
				AND materia = pMateria
				AND alcance = "P"
				AND vencimiento > TODAY) THEN
			LET iStatus = -2;
			LET iMsj 	= "La equivalencia ya se encuentra cargada.";
			RETURN iStatus, iMsj;
END IF;

-- Por último se hacen los insert correspondientes de la equivalencia
INSERT INTO sga_equiv_operac(fecha, fecha_cierre, nro_resolucion, origen, tipo_equiv, matriz_oficial, aplic_automatica, institucion, version, nro_ultima_copia, estado)
			VALUES (TODAY, TODAY, vcResol, "E", "N", "N", "N", vcInstit, 1, 0, "C");

-- Recupero el nro de equivalencia otorgado por el serial
SELECT MAX(operacion_equiv)
	INTO vcNroEquiv
	FROM sga_equiv_operac;

SELECT COUNT(*)
	INTO vcVersion
	FROM sga_versiones_plan
	WHERE carrera = pCarrera
	AND plan = vcPlan
	AND unidad_academica = vcUAOrigen;
	
INSERT INTO sga_equiv_otorgada(operacion_equiv, unidad_academica, carrera, legajo, materia, fecha, alcance, resultado, vencimiento, plan, version, rectificado, estado)
			VALUES (vcNroEquiv, vcUAOrigen, pCarrera, vcLegajo, pMateria, pFechaRegul, "P", pCondicionRegul, pFechaFinRegul, vcPlan, vcVersion, "N", "A");

SELECT MAX(equivalencia)
	INTO vcEquival
	FROM sga_equiv_otorgada;			
			
INSERT INTO sga_equiv_notasext(equivalencia, orden, materia_externa, fecha, nota, libro, acta, folio)
			VALUES (vcEquival, 1, pMateria, TODAY, null, null, pActaExt, null);
			
LET iStatus	= 0;
LET iMsj	= "Se insertó correctamente la equivalencia de regularidad";
RETURN iStatus, iMsj;
			
END PROCEDURE;