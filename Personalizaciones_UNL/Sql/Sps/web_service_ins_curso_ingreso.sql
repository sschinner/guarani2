CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_ser_ins_curso_ingreso') THEN
		DROP PROCEDURE web_ser_ins_curso_ingreso;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *************** COMIENZO DEL PROCEDURE web_ser_ins_curso_ingreso ***************
-- SP que genera una insercion de una nota de un curso de Ingreso
-- Causas de no inclusion: todas las materias desaprobadas; no tiene generado el legajo.
-- ************************************************************************
-- DROP PROCEDURE "dba".web_ser_ins_curso_ingreso;

CREATE PROCEDURE "dba".web_ser_ins_curso_ingreso (pUnidadAcademica LIKE sga_unidades_acad.unidad_academica,
	pCarrera LIKE sga_carreras.carrera,
	pPaisDocumento LIKE sga_personas.pais_documento,
	pTipoDocumento LIKE sga_personas.tipo_documento,
	pNroDocumento LIKE sga_personas.nro_documento,
	pMateria varchar(5),
	pTipoExamen integer,
	pFechaExamen LIKE sga_equiv_otorgada.fecha,
	pNota varchar(5)) 

RETURNING INT,VARCHAR(255);

DEFINE vcont int;
DEFINE voperc int;

DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(80);
DEFINE vcUserError		varchar(60);
DEFINE iStatus			int;
DEFINE vcMsg			varchar(100);

DEFINE vlegajo varchar(20);
DEFINE vplan varchar(20);
DEFINE vversion  varchar(5);
DEFINE iescala_nota integer;
DEFINE vmateria  varchar(5);
DEFINE vresolucion varchar (15);
DEFINE vforma_aprobacion varchar (30);

DEFINE vioperacion_equiv LIKE sga_equiv_otorgada.operacion_equiv;
DEFINE vcequivalencia LIKE sga_equiv_otorgada.equivalencia;
DEFINE vctipo_equiv LIKE sga_equiv_operac.tipo_equiv;
DEFINE vioperacion_original LIKE sga_equiv_otorgada.equivalencia;
DEFINE vcequiv_nota LIKE sga_equiv_otorgada.nota;
DEFINE vcequiv_fecha LIKE sga_equiv_otorgada.fecha;


  -- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info;
      -- ROLLBACK WORK;
      RETURN iStatus, vcMsg;
END EXCEPTION;
--------------------------------------------------

LET error_info = NULL;
LET sql_err = 0;
LET isam_err = 0;
LET iStatus = 0;
LET vcMsg = 'OK';
LET vlegajo = NULL;
LET vplan = NULL;
LET vresolucion = 'ORD. 1/2000';
LET vmateria = NULL;
LET voperc = NULL;
LET vcont = NULL;
LET vversion = NULL;

LET vioperacion_equiv = NULL;
LET vcequivalencia = NULL;
LET vctipo_equiv = NULL;
LET vioperacion_original = NULL;
LET vcequiv_nota = NULL;
LET vcequiv_fecha = NULL;
LET vforma_aprobacion = NULL;


IF NOT EXISTS (select '*' from sga_equiv_resol where nro_resolucion = vresolucion) THEN
	INSERT INTO sga_equiv_resol values (vresolucion, today, '405811', null);
END IF;

LET vcont = (select max (equivalencia) from sga_equiv_otorgada);
IF vcont IS null THEN
	LET vcont = 1;
ELSE
	LET vcont = vcont + 1;
END IF;

-- No deberia existir operac, si no hay equivalencias
LET voperc = (select max (operacion_equiv) from sga_equiv_operac);
IF voperc IS null THEN
	LET voperc = 1;
ELSE
	LET voperc = voperc + 1;
END IF;

SELECT a.legajo, a.plan, pl.version_actual
	INTO vlegajo, vplan, vversion
FROM sga_personas p 
	JOIN sga_alumnos a
	  ON p.nro_inscripcion = a.nro_inscripcion
	JOIN sga_planes pl
	  ON a.carrera = pl.carrera
		AND a.plan = pl.plan
WHERE p.nro_documento = pNroDocumento
	AND p.tipo_documento = pTipoDocumento
	AND p.pais_documento = pPaisDocumento
	AND a.carrera = pCarrera;

