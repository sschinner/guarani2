drop PROCEDURE sp_cerraractarectr;
CREATE PROCEDURE sp_cerraractarectr (
p_unidad_academica  LIKE sga_actas_cursado.unidad_academica,
p_acta LIKE sga_actas_cursado.acta,
p_origen LIKE sga_mod_acta_curs.origen,
p_autorizador LIKE sga_mod_acta_curs.autorizador)

DEFINE sql_err,isam_err int;
DEFINE error_info varchar(70);
DEFINE v_nro_modificacion INTEGER;
DEFINE v_materia LIKE sga_comisiones.materia;
DEFINE v_comision LIKE sga_actas_cursado.comision;
DEFINE v_carrera LIKE sga_det_acta_curs.carrera;
DEFINE v_legajo LIKE sga_det_acta_curs.legajo;
DEFINE v_plan, vcPlanReg LIKE sga_det_acta_curs.plan;
DEFINE v_version, vcVersionReg LIKE sga_det_acta_curs.version;
DEFINE v_folio   LIKE sga_det_acta_curs.folio;
DEFINE v_renglon LIKE sga_det_acta_curs.renglon;
DEFINE v_fin_vig_regul LIKE sga_det_acta_curs.fin_vigencia_regul;
DEFINE iCnt	SMALLINT;
DEFINE v_estado LIKE sga_actas_cursado.estado;
DEFINE v_version_nueva LIKE sga_actas_cursado.version;
DEFINE v_a_fecha, v_n_fecha LIKE sga_det_acta_curs.fecha_regularidad;
DEFINE v_a_cond_regular, v_n_cond_regular LIKE sga_det_acta_curs.cond_regularidad;
DEFINE vcResultadoCurs, v_a_resultado, v_n_resultado, v_resultado, v_resultado_nota,v_resultado_ant  LIKE sga_det_acta_curs.resultado;
DEFINE v_a_nota, v_n_nota LIKE sga_det_acta_curs.nota;
DEFINE v_a_pct_asistencia, v_n_pct_asistencia	LIKE  sga_det_acta_curs.pct_asistencia;
DEFINE vs_asentar_nota char(1);
DEFINE v_registra_cursada like sga_param_sistema.valor;

ON EXCEPTION SET sql_err, isam_err, error_info
    -- Error. no realizo nada
    RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;

BEGIN

--==================verifica que el acta este impresa con su version y version impresa===========================
-- este control se pasó a uo puesto que falla en cierre de rectificativa

--     IF EXISTS ( SELECT '' FROM sga_actas_cursado
--                           WHERE sga_actas_cursado.unidad_academica = p_unidad_academica
--                                 AND sga_actas_cursado.acta = p_acta 
--            AND sga_actas_cursado.version_impresa <> sga_actas_cursado.version ) THEN
--
--                  raise exception  -746, 0, 'Para cerrar el acta de regularidad, debe estar abierta y con la ultima version impresa.';
--    END IF;
--=================================================================================================



  SELECT version, estado, comision INTO v_version_nueva, v_estado, v_comision
	FROM sga_actas_cursado
	WHERE unidad_academica = p_unidad_academica
	 AND  acta = p_acta;
  IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
	raise exception -746,0,'No existe el Acta de Regularidad N°: ' || p_acta;
  ELSE
    IF v_estado <> 'C' THEN
	raise exception -746,0,'El Acta de Regularidad N°: ' || p_acta || ' debe estar Cerrado.';

    END IF;
       IF v_version_nueva IS NULL OR v_version_nueva <= 0 THEN
          LET v_version_nueva = 1;
       ELSE
          LET v_version_nueva = v_version_nueva + 1;
       END IF;
  END IF;

----- 03/02/2013 busca materia de la comision

   SELECT materia
	 INTO v_materia
	FROM sga_comisiones
	WHERE comision = v_comision;
     IF DBINFO("sqlca.sqlerrd2") <=  0 THEN
	raise exception -746,0,'No se pueden recuperar datos de la comision del acta °: ' || p_acta ;
   END IF;
-----------
-------------------------------------------
-- Verifico que no exista Acta de Promocion o Rectif de Promocion Abierta!!!
IF p_origen = 'R' THEN
  SELECT COUNT(*) INTO iCnt
	FROM sga_actas_promo
	WHERE comision = v_comision
	AND estado = 'A';
   IF iCnt > 0 THEN
	raise exception -746,0,'Debe cerrar antes el Acta de Prom. o Rect de Prom de esta comisión.';
  END IF;
