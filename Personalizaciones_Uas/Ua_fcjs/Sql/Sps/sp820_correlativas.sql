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
-- SP: sp820_correlativas
-- Version 1.9
-- Ultima Version de MOdificacion: 1.11.0
--
-- Recupera las materias correlativas Normales a una materia dada. Correlativas AND/OR
--	teniendo en cuenta notas cargadas en actas no cerradas.
--
-- Parametros:  
-- Devuelve: integer                1 OK, -1 Error
--                  varchar(255)       Mensaje de Error
-- **************************************************************************

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
   DEFINE iAux, contador, iOrden               smallint;
   DEFINE vcConectorLogico  LIKE sga_correlativas.conector_logico;
   DEFINE vcMateriaAnterior  LIKE sga_correlativas.materia_anterior;
   DEFINE vcCondAnterior  LIKE sga_correlativas.condicion_anterior;
   DEFINE vcResultado         varchar(2);
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

begin
   on exception in (-206)
    -- Tabla no existe continuo el proceso	
   end exception with resume;
 DROP TABLE tmp_hist_acad_mat;
 DROP TABLE tmp_mensajes;
end;

CREATE TEMP TABLE  tmp_mensajes
    (orden smallint, mensaje varchar(255));

 -- TMP_HIST_ACAD_MAT sera utilizada en otros procedures llamados desde este sp.
CREATE TEMP TABLE  tmp_hist_acad_mat
    (materia varchar(5), resultado varchar(2));

-- Cargo la tabla temporal con las materias rendidas por el alumno.
 INSERT INTO  tmp_hist_acad_mat (materia, resultado) 
   SELECT materia, resultado 
     FROM vw_hist_academica 
  WHERE unidad_academica = pUnidadAcademica 
    AND carrera          = pCarrera 
    AND legajo           = pLegajo;

-- ******************************************************
-- u820: se agregan al temporal las actas abiertas
-- ******************************************************
 INSERT INTO  tmp_hist_acad_mat (materia, resultado) 
 SELECT materia, resultado
 FROM sga_detalle_acta d
	join sga_actas_examen a
	  ON d.unidad_academica = a.unidad_academica
		and d.tipo_acta = a.tipo_acta
		and d.acta = a.acta
  WHERE d.unidad_academica = pUnidadAcademica 
    AND d.carrera          = pCarrera 
    AND d.legajo           = pLegajo
    AND a.estado in ("A", "I", "N");
-- ******************************************************
-- ******************************************************


-- Solo dejo las materias que el alumno aprobo.
DELETE FROM tmp_hist_acad_mat
WHERE resultado <> 'A';


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
    IF (SELECT COUNT(*) FROM   tmp_hist_acad_mat
	  WHERE materia =	vcMateriaAnterior) > 0 THEN
	LET vcResultado = 1;
	LET vcMensaje = '';
    ELSE
	    -- Verifico la Materia
	    EXECUTE PROCEDURE sp_evalua_materia(pUnidadAcademica, pCarrera, pLegajo, vcMateriaAnterior, pPlan, pVersion, vcCondAnterior) INTO  vcResultado, vcMensaje;	
	    IF vcResultado =  '-1' THEN
		LET vMateriaRegParcial = 'N';	
		-- Si la Materia debe estar cursada...
		IF   vCierreParcial = 'S' and vcCondAnterior = 'C' THEN
			-- Verifico si la regularidad esta Aprobada en un Cierre Parcial de Actas de Cursados
			IF (SELECT  count(*) FROM vw_reg_parciales
			       WHERE unidad_academica   = pUnidadAcademica 
			        AND  carrera		= pCarrera 
			        AND  legajo 		= pLegajo
			        AND  materia 	=  vcMateriaAnterior
			        AND  resultado in ('A','P') ) > 0 THEN
				-- Cumple con la correlativa.
				LET vMateriaRegParcial = 'S';	
				LET vcResultado = 1;
				LET vcMensaje = '';
			END IF;
		END IF;

		IF vMateriaRegParcial = 'N' THEN	

		   -- No cumplio con la correlativa anterior. 
		   LET aprobo_grupo = 'N';
		   IF LENGTH(vcMensajeError) + LENGTH(vcMensaje) > 245 THEN
			-- El mensaje es mayor a 255... debo ingresar los mensajes en una tabla temporal
			INSERT INTO tmp_mensajes(orden, mensaje) VALUES (contador, vcMensajeError);
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
	IF vcResultado =  '-1' THEN
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

IF contador = 1 OR rtn = 1 THEN       
  -- EL mensaje solo estuvo en una linea...
  RETURN rtn, vcMensajeError WITH RESUME;
ELSE
   INSERT INTO tmp_mensajes(orden, mensaje) VALUES (contador, vcMensajeError);
   FOREACH SELECT orden, mensaje INTO iOrden, vcMensajeError 
		FROM tmp_mensajes
		ORDER BY orden
	  RETURN rtn, vcMensajeError WITH RESUME;
  END FOREACH;
END IF

begin
   on exception in (-206)
    -- Tabla no existe continuo el proceso	
   end exception with resume;
   DROP TABLE tmp_mensajes;
   DROP TABLE tmp_hist_acad_mat;
end;

END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp820_correlativas ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_correlativas 
-- *****************************************************************************
revoke execute on "dba".sp820_correlativas from public;
grant execute on "dba".sp820_correlativas to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_correlativas to internet; -- Rol de usuario de Internet