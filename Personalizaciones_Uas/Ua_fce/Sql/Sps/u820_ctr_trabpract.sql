DROP PROCEDURE u820_ctr_trabpract; 
create procedure "dba".u820_ctr_trabpract (	v_unidad_academica	like sga_alumnos.unidad_academica,
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

DEFINE vcMensaje  		varchar(255);
DEFINE vnRetorno, v_ok integer;

  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros
  DEFINE vcUserError	varchar(100);


   select count (*) into 	v_ok
	from sga_cursadas
	where unidad_academica = v_unidad_academica
--		and carrera = v_carrera
		and legajo = v_legajo
		and materia = '1081'
		and resultado = 'A'
		and cond_regularidad = 10;
    
    if v_ok >=1 then	
              LET iStatus = 1;
              LET vcMsg = "OK";
			
    else
         IF EXISTS (select '1' from vw820_hist_academ
		where unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and legajo = v_legajo
    		and materia = '1081'
		and resultado = 'A') THEN    
              LET iStatus = 1;
              LET vcMsg = "OK";
         else
              LET iStatus = -1;
              LET vcUserError = '82002029';
              LET vcMsg = vcUserError;	
         end if;
    end if;

  RETURN iStatus, vcMsg;

end;
end procedure;       

-- EXECUTE  procedure u820_ctr_trabpract ('FCE','0201','33129996-1','1081','0201','05/10');    
-- EXECUTE  procedure u820_ctr_trabpract ('FCE','0201','35652674-9','1081','0201','05/10');    