IF vlegajo IS NOT null THEN -- 'No existe o no tiene generado legajo el aspirante en la carrera'

	SELECT materia INTO vmateria -- Selecciona la materia codigo Guarani correspondiente
	FROM u820_cursos_ing
	WHERE unidad_academica = pUnidadAcademica
	AND carrera = pCarrera
	AND plan = vplan
	AND curso_ingreso = pMateria;


	IF vmateria IS NOT NULL THEN

		IF (pTipoExamen = 2 OR pNota * 1 >= 6) THEN -- hay que cargar o rectificar una aprobada

			IF pNota * 1 <= 5 THEN -- Si viene un exceptuado con una nota de reprobado, migro null
				LET pNota = NULL;
			ELSE
				LET pNota = replace(pNota, ',', '.');
			END IF;

			LET iescala_nota = (SELECT t.escala_examen
					FROM sga_materias m
						join sga_tipos_materia t
						  on m.tipo_de_materia = t.tipo_de_materia
					WHERE m.materia = vmateria
						AND m.unidad_academica = pUnidadAcademica);

			-- Obtener forma de aprobación
			SELECT forma_aprobacion INTO vforma_aprobacion
					FROM vw820_hist_academ 
					WHERE unidad_academica = pUnidadAcademica
						AND carrera = pCarrera
						AND legajo = vlegajo
						AND materia = vMateria
						AND resultado = 'A';

			IF vforma_aprobacion IS NULL THEN --'El alumno no tiene el curso aprobado'

				--BEGIN WORK;
				INSERT INTO sga_equiv_operac values (voperc, today, today, vresolucion, 'I', 'N', '', 'Rectorado', 'N', 'N', pUnidadAcademica, null, '', '', 1, 1, 1, 'C');
				INSERT INTO sga_equiv_otorgada VALUES ( vcont, voperc, pUnidadAcademica, pCarrera, vlegajo, vMateria, pFechaExamen, 'T', 'A', iescala_nota, pNota , null, '', vplan , vversion , 'N', 'A');
				--COMMIT WORK;
				LET vcMsg = 'Se insertó la nota del curso para el legajo: ' || vlegajo;			
			ELSE

				IF vforma_aprobacion = 'Equivalencia' THEN

					SELECT oper.operacion_equiv, equiv.equivalencia, oper.tipo_equiv, oper.operacion_original, equiv.nota, equiv.fecha INTO vioperacion_equiv, vcequivalencia, vctipo_equiv, vioperacion_original, vcequiv_nota, vcequiv_fecha
					FROM sga_equiv_otorgada equiv
						join sga_equiv_operac oper
							on equiv.operacion_equiv = oper.operacion_equiv
					WHERE equiv.unidad_academica = pUnidadAcademica
						AND equiv.carrera = pCarrera
						AND equiv.legajo = vlegajo
						AND equiv.materia = vMateria
						AND equiv.resultado = 'A'
						AND equiv.rectificado = 'N'
                                                AND equiv.estado = 'A'; -- descarto invalidaciones

					IF (vcequiv_nota <> pnota OR vcequiv_fecha <> pFechaExamen) THEN
						IF vctipo_equiv = 'N' THEN

							INSERT INTO sga_equiv_operac values (voperc, today, today, vresolucion, 'I', 'R', '', 'Rectorado', 'N', 'N', pUnidadAcademica, null, '', vioperacion_equiv, 1, 1, 1, 'C');
						ELSE
							INSERT INTO sga_equiv_operac values (voperc, today, today, vresolucion, 'I', 'R', '', 'Rectorado', 'N', 'N', pUnidadAcademica, null, '', vioperacion_original, 1, 1, 1, 'C');
						END IF;
						UPDATE sga_equiv_otorgada set rectificado = 'S' where equivalencia = vcequivalencia;
						INSERT INTO sga_equiv_otorgada VALUES ( vcont, voperc, pUnidadAcademica, pCarrera, vlegajo, vMateria, pFechaExamen, 'T', 'A', iescala_nota, pNota , null, '', vplan , vversion , 'N', 'A');
						-- Se reasignan equivalencias equivalentes
						UPDATE sga_equiv_equiv set equivalencia = vcont where equivalencia = vcequivalencia;

						LET vcMsg = 'Se rectificó la nota del curso para el legajo: ' || vlegajo;
					ELSE
						LET vcMsg = 'La nota del curso de Ingreso no se rectifica por ser igual en fecha y nota a la del legajo: '  || vlegajo;
						LET iStatus = -1;
						RETURN iStatus, vcMsg;
					END IF;	
				ELSE
					LET vcMsg = 'La nota del curso de Ingreso no se rectifica por encontrarse en acta de exámen/promoción'  || vlegajo;
					LET iStatus = -1;
					RETURN iStatus, vcMsg;
				END IF;	


			END IF;
		ELSE
			LET vcMsg = 'La nota del curso de Ingreso no se migra por ser un reprobado. Legajo: '  || vlegajo;
			LET iStatus = -2;
			RETURN iStatus, vcMsg;
		END IF;
	ELSE
		LET vcMsg = 'No existe el curso de Ingreso en la carrera en Guaraní';
		LET iStatus = -3;
		RETURN iStatus, vcMsg;
	END IF;

ELSE
	LET vcMsg = 'No existe o no tiene generado legajo el aspirante en la carrera';
	LET iStatus = -4;
	RETURN iStatus, vcMsg;
END IF;


LET vcMsg = 'OK - ' || vcMsg;
RETURN iStatus, vcMsg;

END PROCEDURE;

-- EJECUCION DEL SP -------------
-- execute procedure "dba".web_ser_ins_curso_ingreso ('FADU', '1', '54', 0, '36000514', '11', 1, '03/18/2017', 8);  -- OJO: mi cliente sql esta seteado DMY por eso no falla con estos parametros de fecha y desde el WS con los mismos si falla.
-- execute procedure "dba".web_ser_ins_curso_ingreso ('FADU', '1', '54', 0, '36000514', '2', 1, '03/18/2011', '');  -- OJO: mi cliente sql esta seteado DMY por eso no falla con estos parametros de fecha y desde el WS con los mismos si falla.


-- select * from u820_cursos_ing;

-- *****************************************************************************
-- Permisos del procedimiento "dba".web_ser_ins_curso_ingreso 
-- *****************************************************************************
revoke execute on "dba".web_ser_ins_curso_ingreso from public;
grant execute on "dba".web_ser_ins_curso_ingreso to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_ser_ins_curso_ingreso to internet; -- Rol de usuario de Internet

