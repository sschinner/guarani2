CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'u820_exa_da006') THEN
		DROP PROCEDURE u820_exa_da006;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();


-- Procedimiento que devuelve si tiene los créditos necesarios, según genérica particular, para rendir la materia.
CREATE PROCEDURE "dba".u820_exa_da006(	v_unidad_acad	like sga_alumnos.unidad_academica,
				v_carrera		like sga_alumnos.carrera,
				v_legajo		like sga_alumnos.legajo,
				v_materia		like sga_actas_examen.materia,
				v_plan		like sga_alumnos.plan,
				v_version		like sga_actas_examen.version)
				
		returning smallint, varchar(255);

-- vars para la respuesta
DEFINE iStatus	smallint;
DEFINE vcMsg 		varchar(255);

-----  VARS PARA EL MANEJO DE EXCEPCIONES
DEFINE sql_err	 			integer;
DEFINE isam_err 				integer;
DEFINE error_info				varchar(76);

DEFINE vcTitulo LIKE sga_titulos.titulo;
DEFINE vcMateria LIKE sga_materias.materia;

DEFINE sResulProc char(1);
DEFINE sCreditos integer; -- Variable nueva de la versión 2.06 que devuelve los creditos de la materia generica


ON EXCEPTION SET sql_err, isam_err, error_info                                        
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'u820_exa_da006' || ',' || sql_err || ' - '  || error_info ; 	
     RETURN iStatus, vcMsg ;
   END EXCEPTION;       

BEGIN

LET sCreditos = 0;
LET vcMateria = 'DA004';
LET sResulProc = NULL;			
LET vcTitulo = NULL;	
LET iStatus = 1;
LET vcMsg = '800320' 	; 

-- Recupero el Titulo de Grado del Plan-Version
SELECT sga_orientaciones.titulo
	INTO vcTitulo
	FROM sga_orientaciones, sga_titulos
	WHERE sga_orientaciones.unidad_academica = v_unidad_acad
	AND sga_orientaciones.carrera = v_carrera
	AND sga_orientaciones.plan = v_plan
	AND sga_orientaciones.orientacion = '0'
	AND sga_orientaciones.unidad_academica = sga_titulos.unidad_academica
	AND sga_orientaciones.titulo = sga_titulos.titulo
	AND sga_titulos.nivel = 'GRADO';

	
	EXECUTE PROCEDURE sp_resultGenerica(v_unidad_acad, v_carrera, v_legajo, vcTitulo, '0', vcMateria) INTO sResulProc, sCreditos;
	IF sCreditos < 6 THEN
			let iStatus = -1;
			let vcMsg = '82012004';
	END IF;


1
RETURN iStatus, vcMsg ;

END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".u820_exa_da006 ******************

revoke execute on "dba".u820_exa_da006 from public;
grant execute on "dba".u820_exa_da006 to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".u820_exa_da006 to internet; -- Rol de usuario de Internet

-- EXECUTE PROCEDURE dba.u820_exa_da006("FADU", "00003", "18109161-1", "DA006", "2012", "1");

