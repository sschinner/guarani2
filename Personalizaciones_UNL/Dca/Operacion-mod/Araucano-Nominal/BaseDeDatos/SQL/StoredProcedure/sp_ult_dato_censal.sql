-- ***************************************************************
-- SIU-Guarani 2.9.3
-- Procedure: sp_ult_dato_censal
-- Retorna: Fecha de relevamiento de ultimo dato censal
-- ***************************************************************

-- DROP PROCEDURE sp_ult_dato_censal;
CREATE PROCEDURE sp_ult_dato_censal (
   pUnidad_academica like sga_personas.unidad_academica, 
   pNro_inscripcion  like sga_personas.nro_inscripcion )
 
  RETURNING date;

DEFINE vd_Fecha                DATE;

BEGIN
   LET vd_Fecha = NULL;
   SELECT MAX(fecha_relevamiento)
     INTO vd_Fecha
     FROM sga_datos_censales
    WHERE unidad_academica = pUnidad_academica
      AND nro_inscripcion = pNro_inscripcion;

  RETURN vd_Fecha;
END;
END PROCEDURE;
-- +++++++++++++++++++++++++++++ Fin procedure sp_ult_dato_censal +++++++++++++++++++++

GRANT EXECUTE ON sp_ult_dato_censal TO public;
