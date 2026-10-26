-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.10.0
-- Procedure sp_evalua_matriz
-- 
-- Ultima version de modificacion: 2.01.0, 2.6.4, 2.9.2 (devuelve el id del grupo de equivalencias)
-- *****************************************************************************
DROP PROCEDURE sp_evalua_matriz;
CREATE PROCEDURE sp_evalua_matriz(
	pUnidadAcademica   LIKE sga_alumnos.unidad_academica,
	pCarrera           LIKE sga_alumnos.carrera,
	pLegajo            LIKE sga_alumnos.legajo,
	pMatrizEquiv       LIKE sga_eqdef_matrices.matriz_equiv )

	RETURNING integer,           -- sga_eqdef_grupos.grupo_equiv
	          varchar(5),        -- sga_equiv_otorgada.materia
	          date,              -- sga_equiv_otorgada.fecha
	          char(1),           -- sga_equiv_otorgada.alcance
	          char(1),           -- sga_equiv_otorgada.resultado
	          integer,           -- sga_equiv_otorgada.escala_notas
	          varchar(5),        -- sga_equiv_otorgada.nota
	          date,              -- sga_equiv_otorgada.vencimiento
	          varchar(255),      -- sga_equiv_otorgada.temas_a_rendir
	          varchar(5),        -- sga_equiv_otorgada.plan
	          varchar(5),        -- sga_equiv_otorgada.version
	          varchar(5),        -- sga_equiv_relacion.carrera
	          varchar(15),       -- sga_equiv_relacion.legajo
	          varchar(5),        -- sga_equiv_relacion.materia
	          date,              -- sga_equiv_relacion.fecha
	          char(1);           -- sga_equiv_relacion.origen

	-- Variables locales
	DEFINE vNroInscripcion LIKE sga_alumnos.nro_inscripcion;
	DEFINE vUnidadAcademica LIKE sga_alumnos.unidad_academica;
	DEFINE vPlan LIKE sga_alumnos.plan;
	DEFINE vCarrera LIKE sga_alumnos.carrera;
	DEFINE vLegajo LIKE sga_alumnos.legajo;

	DEFINE vCarreraOrigenMat	LIKE sga_eqdef_matrices.carrera_origen;
	DEFINE vMateria	LIKE sga_eqdef_materias.materia;
	DEFINE vOrigenDestino	LIKE sga_eqdef_materias.origen_destino;
	DEFINE vCondicion	LIKE sga_eqdef_materias.condicion;
	DEFINE vTemas	LIKE sga_eqdef_materias.temas_a_rendir;
	DEFINE vVencimiento	LIKE sga_equiv_otorgada.vencimiento;
	DEFINE vRetornarMateria, vCumpleMatOrigen CHAR(1);
	DEFINE vVersion	LIKE  sga_equiv_otorgada.version;

	DEFINE vGrupoEquiv	LIKE  sga_eqdef_grupos.grupo_equiv;

	DEFINE vCarreraOrigen	LIKE sga_equiv_relacion.carrera;
	DEFINE vLegajoOrigen	LIKE  sga_equiv_relacion.legajo;
	DEFINE vMateriaOrigen	LIKE  sga_equiv_relacion.materia;
	DEFINE vFechaOrigen	LIKE  sga_equiv_relacion.fecha;
	DEFINE vCondicionOrigen	LIKE  sga_equiv_relacion.origen;  -- R - Equivalencia Parcial / A - Aprobacion de materia

	DEFINE vOrigen	LIKE  sga_equiv_relacion.origen;

	DEFINE vRegular, vEstado	char(1);
	DEFINE vFecha 	   DATE;
	DEFINE vNota	   LIKE sga_det_escala.nota;
	DEFINE vEscalaNotas LIKE sga_det_escala.escala_notas;
	DEFINE vResultado     LIKE sga_det_escala.resultado;


	-- Variables para el manejo de excepciones
	DEFINE SQLErr             integer;
	DEFINE ISAMError          integer;
	DEFINE errorInfo          varchar(76);

	-- Si hay algun error
	ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
		RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
	END EXCEPTION;
BEGIN
	-- selecciono la carrera origen de la matriz
	LET vCarreraOrigenMat	 = NULL;
	SELECT carrera_origen INTO vCarreraOrigenMat	
		FROM sga_eqdef_matrices
		WHERE matriz_equiv = pMatrizEquiv;


        -- Creo la tabla temporal de la Historia academica del alumno	
        CREATE TEMP TABLE tmp_equiv_hacad (carrera varchar(5), legajo varchar(15), materia  varchar(5), fecha  date,  nota varchar(5), escala_notas integer, resultado varchar(2), forma_aprobacion varchar(20)) WITH NO LOG;

        -- Creo la tabla temporal de la Historia academica equivalente del alumno	
        CREATE TEMP TABLE tmp_eq_hacad_equiv (carrera varchar(5), legajo varchar(15), materia  varchar(5), fecha  date,  nota varchar(5), escala_notas integer, resultado varchar(2), forma_aprobacion varchar(20)) WITH NO LOG;

        -- Materias que el alumno tiene cursadas.
        CREATE TEMP TABLE tmp_equiv_cursadas (carrera varchar(5), legajo varchar(15), materia  varchar(5), fecha  date, nota varchar(5), escala_notas integer, resultado varchar(2),origen varchar(2), fecha_vencimiento date) WITH NO LOG;


     SELECT Nro_Inscripcion INTO vNroInscripcion
	FROM sga_alumnos
               WHERE unidad_academica = pUnidadAcademica
                 AND carrera = pCarrera
                 AND legajo  = pLegajo;

      -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     -- La matriz es con una carrera de origen definida 
     -- Recupera las carreras en la que esta la Persona, no importando el estado (si es regular o no, activo o no..)	
      -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     FOREACH EXECUTE PROCEDURE b_carrerasPersona(pUnidadAcademica, vNroInscripcion)
	 INTO vUnidadAcademica, vCarrera, vLegajo, vPlan, vRegular, vEstado

