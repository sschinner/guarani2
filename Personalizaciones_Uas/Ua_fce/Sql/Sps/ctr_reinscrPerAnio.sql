DROP PROCEDURE "dba".ctr_reinscrperanio;
CREATE PROCEDURE "dba".ctr_reinscrperanio(
	pUnidadAcademica  LIKE sga_personas.unidad_academica,
	pNroInscripcion   LIKE sga_personas.nro_inscripcion,
	pAnio_academico        LIKE sga_anio_academico.anio_academico)
	RETURNING smallint, varchar(255);


-- vars para la respuesta
DEFINE iStatus             smallint;
DEFINE vcMsg               varchar(255);

-- vars para el manejo de excepciones
DEFINE sql_err             integer;
DEFINE isam_err            integer;
DEFINE error_info          varchar(76);

-- vars locales
DEFINE v_cntReinsc,v_cntNoReinsc       integer;
DEFINE v_carreraNoReinsc   like sga_carreras.carrera;
DEFINE v_carNomNoReinsc    like sga_carreras.nombre_reducido;
DEFINE v_NomCarreras       varchar(255);
DEFINE v_ReinsAluIng, vcEsIngresante       char(1);
DEFINE v_legajo            like sga_alumnos.legajo;

DEFINE dFechaIngreso       like sga_alumnos.fecha_ingreso;


-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   -- RAISE EXCEPTION  sql_err,isam_err, error_info;
   LET iStatus = -1 ;
   LET vcMsg = '800321' || ',' || 'reinscripcion' || ',' || sql_err || ' - '  || error_info ;
   RETURN iStatus, vcMsg ;
END EXCEPTION;

BEGIN
   
   -- Inicia las variables
   LET v_cntNoReinsc = 0;

 LET v_NomCarreras = '';
   
   -- Verifico el parametro si reinscribe o no a los alumnos ingresantes!
   EXECUTE PROCEDURE sp_param_sistema('reinscripcion_ingresante') INTO v_ReinsAluIng;
   
   
   
   -- Se fija si la persona está reinscripta enalguna carrera
   SELECT count(*)
     INTO v_cntReinsc
     FROM sga_reinscripcion,
          sga_alumnos
    WHERE sga_alumnos.unidad_academica = pUnidadAcademica
      AND sga_alumnos.nro_inscripcion = pNroInscripcion
      AND sga_alumnos.unidad_academica = sga_reinscripcion.unidad_academica
      AND sga_alumnos.carrera = sga_reinscripcion.carrera
      AND sga_alumnos.legajo = sga_reinscripcion.legajo
      AND sga_reinscripcion.anio_academico = panio_academico;
   
   -- Se fija si le falta la reinscripción en alguna carrera
   FOREACH SELECT sga_alumnos.carrera, sga_alumnos.legajo, sga_carreras.nombre_reducido
      INTO v_carreraNoReinsc, v_legajo, v_carNomNoReinsc
      FROM sga_alumnos, sga_carreras
     WHERE sga_alumnos.unidad_academica = pUnidadAcademica
       AND sga_alumnos.nro_inscripcion = pNroInscripcion
       AND sga_carreras.unidad_academica = sga_alumnos.unidad_academica
       AND sga_carreras.carrera = sga_alumnos.carrera
       AND (sga_carreras.tipo_de_carrera = 'C' or sga_carreras.tipo_de_carrera = 'B' )
       AND NOT EXISTS (SELECT ''   FROM sga_reinscripcion
                        WHERE sga_alumnos.unidad_academica = sga_reinscripcion.unidad_academica
                          AND sga_alumnos.carrera = sga_reinscripcion.carrera
                          AND sga_alumnos.legajo = sga_reinscripcion.legajo
                          AND sga_reinscripcion.anio_academico = panio_academico)
      
       -- NUEVO FILTRO OBLIGATORIO, SOLO PARA CARRERAS DE GRADO!!!!

      -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- VERIFICO SI EL ALUMNO ES INGRESANTE EN LA CARRERA.
      -- Si tiene un registro en el periodo de INscripcion del Año Academico Actual
      -- entonces es un alumno Ingresante.	
      -- Situacion Aspirante -> Resultado = I.
      -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      EXECUTE PROCEDURE sp_es_ingr_anio(pUnidadAcademica, v_carreraNoReinsc, v_legajo, panio_academico) INTO vcEsIngresante;
      IF vcEsIngresante = 'S' THEN
         -- La Persona es ingresante en la carrera "v_carreraNoReinsc"
         IF v_ReinsAluIng = 'S' THEN
            -- ERROR!!! Es Ingresante y NO esta REINSCRIPTO

-- POR PARAMETRO TENDRIA QUE REINSCRIBIRSE!!!
            -- Va guardando los nombres de las carreras
            LET v_cntNoReinsc = v_cntNoReinsc + 1;
            LET v_NomCarreras = v_NomCarreras || ', ' || v_carreraNoReinsc;
         END IF;

 ELSE
         -- ERROR!!! NO ES INGRESANTE y no esta REINSCRIPTO
         -- Va guardando los nombres de las carreras
         LET v_cntNoReinsc = v_cntNoReinsc + 1;
         LET v_NomCarreras = v_NomCarreras || ', ' || v_carreraNoReinsc;
      END IF;
      -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      
   END FOREACH;
   
   -- Si hay alguna carrera en la que NO este reinscripto
   IF v_cntNoReinsc > 0 THEN
      -- Si hay alguna carrera en la que SI este reinscripto
      IF v_cntReinsc > 0 THEN -- CONTINUA
         -- OK
         LET iStatus = 1;
         LET vcMsg = '800320';
      ELSE -- ERROR, no esta reinscripto en ninguna carrera
         LET iStatus = -1;
         LET vcMsg = '800449';

      END IF;
   ELSE -- Esta reinscripto en todas las carreras
      -- OK
      LET iStatus = 1;
      LET vcMsg = '800320';
   END IF;
   
   RETURN iStatus, vcMsg;
   
END;
END PROCEDURE                                                                   
                                                                                                                                                                                                                                                              
