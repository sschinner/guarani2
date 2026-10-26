CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_intcon_rescumat') THEN
		DROP PROCEDURE sp_intcon_rescumat;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 2.03.1
-- Procedure con_cnt_rescur_mat
-- Ultima version de modificacion: 2.03.2
--
-- Recupera la cantidad de alumnos que cumplieron con el resultado de la cursada  
-- que se pasa por parametro. 
-- 	pTipoResultado = 'P' : Alumnos que promovieron la cursada. --U820: debo sumar los PP
-- 	pTipoResultado = 'A' : Alumnos que aprobaron la cursada. --U820: debo restar los PP
-- 	pTipoResultado = 'R' : Alumnos que reprobaron la cursada.
-- 	pTipoResultado = 'U' : Alumnos ausentes.
--  La cantidad de alumnos es para una unidad academica, carrera y anio academico
--  especifico.
-- *****************************************************************************
-- DROP PROCEDURE "dba".sp_intcon_rescumat;
CREATE PROCEDURE "dba".sp_intcon_rescumat ( pUnidadACademica VARCHAR(5), 
                                      pCarrera         VARCHAR(5),
                                      pMateria         VARCHAR(5),
                                      pAnio            INTEGER,
                                      pTipoResultado   CHAR(1),
		      pCatedra VARCHAR(255)  )
       RETURNING INTEGER;


-- Variables locales
DEFINE iAnio, cnt_cumplen_res, cnt_cumplen_res_PP INTEGER;
DEFINE vPeriodoLectivo   	varchar(20);

-- Variables para el manejo de excepciones
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- Si hay algun error
ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
   RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
END EXCEPTION;

BEGIN
   
   LET cnt_cumplen_res = 0;
   LET cnt_cumplen_res_PP = 0;
   
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   -- Recupero la cantidad de alumnos que cumplen con el 
   -- resultado de la cursada pTipoResultado para una materia determinada.
   -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   SELECT COUNT(sga_det_acta_curs.legajo)
     INTO cnt_cumplen_res
     FROM sga_comisiones,
          sga_actas_cursado,
          sga_det_acta_curs
    WHERE sga_comisiones.unidad_academica = pUnidadACademica
      AND sga_comisiones.anio_academico   = pAnio
      AND sga_comisiones.materia          = pMateria
   
      AND sga_actas_cursado.unidad_academica = sga_comisiones.unidad_academica
      AND sga_actas_cursado.comision         = sga_comisiones.comision
      AND sga_actas_cursado.estado           = 'C' -- Solo cuento las actas cerradas
   
      AND sga_det_acta_curs.unidad_academica = sga_actas_cursado.unidad_academica
      AND sga_det_acta_curs.acta             = sga_actas_cursado.acta
      AND sga_det_acta_curs.estado           = 'A' -- Verifico que el detalle de acta no este invalidado
      AND sga_det_acta_curs.resultado        = pTipoResultado
      AND sga_det_acta_curs.carrera          = pCarrera

      AND sp_docentes_com(sga_comisiones.comision) = pCatedra;


   IF pTipoResultado in ('A', 'P') THEN

	-- U820 recupero los PP
   SELECT COUNT(sga_det_acta_curs.legajo)
     INTO cnt_cumplen_res_PP
     FROM sga_comisiones,
          sga_actas_cursado,
          sga_det_acta_curs
    WHERE sga_comisiones.unidad_academica = pUnidadACademica
      AND sga_comisiones.anio_academico   = pAnio
      AND sga_comisiones.materia          = pMateria
   
      AND sga_actas_cursado.unidad_academica = sga_comisiones.unidad_academica
      AND sga_actas_cursado.comision         = sga_comisiones.comision
      AND sga_actas_cursado.estado           = 'C' -- Solo cuento las actas cerradas
   
      AND sga_det_acta_curs.unidad_academica = sga_actas_cursado.unidad_academica
      AND sga_det_acta_curs.acta             = sga_actas_cursado.acta
      AND sga_det_acta_curs.estado           = 'A' -- Verifico que el detalle de acta no este invalidado
      AND sga_det_acta_curs.cond_regularidad  = 7
      AND sga_det_acta_curs.carrera          = pCarrera

      AND sp_docentes_com(sga_comisiones.comision) = pCatedra;

	IF pTipoResultado = 'A' THEN
		LET cnt_cumplen_res = cnt_cumplen_res - cnt_cumplen_res_PP;
	ELSE
		LET cnt_cumplen_res = cnt_cumplen_res + cnt_cumplen_res_PP;
	END IF;
   
   END IF;

   
   -- Cantidad de alumnos que tienen el resultado pTipoResultado
   RETURN cnt_cumplen_res;	
   
END;
END PROCEDURE;
-- ************************ Fin del procedure sp_intcon_rescumat ************************

-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 1.3.0
-- *******************************************************************************
Execute procedure dba.sp_cambiaparametro( 'ifz00028', 1 , 4, "dr820_materias_cursantes_recursante_fadu" );
Execute procedure dba.sp_cambiaparametro( 'ifz00028', 1 , 5, "dl820_materias_cursantes_recursante_fadu" );

-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 1.3.0
-- *******************************************************************************
Execute procedure dba.sp_cambiaparametro( 'ifz00013', 1 , 4, "dr820_coneau_resultado_cursadas_fadu" );
Execute procedure dba.sp_cambiaparametro( 'ifz00013', 1 , 5, "dl820_coneau_resultado_cursadas_fadu" );

-- *******************************************************************************
-- SIU - SIU - Guaraní. Sistema de Gestión Académica
-- Versión 1.3.0
-- *******************************************************************************
Execute procedure dba.sp_cambiaparametro( 'ifz00015', 1 , 4, "dr820_coneau_resultado_examenes_fadu" );
Execute procedure dba.sp_cambiaparametro( 'ifz00015', 1 , 5, "dl820_coneau_resultado_examenes_fadu" );

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_intcon_rescumat;
-- *****************************************************************************
revoke execute on "dba".sp_intcon_rescumat from public;
grant execute on "dba".sp_intcon_rescumat to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_intcon_rescumat to internet; -- Rol de usuario de Internet