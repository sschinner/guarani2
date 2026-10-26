CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_alu_reg_materia') THEN
		DROP PROCEDURE sp_alu_reg_materia;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ***********************************************************************************
-- SIU-GUARANI
--
-- Procedure sp_alu_reg_materia
-- Version 1.11.0
--
-- Verifica si el Alumno tiene la cursada de la Materia y aun es Regular en la misma!
--
-- Ultima version de modfiicacion: 2.0.3 , 2.04.0, 2.6.0
--
-- Ahora la fecha contra la que se controla la regularidad se pasa en un nuevo parametro
-- Para usar el SP con la funcionalidad anterior agregar TODAY como ultimo parametro.
-- Esta funcionalidad se agrego para determinar si para la fecha de un examen la
-- regularidad va a estar vigente.
-- ***********************************************************************************

CREATE PROCEDURE "dba".sp_alu_reg_materia ( pUnidadAcademica LIKE sga_alumnos.unidad_academica,
                                      pCarrera LIKE sga_alumnos.carrera,
                                      pLegajo  LIKE sga_alumnos.legajo,
                                      pMateria LIKE sga_materias.materia,
                                      pFecha   LIKE sga_prestamos.fecha )
          RETURNING INTEGER;

/*
 Retorna:  
	0 -- No es regular
	1 -- Es Regular en la materia
*/

DEFINE vi_Retorno  INTEGER;
DEFINE vCierreParcial LIKE sga_param_sistema.valor;
DEFINE n_fecha Date;

BEGIN

    LET vi_Retorno = 0;


-- Obtiene la ultima regularidad adquirida.
	SELECT max (fecha_regularidad)  
		Into n_fecha
		FROM sga_cursadas
		WHERE legajo= pLegajo
		AND materia = pMateria;

   -- verifica en la vista de cursadas.
   SELECT COUNT(*)
     INTO vi_Retorno
     FROM sga_cursadas
    WHERE sga_cursadas.unidad_academica = pUnidadAcademica
      AND sga_cursadas.carrera = pCarrera
      AND sga_cursadas.legajo  = pLegajo
      AND sga_cursadas.resultado        IN ('A', 'P')
      AND ((sga_cursadas.fin_vigencia_regul >= pFecha) OR (sga_cursadas.fin_vigencia_regul IS NULL))
      AND sga_cursadas.estado = 'A'
      AND sga_cursadas.materia  = pMateria
	-- Obtiene la ultima regularidad adquirida.
	AND sga_cursadas.fecha_regularidad = n_fecha;

   IF vi_Retorno <= 0 THEN
	-- Verifico si trabaja con cierres parciales. Busco fechas de las regularidades
	EXECUTE PROCEDURE sp_param_sistema('cierre_parcial_acta_cursados') INTO vCierreParcial;
	IF vCierreParcial = 'S' THEN
		-- Verifico si la regularidad esta Aprobada en un Cierre Parcial de Actas de Cursados
        -- en todas las carreras de la persona. Req aproabada antes de la fecha del Examen
        EXECUTE PROCEDURE sp_tieneregparcial(pUnidadAcademica, pCarrera, pLegajo, pMateria, pFecha) INTO vi_Retorno;
	END IF;
   END IF;

   IF vi_Retorno < 0 THEN
	LET vi_Retorno = 0;
   ELIF vi_Retorno >= 1 THEN
	-- Por si tiene mas de una regularidad vigente.
	LET vi_Retorno = 1;
   END IF;

   RETURN vi_Retorno;
END;
END PROCEDURE;
-- *************** Fin del procedimiento "dba".sp_alu_reg_materia ********************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_alu_reg_materia 
-- *****************************************************************************
revoke execute on "dba".sp_alu_reg_materia from public;
grant execute on "dba".sp_alu_reg_materia to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_alu_reg_materia to internet; -- Rol de usuario de Internet