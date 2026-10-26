
CREATE PROCEDURE "dba".verifica_objeto()

BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_materias_carrera ') THEN
		DROP PROCEDURE web_serv_materias_carrera ;
	END IF;		
END

END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();
-- execute procedure web_serv_carreras_ua();
-- Parametros de WS: carrera; 
-- Objetivo: obtener el listado de materias de una determinada carrera y plan vigente
-- execute procedure web_serv_materias_carrera ('1','2001','9');
-- select * from sga_versiones_plan order by 2, 3, 4;

CREATE PROCEDURE web_serv_materias_carrera (pcarrera varchar(10), pplan varchar(5), pversion varchar(5))
RETURNING varchar(5), -- 0)materia
varchar(255), -- nombre materia
varchar(1), --tipo materia
varchar(5), --horas semanales
varchar(5) ,--carga horaria
varchar(5), --valor materia
varchar(1), --promediable
varchar(1), --obligatoria
varchar(5), --anio_de_cursada
varchar(15), -- periodo_dictado
varchar(15) --tipo_de_periodo

DEFINE vc_materia varchar(5);
DEFINE vc_nombre_mat varchar(255);
DEFINE vc_tipo_mat varchar(5);
DEFINE vc_horas_semanales varchar(5);
DEFINE vc_carga_horaria varchar(5);
DEFINE vc_valor_materia varchar(5);
DEFINE vc_obligatoria varchar(1);
DEFINE vc_promediable varchar(1);
DEFINE  vc_anio_cursada varchar(5);
DEFINE vc_periodo_dictado varchar(15);
DEFINE vc_tipo_periodo varchar(15);

LET vc_materia = NULL;
LET vc_nombre_mat =NULL;
LET vc_tipo_mat = NULL;
LET vc_horas_semanales  = NULL;
LET vc_carga_horaria = NULL;
LET vc_valor_materia = NULL;
LET vc_obligatoria = NULL;
LET vc_promediable = NULL;
LET vc_anio_cursada = NULL;
LET vc_periodo_dictado = NULL;
LET vc_tipo_periodo = NULL;

FOREACH

SELECT unique a.materia, a.nombre_materia, a.tipo_materia, a.horas_semanales, a.carga_horaria_tot, CAST(NULL as INTEGER), a.promediable, a.obligatoria,a.anio_de_cursada, a.periodo_dictado, ma.tipo_de_periodo
		--INTO vc_materia, vc_nombre_mat, vc_tipo_mat, vc_horas_semanales ,vc_carga_horaria, vc_valor_materia, vc_promediable , vc_obligatoria, vc_anio_cursada, vc_periodo_dictado,vc_tipo_periodo 
	FROM sga_atrib_mat_plan a
		JOIN sga_carreras c on a.carrera = c.carrera
		JOIN sga_tipos_carrera tc on tc.tipo_de_carrera = c.tipo_de_carrera 	
		JOIN sga_carreras_grupo cg on cg.carrera = c.carrera
		JOIN sga_materias ma on  ma.materia = a.materia

	WHERE a.carrera= pcarrera			
	AND a.plan = pplan
 	AND a.version = pversion
	AND cg.grupo_carrera = '00001' -- Carreras de Grado
	AND a.tipo_materia <> 'G'
	AND a.tipo_materia <> 'O'
	AND a.obligatoria = 'S'
	AND a.materia NOT IN (select materia from u820_cursos_ing)

	
UNION


SELECT unique a.materia, a.nombre_materia, a.tipo_materia, a.horas_semanales, a.carga_horaria_tot, m.valor_materia, a.promediable, a.obligatoria,a.anio_de_cursada, a.periodo_dictado,ma.tipo_de_periodo  
		INTO vc_materia, vc_nombre_mat, vc_tipo_mat, vc_horas_semanales ,vc_carga_horaria, vc_valor_materia, vc_promediable , vc_obligatoria, vc_anio_cursada, vc_periodo_dictado,vc_tipo_periodo 
	FROM sga_atrib_mat_plan a
		JOIN sga_carreras c on a.carrera = c.carrera
		JOIN sga_tipos_carrera tc on tc.tipo_de_carrera = c.tipo_de_carrera 	
		JOIN sga_carreras_grupo cg on cg.carrera = c.carrera
		JOIN sga_materias ma on  ma.materia = a.materia
		LEFT JOIN sga_mat_genericas m ON m.materia_optativa=a.materia

	WHERE a.carrera= pcarrera			
	AND a.plan = pplan
 	AND a.version = pversion
	AND cg.grupo_carrera = '00001' -- Carreras de Grado
	AND a.tipo_materia <> 'G'
	AND (
		(m.materia_generica in (Select atm.materia From sga_atrib_mat_plan atm
						JOIN sga_materias mat on atm.materia = mat.materia  
		WHERE atm.carrera= pcarrera 
		AND atm.plan = pplan 
		AND atm.version = pversion
		AND UPPER(mat.nombre) LIKE "%OPTATIVA%") -- Criterio por nombre de Bolsa de materia: es lo mas aproximado. Se puede modificar el nombre de materi por sistema. La Bolsa que no contenga optativas, no debe figurar en su nombre la palabra optativa. En caso contrario si debe figurar.
		OR
		m.materia_generica IS NULL -- EN ETE CASO ES UNA MATERIA DIRECTA DEL PLAN
		)			          )
	AND a.materia NOT IN (select materia from u820_cursos_ing)
	order by 1

RETURN vc_materia, vc_nombre_mat, vc_tipo_mat,vc_horas_semanales, vc_carga_horaria, vc_valor_materia, vc_promediable , vc_obligatoria, vc_anio_cursada, vc_periodo_dictado,vc_tipo_periodo   WITH RESUME;


END FOREACH;

END PROCEDURE;
-- execute procedure "dba".web_serv_materias_carrera('03',  '2006', '28');

-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_materias_carrera 
-- *****************************************************************************
revoke execute on "dba".web_serv_materias_carrera from public;
grant execute on web_serv_materias_carrera to guarani; -- Rol de usuarios de Gestion
grant execute on web_serv_materias_carrera to internet; -- Rol de usuario de Internet

