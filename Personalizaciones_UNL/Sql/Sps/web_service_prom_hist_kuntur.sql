CREATE PROCEDURE "dba".verifica_objeto()

BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_promedio_hist_5 ') THEN
		DROP PROCEDURE web_serv_promedio_hist_5 ;
	END IF;		
END

END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Par�metros de WS: anio academico; periodo lectivo; 
-- Objetivo: obtener el promedio hist�rico de las carreras en los ultimos 5 a�os
-- execute procedure "dba".web_serv_promedio_hist_5 ();

CREATE PROCEDURE "dba".web_serv_promedio_hist_5 ()
RETURNING varchar(5), -- 0)carrera
varchar(255), -- nombre carrera
decimal, -- promedio aplazos
decimal-- promedio sin aplazos

DEFINE vi_carrera like sga_carreras.carrera;
DEFINE vc_nombre_car like sga_carreras.nombre;
DEFINE vi_prom_apl decimal(6,2);
DEFINE vi_prom_sin decimal(6,2);

LET vi_carrera = NULL;
LET vc_nombre_car = NULL;
LET vi_prom_apl = 0;
LET vi_prom_sin = 0;

FOREACH

select car.carrera, car.nombre, avg(prom_general) as prom_con_aplazos, avg(prom_sin_aplazos) as prom_sin_aplazos 
INTO vi_carrera, vc_nombre_car, vi_prom_apl, vi_prom_sin 

from sga_titulos_otorg tit

	join sga_carreras car

	on tit.carrera = car.carrera

where year(fecha_egreso) between (YEAR(TODAY)-5) and YEAR(TODAY)

group by 1, 2

RETURN vi_carrera, vc_nombre_car, vi_prom_apl, vi_prom_sin  WITH RESUME;


END FOREACH;

END PROCEDURE;

-- execute procedure "dba".web_serv_promedio_hist_5 ();

-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_promedio_hist_5 
-- *****************************************************************************
revoke execute on "dba".web_serv_promedio_hist_5 from public;
grant execute on "dba".web_serv_promedio_hist_5 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_promedio_hist_5 to internet; -- Rol de usuario de Internet