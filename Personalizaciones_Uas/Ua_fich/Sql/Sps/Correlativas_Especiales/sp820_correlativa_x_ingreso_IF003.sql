-- ***************  Correlativa especial de la materia Químca de Ing. Inf. Plan 2006 (IF003): ***************************************
-- Se controla que si es año ingreso 2011 y posteriores tenga aprobada la materia Química del curso de ingreso (00426)
-- **************************************************************************************************************************************************
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_quimica_x_ingreso') THEN
		DROP PROCEDURE u820_quimica_x_ingreso;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

create procedure "dba".u820_quimica_x_ingreso(	v_unidad_academica	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_actas_examen.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like  sga_planes.version_actual)
				
		returning smallint, varchar(255);

DEFINE sqlerr		integer;
DEFINE isamerr		integer;
DEFINE errorinfo		varchar(76);
DEFINE vi_anio_ingreso integer;

-- si hay algun error
ON EXCEPTION  SET SQLErr, ISAMErr, errorInfo
	RETURN -1, errorInfo;
END EXCEPTION;

begin

LET vi_anio_ingreso = NULL;

Select per.anio_academico Into vi_anio_ingreso
From sga_alumnos alu
	join sga_carrera_aspira car
		join sga_periodo_insc per
		on car.periodo_inscripcio = per.periodo_inscripcio
	on alu.carrera = car.carrera
	and alu.nro_inscripcion = car.nro_inscripcion
Where alu.unidad_academica = v_unidad_academica
	and alu.carrera = v_carrera
	and alu.legajo = v_legajo
	and alu.plan = v_plan
	and car.situacion_asp IN ('IC','IL');

If vi_anio_ingreso >= 2011 Then

	If Not exists (select '*'
	from vw_hist_academica
	where resultado = 'A'
		and unidad_academica = v_unidad_academica
		and carrera = v_carrera
		and legajo = v_legajo
		and plan = v_plan
		and materia = '00426') then
	
		return -1, '82004002';
	else
		return 1, 'OK';
	end if;

Else

	return 1, 'OK';

End if;

end;
end procedure;
-- ***************** Fin del procedimiento "dba".u820_quimica_x_ingreso **********************

-- execute procedure  "dba".u820_quimica_x_ingreso ("FICH", "03", "40115859-2", "IF003", "2006", "21"); -- ingreso sin 2011
-- execute procedure  "dba".u820_quimica_x_ingreso ("FICH", "03", "", "IF003", "2006", "09"); -- ingreso con 2011
-- execute procedure  "dba".u820_quimica_x_ingreso ("FICH", "03", "36670811-3", "IF003", "2006", "09"); -- Ingreso 2010
	
-- *****************************************************************************
-- Permisos del procedimiento "dba".u820_quimica_x_ingreso 
-- *****************************************************************************
revoke execute on "dba".u820_quimica_x_ingreso from public;
grant execute on "dba".u820_quimica_x_ingreso to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_quimica_x_ingreso to internet; -- Rol de usuario de Internet
