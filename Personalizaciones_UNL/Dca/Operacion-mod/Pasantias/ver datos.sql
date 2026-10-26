select * from u820_pasantias;

select * from u820_planes_pas;

select * from u820_cond_pas;

select * from u820_cond_esp_pas;

select * from u820_solicit_pas;

select * from u820_insc_pas;

select * from aca_usuarios_ag
where identificacion = '29048285'

select * from sga_alumnos
where legajo = '21721953-7';

select * from u820_insc_baja_pas;


-- 25519198
Insert into acc_parametros_net values ('netpas03', 1, 'a_alumnos/elegirCarrera.php', null, 'Elegir Carrera');
Insert into acc_parametros_net values ('netpas03', 2, 'a_alumnos/u820_elegirInscPasantia.php', null, 'Inscripciones a Pasantías');
Insert into acc_parametros_net values ('netpas03', 3, 'a_alumnos/u820_inscribirsePasantia.php', null, 'Resultado Insc. a Pasantías');

select * from par_puntos_x_pag where operacion = 'u820%';

-- select legajo from sga_alumnos where carrera in ("03", "04") and plan = "1999" group by legajo having count (*) = 2

execute procedure sp820_inscpas('FICH', '1353');
execute procedure sp820_pasvig('FICH', '1248');

-- delete from u820_pasantias;

-- delete from u820_planes_pas;

-- delete from u820_cond_pas;

-- delete from u820_cond_esp_pas;

-- delete from u820_solicit_pas;

-- delete from u820_insc_pas;

-- delete from u820_insc_baja_pas;
