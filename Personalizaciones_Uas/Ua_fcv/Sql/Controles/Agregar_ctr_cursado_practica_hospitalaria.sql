-- U820 ***********************************************************************************************************************
-- Controla si el Alumno tiene una inscripción a cursada vigente de Práctica Hospitalaria, y en consecuencia no lo deja inscribirse a otra materia.
-- Si la materia a la que me intento inscribir es Práctica -> Verifico que no tenga otras inscripciones (en Práctica u otras).
-- Si la materia a la que me intento inscribir no es Práctica -> Verifico que no tenga inscripcion en Práctica.
-- Verificar inscripción (como lo hago): Si el alumno esta en una (cursada pendiente Ó esta inscripto a cursar "Aceptado" Ó esta inscripto a cursar "Pendiente" y no finalizó el período de inscripción), -> tiene inscripción a cursada vigente.
-- U820 ***********************************************************************************************************************

CREATE PROCEDURE "dba".verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR CONTINUO

ON EXCEPTION 
END EXCEPTION WITH RESUME;

-- El control es sobre la persona
insert into par_implem_control (stored_procedure, parametros) values ("ctr820_practica_ho", "s,s,s,n");
insert into par_controles (control, stored_procedure, desc_abreviada, descripcion, param_adicionales) values (820026, "ctr820_practica_ho", "Controla Cursado de Práctica Hospitalaria", "Controla Cursado de Práctica Hospitalaria", null);
insert into par_cont_x_punto (punto_de_control, control) values (5, 820026);
execute procedure sp_confcont_cont (5, 820026);

END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_datos();
DROP PROCEDURE "dba".verifica_datos();


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_practica_ho') THEN
		DROP PROCEDURE ctr820_practica_ho;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


CREATE PROCEDURE "dba".ctr820_practica_ho ( pUnidadAcademica 	LIKE sga_alumnos.unidad_academica,
					   pCarrera 		LIKE sga_alumnos.carrera,
					   pLegajo  		LIKE sga_alumnos.legajo,
					   pComision 		LIKE sga_comisiones.comision)
	RETURNING 	smallint,       -- status
			varchar(255);   -- <mensaje, parametros>

  --  controla el Alumno Cursa Práctica Hospitalaria.
  --    devuelve:  1 - si esta OK            no cursa Práctica Hospitalaria
  --         -1 - en otro caso       cursa Práctica Hospitalaria
  

  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 	integer;
   DEFINE error_info 	varchar(76);

   DEFINE vcUserError	varchar(10);


   -- variables locales
DEFINE vcMateria like sga_comisiones.materia;

-- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'ctr820_practica_hosp' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        


BEGIN
   -- seteo los valores default
   LET vcMateria = NULL;
   LET iStatus		= 1 ;
   LET vcMsg		= 'OK';

-- Obtener la materia de la comisión
SELECT com.materia Into vcMateria
   FROM sga_comisiones com
	JOIN sga_periodos_lect per
		on com.anio_academico = per.anio_academico
		and com.periodo_lectivo = per.periodo_lectivo
	JOIN sga_fec_insc_cur fec
		on fec.anio_academico = per.anio_academico
		and fec.periodo_lectivo = per.periodo_lectivo 
   WHERE com.comision = pComision;

IF vcMateria IN ('10035', '10036') THEN
	IF EXISTS 
	(SELECT '*'
         FROM sga_alumnos,
               sga_insc_cursadas,
               sga_comisiones,
               sga_periodos_lect,
               sga_carreras,
               sga_planes,
               sga_atrib_mat_plan,
               par_interfaces,
               sga_sedes
         WHERE sga_alumnos.unidad_academica    = pUnidadAcademica
           AND sga_carreras.unidad_academica   = sga_alumnos.unidad_academica
           AND sga_carreras.carrera            = sga_alumnos.carrera
           AND sga_insc_cursadas.unidad_academica   = sga_alumnos.unidad_academica
           AND sga_insc_cursadas.carrera            = sga_alumnos.carrera
           AND sga_insc_cursadas.legajo             = sga_alumnos.legajo
           AND sga_insc_cursadas.comision           = sga_comisiones.comision
           AND sga_planes.unidad_academica  = sga_alumnos.unidad_academica
           AND sga_planes.carrera           = sga_alumnos.carrera
           AND sga_planes.plan              = sga_alumnos.plan
           AND sga_atrib_mat_plan.unidad_academica  = sga_planes.unidad_academica
           AND sga_atrib_mat_plan.carrera           = sga_planes.carrera
           AND sga_atrib_mat_plan.plan              = sga_planes.plan
           AND sga_atrib_mat_plan.version           = sga_planes.version_actual
           AND sga_atrib_mat_plan.materia           = sga_comisiones.materia
           AND sga_insc_cursadas.interfaz        = par_interfaces.interfaz
           AND sga_periodos_lect.anio_academico  = sga_comisiones.anio_academico
           AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo
           AND sga_comisiones.sede = sga_sedes.sede
           AND TODAY <= sga_periodos_lect.fecha_fin
           AND sga_alumnos.carrera = pCarrera
	   AND sga_alumnos.legajo = pLegajo
	   AND sga_insc_cursadas.comision <> pComision
	   AND sga_alumnos.carrera = '01'
	   AND sga_alumnos.plan = '2011'
               
	) THEN
		LET iStatus		= -1 ;
   		LET vcMsg		= '82002039';
	END IF;

