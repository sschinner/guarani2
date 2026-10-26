drop PROCEDURE "dba".u820_ctr_optativa_0153;
CREATE PROCEDURE "dba".u820_ctr_optativa_0153 (	v_unidad_academica	like sga_alumnos.unidad_academica,
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
DEFINE vcMensaje  		varchar(255);
DEFINE vnRetorno, v_ok integer;

DEFINE vcMateria	varchar(255);

-- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
RETURN -1, 'ERROR SQL';
END EXCEPTION;

BEGIN


LET vnRetorno = 1 ;

LET vcMateria = (select  nombre_reducido 
	from sga_atrib_mat_plan 
	where unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and plan = v_plan
		and version = v_version
		and materia = 3120);

-- si existe aprobada la materia 3120 no se puede inscribir

IF EXISTS (select '1' from vw820_hist_academ
		where unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and legajo = v_legajo
    		and materia = '3120'
		and resultado = 'A') THEN

	 	let vcMensaje =  'Tenés aprobada la materia ' || vcMateria ;
                                              return -1, vcMensaje;
END IF;

-- debe tener aprobada la materia 1020

LET vcMateria = (select  nombre_reducido 
	from sga_atrib_mat_plan 
	where unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and plan = v_plan
		and version = v_version
		and materia = 1020);

IF NOT EXISTS (select '1' from vw820_hist_academ
		where unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and legajo = v_legajo
		and materia = '1020' 
		and resultado = 'A') THEN
                            let vcMensaje =  'No tenés aprobada la materia ' || vcMateria ;
                            return -1, vcMensaje;

END IF;
-- Debe pertenecer a la carrera 0201

if v_carrera <> '0201' then
   let vcMensaje =  'No pertenecés a la carrera de  Contador Público Nacional';
   return -1, vcMensaje;
end if ;

return 1, '';


END;
END PROCEDURE;
                                                                                                                                             
