CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_correlativas') THEN
		DROP PROCEDURE sp820_correlativas;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **************************************************************************
-- SP: sp_correlativas
-- Version 1.9
-- Ultima Version de MOdificacion: 1.11.0, 2.03.0
--
-- Recupera las materias correlativas Normales a una materia dada. Correlativas AND/OR
-- Cierre Parcial de actas de Cursado/Promocion: Verifica materias regularizadas en otras carreras del alumno
--
-- Parametros:
-- Devuelve: integer                1 OK, -1 Error
--                  varchar(255)       Mensaje de Error
-- **************************************************************************
-- DROP PROCEDURE "dba".sp820_correlativas;
CREATE PROCEDURE "dba".sp820_correlativas (
	pUnidadAcademica   LIKE sga_unidades_acad.unidad_academica,
	pCarrera           LIKE sga_carreras.carrera,
	pLegajo            LIKE sga_alumnos.legajo,
	pMateria           LIKE sga_materias.materia,
	pPlan              LIKE sga_planes.plan,
	pVersion           LIKE sga_planes.version_actual,
	p_para             CHAR(1)  -- (C - Cursar materia, A - Aprobar/ Rendir Materia)
	) RETURNING
		smallint,      -- status 1-OK/ -1 NO paso correlativas
		varchar(255);    -- MENSAJE. OK si aprobo, Mensaje de error si no aprobo ningun grupo.

 /*  verifica si tiene todas materias  correlativas a una dada cumplidas
       devuelve: *  1 - si esta OK  -1 - en otro caso
	        *  Mensaje
	o un RAISE EXCEPTION */
   DEFINE rtn        smallint;                   -- status

  -- var's para el manejo de excepciones
   DEFINE sql_err      integer;
   DEFINE isam_err     integer;
   DEFINE error_info   varchar(76);

  -- var's locales
   DEFINE iAux, contador, iOrden, iRegMateria, iRtnEvaluarMat              smallint;
   DEFINE vcConectorLogico  LIKE sga_correlativas.conector_logico;
   DEFINE vcMateriaAnterior  LIKE sga_correlativas.materia_anterior;
   DEFINE vcCondAnterior  LIKE sga_correlativas.condicion_anterior;
   DEFINE vcTitulo           LIKE sga_titulos.titulo;
   DEFINE vcMensaje, vcMensajeError  varchar(255);
   DEFINE aprobo_grupo, vMateriaRegParcial  char(1);
   DEFINE vCierreParcial LIKE sga_param_sistema.valor;


  -- blk de excepciones
  ON EXCEPTION SET sql_err, isam_err, error_info
   	RAISE EXCEPTION  sql_err, isam_err, error_info;
   END EXCEPTION;


BEGIN
   -- por default el codigo de retorno es OK
   LET rtn 	= 1;
   LET contador 	= 1;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Verifico si trabaja con cierres parciales. Busco fechas de las regularidades
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
EXECUTE PROCEDURE sp_param_sistema('cierre_parcial_acta_cursados') INTO vCierreParcial;


--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- recupero todas las correlativas OR de la materia
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
LET aprobo_grupo = 'S';
LET vcConectorLogico = 'Y';
LET vcMensajeError = 'Ud. debe: (';
LET vcMensaje = '';