ELSE
	IF EXISTS 
	(SELECT '*'
         FROM sga_alumnos,
               sga_insc_cursadas,
               sga_comisiones,
               sga_periodos_lect,
               sga_carreras,
               sga_planes,
               sga_atrib_mat_plan,
               par_interfaces,
               sga_sedes
         WHERE sga_alumnos.unidad_academica    = pUnidadAcademica
           AND sga_carreras.unidad_academica   = sga_alumnos.unidad_academica
           AND sga_carreras.carrera            = sga_alumnos.carrera
           AND sga_insc_cursadas.unidad_academica   = sga_alumnos.unidad_academica
           AND sga_insc_cursadas.carrera            = sga_alumnos.carrera
           AND sga_insc_cursadas.legajo             = sga_alumnos.legajo
           AND sga_insc_cursadas.comision           = sga_comisiones.comision
           AND sga_planes.unidad_academica  = sga_alumnos.unidad_academica
           AND sga_planes.carrera           = sga_alumnos.carrera
           AND sga_planes.plan              = sga_alumnos.plan
           AND sga_atrib_mat_plan.unidad_academica  = sga_planes.unidad_academica
           AND sga_atrib_mat_plan.carrera           = sga_planes.carrera
           AND sga_atrib_mat_plan.plan              = sga_planes.plan
           AND sga_atrib_mat_plan.version           = sga_planes.version_actual
           AND sga_atrib_mat_plan.materia           = sga_comisiones.materia
           AND sga_insc_cursadas.interfaz        = par_interfaces.interfaz
           AND sga_periodos_lect.anio_academico  = sga_comisiones.anio_academico
           AND sga_periodos_lect.periodo_lectivo = sga_comisiones.periodo_lectivo
           AND sga_comisiones.sede = sga_sedes.sede
           AND TODAY <= sga_periodos_lect.fecha_fin
           AND sga_comisiones.materia IN ('10035', '10036')
           AND sga_alumnos.carrera = pCarrera
	   AND sga_alumnos.legajo = pLegajo
	   AND sga_insc_cursadas.comision <> pComision
	   AND sga_alumnos.carrera = '01'
	   AND sga_alumnos.plan = '2011'
     
	) THEN

		LET iStatus		= -1 ;
   		LET vcMsg		= '82002039';
	END IF;
END IF;

RETURN iStatus, vcMsg; 

END;
END PROCEDURE;
-- ************************ Fin Control "dba".ctr820_practica_hosp ***********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".ctr820_practica_ho
-- *****************************************************************************
revoke execute on "dba".ctr820_practica_ho from public;
grant execute on "dba".ctr820_practica_ho to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".ctr820_practica_ho to internet; -- Rol de usuario de Internet

{

execute PROCEDURE "dba".ctr820_practica_ho ( 'FCV', '01',   '40046286-7', 6452); -- Ya esta inscripto en Pract. Hosp.: No puede insc. a PH
execute PROCEDURE "dba".ctr820_practica_ho ( 'FCV', '01',   '40046286-7', 6359); -- Ya esta inscripto en Pract. Hosp.: No puede insc. a otra materia
execute PROCEDURE "dba".ctr820_practica_ho ( 'FCV', '01',   '40046286-7', 6452); -- Ya esta inscripto en Otra Materia : No puede insc. a PH
execute PROCEDURE "dba".ctr820_practica_ho ( 'FCV', '03',   '27793242-8', 6453 ); -- No esta inscripto en ninguna Materia : Si puede insc. a PH

}
