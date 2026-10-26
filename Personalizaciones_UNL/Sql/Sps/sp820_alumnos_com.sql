-- ******************************************************************************
-- Recupera los Registros de la Tabla de Cursadas Pendientes de una Comision.
-- Se supone que estos registros no tienen definido un Acta de Cursado.
--
-- Ultima version de modificacion: 2.6.3, 2.08.0 (devuelve el id de la imagen del alumno)
-- Recibe:   Integer    - Codigo de Comision
--   Char(1)    - Tipo de Registro que recupera: 
--    MR - Regulares, 
--    CR - Cerrado de Regulares
--    RR - Rectificativa de Regulares
--    MP - Modificacion de Promocionales
--    CP - Para Cerrado de Promocionales
--    RP - Rectificativa de Promocionales
--    MT - Todos, (Regulares y Promocionales ordenados por folio y renglon de regulares)
--
-- ******************************************************************************
-- DROP PROCEDURE sp820_alumnos_com;
CREATE PROCEDURE sp820_alumnos_com( 
   p_comision LIKE sga_curs_pendiente.comision, 
   p_tipo char(2))
RETURNING  varchar(5) ,varchar(5) , varchar(15) , integer,  varchar(5), varchar(5) , date, integer, char(1), varchar(5), float,  integer, integer, integer,integer, integer, integer, char(1) ,char(1), varchar(30), varchar(30), char(1), char(1), varchar(180), varchar(20);

DEFINE l_unidad_academica LIKE sga_curs_pendiente.unidad_academica;   
DEFINE l_carrera LIKE sga_curs_pendiente.carrera;   
DEFINE l_legajo LIKE sga_curs_pendiente.legajo;   
DEFINE l_comision LIKE sga_curs_pendiente.comision;   
DEFINE l_plan LIKE sga_curs_pendiente.plan;   
DEFINE l_version LIKE sga_curs_pendiente.version;   
DEFINE l_fecha_regular LIKE sga_curs_pendiente.fecha_regularidad;   
DEFINE l_cond_regularidad,  l_cond_reg_no_prom LIKE sga_curs_pendiente.cond_regularidad;   
DEFINE l_resultado LIKE sga_curs_pendiente.resultado;   
DEFINE l_nota LIKE sga_curs_pendiente.nota;   
DEFINE l_pct_asistencia LIKE sga_curs_pendiente.pct_asistencia;   
DEFINE l_acta_promocion LIKE sga_curs_pendiente.acta_promocion;   
DEFINE l_folio_promocion, l_folio LIKE sga_curs_pendiente.folio_promocion;   
DEFINE l_renglon_promoc, l_renglon LIKE sga_curs_pendiente.renglon_promocion;   
DEFINE l_acta_regular LIKE sga_curs_pendiente.acta_regular;   
DEFINE l_folio_regular LIKE sga_curs_pendiente.folio_regular;   
DEFINE l_renglon_regular LIKE sga_curs_pendiente.renglon_regular;   
DEFINE l_promocional LIKE sga_curs_pendiente.promocional;  
DEFINE l_controlado LIKE sga_curs_pendiente.controlado;  
DEFINE l_nombre_alumno varchar(30); 
DEFINE l_apellido_alumno varchar(30); 
DEFINE l_agregado	char(1);
DEFINE l_tiene_nota char(1);  -- Usado para caso de Cierre Parcial, si tiene nota, entonces no se permite modificar el registro.
DEFINE l_recupera_no_prom LIKE sga_param_sistema.valor;
DEFINE l_cnt_lineas_folio INTEGER;
DEFINE vCierreParcial LIKE sga_param_sistema.valor;
DEFINE vcArchivoFoto varchar(180);
DEFINE l_nro_documento varchar(20); 


LET l_agregado = 'N';
LET l_recupera_no_prom = 'N';
LET l_tiene_nota = 'N';

LET p_tipo = TRIM(UPPER(p_tipo));
IF p_tipo NOT IN ('MR','CR','RR', 'MP','CP', 'RR','MT') THEN
     raise exception -746,0,'Debe ingresar un Parámetro válido para recuperar registros del Acta';
END IF;

-- Verifico si trabaja con cierres parciales. Busco fechas de las regularidades
EXECUTE PROCEDURE sp_param_sistema('cierre_parcial_acta_cursados') INTO vCierreParcial;


IF p_tipo = 'MP' OR p_tipo = 'CP' THEN
  -- Selecciono la condicion de regularidad del Resultado No Promociono
  SELECT cond_regularidad INTO l_cond_reg_no_prom
	FROM sga_cond_regular
	WHERE  resultado = 'N';
  IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
     -- Error
    raise exception -746,0,'No se pudo recuperar la Condición de Regularidad para los No Promocionados.';
  END IF;
END IF;

-- Recupero los Registros de Cursada Pendiente 
BEGIN
  on exception in (-206)
    -- Tabla no existe continuo el proceso	
   end exception with resume;
   DROP TABLE tmp_cursadas_pend;
