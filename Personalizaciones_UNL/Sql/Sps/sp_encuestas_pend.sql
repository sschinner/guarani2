CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_encuestas_pend') THEN
		DROP PROCEDURE sp_encuestas_pend;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ***********************************************************************************
-- SIU-GUARANI
-- 
-- Procedure sp_encuestas_pend
-- Version 2.04.0
-- 
-- Retorna todas las encuestas pendientes por responder 
-- para una persona.
-- 
-- Version 2.04.2: Ahora si la comision se retorna, tambien se retorna la materia 
--                 y el nombre de la comision.
-- 2.6.3: Se optimizaron algunas querys.
-- 2.6.4: Se optimiza el procedure
-- 2.7.0: Se corrige bug ticket 16 solo incluye materias del alcance
-- U820 Se adaptó la personalización a la versión 2.8.0.
-- ***********************************************************************************
-- DROP PROCEDURE "dba".sp_encuestas_pend;
CREATE PROCEDURE "dba".sp_encuestas_pend(pUA      LIKE sga_unidades_acad.unidad_academica,
                                   pNroInsc LIKE sga_personas.nro_inscripcion)

                             RETURNING VARCHAR(5),   -- 0  unidad academica
                                       VARCHAR(15),  -- 1  nro_inscripcion
                                       INTEGER,      -- 2  encuesta
                                       VARCHAR(60),  -- 3  titulo_encuesta 
                                       INTEGER,      -- 4  alcance
                                       VARCHAR(60),  -- 5  titulo_alcance 
                                       VARCHAR(5),   -- 6  ** carrera
                                       VARCHAR(255), -- 7  nombre carrera
                                       INTEGER,      -- 8  ** comision
                                       VARCHAR(255), -- 9  nombre materia
                                       VARCHAR(10),  -- 10 ** legajo  
                                       VARCHAR(100), -- 11 nombre docente
                                       VARCHAR(5),   -- 12 materia
                                       VARCHAR(15);  -- 13 nombre de la comision

DEFINE i_encuesta       LIKE gde_encuestas.encuesta;
DEFINE vc_enc_titulo    LIKE gde_encuestas.titulo;
DEFINE i_alcance        LIKE gde_encues_alcance.alcance;
DEFINE vc_alc_titulo    LIKE gde_encues_alcance.titulo;
DEFINE i_comision       LIKE sga_comisiones.comision;
DEFINE vc_mat_nom       LIKE sga_materias.nombre;
DEFINE vc_carrera       LIKE sga_carreras.carrera;
DEFINE vc_car_nom       LIKE sga_carreras.nombre;
DEFINE vc_legajo        LIKE sga_docentes.legajo;
DEFINE vc_legajo_alu        LIKE sga_alumnos.legajo;

DEFINE vc_doc_nom       VARCHAR(100);

DEFINE i_anio_academico LIKE sga_anio_academico.anio_academico;
DEFINE vc_periodo_lect  LIKE sga_periodos_lect.periodo_lectivo;
DEFINE vc_materia       LIKE sga_materias.materia;
DEFINE vc_nom_com       LIKE sga_comisiones.nombre;

DEFINE c_una_x_car      LIKE gde_encues_alcance.una_por_carrera;
DEFINE c_una_x_com      LIKE gde_encues_alcance.una_por_comision;
DEFINE c_una_x_doc      LIKE gde_encues_alcance.una_por_docente; 
DEFINE c_mat_regul      LIKE gde_encues_alcance.materia_regul;

DEFINE i_alc_car        INTEGER;
DEFINE i_alc_mat        INTEGER;
DEFINE i_alc_com        INTEGER;
DEFINE i_alc_doc        INTEGER;

DEFINE i_cant_car       INTEGER;
DEFINE i_cant_mat       INTEGER;
DEFINE i_cant_com       INTEGER;
DEFINE i_cant_doc       INTEGER;

DEFINE vc_alcance_valido CHAR(1);
DEFINE cnt_enc_activas       INTEGER;

-- set debug file to 'encuestas.txt';
-- trace on;

BEGIN

SELECT count(*) INTO cnt_enc_activas
             FROM gde_encues_alcance ea,
                  gde_encuestas      e
            WHERE ea.unidad_academica = pUA
              AND ea.encuesta         = e.encuesta
              AND ea.activo           = 'S';

IF cnt_enc_activas > 0 THEN 