-- esta carrera legajo, el alumno aun no tiene HISTORIA ACADEMICA!!!!
      	
          -- Cargo la Historia academica del alumno y las cursadas vigentes

----------------------- modificado 18-11-2014 por adaptacion de FCE

       if pCarrera = vCarrera or vCarrera = '0205' then
          -- Agrego las materias APROBADAS y REPROBADAS del Alumno	
          INSERT INTO tmp_equiv_hacad (carrera, legajo, materia, fecha,  nota, escala_notas, resultado, forma_aprobacion)
              SELECT vw_hist_academica.carrera, vw_hist_academica.legajo, vw_hist_academica.materia, 
	vw_hist_academica.fecha, vw_hist_academica.nota, vw_hist_academica.escala_notas, vw_hist_academica.resultado, vw_hist_academica.forma_aprobacion
                FROM vw_hist_academica
               WHERE vw_hist_academica.unidad_academica = pUnidadAcademica
                 AND vw_hist_academica.carrera = vCarrera
                 AND vw_hist_academica.legajo  = vLegajo;

          -- Cursadas vigentes del Alumno.
          INSERT INTO tmp_equiv_cursadas (carrera, legajo, materia,fecha,  nota, escala_notas, resultado,origen, fecha_vencimiento)
              SELECT sga_cursadas.carrera, sga_cursadas.legajo, sga_cursadas.materia,  sga_cursadas.fecha_regularidad, sga_cursadas.nota, sga_cursadas.escala_notas, sga_cursadas.resultado , sga_cursadas.origen , sga_cursadas.fin_vigencia_regul
                FROM sga_cursadas
               WHERE sga_cursadas.unidad_academica = pUnidadAcademica
                 AND sga_cursadas.carrera = vCarrera
                 AND sga_cursadas.legajo  = vLegajo	
                 AND (sga_cursadas.fin_vigencia_regul >= Today or fin_vigencia_regul IS NULL)
                 AND sga_cursadas.resultado = 'A'
                 AND sga_cursadas.estado = 'A';	
             END IF;

                 -- AND sga_cursadas.origen = 'C'   -- Origen C = Cursadas

     END FOREACH;  -- Carreras de la Persona


     -- paso a la temporal todos los registros equivalentes
     -- para control de actividad academica duplicada
     INSERT INTO tmp_eq_hacad_equiv
     SELECT * FROM tmp_equiv_hacad
	     WHERE forma_aprobacion in ( 'Examen equivalente','Promoción en otra carrera',  'Equivalencia equivalente')
		     AND carrera = pCarrera
		     AND legajo = pLegajo
		     AND resultado = 'A';

      -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- Saco de la temporal de historia academica, aquellos registros que son resultado de equivalencias equivalentes
      -- examentes equivalentes, promociones equivalentes, etc..
      -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      DELETE FROM tmp_equiv_hacad
	WHERE forma_aprobacion in ( 'Examen equivalente','Promoción en otra carrera',  'Equivalencia equivalente');
	
	-- Saco Cursadas Equivalentes y Equivalencias Equivalentes..
      DELETE FROM tmp_equiv_cursadas
	WHERE origen in ( 'CE','EE');

      -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       -- Recupero las materias de la matriz
      -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       FOREACH SELECT grupo_equiv INTO vGrupoEquiv
	FROM sga_eqdef_grupos
	WHERE sga_eqdef_grupos.matriz_equiv = pMatrizEquiv

	FOREACH
		 EXECUTE PROCEDURE sp_evalua_grupo(pUnidadAcademica, pCarrera, pLegajo, pMatrizEquiv, vGrupoEquiv)
			 INTO vMateria, vFecha, vCondicion, vResultado, vEscalaNotas, vNota, vVencimiento, vTemas, vPlan, vVersion, vCarreraOrigen, vLegajoOrigen, vMateriaOrigen, vFechaOrigen, vCondicionOrigen

		IF NOT EXISTS (SELECT '' FROM tmp_eq_hacad_equiv WHERE materia = vMateria) THEN

			RETURN vGrupoEquiv, vMateria, vFecha, vCondicion, vResultado, vEscalaNotas, vNota, vVencimiento, vTemas, vPlan, vVersion, vCarreraOrigen, vLegajoOrigen, vMateriaOrigen, vFechaOrigen, vCondicionOrigen  WITH RESUME;

		END IF;

	END FOREACH;

      END FOREACH; -- Grupos de Equivalencias

        -- Borro las tablas temporales	
        DROP  TABLE tmp_equiv_hacad;
        DROP  TABLE tmp_equiv_cursadas;
	DROP TABLE tmp_eq_hacad_equiv;


END;
END PROCEDURE;
                                                                                                                                                                
-- ********************* Fin del procedure sp_evalua_matriz ********************                                                                