END;
SELECT sga_curs_pendiente.unidad_academica,  
       sga_curs_pendiente.carrera,   
       sga_curs_pendiente.legajo,   
       sga_curs_pendiente.comision,   
       sga_curs_pendiente.plan,   
       sga_curs_pendiente.version,   
       sga_curs_pendiente.fecha_regularidad,   
       sga_curs_pendiente.cond_regularidad,   
       sga_curs_pendiente.resultado,   
       sga_curs_pendiente.nota,   
       sga_curs_pendiente.pct_asistencia,   
       sga_curs_pendiente.acta_promocion,   
       sga_curs_pendiente.folio_promocion,   
       sga_curs_pendiente.renglon_promocion,   
       sga_curs_pendiente.acta_regular,   
       sga_curs_pendiente.folio_regular,   
       sga_curs_pendiente.renglon_regular,   
       sga_curs_pendiente.promocional,  
       sga_curs_pendiente.controlado,  
       sga_personas.apellido as apellido_alumno,
       sga_personas.nombres as nombre_alumno,
       sga_personas.id_imagen as id_imagen,
       sga_personas.nro_documento	
    FROM sga_curs_pendiente,
         sga_alumnos,
         sga_personas
   WHERE sga_curs_pendiente.comision =  p_comision     AND
         sga_alumnos.unidad_academica = sga_curs_pendiente.unidad_academica  AND  
         sga_alumnos.carrera = sga_curs_pendiente.carrera  AND  
         sga_alumnos.legajo  = sga_curs_pendiente.legajo  AND  
         sga_personas.unidad_academica = sga_alumnos.unidad_academica  and  
         sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion  
   INTO TEMP tmp_cursadas_pend;

IF DBINFO("sqlca.sqlerrd2") > 0 THEN

 IF p_tipo = 'MR' or p_tipo = 'CR' or p_tipo = 'MT' THEN
  -- Recupero alumnos de Cursada Pendiente para Modificacion de Acta de Regulares
  -- o carga de regulares y promocionales en el mismo cargador
  -- Ordenados por folio_regular y renglon_regular

  FOREACH SELECT *  INTO l_unidad_academica, l_carrera,   l_legajo,l_comision,  
      l_plan,l_version,l_fecha_regular, l_cond_regularidad, l_resultado,l_nota,
      l_pct_asistencia,l_acta_promocion,  l_folio_promocion,  l_renglon_promoc,  l_acta_regular,
      l_folio_regular, l_renglon_regular,  l_promocional,  l_controlado, l_apellido_alumno,  l_nombre_alumno, vcArchivoFoto,l_nro_documento
    FROM tmp_cursadas_pend
    ORDER BY folio_regular, renglon_regular

    IF l_resultado = 'N' THEN
      LET l_resultado = NULL;
      LET l_cond_regularidad = NULL;
      --    LET l_nota = NULL;
    END IF;

    IF l_resultado IS NULL THEN
      LET l_tiene_nota = 'N';
    ELSE
      LET l_tiene_nota = 'S';
    END IF;

    RETURN l_unidad_academica, l_carrera, l_legajo, l_comision, l_plan, l_version, 
        l_fecha_regular, l_cond_regularidad, l_resultado, l_nota, l_pct_asistencia,
        l_acta_promocion, l_folio_promocion, l_renglon_promoc, l_acta_regular, l_folio_regular,
        l_renglon_regular, l_promocional, l_controlado, l_apellido_alumno, l_nombre_alumno, l_agregado, l_tiene_nota, vcArchivoFoto,l_nro_documento WITH RESUME;
  END FOREACH;

 ELIF p_tipo = 'MP' or p_tipo = 'RP' THEN
   -- Recupero alumnos de Cursada Pendiente para Modificacion de Acta de promocionales
   -- o para Rectificación de Actas de Promoción.
   -- Ordenados por folio_promocion y renglon_promocion
   FOREACH SELECT * INTO l_unidad_academica, l_carrera,   l_legajo,l_comision,  
        l_plan,l_version,l_fecha_regular, l_cond_regularidad, l_resultado,l_nota,
        l_pct_asistencia,l_acta_promocion,  l_folio_promocion,  l_renglon_promoc,  l_acta_regular,
        l_folio_regular, l_renglon_regular,  l_promocional,  l_controlado,  l_apellido_alumno, l_nombre_alumno, vcArchivoFoto,l_nro_documento
      FROM tmp_cursadas_pend
      WHERE	promocional = 'S'
      ORDER BY folio_promocion, renglon_promocion


     IF l_cond_regularidad IS NULL THEN
       LET l_tiene_nota = 'N';
     ELSE
       LET l_tiene_nota = 'S';
     END IF;

     -- Si no es una PROMOCION ni un AUSENTE, entonces devuelvo un NO PROMOCIONO.
     IF (l_resultado <> 'P' AND l_resultado <> 'U') or l_resultado IS NULL THEN       --##AUSENTE
        -- Si el resultado no es Promocion entonces ubico la condicion de No Promocionado.
       --  LET l_nota = NULL;  -- Dejo la nota que esta cargada !
       LET l_resultado = 'N';
       LET l_cond_regularidad = l_cond_reg_no_prom;
     END IF;