FOREACH
       SELECT c.orden,
	    c.materia_anterior,
                    c.condicion_anterior,   -- Solo cuando esta cargada la materia....
	    c.conector_logico
         INTO iOrden, vcMateriaAnterior, vcCondAnterior, vcConectorLogico
         FROM sga_correlativas c
        WHERE c.unidad_academica = pUnidadAcademica
          AND c.carrera          = pCarrera
          AND c.plan             = pPlan
          AND c.version          = pVersion
          AND c.materia          = pMateria
          AND c.condicion      = p_para
      ORDER BY orden

    -- Verifico si la materia esta aprobada
    IF (SELECT COUNT(*)  FROM vw_hist_academica
	  WHERE unidad_academica = pUnidadAcademica
		AND carrera          = pCarrera
		AND legajo           = pLegajo
		AND materia =	vcMateriaAnterior
		AND resultado = 'A') > 0 THEN
	LET iRtnEvaluarMat = 1;
	LET vcMensaje = '';
    ELSE
	    -- Verifico la Materia
	    EXECUTE PROCEDURE sp820_evalua_materia(pUnidadAcademica, pCarrera, pLegajo, vcMateriaAnterior, pPlan, pVersion, vcCondAnterior) INTO  iRtnEvaluarMat, vcMensaje;
	    IF iRtnEvaluarMat <>  1 THEN
		LET vMateriaRegParcial = 'N';
		-- Si la Materia debe estar cursada...
		IF   vCierreParcial = 'S' and vcCondAnterior = 'C' THEN

			-- Verifico si la regularidad esta Aprobada en un Cierre Parcial de Actas de Cursados
			-- Controlo en todas las carreras del Alumno
			LET  iRegMateria = -1;
			EXECUTE PROCEDURE sp_tieneregparcial(pUnidadAcademica, pCarrera, pLegajo, vcMateriaAnterior, TODAY) INTO iRegMateria;
			IF  iRegMateria =  1 THEN
				-- Cumple con la correlativa.
				LET vMateriaRegParcial = 'S';
				LET iRtnEvaluarMat = 1;
				LET vcMensaje = '';
			END IF;
		END IF;

		IF vMateriaRegParcial = 'N' THEN

		   -- No cumplio con la correlativa anterior.
		   LET aprobo_grupo = 'N';
		   IF LENGTH(vcMensajeError) + LENGTH(vcMensaje) > 245 THEN
			-- El mensaje es mayor a 255... debo ingresar los mensajes en una tabla temporal
			-- INSERT INTO tmp_mensajes(orden, mensaje) VALUES (contador, vcMensajeError);
			LET vcMensajeError = vcMensaje;
			LET contador = contador + 1;
		   ELSE
			LET vcMensajeError = vcMensajeError || vcMensaje;
		   END IF;
		END IF;
	    END IF;
     END IF;

      IF vcConectorLogico = 'O' THEN     -- Condicion OR (Este divide los grupos para las correlativas OR)
	-- Hasta aca llegó el grupo. Debo evaluar que sucedio, si lo aprobo o no.
	IF aprobo_grupo = 'S' THEN
		-- Salgo del recorrido, ya que cumplio con un grupo de las correlativas AND/OR
		-- Cumplio con las correlativas. todo OK.
		LET rtn = 1;
		LET vcMensajeError = 'OK';
		EXIT FOREACH;
	ELIF  aprobo_grupo = 'N' THEN
		-- Inicializo variables.
		LET rtn = -1;
		LET aprobo_grupo = 'S';
		IF SUBSTR(vcMensajeError, LENGTH(vcMensajeError),1) = 'y' THEN
			LET vcMensajeError = SUBSTR(vcMensajeError,1, LENGTH (vcMensajeError) - 1);
		END IF;
		LET vcMensajeError = vcMensajeError || ') o (';
	END IF;
      ELIF vcConectorLogico = 'Y' THEN     -- Condicion AND
	IF iRtnEvaluarMat =  -1 THEN
	   -- Compongo el Mensaje
  	   LET rtn = -1;
	   LET vcMensajeError = vcMensajeError || ' y';
	END IF;
      END IF;
END FOREACH;


-- por el ultimo grupo
IF aprobo_grupo = 'S' and  NOT (rtn = -1 and vcConectorLogico = 'O') THEN
  LET rtn = 1;
  LET vcMensajeError = 'OK';
END IF;

-- Aca debo sacar el "o" que quedo al final del mensaje.
 IF rtn = -1 OR vcConectorLogico = 'O' THEN
    IF SUBSTR(vcMensajeError, LENGTH(vcMensajeError),1) = 'y' THEN
	LET vcMensajeError = SUBSTR(vcMensajeError,1, LENGTH (vcMensajeError) - 1) || ')';
    ELIF SUBSTR(vcMensajeError, LENGTH(vcMensajeError) - 2,3) = 'o (' THEN
	LET vcMensajeError = SUBSTR(vcMensajeError,1, LENGTH (vcMensajeError) - 3) ;
    ELIF SUBSTR(vcMensajeError, LENGTH(vcMensajeError) - 2,3) = ') o' THEN
	LET vcMensajeError = SUBSTR(vcMensajeError,1, LENGTH (vcMensajeError) - 1) ;
    END IF
END IF;


RETURN rtn, vcMensajeError;

END;
END PROCEDURE;
-- ******************** FIN PROCESO sp_correlativas ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_correlativas
-- *****************************************************************************
revoke execute on "dba".sp820_correlativas from public;
grant execute on "dba".sp820_correlativas to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_correlativas to internet; -- Rol de usuario de Internet