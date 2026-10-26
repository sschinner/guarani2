

CREATE PROCEDURE "dba".verifica_objeto()

BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_genera_legajo') THEN
		DROP PROCEDURE web_serv_genera_legajo;
	END IF;		
END

END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: legajo
-- Objetivo: determinar si una persona es alumno de una determinada carrera
--EXECUTE PROCEDURE web_serv_genera_legajo ('FBCB',2016,'0302',54,0,'39033218');

CREATE PROCEDURE 'dba'.web_serv_genera_legajo (pua varchar(10), pcarrera varchar(8), ppais_doc integer, ptipo_doc integer, pnro_doc varchar(15), ptipolegajo char(1))
RETURNING  varchar (15),--1
	integer, --2
	integer, --3)  
	varchar (250); --4)	Mensaje


DEFINE vi_nro_insc varchar (15);
DEFINE vc_resultado varchar (15);
DEFINE vi_cod_uno integer;
DEFINE vi_cod_dos integer;
DEFINE vc_mensaje varchar (250);
DEFINE leg                	LIKE sga_alumnos.legajo;
DEFINE l_periodo_insc     	LIKE sga_carrera_aspira.periodo_inscripcio;
DEFINE anro_inscripcion LIKE sga_personas.nro_inscripcion;
DEFINE v_retorno_situasp  	LIKE sga_situacion_asp.situacion_asp;
DEFINE ll_result, ll_result2		Integer;
DEFINE ls_mensaje_result,ls_mensaje_result2 	varchar(255);
DEFINE panio_acad integer;

-- Variables para el manejo de excepciones
DEFINE sql_err 		integer;
DEFINE  isam_err		integer;
DEFINE error_Info          varchar(76);

-- Si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vc_mensaje = 'Error de procedimiento.';
      LET vi_cod_uno = 4; 
      LET vi_cod_dos = '';
      LET vc_mensaje =  vc_mensaje || ', ' || sql_err || ' - ' || error_Info;
      SET TRIGGERS FOR sga_datos_censales enabled;
      
     RETURN vc_resultado,  vi_cod_uno, vi_cod_dos, vc_mensaje;
END EXCEPTION;


BEGIN

LET vi_nro_insc = NULL;
LET vc_resultado = '0';
LET vc_mensaje = '';
LET vi_cod_uno = -2;
LET vi_cod_dos = '';
LET leg = NULL;
LET l_periodo_insc = NULL;
LET anro_inscripcion = NULL;
LET panio_acad = NULL;

-- OBTENGO EL AÑO ACADEMICO 

SELECT insc.anio_academico
	INTO panio_acad
		FROM sga_periodo_insc insc
		join sga_carrera_aspira c
			on insc.periodo_inscripcio = c.periodo_inscripcio
		join sga_personas p 
			on  p.nro_inscripcion= c.nro_inscripcion

where p.nro_documento= pnro_doc
and p.pais_documento=ppais_doc
and p.tipo_documento=ptipo_doc
and c.carrera = pcarrera
and c.fecha_inscripcion = (select max(fecha_inscripcion)
				from sga_carrera_aspira
					join sga_periodo_insc
					on sga_carrera_aspira.periodo_inscripcio = sga_periodo_insc.periodo_inscripcio
				where sga_carrera_aspira.nro_inscripcion = c.nro_inscripcion
				and sga_carrera_aspira.carrera = c.carrera
				and sga_carrera_aspira.carrera = pcarrera);


-- VERIFICAR PRIMERO SI NO ESTA RECHAZADO EN EL PERIODO DE INSCRIPCION
-- ESTO SE PUEDE DAR POR EL CONTROL DE CIERRE DE PERIODO DE INSCRIPCION
-- DEBO VERIFICAR TODOS LOS PERIODOS DE INSCRIPCION DEL AÑO ACADEMICO


IF EXISTS (SELECT '*'
		FROM sga_periodo_insc insc
		join sga_carrera_aspira c
			on insc.periodo_inscripcio = c.periodo_inscripcio
		join sga_situacion_asp sit
			on c.situacion_asp = sit.situacion_asp
		join sga_personas p 
			on  p.nro_inscripcion= c.nro_inscripcion

where p.nro_documento=pnro_doc
and p.pais_documento=ppais_doc
and p.tipo_documento=ptipo_doc
and c.carrera = pcarrera
and sit.resultado_asp = 'R'
and insc.anio_academico = panio_acad
and c.fecha_inscripcion = (select max(fecha_inscripcion)
				from sga_carrera_aspira
					join sga_periodo_insc
					on sga_carrera_aspira.periodo_inscripcio = sga_periodo_insc.periodo_inscripcio
				where sga_carrera_aspira.nro_inscripcion = c.nro_inscripcion
				and sga_carrera_aspira.carrera = c.carrera
				and sga_carrera_aspira.carrera = pcarrera
				and sga_periodo_insc.anio_academico = panio_acad
				)

) THEN

	LET vc_mensaje = 'Aspirante rechazado en el periodo de inscripcion';
	LET vi_cod_uno = -3;