--	IF l_resultado IS NULL THEN
--		LET l_tiene_nota = 'N';
--	ELSE
--		LET l_tiene_nota = 'S';
--	END IF;

   RETURN l_unidad_academica, l_carrera, l_legajo, l_comision, l_plan, l_version, 
          l_fecha_regular, l_cond_regularidad, l_resultado, l_nota, l_pct_asistencia,
          l_acta_promocion, l_folio_promocion, l_renglon_promoc, l_acta_regular, l_folio_regular,
          l_renglon_regular, l_promocional, l_controlado,l_apellido_alumno, l_nombre_alumno, l_agregado, l_tiene_nota, vcArchivoFoto,l_nro_documento  WITH RESUME;
  END FOREACH;

 ELIF p_tipo = 'CP' THEN
	-- Recupero alumnos de Cursada Pendiente para el Cerrado de Acta de promocionales
	-- Ordenados por folio_promocion y renglon_promocion

	-- Estoy en el Cerrado de Actas de Promociones
	-- Veo si debo mostrar o no los alumnos que no estan Promocionados
	execute procedure sp_param_sistema('muestra_alumnos_no_promocionados') INTO l_recupera_no_prom;
	IF l_recupera_no_prom <> 'S' and l_recupera_no_prom <> 's' THEN
		LET l_recupera_no_prom = 'N';
		-- Selecciono la Cantidad de Renglones por folio del unico Acta de Promocion
		-- abierta para esta comision.
		SELECT renglones_folio INTO l_cnt_lineas_folio
			FROM sga_actas_promo
			WHERE  comision = p_comision
			  AND estado = 'A';
		IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
			-- Error
			raise exception -746,0,'No se pudo recuperar la Cantidad de Renglones por Folio del Acta.';
 		END IF;

	ELSE
		LET l_recupera_no_prom = 'S';
	END IF;

	LET l_folio   = 1;
	LET l_renglon = 0;

   FOREACH SELECT *  INTO l_unidad_academica, l_carrera,   l_legajo,l_comision,  
       l_plan,l_version,l_fecha_regular, l_cond_regularidad, l_resultado,l_nota,
       l_pct_asistencia,l_acta_promocion,  l_folio_promocion,  l_renglon_promoc,  l_acta_regular,
       l_folio_regular, l_renglon_regular,  l_promocional,  l_controlado,  l_apellido_alumno, l_nombre_alumno, vcArchivoFoto,l_nro_documento
     FROM tmp_cursadas_pend
     WHERE promocional = 'S'
     ORDER BY folio_regular, renglon_regular
	
	IF l_recupera_no_prom = 'N' THEN

	    IF l_resultado <> 'P' THEN
		-- No visualizo este Alumno. Porque no Promociono
		CONTINUE FOREACH;
	    END IF;
	    LET l_renglon = l_renglon + 1;
	    -- Recalculo Nro de Folio y renglon
	   IF l_renglon   > l_cnt_lineas_folio THEN
		LET l_renglon = 1;
		LET l_folio   = l_folio + 1;
	   END IF;
	ELSE 
	    LET l_folio   = l_folio_promocion;
	    LET l_renglon = l_renglon_promoc;
	 END IF;
	 
	-- Si no es una PROMOCION ni un AUSENTE, entonces devuelvo un NO PROMOCIONO.
	IF (l_resultado <> 'P' AND l_resultado <> 'U') or l_resultado IS NULL THEN       --##AUSENTE
	   -- Si el resultado no es Promocion entonces ubico la condicion de No Promocionado.
	   --  LET l_nota = NULL;  -- Dejo la nota que esta cargada !
	   LET l_resultado = 'N';
	   LET l_cond_regularidad = l_cond_reg_no_prom;
	END IF;

	IF l_resultado IS NULL THEN
		LET l_tiene_nota = 'N';
	ELSE
		LET l_tiene_nota = 'S';
	END IF;
	
	 RETURN l_unidad_academica, l_carrera, l_legajo, l_comision, l_plan, l_version, 
		 l_fecha_regular, l_cond_regularidad, l_resultado, l_nota, l_pct_asistencia,
		 l_acta_promocion, l_folio, l_renglon, l_acta_regular, l_folio_regular,
		 l_renglon_regular, l_promocional, l_controlado, l_apellido_alumno, l_nombre_alumno, l_agregado, l_tiene_nota, vcArchivoFoto,l_nro_documento WITH RESUME;

	END FOREACH;
 END IF;

BEGIN
  on exception in (-206)
  end exception with resume;
  DROP TABLE tmp_cursadas_pend;
END;

END IF;  -- DBINFO()
END PROCEDURE;
--+++++++++++++++++++++++++++++++ Fin procedure sp820_alumnos_com +++++++++++++++++++++++++++++++++++++++++

