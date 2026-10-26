
DROP PROCEDURE sp820_fce_aspirantes_x_sexo;
CREATE PROCEDURE "dba".sp820_fce_aspirantes_x_sexo(
	pUa		LIKE sga_unidades_acad.unidad_academica,
	pCarrera LIKE sga_carreras.carrera,
	pAnioAcademico	LIKE sga_periodo_insc.anio_academico)

RETURNING	varchar(5), 		-- unidad_academica. 1
		integer,		-- anio ingreso. 2
		varchar(60),		-- nombre_carrera. 3
		integer,		-- femeninos. 4
		integer;			-- masculinos. 5

DEFINE	vc_unidad_academica		varchar(5);
DEFINE 	vi_anio_ingreso			integer;
DEFINE	vc_nombre_carrera			varchar(60);
DEFINE  vi_mujer integer;
DEFINE  vi_varon integer;
--******************************************************************************
-- variables para el manejo de excepciones
DEFINE		SQLErr, ISAMError		integer;
DEFINE		errorInfo 			varchar(76);

-- Variables para la devolución de datos
-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
DEFINE 	v_anio				integer;
DEFINE 	v_anio_ingreso			varchar(20);
DEFINE	v_unidad_academica		varchar(5);
DEFINE	v_carrera				varchar(5);
DEFINE	v_nombre_carrera			varchar(60);
DEFINE	v_legajo				varchar(15);
DEFINE	v_apellido			varchar(30);
DEFINE	v_nombres			varchar(30);
DEFINE	v_fecha_nacimiento		date;
DEFINE	v_sexo				char(1);
DEFINE	v_tipo_documento			varchar(50);
DEFINE	v_nro_documento			decimal(15,0);
DEFINE	v_estado_civil			varchar(50);
DEFINE	v_calle_proc			varchar(100);
DEFINE	v_numero_proc			varchar(5);
DEFINE	v_piso_proc			varchar(3);
DEFINE	v_dpto_proc			varchar(5);
DEFINE	v_unidad_proc			varchar(3);
DEFINE	v_localidad_proc			varchar(255);
DEFINE	v_patido_proc			varchar(255);
DEFINE	v_provincia_proc			varchar(255);
DEFINE	v_cp_proc			varchar(6);
DEFINE	v_te_proc			varchar(18);
DEFINE	v_calle_per_lect			varchar(100);
DEFINE	v_numero_per_lect			varchar(5);
DEFINE	v_piso_per_lect			varchar(3);
DEFINE	v_dpto_per_lect			varchar(5);
DEFINE	v_unidad_per_lect			varchar(3);
DEFINE	v_loc_per_lect			varchar(255);
DEFINE	v_patido_per_lect			varchar(255);
DEFINE	v_prov_per_lect			varchar(255);
DEFINE	v_cp_per_lect			varchar(6);
DEFINE	v_te_per_lect			varchar(18);
DEFINE	v_rendidos			integer;
DEFINE	v_aprobadas			integer;
DEFINE	v_aprobadas_ant			integer;
DEFINE	v_sit_lab_alu			varchar(255);
DEFINE	v_horas_trabaja			varchar(255);
DEFINE	v_sector_econom_alum		varchar(255);
DEFINE	v_tareas_act_alum			varchar(255);
DEFINE	v_jerarquia_act_alum		varchar(255);
-- ***************************************************************************************************************
-- ***************************************************************************************************************
DEFINE	v_anio_academico			integer;
DEFINE	vcInicio				LIKE sga_anio_academico.fecha_inicio;
DEFINE	vcFin				LIKE sga_anio_academico.fecha_fin;
DEFINE 	v_plan				varchar(5);
DEFINE 	v_tipo				varchar(2);
DEFINE	v2_carrera			varchar(5);
DEFINE	v2_anio_academico		integer;
DEFINE 	v_nro_inscripcion			varchar(10);
DEFINE 	pFecha				date;
DEFINE 	pFechaegreso			date;
DEFINE 	ptipo_dato			CHAR(1);
		
-- si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
	RAISE EXCEPTION  SQLErr, SQLErr, errorInfo ;
END EXCEPTION;

BEGIN

 LET ptipo_dato = "I";

