DROP PROCEDURE "dba".sp820_materias_adeuda;
CREATE PROCEDURE "dba".sp820_materias_adeuda( pUA LIKE sga_carrera_aspira.unidad_academica, pCarrera LIKE sga_alumnos.carrera, plegajo like sga_alumnos.legajo)
       RETURNING    varchar(5),  -- unidad academica
		varchar(5),  -- carrera
	                varchar(15),          -- legajo
                                 varchar(5) ,    ----materia
                                   varchar(255) ;   ---- nombre materia


 DEFINE vUnidadAcademica, pUnidadAcademica LIKE sga_alumnos.unidad_academica;
 DEFINE vCarrera LIKE sga_alumnos.carrera;
  DEFINE vLegajo LIKE sga_alumnos.legajo;
  DEFINE vMateria LIKE sga_materias.materia;
  DEFINE vNombre LIKE sga_materias.nombre;  

begin

 -- inicializo valores default
 LET vUnidadAcademica   = NULL;
 LET vCarrera   = NULL;
 LET vLegajo   = NULL;
 LET vMateria  = NULL;
 LET vNombre   = NULL;
 FOREACH
SELECT  sga_alumnos.unidad_academica,
   
               sga_carreras.carrera,
   
               sga_alumnos.legajo,
    
          sga_atrib_mat_plan.materia,
 
          sga_materias.nombre
into vUnidadAcademica, vCarrera, vLegajo, vMateria, vNombre
      	
    FROM sga_carreras,

	 sga_alumnos,

	 sga_personas,

          mdp_tipo_documento,

          sga_atrib_mat_plan,

          sga_materias			
   WHERE  		 sga_alumnos.unidad_academica =   pUA  AND 
			 sga_alumnos.carrera =   pCarrera  AND 
			 sga_alumnos.legajo  =  pLegajo   AND 

(
   (sga_alumnos.carrera||sga_alumnos.legajo not in
        (SELECT carrera||legajo FROM dba.sga_orient_alumno
         WHERE unidad_academica =  pUA) 
     and 
     sga_atrib_mat_plan.materia in       
           (select sga_atrib_mat_plan.materia 
               from sga_atrib_mat_plan,
                      sga_planes 
               where sga_atrib_mat_plan.carrera =  pCarrera
                  and sga_planes.carrera =  pCarrera
                  and sga_planes.estado = 'V' 
                  and sga_atrib_mat_plan.plan = sga_planes.plan 
                  and sga_atrib_mat_plan.version = sga_planes.version_actual)
   )
    or
   (sga_alumnos.carrera||sga_alumnos.legajo in
        (SELECT carrera||legajo  FROM dba.sga_orient_alumno
         WHERE unidad_academica =  pUA) 
     and 
     sga_atrib_mat_plan.materia in       
            (select sga_materias_ciclo.materia
                from sga_materias_ciclo 
            where ciclo in 
               (SELECT ciclo FROM dba.sga_ciclos_orient, dba.sga_planes
                             WHERE sga_ciclos_orient.plan = sga_planes.plan 
                              and sga_ciclos_orient.version = sga_planes.version_actual 
                              and sga_ciclos_orient.titulo = sga_ciclos_orient.carrera 
                              and (sga_ciclos_orient.orientacion in 
                                        (SELECT orientacion   FROM dba.sga_orient_alumno
                                              WHERE carrera = pCarrera and legajo = pLegajo)
                                          or sga_ciclos_orient.orientacion = 0)
                             AND  sga_ciclos_orient.carrera	= pCarrera
                             and sga_planes.carrera = pCarrera 
                             and sga_planes.estado = 'V' )
            )
   )
)

and
------------------- modificado 09/09/2014
         -----     sga_atrib_mat_plan.materia not in ('1041', '1081', '1011')  

	pCarrera||sga_atrib_mat_plan.materia  not in (select carrera||materia from u820_cursos_ing)       
