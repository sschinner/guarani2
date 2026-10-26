-- U820 ***********************************************************************************************************************
-- El control es para alumnos que cursen en Paralelo las carreras de Analista e Ingeniería Industrial.
-- Verifica si la mesa la que se intenta inscribr un alumno que cursa Paralelo, es de Analista. 
-- En ese caso el control falla.
-- U820 ***********************************************************************************************************************

CREATE PROCEDURE "dba".verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR CONTINUO

ON EXCEPTION 
END EXCEPTION WITH RESUME;


-- El control esta asociado al Punto de Control Nro 10 (Alumno - Mesa)

-- update par_implem_control set parametros = "s,s,s,s,n,s,s,n,s" where stored_procedure = "ctr820_RindeParal";

insert into par_implem_control (stored_procedure, parametros) values ("ctr820_RindeParal", "s,s,s,s,n,s,s,n,s");

insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (820018, "ctr820_RindeParal", "Controla Cursado Paralelo Ing./An. Ind.", "Controla Cursado Paralelo Ing./An. Ind.", null);

insert into par_cont_x_punto (punto_de_control, control) values (10, 820018);
execute procedure sp_confcont_cont (10, 820018);

END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_datos();
DROP PROCEDURE "dba".verifica_datos();


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_rindeparal') THEN
		DROP PROCEDURE ctr820_rindeparal;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


CREATE PROCEDURE "dba".ctr820_RindeParal ( pUnidadAcademica 	LIKE sga_alumnos.unidad_academica,
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

  /*  controla el Alumno Cursa en paralelo Ing./An. Ind.
       devuelve:  1 - si esta OK            no cursa Paralelo
             -1 - en otro caso       cursa Paralelo
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


-- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'ctr820_RindeParal' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        


BEGIN
   -- seteo los valores default
   LET iStatus		= 1 ;
   LET vcMsg		= 'OK';
   LET vcNro_inscripcion = '';
   LET vcCarrera = '';



SELECT carrera Into vcCarrera
   FROM sga_mesas_examen 
   WHERE unidad_academica = pUnidadAcademica
	and materia = pMateria
	and anio_academico = pAnioAcademico
	and turno_examen = pTurnoExamen
	and mesa_examen = pMesaExamen;

SELECT nro_inscripcion Into vcNro_Inscripcion
  FROM sga_alumnos
  WHERE legajo = pLegajo and carrera = pCarrera;

IF EXISTS (select nro_inscripcion, count(*)
		from sga_alumnos
		where nro_inscripcion = vcNro_Inscripcion
			and carrera in ('00006', '00007')
			and calidad = 'A'
		group by nro_inscripcion
		having count(*) = 2) 
	AND vcCarrera = '00007' 
	THEN

	LET iStatus  = -1; 
	LET vcMsg  =  '82001017' || ',' || 'Analista/Ing. Industrial. ' || ',' || 'No podés inscribirte a una Mesa de Analista';

END IF;
 
RETURN iStatus, vcMsg; 
END;
END PROCEDURE;
-- ************************ Fin Control "dba".ctr820_RindeParal ***********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".ctr820_RindeParal
-- *****************************************************************************
revoke execute on "dba".ctr820_RindeParal from public;
grant execute on "dba".ctr820_RindeParal to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_RindeParal to internet; -- Rol de usuario de Internet