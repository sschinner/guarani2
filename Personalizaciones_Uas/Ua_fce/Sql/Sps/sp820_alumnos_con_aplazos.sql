DROP PROCEDURE "dba".sp820_alumnos_con_aplazos;
CREATE PROCEDURE "dba".sp820_alumnos_con_aplazos( pUnidadAcademica LIKE sga_personas.unidad_academica, pCarrera LIKE sga_carreras.carrera, pCant Integer, pFecha	 varchar(10))

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
Recupera los alumnos que tienen la cantidad o mas de aplazos ingresados, a partir de la fecha ingresada
*/

   --vars para el manejo de excepciones
   DEFINE sql_err         integer;
   DEFINE isam_err        integer;
   DEFINE error_info      varchar(76);

   -- vars locales
    DEFINE dFecha		date;


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
  LET dFecha = stringToDate( pFecha, '%d-%m-%Y');

SELECT  alu.carrera, 
         car.nombre,  
         alu.legajo,   
         asp.periodo_inscripcio,
         alu.nro_inscripcion,
         per.apellido,
         per.nombres,
         per.nro_documento, 
         alu.calidad,
         alu.unidad_academica
    FROM sga_alumnos alu,   
         sga_personas per,
         sga_carrera_aspira  asp,
         sga_carreras car      
        
   WHERE car.unidad_academica = pUnidadAcademica and
               (car.carrera = pCarrera or  car.carrera is null) and 
              alu.unidad_academica = car.unidad_academica and
              alu.carrera = car.carrera and              
              alu.calidad = "A"    and

         per.nro_inscripcion = alu.nro_inscripcion   and

         asp.unidad_academica = alu.unidad_academica and
         asp.carrera = alu.carrera and
         asp.nro_inscripcion = alu.nro_inscripcion  
     
         into temp tmp_intermedia;
  
    SELECT sga_cursadas.carrera,sga_cursadas.legajo, tmp_intermedia.apellido,tmp_intermedia.nombres,sga_cursadas.materia, COUNT(*) as cantidad, max(sga_cursadas.fecha_regularidad) as fecha
	  FROM sga_cursadas,tmp_intermedia
	 WHERE sga_cursadas.unidad_academica = pUnidadAcademica
	   AND (sga_cursadas.carrera = tmp_intermedia.carrera or sga_cursadas.carrera is null)
	   AND sga_cursadas.legajo = tmp_intermedia.legajo
	   AND NVL(sga_cursadas.fin_vigencia_regul, TODAY) >= TODAY 
                   AND sga_cursadas.cond_regularidad in (10,12)
	  group by sga_cursadas.carrera,sga_cursadas.legajo, sga_cursadas.materia,tmp_intermedia.apellido,tmp_intermedia.nombres
          into temp tmp_intermedia2;

-- Para estos alumnos determina si tienen tres aplazos luego de la regularidad

/* COMENTO ESTO QUE DA ERROR
select vw.carrera, vw.plan, vw.materia, vw.legajo
,  max (p.apellido) apellido, max (p.nombres) nombres
, count (*) as cant_aplazos
from vw820_hist_academ vw, TMP_INTERMEDIA2 p where
		vw.unidad_academica = pUnidadAcademica
		and vw.carrera = p.carrera
	and vw.legajo = p.legajo
                and vw.materia = p.materia
	and vw.resultado = 'R'
                and (vw.fecha >=p.fecha and vw.fecha >= '06/01/2011')
group by vw.carrera, vw.plan, vw.materia, vw.legajo, apellido, nombres
having count (*) >= pCant*1;
*/

-----Hasta aca
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
--	and plan = pPlan
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
                and ((pMateria = 1030 and vw.fecha >= '07/01/2006') or (pMateria = 2040 and vw.fecha >= '07/01/2007')
                       or pMateria not in (1030,2040))
group by vw.unidad_academica, vw.carrera, vw.plan, vw.materia, vw.legajo, apellido, nombres
--having count (*) >= pCant*1
having count (*) = pCant*1
order by 1, 2, 3, 4 , 8, 6, 7
into temp tmp_segui_acad;


delete from tmp_segui_acad where
	 trim(unidad_academica)||trim(carrera)||trim(plan)||trim(materia)||trim(legajo)||(cant_aplazos) in (select trim(unidad_academica)||trim(carrera)||trim(plan)||trim(materia)||trim(legajo)||(cant_aplazos)
			from tmp_aprobados);
delete from tmp_segui_acad where
	 trim(unidad_academica)||trim(carrera)||trim(plan)||trim(materia)||trim(legajo)in (select trim(unidad_academica)||trim(carrera)||trim(plan)||trim(materia)||trim(legajo)
			from tmp_aprobados where cant_aplazos = 0);
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
                                                                                                                                                                                                                    