LET i_encuesta = null;
LET vc_enc_titulo = null;
LET i_alcance = null;
LET vc_alc_titulo = null;
LET vc_carrera = null;
LET vc_car_nom = null;
LET i_comision = null;
LET vc_mat_nom = null;
LET vc_legajo = null;
LET vc_doc_nom = null;
LET vc_materia = null;
LET vc_nom_com = null;


  -- Bloque para crear tablas temporales.
  BEGIN
    ON EXCEPTION IN (-958) -- Temp table  already exists in session 
      -- Si existe la tabla continua en la siguiente sentencia...
    END EXCEPTION WITH RESUME;
    
    -- Creo la tabla temporal de carreras
    CREATE TEMP TABLE tmp_carreras (
      carrera  VARCHAR(5),
      legajo varchar(15)
    ) WITH NO LOG;
    
    -- Creo la tabla temporal de comisiones
    CREATE TEMP TABLE tmp_comisiones (
      comision INTEGER,
      carrera  VARCHAR(5),
      legajo   VARCHAR(15), 
      materia  VARCHAR(5)   
    ) WITH NO LOG;
    
    -- Creo la tabla temporal de legajos de docentes
    CREATE TEMP TABLE tmp_legajos (
      comision INTEGER,
      legajo   VARCHAR(10)
    ) WITH NO LOG;
    
    -- Creo la tabla temporal de encuestas
    CREATE TEMP TABLE tmp_encuestas (
      carrera  VARCHAR(5),
      comision INTEGER,
      materia  VARCHAR(5),   
      legajo   VARCHAR(10)
    ) WITH NO LOG;
    
    -- Creo la tabla temporal de la vista de cursadas
    CREATE TEMP TABLE tmp_cursadas (
      unidad_academica  VARCHAR(5),   
      carrera  VARCHAR(5),
      legajo   VARCHAR(15),
      comision INTEGER
    ) WITH NO LOG;

    -- Creo la tabla temporal de las inscricpiones
    CREATE TEMP TABLE tmp_inscripciones (
      unidad_academica  VARCHAR(5),   
      carrera  VARCHAR(5),
      legajo   VARCHAR(15),
      comision INTEGER,
      materia VARCHAR(5),
      anio_academico INTEGER,
      periodo_lectivo VARCHAR(20),
      nombre_comision VARCHAR(15),
      nombre_materia VARCHAR(255),
      legajo_docente VARCHAR(10)
    ) WITH NO LOG;

    -- Borro los datos si la tabla temporal existia...    
    DELETE FROM tmp_encuestas;
    DELETE FROM tmp_carreras;
    DELETE FROM tmp_comisiones;
    DELETE FROM tmp_legajos;
    DELETE FROM tmp_cursadas;
    DELETE FROM tmp_inscripciones;
  END;

-- Creo índice para las tablas temporales...    
create unique index in_comisiones on tmp_comisiones (comision, carrera, legajo);	
create unique index in_carreras on tmp_carreras (carrera);	
create unique index in_legajos on tmp_legajos (comision, legajo);	
create index in_encuestas on tmp_encuestas (comision, carrera, legajo);	


    -- (1) Recupero cada carrera de la persona
    INSERT INTO tmp_carreras
    SELECT a.carrera, a.legajo
      FROM sga_alumnos as a
     WHERE a.unidad_academica  = pUA
       AND a.nro_inscripcion   = pNroInsc
       AND a.calidad           <> 'E'
	-- U820 Alumnos en estado Regular
       AND a.regular           = 'S';

-- 1.b recupero las cursadas de la persona
foreach select carrera, legajo
    into vc_carrera, vc_legajo_alu
    from tmp_carreras

   INSERT INTO tmp_cursadas
   SELECT unidad_academica, carrera, legajo, comision 
                 FROM sga_cursadas
                WHERE unidad_academica  = pUA
                  AND carrera           = vc_carrera
                  AND legajo            = vc_legajo_alu
                  AND fecha_regularidad <= TODAY
                  AND origen            IN ('C','P')
                  AND resultado         IN ('A','P');

end foreach;
             
foreach select carrera, legajo
    into vc_carrera, vc_legajo_alu
    from tmp_carreras

   INSERT INTO tmp_inscripciones
   select sic.unidad_academica, sic.carrera, sic.legajo, sic.comision, sc.materia, sc.anio_academico, sc.periodo_lectivo, sc.nombre, samp.nombre_materia, sdc.legajo 
	from sga_insc_cursadas sic,
		sga_comisiones sc,
		sga_atrib_mat_plan samp,
		outer(sga_docentes_com sdc)
	where sic.unidad_academica = pUA
		and sic.carrera = vc_carrera
		and sic.legajo = vc_legajo_alu

		and sic.comision = sc.comision

		and sic.unidad_academica = samp.unidad_academica
		and sic.carrera = samp.carrera
		and sic.plan = samp.plan
		and sic.version = samp.version
		and sc.materia = samp.materia

		and sc.comision = sdc.comision
		-- U820 Inscripciones en estado A o E
		and sic.estado in ('A', 'E');