ELSE


	-- Si ya posee legajo el alumno, para esa carrera, lo recupero (alumnos que fueron rechazados por control de cierre de PI por ejemplo).
	-- Obtengo el max. ya que pueden tener muchas inscripciones a periodos
	SELECT p.nro_inscripcion, a.legajo, c.periodo_inscripcio INTO vi_nro_insc, leg, l_periodo_insc
	FROM sga_periodo_insc insc
		join sga_carrera_aspira c
			on insc.periodo_inscripcio = c.periodo_inscripcio
		join sga_personas p 
			on  p.nro_inscripcion= c.nro_inscripcion
		left join sga_alumnos a 
			on c.nro_inscripcion = a.nro_inscripcion
			and c.carrera = a.carrera

	where p.nro_documento=pnro_doc
	and p.pais_documento=ppais_doc
	and p.tipo_documento=ptipo_doc
	and c.carrera = pcarrera
	and insc.anio_academico = panio_acad
	and c.situacion_asp in ('AC')
	and c.fecha_inscripcion = (select max(fecha_inscripcion)
				from sga_carrera_aspira
					join sga_periodo_insc
					on sga_carrera_aspira.periodo_inscripcio = sga_periodo_insc.periodo_inscripcio
				where sga_carrera_aspira.nro_inscripcion = c.nro_inscripcion
				and sga_carrera_aspira.carrera = c.carrera
				and sga_carrera_aspira.carrera = pcarrera
				and sga_periodo_insc.anio_academico = panio_acad
				);

	IF (vi_nro_insc  IS NOT NULL)  THEN

		execute PROCEDURE "dba".sp_crear_alumno (trim(pua), vi_nro_insc, trim(pcarrera), leg, NULL) into vc_resultado,  vi_cod_uno, vi_cod_dos, vc_mensaje;

		IF vi_cod_uno = 0 THEN

			-- Cambio la condicionalidad del legajo
			IF ptipolegajo = 'N' THEN
				-- Se pasa la situacion de aspirante a 'IC'(Ingresante Condicional).
				UPDATE 	sga_carrera_aspira
				SET 	situacion_asp = 'IC'
				WHERE 	unidad_academica = pua
				AND	carrera = pcarrera
				AND	nro_inscripcion = vi_nro_insc
				AND	periodo_inscripcio = l_periodo_insc;
			END IF;

		END IF;

	ELSE 

		-- En caso de que tenga legajo generado, se solicite por parametro legajo "S" y cumplimente los requisitos obligatorios, se le cambia la situación del alumno a "IL".
		Select per.nro_inscripcion, asp.periodo_inscripcio Into anro_inscripcion, l_periodo_insc
				from sga_personas per
					join sga_carrera_aspira asp
					on per.nro_inscripcion = asp.nro_inscripcion
					join sga_alumnos alu
					on asp.nro_inscripcion = alu.nro_inscripcion
					and asp.carrera = alu.carrera
				where per.tipo_documento = ptipo_doc 
					and per.nro_documento = pnro_doc
					and per.pais_documento = ppais_doc
					and per.unidad_academica = pua
					and asp.carrera = pCarrera
					and asp.situacion_asp = 'IC';

		IF (anro_inscripcion IS NOT NULL) AND (ptipolegajo = 'S')THEN
		
			IF l_periodo_insc IS NOT NULL THEN
				-- Ejecutar el Sp. para saber si cumplió con todos los requisitos obligatorios.
		      		EXECUTE PROCEDURE sp_cumplio_req(pua,anro_inscripcion,pCarrera,l_periodo_insc) INTO ll_result, ll_result2, ls_mensaje_result;
				IF ll_result = 1 THEN

					-- Se pasa la situación de aspirante a 'IL'(Ingresante con Legajo).
					-- Buscar el código de situacion de aspirante por default establecido, para resultado inscripto('I').
					EXECUTE PROCEDURE sp_default_sit_res('I') into v_retorno_situasp;
					UPDATE 	sga_carrera_aspira
					SET 	situacion_asp = v_retorno_situasp
					WHERE 	unidad_academica = pua
					AND	carrera = pCarrera
					AND	nro_inscripcion = anro_inscripcion
					AND	periodo_inscripcio = l_periodo_insc;

					LET vi_cod_uno = '0';
					LET vc_mensaje = 'Se cambio la calidad de legajo del alumno a Definitivo';
				ELSE
					LET vc_mensaje = 'Alumno con legajo condicional ya generado en la carrera para el año académico ' || panio_acad;
					LET vi_cod_uno = '-1';

				END IF;
			END IF;
	
		ELSE
			LET vc_mensaje = 'La persona No es aspirante de la carrera o ya tiene legajo generado'; -- Una vez generado legajo (inicialmente condicional por parte de bienestar), solo alumnado puede cambiar la situación del mismo a definitivo si corresponde. 
	
		END IF;
	END IF;

END IF;

RETURN vc_resultado,  vi_cod_uno, vi_cod_dos, vc_mensaje;


END;
END PROCEDURE;


--EXECUTE PROCEDURE web_serv_genera_legajo ("FHUC","04", "54","0", "31341313", 'N');
-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_esta_inscripto 
-- *****************************************************************************
revoke execute on "dba".web_serv_genera_legajo from public;
grant execute on "dba".web_serv_genera_legajo to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_genera_legajo to internet; -- Rol de usuario de Internet