-- *******************************************************************************************************************************************
-- Calcular el Año Academico, correspondiente al Año anterior al Año Academico Seleccionado (pAnioacademico).
-- *******************************************************************************************************************************************
LET vcInicio = MDY ('04', '01', pAnioAcademico - 1);
LET vcFin = MDY ('03', '31', pAnioAcademico);
LET pCarrera = trim(pCarrera);
-- *******************************************************************************************************************************************
-- convierto fechas
---  LET pFecha = stringToDate(psFecha, '%d-%m-%Y');
     LET pFecha = TODAY;
 --  LET pFechaegreso = stringToDate(psFechaegreso, '%d-%m-%Y');
     LET pFechaegreso =  TODAY;
--LET pFecha = MDY ('09', '01', pAnioAcademico);
--LET pFecha = MDY ('01', '01', pAnioAcademico);
-- *******************************************************************************************************************************************


-- *******************************************************************************************************************************************
-- Obtengo los datos censales
-- *******************************************************************************************************************************************
SELECT nro_inscripcion, MAX(fecha_actualiz) AS fecha_actualiz
FROM sga_datos_censales
GROUP BY nro_inscripcion
INTO TEMP aux_max_censales WITH NO LOG;


-- *******************************************************************************************************************************************
-- Obtengo alumnos reinscriptos e inscriptos
-- *******************************************************************************************************************************************
select a.carrera, a.plan, a.legajo, a.nro_inscripcion, p.anio_academico, a.calidad,'I' as tipo                       
                  from sga_alumnos a , sga_carrera_aspira c,sga_periodo_insc p
		where  c.periodo_inscripcio = p.periodo_inscripcio
		and c.unidad_academica = a.unidad_academica
		and c.carrera = a.carrera
		and c.nro_inscripcion = a.nro_inscripcion
                                and a.unidad_academica = pUA
                                and a.carrera = pCarrera
                                and p.anio_academico = pAnioAcademico 
                                and c.situacion_asp not in ('RR','RC','RF')
                                and fecha_ingreso <= pFecha
into temp t_candidatos_I WITH NO LOG;
---REINSCRIPTOS
select a.carrera, a.plan, a.legajo, a.nro_inscripcion, p.anio_academico, a.calidad, 'R' as tipo                       
                  from sga_alumnos a , sga_reinscripcion p, sga_carrera_aspira c
		where
                               p.unidad_academica = pUA
                                and p.carrera = pCarrera
                                and p.anio_academico = pAnioAcademico 
                                 and a.unidad_academica = p.unidad_academica 
                                and a.carrera = p.carrera
                                and a.legajo = p.legajo
                                and c.unidad_academica = a.unidad_academica
		and c.carrera = a.carrera
		and c.nro_inscripcion = a.nro_inscripcion
                                 and c.situacion_asp not in ('RR','RC','RF')
                               and MDY( month(p.fecha_reinscrip),day(p.fecha_reinscrip),year(p.fecha_reinscrip)) <= pFecha
into temp t_candidatos_R WITH NO LOG;

--- Elimina de reinscriptos, los ingresaron y se reinscribieron en el mismo año
select * from t_candidatos_I
UNION
select * from t_candidatos_R  R where not exists (select I.legajo from  t_candidatos_I I where I.legajo = R.legajo)

into temp t_candidatos WITH NO LOG;

---- marco los egresados
  update  t_candidatos set tipo = 'E' where calidad = 'E' and legajo in ( select t.legajo
 from t_candidatos t,sga_titulos_otorg o, 
-----sga_anio_academico d, 
   sga_titulos l
  where t.calidad = 'E' and t.carrera = o.carrera and t.legajo = o.legajo and 
  ----- d.anio_academico = pAnioAcademico and
  o.titulo = l.titulo and l.tipo_de_titulo = 'G' 
-- and
---o.fecha_egreso <= d.fecha_fin 
 and MDY( month(o.fecha_egreso ),day(o.fecha_egreso ),year(o.fecha_egreso )) <= pFechaegreso
----and o.fecha_egreso <= d.fecha_fin 
------and  o.fecha_egreso >= d.fecha_inicio 
  and t.carrera = o.carrera and t.legajo = o.legajo);

