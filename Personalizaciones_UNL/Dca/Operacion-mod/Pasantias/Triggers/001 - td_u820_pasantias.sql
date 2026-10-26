

-- ***************************************************************************
-- Tabla  : u820_pasantias
-- Trigger: DELETE
-- ***************************************************************************
--drop procedure "dba".spd_u820_pasantias;
CREATE PROCEDURE "dba".spd_u820_pasantias (	O_UNIDAD_ACADEMICA	LIKE u820_pasantias.UNIDAD_ACADEMICA,
						O_ID_PASANTIA		LIKE u820_pasantias.ID_PASANTIA)
BEGIN
	-- Borra en cascada los registros de la tabla u820_cond_pas y u820_cond_esp_pas
	-- sga_ciclos Contiene sga_materias_ciclo (PARENT DELETE CASCADE) 

	DELETE FROM u820_cond_pas
	WHERE u820_cond_pas.UNIDAD_ACADEMICA = O_UNIDAD_ACADEMICA AND
		u820_cond_pas.ID_PASANTIA = O_ID_PASANTIA;

	DELETE FROM u820_cond_esp_pas
	WHERE u820_cond_esp_pas.UNIDAD_ACADEMICA = O_UNIDAD_ACADEMICA AND
		u820_cond_esp_pas.ID_PASANTIA = O_ID_PASANTIA;

	DELETE FROM u820_planes_pas
	WHERE u820_planes_pas.UNIDAD_ACADEMICA = O_UNIDAD_ACADEMICA AND
		u820_planes_pas.ID_PASANTIA = O_ID_PASANTIA;
END;
END PROCEDURE;




CREATE TRIGGER td_u820_pasantias DELETE ON u820_pasantias
referencing old as old
FOR EACH ROW (
/*	-- Log de la operacion
	INSERT INTO log_u820_pasantias (UNIDAD_ACADEMICA,CICLO,NOMBRE, usuario, fecha_act, operacion)
	Values(old.UNIDAD_ACADEMICA,old.CICLO,old.NOMBRE, User, Current year to Second, 'D'),*/

	-- Ejecuto el Stored Procedure de DELETE
	EXECUTE PROCEDURE spd_u820_pasantias (old.UNIDAD_ACADEMICA,old.ID_PASANTIA)
);


