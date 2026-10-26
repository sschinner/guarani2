CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_validar_acta') THEN
		DROP PROCEDURE sp_validar_acta;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version Alfa 1.1
-- Modificado : Version 1.9
--
-- Procedure sp_validar_acta
-- Verifica si un acta esta en condiciones de ser cerrada
-- U820 Se personaliza para no tener que reimprimir la ultima versión del acta antes de cerrarla
-- *******************************************************************************
CREATE PROCEDURE "dba".sp_validar_acta(
			p_unidad_academica like sga_versiones_plan.unidad_academica,
			p_tipo_acta like sga_detalle_acta.tipo_acta,
			p_acta like sga_detalle_acta.acta)

DEFINE fecha_mesa LIKE sga_prestamos.fecha;
DEFINE vParNUA	LIKE sga_nua.nua;
DEFINE vActaNUA	LIKE sga_nua.nua;
DEFINE vcParam	LIKE sga_param_sistema.parametro;

BEGIN
   -- Verifica que la fecha del examen sea menor o igual a la Fecha Actual, sino no permito cerrar el Acta
	LET fecha_mesa = TODAY;
	SELECT sga_prestamos.fecha
		INTO fecha_mesa
		FROM sga_actas_examen, sga_llamados_mesa, sga_prestamos	
		WHERE sga_actas_examen.unidad_academica = p_unidad_academica
		AND sga_actas_examen.tipo_acta = p_tipo_acta
		AND sga_actas_examen.acta = p_acta 
		AND sga_actas_examen.unidad_academica = sga_llamados_mesa.unidad_academica
		AND sga_actas_examen.materia = sga_llamados_mesa.materia
		AND sga_actas_examen.anio_academico = sga_llamados_mesa.anio_academico
		AND sga_actas_examen.turno_examen = sga_llamados_mesa.turno_examen
		AND sga_actas_examen.mesa_examen = sga_llamados_mesa.mesa_examen
		AND sga_actas_examen.llamado = sga_llamados_mesa.llamado
		AND sga_llamados_mesa.prestamo = sga_prestamos.prestamo;

	IF fecha_mesa > TODAY  THEN
		raise exception  -746, 0, 'No puede cerrar el Acta antes de la Fecha del Examen (' ||  DAY(fecha_mesa) || '/' || MONTH(fecha_mesa) || '/' || YEAR(fecha_mesa) || ')';
	END IF;

	-- Controlo si debe estar el Acta firmada con Notas.
	EXECUTE PROCEDURE sp_param_sistema('docente_firma_acta_examen_con_notas') INTO vcParam;
	IF vcParam = 'S' or vcParam = 's' THEN
		IF  (SELECT sga_actas_examen.estado
				FROM sga_actas_examen
					WHERE sga_actas_examen.unidad_academica = p_unidad_academica
                	AND sga_actas_examen.tipo_acta = p_tipo_acta
	                AND sga_actas_examen.acta = p_acta)  <> 'N' THEN
			raise exception -746,0,'El Docente debe firmar el Acta impresa con Notas antes de cerrarla.';
		END IF;
	END IF;

   -- Verifica que este impresa, con o sin notas
   -- Si esta impresa con notas, verifica ademas que este impresa la ultima copia

-- U820 ***************************************************************
-- Se personaliza para no tener que reimprimir la ultima versión del acta antes de cerrarla
-- U820 ***************************************************************
	IF EXISTS ( SELECT ''
					FROM sga_actas_examen
					WHERE sga_actas_examen.unidad_academica = p_unidad_academica
					AND sga_actas_examen.tipo_acta = p_tipo_acta
					AND sga_actas_examen.acta = p_acta 
					AND sga_actas_examen.estado <> 'I'
					AND sga_actas_examen.estado <> 'N') THEN
		raise exception  -746, 0, 'Para cerrar el acta, debe estar abierta y con la ultima version impresa.';
	END IF;

   -- Verifica si la Materia tiene Condiciones de Aprobacion. Es por Partes.	
	IF (SELECT Count(*) 
			FROM sga_actas_examen, sga_cond_aprob
			WHERE sga_actas_examen.unidad_academica = p_unidad_academica
			AND sga_actas_examen.tipo_acta = p_tipo_acta
			AND sga_actas_examen.acta = p_acta 
			AND sga_cond_aprob.unidad_academica = sga_actas_examen.unidad_academica 
			AND sga_cond_aprob.materia = sga_actas_examen.materia ) = 0 THEN
	-- La Materia no es por Partes. NO TIENE CONDICIONES DE APROBACION.
    -- Verifica que, si el examen no es rendido por partes, este la nota 1
		IF EXISTS ( SELECT ''
						FROM sga_detalle_acta
						WHERE sga_detalle_acta.unidad_academica = p_unidad_academica
						AND sga_detalle_acta.tipo_acta = p_tipo_acta
						AND sga_detalle_acta.acta      = p_acta 
						AND ( sga_detalle_acta.resultado IS NULL OR (sga_detalle_acta.nota IS NULL AND sga_detalle_acta.resultado <> 'U'))  ) THEN
			raise exception  -746, 0, 'Falta cargar el resultado o la nota de algun examen.';
		END IF;
	ELSE	
    -- La Materia TIENE condiciones de Aprobacion. Es por Partes
    -- Verifica que, si el examen es rendido por partes, haya al menos una nota. Si el alumno estuvo
    -- ausente, entonces la nota debe estar en NULL
		IF EXISTS ( SELECT ''
						FROM sga_detalle_acta
						WHERE sga_detalle_acta.unidad_academica = p_unidad_academica
						AND sga_detalle_acta.tipo_acta = p_tipo_acta
						AND sga_detalle_acta.acta = p_acta 
						AND ( sga_detalle_acta.resultado IS NULL OR (sga_detalle_acta.nota IS NULL AND sga_detalle_acta.resultado <> 'U')) 
						AND ( sga_detalle_acta.resultado_2 IS NULL
						OR (sga_detalle_acta.nota_2 IS NULL AND sga_detalle_acta.resultado_2 <> 'U')) ) THEN
			raise exception  -746, 0, 'No está cargado el resultado o la nota de algun examen.';
		END IF;
	END IF;

   -- Si se usa NUA (Número único de aprobación), verifica que es número esté generado antes de cerrar el acta

	EXECUTE PROCEDURE sp_param_sistema('NUA') INTO vParNUA;
	IF vParNUA = 'S' THEN
		SELECT NUA
			INTO vActaNUA
			FROM sga_actas_examen
			WHERE sga_actas_examen.unidad_academica = p_unidad_academica
			AND sga_actas_examen.tipo_acta = p_tipo_acta
			AND sga_actas_examen.acta = p_acta;

		IF vActaNUA IS NULL THEN
			raise exception  -746, 0, 'Para ser cerrada, el acta debe tener su NUA';
		END IF;
	END IF;
END;
END PROCEDURE;

-- ********************** Fin del procedure sp_validar_acta **********************

revoke execute on sp_validar_acta from public;

grant execute on sp_validar_acta to guarani; -- Rol de usuarios de Gestión
grant execute on sp_validar_acta to internet; -- Usuario de internet