CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_ctr_tur_r') THEN
		DROP PROCEDURE sp820_ctr_tur_r;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- execute procedure "dba".sp820_ctr_tur_r ()

CREATE PROCEDURE "dba".sp820_ctr_tur_r ( pUnidadAcademica 	LIKE sga_alumnos.unidad_academica,
					   pCarrera 		LIKE sga_alumnos.carrera,
					   pLegajo  		LIKE sga_alumnos.legajo,
					   pComision 		LIKE sga_comisiones.comision,
						pMateriaCorrelativa LIKE sga_materias.materia,
						pCondRegular integer)
	RETURNING 	smallint,       -- status
			varchar(255);   -- <mensaje, parametros>

  /*  controla el Alumno Cursa Vertical.
       devuelve:  1 - si esta OK            cursa Vertical
             -1 - en otro caso       no cursa Vertical
  */

  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 	integer;
   DEFINE error_info 	varchar(76);

   DEFINE vcUserError	varchar(10);


   -- variables locales

DEFINE vcNro_inscripcion like sga_alumnos.nro_inscripcion;
DEFINE vcCarrera like sga_comisiones.carrera;
DEFINE vcNombre like sga_comisiones.nombre;
DEFINE vcTurno, vcTurnoCurso like sga_comisiones.turno;
DEFINE vcMateria like sga_comisiones.materia;
DEFINE vc_legajo like sga_docentes_com.legajo;

-- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'sp820_ctr_tur_r' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        


BEGIN
   -- seteo los valores default
   LET iStatus		= -1 ;
   LET vcMsg		= '82012001';
   LET vcNro_inscripcion = NULL;
   LET vcCarrera = NULL;
   LET vcNombre = NULL;
   LET vcTurno = NULL;
   LET vcMateria = NULL;
   LET vc_legajo = NULL;
   LET vcTurnoCurso = NULL;



--SELECT com.carrera, com.nombre, trim(com.turno), com.materia, doc.legajo Into vcCarrera, vcNombre, vcTurno, vcMateria, vc_legajo
SELECT com.carrera, com.nombre, trim(com.turno), com.materia Into vcCarrera, vcNombre, vcTurno, vcMateria
   FROM sga_comisiones com
	--left join sga_docentes_com doc
	--on com.comision = doc.comision
   WHERE com.comision = pComision;

-- Mismo turno de la materia a la que intenta inscribirse.
	IF (vcTurno IN (Select com.turno 
		from sga_det_acta_curs det
			join sga_actas_cursado act
				on det.acta = act.acta
			join sga_comisiones com
				on act.comision = com.comision
			left join sga_docentes_com doc
				on com.comision = doc.comision
		where com.materia = pMateriaCorrelativa
		--and det.fin_vigencia_regul >= today -- No importa la vigencia
		-- and (det.cond_regularidad = pCondRegular OR (pCondRegular = 0 and det.resultado IN('P', 'A'))) -- Condicion
		and det.legajo = plegajo)) THEN
		
		LET iStatus  = 1; 
		LET vcMsg  = 'OK';

	ELSE -- No la curso en el mismo turno
		LET iStatus  = -1;
		LET vcMsg  =  '82012001';
	END IF;


RETURN iStatus, vcMsg; 

END;
END PROCEDURE;


-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_ctr_tur_r
-- *****************************************************************************
revoke execute on "dba".sp820_ctr_tur_r from public;
grant execute on "dba".sp820_ctr_tur_r to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_ctr_tur_r to internet; -- Rol de usuario de Internet