--------------------------------------------------------------------------------------
           and

            sga_atrib_mat_plan.tipo_materia <> "O"

                and
            
          sga_carreras.carrera = sga_alumnos.carrera and

			 sga_atrib_mat_plan.unidad_academica =  sga_alumnos.unidad_academica and
			 sga_atrib_mat_plan.carrera =  sga_alumnos.carrera and	
			 sga_atrib_mat_plan.plan =  sga_alumnos.plan and
          sga_atrib_mat_plan.materia =  sga_materias.materia and

 ( 
   (sga_alumnos.carrera||sga_alumnos.legajo not in
        (SELECT carrera||legajo FROM dba.sga_orient_alumno
         WHERE unidad_academica =  pUA) 
     and 
     sga_atrib_mat_plan.version in
           (select sga_planes.version_actual
               from sga_atrib_mat_plan,
                      sga_planes 
               where sga_atrib_mat_plan.carrera =  pCarrera
                  and sga_planes.carrera =  pCarrera
                  and sga_planes.estado = 'V' 
                  and sga_atrib_mat_plan.plan = sga_planes.plan 
                  and sga_atrib_mat_plan.version = sga_planes.version_actual)
   )
    or
   (sga_alumnos.carrera||sga_alumnos.legajo in
        (SELECT carrera||legajo  FROM dba.sga_orient_alumno
         WHERE unidad_academica =  pUA) 
     and 
     sga_atrib_mat_plan.version in       
            (select sga_ciclos_orient.version
                from sga_ciclos_orient 
            where ciclo in 
               (SELECT ciclo FROM dba.sga_ciclos_orient, dba.sga_planes
                             WHERE sga_ciclos_orient.plan = sga_planes.plan 
                              and sga_ciclos_orient.version = sga_planes.version_actual 
                             and sga_ciclos_orient.titulo = sga_ciclos_orient.carrera 
                              and (sga_ciclos_orient.orientacion in 
                                        (SELECT orientacion   FROM dba.sga_orient_alumno
                                              WHERE carrera = pCarrera and legajo = pLegajo)
                                          or sga_ciclos_orient.orientacion = 0)
                             AND  sga_ciclos_orient.carrera	= pCarrera
                             and sga_planes.carrera = pCarrera 
                             and sga_planes.estado = 'V' )
            )
   )
)

 and

          sga_materias.tipo_de_materia <> "O" and	
          sga_materias.tipo_de_materia <> "G" and	

			 sga_personas.unidad_academica =  sga_alumnos.unidad_academica AND 
			 sga_personas.nro_inscripcion  =  sga_alumnos.nro_inscripcion  AND

			 mdp_tipo_documento.tipo_documento =  sga_personas.tipo_documento  and


             not ( (sga_alumnos.carrera = "0203" and 
                 sga_atrib_mat_plan.materia in ('2270',
 '4020',
 '3040',
 '3230',
 '1005',
 '1006',
 '3001')) or

                (sga_alumnos.carrera = "0202" and 
                 sga_atrib_mat_plan.materia in ('2270',
 '4160',
 '3150',
 '1005',
 '1006',
 '4340')) or

                (sga_alumnos.carrera = "0201" and 
                 sga_atrib_mat_plan.materia in ('2270',
 '1005',
 '1006',
 '4340',
 '0154')) )     and

                                             sga_atrib_mat_plan.materia not in

         (   SELECT   
         vw820_hist_academ.materia

			
    FROM   
			  
			 sga_alumnos,

			 sga_personas,

          mdp_tipo_documento,

          sga_materias,

          sga_carreras,


         vw820_hist_academ
			
   WHERE                               
          sga_materias.tipo_de_materia <> "G" AND

          sga_carreras.carrera = sga_alumnos.carrera and
		
				 sga_alumnos.unidad_academica =   pUA  AND 
			 sga_alumnos.carrera =   pCarrera  AND 
			 sga_alumnos.legajo  =  pLegajo   AND 

 
			 sga_personas.unidad_academica =  sga_alumnos.unidad_academica AND 
			 sga_personas.nro_inscripcion  =  sga_alumnos.nro_inscripcion  AND

			 mdp_tipo_documento.tipo_documento =  sga_personas.tipo_documento  AND
         vw820_hist_academ.resultado  = "A" AND
     
           vw820_hist_academ.materia =  sga_materias.materia  AND
      vw820_hist_academ.unidad_academica  =  sga_materias.unidad_academica   AND
 vw820_hist_academ.unidad_academica =  sga_alumnos.unidad_academica AND
     vw820_hist_academ.carrera = sga_alumnos.carrera AND
vw820_hist_academ.legajo = sga_alumnos.legajo
          )

RETURN     vUnidadAcademica, vCarrera, vLegajo, vMateria, vNombre 
      WITH RESUME;

   END FOREACH ;

END;

END PROCEDURE;                           
