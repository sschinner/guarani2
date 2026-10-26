CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_ctr_recur') THEN
		DROP PROCEDURE sp820_ctr_recur;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


CREATE PROCEDURE "dba".sp820_ctr_recur ( pUnidadAcademica 	LIKE sga_alumnos.unidad_academica,
					   pCarrera 		LIKE sga_alumnos.carrera,
					   pLegajo  		LIKE sga_alumnos.legajo,
					   pComision 		LIKE sga_comisiones.comision,
						pMateriaCorrelativa LIKE sga_materias.materia,
						pCondRegular integer)
	RETURNING 	smallint,       -- status
			varchar(255);   -- <mensaje, parametros>

  /*  controla el Alumno Cursa Vertical.
       devuelve:  1 - si esta OK            Regular o Aprobado la correlativa dentro de los 3 años
             -1 - en otro caso       Ni Regular o NI Aprobado la correlativa dentro de los 3 años
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
     LET vcMsg = '800321' || ',' || 'sp820_ctr_recur' || ',' || sql_err || ' - '  || error_info ;  
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



-- SELECT com.carrera, com.nombre, com.turno, com.materia, doc.legajo Into vcCarrera, vcNombre, vcTurno, vcMateria, vc_legajo
SELECT com.carrera, com.nombre, com.turno, com.materia Into vcCarrera, vcNombre, vcTurno, vcMateria
   FROM sga_comisiones com
	--left join sga_docentes_com doc
	--on com.comision = doc.comision
   WHERE com.comision = pComision;


-- Si tiene una cursada no vigente, de la materia que intenta cursar
-- En FADU el parámetro Recursar Regularizadas esta en: N con lo cual no se puede recursar una materia regularizada vigente
IF EXISTS (Select '*' from sga_det_acta_curs det
		join sga_actas_cursado act
			on det.acta = act.acta
		join sga_comisiones com
			on act.comision = com.comision
	where com.materia = vcMateria

	AND (
		(det.fin_vigencia_regul < today OR ((year(today)-com.anio_academico) > 3)) -- Comprobar Vigencia ó HACER DIF. DE 3 AÑOS
		OR
		(det.cond_regularidad = pCondRegular OR (pCondRegular = 0 and det.resultado not in ('P', 'A'))) -- Condicion
	)
	and det.legajo = plegajo) THEN

	LET iStatus  = 1; 
	LET vcMsg  = 'OK';
ELSE 
	LET iStatus  = -1;
	LET vcMsg  =  '82012001';
END IF;

			

RETURN iStatus, vcMsg; 

END;
END PROCEDURE;

-- *************** Fin del procedimiento "dba".sp820_ctr_recur ******************

-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
revoke execute on "dba".sp820_ctr_recur from public;
grant execute on "dba".sp820_ctr_recur to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_ctr_recur to internet; -- Rol de usuario de Internet

{
 select * from sga_comisiones where anio_academico = 2017 and materia = 'A0301' and periodo_lectivo = '2° cuatrimestre';
-- Quiere cursar A0301:

EXECUTE PROCEDURE "dba".ctr820_cursvertica ('FADU', '1', '40774229-8', 7736); -- NO
EXECUTE PROCEDURE "dba".ctr820_cursvertica ('FADU', '1', '40774229-8', 7766); -- NO
EXECUTE PROCEDURE "dba".ctr820_cursvertica ('FADU', '1', '43113115-3', 9058); -- SI

}
