DROP PROCEDURE "dba".u820_comp_hab_cursar;
CREATE PROCEDURE "dba".u820_comp_hab_cursar (	v_unidad_academica	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_materias.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like  sga_planes.version_actual
)
				
RETURNING smallint, varchar(255);

DEFINE sqlerr		integer;
DEFINE isamerr		integer;
DEFINE errorinfo		varchar(76);
DEFINE vcMensaje  	varchar(255);
DEFINE vnRetorno, v_ok integer;
DEFINE v_i_anio_cursada integer;
DEFINE v_i_valida integer;

DEFINE vcMateria	varchar(255);

-- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
RETURN -1, 'ERROR SQL'||errorInfo;
END EXCEPTION;

BEGIN


LET vnRetorno = 1 ;
LET vcMateria = (select  nombre_reducido 
	from sga_atrib_mat_plan 
	where unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and plan = v_plan
		and version = v_version
		and materia = '1030');
LET  v_i_valida = 1 ;
IF EXISTS (select '1' from vw820_hist_academ
		where unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and legajo = v_legajo
    		and materia = '2040' -- codigo de Derecho Privado o Instituciones de Derecho II
		and resultado = 'A') THEN

	 	LET  v_i_valida = 0 ;
END IF;
--------------
LET v_i_anio_cursada = 0;
select anio_de_cursada INTO v_i_anio_cursada
from sga_atrib_mat_plan
where unidad_academica = v_unidad_academica
	and carrera = v_carrera
	and plan = v_plan
	and version = v_version
	and materia = v_materia;
-----
IF v_i_valida = 1  THEN
 EXECUTE PROCEDURE u820_comp_hab_d2( v_unidad_academica, v_carrera, v_legajo, v_materia, v_plan , v_version )     
               INTO vnRetorno, vcMensaje ;	
END IF;
 if vnRetorno = -1 then    
		 let vcMensaje =  'No tenés un Complemento de la materia ' || vcMateria || ' aprobado';
		 return -1, vcMensaje ;
 else
                 if (v_carrera = '0202' and v_materia = '3010')    or
                       v_i_anio_cursada in (4, 5)    then            
                       EXECUTE PROCEDURE u820_2_tercios(v_unidad_academica, v_carrera, v_legajo, v_materia, v_plan, v_version)    
                                                INTO vnRetorno, vcMensaje ;	
                        if vnRetorno = -1 then    
		 return -1, vcMensaje ;
                        else
                                 return 1, '';
                        end if;
                 else
                       return 1, '';
                 end if;
 end if;

END;
END PROCEDURE;
                                                                                                                                                                                                                                                     
