CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_intcon_ifz016') THEN
		DROP PROCEDURE sp_intcon_ifz016;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1, 2.9.2
-- Procedure sp_coneau_cuadro16
-- *****************************************************************************
-- DROP PROCEDURE sp_intcon_ifz016;
CREATE PROCEDURE "dba".sp_intcon_ifz016 (pAnioHasta   INTEGER)

	RETURNING varchar(5), 	   -- unidad_academica
		varchar(5), 	   -- carrera
		varchar(60), 	   -- nombre carrera
	          integer,         -- Alumnos 8 años antes
	          integer,         -- Alumnos 7 años antes
	          integer,         -- Alumnos 6 años antes
	          integer,         -- Alumnos 5 años antes
	          integer,         -- Alumnos 4 años antes
	          integer,         -- Alumnos 3 años antes
	          integer,         -- Alumnos 2 años antes
	          integer,         -- Alumnos 1 años antes
	          integer;         -- Alumnos en el año

-- Variables locales
DEFINE iAnio            INTEGER;
DEFINE cnt_alumnos8     INTEGER;
DEFINE cnt_alumnos7     INTEGER;
DEFINE cnt_alumnos6     INTEGER;
DEFINE cnt_alumnos5     INTEGER;
DEFINE cnt_alumnos4     INTEGER;
DEFINE cnt_alumnos3     INTEGER;
DEFINE cnt_alumnos2     INTEGER;
DEFINE cnt_alumnos1     INTEGER;
DEFINE cnt_alumnos0     INTEGER;
DEFINE cnt_alumnos      INTEGER;
DEFINE vNombreCarrera   LIKE sga_carreras.nombre;
DEFINE vCarrera         LIKE sga_carreras.carrera;
DEFINE vUA              LIKE sga_carreras.unidad_academica;


-- Variables para el manejo de excepciones
DEFINE SQLErr             	INTEGER;
DEFINE ISAMError          	INTEGER;
DEFINE errorInfo          	varchar(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
	RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN
   
   FOREACH
    SELECT unidad_academica, carrera, nombre
      INTO vUA, vCarrera, vNombreCarrera
      FROM sga_carreras
     --WHERE tipo_de_carrera = 'C'
      
      LET iAnio = pAnioHasta - 8;
      
      WHILE iAnio <= pAnioHasta
         
         LET cnt_alumnos = 0;
         
         -- Cantidad de ALUMNOS de la carrera
         EXECUTE PROCEDURE sp_intcon_alu_car (vUA, vCarrera, iAnio) INTO cnt_alumnos;
         
         IF iAnio = pAnioHasta  - 8 THEN
            LET cnt_alumnos8 = cnt_alumnos;
         ELIF iAnio = pAnioHasta  - 7 THEN
            LET cnt_alumnos7 = cnt_alumnos;
         ELIF iAnio = pAnioHasta  - 6 THEN
            LET cnt_alumnos6 = cnt_alumnos;
         ELIF iAnio = pAnioHasta  - 5 THEN
            LET cnt_alumnos5 = cnt_alumnos;
         ELIF iAnio = pAnioHasta  - 4 THEN
            LET cnt_alumnos4 = cnt_alumnos;
         ELIF iAnio = pAnioHasta  - 3 THEN
            LET cnt_alumnos3 = cnt_alumnos;
         ELIF iAnio = pAnioHasta  - 2 THEN
            LET cnt_alumnos2 = cnt_alumnos;
         ELIF iAnio = pAnioHasta  - 1 THEN
            LET cnt_alumnos1 = cnt_alumnos;
         ELSE
            LET cnt_alumnos0 = cnt_alumnos;
         END IF;
         
         LET iAnio = iAnio + 1;
         
      END WHILE;  
   
      RETURN vUA, vCarrera, vNombreCarrera, cnt_alumnos8, cnt_alumnos7, cnt_alumnos6, cnt_alumnos5, cnt_alumnos4, cnt_alumnos3, cnt_alumnos2, cnt_alumnos1, cnt_alumnos0  WITH RESUME;	
   
   END FOREACH;
   
END;
END PROCEDURE;
-- ************************ Fin del procedure sp_coneau_cuadro16 ************************

revoke execute on sp_intcon_ifz016 from public;

grant execute on sp_intcon_ifz016 to guarani; -- Rol de usuarios de Gestión
grant execute on sp_intcon_ifz016 to internet; -- Usuario de internet
