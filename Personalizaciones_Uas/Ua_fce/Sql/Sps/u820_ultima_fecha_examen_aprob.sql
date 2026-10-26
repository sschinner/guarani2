drop procedure u820_ultima_fecha_examen_aprob;

create procedure "dba".u820_ultima_fecha_examen_aprob(Punidad_academica like sga_alumnos.unidad_academica,
				Pcarrera like sga_alumnos.carrera,
 				Plegajo like sga_alumnos.legajo)
                                                               
	returning date;

define a_fecha_ultima date;	
		

begin
             
           SELECT max(fecha) into a_fecha_ultima
                       FROM vw820_hist_academ
                                 
                         WHERE
                          Punidad_academica = unidad_academica and
                          Pcarrera = carrera and resultado = 'A' and
---------------------------- Modificado 09/09/2014
                      ---    materia not in ("1011",  "1041", "1080") 
                            Pcarrera||materia not in (select carrera||materia from u820_cursos_ing) and
----------------------------------------------
           	Plegajo = legajo;
            return a_fecha_ultima;
              
end;
end procedure;
                                                                                                                                                                                                                          
