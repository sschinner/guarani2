-- ******************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Versión 2.05.2, 2.7.0, 2.09.0
-- Procedure sp_int_arau_ccu_11
-- 
-- Proceso que realiza el calculo para el Cuadro 3 del Araucano.
-- Se estan contando todos los titulos, de nivel final e intermedio.
-- 
-- CUADRO 11:
-- IdSerie = E (egresados)
-- IdSubSerie = EPAI (por año de ingreso)
-- 
-- Recibe: Anio Académico informado
-- Retorna: nada.
-- ******************************************************************************

-- DROP PROCEDURE sp_int_arau_ccu_11;
CREATE PROCEDURE sp_int_arau_ccu_11( pAnio LIKE sga_anio_academico.anio_academico )

DEFINE l_titulo		   INTEGER;
DEFINE l_institu_araucano  INTEGER;

DEFINE l_cant              INTEGER;
DEFINE l_cant_A            INTEGER;
DEFINE l_index_sexo        INTEGER;
DEFINE l_index             SMALLINT;
DEFINE l_index_anter  	   SMALLINT;
DEFINE l_anio_ant          SMALLINT;
DEFINE l_pre_anio          SMALLINT;

DEFINE tot_var_ndi         INTEGER;
DEFINE tot_var_0           INTEGER;
DEFINE tot_var_1           INTEGER;
DEFINE tot_var_2           INTEGER;
DEFINE tot_var_3           INTEGER;
DEFINE tot_var_4           INTEGER;
DEFINE tot_var_5           INTEGER;
DEFINE tot_var_6           INTEGER;
DEFINE tot_var_7           INTEGER;
DEFINE tot_var_8           INTEGER;
DEFINE tot_var_9           INTEGER;
DEFINE tot_var_10          INTEGER;
DEFINE tot_var_11          INTEGER;
DEFINE tot_var_12          INTEGER;
DEFINE tot_var_13          INTEGER;

DEFINE tot_muj_ndi         INTEGER;
DEFINE tot_muj_0           INTEGER;
DEFINE tot_muj_1           INTEGER;
DEFINE tot_muj_2           INTEGER;
DEFINE tot_muj_3           INTEGER;
DEFINE tot_muj_4           INTEGER;
DEFINE tot_muj_5           INTEGER;
DEFINE tot_muj_6           INTEGER;
DEFINE tot_muj_7           INTEGER;
DEFINE tot_muj_8           INTEGER;
DEFINE tot_muj_9           INTEGER;
DEFINE tot_muj_10          INTEGER;
DEFINE tot_muj_11          INTEGER;
DEFINE tot_muj_12          INTEGER;
DEFINE tot_muj_13          INTEGER;


-- VARIABLES PARA EL MANEJO DE EXCEPCIONES.
DEFINE SQLErr               INTEGER;
DEFINE ISAMError            INTEGER;
DEFINE errorInfo            VARCHAR(76);


-- SI HAY ALGÚN ERROR.
ON EXCEPTION SET SQLErr, ISAMError, errorInfo
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;


BEGIN
   
   -- OBTENER LA INSTITUCION DE ARAUCANO DE LA TABLA "sga_unidades_acad".
