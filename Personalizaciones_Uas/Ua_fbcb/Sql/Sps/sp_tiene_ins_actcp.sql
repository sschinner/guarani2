CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_tiene_ins_actcp') THEN
		DROP PROCEDURE sp_tiene_ins_actcp;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.7.0, 2.8.0
-- Procedure sp_tiene_ins_actcp
-- Llamado desde el sp de cambio de plan
-- Retorna 1 si el alumno puede cambiarse de plan
--	-1 si tiene actividad no coherente con el plan nuevo

-- Si tiene alguna inscipcion o figura en actas de una materia que no pertenece
-- la plan nuevo, no puede cambiarse
-- U820 No se consideran inscripciones que se encuentren pendientes, para poder cambiarlo de plan (tanto de cursadas como de exámenes)
-- *****************************************************************************

CREATE PROCEDURE "dba".sp_tiene_ins_actcp(punidad_academica LIKE sga_alumnos.unidad_academica, pCarrera like sga_alumnos.carrera, plegajo like sga_alumnos.legajo, pplan like sga_alumnos.plan) 
	RETURNING smallint, --codigo
			varchar(255); --vcMensaje;



DEFINE vi_comision  INTEGER;
DEFINE vi_no_esta  INTEGER;

DEFINE 	vdFecInscripcion	LIKE sga_insc_cursadas.fecha_inscripcion	;
DEFINE   vcCalidadInsc	LIKE sga_insc_cursadas.calidad_insc		;  
DEFINE 	vcMateriaGenerica	LIKE sga_insc_cursadas.materia_generica	;
DEFINE	vcPlan		LIKE sga_insc_cursadas.plan			; 
DEFINE	vcVersion		LIKE sga_insc_cursadas.version		; 
DEFINE	vcNroTransaccion	LIKE sga_insc_cursadas.nro_transaccion	; 
DEFINE	viInterfaz		LIKE sga_insc_cursadas.interfaz		; 
DEFINE	vcNroTransacBaja	LIKE sga_insc_cursadas.nro_transaccion	; 
DEFINE 	vdFecTopeBajaInsc	LIKE sga_insc_cursadas.fecha_inscripcion	;
DEFINE 	viCantidad integer;
DEFINE   vdtrans          DATETIME HOUR TO SECOND;


DEFINE vcMateria 		LIKE sga_insc_examen.materia;
DEFINE viAnioacademico 		LIKE sga_insc_examen.anio_academico;
DEFINE vcTurnoExamen 		LIKE sga_insc_examen.turno_examen;
DEFINE vcMesaExamen 		LIKE sga_insc_examen.mesa_examen;
DEFINE viLlamado 		LIKE sga_insc_examen.llamado;
DEFINE viInterfase		LIKE sga_insc_examen.interfaz;
DEFINE vctipoInscripcion	LIKE sga_insc_examen.tipo_inscripcion;  
DEFINE vcEquivParcial	LIKE sga_insc_examen.equiv_parcial	;
DEFINE viInterfaz2		LIKE sga_insc_examen.interfaz		; 
DEFINE vilistadoExamen	LIKE sga_insc_examen.listado_examen;	 


LET vi_no_esta = 0;


-- ACTAS DE CURSADO/PROMOCION ABIERTAS
FOREACH SELECT materia
		INTO vcmateria
		FROM sga_curs_pendiente, sga_comisiones
		WHERE sga_curs_pendiente.unidad_academica = punidad_academica
			AND sga_curs_pendiente.carrera = pCarrera
			AND sga_curs_pendiente.legajo = pLegajo
			AND sga_curs_pendiente.comision = sga_comisiones.comision

	IF NOT EXISTS (SELECT ''
			FROM sga_planes, sga_atrib_mat_plan
			WHERE sga_planes.unidad_academica = punidad_academica
				and sga_planes.carrera = pCarrera
				and sga_planes.plan = pplan
				and sga_atrib_mat_plan.materia = vcmateria
				and sga_planes.unidad_academica = sga_atrib_mat_plan.unidad_academica
				and sga_planes.carrera = sga_atrib_mat_plan.carrera
				and sga_planes.plan = sga_atrib_mat_plan.plan
				and sga_planes.version_actual = sga_atrib_mat_plan.version) THEN
				

		RETURN -1, 'En actas de cursado de materias que no están en el nuevo plan (' || vcmateria || ')';
	END IF

END FOREACH;

