CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_beca_alumno') THEN
		DROP PROCEDURE web_serv_beca_alumno;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: tipo y nro. documento;
-- El alumno puede tener titulo intermedio, en cuyo caso sigue siendo alumno.


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_beca_alumno') THEN
		DROP PROCEDURE web_serv_beca_alumno;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parametros de WS: tipo y nro. documento;
-- El alumno puede tener titulo intermedio, en cuyo caso sigue siendo alumno.


CREATE PROCEDURE "dba".web_serv_beca_alumno(pua varchar(10),pcarrera varchar(10),ppaisDocumento integer,ptipoDocumento integer, pNroDocumento varchar(20), pfechaInicio date, pfechaFin date)
RETURNING 
varchar(10), -- 0) codigo materia
varchar(255), --1) nombre materia
char(1), --2) tipo materia
date, ---3) Fecha examen
varchar(20) ,---4) forma aprob
varchar(5), ---6) codigo carrera
varchar(255), ---5) nombre carrera
varchar(4), -- anio ingreso  
integer, --cod retorno
varchar(200); --mjs retorno

DEFINE vc_codigo_mat varchar(10);
DEFINE vc_nombre_materia varchar(255);
DEFINE vc_tipo_materia char(1); 
DEFINE vd_fecha_exa date;
DEFINE vc_forma_aprob varchar(20);
DEFINE vc_legajo varchar(20);
DEFINE vd_anio_actual date;
DEFINE vd_anio_ingreso varchar(4);
DEFINE vcEsIngresante char(1);
DEFINE vc_carrera LIKE sga_carreras.carrera;
DEFINE vc_carrera_nombre LIKE sga_carreras.nombre;

DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(80);
DEFINE vcUserError		varchar(10);
DEFINE iStatus			int;
DEFINE vcMsg			varchar(200);

DEFINE iExiste_trab_alum	int;
  -- si hay algun error
ON EXCEPTION SET sql_err, isam_err, error_Info                                        

      LET vcUserError  = 'Error de procedimiento.';
      LET iStatus 	  = 4; 
      LET vcMsg 	  =  vcUserError || ', ' || sql_err || ' - ' || error_Info;
    
     RETURN vc_carrera, vc_nombre_materia , vc_tipo_materia, vd_fecha_exa, vc_forma_aprob, vd_anio_ingreso,vc_carrera,vc_carrera_nombre, iStatus,vcMsg ;
END EXCEPTION;


LET vc_carrera  = NULL;
LET vc_carrera_nombre  = NULL;
LET vc_codigo_mat = NULL;
LET vc_nombre_materia = NULL;
LET vc_tipo_materia = NULL;
LET vd_fecha_exa = NULL;
LET vc_forma_aprob = NULL;
LET vc_legajo = NULL;
LET vd_anio_actual = YEAR(TODAY);
LET vcEsIngresante = NULL;
LET vd_anio_ingreso = NULL;
LET iStatus = 0;
LET vcMsg = 'OK - Beca Alumno';



FOREACH
	SELECT  alu.legajo, alu.carrera, car.carrera, car.nombre,  pi.anio_academico INTO vc_legajo, pcarrera, vc_carrera, vc_carrera_nombre, vd_anio_ingreso
		FROM sga_personas per
		JOIN sga_alumnos alu
			ON per.nro_inscripcion = alu.nro_inscripcion
		JOIN sga_carreras car
			ON alu.carrera = car.carrera
		JOIN sga_carrera_aspira ca
			ON per.nro_inscripcion = ca.nro_inscripcion and alu.carrera = ca.carrera
		JOIN sga_periodo_insc pi
			ON pi.periodo_inscripcio = ca.periodo_inscripcio 
	WHERE  per.nro_documento= pNroDocumento
	AND per.tipo_documento = pTipoDocumento
	AND per.pais_documento = ppaisDocumento
	AND (alu.carrera = pcarrera OR pCarrera IS NULL OR pCarrera = "")
	

		FOREACH
			

			SELECT  m.materia, m.nombre,  atr.tipo_materia, h.fecha, h.forma_aprobacion
			INTO  vc_codigo_mat , vc_nombre_materia, vc_tipo_materia, vd_fecha_exa, vc_forma_aprob 
			FROM sga_personas per
				JOIN sga_alumnos alu
					ON per.nro_inscripcion = alu.nro_inscripcion
				JOIN vw_hist_academica h
					ON h.legajo = alu.legajo AND h.carrera = alu.carrera
				JOIN sga_materias m
					ON m.materia = h.materia
				JOIN sga_atrib_mat_plan atr
					ON h.materia = atr.materia and alu.carrera = atr.carrera and h.plan = atr.plan and h.version = atr.version

			WHERE  per.nro_documento= pNroDocumento
			AND per.tipo_documento = pTipoDocumento
			AND per.pais_documento = ppaisDocumento
			AND (alu.carrera = pcarrera OR pCarrera IS NULL)
			AND h.resultado = 'A'
			AND (h.forma_aprobacion in ('Examen', 'Promoción') OR (h.forma_aprobacion = 'Equivalencia' AND atr.tipo_materia in ('O','E') ))
			AND ((atr.obligatoria ="S") OR (atr.obligatoria ="N" AND atr.tipo_materia <> 'N')) 
			AND (h.fecha >= pfechaInicio OR pfechaInicio IS NULL)
			AND (h.fecha <= pFechaFin OR pFechaFin IS NULL)
			AND h.materia NOT IN (Select materia from u820_cursos_ing)
			order by  h.fecha

		RETURN  vc_codigo_mat , vc_nombre_materia, vc_tipo_materia, vd_fecha_exa, vc_forma_aprob, vc_carrera, vc_carrera_nombre, vd_anio_ingreso,iStatus,vcMsg  WITH RESUME; 
		END FOREACH;

IF ( vc_codigo_mat IS NULL ) THEN 
	RETURN  vc_codigo_mat , vc_nombre_materia, vc_tipo_materia, vd_fecha_exa, vc_forma_aprob, vc_carrera, vc_carrera_nombre, vd_anio_ingreso,iStatus,vcMsg  WITH RESUME;
END IF;
END FOREACH;

IF vc_legajo is null THEN 
		LET iStatus = -1;
		LET vcMsg = 'No hay datos - Nro documento ' || pNroDocumento || ', Tipo documento ' ||  pTipoDocumento || ' y Pais documento ' || ppaisDocumento || ' - Verifique';
		RETURN  vc_codigo_mat , vc_nombre_materia, vc_tipo_materia, vd_fecha_exa, vc_forma_aprob, vc_carrera, vc_carrera_nombre, vd_anio_ingreso,iStatus,vcMsg  WITH RESUME; 
	END IF;
END PROCEDURE;

-- EXECUTE PROCEDURE "dba".web_serv_beca_alumno('FHUC', null, '54','0','39255571','01/01/2012','12/12/2018'); --1
-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_dat_acad_hefe 
-- *****************************************************************************
revoke execute on "dba".web_serv_beca_alumno from public;
grant execute on "dba".web_serv_beca_alumno to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_beca_alumno to internet; -- Rol de usuario de Internet



