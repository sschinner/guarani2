CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_evalua_materia') THEN
		DROP PROCEDURE sp820_evalua_materia;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- U820 ********************************************************************
-- ESTE ES EL PROCEDIMIENTO ORIGINAL (MANTIENE EL  MISMO NOMBRE) MODIFICADO.***********************
-- ESTE SP SE USA TANTO EN CURSADAS COMO EN EXAMEN
-- U820 ********************************************************************

-- **************************************************************************
-- SP: sp_evalua_materia
-- Verifica si la materia esta aprobada o tiene la cursada de la misma
-- Ultima version de modificacion: 2.03.0, 2.05.0
-- 
-- Parametros:  
-- Devuelve: integer               1 = OK , -1 = No cumple con el conjunto.
--	     varchar(255)     Mensaje de Error
-- **************************************************************************
--DROP PROCEDURE "dba".sp820_evalua_materia;
CREATE PROCEDURE "dba".sp820_evalua_materia (
                 pUnidadAcademica  LIKE sga_unidades_acad.unidad_academica,
                 pCarrera          LIKE sga_carreras.carrera,
                 pLegajo           LIKE sga_alumnos.legajo,
                 pMateria          LIKE sga_materias.materia,
                 pPlan             LIKE sga_planes.plan,
                 pVersion          LIKE sga_planes.version_actual,
                 pCondicion        CHAR(1)  -- (C - Materia Cursada / A - Materia Aprobada / S - Cursada Simultanea)
                 )
       RETURNING smallint,       -- status 1-OK/ -1 NO paso correlativas
                 varchar(255);   -- MENSAJE. OK si aprobo, Mensaje de error si no aprobo o curso la materia.


DEFINE rtn_1        smallint;      -- status
DEFINE rtn_2        varchar(255);  -- mensaje

-- var's para el manejo de excepciones
DEFINE sql_err      integer;
DEFINE isam_err     integer;
DEFINE error_info   varchar(76);

-- var's locales
DEFINE iAux         smallint;
DEFINE vcTitulo     LIKE sga_titulos.titulo;
DEFINE sResultado   varchar(2);
  
DEFINE vnombre_mat     varchar(255); 

-- blk de excepciones
ON EXCEPTION SET sql_err, isam_err, error_info
   RAISE EXCEPTION  sql_err, isam_err, error_info;
END EXCEPTION;



BEGIN

   -- por default el codigo de retorno es OK
   LET rtn_1  = 1; 
   LET rtn_2  = 'OK'; 

-- U820 ********************************************************************
-- Nombre Reducido de la materia, según el Plan de Estudios.
-- U820 ********************************************************************

SELECT nombre_reducido INTO vnombre_mat
FROM sga_atrib_mat_plan
WHERE sga_atrib_mat_plan.unidad_academica = pUnidadAcademica
	AND sga_atrib_mat_plan.carrera = pCarrera
	AND sga_atrib_mat_plan.plan = pPlan
	AND sga_atrib_mat_plan.version = pVersion
	AND sga_atrib_mat_plan.materia = pMateria;
Let vnombre_mat = '(' || pMateria || ') ' || vnombre_mat; 

-- ************************************************************************************************************************
-- 		 Condicion: MATERIA APROBADA
-- ************************************************************************************************************************
IF pCondicion = 'A' THEN  -- Controlo las condiciones para Rendir Examen
   -- ***********************************************************
   -- Veo si la Materia Correlativa es una Materia Genérica,
   -- Si es asi veo que tenga aprobadas las Materias Optativas
   -- ***********************************************************
   IF (SELECT tipo_materia
         FROM sga_materias
        WHERE unidad_academica = pUnidadAcademica
          AND materia = pMateria) = 'G' THEN
      
      -- La materia correlativa es Generica, verifico que esta este aprobada
      
      -- Orientacion Base.	
      -- Recupero el Titulo de Grado del Plan-Version
      SELECT sga_orientaciones.titulo 
        INTO vcTitulo
        FROM sga_orientaciones, sga_titulos
       WHERE sga_orientaciones.unidad_academica   = pUnidadAcademica
         AND sga_orientaciones.carrera  = pCarrera  
         AND sga_orientaciones.plan     = pPlan 
         AND sga_orientaciones.orientacion = '0'
         AND sga_orientaciones.unidad_academica   = sga_titulos.unidad_academica
         AND sga_orientaciones.titulo  = sga_titulos.titulo
         AND sga_titulos.nivel = 'GRADO';  
      
      LET sResultado = '';	
      EXECUTE PROCEDURE sp820_resultGenerica(pUnidadAcademica, pCarrera, pLegajo, vcTitulo,'0',pMateria) INTO sResultado;
      IF sResultado <> 'A' THEN
         LET rtn_1 = -1;
         LET rtn_2 = ' Aprobar ' || vnombre_mat;
         RETURN rtn_1, rtn_2 ;
      END IF;
   ELSE
      -- No es materia Generica. 
      LET rtn_1 = -1;
      LET rtn_2 = ' Aprobar ' || vnombre_mat;
      RETURN rtn_1,rtn_2 ;	
   END IF;  
   -- ******************************* Materia Generica****************************


