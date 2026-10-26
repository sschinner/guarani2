CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_reinsc_per_a') THEN
		DROP PROCEDURE u820_reinsc_per_a;
	END IF;

	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_reinsc_per_a') THEN
		DROP PROCEDURE sp820_reinsc_per_a;
	END IF;
		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 
-- Procedure sp820_reinsc_per_a
-- *******************************************************************************
CREATE PROCEDURE "dba".sp820_reinsc_per_a (p_unidad_academica like sga_datos_censales.unidad_academica,
					p_nro_inscripcion like sga_datos_censales.nro_inscripcion,
					p_periodo like sga_periodo_insc.periodo_inscripcio)
RETURNING  VARCHAR(100);


DEFINE v_nro_transaccion like sga_reinscripcion.nro_transaccion;
DEFINE v_cad_transaccion varchar(100);

let v_cad_transaccion = "";


foreach select r.nro_transaccion
	  into v_nro_transaccion
	  from sga_reinscripcion r
		join sga_periodo_insc p
		  on r.anio_academico = p.anio_academico
		join sga_alumnos a
		  on r.legajo = a.legajo
			and r.carrera = a.carrera
	 where r.unidad_academica = p_unidad_academica
		and a.nro_inscripcion = p_nro_inscripcion
		and p.periodo_inscripcio = p_periodo

	let v_cad_transaccion = v_cad_transaccion || trim(both " " from v_nro_transaccion) || ", ";
end foreach;

let v_cad_transaccion = substr(v_cad_transaccion, 0, length(v_cad_transaccion) - 1) || ".";

return v_cad_transaccion;

End procedure;

-- ******************** FIN DEL PROCEDURE sp820_reinsc_per_a ******************** 

 --execute PROCEDURE sp820_reinsc_per_a('FICH','03','23552487-9','3','2014','','254');

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_reinsc_per_a 
-- *****************************************************************************
revoke execute on "dba".sp820_reinsc_per_a from public;
grant execute on "dba".sp820_reinsc_per_a to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_reinsc_per_a to internet; -- Rol de usuario de Internet


 




