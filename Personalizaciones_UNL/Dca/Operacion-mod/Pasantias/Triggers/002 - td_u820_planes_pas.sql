-- ***************************************************************************
-- Tabla  : u820_pasantias
-- Trigger: DELETE
-- ***************************************************************************
--drop procedure "dba".spd_u820_planes_pas;
CREATE PROCEDURE "dba".spd_u820_planes_pas (	O_UNIDAD_ACADEMICA	LIKE u820_planes_pas.UNIDAD_ACADEMICA,
						O_ID_PASANTIA		LIKE u820_planes_pas.ID_PASANTIA,
						O_CARRERA		LIKE u820_planes_pas.CARRERA,
						O_PLAN			LIKE u820_planes_pas.PLAN)
BEGIN
	-- Borra en cascada los registros de la tabla u820_cond_pas

	DELETE FROM u820_cond_pas
	WHERE u820_cond_pas.UNIDAD_ACADEMICA = O_UNIDAD_ACADEMICA AND
		u820_cond_pas.ID_PASANTIA = O_ID_PASANTIA AND
		u820_cond_pas.CARRERA = O_CARRERA AND
		u820_cond_pas.PLAN = O_PLAN;
END;
END PROCEDURE;




CREATE TRIGGER td_u820_planes_pas DELETE ON u820_planes_pas
referencing old as old
FOR EACH ROW (
/*	-- Log de la operacion
	INSERT INTO log_u820_pasantias (UNIDAD_ACADEMICA,CICLO,NOMBRE, usuario, fecha_act, operacion)
	Values(old.UNIDAD_ACADEMICA,old.CICLO,old.NOMBRE, User, Current year to Second, 'D'),*/

	-- Ejecuto el Stored Procedure de DELETE
	EXECUTE PROCEDURE spd_u820_planes_pas (old.UNIDAD_ACADEMICA, old.ID_PASANTIA, old.CARRERA, old.PLAN)
);


