CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_reinscralumno') THEN
		DROP PROCEDURE ctr820_reinscralumno;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- PERSONALIZADO PARA CERTIFICADO ALUMNO REGULAR ONLINE, SE MODIFICA PARA QUE TOME EL ANIO CALENDARIO
-- SE MODIFICA PARA QUE LLAME AL sp820_es_ingresante, el cual se modifica para que controle contra el año calendario de igual manera que dicho control 
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.11.0
-- Ultima modificacion: Version 2.0.0,2.7.0
-- Procedure ctr_reinscrAlumno
-- 
-- Controla que la persona este reinscripta en alguna carrera en el año academico actual
-- Si le Persona es ingresante, no controla! 
-- VERIFICA QUE LA CARRERA SEA DE GRADO!!!! (tipo_de_carrera = 'C')
-- Verifica que la carrera sea del tipo que puede emitir certificado de alumno regular  ('C', 'P', 'R', 'T', 'S', 'B') OJO para cemed se debe agregar 'Q'=Pregrado ('C', 'P', 'R', 'T', 'S', 'B','Q') ya que en algunas UA lo tienen como Q;

-- *****************************************************************************

-- EXECUTE procedure ctr820_reinscrAlumno ('FBCB','00007','26020664-9','2016','')

-- DROP PROCEDURE "dba".ctr820_reinscrAlumno;
CREATE PROCEDURE "dba".ctr820_reinscrAlumno( pUnidadAcademica LIKE sga_alumnos.unidad_academica,
                                    pCarrera         LIKE sga_alumnos.carrera,
                                    pLegajo          LIKE sga_alumnos.legajo,
				    pAnio            LIKE sga_anio_academico.anio_academico,    
                                    pOperacion       LIKE acc_operaciones.operacion )

      RETURNING smallint, varchar(255);

-- vars para la respuesta
DEFINE iStatus             smallint;
DEFINE vcMsg               varchar(255);

-- vars para el manejo de excepciones
DEFINE sql_err             integer;
DEFINE isam_err            integer;
DEFINE error_info          varchar(76);

-- vars locales
--DEFINE v_anio              LIKE sga_anio_academico.anio_academico;
DEFINE v_cntReinsc, cnt    integer;
DEFINE v_NomCarrera        LIKE sga_carreras.nombre_reducido;
DEFINE vc_TipoCarrera      LIKE sga_carreras.tipo_de_carrera;
DEFINE v_ReinsAluIng       char(1);
DEFINE vcEsIngresante, vcCntrReinsc      char(1);
DEFINE vcNroInscripcion	   LIKE sga_personas.nro_inscripcion;
DEFINE dFechaIngreso       LIKE sga_alumnos.fecha_ingreso;

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   -- RAISE EXCEPTION  sql_err, isam_err, error_info;
   LET iStatus = -1 ;
   LET vcMsg = '800321' || ',' || 'reinscripcion' || ',' || sql_err || ' - '  || error_info ;
   RETURN iStatus, vcMsg ;
END EXCEPTION;

BEGIN
   
   -- Verifico el parametro si reinscribe o no a los alumnos ingresantes!
   EXECUTE PROCEDURE sp_param_sistema('reinscripcion_ingresante') INTO v_ReinsAluIng;
   
   -- Busca el año académico actual
   --SELECT YEAR(TODAY)
   --  INTO v_anio
   -- FROM sga_anio_academico
   -- WHERE TODAY BETWEEN fecha_inicio AND fecha_fin;
   
   -- Se fija si el alumno está reinscripto
   SELECT count(*)
     INTO v_cntReinsc
     FROM sga_reinscripcion,   sga_carreras, sga_tipos_carrera
    WHERE sga_reinscripcion.unidad_academica = pUnidadAcademica
      AND sga_reinscripcion.carrera = pCarrera
      AND sga_reinscripcion.legajo = pLegajo
      AND sga_reinscripcion.anio_academico = pAnio
      AND sga_carreras.unidad_academica = sga_reinscripcion.unidad_academica
      AND sga_carreras.carrera = sga_reinscripcion.carrera
      AND sga_carreras.tipo_de_carrera = sga_tipos_carrera.tipo_de_carrera
	AND sga_tipos_carrera.tipo_de_carrera IN ('C', 'P', 'R', 'T', 'S', 'B', 'W', 'Z');
   
   -- OK
   LET iStatus = 1;
   LET vcMsg = '800320';
   
   -- NO está reinscripto en la carrera
   IF (v_cntReinsc = 0) THEN
      
      -- Averiguo el Tipo de Carrera, solo controlo a las que son carreras de Grado.
      SELECT sga_carreras.tipo_de_carrera, sga_tipos_carrera.controla_reinscrip
        INTO vc_TipoCarrera, vcCntrReinsc
        FROM sga_carreras, sga_tipos_carrera
       WHERE sga_carreras.unidad_academica = pUnidadAcademica
         AND sga_carreras.carrera = pCarrera
         AND sga_carreras.tipo_de_carrera = sga_tipos_carrera.tipo_de_carrera;

	IF vc_TipoCarrera IN ('C', 'P', 'R', 'T', 'S', 'B', 'W', 'Z') THEN
      
	      -- ERROR, VERIFICO ANTES DE MANDAR EL ERROR QUE SEA CARRERA DE GRADO!!!
	      -- Busca el nombre de la carrera, para devolver el mensaje
	      IF (vcCntrReinsc = 'S') THEN
		 SELECT nombre_reducido
		   INTO v_NomCarrera
		   FROM sga_carreras
		  WHERE sga_carreras.unidad_academica = pUnidadAcademica
		    AND sga_carreras.carrera = pCarrera ;
		 
		 EXECUTE PROCEDURE sp820_es_ingresante(pUnidadAcademica, pCarrera, pLegajo,pAnio) INTO vcEsIngresante;
		 IF vcEsIngresante = 'S' THEN
		    -- La Persona es ingresante en la carrera "v_carreraNoReinsc"
		    -- verifico si los ingresantes deben reinscribirse.
		    IF v_ReinsAluIng = 'S' THEN
		       LET iStatus = -1;
		       LET vcMsg = '800452, ' || v_NomCarrera;
		    END IF;
		 ELSE
		    -- La persona no es ingresante en la Carrera.	
		    LET iStatus = -1;
		    LET vcMsg = '800452, ' || v_NomCarrera;
		 END IF;
		 
	      END IF;	-- vcCntrReinsc = 'S'
	ELSE
		LET iStatus = -1;
		LET vcMsg = '800211';
	END IF;

   END IF;	-- v_cntReinsc = 0
   
   RETURN iStatus, vcMsg;
   
END;
END PROCEDURE;
-- ************************* Procedure ctr_reinscrAlumno ****************************