--- Las carreras 0200 alumnos externos y 0204 bachiller a distancia (actualmente no existe) no se consideran

--- Si la carrera es distinta a la 0205, los alumnos inscriptos para empezar la carrera pueden ser reinscriptos en el caso que hayan realizado anteriormente la carrera 0205 (siempre
--- que no hayan realizado entre medio otra carrera de grado)
--- si realizaron el mismo año la carrera 0205, son ingresantes si en la 0205 son ingresantes, sino son reinscriptos
if pCarrera <> '0205' then
FOREACH  select carrera, plan, legajo, nro_inscripcion, anio_academico
                          INTO
		v_carrera,
                                v_plan,
		v_legajo,
          		v_nro_inscripcion,
                                v_anio_ingreso                                 
 from t_candidatos
                  where tipo = 'I' 
                   LET v2_carrera = NULL;
                   LET v2_anio_academico = NULL;
                   select max(p.anio_academico) into v2_anio_academico
                               from sga_alumnos a,sga_periodo_insc p,sga_carrera_aspira c
		where  a.carrera = '0205'
                                       and a.legajo = v_legajo
                                       and c.periodo_inscripcio = p.periodo_inscripcio
		       and p.anio_academico <= v_anio_ingreso
                                and c.unidad_academica = a.unidad_academica
		and c.carrera = a.carrera
		and c.nro_inscripcion = a.nro_inscripcion;
                      if  v2_anio_academico is not null then
                      -----  hicieron antes 0205 entonces pueden ser reinscriptos
                         if v2_anio_academico <> v_anio_ingreso then
                         ---- hicieron 0205 en un año anterior, debe determinarse si hicieron otra carrera de grado en el medio
                               if not exists(select p.anio_academico
                                             from sga_alumnos a,sga_periodo_insc p,sga_carrera_aspira c
			where  a.carrera not in ( '0205',v_carrera,'0204','0200')
                                       and a.legajo = v_legajo
                                       and c.periodo_inscripcio = p.periodo_inscripcio
		       and p.anio_academico < v_anio_ingreso
                                       and p.anio_academico >= v2_anio_academico
                                and c.unidad_academica = a.unidad_academica
		and c.carrera = a.carrera
		and c.nro_inscripcion = a.nro_inscripcion ) THEN
                                               update  t_candidatos set tipo = 'RI' where legajo = v_legajo;
                                end if;
                          ---- ingresaron en  0205 en el mismo año entonces  son ingresantes                                   
                          end if;
                       end if;
end foreach;
end if;                            

--- Si la carrera es 0205 los alumnos que se reinscribieron son reingresantes y los que se inscribieron para empezar la carrera son ingresantes, excepto que se hayan inscripto o reinscripto a su vez en una carrera de 
--- grado en el mismo año , en este caso se consideran sólo ingresantes en esta última carrera
--- caso 10 y 11 si en un año anterior se inscribieron en 0205, y luego en el mismo año o siguiente se inscribieron o reinscribieron en en una carrera de grado, no se consideran reinscriptos en este año por más que se hayan reinscripto a la 0205
if pCarrera = '0205' then
FOREACH  select carrera, plan, legajo, nro_inscripcion, anio_academico, tipo
                          INTO
		v_carrera,
                                v_plan,
		v_legajo,
          		v_nro_inscripcion,
                                v_anio_ingreso, v_tipo
 from t_candidatos                
                   if exists( select a.carrera
                               from sga_alumnos a,sga_periodo_insc p,sga_carrera_aspira c
		where  a.carrera not in('0205','0200','0204')
                                ----   where  a.carrera not in('0205','0200')
                                       and a.legajo = v_legajo
                                       and c.periodo_inscripcio = p.periodo_inscripcio
		       and p.anio_academico = v_anio_ingreso
                                and c.unidad_academica = a.unidad_academica
		and c.carrera = a.carrera
		and c.nro_inscripcion = a.nro_inscripcion
----------------------------se agrega control por fecha
                                and MDY( month(fecha_ingreso),day(fecha_ingreso),year(fecha_ingreso)) <= pFecha
----------------------------------------------------------------------
                              ) then                    
                                               update  t_candidatos set tipo = 'X' where legajo = v_legajo;
                     else
                       if exists( select a.carrera
                               from sga_alumnos a,sga_reinscripcion c
		where  a.carrera not in('0205','0200','0204')
                            -----     where  a.carrera not in('0205','0200')
                                       and a.legajo = v_legajo
                                       and c.anio_academico = pAnioAcademico
                                and c.unidad_academica = a.unidad_academica
		and c.carrera = a.carrera
		and c.legajo = a.legajo) then                    
                                               update  t_candidatos set tipo = 'X' where legajo = v_legajo;
                      end if;
                     end if;
                     if v_tipo = 'R' 	then
