CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_crea_acta') THEN
		DROP PROCEDURE sp_crea_acta;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- Personalizacion: UNS
--
-- Crea un Acta de Examen a partir de una Mesa de Examen para un LLamado.
-- Si la Mesa de Examen no tiene inscriptos, igual crea la Cabecera del Acta de
-- Examen pero sin detalle, ni folios.
--
-- Recibe:   - Unidad Academica
--	     - Materia
--	     - Anio_Academico
--	     - Turno de Examen
--	     - Mesa de Examen
--	     - Llamado      (Si la Generacion del Acta es por Turno, esta debe venir en NULL)
--	     - Tipo de Acta
--      - Libro de Actas (Puede venir en Nulo)
--
--      - Nro de Acta    (Si viene en nulo, se genera automaticamente)
--
-- Retorna:  - Numero de Acta
--
-- Versión 1.3.0
-- Modificado: Version 1.5
-- Modificada: Version 1.11, 2.03.0, 2.05.0, 2.6.0
-- Se saco el WITH NO LOG porque no recupera los registros ordenados si existe mas de un dbspace temporal.
-- *****************************************************************************
-- DROP PROCEDURE sp_crea_acta;
CREATE PROCEDURE "dba".sp_crea_acta
   (p_unidad_academica  LIKE sga_listado_examen.unidad_academica,
    p_materia LIKE sga_actas_examen.materia ,
    p_anio_academico LIKE sga_actas_examen.anio_academico ,
    p_turno_examen LIKE sga_actas_examen.turno_examen ,
    p_mesa_examen  LIKE sga_actas_examen.mesa_examen ,
    p_llamado LIKE sga_actas_examen.llamado ,
    p_tipo_acta    LIKE  sga_actas_examen.tipo_acta,
    p_libro    LIKE  sga_actas_examen.libro,
    p_acta    LIKE  sga_actas_examen.acta)
    returning varchar(10);

  DEFINE v_acta    LIKE  sga_actas_examen.acta;
  DEFINE cnt_reng_por_folio, cnt_insc, cnt_folios, i INTEGER;
  DEFINE l_unidad_academica  LIKE sga_listado_examen.unidad_academica;
  DEFINE l_controlado, l_equiv_parcial char(1);
  DEFINE l_carrera     LIKE sga_detalle_acta.carrera;
  DEFINE vc_carrera     LIKE sga_detalle_acta.carrera;
  DEFINE l_legajo      LIKE sga_detalle_acta.legajo;
  DEFINE l_fecha_de_examen  LIKE  sga_detalle_acta.fecha_de_examen;
  DEFINE l_plan       LIKE  sga_detalle_acta.plan;
  DEFINE l_version     LIKE  sga_detalle_acta.version;
  DEFINE l_tipo_inscripcion LIKE sga_detalle_acta.tipo_inscripcion;
  DEFINE v_escala_notas LIKE sga_actas_examen.escala_notas;
  DEFINE l_folio, l_renglon, l_orden INTEGER;
  DEFINE sql_err int;
  DEFINE isam_err int;
  DEFINE error_info varchar(70);
  DEFINE vGeneraActa LIKE sga_param_sistema.valor;

  on exception set sql_err, isam_err, error_info
    -- error
    Rollback Work;
    raise exception  sql_err, isam_err, error_info;
  end exception;

-- U820 ************************************************************************************************
-- Llamada para actualizar la condicion de Regularidad en la Inscripción a Exámenes
-- Para el caso FCJS, no se realiza dicho recálculo ya que la elección de la inscripción la realiza el alumno (no es automática), y esto podría implicar la decisión de no hacer uso de la regularidad (rendir libre) obtenida por parte del mismo. (Condición administrativa que se maneja a partir del turno Noviembre-Dicimebre 2013 por sistema)
-- U820 ************************************************************************************************

