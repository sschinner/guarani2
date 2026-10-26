drop procedure "dba".u820_cuenta_mat_fecha_rapido_sv;
create procedure "dba".u820_cuenta_mat_fecha_rapido_sv(Punidad_academica like sga_alumnos.unidad_academica,
				Pcarrera like sga_alumnos.carrera,
 				Plegajo like sga_alumnos.legajo,
                                                             Pfecha like sga_detalle_acta.fecha_de_examen, 
                                                                Pcuenta char(1)) 
	returning integer;

  
define a_total integer;	


begin
           let a_total = 0;
             
           SELECT count(materia) into a_total
                       FROM vw820_hist_academ
                                 
                         WHERE 
                Punidad_academica = unidad_academica and
                Pcarrera = carrera and
                Plegajo = legajo and          
                resultado = Pcuenta and
                
                fecha  <= Pfecha and
               
                materia in  (select distinct materia from sga_atrib_mat_plan where carrera = PCarrera)
               and   materia not in (select materia 
		from u820_cursos_ing
		where unidad_academica =  Punidad_academica
			and carrera =  Pcarrera);
             

           return a_total;
              
end;
end procedure;                                      
                                                                                                                                                                                                                                                              -- execute  PROCEDURE "dba".u820_cuenta_mat_fecha_rapido_sv('FCE','0201','14305720-1','01/01/2016','A')    
                                                 
-- execute  PROCEDURE "dba".u820_cuenta_mat_fecha_rapido_sv('FCE','0201','22449032-3','01/01/2016','A')    

