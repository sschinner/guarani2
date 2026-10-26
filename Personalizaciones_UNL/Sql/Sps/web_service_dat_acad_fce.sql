CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_dat_acad_fce') THEN
		DROP PROCEDURE web_serv_dat_acad_fce;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parámetros de WS: tipo y nro. documento;
-- El alumno puede tener titulo intermedio, en cuyo caso sigue siendo alumno.


CREATE PROCEDURE "dba".web_serv_dat_acad_fce(ptipoDocumento integer, pNroDocumento varchar(20))
RETURNING integer, -- 0) codigo retorno
varchar(5), -- unidad academica
varchar(5), -- Carrera
integer, -- Cantidad materias aprobadas
integer, -- Cantidad materias reprobadas
decimal(6,2), -- Promedio con aplazo
decimal(6,2), -- Promedio sin aplazo
varchar(5); --CALIDAD


DEFINE vi_codigo_ret integer;
DEFINE vc_unidad_academica varchar(5);
DEFINE vc_carrera_nombre varchar(255);
DEFINE vc_carrera varchar(5);
DEFINE vc_carrera_nombre1 varchar(255);
DEFINE vc_carrera1 varchar(5);
DEFINE vc_estado char(1); 
DEFINE vd_ingreso date;
DEFINE vd_fin date;
DEFINE vi_cant_aprob integer;
DEFINE vi_cant_plan integer;
DEFINE vi_cant_reprob integer;
DEFINE vi_cant_plan1 integer;
DEFINE vi_prom_aplazo decimal(6,2); 
DEFINE vi_prom_sin_aplazo decimal(6,2); 
DEFINE vc_resol char(1);
DEFINE vi_tipo_doc integer;
DEFINE vc_nro_documento like sga_personas.nro_documento;
DEFINE vi_tipo_doc1 integer;
DEFINE vc_nro_documento1 like sga_personas.nro_documento;
DEFINE vc_nro_inscripcion like sga_personas.nro_inscripcion;
DEFINE vc_legajo like sga_alumnos.legajo;
DEFINE vc_unl_ua like u820_codigos_univ.unl_ua;
DEFINE vc_unl_carrera like u820_codigos_univ.unl_carrera;
DEFINE vc_unl_carrera1 like u820_codigos_univ.unl_carrera;
DEFINE vc_calidad char(5);


LET vi_codigo_ret = 0;
LET vc_unidad_academica = NULL;
LET vc_carrera = NULL;
LET vc_carrera_nombre = NULL;
LET vc_carrera1 = NULL;
LET vc_carrera_nombre1 = NULL;
LET vc_estado = NULL;
LET vd_ingreso = NULL;
LET vd_fin = NULL;
LET vi_cant_aprob = NULL;
LET vi_cant_plan = NULL;
LET vi_cant_reprob = NULL;
LET vi_cant_plan1 = NULL;
LET vi_prom_aplazo = NULL;
LET vi_prom_sin_aplazo = NULL;
LET vc_legajo = NULL;
LET vc_unl_ua  = NULL;
LET vc_unl_carrera  = NULL;
LET vc_unl_carrera1  = NULL;
LET vc_calidad  = NULL;

FOREACH 
SELECT  car.unidad_academica, alu.carrera, alu.legajo, alu.nro_inscripcion, alu.calidad, alu.fecha_ingreso, egre.fecha_egreso, cod.unl_ua, cod.unl_carrera

 INTO  vc_unidad_academica, vc_carrera, vc_legajo, vc_nro_inscripcion, vc_estado, vd_ingreso, vd_fin, vc_unl_ua, vc_unl_carrera  
FROM sga_personas per
	join sga_alumnos alu
		on per.nro_inscripcion = alu.nro_inscripcion
	join sga_carreras car
		on alu.carrera = car.carrera
	join u820_codigos_univ cod
		on car.carrera = cod.carrera
	left join sga_titulos_otorg egre
		on alu.carrera = egre.carrera
		and alu.nro_inscripcion = egre.nro_inscripcion

WHERE  per.nro_documento= pNroDocumento
AND per.tipo_documento = pTipoDocumento
	LET vi_codigo_ret = 1;

	-- Calculo de datos academicos: cant. mat. aprob.; cant. mat. plan; prom. c/aplazos; prom. s/aplazos

	execute  PROCEDURE "dba".sp820_prom_alu_res(vc_unidad_academica, vc_carrera, vc_legajo, 'S') Into vi_prom_aplazo, vc_resol;
	execute  PROCEDURE "dba".sp820_prom_alu_res(vc_unidad_academica, vc_carrera, vc_legajo, 'N') Into vi_prom_sin_aplazo, vc_resol;
	-- el problema es el numero de parametros devueltos
	execute PROCEDURE "dba".sp820_can_apro_sci_ws_fce (vc_nro_inscripcion, vc_carrera) Into vi_tipo_doc, vc_nro_documento, vc_unl_carrera, vc_carrera_nombre, vi_cant_plan, vi_cant_aprob, vc_calidad;
	execute PROCEDURE "dba".sp820_can_repro_SCI (vc_nro_inscripcion, vc_carrera) Into vi_tipo_doc1, vc_nro_documento1, vc_unl_carrera1, vc_carrera_nombre1, vi_cant_plan1, vi_cant_reprob;

	RETURN vi_codigo_ret, vc_unl_ua, vc_unl_carrera, vi_cant_aprob, vi_cant_reprob, vi_prom_aplazo, vi_prom_sin_aplazo, vc_calidad WITH RESUME;

	
END FOREACH;

IF vd_ingreso is null THEN 
	LET vi_codigo_ret = 0;
	RETURN vi_codigo_ret, vc_unl_ua, vc_unl_carrera, vi_cant_aprob, vi_cant_reprob, vi_prom_aplazo, vi_prom_sin_aplazo,vc_calidad;
		
END IF;


END PROCEDURE;

-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_dat_acad_fce 
-- *****************************************************************************
revoke execute on "dba".web_serv_dat_acad_fce from public;
grant execute on "dba".web_serv_dat_acad_fce to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_dat_acad_fce to internet; -- Rol de usuario de Internet


-- Casos de prueba
{
select * from aca_usuarios_ag tipo_usuario = 'DOC';
select first 1000 * from sga_carrera_aspira where situacion_asp = 'IL';
select * from sga_personas where nro_inscripcion = 'FCE-2839';

Casos:
-- Usuario Autenticado
EXECUTE PROCEDURE "dba".web_serv_dat_acad_fce(0, '32951378'); --1

-- Usuario No autenticado por identificacion
EXECUTE PROCEDURE "dba".web_serv_dat_acad_fce(0, "30339250"); --0
}