CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT idxname
			FROM sysindexes
			WHERE idxname = 'in820_detalle_acta') THEN
		DROP INDEX in820_detalle_acta;
	END IF;

	IF EXISTS (SELECT idxname
			FROM sysindexes
			WHERE idxname = 'in820_examenes_equiv ') THEN
		DROP INDEX in820_examenes_equiv ;
	END IF;
	IF EXISTS (SELECT idxname
			FROM sysindexes
			WHERE idxname = 'in820_det_acta_promo') THEN
		DROP INDEX in820_det_acta_promo;
	END IF;
	IF EXISTS (SELECT idxname
			FROM sysindexes
			WHERE idxname = 'in820_promo_equiv') THEN
		DROP INDEX in820_promo_equiv ;
	END IF;
	IF EXISTS (SELECT idxname
			FROM sysindexes
			WHERE idxname = 'in820_equiv_otorgada') THEN
		DROP INDEX in820_equiv_otorgada;
	END IF;
	IF EXISTS (SELECT idxname
			FROM sysindexes
			WHERE idxname = 'in820_equiv_equiv') THEN
		DROP INDEX in820_equiv_equiv ;
	END IF;


	IF EXISTS (SELECT idxname
			FROM sysindexes
			WHERE idxname = 'in820_otras_mat_apro') THEN
		DROP INDEX in820_otras_mat_apro;
	END IF;
		
	IF EXISTS (SELECT idxname
			FROM sysindexes
			WHERE idxname = 'idx820_cur_com') THEN
		DROP INDEX idx820_cur_com;
	END IF;

END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *******************************************************************************************
-- Indice sobre la tabla sga_detalle_acta por Legajo
-- *******************************************************************************************
create index in820_detalle_acta on sga_detalle_acta (legajo);

-- *******************************************************************************************
-- Indice sobre la tabla sga_examenes_equiv por Legajo
-- *******************************************************************************************
create index in820_examenes_equiv on sga_examenes_equiv (legajo);

-- *******************************************************************************************
-- Indice sobre la tabla sga_det_acta_promo por Legajo
-- *******************************************************************************************
create index in820_det_acta_promo on sga_det_acta_promo (legajo);
 
-- *******************************************************************************************
-- Indice sobre la tabla sga_promo_equiv por Legajo
-- *******************************************************************************************
create index in820_promo_equiv on sga_promo_equiv (legajo);

-- *******************************************************************************************
-- Indice sobre la tabla sga_equiv_otorgada por Legajo
-- *******************************************************************************************
create index in820_equiv_otorgada on sga_equiv_otorgada (legajo);

-- *******************************************************************************************
-- Indice sobre la tabla sga_equiv_equiv por Legajo
-- *******************************************************************************************
create index in820_equiv_equiv on sga_equiv_equiv (legajo);

-- *******************************************************************************************
-- Indice sobre la tabla sga_otras_mat_apro por Legajo
-- *******************************************************************************************
create index in820_otras_mat_apro on sga_otras_mat_apro (legajo);

-- *******************************************************************************************
-- Indice sobre la tabla sga_insc_cursadas por Comision, Legajo
-- *******************************************************************************************
create index idx820_cur_com on sga_insc_cursadas(comision,legajo)