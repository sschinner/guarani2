DROP PROCEDURE "dba".spu_perdidas_regul;
CREATE PROCEDURE "dba".spu_perdidas_regul(

       o_unidad_academica like sga_perdidas_regul.unidad_academica,

       o_carrera like sga_perdidas_regul.carrera,

       o_legajo like sga_perdidas_regul.legajo,

       o_anio_academico like sga_perdidas_regul.anio_academico,

       o_perdida_regul like sga_perdidas_regul.perdida_regul,

       o_fecha_baja like sga_perdidas_regul.fecha_baja,

       o_nro_resol_baja like sga_perdidas_regul.nro_resol_baja,

       o_anio_rehab like sga_perdidas_regul.anio_rehab,

       o_fecha_rehab like sga_perdidas_regul.fecha_rehab,

       o_nro_resol_rehab like sga_perdidas_regul.nro_resol_rehab,

       o_fecha_vencim_reh like sga_perdidas_regul.fecha_vencim_rehab,

       o_tipo_rehab like sga_perdidas_regul.tipo_rehab,

       o_contabiliza like sga_perdidas_regul.contabiliza,

       n_unidad_academica like sga_perdidas_regul.unidad_academica,

       n_carrera like sga_perdidas_regul.carrera,

       n_legajo like sga_perdidas_regul.legajo,

       n_anio_academico like sga_perdidas_regul.anio_academico,

       n_perdida_regul like sga_perdidas_regul.perdida_regul,

       n_fecha_baja like sga_perdidas_regul.fecha_baja,

       n_nro_resol_baja like sga_perdidas_regul.nro_resol_baja,

       n_anio_rehab like sga_perdidas_regul.anio_rehab,

       n_fecha_rehab like sga_perdidas_regul.fecha_rehab,

       n_nro_resol_rehab like sga_perdidas_regul.nro_resol_rehab,

       n_fecha_vencim_reh like sga_perdidas_regul.fecha_vencim_rehab,

       n_tipo_rehab like sga_perdidas_regul.tipo_rehab,

       n_contabiliza like sga_perdidas_regul.contabiliza)

BEGIN

   -------------------------------------------------------------------------------- 

   -- Impide que se modifique la clave primaria de un registro 

   -------------------------------------------------------------------------------- 

   IF o_unidad_academica <> n_unidad_academica OR

      o_carrera <> n_carrera OR

      o_legajo <> n_legajo OR

      o_anio_academico <> n_anio_academico OR

      o_perdida_regul <> n_perdida_regul  THEN

      raise exception -746,0,'No se puede modificar la clave primaria de un registro.';

   END IF;

   

	-- *************************************************************************

	-- Verifico que la fecha de readmisión no sea menor a la ultima fecha de 

	-- perdida de regularidad.

	-- *************************************************************************



	IF n_fecha_baja > n_fecha_rehab THEN 

		raise exception -746, 0, 'La fecha de readmisión es menor a la de pérdida de regularidad. ';

	END IF



	-- *************************************************************************

	-- Si se soluciona una pérdida de regularidad, controla que estén todos

	-- los datos obligatorios cargados

	-- *************************************************************************

	IF n_tipo_rehab IS NOT NULL THEN

		IF n_anio_rehab IS NULL OR

		   n_fecha_rehab IS NULL THEN

			raise exception -746, 0, 'Faltan datos sobre la solución de la pérdida de regularidad';

--			raise exception -746, 0, '800XX1'; -- Faltan datos sobre la solución de la pérdida de regularidad

		ELIF n_anio_academico <> n_anio_rehab and n_tipo_rehab NOT IN ( 'R' ,'P') THEN

			raise exception -746, 0, 'Solo las readmisiones admiten soluc. posteriores al año de pérdida de regul.';

--			raise exception -746, 0, '800XX5'; -- Solo las readmisiones admiten soluciones para años posteriores al de la pérdida de regularidad

		END IF;

	ELIF n_anio_rehab IS NOT NULL OR

	     n_fecha_rehab IS NOT NULL OR

	     n_fecha_vencim_reh IS NOT NULL OR

	     n_nro_resol_rehab IS NOT NULL THEN

		raise exception -746, 0, '800XX1 - Faltan datos sobre la solución de la pérdida de regularidad';

--		raise exception -746, 0, '800XX1'; -- Faltan datos sobre la solución de la pérdida de regularidad

	END IF;



	-- Si finalmente se soluciona una pérdida de regularidad

	IF n_tipo_rehab IS NOT NULL AND o_tipo_rehab IS NULL THEN

		-- Pasa el alumno a regular

		UPDATE sga_alumnos

		   SET regular = 'S'

		 WHERE sga_alumnos.unidad_academica = n_unidad_academica

		   AND sga_alumnos.carrera = n_carrera

		   AND sga_alumnos.legajo = n_legajo;



		IF n_contabiliza = 'S' THEN

			UPDATE sga_alumnos

			   SET cnt_readmisiones = cnt_readmisiones + 1

			 WHERE sga_alumnos.unidad_academica = n_unidad_academica

			   AND sga_alumnos.carrera = n_carrera

			   AND sga_alumnos.legajo = n_legajo;

		END IF;

	END IF;



   -- Carga la tabla de log para auditoria

   INSERT INTO log_perdidas_regul (

     unidad_academica,

     carrera,

     legajo,

     anio_academico,

     perdida_regul,

     fecha_baja,

     nro_resol_baja,

     anio_rehab,

     fecha_rehab,

     nro_resol_rehab,

     fecha_vencim_rehab,

     tipo_rehab,

     contabiliza,

     usuario,

     fecha_act,

     oper)

   VALUES (

     n_unidad_academica,

     n_carrera,

     n_legajo,

     n_anio_academico,

     n_perdida_regul,

     n_fecha_baja,

     n_nro_resol_baja,

     n_anio_rehab,

     n_fecha_rehab,

     n_nro_resol_rehab,

     n_fecha_vencim_reh,

     n_tipo_rehab,

     n_contabiliza,

     User,

     Current year to Second,

     'U');

end;

end procedure;
                                                                                                                                                       