-- ************************************************************************************************************************
-- 		 Condicion: MATERIA CURSADA
-- ************************************************************************************************************************
ELIF pCondicion = 'C' or pCondicion = 'S' THEN	-- busco en cursadas
   
   -- Si la materia correlativa es una materia genérica.
   IF ( SELECT tipo_materia 
          FROM sga_materias
         WHERE unidad_academica = pUnidadAcademica		
           AND materia = pMateria) = 'G' THEN
      
      -- Orientacion Base.	
      -- Recupero el Titulo de Grado del Plan-Version
      SELECT sga_orientaciones.titulo 
        INTO vcTitulo
        FROM sga_orientaciones, sga_titulos
       WHERE sga_orientaciones.unidad_academica   = pUnidadAcademica
         AND sga_orientaciones.carrera  = pCarrera  
         AND sga_orientaciones.plan     = pPlan 
         AND sga_orientaciones.orientacion = '0'
         AND sga_orientaciones.unidad_academica   = sga_titulos.unidad_academica
         AND sga_orientaciones.titulo  = sga_titulos.titulo
         AND sga_titulos.nivel = 'GRADO';  
      
      LET sResultado = '';	
      
      -- Verificar que la materia genérica este cursada.
      -- Me retorna 'C' en caso de que se la de por cursada y 'N' en caso de no tenerla como cursada.
      EXECUTE PROCEDURE sp_resultGenCurs(pUnidadAcademica, pCarrera, pLegajo, vcTitulo,'0',pMateria,pCondicion) INTO sResultado;
      IF sResultado <> 'C' THEN
         
         LET rtn_1 = -1;
         IF pCondicion = 'S' THEN
            LET rtn_2 = ' Inscribirse a Cursar ' || vnombre_mat;
         ELSE
            LET rtn_2 = ' Cursar ' || vnombre_mat;
         END IF;
         
         RETURN rtn_1, rtn_2 ;	

      END IF;	
      
   ELSE
      
      SELECT COUNT(*)
        INTO iAux
        FROM sga_cursadas c
       WHERE c.unidad_academica = pUnidadAcademica
         AND c.carrera          = pCarrera
         AND c.legajo           = pLegajo
         AND c.materia          = pMateria
         AND c.resultado        IN ('A', 'P')
         AND (c.fin_vigencia_regul >= TODAY or c.fin_vigencia_regul IS NULL)
         AND c.fecha_regularidad IS NOT NULL;
      
      -- si no figura aprobada, no satisface la correlatividad
      IF iAux = 0 THEN
         -- Verifica si es una Equivalencia Parcial que solo vale para correlativas: alcance = 'C'
         SELECT COUNT(*)  INTO iAux
	FROM vw_equivpar_corr
	WHERE unidad_academica = pUnidadAcademica
	AND carrera = pCarrera
	AND legajo   = pLegajo
	AND materia = pMateria
	AND resultado = 'A'
	AND ( fin_vigencia_equiv >= TODAY OR fin_vigencia_equiv IS NULL);
         
         IF iAux = 0 THEN
            -- Verifico si es cursada Simultanea
            IF pCondicion = 'S' THEN
               -- Verifico si esta cursando actualmente la materia...
               -- Recupero los periódos lectivos Actuales...
               IF (SELECT COUNT(*)
                     FROM vw_perlectactuales pl,
                          sga_comisiones c,
                          sga_insc_cursadas ic
                    WHERE c.anio_academico = pl.anio_academico
                      AND c.periodo_lectivo = pl.periodo_lectivo
                      AND c.materia = pMateria
                      AND ic.comision = c.comision
                      AND ic.unidad_academica =  pUnidadAcademica
                      AND ic.carrera = pCarrera
                      AND ic.legajo = pLegajo
                      AND ic.estado in ('A','P','E') ) > 0 THEN
                  
                  -- OK. Esta inscripto a cursar la materia en un período vigente...
                  LET rtn_1 = 1;
                  LET rtn_2 = 'OK';
                  RETURN rtn_1, rtn_2;
               END IF;			
            END IF;
            
            LET rtn_1 = -1;
            IF pCondicion = 'S' THEN
               LET rtn_2 = ' Inscribirse a Cursar ' || vnombre_mat;
            ELSE
               LET rtn_2 = ' Cursar ' || vnombre_mat;
            END IF;
            
            RETURN rtn_1, rtn_2;
            
         END IF;  -- no figura como equivalencia parcial solo para correlativas...
      END IF;  -- no figura aprobada la cursada
   END IF;

END IF;  -- Cursada Materia

-- cumple con la cursada
RETURN rtn_1, rtn_2;

END;
END PROCEDURE;
-- ******************** FIN PROCESO sp820_evalua_materia ********************


-- *************** Fin del procedimiento  ******************

-- *****************************************************************************
-- Permisos del procedimiento 
-- *****************************************************************************
revoke execute on "dba".sp820_evalua_materia from public;
grant execute on "dba".sp820_evalua_materia to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_evalua_materia to internet; -- Rol de usuario de Internet