-- ACTAS DE EXAMEN ABIERTAS
FOREACH SELECT materia
		INTO vcmateria
		FROM sga_actas_examen sae, sga_detalle_acta sda
		WHERE sae.unidad_academica = sda.unidad_academica
			AND sae.tipo_acta = sda.tipo_acta
			AND sae.acta = sda.acta
			AND sae.estado='A'
			AND sda.unidad_academica = punidad_academica
			AND sda.carrera = pCarrera
			AND sda.legajo = pLegajo



	IF NOT EXISTS (SELECT ''
			FROM sga_planes, sga_atrib_mat_plan
			WHERE sga_planes.unidad_academica = punidad_academica
				and sga_planes.carrera = pCarrera
				and sga_planes.plan = pplan
				and sga_atrib_mat_plan.materia = vcmateria
				and sga_planes.unidad_academica = sga_atrib_mat_plan.unidad_academica
				and sga_planes.carrera = sga_atrib_mat_plan.carrera
				and sga_planes.plan = sga_atrib_mat_plan.plan
				and sga_planes.version_actual = sga_atrib_mat_plan.version) THEN
				

		RETURN -1, 'En actas de examen de materias que no están en el nuevo plan (' || vcmateria || ')';
	END IF


END FOREACH;


-- TRAMITES DE EQUIVALENCIAS ABIERTOS

FOREACH SELECT materia
	INTO vcmateria
    FROM dba.sga_equiv_operac,
         dba.sga_equiv_otorgada,
         dba.sga_carreras

   WHERE dba.sga_equiv_otorgada.operacion_equiv = dba.sga_equiv_operac.operacion_equiv
     AND dba.sga_equiv_operac.estado = 'A'
     AND dba.sga_equiv_operac.tipo_equiv = 'N'
     AND dba.sga_equiv_otorgada.unidad_academica = punidad_academica
     AND dba.sga_equiv_otorgada.carrera = pCarrera
     AND dba.sga_equiv_otorgada.legajo  = pLegajo
     AND dba.sga_carreras.unidad_academica = dba.sga_equiv_otorgada.unidad_academica
     AND dba.sga_carreras.carrera = dba.sga_equiv_otorgada.carrera

	IF NOT EXISTS (SELECT ''
			FROM sga_planes, sga_atrib_mat_plan
			WHERE sga_planes.unidad_academica = punidad_academica
				and sga_planes.carrera = pCarrera
				and sga_planes.plan = pplan
				and sga_atrib_mat_plan.materia = vcmateria
				and sga_planes.unidad_academica = sga_atrib_mat_plan.unidad_academica
				and sga_planes.carrera = sga_atrib_mat_plan.carrera
				and sga_planes.plan = sga_atrib_mat_plan.plan
				and sga_planes.version_actual = sga_atrib_mat_plan.version) THEN
				

		RETURN -1, 'En trámite de equiv. de materias que no están en el nuevo plan (' || vcmateria || ')';
	END IF

END FOREACH;		

-- INSCRIPCIONES A CURSADAS QUE NO ESTAN EN ACTAS
-- No se tiene en cuenta si la inscripción esta o no en actas
/*
FOREACH SELECT sga_comisiones.comision, sga_comisiones.materia
 		into vi_comision, vcmateria
		FROM sga_insc_cursadas, sga_comisiones
		WHERE sga_insc_cursadas.unidad_academica = punidad_academica
			AND sga_insc_cursadas.carrera = pCarrera
			AND sga_insc_cursadas.legajo = pLegajo
			AND sga_insc_cursadas.comision = sga_comisiones.comision

			-- U820 No se consideran inscripciones que se encuentren pendientes
			AND sga_insc_cursadas.estado <> 'P'

	LET vi_no_esta = 0;

	-- EN ACTAS DE CURSADO CERRADAS
	IF EXISTS (SELECT ' '
			FROM sga_actas_cursado sac, sga_det_acta_curs sdac
			where sac.unidad_academica = sdac.unidad_academica
				AND sac.acta = sdac.acta
				AND sac.estado IN ('C','B')
				AND sac.comision = vi_comision
				AND sdac.unidad_academica = pUnidad_academica
				AND sdac.carrera = pCarrera
				AND sdac.legajo = pLegajo ) THEN

		LET vi_no_esta = 1;

	END IF;

	-- EN ACTAS DE PROMOCION CERRADAS
	IF EXISTS (SELECT ' '
			FROM sga_actas_promo sap, sga_det_acta_promo sdap
			where sap.unidad_academica = sdap.unidad_academica
				AND sap.acta = sdap.acta
				AND sap.estado IN ('C','B')
				AND sap.comision = vi_comision
				AND sdap.unidad_academica = pUnidad_academica
				AND sdap.carrera = pCarrera
				AND sdap.legajo = pLegajo ) THEN

		LET vi_no_esta = 1;

	END IF;


	IF vi_no_esta = 0 THEN

	IF NOT EXISTS (SELECT ''
			FROM sga_planes, sga_atrib_mat_plan
			WHERE sga_planes.unidad_academica = punidad_academica
				and sga_planes.carrera = pCarrera
				and sga_planes.plan = pplan
				and sga_atrib_mat_plan.materia = vcmateria
				and sga_planes.unidad_academica = sga_atrib_mat_plan.unidad_academica
				and sga_planes.carrera = sga_atrib_mat_plan.carrera
				and sga_planes.plan = sga_atrib_mat_plan.plan
				and sga_planes.version_actual = sga_atrib_mat_plan.version) THEN
				

		RETURN -1, 'Insc. a cursadas en materias que no están en el nuevo plan (' || vcmateria || ')';
	END IF

	END IF;
	

END FOREACH;
*/