--------------- caso 10 y 11 - se inscribieron antes a la 0205 y luego entraron en ese año u otra a una carrera de grado
  		LET v2_anio_academico = NULL;                           
		select min (p.anio_academico) into 
                               v2_anio_academico
                               from sga_alumnos a,sga_periodo_insc p,sga_carrera_aspira c
		where  a.carrera = '0205'
                                       and a.legajo = v_legajo
                                       and c.periodo_inscripcio = p.periodo_inscripcio
		       and p.anio_academico < v_anio_ingreso
                                and c.unidad_academica = a.unidad_academica
		and c.carrera = a.carrera
		and c.nro_inscripcion = a.nro_inscripcion;
                                if  v2_anio_academico is not null then 
                                    if exists (select a.carrera
                                      from sga_alumnos a,sga_periodo_insc p,sga_carrera_aspira c
		      where  a.carrera not in ('0205','0200','0204')
                                  -----    where  a.carrera not in ('0205','0200')
                                       and a.legajo = v_legajo
                                       and c.periodo_inscripcio = p.periodo_inscripcio
		       and p.anio_academico >= v2_anio_academico
                                        and p.anio_academico < pAnioAcademico
                                    and c.unidad_academica = a.unidad_academica
		    and c.carrera = a.carrera
		    and c.nro_inscripcion = a.nro_inscripcion
----------------------------se agrega control por fecha
                                and MDY( month(fecha_ingreso),day(fecha_ingreso),year(fecha_ingreso)) <= pFecha
----------------------------------------------------------------------
                                                    ) then                                                               
                                               update  t_candidatos set tipo = 'X' where legajo = v_legajo;
                                     end if;
                                  end if;
                     end if;
    end foreach;
end if;                            

-- *******************************************************************************************************************************************
-- Armo tabla con datos agregados
-- *******************************************************************************************************************************************

SELECT  distinct a.nro_inscripcion,
	a.anio_academico,
	a.carrera,
	a.plan,
	p.unidad_academica,
	c.nombre AS nombre_carrera,
	a.legajo, 
	p.apellido, 
	p.nombres,
	p.fecha_nacimiento,
	case ""||p.sexo	when "1" then "M"
			when "2" then "F"
		end as sexo,
	case ""||p.tipo_documento	when "0" then "DNI"
				when "2" then "CI"
				when "18" then "LE"
				when "19" then "LC"
				when "90" then "Pas"
		end as tipo_documento,
 	p.nro_documento, 
	case ""||dat.estado_civil	when "1" then "Soltero"
				when "2" then "Casado"
				when "3" then "Separado"
				when "4" then "Divorciado"
				when "5" then "Unión concensual"
				when "6" then "Viudo"
		end as estado_civil,
	dat.calle_proc, 
	dat.numero_proc,
	dat.piso_proc,
	dat.dpto_proc,  
	dat.unidad_proc, 
	dat.loc_proc, 
	"                                                                                                                             " AS localidad_proc,  --l.nombre 
	"                                                                                                                             " AS partido_proc, --dpto.nombre 
	"                                                                                                                             " AS provincia_proc,  --pro.nombre 
	dat.cp_proc, 
	dat.te_proc,
	dat.calle_per_lect,
	dat.numero_per_lect,
	dat.piso_per_lect,
	dat.dpto_per_lect,  
	dat.unidad_per_lect, 
	dat.loc_per_lect,
	"                                                                                                                             " AS localidad_per_lect,  --l1.nombre 
	"                                                                                                                             " AS partido_per_lect, --dpto1.nombre 
	"                                                                                                                             " AS provincia_per_lect,  --pro1.nombre 
	dat.cp_per_lect, 
	dat.te_per_lect,
	0 as rendidos,
	0 as aprobadas,
	0 as aprobadas_ant,

	case when dat.fecha_actualiz > (select fecha_generacion from app_versiones where version = "CNV2.03.0-01")
		and exists (select fecha_generacion from app_versiones where version = "CNV2.03.0-01") then
			case ""||dat.sit_laboral_alu	when "1" then "Desocupado"
						when "2" then "Ocupado Temporal"
						when "3" then "Ocupado Permanente"
						when "4" then "Subocupado"
						when "5" then "Atención del Hogar y la Familia"
						when "6" then "Jubilado o Pencionado"
						when "7" then "Otros"
			end
		else
			case ""||dat.sit_laboral_alu	when "1" then "Ocupado Permanente"
						when "2" then "Subocupado"
						when "3" then "Desocupado"
						when "4" then "Jubilado o Pencionado"
			end
		end as sit_laboral_alu,

	horas.descripcion as hora_trabaja,
	act_econ.descripcion as sector_econom_alum,
	u820_rama.nombre as tareas_act_alum,
	categ.descripcion as jerarquia_act_alum

