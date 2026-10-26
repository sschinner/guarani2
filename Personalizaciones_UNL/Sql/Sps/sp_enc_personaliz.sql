CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_enc_personaliz') THEN
		DROP PROCEDURE sp_enc_personaliz;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ***********************************************************************************
-- SIU-GUARANI
-- Version 2.9.2
-- Procedure sp_enc_personaliz
-- Recupera las personas que responderan la encuesta segun el proceso personalizado seleccionado en el alcance de la encuesta. 
-- Se llena la tabla temporal _Tencuestado_aux que sera utilizada por el procedure que llamo a este.
--  
-- gde_encues_alcance.generar         = U - Unica encuesta por alumno
-- gde_encues_alcance.responderan =  PE - Alumnos. Procesos personalizados.
-- 
-- ***********************************************************************************

-- DROP PROCEDURE "dba".sp_enc_personaliz;
CREATE PROCEDURE "dba".sp_enc_personaliz(pAlcance LIKE gde_encues_alcance.alcance)

-- Variables del alcance
DEFINE i_anio_academico integer;
DEFINE vc_periodo_lect  LIKE sga_comisiones.periodo_lectivo;
DEFINE vc_proc_personaliz LIKE gde_encues_alcance.stored_procedure;
DEFINE i_alcance_car      INTEGER;

-- Variables de procesos personalizados
-- Variables de sp_posibles_egres
 DEFINE vcFechaIngreso  varchar(10); 
 DEFINE vcUA, vcCarrera  VARCHAR(5);
 DEFINE ls_Ua  		LIKE  sga_alumnos.unidad_academica;
 DEFINE ls_NombreAlumno  	Varchar(255);
 DEFINE ls_Legajo  		LIKE  sga_alumnos.legajo;
 DEFINE ls_TipoDoc  		LIKE  sga_personas.tipo_documento;
 DEFINE ls_NroDoc  		LIKE  sga_personas.nro_documento;
 DEFINE ls_NroInscripcion	LIKE  sga_personas.nro_inscripcion;
 DEFINE ls_Carrera  		LIKE  sga_alumnos.carrera;
 DEFINE ls_CarreraNombre  	LIKE  sga_carreras.nombre;
 DEFINE ls_Plan  		LIKE  sga_planes.plan;
 DEFINE ls_TituloNombre  	LIKE  sga_titulos.nombre;
 DEFINE ls_Titulo  		LIKE  sga_titulos_plan.titulo;
 DEFINE ls_Version  		LIKE  sga_planes.version_actual;
 DEFINE ls_Orientacion  	LIKE  sga_orientaciones.orientacion;
 DEFINE ls_OrientNombre 	varchar(255);
 DEFINE ls_Estado		like sga_titulos_otorg.estado;
 DEFINE ls_Nivel		LIKE sga_titulos.nivel;

