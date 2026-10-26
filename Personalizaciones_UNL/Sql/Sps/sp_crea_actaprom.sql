-- **********************************************************************
-- Version: 1.3
-- Proceso: sp_crea_actaprom
-- Ultima version de modificacion: 2.03.0, 2.5.1, 2.6.1, 2.9.4
--
-- Crea Acta de Promocionales
-- Solo si existe un Acta de Regulares Abierto para esta Comisión
-- Sino debe generarse 2ro el Acta de Regulares
-- 
-- Por cada inscripcion con calidad de Inscripcion = P (para promocionar)
-- actualiza el campo "promocional" en la tabla de cursadas pendientes.
-- Si alguno de estos alumnos tiene el Resultado o la Nota cargada no Genera el 
-- Acta de Promocion.
-- 
-- Recibe:   - Unidad Academica
--	     - Comision
--	     - Libro de Actas (Puede venir en Nulo)
--
-- Retorna:  Integer	- Numero de Acta de Promocionales (puede no haberse generado este Acta)

--*******---------***********------------**********-----------*********--
-- ** FIX BUG  **	
-- Se modifica procedimiento original, se reemplaza la variable v_comision(inexistente) por p_comision(valor de entrada)
-- **********************************************************************


-- DROP PROCEDURE sp_crea_actaprom;
CREATE PROCEDURE sp_crea_actaprom 
   (p_unidad_academica  LIKE sga_insc_cursadas.unidad_academica,
    p_comision LIKE sga_insc_cursadas.comision ,
    p_libro    LIKE  sga_actas_cursado.libro,
    p_nro_acta	integer)
    returning integer;

  DEFINE sql_err , isam_err int;
  DEFINE error_info varchar(70);
  DEFINE cnt_insc, cnt_reng_por_folio, cnt_carreras smallint;
  DEFINE lescala_notas LIKE sga_actas_promo.escala_notas;
  DEFINE v_unidad_academica like sga_alumnos.unidad_academica;
  DEFINE v_carrera, lcarrera like sga_alumnos.carrera;
  DEFINE v_legajo like sga_alumnos.legajo;
  DEFINE v_libro_actapromo    LIKE  sga_libros_actacur.libro;
  DEFINE ifolio_prom, irenglon_prom, ifolio_reg, irenglon_reg INTEGER;

  on exception set sql_err, isam_err, error_info
     -- error
    Rollback Work;
    raise exception  sql_err, isam_err, error_info;
  end exception;