from  t_candidatos a, sga_personas p, sga_datos_censales dat, aux_max_censales aux_dc, outer sga_carreras c, outer sga_categ_ocup categ, outer u820_rama_actividad u820_rama,
          outer sga_act_economica act_econ, outer sga_horas_sem_trab horas
           where      (  (ptipo_dato = 'R' and (a.tipo = 'R' or a.tipo = 'RI')) OR
                               (ptipo_dato = 'I' and a.tipo = 'I') )
                            and  a.carrera = c.carrera
                            and  dat.categ_ocup_alum = categ.categ_ocup
                            and dat.det_rama_act_alum = u820_rama.rama
                            and  dat.act_econom_alum = act_econ.act_economica
                           and  dat.hora_sem_trab_alum = horas.hora_sem_trab
                           and  dat.nro_inscripcion = aux_dc.nro_inscripcion
	              and ( (dat.fecha_actualiz is null ) or dat.fecha_actualiz = aux_dc.fecha_actualiz)
	              and p.nro_inscripcion = dat.nro_inscripcion
	              and a.nro_inscripcion = p.nro_inscripcion 

ORDER BY a.carrera
INTO TEMP aux_alumno WITH NO LOG;


FOREACH  
	select unidad_academica,
	anio_academico,
	nombre_carrera,
	sum(case sexo when 'M' then 1 else 0 end) as mujeres,
	sum(case sexo when 'F' then 1 else 0 end) as varones
into vc_unidad_academica, vi_anio_ingreso, vc_nombre_carrera, vi_mujer, vi_varon

from aux_alumno

---where insc.anio_academico = pAnioAcademico
-- AND asp.situacion_asp in ('AC', 'IL', 'IC') -- No se tiene en cuenta el estado. Solo interesa que si fue aspirante
---AND (asp.carrera = pCarrera or pCarrera = '')
----AND gc.grupo_carrera in ('00001', '00002')
group by 1, 2, 3
order by 1, 3
-- ***************************************************************************************************************
-- Listado de variables a devolver
-- ***************************************************************************************************************
		RETURN vc_unidad_academica, vi_anio_ingreso, vc_nombre_carrera, vi_mujer, vi_varon WITH RESUME;
-- ***************************************************************************************************************
-- ***************************************************************************************************************
END FOREACH;
END;
	
BEGIN

on exception in (-206)
       -- Tabla no existe continuo el proceso	
end exception with resume;
                DROP TABLE t_candidatos_R;
                DROP TABLE t_candidatos_I;
                DROP TABLE t_candidatos;
	DROP TABLE aux_alumno;
                DROP TABLE aux_max_censales;
END;
END PROCEDURE;                                                                                                                            

-- EXECUTE PROCEDURE sp820_fce_aspirantes_x_sexo('FCE', '0203', '2014');
-- EXECUTE PROCEDURE sp820_fce_aspirantes_x_sexo('FCE', '0202', '2014');

