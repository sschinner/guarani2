drop procedure "dba".u820_cuenta_apr_repr_periodo;

create procedure "dba".u820_cuenta_apr_repr_periodo(Punidad_academica like sga_alumnos.unidad_academica,
				Pcarrera like sga_alumnos.carrera,
 				Plegajo like sga_alumnos.legajo,
                                                        Pplan like sga_planes.plan,
                                                        Pversion like sga_planes.version_actual, 
                                                        Pperiodo like sga_anio_academico.anio_academico) 
	returning integer, integer;
	
DEFINE  vcPlan, vcVersiontit varchar(5);
DEFINE vAprobadas integer;
DEFINE vReprobadas integer;
DEFINE vFecini date;
DEFINE vfecfin date;
begin
         LET vcPlan = Pplan;
         LET vcVersiontit = Pversion;
         LET vAprobadas   = NULL;
         LET vReprobadas   = NULL;
         LET vFecini = NULL;
         LET vFecfin= NULL;
         BEGIN
    	 on exception in (-206)
       -- Tabla no existe continuo el proceso	
             end exception with resume;
        DROP TABLE tmp_mat_apr_repr;
        END;   
          SELECT fecha_inicio, fecha_fin
                 into vFecini,vFecfin from sga_anio_academico where anio_academico = Pperiodo;
           if vFecini is null  then
                   return null, null;
           end if;
 
          SELECT materia, resultado 
                       FROM vw820_hist_academ
                                 
                         WHERE               
                Punidad_academica = unidad_academica and
                Pcarrera = carrera and
                Plegajo = legajo 
                 and   materia not in (select materia 
		from u820_cursos_ing
		where unidad_academica =  Punidad_academica
			and carrera =  Pcarrera)
                  and fecha >= vFecini and fecha <= vFecfin
            into temp tmp_mat_apr_repr with no log;
           
            Select count(materia) into vAprobadas  from tmp_mat_apr_repr where resultado = 'A'
                  and 
                materia in  (select materia from sga_atrib_mat_plan where carrera = PCarrera 
                                  and plan = vcPlan  and version = vcVersiontit);
            Select count(materia) into vReprobadas   from tmp_mat_apr_repr where resultado = 'R'
                and 
                materia in  (select materia from sga_atrib_mat_plan where carrera = PCarrera 
                                  and plan = vcPlan  and version = vcVersiontit);

           return vAprobadas, vReprobadas;
              
end;
end procedure                
