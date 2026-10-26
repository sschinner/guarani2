drop PROCEDURE "dba".sp820_n_aplazos_turno; 

CREATE PROCEDURE "dba".sp820_n_aplazos_turno( pUnidadAcademica LIKE sga_personas.unidad_academica, 
pCarrera LIKE sga_carreras.carrera, pPlan LIKE sga_planes.plan, pMateria LIKE sga_materias.materia, pCant Integer,
pTurnoExamen LIKE sga_insc_examen.turno_examen)

   RETURNING   varchar(5),    -- unidad academica
               varchar(5),    -- carrera
               varchar(60),   -- carrera nombre Reducido
               varchar(15),    -- plan
               varchar(5),    -- materia
               varchar(100),  -- materia nombre
               varchar(15),   -- legajo
	varchar(100),  -- apellido
	varchar(100),  -- nombre
	integer;

/* 
Recupera la cantidad de aplazos por carrera y materia de los alumnos que no tienen la materia aprobada y con pCant o mas aplazos.
*/

   --vars para el manejo de excepciones
   DEFINE sql_err         integer;
   DEFINE isam_err        integer;
   DEFINE error_info      varchar(76);

   -- vars locales
   DEFINE vcUnidadAcademica   LIKE sga_alumnos.unidad_academica;
   DEFINE vcCarrera           LIKE sga_alumnos.carrera;
   DEFINE vcCarreraNombre     LIKE sga_carreras.nombre;
   DEFINE vcPlan              LIKE sga_alumnos.plan;
   DEFINE vcMateria           LIKE sga_materias.materia;
   DEFINE vcMateriaNombre  LIKE sga_atrib_mat_plan.nombre_reducido;
   DEFINE vcLegajo            LIKE sga_alumnos.legajo;
   DEFINE vcApellido	LIKE sga_personas.apellido;
   DEFINE vcNombres	LIKE sga_personas.nombres;
   DEFINE viCant	Integer;

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
      RAISE EXCEPTION  sql_err, isam_err, error_info;
   END EXCEPTION;     

BEGIN


select distinct vw.unidad_academica, vw.carrera, vw.plan, vw.materia, vw.legajo, 0 as cant_aplazos
from vw820_hist_academ vw
where unidad_academica = pUnidadAcademica
	and carrera = pCarrera
	and (plan = pPlan)
	and materia = pMateria 
	and resultado = 'A'

union

select distinct unidad_academica, carrera, plan, materia, legajo, cant_aplazos
from u820_habilitados
where unidad_academica = pUnidadAcademica
	and carrera = pCarrera
	and plan = pPlan
	and materia = pMateria 
	and cant_aplazos >= pCant*1
into temp tmp_aprobados;

select vw.unidad_academica, vw.carrera, vw.plan, vw.materia, vw.legajo,  max (p.apellido) apellido, max (p.nombres) nombres, count (*) as cant_aplazos
from vw820_hist_academ vw 
	join sga_alumnos a
		join sga_personas p
		on a.unidad_academica = p.unidad_academica
		and a.nro_inscripcion = p.nro_inscripcion
	on vw.unidad_academica = a.unidad_academica
	and vw.carrera = a.carrera
	and vw.legajo = a.legajo
	and a.calidad = 'A'
where 	vw.unidad_academica = pUnidadAcademica
	and vw.carrera = pCarrera
	and vw.plan = pPlan
	and vw.materia = pMateria 
	and vw.resultado = 'R'
   ----         and ((pMateria = 1030 and vw.fecha >= '07/01/2006') or (pMateria = 2040 and vw.fecha >= '07/01/2007')
  ------                or pMateria not in (1030,2040))
   ---- corrección nov./2011 
                 and vw.fecha >= '06/20/2011'
group by vw.unidad_academica, vw.carrera, vw.plan, vw.materia, vw.legajo, apellido, nombres
having count (*) >= pCant*1
order by 1, 2, 3, 4 , 8, 6, 7
into temp tmp_segui_acad;

delete from tmp_segui_acad where
	 trim(unidad_academica)||trim(carrera)||trim(plan)||trim(materia)||trim(legajo)||(cant_aplazos) in (select trim(unidad_academica)||trim(carrera)||trim(plan)||trim(materia)||trim(legajo)||(cant_aplazos)
			from tmp_aprobados);
delete from tmp_segui_acad where
	 trim(unidad_academica)||trim(carrera)||trim(plan)||trim(materia)||trim(legajo)in (select trim(unidad_academica)||trim(carrera)||trim(plan)||trim(materia)||trim(legajo)
			from tmp_aprobados where cant_aplazos = 0);



delete from tmp_segui_acad where 
      trim(unidad_academica)||trim(carrera)||trim(plan)||trim(materia)||trim(legajo)
      not in (select trim(unidad_academica)||trim(carrera)||trim(plan)||trim(materia)||trim(legajo)
                       from sga_insc_examen  where unidad_academica = pUnidadAcademica  and
                                                                        carrera = pCarrera  and
                                                                        materia = pMateria and
                                                                        turno_examen = pTurnoExamen);


LET vcCarreraNombre = (Select nombre from sga_carreras Where carrera = pCarrera);
LET vcMateriaNombre = (Select nombre from sga_materias Where materia = pMateria);

     FOREACH
        SELECT unidad_academica, carrera, plan, materia, legajo,  apellido, nombres, cant_aplazos INTO vcUnidadAcademica, vcCarrera,  vcPlan, vcMateria,  vcLegajo, vcApellido, vcNombres, viCant FROM tmp_segui_acad
            
          Return vcUnidadAcademica, vcCarrera,  vcCarreraNombre, vcPlan, vcMateria,  vcMateriaNombre, vcLegajo, vcApellido, vcNombres, viCant WITH RESUME;  
     END FOREACH;    

DROP TABLE tmp_segui_acad;
DROP TABLE tmp_aprobados;

END;


END PROCEDURE;
                                                                                                                                                                                                          
