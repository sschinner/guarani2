CREATE PROCEDURE "dba".verifica_objeto()

BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_carreras_alumno') THEN
		DROP PROCEDURE "dba".web_serv_carreras_alumno;
	END IF;		
END

END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Par?metros de WS: carrera; 
-- Objetivo: obtener el listado de materias de una determinada carrera y plan vigente
-- execute procedure "dba".web_serv_carreras_alumno('29349542','0','54');

CREATE PROCEDURE "dba".web_serv_carreras_alumno(pnro_documento varchar(15), ptipo_documento integer, ppais integer)
RETURNING varchar(5), -- unidad academica
varchar(5), -- carrera
varchar(255), -- nombre carrera
varchar(10), -- calidad
integer, --tipoIngreso
varchar(255), -- descripciontipoIngreso
varchar(5),  --tipoCarrera
varchar(255) -- descripciontipoCarrera

DEFINE vc_unidad_academica like sga_alumnos.unidad_academica;
DEFINE vc_carrera like sga_carreras.carrera;
DEFINE vc_nombre_car like sga_carreras.nombre;
DEFINE vc_calidad varchar(10);
DEFINE vc_tipo_ingreso integer;
DEFINE vc_descripcion_tipo_ingreso varchar(255);
DEFINE vc_tipo_carrera varchar(5);
DEFINE vc_descripcion_tipo_carrera varchar(255);


LET vc_unidad_academica = NULL;
LET vc_carrera = NULL;
LET vc_nombre_car = NULL;
LET vc_calidad =NULL;
LET vc_tipo_ingreso = NULL;
LET vc_descripcion_tipo_ingreso = NULL;
LET vc_tipo_carrera =NULL;
LET vc_descripcion_tipo_carrera =NULL;



FOREACH


SELECT a.unidad_academica, c.carrera, c.nombre, a.calidad, ca.tipo_ingreso, ti.descripcion, c.tipo_de_carrera, tc.nombre 
		INTO 	vc_unidad_academica, vc_carrera ,vc_nombre_car ,vc_calidad ,vc_tipo_ingreso,vc_descripcion_tipo_ingreso,vc_tipo_carrera,vc_descripcion_tipo_carrera
					FROM sga_personas p
					INNER JOIN sga_alumnos a ON (p.nro_inscripcion = a.nro_inscripcion)
					INNER JOIN sga_carrera_aspira ca ON (a.nro_inscripcion = ca.nro_inscripcion AND a.carrera = ca.carrera)
					INNER JOIN sga_carreras c ON (a.carrera = c.carrera)
					LEFT JOIN sga_tipos_carrera tc ON (tc.tipo_de_carrera = c.tipo_de_carrera)
					LEFT JOIN sga_tipos_ingreso ti ON (ti.tipo_ingreso =ca.tipo_ingreso )
		WHERE p.nro_documento = pnro_documento 
		AND p.tipo_documento = ptipo_documento 
		AND p.pais_documento = ppais
                AND c.nombre_reducido = 'ALUMNOS_INTEGRACION'

	IF vc_calidad = 'A' THEN
		LET vc_calidad = 'Activo';
	ELIF  vc_calidad = 'E' THEN
		LET vc_calidad = 'Egresado';		
	ELIF  vc_calidad = 'P' THEN
		LET vc_calidad = 'Pasivo';
	ELSE
		LET vc_calidad = 'Abandono';
	END IF;
	

RETURN vc_unidad_academica, vc_carrera ,vc_nombre_car ,vc_calidad ,vc_tipo_ingreso,vc_descripcion_tipo_ingreso,vc_tipo_carrera,vc_descripcion_tipo_carrera WITH RESUME;


END FOREACH;

END PROCEDURE;
