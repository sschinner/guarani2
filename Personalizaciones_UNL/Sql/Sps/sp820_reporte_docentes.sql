CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_reporte_docentes') THEN
		DROP PROCEDURE sp820_reporte_docentes;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 2.05.0
-- p_req_vencidos_no varchar(1),  (V vencidos / N no vencidos / T todos
-- p_req_obligatorios ( O obligatorios , L obligatorios para generacion de legajo, N no obligatorios
-- *******************************************************************************

-- execute procedure sp820_reporte_docentes('2015', '2do. Cuatrimestre')
create procedure "dba".sp820_reporte_docentes(pAnioAcademico like sga_comisiones.anio_academico, pPeriodoLectivo like sga_comisiones.periodo_lectivo)
returning
	varchar(5), -- unidad_academica
	varchar(255), -- nombre carrera
	varchar(255), -- nombre materia
	varchar(15), -- nro de documento
	varchar(30), -- apellido
	varchar(30) -- nombres

-- Variables para el manejo de excepciones
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- variables para el return
define vc_ua varchar(5);
define vc_nombre_carrera varchar(255);
define vc_nombre_materia varchar(255);
define vc_nro_documento varchar(15);
define vc_apellido varchar(30);
define vc_nombres varchar(30);


-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
	RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;


begin

foreach select distinct d.unidad_academica, ca.nombre, m.nombre, p.nro_documento, p.apellido, p.nombres
into	vc_ua, vc_nombre_carrera, vc_nombre_materia, vc_nro_documento, vc_apellido, vc_nombres
from	sga_docentes_com dc
join	sga_docentes d on dc.legajo = d.legajo
join	sga_personas p on d.nro_inscripcion = p.nro_inscripcion
join	sga_comisiones c on dc.comision = c.comision
join	sga_materias m on c.materia = m.materia
join	sga_carreras ca on c.carrera = ca.carrera
join	sga_carreras_grupo cg on c.carrera = cg.carrera
where	cg.grupo_carrera = '00001'
and	c.anio_academico = pAnioAcademico
and	c.periodo_lectivo = pPeriodoLectivo
order by 1,2,5,6

return vc_ua, vc_nombre_carrera, vc_nombre_materia, vc_nro_documento, vc_apellido, vc_nombres with resume;
end foreach

end;

end procedure;
-- *****************************************************************************
-- *****************************************************************************

-- Permisos del procedimiento "dba".sp820_reporte_docentes

-- *****************************************************************************

revoke execute on "dba".sp820_reporte_docentes from public;
grant execute on "dba".sp820_reporte_docentes to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_reporte_docentes to internet; -- Rol de usuario de Internet