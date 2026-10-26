-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Procedure sp_fichaluporcapro
-- Version modificación: 2.09.0, 2.9.5
-- En el caso de egresados, recupera el plan y version de plan de estudios a la fecha de egreso.
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

DROP PROCEDURE sp_fichaluporcapro;
CREATE PROCEDURE sp_fichaluporcapro (
   pUnidadAcademica LIKE sga_personas.unidad_academica, 
   pNroInscripcion LIKE sga_personas.nro_inscripcion)
 
 RETURNING varchar(5), varchar(10), varchar(30), varchar(30), varchar(5), varchar(255), varchar(5), varchar(255), varchar(5), varchar(255), varchar(15), varchar(5), decimal(6,2), decimal(6,2), varchar(5);--un toco

-- retorno
-- varchar(5),   -- unidad_academica
-- varchar(10),  -- nro_inscripcion
-- varchar(30),  -- apellido
-- varchar(30),  -- nombres
-- varchar(5),   -- carrera
-- varchar(255), -- carrera_nombre
-- varchar(5), -- titulo 
-- varchar(255), -- nombre titulo
-- varchar(5), -- orientacion
-- varchar(255), -- orientacion nombre
-- varchar(15),  -- legajo
-- varchar(5),   -- plan
-- decimal(6,2), -- porcentaje de aprobacion orientacion
-- decimal(6,2), -- porcentaje de aprobacion-titulo
-- varchar(5)  -- version del plan


DEFINE vcUnidadAcademica LIKE sga_alumnos.unidad_academica; 
DEFINE vcCarrera LIKE sga_alumnos.carrera;
DEFINE vcLegajo  LIKE sga_alumnos.legajo;
DEFINE vcPlan, vcPlanAux LIKE sga_versiones_plan.plan;
DEFINE vcVersion, vcVersionAux LIKE sga_versiones_plan.version;
DEFINE vcTitulo LIKE sga_atrib_mat_orie.titulo;
DEFINE vcOrientacion LIKE sga_atrib_mat_orie.orientacion;
DEFINE vcMateria LIKE sga_atrib_mat_orie.materia;
DEFINE vdPorcentaje decimal(6,2);
DEFINE vcOrientElegida LIKE sga_atrib_mat_orie.orientacion;
DEFINE vcApellido        LIKE sga_personas.apellido;
DEFINE vcNombres         LIKE sga_personas.nombres;
DEFINE vcSexo         LIKE sga_personas.sexo;
DEFINE vcNombreCarrera LIKE sga_carreras.nombre; 
DEFINE vcNombreTitulo LIKE sga_titulos.nombre;
DEFINE vcNombreTituloF LIKE sga_titulos.nombre_femenino;
DEFINE vcNombreOrient LIKE sga_orientaciones.nombre;
DEFINE vdPorcentajeOri decimal(6,2);
DEFINE viCantMaterias integer;
DEFINE viCantMateriasOri integer;
DEFINE vcTieneOrient LIKE sga_titulos_plan.tiene_orient;
DEFINE vcResultGene char(1);
DEFINE vcCalidad char(1);
DEFINE vdtFecha Datetime Year to Second;
DEFINE vdFechaEgreso Date;

CREATE TEMP TABLE tmp_materia_porcen (
	unidad_academica varchar(5),
	carrera varchar(5),
	legajo varchar(15),
	plan varchar(5),
	version varchar(5),
	titulo varchar(5),
	orientacion varchar(5),
	materia varchar(5),
	porcentaje decimal(6,2) default 0 ) WITH NO LOG;

CREATE TEMP TABLE tmp_result_porcen (
	unidad_academica varchar(5),
	carrera varchar(5),
	legajo varchar(15),
	plan varchar(5),
	version varchar(5),
	titulo varchar(5),
	orientacion varchar(5),
	suma decimal(10,2),
	conteo integer ) WITH NO LOG;

