drop PROCEDURE "dba".ctr_optativas;
CREATE PROCEDURE "dba".ctr_optativas(pUnidadAcademica  LIKE sga_alumnos.unidad_academica,
                                  pCarrera          LIKE sga_alumnos.carrera,
                                  pLegajo           LIKE sga_alumnos.legajo,
                                  pMateria          LIKE sga_materias.materia)

	RETURNING 	smallint,       -- status
			varchar(255);   -- <mensaje, parametros>


  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros
   DEFINE vcUserError	varchar(100);

  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 	integer;
   DEFINE error_info 	varchar(76);



   -- variables locales
   DEFINE viCantAus integer;
   DEFINE vcAnioAcademico LIKE sga_mesas_examen.anio_academico;
   DEFINE vcTurnoExamen LIKE sga_mesas_examen.turno_examen;
   DEFINE vdFecha_fin  LIKE sga_turnos_examen.fecha_fin;
  DEFINE v_plan 	LIKE sga_planes.plan;
  DEFINE v_version	LIKE sga_planes.version_actual;
  DEFINE v_cant_opt Integer;
  DEFINE v_cant_mat Integer;
  DEFINE v_cant_req Integer;
  DEFINE vioptativa Integer;
  DEFINE v_c_orden varchar(5);

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'ctr_optativas' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN
   -- seteo los valores default
   LET iStatus		= 1 ;
   LET vcMsg		= 'OK';
   LET viCantAus  = 0;
   LET vioptativa  = 0;

select a.plan, p.version_actual Into v_plan, v_version
from sga_alumnos a
	join sga_planes p
	  on a.carrera = p.carrera
		and a.plan = p.plan
where a.legajo = pLegajo
	and a.carrera = pCarrera 
	and a.unidad_academica = pUnidadAcademica;
-- RETURN iStatus, 'ALUMNO '||pCarrera||v_plan||v_version;
  
-- SI la materia No es optativa. Lo hago asi para no colocarla como correlativa.
IF pMateria Not In (select materia_optativa
		from sga_atrib_mat_plan a join sga_mat_genericas g
			on a.materia = g.materia_generica
		where  a.unidad_academica = pUnidadAcademica
			and a.carrera = pCarrera
			and a.plan = v_plan
			and a.version = v_version)  or (pMateria IN (1080,1081,1082)) THEN
	
	RETURN iStatus, vcMsg; 
             --RETURN iStatus, 'No es opt '||pMateria||pCarrera||v_plan||v_version; 
END IF;

-- Control que se pueda inscribir a 1 sola optativa. OJO esto esta particularizado para un periodo lectivo. Habria que hacerlo generico.
-- Este control a partir del 2006, separarlo segun se indica al principio del archivo.
-- AGOSTO/2014 Se modifica para permitir inscribirse a 2 optativas

Select count(*) into vioptativa FROM sga_insc_cursadas cur
			 join sga_comisiones com
			 on cur.comision = com.comision
		WHERE  	com.anio_academico = 2016
		and com.periodo_lectivo LIKE '1er. CUATRIMESTRE%'
			and cur.legajo =  pLegajo
			and com.materia In (select materia_optativa
					from sga_atrib_mat_plan a join sga_mat_genericas g
					on a.materia = g.materia_generica
					where  a.unidad_academica = pUnidadAcademica
						and a.carrera = pCarrera
						and a.plan = v_plan
						and a.version = v_version) and  (com.Materia NOT IN (1080,1081,1082)) ;
							
IF vioptativa > 1 THEN
                                LET iStatus = -1;
		LET vcUserError = '82002038'; 
		LET vcMsg = vcUserError;	
		RETURN iStatus, vcMsg;
END IF;

--RETURN iStatus, 'No tiene opt '||pCarrera||v_plan||v_version;

select count (*)  Into v_cant_opt
from vw_hist_academica
where unidad_academica = pUnidadAcademica
	and carrera = pCarrera
	and plan = v_plan
--	and version = v_version
	and legajo = pLegajo
	and resultado = 'A'
	and materia In (select materia_optativa
		from sga_atrib_mat_plan a join sga_mat_genericas g
			on a.materia = g.materia_generica
		where  a.unidad_academica = pUnidadAcademica
			and a.carrera = pCarrera
			and a.plan = v_plan
			and a.version = v_version) and (materia not in (1080,1081,1082));
--- AGOSTO/2014 si es la segunda optativa a la que se inscribe se considera como la cantidad de optativa + 2
LET v_cant_opt = v_cant_opt + 1 + vioptativa;

select count (*)  Into v_cant_mat
from vw_hist_academica
where unidad_academica = pUnidadAcademica
	and carrera = pCarrera
	and plan = v_plan
	and legajo = pLegajo
	and resultado = 'A'
-- modificado 2do cuatrimestre 2015
 and   materia not in (select materia 
		from u820_cursos_ing
		where unidad_academica =  pUnidadAcademica
			and carrera =  pCarrera);

LET iStatus = -1;
LET vcUserError = '82002039'; 
LET vcMsg = vcUserError;	


-- **************************************************************************************************************************************************************************
-- HAY DETERMINADAS OPTATIVAS QUE SOLO SE OFRECEN SEGUN SEA LA 1, 2, 3, ETC. OPTATIVA QUE VAYA A CURSAR EL ALUMNO
-- **************************************************************************************************************************************************************************

--  materias restringidas a 1era. optativa --
--- MODIFICADO 1ER CUATR 2016
If v_cant_opt <> 1 and pmateria in ('0158') then 
                     LET iStatus = -1;
		LET vcUserError = '82002020'; 
		LET vcMsg = vcUserError;	
		RETURN iStatus, vcMsg;
end if;

--  materias restringidas a 2da. optativa ---
--NO HAY EN 2DO CUAT 2016
/*
 If v_cant_opt <> 2 and pmateria in ('0170') then 
                    LET iStatus = -1;	  
                   LET vcUserError = '82002021'; 
	   LET vcMsg = vcUserError;	
	   RETURN iStatus, vcMsg;
 end if;*/

          
LET vcUserError = '82002039'; 

if v_cant_opt = 1 then
    let  v_c_orden = '1er.';
    let v_cant_req = 5;
end if;
if v_cant_opt = 2 then
    let  v_c_orden = '2da.';
    let v_cant_req = 15;
end if;
if v_cant_opt = 3 then
    let  v_c_orden = '3era.';
    let v_cant_req = 21;
end if;
if v_cant_opt = 4 then
    let  v_c_orden = '4ta..';
    let v_cant_req = 27;
end if;

if v_cant_opt > 4 then
    let  v_c_orden = '.';
    let v_cant_req = 27;
end if;
	
LET vcMsg =  vcUserError || ',' || v_cant_mat || ',' || v_cant_req || ',' || v_c_orden;
If v_cant_opt = 1 then
	if v_cant_mat < 5 then
                     LET iStatus = -1;
	RETURN iStatus, vcMsg; 
	end if;
else

	if v_cant_opt = 2  then       
		if v_cant_mat < 15 then
                     LET iStatus = -1;
		RETURN iStatus, vcMsg; 
		end if;
	elif v_cant_opt = 3 then
		if v_cant_mat < 21 then
                     LET iStatus = -1;
		RETURN iStatus, vcMsg; 
		end if;
	elif v_cant_opt >= 4 then
		if v_cant_mat < 27 then
                     LET iStatus = -1;
		RETURN iStatus, vcMsg; 
		end if;
	end if;
end if;


LET iStatus		= 1 ;
LET vcMsg		= 'OK';
RETURN iStatus, vcMsg; 
END;
END PROCEDURE;                                                                                             
