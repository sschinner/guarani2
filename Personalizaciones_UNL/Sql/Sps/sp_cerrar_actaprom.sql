CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_cerrar_actaprom') THEN
		DROP PROCEDURE sp_cerrar_actaprom;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ******************************************************************************
-- PROCEDURE: sp_cerrar_actaprom
-- Ultima version de modificacion: 2.6.3, 2.9.4 (refoliado)
-- U820 Se permite cerrar el acta sin el control de acta impresa
-- ******************************************************************************

-- DROP PROCEDURE sp_cerrar_actaprom;
CREATE PROCEDURE "dba".sp_cerrar_actaprom(p_unidad_academica  LIKE sga_actas_promo.unidad_academica, 
    p_acta  LIKE sga_actas_promo.acta)

DEFINE sql_err int;
DEFINE isam_err int;
DEFINE error_info varchar(70);

DEFINE v_estado_acta LIKE sga_actas_promo.estado;
DEFINE v_escala_notas LIKE sga_actas_promo.escala_notas;
DEFINE v_comision LIKE sga_actas_promo.comision;
DEFINE v_resultado, v_resultado_nota like sga_det_acta_promo.resultado;

DEFINE v_unidad_academica LIKE sga_det_acta_promo.unidad_academica;
DEFINE v_carrera LIKE sga_det_acta_promo.carrera;
DEFINE v_legajo LIKE sga_det_acta_promo.legajo;
DEFINE v_plan LIKE sga_det_acta_promo.plan;
DEFINE v_version LIKE sga_det_acta_promo.version;
DEFINE v_fecha_regular LIKE sga_det_acta_promo.fecha;
DEFINE v_cond_reg_no_prom, v_cond_regularidad LIKE sga_det_acta_promo.cond_regularidad;
DEFINE v_pct_asistencia LIKE sga_det_acta_promo.pct_asistencia;
DEFINE v_acta LIKE sga_det_acta_promo.acta;
DEFINE v_folio LIKE sga_det_acta_promo.folio;
DEFINE v_renglon LIKE sga_det_acta_promo.renglon;
DEFINE v_nota LIKE sga_det_acta_promo.nota;
DEFINE v_controlado LIKE sga_curs_pendiente.controlado;
DEFINE v_sAux char(1);
DEFINE vcCargarNotas, v_promo_otras_car LIKE sga_param_sistema.valor;
DEFINE vParNUA LIKE sga_nua.nua;
DEFINE vActaNUA LIKE sga_nua.nua;
DEFINE v_muestra_no_prom LIKE sga_param_sistema.valor;
DEFINE v_renglon_acta, v_folio_acta, v_renglones_folio integer;

on exception set sql_err, isam_err, error_info
    -- Error. no realizo nada
    raise exception  sql_err, isam_err, error_info;
end exception;

on exception in (-206)
    -- Tabla no existe continuo el proceso	
end exception with resume;


   -- Verifico que el Acta de Promocionados no este Cerrada. Selecciono el Tipo de Acta
	
   SELECT estado, comision, escala_notas, renglones_folio INTO v_estado_acta, v_comision, v_escala_notas, v_renglones_folio
	FROM sga_actas_promo
	WHERE unidad_academica = p_unidad_academica
	  AND acta = p_acta;
   IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
	raise exception -746,0,'No existe el Acta de Promoción N°: ' || p_acta;
   END IF;
   IF v_estado_acta = 'C' THEN
	raise exception -746,0,'No puede cerrarse el Acta porque ya está cerrada.';
   ELIF v_estado_acta = 'B' THEN
	raise exception -746,0,'No puede cerrarse el Acta porque está dada de Baja.';
   END IF;	

   -- ******************************************************************************
   -- Verifico si Existe otro Acta de Promocionados Cerrada.
   -- Si es Asi no dejo Cerrar esta, porque solamente debe haber un Acta de Promocionados
   -- Se deberá rectificar el Acta de Promocionados
   -- Recupero la Comision del Acta que se va a cerrar	
   -- ******************************************************************************
   
   -- Existe una Acta de Promoc cerrada.
   IF (SELECT COUNT(*) FROM sga_actas_promo
	WHERE unidad_academica = p_unidad_academica
	  AND comision = v_comision
	  AND acta <> p_acta
	  AND tipo = 'P'
	  AND estado = 'C' ) > 0 THEN	   
	   raise exception -746,0,'Existe un Acta de Promocionados Cerrado. Debe Rectificarlo!';
   END IF;	