END IF;

 -- Regularidad vale en todas las Carreras.
  LET v_registra_cursada = 'N';
  EXECUTE PROCEDURE sp_param_sistema('regularidad_vale_en_todas_las_carreras') INTO v_registra_cursada;
  IF v_registra_cursada IS NULL OR TRIM(v_registra_cursada) = '' THEN
  	raise exception -746,0,'Error. Falta cargar P. del Sist "regularidad_vale_en_todas_las_carreras"' ;
  END IF;

  LET vs_asentar_nota = NULL;
  -- Controlo si debe o no ingresarse la Nota en el Acta de Regulares
  Execute procedure sp_param_sistema('asentar_notas_actas_regulares') INTO vs_asentar_nota;

-- Recupero los Registros de Cursada Pendiente
BEGIN
  on exception in (-206)
    -- Tabla no existe continuo el proceso
  end exception with resume;
  DROP TABLE tmp_cerrar_rectreg;
END;

LET vcPlanReg = NULL;
LET vcVersionReg = NULL;

 SELECT c.carrera,
       c.legajo,
       NVL(c.folio,d.folio) as folio,

       NVL(c.renglon,  d.renglon) as renglon,
       d.fecha_regularidad,
       d.cond_regularidad,
       d.resultado,
       d.nota,
       d.pct_asistencia,
       c.fecha as rc_fecha,
       c.cond_regularidad as rc_cond_reg,
       c.resultado as rc_resultado,
       c.nota as rc_nota,
       c.pct_asistencia as rc_pct_asistencia
    FROM sga_cambios_curpen as c ,
 	OUTER sga_det_acta_curs as d ,
 	sga_alumnos
   WHERE c.unidad_academica = p_unidad_academica   AND
	 c.acta   =  p_acta  AND
	 c.unidad_academica =  d.unidad_academica    AND
	 c.carrera =  d.carrera  AND
	 c.legajo  =  d.legajo   AND
	 c.acta    =  d.acta   AND
	 sga_alumnos.unidad_academica = c.unidad_academica  AND
 	 sga_alumnos.carrera = c.carrera  AND
	 sga_alumnos.legajo  = c.legajo
     INTO TEMP tmp_cerrar_rectreg WITH NO LOG;


  IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
	raise exception -746,0,'No existen cambios en el Acta de Regulares.';
  ELSE
	-- Recupero el Nro de Modificacion
	execute procedure sp_nromodifrectreg(p_unidad_academica, p_acta) INTO v_nro_modificacion;
	IF v_nro_modificacion <= 0 OR v_nro_modificacion IS NULL THEN
		raise exception -746,0,'Error al generar nro de Modificación de Actas de Regulares.';
	END IF;


  -- Agrego una fila en Modificaciones de Cursadas
  INSERT INTO sga_mod_acta_curs
	(unidad_academica, acta, modificacion, fecha, version_del_acta, origen, autorizador)
	VALUES (p_unidad_academica, p_acta, v_nro_modificacion, today, v_version_nueva, p_origen, p_autorizador);

  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Recupero alumnos de Cambios Pendientes de Actas de Regulares. Ordenados por folio y renglon
  -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  FOREACH SELECT * INTO v_carrera, v_legajo, v_folio, v_renglon,
		v_a_fecha, v_a_cond_regular, v_a_resultado, v_a_nota, v_a_pct_asistencia,
		v_n_fecha, v_n_cond_regular, v_n_resultado, v_n_nota, v_n_pct_asistencia

	FROM tmp_cerrar_rectreg
	ORDER BY folio, renglon

	LET v_resultado = NULL;
	LET v_resultado_nota = NULL;

	IF v_n_cond_regular IS NULL THEN
	     raise exception -746,0,'Error. La Cond. de Reg no puede ser Nula. Pág:' || v_folio || ' Fila: ' || v_renglon ;
	ELSE
	  -- Recupera el resultado que corresponde por la condicion de aprobacion informada
	  EXECUTE PROCEDURE sp_resultado_creg (v_n_cond_regular) INTO v_resultado;
	END IF;

	-- Controlo si debe o no ingresarse la Nota en el Acta de Regulares
	IF (vs_asentar_nota = 'S'  AND v_n_nota IS NOT NULL) THEN
		-- No debe ingresarse la Nota
		LET v_n_nota = NULL;
	ELIF (vs_asentar_nota = 'O' AND v_n_nota IS NULL and v_resultado <> 'U') THEN
	       -- Error. La carga de la Nota es obligatoria
	       raise exception  -746, 0,  'Debe ingresarse la Nota. Folio:' || v_folio || ' Reng:' || v_renglon ;
	END IF;

	IF v_n_nota IS NOT NULL THEN
	  EXECUTE PROCEDURE sp_resultado_nota (v_comision, v_n_nota) INTO v_resultado_nota;

	  IF p_origen = 'R' THEN
		-- Este SP se ejecuta desde el cerrado de Rectif de Actas de Regulares
		-- debo controlar que no existan Promociones.
	  	IF v_resultado_nota = 'P' and v_resultado <> 'P' THEN
		   -- Seteo un A como Aprobado y no una P de Promocionado

		   -- ya que no se puede cargar el estado de Promocionado en Regulares.
		   LET v_resultado_nota = 'A';
		ELIF v_resultado = 'P' THEN
	     	   raise exception -746,0,'Error. El resultado no puede ser "Promovido". Pág:' || v_folio || ' Fila: ' || v_renglon ;
	 	END IF;
	  END IF;

	  -- Si no coincide el resultado que corresponde por la condicion con el que corresponde
	  -- por la nota, sale con un error.
	  IF v_resultado_nota = 'P' AND (v_resultado = 'A' or v_resultado = 'P') Then

		-- Puedo en Actas de Regulares, agregar un Alumno y cargar la Cond
		-- de Reg cuyo Resultado = A y una Nota cuyo resultado es de Promocion!!!
	  ELSE
		-- ERROR
 	  	IF v_resultado <> v_resultado_nota Then
		    raise exception  -746, 0, 'La nota no es compatible con la cond. de aprob. informada. Pág:' || v_folio || ' Fila:' || v_renglon ;
		END IF ;
	  END IF;
	END IF;

	-- Todo OK
	-- Agrego los cambios a Historia de Cambios de Actas de Regulares
	INSERT INTO sga_hist_acta_curs
		(unidad_academica, carrera, legajo, acta, modificacion,
		a_fecha, a_cond_regularidad, a_nota, a_resultado, a_pct_asistencia,
		n_fecha, n_cond_regularidad, n_nota, n_resultado, n_pct_asistencia)
	VALUES (p_unidad_academica, v_carrera, v_legajo, p_acta, v_nro_modificacion,
		v_a_fecha, v_a_cond_regular, v_a_nota, v_a_resultado, v_a_pct_asistencia,
		v_n_fecha, v_n_cond_regular, v_n_nota, v_resultado, v_n_pct_asistencia);


	   -- Debo calcular la Fecha de Fin de Vigencia de Regularidad
	-- 09/11/2012: cambia proc

