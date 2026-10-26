select * from sga_periodos_lect 

execute procedure sp820_obtener_regularidades('2009','1° cuatrimestre','FBCB')

select * from sga_cursadas
where comision in ('4411','4412')

select * from sga_actas_cursado
where acta = '2095'

select * from  u820_capic_com



-- Solo recupera los resultados de las regularidades de actas CERRADAS.
--DROP PROCEDURE "dba".sp820_obtener_regularidades;

CREATE PROCEDURE "dba".sp820_obtener_regularidades(
	pAnioAcademico LIKE sga_periodo_insc.anio_academico,
	pPeriodoLectivo LIKE sga_periodos_lect.periodo_lectivo,
	pUA_Origen LIKE sga_unidades_acad.unidad_academica)

	Returning date, 		-- fecha de regularidad
		date,		-- fin de regularidad
		Int,		-- Tipo documento
		int,	-- Numero documento
		int,		-- comison de capic
		Int,		-- condicion de regularidad
		char(1),		-- Resultado
		varchar(5),	-- Nota
		int;		-- Acta de regularidad
--		int,		-- Codigo de Error
--		varchar(100);	-- Mensade de error

DEFINE aunidad_academica LIKE sga_unidades_acad.unidad_academica;


DEFINE afecha_regul LIKE sga_det_acta_curs.fecha_regularidad;
DEFINE afin_fecha_regul LIKE sga_det_acta_curs.fin_vigencia_regul;
DEFINE atipo_docu LIKE sga_personas.tipo_documento;
DEFINE anro_documento LIKE sga_personas.nro_documento;


DEFINE acomision_capic LIKE sga_comisiones.comision;
DEFINE acomision LIKE sga_comisiones.comision;


DEFINE acond_regul LIKE sga_det_acta_curs.cond_regularidad;
DEFINE aresultado LIKE sga_det_acta_curs.resultado;
DEFINE anota LIKE sga_det_acta_curs.nota;
DEFINE aacta LIKE sga_actas_cursado.acta;


DEFINE alegajo LIKE sga_alumnos.legajo;
DEFINE acarrera LIKE sga_carreras.carrera;
DEFINE anro_inscripcion LIKE sga_personas.nro_inscripcion;


BEGIN

ON EXCEPTION IN (-206)
	END EXCEPTION WITH RESUME;
	--borro la tabla temporal
	DROP TABLE comision_temp;
END


BEGIN

--DEFINE iStatus INT;
--DEFINE iMens_err varchar(100);
--LET iStatus		= 0;
--LET iMens_err		= " ";


LET aunidad_academica	= NULL;
LET afecha_regul		= NULL;
LET afin_fecha_regul	= NULL;
LET atipo_docu		= NULL; 
LET anro_documento	= NULL; 
LET acomision_capic	= NULL; 
LET acomision		= NULL; 
LET acond_regul		= NULL; 
LET aresultado		= NULL; 
LET anota		= NULL; 
LET alegajo		= NULL;
LET acarrera		= NULL; 
LET anro_inscripcion	= NULL; 
LET aacta		= NULL; 



-- Obtengo la Unidad Academica en la que nos encontramos.
SELECT unidad_academica INTO aunidad_academica 
	FROM sga_valor_inicial;


-- Obtengo la carrera de integración de la unidad academica
SELECT carrera INTO acarrera
	FROM sga_carreras_grupo
		WHERE grupo_carrera = 'i0001';


-- Obtenemos en una tabla temporal todas las comisiones en guarani que corresponden la UA de origen.
SELECT co.comision, ca.capic_comision 
	FROM sga_comisiones co, u820_capic_com ca
		WHERE co.comision = ca.comision
		AND ca.unidad_academica = pUA_Origen
		AND co.anio_academico = pAnioAcademico
		AND co.periodo_lectivo = pPeriodoLectivo
			INTO TEMP comision_temp;


-- Verifica que la comision para la unidad academica especificada este creada en la UA de destino
-- Si no estan creada, devuelve el mensaje de error y corta la ejecucion.

IF NOT EXISTS (SELECT comision FROM comision_temp) THEN
	--LET iStatus = -1;	-- No existen comisiones para la unidad academica especificada
	--LET iMens_err = "No existen comisiones para la unidad academica especificada";

	DROP TABLE comision_temp;
	RAISE EXCEPTION -746,0,'No existen comisiones para la unidad academica especificada';

	--RETURN	afecha_regul, afin_fecha_regul, atipo_docu, anro_documento, acomision_capic, acond_regul, aresultado, anota, iStatus, iMens_err;
END IF;
	

-- Verifica que halla inscriptos en las comisiones de capic
-- Si no hay, devuelve el mensaje de error y corta la ejecucion.

IF NOT EXISTS (SELECT legajo FROM sga_insc_cursadas WHERE comision IN (SELECT comision FROM comision_temp)) 
	THEN
	--LET iStatus = -2;	-- No hay inscriptos para las comisiones de la UA especificada
	--LET iMens_err = "No hay inscriptos para las comisiones de la UA especificada";

	DROP TABLE comision_temp;
	RAISE EXCEPTION -746,0,'No hay inscriptos para las comisiones de la UA especificada';

	--RETURN	afecha_regul, afin_fecha_regul, atipo_docu, anro_documento, acomision_capic, acond_regul, aresultado, anota, iStatus, iMens_err;
END IF;


-- Por ultimo verifica si existe alguna regularidad cargada para las comisiones de capic
-- De no existir devuelve el mensaje de error y corta la ejecucion.

--IF NOT EXISTS (SELECT cu.fecha_regularidad FROM sga_cursadas cu, comision_temp te WHERE cu.comision = te.comision) 
--	THEN
--	LET iStatus = -3;	-- No hay regularidades cargadas
--	LET iMens_err = "No hay regularidades cargadas";
--	DROP TABLE comision_temp;
--	RETURN	afecha_regul, afin_fecha_regul, atipo_docu, anro_documento, acomision_capic, acond_regul, aresultado, anota, iStatus, iMens_err;
--END IF;

		
FOREACH


SELECT cu.fecha_regularidad, cu.fin_vigencia_regul, pe.tipo_documento, pe.nro_documento, te.capic_comision, cu.cond_regularidad, cu.resultado, cu.nota, cu.acta_regular 	
	INTO afecha_regul, afin_fecha_regul, atipo_docu, anro_documento, acomision_capic, acond_regul, aresultado, anota, aacta
		FROM sga_cursadas cu, comision_temp te, sga_alumnos alu, sga_personas pe, sga_actas_cursado ac 
			WHERE cu.comision = te.comision
			AND cu.legajo = alu.legajo
			AND alu.nro_inscripcion = pe.nro_inscripcion
			AND cu. carrera = acarrera
			AND alu.carrera = acarrera
			AND te.comision = ac.comision
			AND ac.estado = 'C'  -- Para que recupere unicamente las regularidades de actas que estan cerradas.
			

RETURN	afecha_regul, 
	afin_fecha_regul, 
	atipo_docu, 
	anro_documento, 
	acomision_capic, 
	acond_regul, 
	aresultado, 
	anota,
	aacta		WITH RESUME;
--	iStatus,
--	iMens_err		WITH RESUME;

END FOREACH;

DROP TABLE comision_temp;

END;

END PROCEDURE;
	
