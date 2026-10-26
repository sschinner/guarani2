-- Insercion del procedimiento personalizado de obtencion de grupo de graduados a encuestar
DELETE FROM gde_procesos_pers WHERE stored_procedure = 'sp820_enc_graduados';
INSERT INTO gde_procesos_pers (stored_procedure, descripcion, grupo_de, estado)
   VALUES ('sp820_enc_graduados', 'Alumnos Graduados','A','A');

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_enc_graduados') THEN
		DROP PROCEDURE sp820_enc_graduados;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *********************************************************************************************************************
-- SIU - GUARANI: Sistema de Gestion Academica
-- PROCEDURE: sp820_enc_graduados 
-- Version: 
-- Ultima version de modificacion: 2.09.2
-- El conjunto de graduados a encuestar corresponde a Egresados
-- La encuesta en principio es para alumnos graduados con titulo final de carrera
-- *********************************************************************************************************************
-- DROP PROCEDURE "dba".sp820_enc_graduados;
CREATE PROCEDURE "dba".sp820_enc_graduados( pUA like sga_alumnos.unidad_academica, pCarrera like sga_alumnos.carrera, pAnioAcademico integer )
RETURNING 	
		varchar(10),		-- Unidad Academica
		varchar(10);		-- Nro. Inscripcion


  -- inicializaciones.
  ---------------------------
  DEFINE ls_Titulo  		LIKE  sga_titulos_plan.titulo;
  DEFINE ls_Plan  		LIKE  sga_planes.plan;
  DEFINE ls_Version  		LIKE  sga_planes.version_actual;
  DEFINE ls_Orientacion  	LIKE  sga_orientaciones.orientacion;
  DEFINE ls_OrientNombre 	varchar(255);
  DEFINE ls_Ciclo		LIKE  sga_ciclos.ciclo;
  DEFINE ls_Materia		LIKE  sga_materias.materia;
  DEFINE fPuntos		float;
  DEFINE ls_Estado		like sga_titulos_otorg.estado;
  DEFINE ls_Nivel		LIKE sga_titulos.nivel;

  DEFINE ls_NombreAlumno  	Varchar(255);
  DEFINE ls_TipoDoc  		LIKE  sga_personas.tipo_documento;
  DEFINE ls_NroDoc  		LIKE  sga_personas.nro_documento;
  DEFINE ls_NroInscripcion	LIKE  sga_personas.nro_inscripcion;
  DEFINE ls_Ua  		LIKE  sga_alumnos.unidad_academica;
  DEFINE ls_Carrera  		LIKE  sga_alumnos.carrera;
  DEFINE ls_CarreraNombre  	LIKE  sga_carreras.nombre;
  DEFINE ls_Legajo  		LIKE  sga_alumnos.legajo;
  DEFINE ls_TituloNombre  	LIKE  sga_titulos.nombre;
  DEFINE ls_FechaRec  		LIKE  sga_titulos_otorg.fecha_egreso;
  DEFINE dFHasta		date;

  DEFINE sql_err , isam_err 	int;
  DEFINE error_info 		varchar(70);


-- LET dFHasta = stringToDate( pFechaIngreso, '%d-%m-%Y');
  LET ls_Estado = '-';

-- selecciono los alumnos que cumplen con los parametros ingresados
-------------------------------------------------------------------

  FOREACH SELECT 
	sga_alumnos.unidad_academica,
                sga_alumnos.nro_inscripcion
    INTO ls_Ua, ls_NroInscripcion
    FROM sga_alumnos,
                sga_titulos_plan,
			sga_titulos_otorg,
				sga_titulos
  WHERE sga_alumnos.unidad_academica = pUA   
       AND sga_alumnos.carrera = pCarrera  
--       AND ( sga_alumnos.legajo = pLegajo   OR   ESNULO (pLegajo) = 1 )
-- La encuesta en principio es para alumnos graduados con titulo final de carrera
       AND sga_alumnos.calidad = 'E'
--       AND sga_alumnos.fecha_Ingreso <= dFHasta
       AND sga_titulos_plan.unidad_academica = sga_alumnos.unidad_academica
       AND sga_titulos_plan.carrera = sga_alumnos.carrera
       AND sga_titulos_plan.plan = sga_alumnos.plan
	AND sga_alumnos.unidad_academica = sga_titulos_otorg.unidad_academica
	AND sga_alumnos.nro_inscripcion = sga_titulos_otorg.nro_inscripcion
	--AND YEAR(sga_titulos_otorg.fecha_egreso) = pAnioAcademico
	AND sga_titulos_otorg.titulo = sga_titulos_plan.titulo
	AND sga_titulos_plan.titulo = sga_titulos.titulo
	AND sga_titulos.tipo_de_titulo in ('G', 'E', 'D', 'M', 'S')


  ORDER BY sga_alumnos.unidad_academica, sga_alumnos.carrera

   BEGIN
	ON EXCEPTION SET   sql_err, isam_err, error_info
	    -- error
	    -- Se agrego esta excepcion para que continue si encontro algun problema!!!	
	    -- Poruqe si da error el titulo por orientacion no seleccionada, devuelve un -746	
	END EXCEPTION WITH RESUME;   
 	 
      RETURN 
	ls_UA,
	ls_NroInscripcion
      WITH RESUME;
    END;

  END FOREACH;

END PROCEDURE;
-- **************************** FIN PROCEDURE sp820_enc_graduados ****************************
revoke execute on sp820_enc_graduados from public;
grant execute on sp820_enc_graduados to guarani; -- Rol de usuarios de Gestion
grant execute on sp820_enc_graduados to internet; -- Usuario de internet

