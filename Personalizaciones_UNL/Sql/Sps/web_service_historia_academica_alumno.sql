CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_service_historia_academica_alumno') THEN
		DROP PROCEDURE "dba".web_service_historia_academica_alumno;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Par?metros de WS: tipo y nro. documento;
-- El alumno puede tener titulo intermedio, en cuyo caso sigue siendo alumno.

-- execute PROCEDURE  "dba".web_service_historia_academica_alumno('03',0,'29686498',54)

CREATE PROCEDURE "dba".web_service_historia_academica_alumno(pCarrera varchar(10), ptipoDocumento integer, pNroDocumento varchar(20), pPais integer)

RETURNING  varchar(10), -- codigo materia

varchar(100), -- nombre materia

date, -- Fecha examen

varchar(4), -- nota

varchar(2), -- resultado

varchar(10), --acta

varchar(1), -- tipo_acta

varchar(15), --forma_aprobacion

varchar(10), -- nro_resolucion

varchar(20), --nombre tipo materia 

varchar(1), -- tipo de materia

integer, -- 0) codigo retorno

varchar(150); --Mensaje retorno





DEFINE vi_codigo_ret integer;

DEFINE vc_mje_ret varchar(150);

DEFINE vc_tipo_de_materia varchar(1);

DEFINE vc_materia_nombre varchar(255);

DEFINE vc_materia varchar(5);

DEFINE vd_fecha_examen date;

DEFINE vc_resultado varchar(2);

DEFINE vc_forma_aprobacion varchar(15);

DEFINE vc_tipo_acta varchar(1);

DEFINE vc_acta varchar(10);

DEFINE vc_acta_promo varchar(10);

DEFINE vc_nro_resolucion varchar(10);

DEFINE vc_nombre_tipo_materia varchar(20);

--DEFINE vc_nota decimal(6,2);

DEFINE vc_nota varchar(4);






LET vi_codigo_ret = 0;

LET vc_mje_ret = 'OK - Historia Academica';

LET vc_tipo_de_materia = NULL;

LET vc_materia = NULL;

LET vc_materia_nombre = NULL;

LET vd_fecha_examen = NULL;

LET vc_resultado = NULL;

LET vc_nota = NULL;

LET vc_forma_aprobacion  = NULL;

LET vc_tipo_acta = NULL;

LET vc_acta  = NULL;

LET vc_acta_promo  = NULL;

LET vc_nro_resolucion = NULL;

LET vc_nombre_tipo_materia = NULL;

IF NOT EXISTS (SELECT * FROM sga_personas WHERE nro_documento = pNroDocumento and tipo_documento = ptipoDocumento and pais_documento = pPais ) THEN
	LET vi_codigo_ret = -1;

	LET vc_mje_ret = 'No hay datos - Tipo ' || pTipoDocumento || '  Documento ' || pNroDocumento || ' Pais ' || pPais || ' y Carrera ' || pCarrera || '';

	RETURN  vc_materia , vc_materia_nombre  ,vd_fecha_examen , vc_nota , vc_resultado  , vc_acta , vc_tipo_acta , vc_forma_aprobacion ,   vc_nro_resolucion, vc_nombre_tipo_materia , vc_tipo_de_materia, vi_codigo_ret, vc_mje_ret ;
		
	END IF;

FOREACH 

SELECT h.materia, m.nombre, h.fecha, h.resultado, h.nota, h.forma_aprobacion, h.tipo_acta, h.acta, h.acta_promocion, h.nro_resolucion, t.desc_abreviada, m.tipo_de_materia

 INTO  vc_materia , vc_materia_nombre  ,vd_fecha_examen , vc_resultado , vc_nota  , vc_forma_aprobacion , vc_tipo_acta , vc_acta  , vc_acta_promo  , vc_nro_resolucion, vc_nombre_tipo_materia, vc_tipo_de_materia 

FROM sga_personas per

	INNER JOIN sga_alumnos alu

		ON per.nro_inscripcion = alu.nro_inscripcion

	INNER JOIN vw_hist_academica h

		ON h.legajo = alu.legajo and h.carrera = alu.carrera

	INNER JOIN sga_materias m

		ON m.materia = h.materia
	
	INNER JOIN sga_tipos_materia t

		ON m.tipo_de_materia = t.tipo_de_materia

	INNER JOIN sga_carreras_grupo cg
		ON cg.carrera = alu.carrera

WHERE  per.nro_documento= pNroDocumento

AND per.tipo_documento = pTipoDocumento

AND per.pais_documento = pPais

AND alu.carrera = pCarrera
AND cg.grupo_carrera in ('00001', 'i0001')


	IF vc_acta = '' THEN

		LET vc_acta = vc_acta_promo;

	END IF;



  	RETURN  vc_materia , vc_materia_nombre  ,vd_fecha_examen , vc_nota , vc_resultado  , vc_acta, vc_tipo_acta , vc_forma_aprobacion ,   vc_nro_resolucion,vc_nombre_tipo_materia , vc_tipo_de_materia, vi_codigo_ret, vc_mje_ret WITH RESUME;

END FOREACH;



IF vc_materia is null THEN 

	LET vi_codigo_ret = 0;

	LET vc_mje_ret = 'El alumno no posee historia académica en la carrera '  || pCarrera || '';

	RETURN  vc_materia , vc_materia_nombre  ,vd_fecha_examen , vc_nota , vc_resultado  , vc_acta , vc_tipo_acta , vc_forma_aprobacion ,   vc_nro_resolucion, vc_nombre_tipo_materia , vc_tipo_de_materia, vi_codigo_ret, vc_mje_ret ;

		

END IF;

END PROCEDURE;


-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
--revoke execute on "dba".web_service_historia_academica_alumno from public;--
--grant execute on "dba".web_service_historia_academica_alumno to guarani; -- Rol de usuarios de Gestion
--grant execute on "dba".web_service_historia_academica_alumno to internet; -- Rol de usuario de Internet
