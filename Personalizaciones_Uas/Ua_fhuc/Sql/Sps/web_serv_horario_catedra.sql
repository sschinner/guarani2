CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_horario_catedra') THEN
		DROP PROCEDURE web_serv_horario_catedra;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

--execute procedure web_serv_horario_catedra(2017, '1er. Cuatrimestre')


-- Parámetros de WS: anio academico; periodo lectivo; 
-- Objetivo: obtener los datos de las cursadas de un determinado año y periodo lectivos

CREATE PROCEDURE "dba".web_serv_horario_catedra(panio_cademico integer, pperiodo_lectivo  varchar(50))
RETURNING varchar(200), -- 0) nombre materia
varchar(10), -- codigo materia
varchar(10), -- codgo carrera
varchar(80), --carrera
integer, --comision
varchar(150), --nombre de la comision
varchar(100), -- apellido
varchar(100),-- nombre profesor
varchar(15), -- documento profesor
integer, -- dia de la semana
varchar(100), -- dia de la semana
varchar(50), -- tipo de clase
varchar(10), -- hora inicio clase.
varchar(10), -- hora fin clase.
varchar(50) , -- nombre aula
varchar(50),-- nombre edificio
integer, -- anio cursada
varchar(255) -- sede/ubicacion

DEFINE vc_nombre_materia varchar(200);
DEFINE vc_codigo_materia varchar(10);
DEFINE vi_codigo_carrera varchar(10);
DEFINE vc_carrera varchar(80);
DEFINE vi_comision integer;
DEFINE vc_nombre_comision varchar(150);
DEFINE vc_apellido_doc varchar(80);
DEFINE vc_nombre_doc varchar(80);
DEFINE vi_documento_doc varchar(15);
DEFINE vi_dia_semana integer;
DEFINE vc_dia_semana varchar(50);
DEFINE vi_tipo_clase varchar(100);
DEFINE vd_hora_comienzo varchar(10);
DEFINE vd_hora_fin varchar(10); 
DEFINE vc_nombre_aula varchar(50);
DEFINE vc_nombre_edificio varchar(50);
DEFINE vi_anio_cursada integer;
DEFINE vc_ubicacion varchar(255);


LET vi_dia_semana =0;
LET vi_comision = 0;
LET vi_codigo_carrera = NULL;
LET vc_dia_semana = NULL;
LET vi_tipo_clase = NULL;
LET vc_carrera = NULL;
LET vc_nombre_comision = NULL;
LET vc_nombre_materia = NULL;
LET vi_documento_doc = NULL;
LET vc_apellido_doc = NULL;
LET vc_nombre_doc = NULL;
LET vc_codigo_materia = NULL;
LET vd_hora_comienzo = NULL;
LET vd_hora_fin = NULL;
LET vc_nombre_aula = NULL;
LET vc_nombre_edificio = NULL;
LET vi_anio_cursada = 0;
LET vc_ubicacion = NULL;

FOREACH
	SELECT  unique(m.nombre), c.materia, ca.carrera, ca.nombre, c.comision, c.nombre As nombrecomision, p.apellido, p.nombres, p.nro_documento, a.dia_semana, (case when a.dia_semana="1" THEN 'Domingo' ELSE (case when a.dia_semana="2" THEN 'Lunes' ELSE  (case when a.dia_semana="3" THEN 'Martes' ELSE  (case when a.dia_semana="4" THEN 'Miercoles' ELSE  (case when a.dia_semana="5" THEN 'Jueves' ELSE  (case when a.dia_semana="6" THEN 'Viernes' ELSE'Sabado' END)END)END)END)END)END) AS diaSemana, tc.descripcion, a.hs_comienzo_clase, a.hs_finaliz_clase, au.nombre_aula, e.nombre As nombre_edificio, amp.anio_de_cursada, sed.nombre
		INTO   vc_nombre_materia , vc_codigo_materia, vi_codigo_carrera, vc_carrera,  vi_comision,vc_nombre_comision, vc_apellido_doc, vc_nombre_doc, vi_documento_doc, vi_dia_semana, vc_dia_semana, vi_tipo_clase, vd_hora_comienzo, vd_hora_fin, vc_nombre_aula, vc_nombre_edificio, vi_anio_cursada, vc_ubicacion
			FROM sga_comisiones c
				LEFT JOIN sga_asign_clases s ON (c.comision = s.comision)
				LEFT JOIN sga_asignaciones a ON (s.asignacion = a.asignacion)
				LEFT JOIN sga_docentes_com dc ON (dc.comision=c.comision)
				LEFT JOIN sga_docentes d ON (dc.legajo = d.legajo)
				LEFT JOIN sga_personas p ON (d.nro_inscripcion = p.nro_inscripcion)
				INNER JOIN sga_materias m ON (c.materia=m.materia)
				LEFT JOIN sga_tipo_clase tc ON (tc.tipo_clase = s.tipo_clase)
				LEFT JOIN sga_carreras ca ON (ca.carrera = c.carrera)
				LEFT JOIN sga_edificios e ON (e.edificio=a.edificio)
				LEFT JOIN sga_aulas au ON (au.aula=a.aula and au.edificio=e.edificio) 
				LEFT JOIN sga_atrib_mat_plan amp ON (amp.materia = c.materia and amp.plan = c.plan and amp.carrera = c.carrera and amp.version = (select max(version) as version_ from sga_atrib_mat_plan sg where sg.materia=c.materia and sg.carrera = ca.carrera and sg.plan = c.plan))
				JOIN sga_sedes sed ON c.sede = sed.sede
			WHERE c.anio_academico=panio_cademico
			AND  c.periodo_lectivo=pperiodo_lectivo
			-- AND c.insc_habilitada = 'S' -- Se quita este filtro por ticket 172645

	RETURN vc_nombre_materia , vc_codigo_materia, vi_codigo_carrera, vc_carrera, vi_comision, vc_nombre_comision,  vc_apellido_doc, vc_nombre_doc, vi_documento_doc, vi_dia_semana, vc_dia_semana, vi_tipo_clase, vd_hora_comienzo, vd_hora_fin, vc_nombre_aula, vc_nombre_edificio, vi_anio_cursada, vc_ubicacion WITH RESUME;

END FOREACH;
END PROCEDURE;

-- **************************  Fin del Procedure web_serv_horario_catedra **************************

REVOKE execute ON "dba".web_serv_horario_catedra FROM public;
GRANT execute ON "dba".web_serv_horario_catedra to guarani; -- Rol de usuarios de Gestion
GRANT execute ON "dba".web_serv_horario_catedra to internet; -- Rol de usuario de Internet
