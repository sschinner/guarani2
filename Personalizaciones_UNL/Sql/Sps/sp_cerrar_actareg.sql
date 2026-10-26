CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_cerrar_actareg') THEN
		DROP PROCEDURE sp_cerrar_actareg;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ******************************************************************************
-- U820 Se permite cerrar el acta sin el control de acta impresa
-- ******************************************************************************

CREATE PROCEDURE "dba".sp_cerrar_actareg(p_unidad_academica  LIKE sga_curs_pendiente.unidad_academica, p_acta  LIKE sga_curs_pendiente.acta_regular)

DEFINE sql_err , isam_err int;
DEFINE error_info varchar(70);
DEFINE v_estado, v_estado_acta_prom LIKE sga_actas_cursado.estado;
DEFINE v_comision LIKE sga_actas_cursado.comision;
DEFINE v_escala_notas LIKE sga_actas_cursado.escala_notas;

DEFINE v_acta_prom, v_acta LIKE sga_actas_promo.acta;
DEFINE v_carrera LIKE sga_actas_cursado.carrera;
DEFINE v_legajo LIKE sga_det_acta_curs.legajo;
DEFINE v_plan LIKE sga_det_acta_curs.plan;
DEFINE v_version LIKE sga_det_acta_curs.version;
DEFINE v_fecha_regular LIKE sga_det_acta_curs.fecha_regularidad;
DEFINE v_cond_regularidad LIKE sga_det_acta_curs.cond_regularidad;
DEFINE v_resultado,v_resultado_nota LIKE sga_det_acta_curs.resultado;
DEFINE v_pct_asistencia LIKE sga_det_acta_curs.pct_asistencia;
DEFINE v_folio, folio_aux LIKE sga_det_acta_curs.folio;
DEFINE v_renglon, renglon_aux  LIKE sga_det_acta_curs.renglon;
DEFINE v_nota LIKE sga_det_acta_curs.nota;
DEFINE v_promocional LIKE sga_curs_pendiente.promocional;
DEFINE v_controlado  LIKE sga_curs_pendiente.controlado;
DEFINE vs_acentar_nota, vs_ins_promovidos   char(1);	
DEFINE v_fin_vig_regul LIKE sga_det_acta_curs.fin_vigencia_regul;
DEFINE v_cnt_max_filas, cnt_promo INTEGER;
DEFINE v_registra_cursada like sga_param_sistema.valor;

on exception set sql_err, isam_err, error_info
    -- Error. no realizo nada
    raise exception  sql_err, isam_err, error_info;
end exception;



   -- Verifico que el Acta de Cursado no este Cerrada.
   SELECT estado, comision, escala_notas, renglones_folio
	 INTO v_estado, v_comision, v_escala_notas, v_cnt_max_filas
	FROM sga_actas_cursado
	WHERE unidad_academica = p_unidad_academica
	  AND acta = p_acta;

   -- Recupero la Cantidad de registros seleccionados
   IF DBINFO("sqlca.sqlerrd2") <=  0 THEN
	raise exception -746,0,'No existe el Acta de Regularidad N°: ' || p_acta ;
   END IF;
   IF v_estado = 'C' THEN
	raise exception -746,0,'No se puede cerrar el Acta N°: ' || p_acta || ' porque ya esta Cerrado.';
   ELIF v_estado = 'B' THEN
	raise exception -746,0,'No se puede cerrar el Acta N°: ' || p_acta || '  porque esta dado de Baja.';
   END IF;	

-- U820 ***************************************************************
-- Se personaliza para no tener que reimprimir la ultima versión del acta antes de cerrarla
-- U820 ***************************************************************
--==================verifica que el acta este impresa con su version y version impresa===========================
/*     IF EXISTS ( SELECT '' FROM sga_actas_cursado
                           WHERE sga_actas_cursado.unidad_academica = p_unidad_academica
                                 AND sga_actas_cursado.acta = p_acta 
	                         AND sga_actas_cursado.version_impresa <> sga_actas_cursado.version ) THEN

                  raise exception  -746, 0, 'Para cerrar el acta, debe tener la ultima version impresa.';
    END IF;
*/
--=================================================================================================
-- U820 ***************************************************************
-- Se personaliza para no tener que reimprimir la ultima versión del acta antes de cerrarla
-- U820 ***************************************************************

   -- Verifico que no exista un Acta de Promocion o Rect de Promocion abierta
   IF (SELECT COUNT(*) FROM sga_actas_promo
	WHERE unidad_academica = p_unidad_academica
	AND comision = v_comision
	AND estado = 'A' )  > 0 THEN
	raise exception -746,0,'Debe cerrar el Acta de Promocionales de esta comisión.';
  END IF;

   -- Recupero los Registros de Cursadas Pendientes
  begin	
     on exception in (-206)
         -- Tabla no existe continuo el proceso. Es por el delete de la tabla temporal	
     end exception with resume;
     DROP TABLE temp_curs_pend_reg;
   end;
   SELECT unidad_academica, carrera, legajo, comision, plan, version, fecha_regularidad, cond_regularidad,   
	resultado, nota, pct_asistencia, acta_regular, folio_regular, renglon_regular, promocional, controlado  
    FROM sga_curs_pendiente  
   WHERE unidad_academica = p_unidad_academica
     AND comision = v_comision
   INTO TEMP temp_curs_pend_reg;
