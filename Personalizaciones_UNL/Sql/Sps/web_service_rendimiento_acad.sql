--*******  PROCEDIMIENTO PARA TODAS LAS UAS MENOS FCE, PARA FCE BUSCAR EN LAS PERSONALIZACIONES DE FCE  *********

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_service_rendimiento_acad') THEN
		DROP PROCEDURE "dba".web_service_rendimiento_acad;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Par?metros de WS: tipo y nro. documento;
-- El alumno puede tener titulo intermedio, en cuyo caso sigue siendo alumno.

-- execute PROCEDURE  "dba".web_service_rendimiento_acad(0,'29349542',54)
CREATE PROCEDURE "dba".web_service_rendimiento_acad(ptipoDocumento integer, pNroDocumento varchar(20), pPais integer)
RETURNING integer, -- 0) codigo retorno
varchar(5), -- unidad academica
varchar(5), -- Carrera
varchar(10), -- estado: alumno, graduado
date, -- Fecha de ingreso a la carrera
date , -- Fecha de finalizaci?n (en caso de ser egresado)
integer, -- Cantidad materias aprobadas
integer, -- Cantidad materias del plan
decimal(6,2), -- Promedio con aplazo
decimal(6,2), -- Promedio sin aplazo
integer, -- Cantidad materias reprobadas
varchar(80), --nombre de carrera
varchar(150), -- Mensaje situacion asp
varchar(1), --Regular
varchar(100), -- nombre titulo
integer, -- Egresado 
varchar(150); --Mensaje retorno


DEFINE vi_codigo_ret integer;
DEFINE vc_mje_ret varchar(150);
DEFINE vc_regular varchar(1);
DEFINE vc_mje_sit_asp varchar(150);
DEFINE vc_unidad_academica varchar(5);
DEFINE vc_carrera_nombre varchar(255);
DEFINE vc_carrera varchar(5);
DEFINE vc_estado varchar(10);
DEFINE vd_ingreso date;
DEFINE vd_fin date;
DEFINE vi_cant_aprob integer;
DEFINE vi_cant_plan integer;
DEFINE vi_prom_aplazo decimal(6,2); 
DEFINE vi_prom_sin_aplazo decimal(6,2); 
DEFINE istatus integer;
DEFINE vcMsg varchar(255);

DEFINE vi_tipo_doc integer;
DEFINE vc_nro_documento like sga_personas.nro_documento;
DEFINE vc_nro_inscripcion like sga_personas.nro_inscripcion;
DEFINE vc_legajo like sga_alumnos.legajo;
DEFINE vc_unl_ua like u820_codigos_univ.unl_ua;
DEFINE vc_unl_carrera like u820_codigos_univ.unl_carrera;
DEFINE vc_unl_carrera1 like u820_codigos_univ.unl_carrera;
DEFINE vc_apellido LIKE sga_personas.apellido;
DEFINE vc_nombres LIKE sga_personas.nombres;
DEFINE vi_tipo_doc1 integer;
DEFINE vc_nro_documento1 like sga_personas.nro_documento;
DEFINE vc_carrera1 varchar(5);
DEFINE vc_carrera_nombre1 varchar(255);
DEFINE vi_cant_plan1 integer;
DEFINE vi_cant_reprob integer;
DEFINE vc_nombre_carrera varchar(80);
DEFINE vc_nombre_titulo varchar(100);
DEFINE vb_egresado integer; 
DEFINE vc_carrera_cod varchar(5);
DEFINE vc_pais_cod integer; 

LET vi_codigo_ret = 0;
LET vc_mje_ret = 'OK - Datos Academicos';
LET vc_unidad_academica = NULL;
LET vc_carrera = NULL;
LET vc_nombre_carrera = NULL;
LET vc_carrera_nombre = NULL;
LET vc_estado = NULL;
LET vd_ingreso = NULL;
LET vd_fin = NULL;
LET vi_cant_aprob = NULL;
LET vi_cant_plan = NULL;
LET vi_prom_aplazo = NULL;
LET vi_prom_sin_aplazo = NULL;
LET vc_legajo = NULL;
LET vc_unl_ua  = NULL;
LET vc_unl_carrera  = NULL;
LET vc_apellido  = NULL;
LET vc_nombres  = NULL;
LET vi_tipo_doc1 = NULL;
LET vc_nro_documento1 = NULL;
LET vc_unl_carrera1= NULL;
LET vc_carrera_nombre1 = NULL;
LET vi_cant_plan1 = NULL;
LET vi_cant_reprob =NULL;
LET vc_mje_sit_asp = NULL;
LET vc_regular = NULL;
LET vc_nombre_titulo  = NULL;
LET vb_egresado = 0;
LET vc_carrera_cod = NULL;
LET vc_pais_cod = NULL;
LET istatus = NULL;
LET vcMsg = NULL;

FOREACH 
SELECT  car.unidad_academica, alu.carrera, alu.legajo, alu.nro_inscripcion, alu.calidad, alu.fecha_ingreso, 
--egre.fecha_egreso, 
 (case when  alu.calidad = 'E' then egre.fecha_egreso  else null end) as fecha_egresado,
cod.unl_ua, cod.unl_carrera,car.nombre, sit.descripcion, (case when  per.sexo = 0 then titu.nombre else titu.nombre_femenino end) as nombre_titulo,   (case when  alu.calidad = 'E' then 1 else 0 end) as egresado

 INTO  vc_unidad_academica, vc_carrera, vc_legajo, vc_nro_inscripcion, vc_estado, vd_ingreso, vd_fin, vc_unl_ua, vc_unl_carrera, vc_nombre_carrera, vc_mje_sit_asp,vc_nombre_titulo, vb_egresado
