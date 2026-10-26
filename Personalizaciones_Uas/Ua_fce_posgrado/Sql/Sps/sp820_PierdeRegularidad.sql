drop procedure sp820_PierdeRegularidad;
CREATE PROCEDURE "dba".sp820_PierdeRegularidad( pUnidadAcademica LIKE sga_personas.unidad_academica, pcarrera LIKE sga_alumnos.carrera, pcant integer)

      RETURNING   integer,
               varchar(5),    -- unidad academica
               varchar(5),    -- carrera
               varchar(60),   -- carrera nombre Reducido
               varchar(15),    -- plan
               varchar(5),    -- materia
               varchar(100),  -- materia nombre
               varchar(15),   -- legajo
	varchar(100),  -- apellido
	varchar(100),  -- nombre
	integer  --- cantidad aplazos;

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

------- Obteniene todos los alumnos activos que tengan 3 o mas aplazos en una materia en la cual tienen regularidad 10 o 12 
-------- y la obtenciòn de los aplazos sea posterior al inicio de la regularidad - considerando siempre la última regularidad obtenida - y mayor a la fecha de la norma 01/06/2011

-- Obtiene todos los alumnos activos de la carrera ingresada como parámetro
    
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
               ((car.carrera in ( '0201','0202','0203','0205') and  pcarrera = '0000')
               or car.carrera = pcarrera) and
              alu.unidad_academica = car.unidad_academica and
              alu.carrera = car.carrera and              
               alu.calidad = "A"    and
               per.nro_inscripcion = alu.nro_inscripcion   and
               asp.unidad_academica = alu.unidad_academica and
               asp.carrera = alu.carrera and
               asp.nro_inscripcion = alu.nro_inscripcion  
         into temp tmp_intermedia;

---  Obtiene la máxima regularidad obtenida, vigente a la fecha
   SELECT sga_cursadas.carrera,sga_cursadas.legajo, tmp_intermedia.apellido,tmp_intermedia.nombres,sga_cursadas.materia, COUNT(*) as cantidad, max(sga_cursadas.fecha_regularidad) as fecha
	  FROM sga_cursadas,tmp_intermedia
	 WHERE sga_cursadas.unidad_academica = pUnidadAcademica
	   AND (sga_cursadas.carrera = tmp_intermedia.carrera or sga_cursadas.carrera is null)
	   AND sga_cursadas.legajo = tmp_intermedia.legajo
	   AND NVL(sga_cursadas.fin_vigencia_regul, TODAY) >= TODAY 
                   AND sga_cursadas.cond_regularidad in (10,12)
	  group by sga_cursadas.carrera,sga_cursadas.legajo, sga_cursadas.materia,tmp_intermedia.apellido,tmp_intermedia.nombres
          into temp tmp_intermedia2;

-- Determina si tienen tres aplazos luego de la obtención de la regularidad y posterior al 01/06/2011 - fecha de la normativa
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
having count (*) >= pcant into temp  tmp_intermedia3;

-- Determina nombre carrera y materia
FOREACH
        SELECT pUnidadAcademica, p.carrera, c.nombre, p.plan, p.materia, m.nombre,p.legajo,  p.apellido, p.nombres, p.cant_aplazos 
         INTO vcUnidadAcademica, vcCarrera,  vcCarreraNombre, vcPlan, vcMateria, vcMateriaNombre, vcLegajo, vcApellido, vcNombres, viCant FROM tmp_intermedia3 p, sga_carreras c, sga_materias m
          Where p.carrera = c.carrera and p.materia = m.materia
          Return pcant, vcUnidadAcademica, vcCarrera,  vcCarreraNombre, vcPlan, vcMateria,  vcMateriaNombre, vcLegajo, vcApellido, vcNombres, viCant WITH RESUME;  
     END FOREACH;    
drop table tmp_intermedia;   
drop table tmp_intermedia2;  
drop table tmp_intermedia3;  

END;
END PROCEDURE;                                                                                                                                                                                                                         

