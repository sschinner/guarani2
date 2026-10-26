CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_nro_acta_prom') THEN
		DROP PROCEDURE sp_nro_acta_prom;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **********************************************************************
-- Genera un Nro de Acta de Promocionales
--
-- Recibe:   - Unidad Academica
--	 - Comision
--	 - Tipo de Acta        (P - Promocionales, .....)				 
--	 - Libro               (puede ser Nulo)				 
--					 
--
-- Retorna:  - Integer		(Nro de Acta)
-- **********************************************************************

-- execute procedure "dba".sp_nro_acta_prom ('FIQ', 11638 , 'P', null ); 

create procedure  "dba".sp_nro_acta_prom
	(p_unidad_academica  LIKE sga_actas_promo.unidad_academica, 
	p_comision  LIKE sga_actas_promo.comision, 
	p_tipo_acta  LIKE sga_actas_promo.tipo,
	p_libro  LIKE sga_actas_promo.libro) 
	returning integer;

	DEFINE  v_acta LIKE sga_actas_promo.acta;
	DEFINE  v_anio_academico LIKE sga_comisiones.anio_academico;
	DEFINE  v_carrera LIKE sga_comisiones.carrera;
   --------------------------------------------------------------
   -- Verifico que existe una entrada en la tabla de números para el anio academico
   --------------------------------------------------------------
	select anio_academico, carrera into v_anio_academico, v_carrera
	from sga_comisiones
	where comision = p_comision;
	
	if not exists( 	select *
			from u820_nro_promo
			where anio_academico = v_anio_academico) then

		insert into u820_nro_promo
		values (v_anio_academico,  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
	end if;

	if p_tipo_acta <> "P" then
		select nro_rec into v_acta
		from u820_nro_promo
		where anio_academico = v_anio_academico;

		update u820_nro_promo
		set nro_rec = nro_rec + 1
		where anio_academico = v_anio_academico;

		let v_acta = 9999 * 100000 + v_acta;
	else

		if v_carrera = "00001" then
			select nro_01 into v_acta
			from u820_nro_promo
			where anio_academico = v_anio_academico;
	
			update u820_nro_promo
			set nro_01 = nro_01 + 1
			where anio_academico = v_anio_academico;
		else
			if v_carrera = "00002" then
				select nro_02 into v_acta
				from u820_nro_promo
				where anio_academico = v_anio_academico;
	
				update u820_nro_promo
				set nro_02 = nro_02 + 1
				where anio_academico = v_anio_academico;
			else
				if v_carrera = "00003" then
					select nro_03 into v_acta
					from u820_nro_promo
					where anio_academico = v_anio_academico;
	
					update u820_nro_promo
					set nro_03 = nro_03 + 1
					where anio_academico = v_anio_academico;
				else
					if v_carrera = "90006" then
						-- Utilizo la variable nro_04 porque no existe la carrera 00004
						select nro_04 into v_acta
						from u820_nro_promo
						where anio_academico = v_anio_academico;
						
						let v_carrera = "96";
	
						update u820_nro_promo
						set nro_04 = nro_04 + 1
						where anio_academico = v_anio_academico;
					else
						if v_carrera = "00005" then
							select nro_05 into v_acta
							from u820_nro_promo
							where anio_academico = v_anio_academico;

							update u820_nro_promo
							set nro_05 = nro_05 + 1
							where anio_academico = v_anio_academico;
						else
							if v_carrera = "00006" then
								select nro_06 into v_acta
								from u820_nro_promo
								where anio_academico = v_anio_academico;

								update u820_nro_promo
								set nro_06 = nro_06 + 1
								where anio_academico = v_anio_academico;
							else
								if v_carrera = "00007" then
									select nro_07 into v_acta
									from u820_nro_promo
									where anio_academico = v_anio_academico;

									update u820_nro_promo
									set nro_07 = nro_07 + 1
									where anio_academico = v_anio_academico;
								else
									if v_carrera = "00008" then
										select nro_08 into v_acta
										from u820_nro_promo
										where anio_academico = v_anio_academico;
	
										update u820_nro_promo
										set nro_08 = nro_08 + 1
										where anio_academico = v_anio_academico;
									else
										if v_carrera = "00009" then
											select nro_09 into v_acta
											from u820_nro_promo
											where anio_academico = v_anio_academico;
	
											update u820_nro_promo
											set nro_09 = nro_09 + 1
											where anio_academico = v_anio_academico;
										else
											if v_carrera = "00010" then
												select nro_10 into v_acta
												from u820_nro_promo
												where anio_academico = v_anio_academico;
	
												update u820_nro_promo
												set nro_10 = nro_10 + 1
												where anio_academico = v_anio_academico;
											else
												if v_carrera = "00011" then
													select nro_11 into v_acta
													from u820_nro_promo
													where anio_academico = v_anio_academico;
		
													update u820_nro_promo
													set nro_11 = nro_11 + 1
													where anio_academico = v_anio_academico;
												else
													if v_carrera = "00012" then
														select nro_12 into v_acta
														from u820_nro_promo
														where anio_academico = v_anio_academico;
	
														update u820_nro_promo
														set nro_12 = nro_12 + 1
														where anio_academico = v_anio_academico;
													else
														if v_carrera = "90000" then
															select nro_14 into v_acta
															from u820_nro_promo
															where anio_academico = v_anio_academico;
										
															let v_carrera = "90";
											
															update u820_nro_promo
															set nro_14 = nro_14 + 1
															where anio_academico = v_anio_academico;
														else 
															select nro into v_acta
															from u820_nro_promo
															where anio_academico = v_anio_academico;
					
															update u820_nro_promo
															set nro = nro + 1
															where anio_academico = v_anio_academico;
														end if;
													end if;
												end if;
											end if;
										end if;
									end if;
								end if;
							end if;
						end if;	
					end if;
				end if;
			end if;
		end if;
		if v_carrera is null then
			let v_carrera = 0;
		end if;

--		let v_acta = v_carrera * 10000000 + mod(v_anio_academico, 100) * 100000 + v_acta;
		let v_acta = v_carrera || lpad(mod(v_anio_academico, 100), 2, "0") || lpad(v_acta, 5, "0");
		
	end if;
RETURN v_acta;
end procedure;

-- *************** Fin del procedimiento "dba".sp_nro_acta_prom ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_nro_acta_prom
-- *****************************************************************************
revoke execute on "dba".sp_nro_acta_prom from public;
grant execute on "dba".sp_nro_acta_prom to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_nro_acta_prom to internet; -- Rol de usuario de Internet