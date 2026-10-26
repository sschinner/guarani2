CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_cerrar_rectific') THEN
		DROP PROCEDURE sp_cerrar_rectific;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version Alfa 6.0
-- Ultima Modificacion: Version 1.8, 1.11.0, 2.01.0, 2.6.0, 2.6.2
--
-- Procedure sp_cerrar_rectific
-- Cierra un acta rectificativa de Examen.
-- *******************************************************************************
-- U820 Se personaliza para no tener que reimprimir la ultima versión del acta antes de cerrarla
-- *******************************************************************************
CREATE PROCEDURE "dba".sp_cerrar_rectific (
	p_unidad_academica like sga_actas_examen.unidad_academica,
	p_tipo_acta like sga_actas_examen.tipo_acta,
	p_acta like sga_actas_examen.acta)

	DEFINE v_acta_referencia like sga_actas_examen.acta_referencia;
	DEFINE v_carrera like sga_detalle_acta.carrera;
	DEFINE v_legajo like sga_detalle_acta.legajo;
	DEFINE v_fecha like sga_detalle_acta.fecha_de_examen;
	DEFINE v_tipo_acta like sga_actas_examen.tipo_acta;
	DEFINE v_acta like sga_actas_examen.acta;
	DEFINE vcParam	LIKE sga_param_sistema.parametro;
	DEFINE v_registra_examen LIKE sga_param_sistema.valor;

	-- Errores
	DEFINE sql_err , isam_err integer;
	DEFINE error_info varchar(76);

BEGIN
	-- Lee la materia del acta y el numero del acta original
	SELECT acta_referencia
	  INTO v_acta_referencia
	  FROM sga_actas_examen
	 WHERE unidad_academica = p_unidad_academica
	   AND tipo_acta = p_tipo_acta
	   AND acta = p_acta ;

	  -- Controlo si debe estar el Acta impresa con Notas firmada por el Docente (estado = N).
	   EXECUTE PROCEDURE sp_param_sistema('docente_firma_acta_examen_con_notas') INTO vcParam;
	   IF vcParam = 'S' or vcParam = 's' THEN
		IF  (SELECT sga_actas_examen.estado  FROM sga_actas_examen
		                WHERE sga_actas_examen.unidad_academica = p_unidad_academica
               	 		  AND sga_actas_examen.tipo_acta = p_tipo_acta
		                  AND sga_actas_examen.acta = p_acta)  <> 'N' THEN
			raise exception -746,0,'El Docente debe firmar el Acta impresa con Notas antes de cerrarla.';
		END IF;
	   END IF;

	-- Examenes equivalentes en otras carreras
	EXECUTE PROCEDURE sp_param_sistema('examen_vale_en_todas_las_carreras') INTO v_registra_examen;
	IF v_registra_examen IS NULL OR TRIM(v_registra_examen) = '' THEN
		raise exception -746,0,'Error. Falta cargar Parametro (examen_vale_en_todas_las_carreras)' ;	
	END IF;

-- U820 ***************************************************************
-- Se personaliza para no tener que reimprimir la ultima versión del acta antes de cerrarla
-- U820 ***************************************************************
--MODIFICACION PARA LA VERSION 2.6.2 QUE CONTROLE SI EL CIERRE DE ACTA RECTIFICATIVA NO ESTA IMPRESA ANTES DE CERRARLA
  --verifica que el acta este impresa con su version y version impresa
     IF EXISTS ( SELECT '' FROM sga_actas_examen
                           WHERE sga_actas_examen.unidad_academica = p_unidad_academica
                                 AND sga_actas_examen.tipo_acta = p_tipo_acta
                                 AND sga_actas_examen.acta = p_acta 
			AND sga_actas_examen.estado in ('I', 'N') 
			AND sga_actas_examen.version_impresa <> sga_actas_examen.version) THEN
	                         -- AND sga_actas_examen.version_impresa <> sga_actas_examen.version ) THEN

                  raise exception  -746, 0, 'Para cerrar el acta, debe estar abierta y con la ultima version impresa.';
    END IF;


