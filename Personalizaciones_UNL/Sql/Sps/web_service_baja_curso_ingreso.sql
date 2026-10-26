CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_ser_baj_curso_ingreso') THEN
		DROP PROCEDURE web_ser_baj_curso_ingreso;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *************** COMIENZO DEL PROCEDURE web_ser_ins_curso_ingreso ***************
-- SP que genera una baja de una nota de un curso de Ingreso
-- Causas de no baja: no tiene generado el legajo.
-- ************************************************************************
-- DROP PROCEDURE "dba".web_ser_baj_curso_ingreso;

CREATE PROCEDURE "dba".web_ser_baj_curso_ingreso (pUnidadAcademica LIKE sga_unidades_acad.unidad_academica,
	pCarrera LIKE sga_carreras.carrera,
	pPaisDocumento LIKE sga_personas.pais_documento,
	pTipoDocumento LIKE sga_personas.tipo_documento,
	pNroDocumento LIKE sga_personas.nro_documento,
	pMateria varchar(5)) 

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
DEFINE l_equivalencia    like sga_equiv_otorgada.equivalencia;

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
LET l_equivalencia = NULL;

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

		-- En este caso se debe dar de baja la nota de ingreso, si la tenia aprobada. Ya que de ingreso se pasará la última nota valida registrada para el alumno a esa materia.
		--BEGIN WORK;
		LET vcMsg = 'No existe nota del curso de ingreso cargada. Legajo: ';
		LET iStatus = -2;
		FOREACH Select equivalencia INTO l_equivalencia from sga_equiv_otorgada 
			WHERE carrera = pcarrera 
				AND plan = vplan 
				AND materia = vmateria 
				AND legajo = vlegajo
				AND alcance = 'T'
				AND resultado = 'A'
			DELETE from sga_equiv_equiv WHERE equivalencia = l_equivalencia;
			DELETE from sga_mov_equiv WHERE equivalencia = l_equivalencia; 
			DELETE from sga_equiv_notasext WHERE equivalencia = l_equivalencia; 
			DELETE from sga_equiv_relacion WHERE equivalencia = l_equivalencia;
			DELETE FROM sga_equiv_otorgada WHERE equivalencia = l_equivalencia;


			LET vcMsg = 'OK - La nota del curso de Ingreso se elimina por ser un reprobado. Legajo: ';
			LET iStatus = 0;

		END FOREACH ;
		--COMMIT WORK;

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


LET vcMsg = vcMsg  || vlegajo;
RETURN iStatus, vcMsg;

END PROCEDURE;

-- EJECUCION DEL SP -------------
-- execute procedure "dba".web_ser_baj_curso_ingreso ('FADU', '1', '54', 0, '36000514', '11');  -- OJO: mi cliente sql esta seteado DMY por eso no falla con estos parametros de fecha y desde el WS con los mismos si falla.
-- execute procedure "dba".web_ser_baj_curso_ingreso ('FADU', '1', '54', 0, '36000514', '2');  -- OJO: mi cliente sql esta seteado DMY por eso no falla con estos parametros de fecha y desde el WS con los mismos si falla.




-- select * from u820_cursos_ing;

-- *****************************************************************************
-- Permisos del procedimiento "dba".web_ser_baj_curso_ingreso 
-- *****************************************************************************
revoke execute on "dba".web_ser_baj_curso_ingreso from public;
grant execute on "dba".web_ser_baj_curso_ingreso to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_ser_baj_curso_ingreso to internet; -- Rol de usuario de Internet