--     AND acta_regular = p_acta    	

-- Recupero la Cantidad de registros seleccionados
IF DBINFO("sqlca.sqlerrd2") > 0 THEN

	-- Verifico si deben insertarse los Alumnos Promovidos al Acta de Regulares
	Execute procedure sp_param_sistema('inserta_alumnos_promocionados_actareg') INTO vs_ins_promovidos;
	If vs_ins_promovidos <> 'S' THEN
		LET vs_ins_promovidos = 'N';
	END IF;

-- ------------------------------------------------------------------------------------------------------------------------------
--	-- Realizo Algunos Controles
--  	IF (SELECT COUNT(*) 
--		FROM temp_curs_pend_reg
--		WHERE unidad_academica = p_unidad_academica
--		  AND acta_regular = p_acta    	
--		  AND controlado <> 'S') > 0  THEN
--	  raise exception -746,0,'Existe un Registro que no fue Controlado.';
--	END IF;
-- ------------------------------------------------------------------------------------------------------------------------------

	-- Si hay alumnos promocionales, controlo que exista Acta de Promoción y este cerrado.    	
	IF (SELECT COUNT(*) 
		FROM temp_curs_pend_reg	
		WHERE unidad_academica = p_unidad_academica
		  AND acta_regular = p_acta    	
		  AND promocional    = 'S') > 0 THEN

	{     -- Solo debe haber uno o ningun Acta de Promocionales para esta comisión
	     SELECT estado INTO v_estado_acta_prom	
		FROM sga_actas_promo
		WHERE unidad_academica = p_unidad_academica
		  AND comision = v_comision
		  AND tipo = 'P';		
	     IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
		-- No se ha generado el Acta de Promocionales aun!
		raise exception -746,0,'Debe generar y cerrar el Acta de Promocionales antes!';
	     ELSE
		IF v_estado_acta_prom <> 'C' THEN
		     raise exception -746,0,'Debe cerrar el Acta de Promocionales antes!';
		END IF;
	     END IF;
	}

	   LET cnt_promo = 0;	    
	   -- Solo debe haber uno o ningun Acta de Promocionales para esta comisión
	   -- Verifico si hay Acta de promocion Abierta o si no existe Acta de promocion.	
	   SELECT count(*)  INTO cnt_promo
		FROM sga_actas_promo
		WHERE unidad_academica = p_unidad_academica
		  AND comision = v_comision
		  AND tipo   = 'P'
		  AND estado = 'A';
	
	   IF cnt_promo > 0 THEN
		-- Existe un Acta de Promocionales abierto.
		raise exception -746,0,'Debe cerrar el Acta de Promocionales antes!';
	  END IF;

	 -- Debe haber un Acta de Promocion cerrada!!!
	 SELECT count(*) INTO cnt_promo
		FROM sga_actas_promo
		WHERE unidad_academica = p_unidad_academica
		  AND comision = v_comision
		  AND tipo   = 'P'
		  AND estado IN ('C','B');
	   IF cnt_promo = 0 THEN
		-- No se ha generado el Acta de Promocionales aun!
		raise exception -746,0,'Debe generar y cerrar el Acta de Promocionales antes!';
	   END IF;


	END IF;


 -- Regularidad vale en todas las Carreras.
  LET v_registra_cursada = 'N';
  EXECUTE PROCEDURE sp_param_sistema('regularidad_vale_en_todas_las_carreras') INTO v_registra_cursada;
  IF v_registra_cursada IS NULL OR TRIM(v_registra_cursada) = '' THEN
  	raise exception -746,0,'Error. Falta cargar P. del Sist "regularidad_vale_en_todas_las_carreras"' ;	
  END IF;

  -- Controlo si debe o no ingresarse la Nota en el Acta de Regulares
  Execute procedure sp_param_sistema('asentar_notas_actas_regulares') INTO vs_acentar_nota;

  LET folio_aux = 1;
  LET renglon_aux = 0;

  -- Recorro la tabla temporal ordenado por folio y renglon e inserto los datos en el detalle del Acta de Regulares
  FOREACH    SELECT carrera, legajo, comision, plan, version, fecha_regularidad, cond_regularidad,   
		nota, pct_asistencia, folio_regular, renglon_regular, promocional , controlado
		INTO v_carrera, v_legajo, v_comision, v_plan, v_version, v_fecha_regular, v_cond_regularidad,   
		v_nota, v_pct_asistencia, v_folio, v_renglon, v_promocional, v_controlado
		FROM  temp_curs_pend_reg  
		ORDER BY folio_regular, renglon_regular


	-- ***** Ver si Plan y Version del Alumno lo calculo en este momento ******
	-- execute procedure sp_plan_de_alumno(p_unidad_academica,v_carrera, v_legajo, v_fecha_regular) INTO v_plan, v_version;
	-- ************************************************************************************

