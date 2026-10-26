-- U820 ***********************************************************************************************************************
-- El control es para alumnos que hayan obtenido una condición de regularidad "Coloquio Final"
-- En ese caso, no permite la inscripción a examen, ya que el alumno tiene pendiente realizar el coloquio final
-- Una vez realizado el coloqui final, la condición de regularidad se rectifica y se coloca lo que corresponde: Promoción Pendiente ó Regular
-- U820 ***********************************************************************************************************************

CREATE PROCEDURE "dba".verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR CONTINUO

ON EXCEPTION 
END EXCEPTION WITH RESUME;


-- El control esta asociado al Punto de Control Nro 10 (Alumno - Mesa)

insert into par_implem_control (stored_procedure, parametros) values ("ctr820_coloquiofin", "s,s,s,s,n,s,s,n,s");

insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (8200401, "ctr820_coloquiofin", "Controla Regularidad Coloquio Final", "Controla Regularidad Coloquio Final", null);

insert into par_cont_x_punto (punto_de_control, control) values (10, 8200401);

execute procedure sp_confcont_cont (10, 8200401);
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_datos();
DROP PROCEDURE "dba".verifica_datos();


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_coloquiofin') THEN
		DROP PROCEDURE ctr820_coloquiofin;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

CREATE PROCEDURE "dba".ctr820_coloquiofin ( pUnidadAcademica 	LIKE sga_alumnos.unidad_academica,
					   pCarrera 		LIKE sga_alumnos.carrera,
					   pLegajo  		LIKE sga_alumnos.legajo,
					   pMateria 		LIKE sga_materias.materia,
					pAnioAcademico		LIKE sga_anio_academico.anio_academico,
					pTurnoExamen LIKE sga_turnos_examen.turno_examen,
					pMesaExamen LIKE sga_mesas_examen.mesa_examen,
					pllamadoExamen LIKE sga_llamados_mesa.llamado,
					pTipoInsc LIKE sga_insc_examen.tipo_inscripcion)
	RETURNING 	smallint,       -- status
			varchar(255);   -- <mensaje, parametros>

  /*  controla si el Alumno tiene pendiente Coloquio Final.
       devuelve:  1 - si esta OK           
             -1 - en otro caso      
  */

  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 	integer;
   DEFINE error_info 	varchar(76);

   DEFINE vcUserError	varchar(10);


   -- variables locales


-- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'ctr820_coloquiofinal' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        


BEGIN
   -- seteo los valores default
   LET iStatus		= 1 ;
   LET vcMsg		= 'OK';


IF EXISTS (   SELECT '*'  
     FROM sga_cursadas cur
    WHERE cur.unidad_academica      = pUnidadAcademica
      AND cur.carrera               = pCarrera  
      AND cur.legajo                = pLegajo   
      AND cur.materia               = pMateria
      AND cur.cond_regularidad = 12
      AND cur.fin_vigencia_regul   >= TODAY )

THEN

	LET iStatus  = -1; 
	LET vcMsg  =  '82004001' ;

END IF;
 
RETURN iStatus, vcMsg; 
END;
END PROCEDURE;
-- ************************ Fin Control "dba".ctr820_coloquiofin ***********************

-- execute PROCEDURE "dba".ctr820_coloquiofin ( 'FICH', '03',  '3342455-3', 'IF032', 2013, 'pTurnoExamen', 'pMesaExamen', 1, 'R');

-- *****************************************************************************
-- Permisos del control "dba".ctr820_coloquiofin 
-- *****************************************************************************
revoke execute on "dba".ctr820_coloquiofin from public;
grant execute on "dba".ctr820_coloquiofin to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_coloquiofin to internet; -- Rol de usuario de Internet