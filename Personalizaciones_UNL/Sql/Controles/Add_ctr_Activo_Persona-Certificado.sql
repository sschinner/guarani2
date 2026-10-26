-- Agrega el control existente 'Verifica que la Persona sea Alumno Activo' (35), al Pedido de Certificados (Punto de control 25)
CREATE PROCEDURE verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR RETORNO
ON EXCEPTION 

END EXCEPTION WITH RESUME;

insert into par_cont_x_punto (punto_de_control, control) values (25, 35);
execute procedure sp_confcont_cont (25, 35);
	
END
END PROCEDURE;

EXECUTE PROCEDURE verifica_datos();
DROP PROCEDURE verifica_datos();