--	IF v_controlado = 'N'  THEN
--	    -- Error
--	   raise exception -746,0,'Debe controlarse el Alumno del Folio:' || v_folio || ' Reng:' || v_renglon ;
--	END IF;

	-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	IF v_fecha_regular IS NULL  THEN
	    -- Error
	   raise exception -746,0,'Debe cargarse la Fecha de Regularidad. Folio:' || v_folio || ' Reng:' || v_renglon ;
	END IF;

	-- Verifico la Nota y la Condicion de Regularidad
	IF v_cond_regularidad IS NULL THEN
	   raise exception -746,0,'Debe seleccionarse la Cond. de Regularidad. Folio:' || v_folio || ' Reng:' || v_renglon ;
	END IF;

	-- Recupera el resultado que corresponde por la condicion de aprobacion informada
	SELECT resultado  INTO v_resultado
	     FROM sga_cond_regular
	     WHERE cond_regularidad = v_cond_regularidad ;
	IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
	       raise exception  -746, 0,  'No se encontró el Resultado corresp. a la Cond. de Reg. Folio:' || v_folio || ' Reng:' || v_renglon ;
	ELIF v_resultado = 'N' THEN
	       -- El usuario debe seleccionar una nueva condicion de Regularidad.	
	       raise exception  -746, 0,  'Debe seleccionarse la Cond. de Reg. Folio:' || v_folio || ' Reng:' || v_renglon ;
	END IF;

	-- Verifico si inserto los Promocionales
	IF  (vs_ins_promovidos = 'N' and v_resultado = 'P' ) THEN
		CONTINUE FOREACH;
	ELSE
		LET renglon_aux = renglon_aux + 1;
		IF renglon_aux > v_cnt_max_filas THEN
		   LET folio_aux = folio_aux + 1;
		   LET renglon_aux = 1;
		END IF;
	END IF;

	-- Controlo si debe o no ingresarse la Nota en el Acta de Regulares
	IF (vs_acentar_nota = 'S'  AND v_nota IS NOT NULL) THEN
		-- No debe ingresarse la Nota
		LET v_nota = NULL;
	ELIF (vs_acentar_nota = 'O' AND v_nota IS NULL and v_resultado <> 'U' ) THEN
	       -- Debo verificar el resultado, que sea Aprobado (A) o Reprobado(R), si es ausente no es necesario que este la nota!
	       -- Error. La carga de la Nota es obligatoria	
	       raise exception  -746, 0,  'Debe ingresarse la Nota. Folio:' || v_folio || ' Reng:' || v_renglon ;
	END IF;


	-- La nota puede venir en Nulo.
	IF v_nota IS NOT NULL THEN
	     -- Recupera el resultado que corresponde por la nota informada, segun la escala de notas de la comision
	    SELECT resultado  INTO v_resultado_nota
	         FROM sga_det_escala
	         WHERE nota = v_nota
	             AND escala_notas = v_escala_notas ;
	    IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
	          raise exception  -746, 0,  'No se encontró el Resultado correspondiente a la Nota. Folio:' || v_folio || ' Reng:' || v_renglon ;
	    END IF;


	    IF v_resultado_nota = 'P' AND (v_resultado = 'A' or v_resultado = 'P') Then
		-- Puedo en Actas de Regulares, agregar un Alumno y cargar la Cond
		-- de Reg cuyo Resultado = A y una Nota cuyo resultado es de Promocion!!!
	    ELSE	
		-- Si no coincide el resultado que corresponde por la condicion con el que corresponde
		-- por la nota, sale con un error.
		IF v_resultado <> v_resultado_nota Then
			raise exception  -746, 0,  'La nota no es compatible con la cond. de aprob. informada. Folio:' || v_folio || ' Reng:' || v_renglon ;
		END IF ;
	    END IF;
	END IF;

	-- Debo calcular la Fecha de Fin de Vigencia de Regularidad
	EXECUTE PROCEDURE SP_FE_FIN_VIG_REG(v_comision, v_fecha_regular) INTO v_fin_vig_regul;
	IF v_fin_vig_regul IS NULL THEN
		raise exception -746,0,'Error al calcular la Fecha de fin de vigencia de la Regularidad.' ;
	END IF;
	--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	-- Genero el Detalle del Acta de Cursado
   	INSERT INTO sga_det_acta_curs
		(unidad_academica, carrera, legajo, acta,  folio, renglon, fecha_regularidad,   
		cond_regularidad, resultado, nota, plan, version, pct_asistencia, fin_vigencia_regul, rectificado)  
	      VALUES (p_unidad_academica, v_carrera, v_legajo, p_acta,  folio_aux, renglon_aux, v_fecha_regular,   
		     v_cond_regularidad, v_resultado, v_nota, v_plan, v_version, v_pct_asistencia, v_fin_vig_regul, 'N');		

	-- Si existen la registracion de cursadas vale en otras carreras
	-- Si Regularizo la Materia, entonces la registro en sga_curdada_equiv.
	IF v_registra_cursada = 'S' AND v_resultado IN ('A','R') THEN
		EXECUTE PROCEDURE sp_cursadas_equiv(p_unidad_academica, v_carrera, v_legajo, p_acta, v_comision, v_plan, v_version, v_fecha_regular, 'I') ;
	END IF;

  END FOREACH;
   -------------------------------------------------------------------------
   -- Borro las cursadas Pendientes del Acta que se cierra. 
   -- Solo aquellos registros que no pertenezcan a un Acta rectificativa de Promocion 
   -------------------------------------------------------------------------
   SELECT acta INTO v_acta
	FROM sga_actas_promo
	WHERE unidad_academica = p_unidad_academica
	  AND comision = v_comision
	  AND tipo = 'R'
	  AND estado = 'A';		
   IF DBINFO("sqlca.sqlerrd2") > 0 THEN
      -- Existe un Acta Rectificativa de Promociona Abierta para esta comision. No borro los registros rectificados
      DELETE FROM sga_curs_pendiente
	WHERE unidad_academica = p_unidad_academica
	      AND comision = v_comision
      	      AND (acta_promocion IS NULL OR acta_promocion <> v_acta_prom);

   ELSE
      -- Borro todas las filas correspondientes a la comision
      DELETE FROM sga_curs_pendiente
	WHERE unidad_academica = p_unidad_academica
	      AND comision = v_comision;
	--   AND  acta_regular = p_acta
   END IF;	

   -----------------------------------------------------
   -- Actualizo el Estado del Acta de Cursado
   -----------------------------------------------------
   UPDATE sga_actas_cursado 
	SET estado = 'C',    fecha_cierre = TODAY 
	WHERE unidad_academica = p_unidad_academica
	  AND acta = p_acta;	

ELSE
	-- NO existen registros !!!  No permito cerrar el Acta
	raise exception -746,0,'El Acta no tiene alumnos. No se permite cerrar el Acta de Regulares';
-- cnt_insc > 0
END IF;		

  begin	
     on exception in (-206)
         -- Tabla no existe continuo el proceso. Es por el delete de la tabla temporal	
     end exception with resume;
     DROP TABLE temp_curs_pend_reg;
   end;

END PROCEDURE;

-- *****************************************************************************************
revoke execute on sp_cerrar_actareg from public;

grant execute on sp_cerrar_actareg to guarani; -- Rol de usuarios de Gestión
grant execute on sp_cerrar_actareg to internet; -- Usuario de internet
                  