CREATE TEMP TABLE tmp_carreras_plan (
	unidad_academica varchar(5),
	carrera varchar(5),
	legajo varchar(15),
	plan varchar(5),
	version varchar(5));

-- selecciono los datos personales de la persona.
   SELECT sga_personas.apellido,
          sga_personas.nombres,
	sga_personas.sexo
     INTO vcApellido, vcNombres, vcSexo
     FROM sga_personas
    WHERE sga_personas.unidad_academica = pUnidadAcademica
      AND sga_personas.nro_inscripcion = pNroInscripcion;


-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Recorro las carreras en las que se encuentra la persona
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FOREACH SELECT unidad_academica, carrera, legajo, calidad
		INTO vcUnidadAcademica, vcCarrera, vcLegajo, vcCalidad
		FROM sga_alumnos
		WHERE unidad_academica = pUnidadAcademica
		AND nro_inscripcion = pNroInscripcion
		
		
    -- Si es egresado, saco el plan y la version en base a la fecha de solicitud del titulo, sino a la fecha actual
    LET vcPlan = NULL;
    LET vcVersion = NULL;
    LET vdtFecha = NULL;
    LET vdFechaEgreso = NULL;
    IF vcCalidad = 'E' THEN
       -- Egresado. Recupero fecha de egreso, plan y version del título de nivel final - Grado
       SELECT to.fecha_egreso, plan, version 
	     INTO vdFechaEgreso, vcPlan, vcVersion
         FROM sga_titulos_otorg as to,
              sga_titulos as t
		WHERE to.unidad_academica = pUnidadAcademica
 		  AND to.nro_inscripcion = pNroInscripcion
 		  AND to.carrera = vcCarrera
 		  AND to.legajo  = vcLegajo
		  AND t.unidad_academica = to.unidad_academica
 		  AND t.titulo =  to.titulo
 		  AND t.nivel = 'GRADO';

        -- Paso la fecha de egreso a formato datetime con el ultimo minuto del dia de egreso.
        LET vdtFecha = to_date(to_char(vdFechaEgreso,'%d/%m/%Y') || ' 23:59:59', '%d/%m/%Y %H:%M:%S');
	END IF;
	
	IF vdtFecha IS NULL THEN
	   LET vdtFecha = CURRENT;  -- Fecha y hora actual
	END IF;	
	  
	IF vcPlan IS NULL OR vcVersion IS NULL THEN 
		-- Calcula el plan y la version segun la fecha actual o fecha de egreso en la carrera
		EXECUTE PROCEDURE sp_plan_de_alumno (vcUnidadAcademica, vcCarrera, vcLegajo, vdtFecha) INTO vcPlan, vcVersion;
	END IF;	
    
	
	-- Registro el plan y version del alumno en cada carrera
	INSERT INTO tmp_carreras_plan (unidad_academica, carrera, plan, version) VALUES (vcUnidadAcademica, vcCarrera, vcPlan, vcVersion);

	INSERT INTO tmp_materia_porcen (unidad_academica, carrera, legajo, plan, version, titulo, orientacion, materia)
	SELECT vmp.unidad_academica, vmp.carrera, vcLegajo, vmp.plan, vmp.version, vmp.titulo, vmp.orientacion, vmp.materia
		FROM vw_materias_plan AS vmp, 
		     sga_atrib_mat_plan AS samp
		WHERE vmp.unidad_academica = vcUnidadAcademica
			AND vmp.carrera = vcCarrera
			AND vmp.plan = vcPlan
			AND vmp.version = vcVersion
			AND vmp.relacion = 'D'
			AND vmp.unidad_academica = samp.unidad_academica
			AND vmp.carrera = samp.carrera
			AND vmp.plan = samp.plan
			AND vmp.version = samp.version
			AND vmp.materia = samp.materia
			AND obligatoria='S';

	-- por ahora solo trabajo con aprobacion de materias
	FOREACH SELECT DISTINCT titulo
		INTO vcTitulo
		FROM tmp_materia_porcen

		IF (SELECT calculo_egreso
			FROM sga_titulos_plan
			WHERE unidad_academica = vcUnidadAcademica
				AND carrera = vcCarrera
				AND plan = vcPlan
				AND titulo = vcTitulo) <>'AM' THEN

			DELETE FROM tmp_materia_porcen WHERE titulo = vcTitulo;

		END IF;

		-- si el alumno eligio orientacion debo retornar solo esa orientacion
		SELECT orientacion
			INTO vcOrientElegida 
			FROM sga_orient_alumno
			WHERE unidad_academica = vcUnidadAcademica
				AND carrera = vcCarrera
				AND legajo = vcLegajo
				AND plan = vcPlan
				AND titulo = vcTitulo;

		IF vcOrientElegida IS NOT NULL THEN 
			-- borro los datos de las orientaciones no elegidas por el alumno
			DELETE FROM tmp_materia_porcen
				WHERE unidad_academica = vcUnidadAcademica
					AND carrera = vcCarrera
					AND legajo = vcLegajo
					AND plan = vcPlan
					AND titulo = vcTitulo
					AND orientacion NOT IN ('0' ,vcOrientElegida);

		END IF;
		
	END FOREACH; -- filtro por calculo_egreso y orientacion elegida


	FOREACH SELECT titulo, orientacion, materia
		INTO vcTitulo, vcOrientacion, vcMateria
		FROM tmp_materia_porcen

		LET vdPorcentaje = 0;

		IF (SELECT tipo_materia
			FROM sga_materias
			WHERE unidad_academica = vcUnidadAcademica
				AND materia = vcMateria) = 'G' THEN

			-- si la materia es generica busco el porcentaje de aprobacion
			EXECUTE PROCEDURE sp_resultGenePorc(pUnidadAcademica, vcCarrera, vcLegajo, vcTitulo, vcOrientacion,vcMateria) INTO vcResultGene, vdPorcentaje;


			-- U820 - Personalización UNL: la genérica se considera aprobada total o no.
			IF vcResultGene = 'R' THEN
				LET vdPorcentaje = 0;
			END IF;	

		ELSE

			IF EXISTS(SELECT ''
					FROM vw_hist_academica
					WHERE unidad_academica = vcUnidadAcademica
						AND carrera = vcCarrera
						AND legajo = vcLegajo
						AND materia = vcMateria
						AND resultado = 'A') THEN

				LET vdPorcentaje = 1;

			END IF;
		END IF;

		UPDATE tmp_materia_porcen 
			SET porcentaje = vdPorcentaje
			WHERE unidad_academica = vcUnidadAcademica
				AND carrera = vcCarrera
				AND legajo = vcLegajo
				AND titulo = vcTitulo
				AND orientacion = vcOrientacion
				AND materia = vcMateria;
			
	END FOREACH; --materia
			
