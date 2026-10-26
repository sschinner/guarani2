-- INSERT INTO  mme_mensajes (tipo, mensaje, mascara_original, mascara, clasificacion, boton) VALUES (3, 82012002, "No tenés los créditos necesarios para cursar esta materia.",  "No tenés los créditos necesarios para cursar esta materia.", 2, 1);

-- execute procedure "dba".u820_creditos('FADU','1','93278207-7', 'A0316', '2001', '32');

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_creditos') THEN
		DROP PROCEDURE u820_creditos;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_creditos(	v_unidad_acad	like sga_alumnos.unidad_academica,
					v_carrera		like sga_alumnos.carrera,
					v_legajo		like sga_alumnos.legajo,
					v_materia		like sga_actas_examen.materia,
					v_plan		like sga_alumnos.plan,
					v_version		like sga_actas_examen.version)
				
		returning smallint, varchar(255);

begin

	define sqlerr		integer;
	define isamerr		integer;
	define errorinfo		varchar(76);
	define v_resu		smallint;
	define v_c_resu		varchar(255);
	define v_version_vigente	char(3);
	define v_creditos		numeric(5);
	define vi_creditos		numeric(5);
	define aux_creditos		numeric(5);
	define vc_materia		varchar(10);	
	define vc_resultado 	char(1);

	-- si hay algun error
	ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
		RETURN -1, '800321' || ',' || 'u820_creditos' || ',' || sqlerr || ' - '  || errorinfo ;
	END EXCEPTION;
	
	let v_resu = 1;
	let v_c_resu = "OK";
	let v_creditos = 0;

	select version_actual  into v_version_vigente
	from sga_planes
	where carrera =  v_carrera
		and plan = v_plan;


select vw.materia
from vw_hist_academica vw join sga_atrib_mat_plan a
		  on vw.carrera = a.carrera
			and vw.plan = a.plan
			and vw.materia = a.materia
where vw.legajo = v_legajo
	and vw.carrera = v_carrera
	and vw.plan = v_plan
	and vw.resultado = 'A'
	and a.anio_de_cursada in (1, 2)

UNION

select h.materia 
from sga_cursadas h join sga_atrib_mat_plan a
		  on h.carrera = a.carrera
			and h.plan = a.plan
			and h.materia = a.materia
			-- and a.version = v_version_vigente -- No deberia importarme pues se filtra en el UNION
where h.legajo = v_legajo
	and h.carrera = v_carrera
	and h.plan = v_plan			
	and h.cond_regularidad = 7
	and h.resultado = 'A'
	and h.fin_vigencia_regul >= TODAY
	and a.anio_de_cursada in (1, 2)

Into Temp aux_materias;

select sum(a.credito) into v_creditos
from aux_materias h
	join sga_atrib_mat_plan a
	  on h.materia = a.materia
		and a.carrera = v_carrera
		and a.plan = v_plan
		and a.version = v_version_vigente
		and a.obligatoria = 'S';

if v_creditos is null then
	let v_creditos = 0;
end if;
	
if v_carrera = "1" and v_plan = "2001" then
	if v_creditos < 72 then
		let v_resu = -1;
		let v_c_resu = "82012002";
	end if;

elif v_carrera = "3" and v_plan = "2001" then
		if v_creditos < 69 then
			let v_resu = -1;
			let v_c_resu = "82012002";
		end if;
elif v_carrera = "6" and v_plan = "2012" then
		if v_creditos < 70 then
			let v_resu = -1;
			let v_c_resu = "82012002";
		end if;
end if;

drop table aux_materias;
return v_resu, v_c_resu;

end;

end procedure;
-- *************** Fin del procedimiento "dba".u820_creditos ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_creditos
-- *****************************************************************************
revoke execute on "dba".u820_creditos from public;
grant execute on "dba".u820_creditos to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_creditos to internet; -- Rol de usuario de Internet