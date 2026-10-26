CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_sexo_titulo') THEN
		DROP PROCEDURE sp820_sexo_titulo;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.06.2, 2.7.0, 2.9.1
-- Procedure sp820_sexo_titulo

-- Origen del requerimiento: Pedido de Estadistica del reporte de aspirantes por sexo
-- ******************************************************************************

-- execute procedure sp820_sexo_titulo ('35448022-5','35448022','00006')
-- drop procedure "dba".sp820_sexo_titulo;
create procedure "dba".sp820_sexo_titulo( pLegajo  like sga_alumnos.legajo,
				pDocumento  like sga_personas.nro_documento,
				pCarrera like sga_alumnos.carrera)
				
		returning varchar(255);

DEFINE sqlerr		integer;
DEFINE isamerr		integer;
DEFINE errorinfo		varchar(76);

begin


define v_sexo integer;
define v_nombreMasculino varchar(255);
define v_nombreFemenino varchar(255);
define v_fecha date;

let  v_nombreMasculino  = "";
let v_nombreFemenino = "";

SELECT max(fecha_egreso) INTO v_fecha 
FROM sga_titulos_otorg t
WHERE t.legajo=pLegajo
	AND t.carrera=pCarrera
GROUP BY  t.legajo, t.carrera;

SELECT s.nombre,s.nombre_femenino INTO v_nombreMasculino, v_nombreFemenino
	FROM sga_titulos_otorg t, sga_titulos s 
WHERE t.legajo=pLegajo
	AND s.titulo=t.titulo
	AND t.carrera=pCarrera
	AND t.fecha_egreso = v_fecha;
	
select sexo INTO v_sexo from sga_personas
	where nro_documento=pDocumento;


if v_sexo = 2 then
	return v_nombreFemenino;
else
	return v_nombreMasculino;
end if;	

end;
end procedure;
-- **********************************************************************
revoke execute on sp820_sexo_titulo from public;

grant execute on sp820_sexo_titulo to guarani; -- Rol de usuarios de Gestión
grant execute on sp820_sexo_titulo to internet; -- Usuario de internet
