CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_actprovisoria') THEN
		DROP PROCEDURE sp_actprovisoria;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ******************************************************************************
-- U820 Solo muestra a quienes se le cargaron realmente las notas
-- *****************************************************************************************
-- Creating procedure

CREATE PROCEDURE "dba".sp_actprovisoria( pUnidadAcademica 	LIKE sga_personas.unidad_academica,
				             pNroInscripcion 	LIKE sga_personas.nro_inscripcion )

   RETURNING  	varchar(5),		-- unidad academica	0
		varchar(5),		-- carrera			1
		varchar(15),		-- legajo			2
		varchar(5),		-- acta			3
		date,			-- fecha de examen		4
		varchar(2),		-- resultado		5
		varchar(5),		-- nota			6
		varchar(5),		-- materia			7
		varchar(20),		-- materia	nombre reducido	8
		varchar(20);		-- carrera	nombre reducido	9

/* Muestra todas las notas (no los ausentes) que una persona tenga en actas que no fueron cerradas. Incluye actas de exámen, actas de promoción y equivalencias sin confirmar  */

   -- vars para el manejo de excepciones
   DEFINE 	sql_err	 		integer;
   DEFINE 	isam_err 			integer;
   DEFINE 	error_info			varchar(76);
   DEFINE 	v_user_error		varchar(10) ;

   DEFINE 	vcUnidadAcademica	LIKE sga_insc_cursadas.unidad_academica  	;
   DEFINE 	vcCarrera			LIKE sga_insc_cursadas.carrera	  	;
   DEFINE 	vcLegajo			LIKE sga_insc_cursadas.legajo	  	;
   DEFINE 	vcActa	 		LIKE sga_detalle_acta.acta			;
   DEFINE 	dFechaExamen 		LIKE sga_detalle_acta.fecha_de_examen	;
   DEFINE 	vcResultado 		LIKE sga_detalle_acta.resultado		;
   DEFINE 	vcNota 			LIKE sga_detalle_acta.nota			;
   DEFINE 	vcMateria 		LIKE sga_materias.materia			;
   DEFINE 	vcMateriaNombre 		LIKE sga_materias.nombre			;
   DEFINE 	vcCarreraNombre 		LIKE sga_carreras.nombre			;

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
   END EXCEPTION;     

BEGIN

   LET vcUnidadAcademica	= NULL ;
   LET vcCarrera		= NULL ;
   LET vcLegajo		= NULL ;
   LET vcActa	 	= NULL ;
   LET dFechaExamen 	= NULL ;
   LET vcResultado 		= NULL ;
   LET vcNota 		= NULL ;
   LET vcMateria 		= NULL ;
   LET vcMateriaNombre 	= NULL ;
   LET vcCarreraNombre 	= NULL ;

   FOREACH
      SELECT 	dac.unidad_academica,
      	   	dac.carrera,
         		dac.legajo,
		dac.acta,
	         	dac.fecha_de_examen,
	         	dac.resultado,
	         	dac.nota,
		aex.materia,
		amp.nombre_reducido,
		car.nombre_reducido
      INTO 		vcUnidadAcademica,
		vcCarrera,
		vcLegajo,
		vcActa,
		dFechaExamen,
		vcResultado,
		vcNota,
		vcMateria,
		vcMateriaNombre,
		vcCarreraNombre
    FROM 	sga_actas_examen aex,
	sga_detalle_acta     dac ,
	sga_atrib_mat_plan  amp,
	sga_planes               pla,
	sga_carreras             car,
	sga_alumnos	 alu
    WHERE alu.unidad_academica 	= pUnidadAcademica 
          AND alu.nro_inscripcion	= pNroInscripcion
          AND dac.tipo_acta 		= 'N' 
          AND dac.unidad_academica 	= aex.unidad_academica  
          AND dac.tipo_acta 		= aex.tipo_acta  
          AND dac.acta 		= aex.acta  
          AND aex.estado 		IN ('A' , 'I' , 'N' )
          AND alu.unidad_academica 	= dac.unidad_academica  
          AND alu.carrera 		= dac.carrera  
          AND alu.legajo 		= dac.legajo  
          AND pla.unidad_academica 	= alu.unidad_academica 
          AND pla.carrera 		= alu.carrera 
          AND pla.plan 		= alu.plan 
          AND amp.unidad_academica 	= pla.unidad_academica 
          AND amp.carrera 		= pla.carrera 
          AND amp.plan 		= pla.plan 
          AND amp.version 		= pla.version_actual 
          AND amp.materia 		= aex.materia 
          AND car.unidad_academica 	= dac.unidad_academica  
          AND car.carrera 		= dac.carrera 
-- ******************************************************************************
-- u820 esto es para que solo muestre a quienes se le cargaron realmente las notas
          AND dac.nota is not NULL
-- ******************************************************************************
   ORDER BY dac.fecha_de_examen

   -- si no encontro nada, devuelve vacios
   RETURN 	vcUnidadAcademica,
		vcCarrera,
		vcLegajo,
		vcActa,
		dFechaExamen,
		vcResultado,
		vcNota,
		vcMateria,
		vcMateriaNombre,
		vcCarreraNombre  WITH RESUME ;
   END FOREACH ;

END;
END PROCEDURE;
-- *****************************************************************************************
revoke execute on sp_actprovisoria from public;

grant execute on sp_actprovisoria to guarani; -- Rol de usuarios de Gestión
grant execute on sp_actprovisoria to internet; -- Usuario de internet

