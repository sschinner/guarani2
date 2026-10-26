drop  procedure "dba".u820_controla_28mat; 
create procedure "dba".u820_controla_28mat (v_unidad_academica	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_actas_examen.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like sga_planes.version_actual)
				
		returning smallint, varchar(255);

DEFINE sqlerr		integer;
DEFINE isamerr		integer;
DEFINE errorinfo		varchar(76);

  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros
  DEFINE vcUserError	varchar(100);
  DEFINE vcMensaje  		varchar(255);
  DEFINE vnRetorno, v_ok integer;
  -- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
	RETURN -1, errorInfo;
END EXCEPTION;

begin

DEFINE v_i_cantidad	integer;
DEFINE v_i_controla	integer;
DEFINE v_c_nombre_mat	varchar(30);

LET v_i_cantidad = 0;
LET v_i_controla = 28;
LET v_c_nombre_mat = '  ';

---Obtiene  nombre materia
select nombre_reducido into v_c_nombre_mat from sga_atrib_mat_plan 
                                                                      where unidad_academica = v_unidad_academica 
                                                                                and carrera = v_carrera
				                        and plan = v_plan
                                                                                and version = v_version
                                                                                and materia = v_materia;
LET vnRetorno = 1 ;
execute procedure u820_cuenta_mat_rapido (v_unidad_academica,v_carrera,v_legajo,'A',v_plan,v_version)	 INTO v_i_cantidad;

IF v_i_cantidad >= v_i_controla then
                                 LET iStatus = 1;
		     LET vcMsg = "OK";
        	                   RETURN iStatus, vcMsg;
else
                                LET iStatus = -1;
		    LET vcUserError = '82002032';
		    LET vcMsg = vcUserError || ',' || v_i_controla || ',' || v_c_nombre_mat;	
		    RETURN iStatus, vcMsg;
end if;


end;
end procedure;
                                                                                                                                                                                                              
