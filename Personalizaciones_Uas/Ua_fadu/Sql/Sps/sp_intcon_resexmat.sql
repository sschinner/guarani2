CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_intcon_resexmat') THEN
		DROP PROCEDURE sp_intcon_resexmat;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1
-- Procedure sp_intcon_resexmat
--
-- Recupera la cantidad de alumnos para un anio academico y carrera determinadas. 
-- El filtro tipo de resultado determina si se recuperan los alumnos que desaprobaron 
-- (pResultado = 'R' ), aprobaron (pResultado = 'A'), desaprobaron (pResultado = 'U') 
-- o  todos (pResultado = 'NULL').
-- Para los casos en que el filtro pResultado es 'A' o 'R', tambien se puede filtrar
-- por un rango determinado de valores de nota. 
-- La condicion es pNotaDesde <= notas < pNotaHasta
-- modificado 2.7.0
-- *****************************************************************************
-- DROP PROCEDURE "dba".sp_intcon_resexmat;
CREATE PROCEDURE "dba".sp_intcon_resexmat ( pUnidadACademica varchar(5), 
                                      pCarrera varchar(5),
                                      pMateria varchar(5),
		      pLegajo varchar(10),
                                      pAnio   INTEGER,
                                      pResultado VARCHAR(2) DEFAULT NULL,
                                      pNotaDesde DECIMAL(6,2) DEFAULT NULL,
                                      pNotaHasta DECIMAL(6,2) DEFAULT NULL)
       RETURNING integer;   -- Cantidad de alumnos en ese rango

-- Variables locales
DEFINE vc_nota          LIKE sga_detalle_acta.nota;
DEFINE vc_resultado     LIKE sga_detalle_acta.resultado;
DEFINE vc_plan          LIKE sga_atrib_mat_plan.plan;
DEFINE vc_version       LIKE sga_atrib_mat_plan.version;
DEFINE vc_escala_notas  LIKE sga_actas_examen.escala_notas;
DEFINE vc_valor_num     DECIMAL(6,2);
DEFINE vc_Materia       LIKE sga_materias.materia;
DEFINE vc_promediable   LIKE sga_atrib_mat_plan.promediable;

DEFINE cnt_notas_mat 	INTEGER;

-- Variables para el manejo de excepciones
DEFINE SQLErr           INTEGER;
DEFINE ISAMError        INTEGER;
DEFINE errorInfo        VARCHAR(76);


-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
	RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;


BEGIN
   
   -- Inicializo todos los contadores.
   LET vc_valor_num = 0;
   LET cnt_notas_mat = 0;
   
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- Recupero la cantidad de alumnos que se presentaron
   -- a rendir examen.
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   FOREACH
    SELECT da.nota, da.resultado, da.plan,  da.version, ae.escala_notas
      INTO vc_nota, vc_resultado, vc_plan, vc_version, vc_escala_notas
      FROM sga_actas_examen ae, 
           sga_detalle_acta da,
           sga_docentes_llama dll
     WHERE ae.unidad_academica = pUnidadACademica
       AND ae.anio_academico = pAnio
       AND ae.materia = pMateria
       AND ae.estado = 'C'
       AND da.estado = 'A'
       AND da.rectificado = 'N'
       AND (pResultado IS NULL OR da.resultado = pResultado)
       AND ae.unidad_academica = da.unidad_academica
       AND ae.acta    	    = da.acta
       AND ae.tipo_acta = da.tipo_acta
       AND ae.unidad_academica = dll.unidad_academica
       AND ae.materia = dll.materia
       AND ae.anio_academico = dll.anio_academico
       AND ae.turno_examen = dll.turno_examen
       AND ae.mesa_examen = dll.mesa_examen
       AND ae.llamado = dll.llamado     
       AND da.carrera   = pCarrera
       AND dll.legajo = pLegajo
      
      -- aca cuento los presentes
      IF pResultado is null AND vc_resultado <>'U' THEN
         LET cnt_notas_mat = cnt_notas_mat + 1;
      END IF;
      
      -- aca cuento los ausentes
      IF (pResultado <> 'A' AND pResultado <> 'R') THEN
         LET cnt_notas_mat = cnt_notas_mat + 1;
      END IF;
      
      -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      -- En el caso de contar aprobados o desaprobados. Verifico que la materia sea 
      -- promediable.
      -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      IF NOT pResultado IS NULL AND (pResultado = 'A' OR pResultado = 'R') THEN
         
         -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         -- Verifico que la materia sea promediable. Porque solo tengo en cuenta
         -- materias cuya notas sean valores numericos. 
         -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
         SELECT promediable
           INTO vc_promediable
           FROM sga_atrib_mat_plan
          WHERE sga_atrib_mat_plan.unidad_academica = pUnidadAcademica
            AND sga_atrib_mat_plan.carrera          = pCarrera
            AND sga_atrib_mat_plan.plan             = vc_plan
            AND sga_atrib_mat_plan.version          = vc_version
            AND sga_atrib_mat_plan.materia          = pMateria;
         
         IF vc_promediable  = 'S' AND vc_resultado = pResultado THEN
            
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
            -- Recupero el valor numerico de la escala de notas. Porque si la materia 
            -- es promediable debe tener definida una escala de notas numerica. 
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
            SELECT valor_numerico 
              INTO vc_valor_num
              FROM sga_det_escala
             WHERE sga_det_escala.escala_notas = vc_escala_notas 
               AND sga_det_escala.nota         = vc_nota
               AND sga_det_escala.resultado    = vc_resultado;
            
            IF vc_valor_num IS NULL THEN
               RAISE EXCEPTION -746,0,'La materia ' || pMateria || ' es promediable y a su escala de notas '||  vc_escala_notas ||  ' le faltan valores numericos';
            ELSE
               IF (pNotaDesde IS NULL OR (NOT pNotaDesde IS NULL AND pNotaDesde <= vc_valor_num )) AND
                  (pNotaHasta IS NULL OR (NOT pNotaHasta IS NULL AND pNotaHasta > vc_valor_num  )) THEN
                  LET cnt_notas_mat = cnt_notas_mat + 1;
               END IF;
            END IF;
         END IF;
      END IF 
   END FOREACH;
   
   RETURN cnt_notas_mat;
   
END;
END PROCEDURE;
-- ************************ Fin del procedure sp_intcon_resexmat ************************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_intcon_resexmat
-- *****************************************************************************
revoke execute on "dba".sp_intcon_resexmat from public;
grant execute on "dba".sp_intcon_resexmat to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_intcon_resexmat to internet; -- Rol de usuario de Internet