DROP procedure "dba".u820_cuenta_mat;
create procedure "dba".u820_cuenta_mat(Punidad_academica like sga_alumnos.unidad_academica,
				Pcarrera like sga_alumnos.carrera,
 				Plegajo like sga_alumnos.legajo,
                                                                Pcuenta char(1)) 
	returning integer;


define a_total integer;	
define a_total_eq integer;	
define vcCalidad   varchar(11);	
DEFINE  vcPlan, vcVersiontit       varchar(5);

begin

             let a_total = 0;

            SELECT alu.calidad into vcCalidad 
             FROM sga_alumnos alu
              WHERE 	
             alu.unidad_academica = Punidad_academica  and  
                 alu.carrera = Pcarrera  and  
                 alu.legajo = Plegajo;
           
             IF vcCalidad = 'E'
             THEN
                 (SELECT distinct sga_titulos_otorg.plan, sga_titulos_otorg.version
                  INTO vcPlan, vcVersiontit
                  FROM sga_titulos_otorg
                  WHERE sga_titulos_otorg.unidad_academica = Punidad_academica 
                  AND sga_titulos_otorg.carrera = pCarrera
                  AND sga_titulos_otorg.legajo = pLegajo 
                  AND sga_titulos_otorg.fecha_egreso =
                              (SELECT MAX(tito.fecha_egreso)
                                                       FROM  sga_titulos_otorg tito
                                                      WHERE tito.unidad_academica = Punidad_academica 
                                                      AND tito.carrera = pCarrera
                                                      AND tito.legajo = pLegajo));
             ELSE
              (SELECT sga_planes.plan, sga_planes.version_actual
                  INTO vcPlan, vcVersiontit
                  FROM sga_planes
                  WHERE sga_planes.unidad_academica = Punidad_academica 
                  AND sga_planes.carrera = pCarrera
                  AND sga_planes.estado = 'V');
            END IF;
             
           SELECT count(materia) into a_total
                       FROM vw820_hist_academ
                                 
                         WHERE 
                
                Punidad_academica = unidad_academica and
                Pcarrera = carrera and
           	Plegajo = legajo and          
                resultado = Pcuenta and
                materia in  (select materia from sga_atrib_mat_plan where carrera = PCarrera 
                                  and plan = vcPlan  and version = vcVersiontit)
                 and   materia not in (select materia 
		from u820_cursos_ing
		where unidad_academica =  Punidad_academica
			and carrera =  Pcarrera);
             
            
           return a_total;
              
end;
end procedure;                                                 
                                                                                                                                                                                                                                                                                                            
-- execute  PROCEDURE "dba".u820_cuenta_mat('FCE','0201','14305720-1','A')    
-- execute  PROCEDURE "dba".u820_cuenta_mat('FCE','0201','22449032-3','A')    