--	   EXECUTE PROCEDURE SP_FE_FIN_VIG_REG(v_comision, v_n_fecha) INTO v_fin_vig_regul;
--	   IF v_fin_vig_regul IS NULL THEN
--		raise exception -746,0,'Error al calcular la Fecha de fin de vigencia de la Regularidad.' ;
--	   END IF;



  --- Calcula según indicación 05-02-2013
	IF (v_n_cond_regular = 11) THEN
		LET v_fin_vig_regul = MDY(month(v_n_fecha),day(v_n_fecha),year(v_n_fecha) + 20);
	ELSE
		IF (v_n_cond_regular = 10) THEN			
		            IF (v_materia = 1081) THEN
			LET v_fin_vig_regul = MDY(month(v_n_fecha),day(v_n_fecha),year(v_n_fecha) + 20);
                                            ELSE
			LET v_fin_vig_regul = MDY( month(v_n_fecha),day(v_n_fecha),year(v_n_fecha) + 2);

END IF;	
		ELSE
			LET v_fin_vig_regul = MDY( month(v_n_fecha),day(v_n_fecha),year(v_n_fecha) + 1);
		END IF;	
		
	END IF;


	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Alumno Existe en el Acta de Regulares que se esta moficando
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	SELECT COUNT(*)  INTO iCnt
		  FROM sga_det_acta_curs
		  WHERE unidad_academica = p_unidad_academica
		  AND carrera = v_carrera
		  AND legajo = v_legajo
		  AND acta = p_acta;


	IF iCnt > 0 THEN
		LET v_resultado_ant = NULL;
		IF v_registra_cursada = 'S' AND v_resultado = 'A' THEN
			SELECT resultado INTO vcResultadoCurs
				  FROM sga_det_acta_curs
				  WHERE unidad_academica = p_unidad_academica
				  AND carrera = v_carrera
				  AND legajo = v_legajo
				  AND acta = p_acta;
			IF vcResultadoCurs <> 'A' THEN
				LET v_resultado_ant = 'R';
			END IF;
		END IF;

		-- Actualizo el Acta detalle del Regulares
		UPDATE sga_det_acta_curs
			SET (fecha_regularidad, cond_regularidad, nota, resultado, rectificado, fin_vigencia_regul, pct_asistencia ) =
			        (v_n_fecha, v_n_cond_regular, v_n_nota, v_resultado, 'S', v_fin_vig_regul, v_n_pct_asistencia)
		  WHERE unidad_academica = p_unidad_academica
		    AND carrera = v_carrera
		    AND legajo = v_legajo
		    AND acta = p_acta;

		-- Recupero Plan y Version Original
		SELECT plan, version INTO v_plan, v_version
		 FROM sga_det_acta_curs
		  WHERE unidad_academica = p_unidad_academica
		    AND carrera = v_carrera
		    AND legajo = v_legajo
		    AND acta = p_acta;

		   -- Si Regularizo la Materia, entonces la registro en sga_curdada_equiv.
		   IF v_registra_cursada = 'S' THEN
			IF v_resultado IN ('A','R') THEN
			   -- Si aprobo/reprobo la cursada entonces la inserto.	
			   EXECUTE PROCEDURE sp_cursadas_equiv(p_unidad_academica, v_carrera, v_legajo, p_acta, v_comision, v_plan, v_version, v_n_fecha, 'I');
			ELSE
			   -- No Aprobo ni Reprobo la Cursada. Quedo libre en la cursada.			
