CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_intcon_incu_mat') THEN
		DROP PROCEDURE sp_intcon_incu_mat;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1
-- Procedure con_cnt_inscur_mat
-- Ultima version de modificacion: 2.03.2
-- 
-- Recupera cantidad de inscriptos aceptados y exceptuados a una materia 
-- en los períodos lectivos del año academico y carrera pasado como parametro.
-- *****************************************************************************
-- DROP PROCEDURE "dba".sp_intcon_incu_mat;
CREATE PROCEDURE "dba".sp_intcon_incu_mat ( pUnidadACademica VARCHAR(5),
                                      pCarrera         VARCHAR(5),
                                      pMateria         VARCHAR(5),
                                      pAnio            INTEGER,
		      pCatedra VARCHAR(255) )
       RETURNING INTEGER; -- Cantidad de inscriptos


-- Variables locales
DEFINE iAnio, cnt_inscriptos, cnt_insc_materia 	smallint;
DEFINE vPeriodoLectivo   	varchar(20);
DEFINE vMateria		varchar(5);
DEFINE vNombreCarrera  LIKE sga_carreras.nombre;

-- Variables para el manejo de excepciones
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN
   
   LET cnt_inscriptos = 0;
   
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- Recupero la cantidad de inscriptos a la materia del periodo lectivo
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   SELECT  COUNT(distinct sga_insc_cursadas.legajo)
     INTO cnt_inscriptos
     FROM sga_insc_cursadas,
          sga_comisiones
    WHERE sga_insc_cursadas.unidad_academica = pUnidadAcademica
      AND sga_insc_cursadas.carrera = pCarrera
      AND sga_insc_cursadas.comision = sga_comisiones.comision
      AND (sga_insc_cursadas.estado = 'A' or sga_insc_cursadas.estado='E')

      AND sga_comisiones.anio_academico = pAnio
      AND sga_comisiones.unidad_academica = pUnidadAcademica
      AND sga_comisiones.materia = pMateria
      AND sp_docentes_com(sga_comisiones.comision) = pCatedra;
   
   -- Cantidad de inscriptos
   RETURN cnt_inscriptos;	
   
END;
END PROCEDURE;
-- ************************ Fin del procedure con_cnt_inscur_mat ************************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_intcon_incu_mat
-- *****************************************************************************
revoke execute on "dba".sp_intcon_incu_mat from public;
grant execute on "dba".sp_intcon_incu_mat to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_intcon_incu_mat to internet; -- Rol de usuario de Internet