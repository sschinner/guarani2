CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_gen_nro_acta') THEN
		DROP PROCEDURE sp_gen_nro_acta;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **********************************************************************
-- Genera un Nro de Acta de Exámenes
--
-- Recibe:	- Unidad Academica
--		- materia
--		- anio_academico
--		- turno_examen
--		- mesa_examen
--		- llamado
--		- tipo_acta
--		- libro
--					 
--
-- Retorna:	- Varchar(10) (Nro de Acta)
-- **********************************************************************


create procedure "dba".sp_gen_nro_acta
   (p_unidad_academica  LIKE sga_actas_examen.unidad_academica,
    p_materia LIKE sga_actas_examen.materia ,
    p_anio_academico LIKE sga_actas_examen.anio_academico ,
    p_turno_examen LIKE sga_actas_examen.turno_examen ,
    p_mesa_examen  LIKE sga_actas_examen.mesa_examen ,
    p_llamado  LIKE sga_actas_examen.llamado ,
    p_tipo_acta    LIKE  sga_actas_examen.tipo_acta,
    p_libro    LIKE  sga_actas_examen.libro) 
    returning varchar(16);

	DEFINE  v_acta varchar(32);
	DEFINE  v_acta_c varchar(32);
	DEFINE  v_anio_academico LIKE sga_actas_examen.anio_academico;
	DEFINE  v_carrera LIKE sga_actas_examen.carrera;
   --------------------------------------------------------------
   -- Verifico que existe una entrada en la tabla de números para el anio academico
   --------------------------------------------------------------
	select anio_academico, carrera into v_anio_academico, v_carrera
	from sga_mesas_examen
	where unidad_academica = p_unidad_academica
		and anio_academico = p_anio_academico
		and turno_examen = p_turno_examen
		and mesa_examen = p_mesa_examen
		and materia = p_materia;
	
	if not exists( 	select *
			from u820_nro_promo
			where anio_academico = v_anio_academico) then

		insert into u820_nro_promo
		values (v_anio_academico, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
	end if;

	if p_tipo_acta = "R" then
		select nro_rec into v_acta
		from u820_nro_promo
		where anio_academico = v_anio_academico;

		update u820_nro_promo
		set nro_rec = nro_rec + 1
		where anio_academico = v_anio_academico;

--		let v_acta_c = "REC" || mod(v_anio_academico, 100) * 100000 + v_acta;
		let v_acta_c = "REC" || lpad(mod(v_anio_academico, 100), 2, "0") || lpad(v_acta, 5, "0");
	else
		if v_carrera = "00001" then
			select nro_01 into v_acta
			from u820_nro_promo
			where anio_academico = v_anio_academico;

			let v_carrera = "1";

			update u820_nro_promo
			set nro_01 = nro_01 + 1
			where anio_academico = v_anio_academico;
		else
			if v_carrera = "00002" then
				select nro_02 into v_acta
				from u820_nro_promo
				where anio_academico = v_anio_academico;

				let v_carrera = "2";

				update u820_nro_promo
				set nro_02 = nro_02 + 1
				where anio_academico = v_anio_academico;
			else
				if v_carrera = "00003" then
					select nro_03 into v_acta
					from u820_nro_promo
					where anio_academico = v_anio_academico;

					let v_carrera = "3";
	
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

							let v_carrera = "5";
	
							update u820_nro_promo
							set nro_05 = nro_05 + 1
							where anio_academico = v_anio_academico;
						else
							if v_carrera = "00006" then
								select nro_06 into v_acta
								from u820_nro_promo
								where anio_academico = v_anio_academico;

								let v_carrera = "6";
	
								update u820_nro_promo
								set nro_06 = nro_06 + 1
								where anio_academico = v_anio_academico;
							else
								if v_carrera = "00007" then
									select nro_07 into v_acta
									from u820_nro_promo
									where anio_academico = v_anio_academico;
	
									let v_carrera = "7";

									update u820_nro_promo
									set nro_07 = nro_07 + 1
									where anio_academico = v_anio_academico;
								else
									if v_carrera = "00008" then
										select nro_08 into v_acta
										from u820_nro_promo
										where anio_academico = v_anio_academico;

										let v_carrera = "8";
	
										update u820_nro_promo
										set nro_08 = nro_08 + 1
										where anio_academico = v_anio_academico;
									else
										if v_carrera = "00009" then
											select nro_09 into v_acta
											from u820_nro_promo
											where anio_academico = v_anio_academico;

											let v_carrera = "9";
	
											update u820_nro_promo
											set nro_09 = nro_09 + 1
											where anio_academico = v_anio_academico;
										else
											if v_carrera = "00010" then
												select nro_10 into v_acta
												from u820_nro_promo
												where anio_academico = v_anio_academico;

												let v_carrera = "10";
	
												update u820_nro_promo
												set nro_10 = nro_10 + 1
												where anio_academico = v_anio_academico;
											else
												if v_carrera = "00011" then
													select nro_11 into v_acta
													from u820_nro_promo
													where anio_academico = v_anio_academico;

													let v_carrera = "11";
		
													update u820_nro_promo
													set nro_11 = nro_11 + 1
													where anio_academico = v_anio_academico;
												else
													if v_carrera = "00012" then
														select nro_12 into v_acta
														from u820_nro_promo
														where anio_academico = v_anio_academico;

														let v_carrera = "12";
	
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
															if v_carrera = "90007" then
																let v_carrera = "97";
															end if;
	
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
		let v_acta_c = v_acta;
	end if;

RETURN v_acta_c;
end procedure;

-- *************** Fin del procedimiento "dba".sp_gen_nro_acta ******************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_gen_nro_acta
-- *****************************************************************************
revoke execute on "dba".sp_gen_nro_acta from public;
grant execute on "dba".sp_gen_nro_acta to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_gen_nro_acta to internet; -- Rol de usuario de Internet
