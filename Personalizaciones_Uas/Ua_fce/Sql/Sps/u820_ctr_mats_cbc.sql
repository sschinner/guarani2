drop procedure "dba".u820_ctr_mats_cbc;
create procedure "dba".u820_ctr_mats_cbc (v_unidad_academica	like sga_alumnos.unidad_academica,
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
-- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
	RETURN -1, errorInfo;
END EXCEPTION;

begin
	define v_c_ciclo	varchar(5);
	define v_i_cantidad	integer;

-- ************* Mejorar esto ******************

let v_c_ciclo = 'CBC-2';
let v_i_cantidad = NULL;



-- ************* Calculo de la cantidad de materias aprobadas del ciclo ***************


	select count (*) Into v_i_cantidad
	from vw820_hist_academ
	where resultado = 'A'
		and unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and legajo = v_legajo
		and plan = v_plan
		and materia in (select materia from sga_materias_ciclo where ciclo =     v_c_ciclo);



if (v_i_cantidad)  >= 3 then
                             LET iStatus = 1;
		 LET vcMsg = "OK";
        	                 RETURN iStatus, vcMsg;
	else
                                LET iStatus = -1;
		LET vcUserError = '82002025';
		LET vcMsg = vcUserError;	
		RETURN iStatus, vcMsg;
	end if;
	
end;
end procedure;
                                                                                                                                                                                    