FOREACH
   SELECT DISTINCT sga_sedes.instituc_araucano
     INTO l_institu_araucano
     FROM sga_sedes
     WHERE instituc_araucano is not null
   
   -- RECORRER LOS TITULOS DE LAS DISTINTAS UNIDADES ACADEMICAS
   FOREACH
    SELECT DISTINCT int_arau_titulos.titulo_araucano
      INTO l_titulo
      FROM int_arau_titulos,
           sga_titulos
     WHERE sga_titulos.titulo_araucano IS NOT NULL
       AND int_arau_titulos.titulo_araucano = sga_titulos.titulo_araucano
       --AND sga_titulos.tipo_de_titulo IN ('G','P','S')-
      
      
      -- ITERAR POR CANT. DE AÑOS DE ANTERIORIDAD.
      FOR l_index_anter IN ( 0 TO 14 )
         
         -- EN CASO DE SER CERO, CONTAR LOS QUE NO SE DISPONE INFORMACION...
         IF l_index_anter = 14 THEN
            LET l_anio_ant = null;
         ELSE
            LET l_anio_ant = l_index_anter;
         END IF;
         
         -- ITERAR POR SEXO.
         FOR l_index_sexo IN ( 1 TO 2 )
            
            LET l_cant = 0;
            
            -- CONTAR LA CANT. DE PERSONAS EGRESADAS SEGUN EL SEXO Y POR AÑO DE INGRESO.
            IF l_anio_ant IS NULL THEN
               
               -- CONTAR LAS PERSONAS EGRESADAS DE LAS CUALES NO SE DISPONE FECHA DE INGRESO.
               SELECT COUNT(*)
                 INTO l_cant
                 FROM int_arau_egres
                WHERE int_arau_egres.anio_academico  = pAnio
                  AND int_arau_egres.titulo_araucano = l_titulo
                  AND int_arau_egres.sexo            = l_index_sexo
                  AND int_arau_egres.alumno_equiv    = 'S'
                  AND int_arau_egres.anio_ingreso IS NULL
				  AND int_arau_egres.sede IN (select sede 
						from sga_sedes
						where instituc_araucano = l_institu_araucano);
               
            ELSE
               
               -- CALCULAR EL AÑO ACADÉMICO DE INGRESO DE LOS EGRESADOS.
               LET l_pre_anio = (pAnio - l_anio_ant);
               
               -- EN EL CASO DE 13 AÑOS ANTES,
               -- SE CUENTA ESPECIALMENTE DE LOS 13 AÑOS ANTES PARA ATRÁS.
               IF l_index_anter = 13 THEN
                  
                  -- CANTIDAD DE EGRESADOS 13 AÑOS o MÁS, ANTES DE AÑO ACADÉMICO INFORMADO.
                  SELECT COUNT(*)
                    INTO l_cant
                    FROM int_arau_egres
                   WHERE int_arau_egres.anio_academico  = pAnio
                     AND int_arau_egres.titulo_araucano = l_titulo
                     AND int_arau_egres.sexo            = l_index_sexo
                     AND int_arau_egres.alumno_equiv    = 'S'
                     AND int_arau_egres.anio_ingreso   <= l_pre_anio
					 AND int_arau_egres.sede IN (select sede 
						from sga_sedes
						where instituc_araucano = l_institu_araucano);
                  
               ELSE
                  
                  -- CANTIDAD DE EGRESADOS SEGUN EL AÑO ACADÉMICO DE INGRESO.
                  SELECT COUNT(*)
                    INTO l_cant
                    FROM int_arau_egres
                   WHERE int_arau_egres.anio_academico  = pAnio
                     AND int_arau_egres.titulo_araucano = l_titulo
                     AND int_arau_egres.sexo            = l_index_sexo
                     AND int_arau_egres.alumno_equiv    = 'S'
                     AND int_arau_egres.anio_ingreso    = l_pre_anio
					 AND int_arau_egres.sede IN (select sede 
						from sga_sedes
						where instituc_araucano = l_institu_araucano);
                  
               END IF;
               
            END IF;
            
            -- ASIGNACIÓN DE VARIABLES PARA EL INGRESO EN LA TABLA.
            IF l_index_sexo = 1 THEN
               IF l_index_anter = 0 THEN
                  LET tot_var_0 = l_cant;
               ELIF l_index_anter = 1 THEN
                  LET tot_var_1 = l_cant;
               ELIF l_index_anter = 2 THEN
                  LET tot_var_2 = l_cant;
               ELIF l_index_anter = 3 THEN
                  LET tot_var_3 = l_cant;
               ELIF l_index_anter = 4 THEN
                  LET tot_var_4 = l_cant;
               ELIF l_index_anter = 5 THEN
                  LET tot_var_5 = l_cant;
               ELIF l_index_anter = 6 THEN
                  LET tot_var_6 = l_cant;
               ELIF l_index_anter = 7 THEN
                  LET tot_var_7 = l_cant;
               ELIF l_index_anter = 8 THEN
                  LET tot_var_8 = l_cant;
               ELIF l_index_anter = 9 THEN
                  LET tot_var_9 = l_cant;
               ELIF l_index_anter = 10 THEN
                  LET tot_var_10 = l_cant;
               ELIF l_index_anter = 11 THEN
                  LET tot_var_11 = l_cant;
               ELIF l_index_anter = 12 THEN
                  LET tot_var_12 = l_cant;
               ELIF l_index_anter = 13 THEN
                  LET tot_var_13 = l_cant;
			   ELIF l_index_anter = 14 THEN
				  LET tot_var_ndi = l_cant;
               END IF;
            ELSE
               IF l_index_anter = 0 THEN
                  LET tot_muj_0 = l_cant;
               ELIF l_index_anter = 1 THEN
                  LET tot_muj_1 = l_cant;
               ELIF l_index_anter = 2 THEN
                  LET tot_muj_2 = l_cant;
               ELIF l_index_anter = 3 THEN
                  LET tot_muj_3 = l_cant;
               ELIF l_index_anter = 4 THEN
                  LET tot_muj_4 = l_cant;
               ELIF l_index_anter = 5 THEN
                  LET tot_muj_5 = l_cant;
               ELIF l_index_anter = 6 THEN
                  LET tot_muj_6 = l_cant;
               ELIF l_index_anter = 7 THEN
                  LET tot_muj_7 = l_cant;
               ELIF l_index_anter = 8 THEN
                  LET tot_muj_8 = l_cant;
               ELIF l_index_anter = 9 THEN
                  LET tot_muj_9 = l_cant;
               ELIF l_index_anter = 10 THEN
                  LET tot_muj_10 = l_cant;
               ELIF l_index_anter = 11 THEN
                  LET tot_muj_11 = l_cant;
               ELIF l_index_anter = 12 THEN
                  LET tot_muj_12 = l_cant;
               ELIF l_index_anter = 13 THEN
                  LET tot_muj_13 = l_cant;
			   ELIF l_index_anter = 14 THEN
			      LET tot_muj_ndi = l_cant;
               END IF;
            END IF;
            
         END FOR;
         -- FIN DE ITERAR POR SEXO.
         
      END FOR;
      -- FIN DE ITERAR POR CANT. DE AÑOS DE ANTERIORIDAD.
      
      -- INSERTAR LOS REGISTROS EN LA TABLA int_arau_archivo_2
      INSERT INTO int_arau_archivo_2
           VALUES ( pAnio, l_institu_araucano, l_titulo, 'E', 'EPAI', tot_var_ndi, tot_var_0, tot_var_1, tot_var_2, tot_var_3, tot_var_4, tot_var_5,
                    tot_var_6, tot_var_7, tot_var_8, tot_var_9, tot_var_10, tot_var_11, tot_var_12, tot_var_13, tot_muj_ndi, tot_muj_0, tot_muj_1, tot_muj_2,
                    tot_muj_3, tot_muj_4, tot_muj_5, tot_muj_6, tot_muj_7, tot_muj_8, tot_muj_9, tot_muj_10, tot_muj_11, tot_muj_12,
                    tot_muj_13, '1', '1' );
      
   END FOREACH;
   -- FIN DE ITERAR POR TITULO ARAUCANO.
END FOREACH;
-- fin iteracion por institucion
   
END;
END PROCEDURE;
-- ***************************** sp_int_arau_ccu_11 *****************************