BEGIN
 ON EXCEPTION SET sql_err, isam_err, error_info                                        
	ROLLBACK WORK;
	raise exception  sql_err, isam_err, error_info;
 END EXCEPTION;                 

 BEGIN WORK;

	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Para cada registro del acta rectificativa, identifica el acta en la cual
	-- se encuentra el registro activo a rectificar
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	FOREACH
		SELECT sga_detalle_acta.carrera,
		       sga_detalle_acta.legajo
		  INTO v_carrera,
		       v_legajo 
		  FROM sga_detalle_acta  -- Los detalles del acta rectificativa
		 WHERE sga_detalle_acta.unidad_academica = p_unidad_academica
		   AND sga_detalle_acta.tipo_acta = p_tipo_acta
		   AND sga_detalle_acta.acta = p_acta

		-- sga_detalle_acta.plan, sga_detalle_acta.version, sga_detalle_acta.tipo_inscripcion
		-- v_plan,v_version, vn_tipo_inscrip


		BEGIN
			-- Identifica el acta en la cual se encuentra el registro activo a rectificar
			SELECT vw_sga_actas.tipo_acta,      vw_sga_actas.acta 
			  INTO v_tipo_acta,       v_acta 
			  FROM sga_actas_examen,  -- El acta rectificativa, para identificar el acta original
			       vw_sga_actas       -- El detalle del acta en el estado anterior a la rectificacion
			 WHERE sga_actas_examen.unidad_academica = p_unidad_academica
			   AND sga_actas_examen.tipo_acta = p_tipo_acta
			   AND sga_actas_examen.acta = p_acta
			   AND sga_actas_examen.unidad_academica = vw_sga_actas.unidad_academica
			   AND sga_actas_examen.acta_referencia = vw_sga_actas.acta_original
			   AND vw_sga_actas.carrera = v_carrera
			   AND vw_sga_actas.legajo = v_legajo
			   AND NOT (vw_sga_actas.unidad_academica = p_unidad_academica
			        AND vw_sga_actas.tipo_acta = p_tipo_acta
			        AND vw_sga_actas.acta = p_acta);

--			       vw_sga_actas.tipo_inscripcion
--			       vo_tipo_inscrip
--			   AND vw_sga_actas.tipo_original = sga_actas_examen.tipo_referencia

			-- Marca los registros originales como rectificados
			UPDATE sga_detalle_acta
			   SET rectificado = 'S'
			 WHERE unidad_academica = p_unidad_academica
			   AND tipo_acta = v_tipo_acta
			   AND acta = v_acta
			   AND carrera = v_carrera
			   AND legajo = v_legajo ;

			-- Esta parte solo podria afectar a la forma de aprobacion de la materia
			-- (por ahora no se distinguen los libres de los regulares, ni se marcan
			-- las equivalencias parciales)
--			IF vn_tipo_inscrip <> vo_tipo_inscrip OR
--			   vn_eqiv_parcial <> vo_eqiv_parcial THEN
--			END IF ;

		END;
	END FOREACH ;


	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Examenes equivalentes en otras carreras
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	IF v_registra_examen = 'S' THEN
	  -- Recupero los Examenes Aprobados y Reprobados
	   -- Los detalles del acta rectificativa
	  FOREACH SELECT carrera,legajo, fecha_de_examen 
		  INTO v_carrera,v_legajo , v_fecha
		  FROM sga_detalle_acta 
		 WHERE unidad_academica = p_unidad_academica
		   AND tipo_acta = p_tipo_acta
		   AND acta = p_acta
		   AND resultado  IN ('A','R')

		-- Inserto los Examenes Equivalentes en otras carreras.
		EXECUTE PROCEDURE sp_u_examen_equiv (p_unidad_academica, v_carrera, v_legajo, v_fecha, p_tipo_acta, p_acta, 'I');

	  END FOREACH;
	END IF;  -- Examenes equivalentes.


	-- Agrego los folios del Acta.
	EXECUTE PROCEDURE sp_i_folioactaexam(p_unidad_academica, p_tipo_acta, p_acta );

	-- Actualizo la fecha de fin de vigencia de la regularidad de las regularidades de los alumnos del Acta de Examen.
	EXECUTE PROCEDURE sp_finvigreg_acta(p_unidad_academica, p_tipo_acta, p_acta) ;


	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Cambia el estado del acta por 'C', Cerrada
	-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	UPDATE sga_actas_examen
	   SET estado = 'C',
	       fecha_cierre = Current year to Second
	 WHERE unidad_academica = p_unidad_academica
	   AND tipo_acta = p_tipo_acta
	   AND acta = p_acta ;


 COMMIT WORK;
END;

END;
END PROCEDURE;
-- ********************** Fin del procedure sp_cerrar_rectific ***********************

revoke execute on sp_cerrar_rectific from public;

grant execute on sp_cerrar_rectific to guarani; -- Rol de usuarios de Gestión
grant execute on sp_cerrar_rectific to internet; -- Usuario de internet