BEGIN

  -- Datos del Alcance de la encuesta
  LET i_alcance_car  = 0;
  LET i_alcance_car  = (SELECT COUNT(*) FROM gde_alcance_car WHERE alcance = pAlcance);

  SELECT anio_academico, NVL(periodo_lectivo, '<TODOS>'), stored_procedure
    INTO i_anio_academico, vc_periodo_lect, vc_proc_personaliz
    FROM gde_encues_alcance
   WHERE alcance = pAlcance;


  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Se ejecutan los procesos personalizados que recuperaran las personas a ser encuestadas
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  IF vc_proc_personaliz = 'sp_enc_posgres' THEN
     
     LET vcFechaIngreso = to_char(TODAY, '%d-%m-%Y');
     
     -- Recorro las carreras a verificar posibles egresados...
     FOREACH SELECT unidad_academica, carrera INTO vcUA, vcCarrera
               FROM sga_carreras
              WHERE (i_alcance_car = 0 OR carrera IN (SELECT carrera FROM gde_alcance_car WHERE alcance = pAlcance)) 

           -- Recupero posibles egresados de la carrera...           
           FOREACH EXECUTE PROCEDURE sp_posibles_egres (vcUA, vcCarrera, vcFechaingreso) 
                      INTO ls_UA, ls_NroInscripcion,	ls_NombreAlumno, ls_Legajo, ls_TipoDoc, ls_NroDoc, ls_Carrera, ls_CarreraNombre, 
                      ls_Plan, ls_Titulo, ls_TituloNombre, ls_Orientacion, ls_OrientNombre ,ls_Estado,ls_Nivel
                      
              -- Inserto las personas relacionadas con los alumnos en condiciones de egresar en la carrera.
              -- a los cuales se le va a asociar la encuesta
              INSERT INTO _Tencuestado_aux (unidad_academica, nro_inscripcion) VALUES (ls_UA, ls_NroInscripcion);
     
           END FOREACH; -- posibles egresados...
     
     END FOREACH; -- Carreras
     -- +++++++++++++++++++++++ Fin calculo de posibles egresados en las carreras +++++++++++++++++++++++++

     
  -- Agregar los procedures personalizados en los ELIF siguientes...
  
  ELIF vc_proc_personaliz = 'sp820_enc_graduados' THEN
	-- Se pueDe llamar a otro proceso que calcula los encuestados o poner el codigo aqui mismo como en el caso anterior..
	-- Recorro las carreras a verificar posibles egresados...
     	FOREACH SELECT unidad_academica, carrera INTO vcUA, vcCarrera
	       FROM sga_carreras
	      WHERE (i_alcance_car = 0 OR carrera IN (SELECT carrera FROM gde_alcance_car WHERE alcance = pAlcance)) 

		-- Recupero posibles egresados de la carrera...           
	   	FOREACH EXECUTE PROCEDURE sp820_enc_graduados (vcUA, vcCarrera, i_anio_academico) 
	              INTO ls_UA, ls_NroInscripcion
	              
	      	-- Inserto las personas relacionadas con los alumnos en condiciones de egresar en la carrera.
	      	-- a los cuales se le va a asociar la encuesta
	      	INSERT INTO _Tencuestado_aux (unidad_academica, nro_inscripcion) VALUES (ls_UA, ls_NroInscripcion);
     
	   	END FOREACH; -- posibles egresados...
     
     	END FOREACH; -- Carreras

  ELIF vc_proc_personaliz = 'sp820_enc_tit_interm' THEN
	-- Se pueDe llamar a otro proceso que calcula los encuestados o poner el codigo aqui mismo como en el caso anterior..
	-- Recorro las carreras a verificar posibles egresados...
     	FOREACH SELECT unidad_academica, carrera INTO vcUA, vcCarrera
	       FROM sga_carreras
	      WHERE (i_alcance_car = 0 OR carrera IN (SELECT carrera FROM gde_alcance_car WHERE alcance = pAlcance)) 

		-- Recupero posibles egresados de la carrera...           
	   	FOREACH EXECUTE PROCEDURE sp820_enc_tit_interm (vcUA, vcCarrera, i_anio_academico) 
	              INTO ls_UA, ls_NroInscripcion

	              
	      	-- Inserto las personas relacionadas con los alumnos en condiciones de egresar en la carrera.
	      	-- a los cuales se le va a asociar la encuesta
	      	INSERT INTO _Tencuestado_aux (unidad_academica, nro_inscripcion) VALUES (ls_UA, ls_NroInscripcion);
     
	   	END FOREACH; -- posibles egresados...
     
     	END FOREACH; -- Carreras

  
  -- ELIF vc_proc_personaliz = 'proceso personalizado 2' THEN
  --    <codigo para recuperar los alumnos a encuestar>....
  --
  -- ELIF vc_proc_personaliz = 'proceso personalizado n' THEN
  --    <codigo para recuperar los alumnos a encuestar>....
  --    
  END IF;

    
END;
END PROCEDURE;
-- +++++++++++++++++++++++++++++++++++ Fin Procedure sp_enc_personaliz ++++++++++++++++++++++++++
revoke execute on sp_enc_personaliz from public;

grant execute on sp_enc_personaliz to guarani; -- Rol de usuarios de Gestión
grant execute on sp_enc_personaliz to internet; -- Usuario de internet

