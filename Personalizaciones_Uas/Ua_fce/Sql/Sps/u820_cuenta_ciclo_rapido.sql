DROP procedure "dba".u820_cuenta_ciclo_rapido;

create procedure "dba".u820_cuenta_ciclo_rapido (Punidad_academica like sga_alumnos.unidad_academica,
				Pcarrera like sga_alumnos.carrera,
 				Plegajo like sga_alumnos.legajo,
                                                             Pciclo like sga_materias_ciclo.ciclo, 
                                                                Pcuenta char(1),
                                                        Pplan like sga_planes.plan,
                                                        Pversion like sga_planes.version_actual) 
	returning integer;

  
define a_total integer;	
define a_total_eq integer;	
define vcCalidad   varchar(11);	
DEFINE  vcPlan, vcVersiontit       varchar(5);

begin
           let a_total = 0;
          let vcPlan = Pplan;
            let vcVersiontit = Pversion;

             
           SELECT count(materia) into a_total
                       FROM vw820_hist_academ
                                 
                         WHERE 
                
                Punidad_academica = unidad_academica and
                Pcarrera = carrera and
                Plegajo = legajo and          
                resultado = Pcuenta and
               
                materia in  (select c.materia from sga_atrib_mat_plan t, sga_materias_ciclo  c where carrera = PCarrera 
                                  and plan = vcPlan  and version = vcVersiontit and t.materia = c.materia and c.ciclo = Pciclo)
                  and   materia not in (select materia 
		from u820_cursos_ing
		where unidad_academica =  Punidad_academica
			and carrera =  Pcarrera);
             

           return a_total;
              
end;
end procedure;                                                                                                         
                                                                                                                                                                                                                                                                                                              
-- execute  PROCEDURE "dba".u820_cuenta_ciclo_rapido('FCE','0201','14305720-1','0201','CBC-2','A','05/10')    
-- execute  PROCEDURE "dba".u820_cuenta_ciclo_rapido('FCE','0201','22449032-3','0201','CBC-2','A','05/10')    