--==================verifica que el acta este impresa con su version y version impresa===========================
     {IF EXISTS ( SELECT '' FROM sga_actas_promo
                           WHERE sga_actas_promo.unidad_academica = p_unidad_academica
                                 AND sga_actas_promo.acta = p_acta 
	                         AND sga_actas_promo.version_impresa <> sga_actas_promo.version ) THEN

                  raise exception  -746, 0, 'Para cerrar el acta, debe tener la ultima version impresa.';
    END IF;}
--=================================================================================================



   -- Si se usa NUA (Número único de aprobación), verifica que es número esté generado antes de cerrar el acta
   EXECUTE PROCEDURE sp_param_sistema('NUA') INTO vParNUA;
   IF vParNUA = 'S' THEN
      SELECT NUA
        INTO vActaNUA
        FROM sga_actas_promo
       WHERE sga_actas_promo.unidad_academica = p_unidad_academica
         AND sga_actas_promo.acta = p_acta;

      IF vActaNUA IS NULL THEN
         raise exception  -746, 0, 'Para ser cerrada, el acta debe tener su NUA';
      END IF;
   END IF;

  LET v_resultado_nota = NULL;

   -------------------------------------------------------------
   -- Recupero los Registros de Cursadas Pendientes de este Acta
   -- Se supone que en Cursada Pendiente los registros de alumnos promocionales
   -- ya tienen el Nro de Acta, Folio y Renglon
   -------------------------------------------------------------
   -- Borro la tabla temporal si es que existe.
   DROP TABLE temp_curs_pend_pro;	

   SELECT unidad_academica, carrera, legajo,
	comision, plan, version, fecha_regularidad, 
	cond_regularidad, nota, pct_asistencia, 
	acta_promocion, folio_promocion, renglon_promocion, controlado
    FROM sga_curs_pendiente  
   WHERE unidad_academica = p_unidad_academica
     AND comision = v_comision
     AND promocional = 'S'
   INTO TEMP temp_curs_pend_pro WITH NO LOG;

   -- Recupero la Cantidad de registros seleccionados
   IF DBINFO("sqlca.sqlerrd2") > 0 THEN

	-- Promocion vale en todas las Carreras.
	LET v_promo_otras_car = 'N';
	EXECUTE PROCEDURE sp_param_sistema('promocion_vale_en_todas_las_carreras') INTO v_promo_otras_car;
	IF v_promo_otras_car IS NULL OR TRIM(v_promo_otras_car) = '' THEN
  		raise exception -746,0,'Error. Falta cargar P. del Sist "promocion_vale_en_todas_las_carreras"' ;	
	END IF;

	-- Veo si cargo o no los alumnos que no promocionaron en el Acta de Promocionales
	Execute procedure sp_param_sistema('inserta_alumnos_no_promocionados_en_acta') INTO v_sAux;
	IF v_sAux IS NULL or v_sAux = '' THEN
	      raise exception -746, 0, 'Debe cargarse el  P. del Sist "inserta_alumnos_no_promocionados_en_acta"';
	ELIF  v_sAux = 's' or v_sAux = 'S' THEN
		LET v_sAux = 'S';
	ELSE
		LET v_sAux = 'N';
	END IF;

	-- Veo si muestro los alumnos que no promocionaron en el Acta de Promocionales
	Execute procedure sp_param_sistema('muestra_alumnos_no_promocionados') INTO v_muestra_no_prom;
	IF v_muestra_no_prom IS NULL or v_muestra_no_prom = '' THEN
	      raise exception -746, 0, 'Debe cargarse el  P. del Sist "muestra_alumnos_no_promocionados"';
	ELIF  v_muestra_no_prom = 's' or v_muestra_no_prom = 'S' THEN
		LET v_muestra_no_prom = 'S';
	ELSE
		LET v_muestra_no_prom = 'N';
	END IF;
	
	IF v_sAux <> v_muestra_no_prom THEN
	    raise exception -746, 0, 'Los parámetros de mostrar e insertar alumnos en actas no son iguales';
	END IF;
	-- Selecciono la Condicion de Regularidad que devuelve un resultado = N, por si vienen
	-- registros donde el resultado <>  P (Promociono)
	SELECT  cond_regularidad  INTO v_cond_reg_no_prom
	   FROM sga_cond_regular
	  WHERE resultado = 'N';		

             -- Controlo si debe ingresar la nota a los alumnos Promocionados.
             EXECUTE PROCEDURE sp_param_sistema ('cargar_notas_promocion') INTO vcCargarNotas;
             IF vcCargarNotas = 'O' THEN
	  -- La carga de notas es Obligatoria.
      	  IF (SELECT COUNT(*) FROM  temp_curs_pend_pro t
	      WHERE t.nota IS NULL
		AND (select cr.resultado from sga_cond_regular cr
		      where cr.cond_regularidad = t.cond_regularidad) = 'P') > 0 THEN
		raise exception -746,0,'Debe ingresar la nota a los alumnos que han Promocionado la Materia.';
   	   END IF;
              END IF;


	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Recupero los alumnos promocionales y los inserto en el detalle del acta
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	LET v_renglon_acta = 0;
	LET v_folio_acta = 1;

        FOREACH SELECT unidad_academica,  carrera, legajo, plan,  version,
		 fecha_regularidad,  cond_regularidad,   nota,  pct_asistencia, 
		 acta_promocion,  folio_promocion, renglon_promocion, controlado
	INTO  v_unidad_academica, v_carrera, v_legajo, v_plan, v_version,
		v_fecha_regular, v_cond_regularidad,  v_nota, v_pct_asistencia, 
		 v_acta, v_folio, v_renglon, v_controlado
 	FROM temp_curs_pend_pro  
	ORDER BY folio_promocion, renglon_promocion

	IF v_fecha_regular IS NULL  THEN
	    -- Error
	   raise exception -746,0,'Debe cargarse la Fecha de Regul. Folio:' || v_folio || ' Reng:' || v_renglon ;
	END IF;

	IF v_cond_regularidad IS NULL THEN
	   LET v_nota = NULL;
	   LET v_resultado = 'N';
	   LET v_cond_regularidad = v_cond_reg_no_prom;
	ELSE
	   -- Recupera el resultado que corresponde por la condicion de aprobacion informada
	   SELECT resultado  INTO v_resultado
	       FROM sga_cond_regular
	       WHERE cond_regularidad = v_cond_regularidad ;
	   IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
	       raise exception  -746, 0,  'No se encontró el Resultado correspondiente a la Cond. de Promoción. Folio:' || v_folio || ' Reng:' || v_renglon;
	   END IF;
	
	  
	   IF v_resultado <> 'P' AND v_resultado <> 'U' THEN   --## AUSENTE
	   -- IF v_resultado <> 'P' THEN
	      LET v_resultado = 'N';
	      LET v_cond_regularidad = v_cond_reg_no_prom;
	   END IF;

		LET v_resultado_nota = NULL;
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

		    -- Si no coincide el resultado que corresponde por la condicion con el que corresponde
		    -- por la nota, sale con un error.
		    IF (v_resultado = 'P' and  v_resultado_nota <> 'P')  THEN
		       raise exception  -746, 0,  'La nota no es compatible con la cond. de Aprob. Folio:' || v_folio || ' Reng:' || v_renglon ;
		    ELIF (v_resultado <> 'P' and  v_resultado_nota <> 'P')  THEN
			-- No Promociono!				
			-- v_resultado <> 'P' and  v_resultado_nota = 'P' :  no se hace este control porque un alumno
			-- puede no promocionar, pero en la nota de la regularidad puedo poner una nota cuyo resultado es Promocion.

			LET v_resultado = 'N';
			LET v_cond_regularidad = v_cond_reg_no_prom;
		    END IF ;
		END IF;
	END IF;

	-- No permito insertar si no promociono y el param del sistema dice que no inserte 
	-- los alumnos que no promocionaron
	IF  NOT (v_resultado <> 'P' and v_sAux = 'N')  THEN
		IF (v_resultado_nota <> 'P' and v_resultado_nota <> 'U') THEN   -- SI es un AUSENTE, NO DEBERIA TENER NOTA.
			LET v_resultado = 'N';
			LET v_cond_regularidad = v_cond_reg_no_prom;
		END IF;

		-- Reenumero el acta por si quedo mal algun alumno en el folio/renglon. Es el caso de cuando no se incluyen alumnos que no promocionaron.
		LET v_renglon_acta = V_renglon_acta + 1;
		IF v_renglon_acta > v_renglones_folio THEN
		   LET v_renglon_acta = 1;
		   LET v_folio_acta = v_folio_acta + 1;
		END IF;


 		-- Genero el Detalle del Acta de Promocion
		INSERT INTO sga_det_acta_promo
			(unidad_academica, carrera, legajo, plan, version, acta, folio, renglon, fecha, cond_regularidad, resultado, nota, pct_asistencia, rectificado)  
		   VALUES (p_unidad_academica, v_carrera, v_legajo, v_plan, v_version,
			 p_acta, v_folio_acta, v_renglon_acta, v_fecha_regular, v_cond_regularidad, v_resultado, v_nota, v_pct_asistencia, 'N');  

		-- Inserto las Equivalencias por Promocion, si el Alumno Promocionó la materia.
		IF v_promo_otras_car = 'S' AND v_resultado = 'P' THEN
			EXECUTE PROCEDURE sp_u_promo_equiv (p_unidad_academica, v_carrera, v_legajo, v_comision, v_fecha_regular, p_Acta, 'I');
		END IF;
	END IF;

	END FOREACH; -- Alumnos promocionales
	-- +++++++++++++++++++++++++++++++++++ Fin pasaje de alumnos promocionales al acta de promocion ++++++++++++++++++++++++++++

	-- Actualizo el Estado del Acta de Cursado Promocionales
	UPDATE sga_actas_promo 
		SET estado = 'C',   fecha_cierre = TODAY 
		WHERE unidad_academica = p_unidad_academica
		  AND acta = p_acta;	
	IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
		raise exception -746,0, 'Error al actualizar el Acta de Promoción!';	
	END IF;

	-- Limpia campos en la tabla de Cursadas Pendientes
	UPDATE sga_curs_pendiente
		SET acta_promocion = NULL,
		    folio_promocion = NULL,
		    renglon_promocion = NULL
	   WHERE unidad_academica = p_unidad_academica
	     AND acta_promocion = p_acta    	
	     AND promocional = 'S';
   ELSE
	-- Actualizo el Estado del Acta de Cursado Promocionales
	UPDATE sga_actas_promo 
		SET estado = 'C',   fecha_cierre = TODAY 
		WHERE unidad_academica = p_unidad_academica
		  AND acta = p_acta;	
	IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
		raise exception -746,0, 'Error al actualizar el Acta de Promoción!';	
	END IF;

	-- No existen Alumnos en el Acta. No se permite cerrar el Acta de Promocion
	--raise exception -746,0,'El Acta no tiene alumnos. No se permite cerrar el Acta de Promoción.';
   END IF;	-- cnt_insc > 0


   -- INSERTO LOS folios de un Acta de Promocion	
   EXECUTE PROCEDURE sp_i_folioactaprom(p_unidad_academica, p_acta);


   -- Borro la tabla temporal
   DROP TABLE temp_curs_pend_pro;	
	
End procedure;

-- *****************************************************************************************
revoke execute on sp_cerrar_actaprom from public;

grant execute on sp_cerrar_actaprom to guarani; -- Rol de usuarios de Gestión
grant execute on sp_cerrar_actaprom to internet; -- Usuario de internet



