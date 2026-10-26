drop procedure "dba".u820_2_tercios;

create procedure "dba".u820_2_tercios (v_unidad_academica	like sga_alumnos.unidad_academica,
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
	define v_resu	numeric(1);
	define v_c_resu	char(76);
	define v_c_ciclo	varchar(5);
	define v_i_cantidad	integer;
	define v_i_cant_ciclo	integer;
	define v_i_anio_cursada integer;
              define viAnio_ingreso	LIKE sga_periodo_insc.anio_academico;

-- ************* Mejorar esto ******************

let v_c_ciclo = 'CBC-2';
let v_i_anio_cursada = NULL;
let v_i_cantidad = NULL;




-- ************ Calculo del año de cursada de la materia ********************************

select anio_de_cursada INTO v_i_anio_cursada
from sga_atrib_mat_plan
where unidad_academica = v_unidad_academica
	and carrera = v_carrera
	and plan = v_plan
	and version = v_version
	and materia = v_materia;
-- return v_i_anio_cursada,'anio_cursada ';
-- ************* Calculo de la cantidad de materias aprobadas del ciclo ***************

	select count (*) Into v_i_cantidad
	from vw820_hist_academ
	where resultado = 'A'
		and unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and legajo = v_legajo
		and plan = v_plan
		and materia in (select materia from sga_materias_ciclo where ciclo =     v_c_ciclo);


-- return v_i_cantidad,'ua '||v_unidad_academica||' ca '|| v_carrera || 'l ' || v_legajo || 'pl ' || v_plan||'c ' || v_c_ciclo;

-- ************* Calculo de la cantidad de materias del ciclo **********************

	select count (*)  into v_i_cant_ciclo
	from sga_materias_ciclo
	where ciclo = v_c_ciclo;


--  Obtengo el año de ingreso del alumno.Para FCE se toma el ingreso mas viejo sin tener en cuenta la carrera. El legajo es único para todas las carreras

select min(p.anio_academico) into vianio_ingreso
	from sga_alumnos a 
		join sga_carrera_aspira c 
			join sga_periodo_insc p
			on c.periodo_inscripcio = p.periodo_inscripcio
		on c.unidad_academica = a.unidad_academica
			and c.carrera = a.carrera
			and c.nro_inscripcion = a.nro_inscripcion
-- 25/07/2007 se agrega que no considere carreras inválidas
 			and c.situacion_asp not in ('RC','RF','RR')
where a.legajo = v_legajo
	-- and a.carrera = v_carrera
	and a.unidad_academica = v_unidad_academica
	and a.calidad <> 'E';


-- return v_i_cantidad,'cantmats ciclo '||vianio_ingreso||' anioingreso ';


-- EL 2008 INSCRIPCION 1ER. CUATRIMESTE NO SE PEGA PARA 4to Y 5to     

-- EN EL 2008  PARA RENDIR SE PEGA A 4TO.Y 5TO.
-- Todos los alumnos deben tener aprobada  10 materias del ciclo básico CBC-2  para   cursar materias de 4to y 5to.

-- EN EL 2009 PARA RENDIR SE PEGA A 4TO. Y 5TO.
-- Todos los alumnos deben tener aprobada  todas las materias del ciclo básico CBC-2  para   cursar materias de 4to y 5to.
  
IF  (v_i_anio_cursada in (4, 5) and
       not ((v_materia = '4160' and v_carrera = '0203') or (v_materia = '4020' and v_carrera = '0202') or (v_materia = '3080' and v_carrera = '0203')) )
              or
     (v_materia = '3010' and v_carrera = '0202') 
 THEN

	              IF v_i_cantidad  < v_i_cant_ciclo
              	                   THEN
	        		 LET iStatus = -1;
	         		 LET vcUserError = '82002026';
	         		 LET vcMsg = vcUserError;	
	         		 RETURN iStatus, vcMsg;
                   	END IF;

     -- año 2009: Si el año de ingreso esi distinto a 2006 debe tener aprobada  la 1080 para cursar materias de 4to y 5to.
    --  año 2010: se hace el control sin analizar año de ingreso


           --                  IF  viAnio_ingreso <> 2006 and 		
                   	 IF  NOT EXISTS (select materia  from vw820_hist_academ
              			where resultado = 'A'
	              		and unidad_academica = v_unidad_academica 
		              	and carrera = v_carrera	
		              	and legajo = v_legajo 
		              	and plan = v_Plan
		             		and materia in ('1080', '1082'))  THEN
	        		 LET iStatus = -1;
	         		 LET vcUserError = '82002027';
	         		 LET vcMsg = vcUserError;	
	         		 RETURN iStatus, vcMsg;
                               ELSE
                                 LET iStatus = 1;
		 LET vcMsg = "OK";
        	                 RETURN iStatus, vcMsg;              	
                	END IF;

 ELSE
 	if (v_i_cantidad)  >= (Trunc((2*v_i_cant_ciclo)/3) + 1) then
                                  LET iStatus = 1;
		 LET vcMsg = "OK";
        	                 RETURN iStatus, vcMsg;
	else
                                LET iStatus = -1;
		LET vcUserError = '82002009';
		LET vcMsg = vcUserError;	
		RETURN iStatus, vcMsg;
	end if;


END IF;

end;
end procedure;                                                                                                             
                                                                                                                                                                                                                                                              
