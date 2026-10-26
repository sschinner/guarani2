drop procedure "dba".u820_exa_hab;
create procedure "dba".u820_exa_hab(	v_unidad_academica	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_actas_examen.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like  sga_planes.version_actual)
				
		returning smallint, varchar(255);

DEFINE sqlerr		integer;
DEFINE isamerr		integer;
DEFINE errorinfo		varchar(76);

-- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
	RETURN -1, errorInfo;
END EXCEPTION;

begin

DEFINE vcMensaje  	varchar(255);
DEFINE vnRetorno, v_ok integer;
DEFINE v_c_nombre_mat	varchar(30);

  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros
   DEFINE vcUserError	varchar(100);

LET vnRetorno = 1 ;
LET v_c_nombre_mat = '  ';

---Obtiene  nombre materia
select nombre_reducido into v_c_nombre_mat from sga_atrib_mat_plan 
                                                                      where unidad_academica = v_unidad_academica 
                                                                                and carrera = v_carrera
				                        and plan = v_plan
                                                                                and version = v_version
                                                                                and materia = v_materia;

EXECUTE PROCEDURE u820_2_tercios ( v_Unidad_Academica, v_Carrera, v_Legajo, v_Materia, v_Plan , v_Version ) INTO vnRetorno, vcMensaje ;

	if vnRetorno = -1 then
		return -1, vcMensaje ;
	
	else
		select count (*) into 	v_ok
		from sga_cursadas
		where unidad_academica = v_unidad_academica
			and carrera = v_carrera
			and legajo = v_legajo
			and materia = v_materia
			and resultado = 'A'
			and cond_regularidad = 9
			and fin_vigencia_regul >= TODAY;

		if v_ok >=1 then

                               LET iStatus = 1;
		   LET vcMsg = "OK";
        	                 RETURN iStatus, vcMsg;
	                else
                                LET iStatus = -1;
                                LET vcUserError = '82002033';
		    LET vcMsg = vcUserError || ',' || v_c_nombre_mat;	
		    RETURN iStatus, vcMsg;
	             end if;
	end if;


end;
end procedure;
                                                                                                                                                                                                               