-- Borro el registro, ya que el alumno no regularizo la cursada
			   EXECUTE PROCEDURE sp_cursadas_equiv(p_unidad_academica, v_carrera, v_legajo, p_acta, v_comision, v_plan, v_version, v_n_fecha, 'D');
			END IF;
		     END IF;

	ELSE
	   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	   -- Alumno no Existe. Alumno nuevo agregado al Acta de Regulares.
	   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	   -- Recupero Plan y Version de regularidad...
	   EXECUTE PROCEDURE sp_plan_de_alumno(p_unidad_academica, v_carrera, v_legajo, v_n_fecha) INTO vcPlanReg, vcVersionReg;
	   IF vcVersionReg IS NOT NULL and vcPlanReg IS NOT NULL THEN
		LET v_plan = vcPlanReg;
		LET v_version = vcVersionReg;
	   ELSE
		-- Error 
                             raise exception -746,0,'No se pudo recuperar el Plan del Alumno: ' || v_legajo;
	   END IF;

	   -- Es un Alumno Nuevo.
	   INSERT INTO sga_det_acta_curs
		(unidad_academica, carrera, legajo, acta, folio, renglon,
		plan, version, fin_vigencia_regul, fecha_regularidad, cond_regularidad, nota, resultado, pct_asistencia, rectificado)
	         VALUES (p_unidad_academica, v_carrera, v_legajo, p_acta, v_folio, v_renglon,
		v_plan, v_version,  v_fin_vig_regul, v_n_fecha, v_n_cond_regular, v_n_nota, v_resultado, v_n_pct_asistencia,'S');

	   -- Si existen la registracion de cursadas vale en otras carreras
	   -- Si Regularizo la Materia, entonces la registro en sga_curdada_equiv.
	   IF v_registra_cursada = 'S' AND v_resultado IN ('A','R') THEN
		EXECUTE PROCEDURE sp_cursadas_equiv(p_unidad_academica, v_carrera, v_legajo, p_acta, v_comision, v_plan, v_version, v_n_fecha, 'I');
	   END IF;
	END IF;

  END FOREACH;

  -- Actualizo la Version del Acta de Regulares
  UPDATE sga_actas_cursado

SET version = v_version_nueva
    WHERE unidad_academica = p_unidad_academica
      AND  acta = p_acta;

  -- Borro los datos de Cambios en Actas de Regulares
  DELETE FROM sga_cambios_curpen
    WHERE unidad_academica = p_unidad_academica
      AND
 acta = p_acta;

END IF;  -- DBINFO()

BEGIN
  on exception in (-206)
    -- Tabla no existe continuo el proceso
  end exception with resume;
  DROP TABLE tmp_cerrar_rectreg;
END;

END;
END PROCEDURE                                                                          
                                                                                                                                                                                                                                                             
