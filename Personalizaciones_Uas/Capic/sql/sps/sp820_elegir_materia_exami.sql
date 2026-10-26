execute procedure sp820_elegir_materia_exami('FBCB','0301','32276666-4')


-- DROP PROCEDURE sp820_elegir_materia_exami;
CREATE PROCEDURE sp820_elegir_materia_exami(pUnidadAcademica LIKE sga_insc_examen.unidad_academica,
                                   pCarrera         LIKE sga_alumnos.carrera,
                                   pLegajo          LIKE sga_alumnos.legajo)

   RETURNING
             VARCHAR(255), -- carrera nombre (Reducido)
             VARCHAR(5),   -- materia
             VARCHAR(255), -- materia nombre (Reducido)
             VARCHAR(5), --Institucion
             VARCHAR(255), --Nombre Institucion	
             VARCHAR(255), --Acta origen		
             CHAR(1),      -- tipo: 
                           --        '0' : Está inscripto 
                           --        '1': Materia disponible  
             CHAR(1);   --estado(A o R)	
	
  DEFINE vc_carrera_nombre       LIKE sga_carreras.nombre;	
  DEFINE vc_Materia       LIKE sga_materias.materia;
  DEFINE vc_MatNombreRed  LIKE sga_materias.nombre_reducido;
  DEFINE vcInstitucion  LIKE sga_insc_examen.unidad_academica;
  DEFINE vc_Institucion  LIKE sga_equiv_operac.institucion;
  DEFINE vc_NombreInstitucion  LIKE sga_instituciones.nombre;
  DEFINE vc_Acta  LIKE sga_equiv_notasext.acta;
  DEFINE vc_Tipo          CHAR(1);
  DEFINE vc_Estado      CHAR(1);

  BEGIN

  SELECT nombre INTO vc_carrera_nombre FROM sga_carreras where carrera = pCarrera;

  FOREACH SELECT a.materia, d.nombre_reducido, b.institucion, e.nombre, c.acta, a.resultado
             INTO vc_Materia, vc_MatNombreRed, vc_Institucion,vc_NombreInstitucion, vc_Acta, vc_Estado
             	FROM sga_instituciones e, sga_equiv_otorgada a JOIN sga_equiv_operac b
					ON a.operacion_equiv = b.operacion_equiv
				JOIN sga_equiv_notasext c
					ON a.equivalencia = c.equivalencia
				JOIN sga_atrib_mat_plan d
					ON a.unidad_academica = d.unidad_academica 
					and a.carrera = d.carrera
					and a.plan = d.plan
					and a.version = d.version
					and a.materia = d.materia
	WHERE b.institucion = e.institucion
	
	and a.carrera = pCarrera
	and a.legajo = pLegajo
	and a.materia not in (SELECT materia
        				FROM vw_hist_academica 
      				 WHERE unidad_academica = pUnidadAcademica
       				 AND carrera          = pCarrera
				 AND legajo           = pLegajo
        				 AND (resultado = 'A' OR resultado = 'P'))
	and a.alcance = 'P'
	and a.resultado in ('A', 'R')
	and b.nro_resolucion = 'Equiv Capic'	

	LET vc_tipo  = '1';
                 
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
	
      RETURN vc_carrera_nombre,vc_Materia, vc_MatNombreRed, vcInstitucion, vc_NombreInstitucion, vc_Acta, vc_tipo, vc_Estado
         WITH RESUME;
   END FOREACH;

END;
END PROCEDURE;
