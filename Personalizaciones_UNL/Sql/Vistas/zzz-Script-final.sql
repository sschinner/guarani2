-- *************************************************************************************
-- ACTUALIZACION DE LA TABLA DE VERSIONES.
update app_versiones set fecha_actualiz = CURRENT YEAR TO SECOND
where version = "CNV2.09.2" and script_corrido = 33;
-- *************************************************************************************
