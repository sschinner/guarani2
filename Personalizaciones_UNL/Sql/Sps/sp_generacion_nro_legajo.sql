CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_legajo_alumno') THEN
		DROP PROCEDURE sp_legajo_alumno;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- execute procedure "dba".sp_legajo_alumno ('FADU', '26424425', 1);

-- drop procedure "dba".sp_legajo_alumno;
create procedure "dba".sp_legajo_alumno(
	aunidad_academica LIKE sga_alumnos.unidad_academica,
	anro_inscripcion LIKE sga_alumnos.nro_inscripcion,
	acarrera LIKE sga_alumnos.carrera) Returning varchar(16);

define a_cad_ini varchar(16);
define a_cad_resu char (16);
define a_operador1 int;
define a_operador2 int;
define a_aux numeric(15);
define a_aux2 numeric(15);
define a_nro_documento like sga_personas.nro_documento;

begin
on exception in (-1213)
    -- Nro. de documetno no es numericao	
    let a_aux2 = 0;
end exception with resume

LET a_aux2 = NULL;

-- OBTIENE EL NUMERO DE DOCUMENTO
select max(nro_documento) into a_nro_documento
from sga_personas
where nro_inscripcion = anro_inscripcion;

-- Variable solo para probar si es numerico o no el documento: error capturado en el on exception
let a_aux2 = a_nro_documento * 1;

IF a_aux2 = 0 THEN
	Return a_nro_documento;

ELSE
let a_cad_ini = a_nro_documento;
let a_cad_resu = "";

let a_cad_ini = trim(both " " from a_cad_ini );
let a_aux = case when (5-mod(length(a_cad_ini), 4)) = 5 then 1 else (5-mod(length(a_cad_ini), 4)) end;

while not trim(both " " from a_cad_ini ) = ""
	-- quita el primer digito de la cadena del documento y lo pone en el operador
	let a_operador1= substr(a_cad_ini, 1, 1);
	let a_cad_ini = substr(a_cad_ini, 2);

	-- calcula cual es el segundo operador
	if a_aux = 1 then
		let a_operador2 = 9;
	elif a_aux = 2 then
		let a_operador2 = 7;
	elif a_aux = 3 then
		let a_operador2 = 1;
	elif a_aux = 4 then
		let a_operador2 = 3;
	end if;

	-- desplaza el contador para el calculo del segundo operador
	if a_aux < 4 then
		let a_aux = a_aux + 1;
	else
		let a_aux = 1;
	end if;
	
	-- concatena el resultado del producto a la cadena de resultado
	let a_cad_resu = trim(both " " from a_cad_resu) || (a_operador1 * a_operador2);
end while;

let a_aux = 0;
while a_cad_resu*1 >= 10
	let a_cad_ini = a_cad_resu;
	let a_cad_resu = "";
	while not trim(both " " from a_cad_ini ) = ""
		let a_aux = a_aux + 1;
		-- va sumando los dos primeros dígitos y los quita
		if not substr(a_cad_ini, 1, 1) = "" then
			let a_operador1= substr(a_cad_ini, 1, 1);
		else
			let a_operador1= 0;
		end if;
		let a_cad_ini = substr(a_cad_ini, 2);
		if not substr(a_cad_ini, 1, 1) = "" then
			let a_operador2= substr(a_cad_ini, 1, 1);
		else
			let a_operador2= 0;
		end if;
		let a_cad_ini = substr(a_cad_ini, 2);

		let a_cad_resu = trim(both " " from a_cad_resu) || (a_operador1 + a_operador2);
	end while;
end while;

Return a_nro_documento || "-" || trim(both " " from a_cad_resu);
END IF;


end;
end procedure;
-- ******************************************* Fin del procedure sp_legajo_alumno **************************************************

revoke execute on sp_legajo_alumno from public;

grant execute on sp_legajo_alumno to guarani; -- Rol de usuarios de Gestión
grant execute on sp_legajo_alumno to internet; -- Usuario de internet