-- Comienzo la transaccion
BEGIN WORK;
   ---------------------------------------------------------------
   -- Controlo que no exista un Acta de Regulares o Promocionales para la Comision,
   -- o Rectificativas de Promocion
   ---------------------------------------------------------------
   IF (SELECT COUNT(*)   FROM sga_actas_cursado
	WHERE comision         = p_comision 
	 AND  estado = 'A') <> 1 THEN
	raise exception -746,0,'Debe existir un Acta de Regulares abierta para esta comisión';
   END IF;	   

   IF (SELECT COUNT(*)   FROM sga_actas_promo
	WHERE comision  = p_comision 
	 AND  estado <> 'B') > 0 THEN
	raise exception -746,0,'Ya existe un Acta de Promocionales para esta Comisión';
   END IF;	   


   -- Controlo que no existan cargados resultados y o alumnos con Notas de Promoción Cargadas
   IF (SELECT COUNT(sga_insc_cursadas.comision) FROM sga_insc_cursadas
	  WHERE sga_insc_cursadas.comision = p_comision
	    AND sga_insc_cursadas.calidad_insc = 'P'
	    AND EXISTS (SELECT '' FROM sga_curs_pendiente
			WHERE sga_curs_pendiente.unidad_academica  = sga_insc_cursadas.unidad_academica
			 AND sga_curs_pendiente.carrera  = sga_insc_cursadas.carrera
			 AND sga_curs_pendiente.legajo  = sga_insc_cursadas.legajo
			 AND sga_curs_pendiente.comision  = sga_insc_cursadas.comision
			 AND (sga_curs_pendiente.resultado IS NOT NULL AND sga_curs_pendiente.resultado = 'P')
			 )
		) > 0 THEN
	
			-- AND (sga_curs_pendiente.resultado IS NOT NULL OR sga_curs_pendiente.nota IS NOT NULL))) > 0 THEN
	raise exception -746,0,'Hay alumnos Promocionales con Resultado cargado.';
   END IF;	   

  -----------------------------------------------------------     		
  -- Selecciono la cantidad de renglones definidos por por folio para un Acta de cursados
  -----------------------------------------------------------     		
   Execute procedure sp_param_sistema ('lineas_folio_acta_cursados') INTO cnt_reng_por_folio;

  -- Error
  IF cnt_reng_por_folio IS NULL or cnt_reng_por_folio <= 0 THEN		
    raise exception -746,0,'Debe setear la cantidad de renglones por folio en los parametros';
  END IF;

  -- Recupero la Carrera y la Escala de Notas del Acta de cursados.
  -- Se supone que solamente debe existir una abierta y que fue generada anteriormente
  -- a esta, aunque no debe estar cerrada.
  SELECT carrera INTO lcarrera
	FROM sga_actas_cursado 
	WHERE unidad_academica = p_unidad_academica
	  AND comision = p_comision
	  AND estado = 'A';

    IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
        -- No debería pasar
       raise exception -746,0,'Error al recuperar la Carrera definida  en el Acta de Regulares.';
    END IF;

  -- Escala de Notas de la Comision
  LET lescala_notas = NULL;	
  SELECT escala_notas INTO lescala_notas 
	FROM sga_comisiones
	WHERE comision = p_comision;
    IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
       raise exception -746,0,'Error al recuperar la escala de notas de la comisión.';
    END IF;

   -- La escala de notas de la comision debe tener notas con resultado = P (Promoción)
   IF (SELECT COUNT(*) FROM sga_det_escala
	WHERE escala_notas = lescala_notas
	AND resultado = 'P') <= 0 THEN
	-- la escala de notas se recupero de la escala de notas de la comision
	raise exception -746,0,'La Escala de Notas de la comisión no tiene notas de Promoción.';
   END IF;

   -- *********************************  GENERO CABECERA DEL ACTA *********************************************
   IF p_libro IS NULL THEN
     	Execute procedure sp_libroactapromo(p_comision, 'P')  INTO v_libro_actapromo;
   END IF;

   IF p_nro_acta IS NULL or p_nro_acta = 0 THEN
	     -- Recupero el Nro de Acta para Actas de Promocionales
	     Execute procedure sp_nro_acta_prom(p_unidad_academica , p_comision, 'P', v_libro_actapromo)  INTO p_nro_acta;
	     IF p_nro_acta IS NULL or p_nro_acta = 0 THEN		
	         raise exception -746,0,'Error al generar el número de Acta de Promocionales.';
	     END IF;
   END IF;

      INSERT INTO sga_actas_promo
         (unidad_academica,  acta,   tipo,  comision,  carrera, libro, escala_notas,   
           fecha_generacion,  version,  version_impresa, nro_ultima_copia, renglones_folio, estado)  
         VALUES (p_unidad_academica, p_nro_acta, 'P', p_comision, lcarrera,  v_libro_actapromo, lescala_notas, 
	TODAY,  1,  0, 0, cnt_reng_por_folio, 'A');

   -- *********************************  Fin generacion cabecera del Acta *********************************************
   
   -- Actualizo el Campo promocional en Cursadas Pendientes donde en la inscripcion
   -- figura como Promocional.
   FOREACH SELECT unidad_academica, carrera, legajo 
		INTO v_unidad_academica, v_carrera, v_legajo 
		FROM sga_insc_cursadas
		WHERE sga_insc_cursadas.comision = p_comision		
		AND sga_insc_cursadas.calidad_insc = 'P'
	
	UPDATE  sga_curs_pendiente
		SET sga_curs_pendiente.promocional = 'S'
		WHERE sga_curs_pendiente.unidad_academica = v_unidad_academica 
		AND  sga_curs_pendiente.carrera = v_carrera
		AND  sga_curs_pendiente.legajo = v_legajo
		AND  sga_curs_pendiente.comision = p_comision;
   END FOREACH;

   -- Actualizo en Cursada Pendiente, todos las filas donde el campo promocional = 'S' con el nro de Acta de Promocion
   UPDATE sga_curs_pendiente
	SET acta_promocion = p_nro_acta
	WHERE  comision = p_comision
	   AND promocional = 'S';


   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- Asigno folio y renglon del acta de promocion a los alumnos promocionales
   -- Tomo el mismo orden que los alumnos del acta de cursadas.
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- Borro la tabla temporal si es que existe.
   BEGIN 
      on exception in (-206)
         -- Tabla no existe continuo el proceso	
      end exception with resume;
      DROP TABLE temp_foliado;	
   END 

   -- Recupero los alumnos promocionales
   SELECT unidad_academica, carrera, legajo,folio_regular, renglon_regular
     FROM sga_curs_pendiente  
    WHERE comision = p_comision --v_comision
      AND promocional = 'S'
      AND acta_promocion = p_nro_acta 
   INTO TEMP temp_foliado WITH NO LOG;

   IF DBINFO("sqlca.sqlerrd2") > 0 THEN
      LET ifolio_prom = 1;
      LET irenglon_prom = 1;

      -- Recorro los alumnos promocionales y les asigno folio y renglon.
      FOREACH SELECT unidad_academica, carrera, legajo, folio_regular, renglon_regular
                INTO v_unidad_academica, v_carrera, v_legajo, ifolio_reg, irenglon_reg
                FROM temp_foliado
              ORDER BY folio_regular, renglon_regular

         -- Actualizo folio y renglon
         UPDATE sga_curs_pendiente
            SET folio_promocion = ifolio_prom,
                renglon_promocion = irenglon_prom
          WHERE comision = p_comision --v_comision
            AND unidad_academica = v_unidad_academica
            AND carrera = v_carrera
            AND legajo = v_legajo
            AND acta_promocion = p_nro_acta; 

         -- incremento el renglon
         LET irenglon_prom = irenglon_prom + 1;

         -- evaluo el máximo de renglones por folio
	 IF cnt_reng_por_folio < irenglon_prom THEN
            LET ifolio_prom   = ifolio_prom + 1;
            LET irenglon_prom = 1;
         END IF;

      END FOREACH;
      -- Borro tabla temporal
      DROP TABLE temp_foliado;
   END IF; 
   -- ++++++++++++++++++++++++ Fin asignacion folio y renglon a alumnos del acta de promocion


-- Si todo esta correcto realizo el Commit work
COMMIT WORK;

RETURN p_nro_acta;

End procedure;
-- ******************* Fin del procedure sp_crea_actaprom **************************

GRANT EXECUTE ON sp_crea_actaprom TO public;