FROM sga_personas per
	join sga_alumnos alu
		on per.nro_inscripcion = alu.nro_inscripcion
	join sga_carrera_aspira asp
		on per.nro_inscripcion = asp.nro_inscripcion and alu.carrera = asp.carrera and asp.fecha_inscripcion = (Select max(fecha_inscripcion) From sga_carrera_aspira Where  alu.carrera = carrera and per.nro_inscripcion = nro_inscripcion)
	join sga_situacion_asp sit
		on sit.situacion_asp = asp.situacion_asp
	join sga_carreras car
		on alu.carrera = car.carrera
	join u820_codigos_univ cod
		on car.carrera = cod.carrera
	left join sga_titulos_otorg egre
		on alu.carrera = egre.carrera
		and alu.nro_inscripcion = egre.nro_inscripcion
		and egre.fecha_egreso = (Select max(fecha_egreso) From sga_titulos_otorg Where  alu.carrera = carrera and alu.nro_inscripcion = nro_inscripcion)
	left join sga_titulos titu
		on titu.titulo = egre.titulo

WHERE  per.nro_documento= pNroDocumento
AND per.tipo_documento = pTipoDocumento
AND per.pais_documento = pPais
AND car.tipo_de_carrera IN ('C', 'P', 'B', 'R', 'T', 'S', 'W')
AND sit.situacion_asp in ('IL','IC')

        -- Regularidad en la carrera
        execute PROCEDURE ctr_reinscrAlumno( vc_unidad_academica, vc_carrera, vc_legajo,'') INTO istatus, vcMsg;
        IF (istatus = 1) 
        THEN
            LET vc_regular = 'S';
        ELSE
            LET vc_regular = 'N';
        END IF;

	-- Calculo de datos academicos: cant. mat. aprob.; cant. mat. plan; prom. c/aplazos; prom. s/aplazos

	execute  PROCEDURE "dba".sp820_prom_alu_res1(vc_unidad_academica, vc_carrera, vc_legajo, 'S') Into vi_prom_aplazo;
	execute  PROCEDURE "dba".sp820_prom_alu_res1(vc_unidad_academica, vc_carrera, vc_legajo, 'N') Into vi_prom_sin_aplazo;
	-- el problema es el numero de parametros devueltos
	execute PROCEDURE "dba".sp820_can_apro_SCI (vc_nro_inscripcion, vc_carrera) Into vi_tipo_doc, vc_nro_documento, vc_unl_carrera, vc_carrera_nombre, vi_cant_plan, vi_cant_aprob, vc_apellido, vc_nombres, vc_pais_cod,vc_carrera_cod ;

	execute PROCEDURE "dba".sp820_can_repro_SCI (vc_nro_inscripcion, vc_carrera) Into vi_tipo_doc1, vc_nro_documento1, vc_unl_carrera1, vc_carrera_nombre1, vi_cant_plan1, vi_cant_reprob;
	
	IF vc_estado = 'A' THEN
		LET vc_estado = 'Activo';
	ELIF  vc_estado = 'E' THEN
		LET vc_estado = 'Egresado';		
	ELIF  vc_estado = 'P' THEN
		LET vc_estado = 'Pasivo';
	ELSE
		LET vc_estado = 'Abandono';
	END IF;
	
	RETURN vi_codigo_ret, vc_unidad_academica, vc_carrera, vc_estado, vd_ingreso, vd_fin, vi_cant_aprob, vi_cant_plan, vi_prom_aplazo, vi_prom_sin_aplazo,vi_cant_reprob,vc_nombre_carrera, vc_mje_sit_asp, vc_regular, vc_nombre_titulo,vb_egresado, vc_mje_ret WITH RESUME;

	
END FOREACH;

IF vd_ingreso is null THEN 
	LET vi_codigo_ret = -1;
	LET vc_mje_ret = 'No hay datos - Tipo ' || pTipoDocumento || '  Documento ' || pNroDocumento || ' inexistente';
	RETURN vi_codigo_ret, vc_unidad_academica, vc_carrera, vc_estado, vd_ingreso, vd_fin, vi_cant_aprob, vi_cant_plan, vi_prom_aplazo, vi_prom_sin_aplazo,vi_cant_reprob,vc_nombre_carrera,vc_mje_sit_asp, vc_regular,vc_nombre_titulo,vb_egresado, vc_mje_ret;
		
END IF;


END PROCEDURE;



-- Casos de prueba
{
select * from aca_usuarios_ag tipo_usuario = 'DOC';
select * from sga_carrera_aspira where situacion_asp = 'AC';
select * from sga_personas where nro_inscripcion = 'FICH-7193';

Casos:
-- Usuario Autenticado
EXECUTE PROCEDURE "dba".web_service_rendimiento_acad(0, '29722252',54); --1

-- Usuario No autenticado por identificacion
EXECUTE PROCEDURE "dba".web_service_rendimiento_acad(0, "30339250", 54); --0


}

-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_dat_acad_hefe 
-- *****************************************************************************
revoke execute on "dba".web_service_rendimiento_acad from public;
grant execute on "dba".web_service_rendimiento_acad to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_service_rendimiento_acad to internet; -- Rol de usuario de Internet
