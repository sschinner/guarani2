DROP procedure u820_comp_hab_d2;
create procedure u820_comp_hab_d2 (	v_unidad_academica	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_materias.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like  sga_planes.version_actual)
				
		returning smallint, varchar(255);

DEFINE sqlerr		integer;
DEFINE isamerr		integer;
DEFINE errorinfo		varchar(76);

-- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
--	RETURN -1, errorInfo;
RETURN -1, 'ERROR SQL';
END EXCEPTION;

begin

DEFINE vcMensaje  		varchar(255);
DEFINE vnRetorno, v_ok integer;

DEFINE vcMateria	varchar(255);

LET vnRetorno = 1 ;

--- Se coloca retorno 1 para saltar el control por inscripciones 1er cuat 2007
---  return 1, '';

LET vcMateria = (select  nombre_reducido 
	from sga_atrib_mat_plan 
	where unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and plan = v_plan
		and version = v_version
		and materia = v_materia);

-- si existe un examen de Derecho Publico  rendido y aprobado despues de: '05/01/2006'.

IF EXISTS (select '1' from vw820_hist_academ
		where unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and legajo = v_legajo
		and materia = '1030' -- codigo de Derecho Publico
		and resultado = 'A'
		and fecha >= '05/01/2006') THEN

	 	return 1, '';
ELSE
		select count (*) into 	v_ok
		from sga_cursadas
		where unidad_academica = v_unidad_academica
			and carrera = v_carrera
			and legajo = v_legajo
			and materia = '1030'
			and resultado = 'A'
			and cond_regularidad = 11 -- codigo de la condicion de complemento habilitante
			and fin_vigencia_regul >= TODAY;

		if v_ok >= 1 then
				return 1, '';
		else
			    let vcMensaje =  'No tenés un Complemento Habilitante de la materia ' || vcMateria || ' aprobado';
                                                    return -1, vcMensaje;
		end if;
END IF;


end;
end procedure;
                                                 