IF (select trim(nombre) from sga_valor_inicial vi
	join sga_unidades_acad ua
	on vi.unidad_academica = ua.unidad_academica) <> "Facultad de Ciencias Jurídicas y Sociales" THEN

	execute procedure sp820_cambio_in_exa (p_unidad_academica, p_anio_academico, p_turno_examen, p_mesa_examen, p_llamado, p_materia);
END IF;

 begin work;
   -- +++++++++++++++++++++++++++++++++++++ Controles +++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- Controlo que no haya ya un Acta para la Mesa de Examen para
   -- para este llamado pasado como parametro.
   IF p_llamado IS NULL THEN
	-- El acta se genera para el Turno. Controlo si existe algun
	-- acta para esta mesa en este Turno de examen
	IF (SELECT COUNT(*) FROM sga_actas_examen
		WHERE  sga_actas_examen.unidad_academica = p_unidad_academica  AND
			sga_actas_examen.materia         = p_materia  AND
		        sga_actas_examen.anio_academico  = p_anio_academico  AND
		        sga_actas_examen.turno_examen    = p_turno_examen  AND
		        sga_actas_examen.mesa_examen     = p_mesa_examen  AND
		        sga_actas_examen.estado <> 'B') > 0 THEN

        -- Esto hace que se ejecute el "on exception"
        raise exception -746,0,'Ya existe un Acta de Examen generada para la Mesa ' || p_mesa_examen || '.';
	END IF;
    ELSE
	-- El acta se genera para una Mesa en un LLamado.
	-- Controlo si existe algun acta para esta mesa en ese llamado
	IF (SELECT COUNT(*)   FROM sga_actas_examen
		WHERE sga_actas_examen.unidad_academica = p_unidad_academica
          	 AND  sga_actas_examen.materia        = p_materia
		 AND  sga_actas_examen.anio_academico = p_anio_academico
		 AND  sga_actas_examen.turno_examen   = p_turno_examen
		 AND  sga_actas_examen.mesa_examen    = p_mesa_examen
	         AND  sga_actas_examen.llamado        = p_llamado
		 AND  sga_actas_examen.estado <> 'B') > 0 THEN
    	    raise exception -746,0,'Ya existe un Acta de Examen generada para la Mesa ' || p_mesa_examen || ' en el Llamado ' || p_llamado;
	END IF;
   END IF;

   -- Valido que el Acta no exista!!!
   IF p_acta IS NOT NULL AND TRIM(p_acta) <> '' THEN
   	IF (SELECT COUNT(*) FROM sga_actas_examen
		WHERE sga_actas_examen.unidad_academica = p_unidad_academica
		AND sga_actas_examen.tipo_acta = p_tipo_acta
		AND sga_actas_examen.acta = p_acta) > 0 THEN
    	    raise exception -746,0,'Ya existe el Acta de Examen Nro: ' || p_acta;
	END IF;
   END IF;

   -- Verifico si debo generar el Acta si no hay Inscriptos a Examen
   Execute procedure sp_param_sistema ('genera_acta_examen_si_no_hay_inscriptos') INTO vGeneraActa;
   IF vGeneraActa <> 'S'  THEN
      IF (SELECT COUNT(*) FROM sga_insc_examen
	WHERE sga_insc_examen.unidad_academica = p_unidad_academica
          	 AND  sga_insc_examen.materia        = p_materia
	 AND  sga_insc_examen.anio_academico = p_anio_academico
	 AND  sga_insc_examen.turno_examen    = p_turno_examen
	 AND  sga_insc_examen.mesa_examen    = p_mesa_examen
	 AND  sga_insc_examen.llamado               = p_llamado
	 AND  sga_insc_examen.estado IN ('A','E')) <= 0 THEN
	raise exception -746,0,'No se permite generar el Acta de Ex. porque no hay inscriptos.';
     END IF;	
   END IF;
   -- +++++++++++++++++++++++++++++++++++++ Fin Controles +++++++++++++++++++++++++++++++++++++++++++++++++++++++

   -- +++++++++++++++++++++++++++++++++++++ Parametros del Sistema ++++++++++++++++++++++++++++++++++++++++++++
   -- Selecciono el tipo de Ordenamiento. Valores posibles: 1 (legajo) 2 (ape y nom) 3 (tipo y nro doc) 4 (orden de inscripcion)
   Execute procedure sp_param_sistema ('orden_detalle_actas_examen') INTO l_orden;
   IF l_orden IS NULL or l_orden <= 0 or l_orden > 4 THEN
      raise exception -746,0,'Se debe definir el tipo de ordenamiento del detalle del Acta en Param del Sist.';
   END IF;

   -- Selecciono la cantidad de renglones definidos por por folio
   Execute procedure sp_param_sistema ('lineas_folio') INTO cnt_reng_por_folio;
   IF cnt_reng_por_folio IS NULL or cnt_reng_por_folio <= 0 THEN
     raise exception -746,0,'Se debe ingresar la cant. de reng/folio en los parametros';
   END IF;
   -- +++++++++++++++++++++++++++++++++++++ Fin Parametros del Sistema ++++++++++++++++++++++++++++++++++++++++++++

   -- Selecciono las inscripciones de un Listado de examen
   BEGIN 
	on exception in (-206)
	  -- Tabla no existe continuo el proceso
	end exception with resume;
	DROP TABLE temp_insc;
   END;

   IF p_llamado IS NULL THEN

 -- +++++++++++++++++++++++ ATENCION +++++++++++++++++++++++++++++++
 -- Cuando el acta es para todo el turno, que selecciono por cada alumno. Si solo
 -- un registro o uno por cada llamado. Cuantas instancias creo en el detalle
 -- del Acta por Cada Alumno (de acuerdo a los llamados del turno)
 -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

     -- Recupero la Fecha del Examen

     -- El Acta de Examen se realiza para todo el turno.
     -- Recupero todas las insc para la Mesa-turno
     SELECT {+ ordered} DISTINCT insc.unidad_academica  unidad_academica,
	    insc.carrera  carrera,
            insc.legajo  legajo,
            insc.materia  materia,
            insc.anio_academico  anio_academico,
            insc.turno_examen  turno_examen,
            insc.mesa_examen mesa_examen,
            insc.llamado llamado,
            insc.tipo_inscripcion  tipo_inscripcion,
            insc.equiv_parcial  equiv_parcial,
            sga_prestamos.fecha fecha_de_examen,
            sga_personas.apellido apellido,
            sga_personas.nombres nombres,
 		insc.plan,     -- Se agregó plan de la inscripción a examen
		insc.version    -- Se agregó versión de la inscripción a examen
       FROM sga_insc_examen  insc,
	    sga_llamados_mesa,
	    sga_alumnos,
	    sga_personas,
       sga_prestamos
        WHERE insc.unidad_academica = p_unidad_academica
          AND insc.materia          = p_materia
          AND insc.anio_academico   = p_anio_academico
          AND insc.turno_examen     = p_turno_examen
          AND insc.mesa_examen      = p_mesa_examen
          AND (insc.estado = 'A' OR insc.estado = 'E')
          AND sga_llamados_mesa.unidad_academica = insc.unidad_academica
          AND sga_llamados_mesa.materia        = insc.materia
          AND sga_llamados_mesa.anio_academico = insc.anio_academico
          AND sga_llamados_mesa.turno_examen   = insc.turno_examen
          AND sga_llamados_mesa.mesa_examen    = insc.mesa_examen
	  AND sga_alumnos.unidad_academica = insc.unidad_academica
          AND sga_alumnos.carrera  = insc.carrera
          AND sga_alumnos.legajo   = insc.legajo
          AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
          AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion
          AND sga_llamados_mesa.prestamo    = sga_prestamos.prestamo
        ORDER BY sga_personas.apellido ASC,
		 sga_personas.nombres
        INTO TEMP temp_insc;

   ELSE
        -- Selecciono la Fecha del Examen del LLamado
        SELECT  {+ ordered} sga_prestamos.fecha 
	INTO l_fecha_de_examen
	FROM  sga_llamados_mesa  llm, sga_prestamos
	WHERE llm.unidad_academica = p_unidad_academica
		AND llm.materia        = p_materia
		AND llm.anio_academico = p_anio_academico
		AND llm.turno_examen   = p_turno_examen
		AND llm.mesa_examen    = p_mesa_examen
		AND llm.llamado        = p_llamado
		AND llm.prestamo    = sga_prestamos.prestamo;
    IF DBINFO("sqlca.sqlerrd2") <= 0 THEN
      raise exception -746,0,'No se pudo recuperar la Fecha del Examen';
    END IF;

     ---------------------------------------------------------------
     -- El Acta de Examen se realiza para un llamado del turno.
     -- Recupero todas las insc para la Mesa-Llamado
     ---------------------------------------------------------------
     IF l_orden = 1 THEN
	  -- Detalle Ordenado por Legajo
	  SELECT {+ ordered} DISTINCT insc.unidad_academica  unidad_academica,
	    insc.carrera  carrera,
            insc.legajo  legajo,
            insc.materia  materia,
            insc.anio_academico  anio_academico,
            insc.turno_examen  turno_examen,
            insc.mesa_examen mesa_examen,
            insc.llamado llamado,
            insc.tipo_inscripcion  tipo_inscripcion,
            insc.equiv_parcial  equiv_parcial,
            l_fecha_de_examen   fecha_de_examen,
 		insc.plan,     -- Se agregó plan de la inscripción a examen
		insc.version    -- Se agregó versión de la inscripción a examen
          FROM sga_insc_examen  insc,
	    sga_alumnos
          WHERE insc.unidad_academica = p_unidad_academica
		AND insc.materia        = p_materia
		AND insc.anio_academico = p_anio_academico
		AND insc.turno_examen   = p_turno_examen
		AND insc.mesa_examen    = p_mesa_examen
		AND insc.llamado        = p_llamado
		AND (insc.estado = 'A' OR insc.estado = 'E')
		AND sga_alumnos.unidad_academica = insc.unidad_academica
		AND sga_alumnos.carrera = insc.carrera
		AND sga_alumnos.legajo  = insc.legajo
	  ORDER BY insc.legajo  ASC
	  INTO TEMP temp_insc;

	ELIF l_orden = 2 THEN
	  -- Detalle Ordenado por Apellido y Nombre
	  SELECT {+ ordered} DISTINCT insc.unidad_academica  unidad_academica,
	    insc.carrera  carrera,
            insc.legajo  legajo,
            insc.materia  materia,
            insc.anio_academico  anio_academico,
            insc.turno_examen  turno_examen,
            insc.mesa_examen mesa_examen,
            insc.llamado llamado,
            insc.tipo_inscripcion  tipo_inscripcion,
            insc.equiv_parcial  equiv_parcial,
            l_fecha_de_examen  fecha_de_examen,
            sga_personas.apellido apellido,
            sga_personas.nombres nombres,
 		insc.plan,     -- Se agregó plan de la inscripción a examen
		insc.version    -- Se agregó versión de la inscripción a examen
          FROM sga_insc_examen  insc,
	    sga_alumnos,
	    sga_personas
          WHERE insc.unidad_academica = p_unidad_academica
		AND insc.materia        = p_materia
		AND insc.anio_academico = p_anio_academico
		AND insc.turno_examen   = p_turno_examen
		AND insc.mesa_examen    = p_mesa_examen
		AND insc.llamado        = p_llamado
		AND (insc.estado = 'A' OR insc.estado = 'E')
		AND sga_alumnos.unidad_academica = insc.unidad_academica
		AND sga_alumnos.carrera = insc.carrera
		AND sga_alumnos.legajo  = insc.legajo
		AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
		AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion
	  ORDER BY sga_personas.apellido ASC,
                sga_personas.nombres
	  INTO TEMP temp_insc;

	ELIF l_orden = 3  THEN
	  -- Detalle Ordenado por Tipo y Nro de documento
	  SELECT {+ ordered} DISTINCT insc.unidad_academica  unidad_academica,
	    insc.carrera  carrera,
            insc.legajo  legajo,
            insc.materia  materia,
            insc.anio_academico  anio_academico,
            insc.turno_examen  turno_examen,
            insc.mesa_examen mesa_examen,
            insc.llamado llamado,
            insc.tipo_inscripcion  tipo_inscripcion,
            insc.equiv_parcial  equiv_parcial,
            l_fecha_de_examen  fecha_de_examen,
            mdp_tipo_documento.descripcion tipo_documento,
            sga_personas.nro_documento nro_documento,
 		insc.plan,     -- Se agregó plan de la inscripción a examen
		insc.version    -- Se agregó versión de la inscripción a examen
          FROM sga_insc_examen  insc,
	    sga_alumnos,
	    sga_personas,
	    mdp_tipo_documento
          WHERE insc.unidad_academica = p_unidad_academica
		AND insc.materia        = p_materia
		AND insc.anio_academico = p_anio_academico
		AND insc.turno_examen   = p_turno_examen
		AND insc.mesa_examen    = p_mesa_examen
		AND insc.llamado        = p_llamado
		AND (insc.estado = 'A' OR insc.estado = 'E')
		AND sga_alumnos.unidad_academica = insc.unidad_academica
		AND sga_alumnos.carrera = insc.carrera
		AND sga_alumnos.legajo  = insc.legajo
		AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
		AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion
		AND sga_personas.tipo_documento  = mdp_tipo_documento.tipo_documento
	  ORDER BY mdp_tipo_documento.descripcion ASC,
            	   sga_personas.nro_documento ASC
	  INTO TEMP temp_insc;

    ELIF l_orden = 4  THEN
      -- Detalle Ordenado por orden de inscripcion
	  SELECT {+ ordered} DISTINCT insc.unidad_academica  unidad_academica,
	    insc.carrera  carrera,
            insc.legajo  legajo,
            insc.materia  materia,
            insc.anio_academico  anio_academico,
            insc.turno_examen  turno_examen,
            insc.mesa_examen mesa_examen,
            insc.llamado llamado,
            insc.tipo_inscripcion  tipo_inscripcion,
            insc.equiv_parcial  equiv_parcial,
            l_fecha_de_examen  fecha_de_examen,
            mdp_tipo_documento.descripcion tipo_documento,
            sga_personas.nro_documento nro_documento
            , insc.fecha_inscripcion,
 		insc.plan,     -- Se agregó plan de la inscripción a examen
		insc.version    -- Se agregó versión de la inscripción a examen
          FROM sga_insc_examen  insc,
	    sga_alumnos,
	    sga_personas,
	    mdp_tipo_documento
          WHERE insc.unidad_academica = p_unidad_academica
		AND insc.materia        = p_materia
		AND insc.anio_academico = p_anio_academico
		AND insc.turno_examen   = p_turno_examen
		AND insc.mesa_examen    = p_mesa_examen
		AND insc.llamado        = p_llamado
		AND (insc.estado = 'A' OR insc.estado = 'E')
		AND sga_alumnos.unidad_academica = insc.unidad_academica
		AND sga_alumnos.carrera = insc.carrera
		AND sga_alumnos.legajo  = insc.legajo
		AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
		AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion
		AND sga_personas.tipo_documento  = mdp_tipo_documento.tipo_documento
      ORDER BY insc.fecha_inscripcion ASC
	  INTO TEMP temp_insc;
     END IF;
   END IF;

   -- Recupero la Cantidad de registros seleccionados
   LET cnt_insc = DBINFO("sqlca.sqlerrd2");

   -- ******************************************************************************
   -- Recupero el Nro de Libro si viene en Nulo
   -- ******************************************************************************
   IF p_libro IS NULL THEN
     	Execute procedure sp_libroactaexamen(p_unidad_academica, p_materia, p_anio_academico , p_turno_examen , p_mesa_examen, p_llamado, p_tipo_acta)  INTO p_libro;

   END IF;

   -- ******************************************************************************
   -- Recupero el Nro de Acta
   -- ******************************************************************************
   IF p_acta IS NOT NULL AND TRIM(p_acta) <> '' THEN
	   LET v_acta = p_acta;
   ELSE
     Execute procedure sp_gen_nro_acta(p_unidad_academica , p_materia, p_anio_academico, p_turno_examen, p_mesa_examen, p_llamado, p_tipo_acta, p_libro)  INTO v_acta;
  
     IF v_acta IS NULL or TRIM(v_acta) = '' THEN
   	raise exception -746,0,'Error al generar el Numero de Acta.';
     END IF;
   END IF;

   -----------------------------------------------------------
   -- Busca la escala de notas de la materia
   -----------------------------------------------------------
   SELECT escala_notas
     INTO v_escala_notas
     FROM sga_mesas_examen
    WHERE sga_mesas_examen.unidad_academica = p_unidad_academica
      AND sga_mesas_examen.materia = p_materia
      AND sga_mesas_examen.anio_academico = p_anio_academico
      AND sga_mesas_examen.turno_examen = p_turno_examen
      AND sga_mesas_examen.mesa_examen = p_mesa_examen;

   -----------------------------------------------------------
   -- Busca la la carrera de la mesa
   -----------------------------------------------------------
   SELECT carrera
     INTO vc_carrera
     FROM sga_mesas_examen
    WHERE sga_mesas_examen.unidad_academica = p_unidad_academica
      AND sga_mesas_examen.materia = p_materia
      AND sga_mesas_examen.anio_academico = p_anio_academico
      AND sga_mesas_examen.turno_examen = p_turno_examen
      AND sga_mesas_examen.mesa_examen = p_mesa_examen;

	-----------------------------------------------------------
	-- Genero la Cabecera del Acta
	-----------------------------------------------------------
	INSERT INTO sga_actas_examen
	       (sga_actas_examen.unidad_academica,
                sga_actas_examen.tipo_acta,
                sga_actas_examen.acta,
                sga_actas_examen.materia,
                sga_actas_examen.anio_academico,
                sga_actas_examen.turno_examen,
                sga_actas_examen.mesa_examen,
                sga_actas_examen.llamado,
                sga_actas_examen.carrera,
                sga_actas_examen.libro,
                sga_actas_examen.escala_notas,
                sga_actas_examen.fecha_generacion,
                sga_actas_examen.nro_ultima_copia,
                sga_actas_examen.version,
                sga_actas_examen.version_impresa,
                sga_actas_examen.renglones_folio,
                sga_actas_examen.rectificada,
                sga_actas_examen.estado)
   	VALUES (p_unidad_academica,
		p_tipo_acta,
		v_acta,
	        p_materia,
                p_anio_academico,
                p_turno_examen,
         	p_mesa_examen,
         	p_llamado,
	vc_carrera,
         	p_libro,
         	v_escala_notas,
		TODAY,
		0,
		1,
		0,
		cnt_reng_por_folio,
		'N',
		'A');

   IF cnt_insc > 0 THEN
	-----------------------------------------------------------
	-- Genero los Folios del Acta
	-- Calculo la cantidad de Folios que se deben generar de acuerdo
	-- a la cantidad de inscriptos que existen en la mesa de examen.
	-----------------------------------------------------------
	IF MOD(cnt_insc, cnt_reng_por_folio) <> 0 THEN
	   -- La cantidad de folios = a la division entera entera del cociente que resulta de
	   -- de la cant de inscriptos y la cant de renglones por folio.
	   LET cnt_folios = TRUNC(cnt_insc / cnt_reng_por_folio,0) + 1;
	ELSE
	   LET cnt_folios = cnt_insc / cnt_reng_por_folio;
	END IF;

        -- Genero los registros en la tabla de Folios
	FOR i = 1 TO cnt_folios
	  INSERT INTO sga_folios (unidad_academica, tipo_acta, acta, folio )
		          VALUES (p_unidad_academica, p_tipo_acta, v_acta, i);
	END FOR;

	-----------------------------------------------------------
	-- Genero el Detalle del Acta
	-----------------------------------------------------------

    -- Debo calcular el folio y renglon de cada registro del detalle del Acta
    LET l_renglon = 0;
    LET l_folio = 1;

    ----------------------------------------------------------------------------
    --	Recupero de parametros del sistema el param que indica si seteo el campo
    -- controlado del detalle de Acta como examen a controlar o no.
    ----------------------------------------------------------------------------
    Execute procedure sp_param_sistema('controla_detalle_acta') INTO l_controlado;
    If l_controlado = 's' or l_controlado = 'S' THEN
	-- Seteo el detalle del Acta como que no esta controlado
	LET l_controlado = 'N';
    ELSE
	-- Seteo el detalle del Acta como que esta controlado.
	LET l_controlado = 'S';
    END IF;

    FOREACH SELECT temp_insc.unidad_academica,
        	temp_insc.carrera,
		temp_insc.legajo,
	 	temp_insc.tipo_inscripcion,
        	temp_insc.equiv_parcial,
		temp_insc.fecha_de_examen,
		temp_insc.plan,
		temp_insc.version
	INTO l_unidad_academica, l_carrera, l_legajo, l_tipo_inscripcion,
	     l_equiv_parcial, l_fecha_de_examen, l_plan, l_version
	FROM temp_insc

	------------------------------------------------------------------------------
        -- Calculo el Folio y Renglon
	------------------------------------------------------------------------------
        LET l_renglon = l_renglon + 1;
        IF l_renglon > cnt_reng_por_folio THEN
	   -- Nuevo Folio
	   LET l_renglon = 1;
	   LET l_folio = l_folio + 1;
        END IF

	------------------------------------------------------------------------------
	-- Inserto los datos en el Detalle del Acta
	------------------------------------------------------------------------------
 	INSERT INTO sga_detalle_acta
                (unidad_academica, tipo_acta, acta, carrera, legajo,
	         folio, renglon, tipo_inscripcion, equiv_parcial,
        	 fecha_de_examen, plan, version, controlado, rectificado, estado)
	 VALUES (l_unidad_academica, p_tipo_acta, v_acta, l_carrera, l_legajo,
		 l_folio, l_renglon, l_tipo_inscripcion, l_equiv_parcial,
		 l_fecha_de_examen, l_plan, l_version, l_controlado, 'N', 'A');
     END FOREACH;
   ELSE
	-- El acta no tiene alumnos. Es un Acta en Blanco (1 Folio en blanco)
	-- Asi que agrego un registro en la tabla de Folios

	INSERT INTO sga_folios (unidad_academica, tipo_acta, acta, folio )
	       VALUES (p_unidad_academica, p_tipo_acta, v_acta, 1);
   END IF;

   -- Borro la tabla temporal
   BEGIN 
     on exception in (-206)
      -- Tabla no existe continuo el proceso
     end exception with resume;
     DROP TABLE temp_insc;
   END;

-- Si todo esta correcto realizo el Commit work
Commit Work;

Return v_acta;

end procedure;
-- ******************* Fin del procedure sp_crea_acta **************************

revoke execute on sp_crea_acta from public;

grant execute on sp_crea_acta to guarani; -- Rol de usuarios de Gestión
grant execute on sp_crea_acta to internet; -- Usuario de internet