{
CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT constrid
			FROM sysconstraints
			WHERE constrname = 'fku820_dat_cen_rama_act' and constrtype = 'R') THEN
		ALTER TABLE sga_datos_censales DROP CONSTRAINT fku820_dat_cen_rama_act;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

ALTER TABLE sga_datos_censales
       ADD CONSTRAINT FOREIGN KEY (det_rama_act_alum)
                             REFERENCES u820_rama_actividad
              CONSTRAINT fku820_dat_cen_rama_act;

}