end foreach;


  -- Recupero las encuestas vigentes
  FOREACH SELECT e.encuesta, e.titulo, ea.alcance, ea.titulo, ea.anio_academico, ea.periodo_lectivo, 
                  ea.una_por_comision, ea.una_por_docente, ea.una_por_carrera, ea.materia_regul
             INTO i_encuesta, vc_enc_titulo, i_alcance, vc_alc_titulo, i_anio_academico, vc_periodo_lect, 
                  c_una_x_com, c_una_x_doc, c_una_x_car, c_mat_regul   
             FROM gde_encues_alcance ea,
                  gde_encuestas      e
            WHERE ea.unidad_academica = pUA
              AND ea.encuesta         = e.encuesta
              AND ea.activo           = 'S' 
              AND TODAY BETWEEN ea.fecha_desde AND ea.fecha_hasta

--              No filtro por la fecha. La muestro igual a la encuesta
--              se le generar sancion cuando la fecha de registro de la 
--              respuesta no esta en este rango.
--              AND TODAY BETWEEN ea.fecha_desde AND ea.fecha_hasta
--             

           ORDER BY 1, 2
    
    LET i_alc_car = (SELECT COUNT(alcance) FROM gde_alcance_car WHERE alcance = i_alcance);
    LET i_alc_mat = (SELECT COUNT(alcance) FROM gde_alcance_mat WHERE alcance = i_alcance);
    LET i_alc_com = (SELECT COUNT(alcance) FROM gde_alcance_com WHERE alcance = i_alcance);
    LET i_alc_doc = (SELECT COUNT(alcance) FROM gde_alcance_doc WHERE alcance = i_alcance);
    

    -- (2) Recupero cada comision en la que esta inscripta
    -- la persona.
    DELETE FROM tmp_comisiones;
    INSERT INTO tmp_comisiones  
       SELECT comision, carrera, legajo, materia
         FROM tmp_inscripciones
              
        WHERE anio_academico    = i_anio_academico
          AND (
                (NOT vc_periodo_lect IS NULL AND periodo_lectivo = vc_periodo_lect )
                OR vc_periodo_lect IS NULL
              );

    -- (2.5) Elimino las cursadas no aprobadas si para el anio academico y/o periodo lectivo. 
   -- Solo toma las materias cursadas aprobadas (No tiene en cuenta las equivalencias)
    IF c_mat_regul = 'S' THEN       

      DELETE FROM tmp_comisiones 
            WHERE comision NOT IN 
             ( SELECT comision 
                 FROM tmp_cursadas
             );
    END IF

    -- (3) Recupero los docentes de cada comision en la que 
    -- esta inscripta la persona
    DELETE FROM tmp_legajos;
    INSERT INTO tmp_legajos
       SELECT comision, legajo_docente
         FROM tmp_inscripciones;

    -- (4) Hago el join de acuerdo a la multiplicidad. Combinacion de todas.
    DELETE FROM tmp_encuestas;
    INSERT INTO tmp_encuestas (carrera, materia, comision, legajo) 
    SELECT ta.carrera, tm.materia, tm.comision, td.legajo
      FROM tmp_carreras ta,
           tmp_comisiones tm,
           tmp_legajos td
     WHERE td.comision = tm.comision
       AND (tm.carrera IS NULL OR tm.carrera = ta.carrera);

    -- (Pongo en null de acuerdo a la multiplicidad)
    -- despues al retornarlas el DISTINCT hara que las 
    -- que tienen todo en null sean eliminadas.

    -- Una sola encuesta por carrera de la persona
    IF c_una_x_car = 'N' THEN
      UPDATE tmp_encuestas SET carrera = NULL;
    END IF;

    -- Una sola encuesta por comision
    IF c_una_x_com = 'N' THEN
      UPDATE tmp_encuestas SET comision = NULL;
    END IF;

    -- Una sola encuesta por docente
    IF c_una_x_doc = 'N' THEN
      UPDATE tmp_encuestas SET legajo = NULL;
    END IF;

    -- 5) Si hay alcance por carreras borro las carreras que no estan en el alcance
    IF i_alc_car <> 0 THEN
      DELETE FROM tmp_encuestas 
            WHERE carrera NOT IN (
               SELECT ac.carrera
                 FROM gde_alcance_car ac
                WHERE ac.unidad_academica = pUA
                  AND ac.alcance          = i_alcance
       ) ;
    END IF;

    -- 6) Si hay alcance por materias borro las materias que no estan en el alcance
    IF i_alc_mat <> 0 THEN
       DELETE FROM tmp_encuestas 
             WHERE materia NOT IN (
               SELECT am.materia
                 FROM gde_alcance_mat am
                WHERE am.unidad_academica = pUA
                  AND am.alcance          = i_alcance
       ) ;
    END IF;

    -- 7) Si hay alcance por comisiones borro las comisiones que no estan en el alcance
    IF i_alc_com <> 0 THEN
       DELETE FROM tmp_encuestas 
             WHERE comision NOT IN (
               SELECT ac.comision
                 FROM gde_alcance_com ac
                WHERE ac.alcance = i_alcance
       ) ;
    END IF;

    -- 8) Si hay alcance por docentes borro los legajos  que no estan en el alcance
    IF i_alc_doc <> 0 THEN
       DELETE FROM tmp_encuestas 
             WHERE legajo NOT IN (
               SELECT ad.legajo
                 FROM gde_alcance_doc ad
                WHERE ad.alcance = i_alcance
       ) ;
    END IF ;

    -- 9) Retorno las encuestas 
    -- (El DISTINCT hace que las encuestas con carrera = NULL o docente = NULL o comision = NULL
    --  sean consideradas como una sola)
    FOREACH 
       SELECT DISTINCT te.carrera, te.comision,  te.legajo 
         INTO vc_carrera, i_comision, vc_legajo
         FROM tmp_encuestas te

      
      IF (SELECT COUNT(*) 
            FROM gde_encues_persona ep
           WHERE ep.unidad_academica = pUA
             AND ep.nro_inscripcion  = pNroInsc
             AND ep.encuesta         = i_encuesta
             AND ep.alcance          = i_alcance
             AND (ep.carrera  = vc_carrera OR (ep.carrera  IS NULL AND vc_carrera IS NULL))
             AND (ep.comision = i_comision OR (ep.comision IS NULL AND i_comision IS NULL))
             AND (ep.legajo   = vc_legajo  OR (ep.legajo   IS NULL AND vc_legajo  IS NULL))
          ) = 0 THEN

       IF i_comision IS NOT NULL THEN
       		SELECT distinct nombre_comision, materia, nombre_materia
       			INTO vc_nom_com, vc_materia, vc_mat_nom
       			FROM tmp_inscripciones
       			WHERE comision = i_comision;
       ELSE
          LET vc_nom_com = NULL;
          LET vc_materia = NULL;
          LET vc_mat_nom = NULL;
       END IF;	
       
       IF vc_carrera IS NOT NULL THEN
       	SELECT nombre
       	  	 INTO vc_car_nom
         	FROM sga_carreras
        	WHERE unidad_academica = pUA
          	AND carrera          = vc_carrera;
       else
	LET vc_car_nom = null;
       END IF;
       
       IF vc_legajo IS NOT NULL THEN
       		SELECT p.nombres || ' ' || p.apellido
         	INTO vc_doc_nom
         	FROM sga_docentes d , 
            	   sga_personas p
        	WHERE d.legajo = vc_legajo
			AND p.unidad_academica = pUA
          	AND p.nro_inscripcion  = d.nro_inscripcion;
      else 
	LET vc_doc_nom = null;
      END IF;


        RETURN pUA, pNroInsc, i_encuesta, vc_enc_titulo, i_alcance, vc_alc_titulo, 
               vc_carrera, vc_car_nom, i_comision, vc_mat_nom, 
               vc_legajo, vc_doc_nom , vc_materia, vc_nom_com
               WITH RESUME;
      END IF;  
    END FOREACH;   
  END FOREACH;   

  DROP TABLE tmp_carreras;
  DROP TABLE tmp_comisiones;
  DROP TABLE tmp_legajos;
  DROP TABLE tmp_encuestas;
  DROP TABLE  tmp_cursadas;
  DROP TABLE  tmp_inscripciones;
  
END IF; -- si no hay alcances activos sale 

END;
-- trace off;


END PROCEDURE ;
-- +++++++++++++++++++++++++ Fin procedure sp_encuestas_pend ++++++++++++++++++

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_encuestas_pend
-- *****************************************************************************
revoke execute on "dba".sp_encuestas_pend from public;
grant execute on "dba".sp_encuestas_pend to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_encuestas_pend to internet; -- Rol de usuario de Internet