-- INSCRIPCIONES A EXAMENES QUE NO ESTAN EN ACTAS

FOREACH SELECT Materia, Anio_academico, Turno_Examen, Mesa_Examen, Llamado, fecha_inscripcion, tipo_inscripcion, materia_generica,
	  equiv_parcial, nro_transaccion, interfaz, listado_examen 
	INTO vcMateria, viAnioacademico, vcTurnoExamen, vcMesaExamen, viLlamado, vdFecInscripcion, vcTipoInscripcion, vcMateriaGenerica,
	  vcEquivParcial, vcNroTransaccion, viInterfaz, vilistadoexamen
		FROM sga_insc_examen sie
		WHERE sie.unidad_academica = pUnidad_academica
			AND sie.carrera = pCarrera
			AND sie.legajo = pLegajo
			AND NOT EXISTS ( SELECT ' '
						FROM sga_actas_examen sae, sga_detalle_acta sda
						WHERE sae.unidad_academica = sda.unidad_academica
							AND sae.tipo_acta = sda.tipo_acta
							AND sae.acta = sda.acta
							AND sae.unidad_academica = sie.unidad_academica
							AND sae.materia = sie.materia
							AND sae.anio_academico = sie.anio_academico
							AND sae.turno_examen = sie.turno_examen
							AND sae.llamado = sie.llamado
							AND sda.unidad_academica = sie.unidad_academica
							AND sda.carrera = sie.carrera
							AND sda.legajo = sie.legajo)
			-- U820 No se consideran inscripciones que se encuentren pendientes
			AND sie.estado <> 'P'

 IF NOT EXISTS (SELECT ''
   FROM sga_planes, sga_atrib_mat_plan
   WHERE sga_planes.unidad_academica = punidad_academica
    and sga_planes.carrera = pCarrera
    and sga_planes.plan = pplan
    and sga_atrib_mat_plan.materia = vcmateria
    and sga_planes.unidad_academica = sga_atrib_mat_plan.unidad_academica
    and sga_planes.carrera = sga_atrib_mat_plan.carrera
    and sga_planes.plan = sga_atrib_mat_plan.plan
    and sga_planes.version_actual = sga_atrib_mat_plan.version)  THEN

       -- Verifico si la tiene aprobada  
    IF NOT EXISTS (SELECT ''
   FROM vw_hist_academica
   WHERE unidad_academica = Unidad_academica
   and carrera = pCarrera
   and legajo  = pLegajo
   and materia = vcMateria 
   and resultado='A') THEN
    

  RETURN -1, 'Insc. a exámenes de materias que no están en el nuevo plan (' || vcmateria || ')';
   END IF;
 END IF;


END FOREACH;

-- si llegó hasta aca no está en ningun lado
RETURN 1,'Ok';

END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_tiene_ins_actcp ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_tiene_ins_actcp 
-- *****************************************************************************
revoke execute on "dba".sp_tiene_ins_actcp from public;
grant execute on "dba".sp_tiene_ins_actcp to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_tiene_ins_actcp to internet; -- Rol de usuario de Internet

-- *************************** Pruebas de ejecucion **********************************
-- execute procedure "dba".sp_tiene_ins_actcp ('ESS', '07006', '39028347-7', '2013'); 
-- execute procedure "dba".sp_cambioplanCPV('ESS', '07006', '39028347-7', 'CD 1137', 'P');