END FOREACH; -- carreras

-- Ahora tratamos de retornar algo...
INSERT INTO tmp_result_porcen (unidad_academica, carrera, legajo, plan, version, titulo, orientacion, suma, conteo)
SELECT unidad_academica, carrera, legajo, plan, version, titulo, orientacion, SUM(porcentaje), COUNT(*)
	FROM tmp_materia_porcen
	GROUP BY unidad_academica, carrera, legajo, plan, version, titulo, orientacion;

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- para cada plan y titulo
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FOREACH SELECT DISTINCT trp.unidad_academica, trp.carrera, trp.legajo, trp.plan, trp.titulo, sc.nombre, st.nombre, st.nombre_femenino, tiene_orient, tcpv.plan, tcpv.version
		INTO vcUnidadAcademica, vcCarrera, vcLegajo, vcPlan, vcTitulo, vcNombreCarrera, vcNombreTitulo, vcNombreTituloF, vcTieneOrient, vcPlanAux, vcVersionAux
		FROM tmp_result_porcen AS  trp, 
		     sga_carreras AS sc, 
		     sga_titulos AS st, 
		     sga_titulos_plan AS stp,
		     tmp_carreras_plan as tcpv
		WHERE trp.unidad_academica = sc.unidad_academica
			AND trp.carrera = sc.carrera
			AND trp.unidad_academica = st.unidad_academica
			AND trp.titulo = st.titulo
			AND trp.unidad_academica = stp.unidad_academica
			AND trp.carrera = stp.carrera
			AND trp.plan = stp.plan
			AND trp.titulo = stp.titulo
			AND tcpv.unidad_academica = stp.unidad_academica
			AND tcpv.carrera = stp.carrera


		SELECT DISTINCT trp.orientacion, nombre, suma, conteo
			INTO vcOrientacion, vcNombreOrient, vdPorcentaje, viCantMaterias
			FROM tmp_result_porcen AS trp, sga_orientaciones AS so
			WHERE trp.unidad_academica = vcUnidadAcademica
				AND trp.carrera = vcCarrera
				AND trp.plan = vcPlan
				AND trp.titulo = vcTitulo
				AND trp.orientacion ='0'
				AND trp.unidad_academica = so.unidad_academica
				AND trp.carrera = so.carrera
				AND trp.plan = so.plan
				AND trp.titulo = so.titulo
				AND trp.orientacion = so.orientacion;

		IF vcTieneOrient = 'N' THEN
			RETURN pUnidadAcademica, pNroInscripcion, vcApellido, vcNombres, vcCarrera, vcNombreCarrera, vcTitulo, vcNombreTitulo, vcOrientacion, vcNombreOrient, vcLegajo, vcPlanAux, (vdPorcentaje/viCantMaterias*100), (vdPorcentaje/viCantMaterias*100), vcVersionAux WITH RESUME;
		ELSE
			RETURN pUnidadAcademica, pNroInscripcion, vcApellido, vcNombres, vcCarrera, vcNombreCarrera, vcTitulo, vcNombreTitulo, vcOrientacion, vcNombreOrient, vcLegajo, vcPlanAux, (vdPorcentaje/viCantMaterias*100), NULL, vcVersionAux WITH RESUME;
		END IF;


	FOREACH SELECT DISTINCT trp.orientacion, nombre, suma, conteo
			INTO vcOrientacion, vcNombreOrient, vdPorcentajeOri, viCantMateriasOri
			FROM tmp_result_porcen AS trp, sga_orientaciones AS so
			WHERE trp.unidad_academica = vcUnidadAcademica
				AND trp.carrera = vcCarrera
				AND trp.plan = vcPlan
				AND trp.titulo = vcTitulo
				AND trp.orientacion <> '0'
				AND trp.unidad_academica = so.unidad_academica
				AND trp.carrera = so.carrera
				AND trp.plan = so.plan
				AND trp.titulo = so.titulo
				AND trp.orientacion = so.orientacion

		RETURN pUnidadAcademica, pNroInscripcion, vcApellido, vcNombres, vcCarrera, vcNombreCarrera, vcTitulo, vcNombreTitulo, vcOrientacion, vcNombreOrient, vcLegajo, 
		       vcPlanAux, (vdPorcentajeOri/viCantMateriasOri*100), ((vdPorcentaje + vdPorcentajeOri)/(viCantMaterias + viCantMateriasOri)*100), vcVersionAux WITH RESUME;

	END FOREACH; -- orientacion

END FOREACH; -- plan y titulo

-- Borro tablas temporales
DROP TABLE tmp_materia_porcen;
DROP TABLE tmp_result_porcen;
DROP TABLE tmp_carreras_plan;

END PROCEDURE;
-- ++++++++++++++++++++++++++++++++++++++++++++ Fin Procedure ++++++++++++++++++++++++++


GRANT EXECUTE ON sp_fichaluporcapro TO public;
