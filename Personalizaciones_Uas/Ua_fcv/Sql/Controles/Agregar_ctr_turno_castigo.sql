
CREATE PROCEDURE "dba".verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR CONTINUO

ON EXCEPTION 
END EXCEPTION WITH RESUME;

-- Controla si el Alumno figura como ausente en algun acta de la materia del turno anterior.!
-- El control esta asociado al Punto de Control Nro 10 (Alumno - Llamado - Mesa de Examen)

insert into par_implem_control (stored_procedure, parametros) values ("ctr_turnocastigo", 's,s,s,s,n,s,s,n,s');
insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (82007, "ctr_turnocastigo", "Controla Alumno NO Turno Castigo.", "Controla que el Alumno NO haya estado ausente en el Turno anterior.", null);
insert into par_cont_x_punto (punto_de_control, control) values (10, 82007);

EXECUTE PROCEDURE sp_confcont_cont (10, 82007);
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_datos();
DROP PROCEDURE "dba".verifica_datos();



-- **************************************************************************
-- Control: ctr_turnoCastigo
--
-- Controla si el Alumno tiene turno castigo!
--       devuelve:  1 - si esta OK         No Tiene 
--                 -1 - en otro caso       Tiene 
--
-- **************************************************************************

CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr_turnocastigo') THEN
		DROP PROCEDURE ctr_turnocastigo;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Creating procedure
CREATE PROCEDURE "dba".ctr_turnocastigo(pUnidadAcademica LIKE sga_alumnos.unidad_academica, pCarrera LIKE sga_alumnos.carrera,	pLegajo 		LIKE sga_alumnos.legajo, pMateria LIKE sga_mesas_examen.materia,	pAnioAcademico LIKE sga_mesas_examen.anio_academico, pTurnoExamen LIKE sga_mesas_examen.turno_examen, pMesaExamen LIKE sga_mesas_examen.mesa_examen, pLlamado LIKE sga_insc_examen.llamado, pTipoInscripcion LIKE sga_insc_examen.tipo_inscripcion)

	RETURNING 	smallint,       -- status
			varchar(255);   -- <mensaje, parametros>

  /*  controla el Alumno tiene o no turno castigo
       devuelve:  1 - si esta OK            no tiene turno castigo
             -1 - en otro caso       Tiene turno castigo
  */

  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 	integer;
   DEFINE error_info 	varchar(76);
   DEFINE vcUserError	varchar(10);


   -- variables locales
   DEFINE viCantAus integer;
   DEFINE vcAnioAcademico LIKE sga_mesas_examen.anio_academico;
   DEFINE vcTurnoExamen LIKE sga_mesas_examen.turno_examen;
   DEFINE vdFecha_fin  LIKE sga_turnos_examen.fecha_fin;

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'ctr_turnoCastigo' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN
   -- seteo los valores default
   LET iStatus		= 1 ;
   LET vcMsg		= 'OK';
   LET viCantAus  = 0;
   
-- ************************* Cálculo del turno Anterior ************************************************************
-- Se toma como turno anterior, aquel turno/s finalizado/s inmediatamente antes de turno de examen.
-- ********************************************************************************************************************


Select max(fecha_fin) Into vdFecha_fin
From sga_turnos_examen
Where fecha_fin < (select fecha_inicio 
			from sga_turnos_examen 
			where anio_academico = pAnioAcademico
			and turno_examen = pTurnoExamen);

Select anio_academico, turno_examen Into vcAnioAcademico, vcTurnoExamen
From sga_turnos_examen
Where fecha_fin = vdFecha_fin;


select count (*) Into viCantAus 
from sga_detalle_acta d 
	join sga_actas_examen a
	on d.acta = a.acta 
		and a.turno_examen = vcTurnoExamen 
		and a.anio_academico = vcAnioAcademico
where d.unidad_academica = punidadAcademica
	and d.carrera = pcarrera
	and d.legajo = plegajo
	and a.estado = 'C'
	and a.materia = pmateria
	and d.estado = 'A'
	and d.rectificado = 'N'
	and (d.resultado in ('U', '') Or d.resultado is Null);

IF viCantAus > 0 THEN
       -- Error. Tiene turno castigo.
       LET vcUserError  = '82002036';
       LET iStatus 	  = -1; 
       LET vcMsg 	  =  vcUserError || ',' || pMateria || ',' || pCarrera;
       RETURN iStatus, vcMsg; 

END IF;
 
RETURN iStatus, vcMsg; 
END;
END PROCEDURE;

-- ************************ Fin Control ctr_turnoCastigo ***********************

-- select d.*, a.materia from sga_detalle_acta d join sga_actas_examen a on d.acta = a.acta where a.turno_examen = 'Febrero' and d.resultado = 'U' order by d.legajo;
-- execute procedure ctr_turnoCastigo('FCE', '0201', '26369761-4', '5150', 2004, 'Agosto', 'A', 1, 'R');
-- execute procedure  mme_muestramensaje ( '820005, 1060, 0201');

revoke execute on "dba".ctr_turnocastigo from public;
grant execute on "dba".ctr_turnocastigo to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr_turnocastigo to internet; -- Rol de usuario de Internet