-- *******************************************************************************
-- Controla si el Alumno tiene una regularidad vigente en la materia, pero en otra UA. En ese caso solo debería permitirle rendir como libre.
-- El control esta asociado al Punto de Control Nro 10 (Alumno - Llamado Mesa de Examen)
-- *******************************************************************************

insert into par_implem_control (stored_procedure, parametros) values ("ctrcapic02_cursada2", "s,s,s,s,n,s,s,n,s");

insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (8209902, "ctrcapic02_cursada2", "Control Capic: Regularidad Vigente", "Controla que el Alumno no tenga regularidad Vigente obtenida en otra UA", null);

insert into par_cont_x_punto (punto_de_control, control) values (10, 8209902);

execute procedure sp_confcont_cont (10, 8209902);

-- **************************************************************************
-- Control: ctrcapic02_cursada2
--
-- Controla si el Alumno tiene una regularidad vigente de la materia, obtenida en otra UA.
--       devuelve:  1 - si esta OK         No Tiene 
--                 -1 - en otro caso       Tiene 
--
-- **************************************************************************

-- Dropping procedure
-- DROP PROCEDURE "dba".ctrcapic02_cursada2;
 
-- Creating procedure
CREATE PROCEDURE "dba".ctrcapic02_cursada2(pUnidadAcademica	LIKE sga_alumnos.unidad_academica,
	pCarrera		LIKE sga_alumnos.carrera,
	pLegajo 		LIKE sga_alumnos.legajo,
	pMateria 		LIKE sga_mesas_examen.materia,
	pAnioAcademico 	LIKE sga_mesas_examen.anio_academico,
	pTurnoExamen	LIKE sga_mesas_examen.turno_examen,
	pMesaExamen 	LIKE sga_mesas_examen.mesa_examen,
	pLlamado 	LIKE sga_insc_examen.llamado,
	pTipoInscripcion	LIKE sga_insc_examen.tipo_inscripcion)

	RETURNING 	smallint,       -- status
			varchar(255);   -- <mensaje, parametros>

  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros


  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 	integer;
   DEFINE error_info 	varchar(76);
   DEFINE vcUserError	varchar(10);
   DEFINE vc_carrera_nombre       LIKE sga_carreras.nombre;	
   DEFINE vc_Materia       LIKE sga_materias.materia;
   DEFINE vc_MatNombreRed  LIKE sga_materias.nombre_reducido;
   DEFINE vcInstitucion  LIKE sga_insc_examen.unidad_academica;
   DEFINE vc_Institucion  LIKE sga_equiv_operac.institucion;
   DEFINE vc_NombreInstitucion  LIKE sga_instituciones.nombre;
   DEFINE vc_Acta  LIKE sga_equiv_notasext.acta;


   -- variables locales
 
   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'ctrcapic02_cursada2' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN
   -- seteo los valores default
   LET iStatus		= 1 ;
   LET vcMsg		= 'OK';
	LET vc_Materia	= NULL;
	LET vc_MatNombreRed = NULL;
	LET vc_Institucion 	 = NULL;
	LET vc_NombreInstitucion = NULL;
	LET vc_Acta = NULL;
	LET vcInstitucion  = NULL;
	LET vc_carrera_nombre = NULL;
	LET vc_NombreInstitucion  = NULL;

-- Verifico si tiene una regularidad vigente obtenida en otra UA.
SELECT a.materia, d.nombre_reducido, b.institucion, e.nombre, c.acta, car.nombre
             INTO vc_Materia, vc_MatNombreRed, vc_Institucion,vc_NombreInstitucion, vc_Acta, vc_carrera_nombre 
             	FROM sga_instituciones e, 
		sga_equiv_otorgada a 
			JOIN sga_equiv_operac b
				ON a.operacion_equiv = b.operacion_equiv
			JOIN sga_equiv_notasext c
				ON a.equivalencia = c.equivalencia
			JOIN sga_atrib_mat_plan d
				ON a.unidad_academica = d.unidad_academica 
					and a.carrera = d.carrera
					and a.plan = d.plan
					and a.version = d.version
					and a.materia = d.materia
			JOIN sga_carreras car
				ON car.carrera = d.carrera
	WHERE b.institucion = e.institucion
	
	and a.carrera = pCarrera
	and a.legajo = pLegajo
	and a.materia = pMateria
	and a.materia not in (SELECT materia
        				FROM vw_hist_academica 
      				 WHERE unidad_academica = pUnidadAcademica
       				 AND carrera          = pCarrera
				 AND legajo           = pLegajo
        				 AND (resultado = 'A' OR resultado = 'P'))
	and a.alcance = 'P'
	and a.resultado in ('A', 'R')
	and b.nro_resolucion = 'Equiv Capic'
	and a.vencimiento >= today;

                SELECT CASE 
		WHEN vc_Institucion = 100 		THEN "FICH"
		WHEN vc_Institucion = 101		THEN "FBCB" 
		WHEN vc_Institucion = 102	 	THEN "ESS"
		WHEN vc_Institucion = 103		THEN "FADU" 
		WHEN vc_Institucion = 104 		THEN "FHUC"
		WHEN vc_Institucion = 105 		THEN "FCM"
		WHEN vc_Institucion = 106		THEN "ISM" 
		WHEN vc_Institucion = 107		THEN "FCJS" 
		WHEN vc_Institucion = 108		THEN "FCA" 
		WHEN vc_Institucion = 109 		THEN "FCV"
		WHEN vc_Institucion = 110		THEN "FCE" 
		WHEN vc_Institucion = 111		THEN "FIQ" 
	END
	INTO vcInstitucion
	FROM sga_instituciones
		WHERE institucion = vc_Institucion;

   IF ((pTipoInscripcion = 'R') OR (pTipoInscripcion = 'L'))
	and  (vc_materia IS NOT NULL) THEN

		LET iStatus		= -1 ;
		LET vcMsg		= '8209902' || ',' || vc_MatNombreRed || ',' || vc_carrera_nombre || ',' || vcInstitucion;


   END IF;
   
RETURN iStatus, vcMsg; 
END;
END PROCEDURE;
-- ************************ Fin Control ctrcapic02_cursada2 ***********************


