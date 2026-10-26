-- Agrega el control existente 'Controla la reinscripción anual en una c' (15), al Pedido de Certificados (Punto de control 3)
CREATE PROCEDURE verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR RETORNO

ON EXCEPTION 


END EXCEPTION WITH RESUME;

insert into par_cont_x_punto (punto_de_control, control) values (3, 15);
execute procedure sp_confcont_cont (3, 15);
 
	
END
END PROCEDURE;

EXECUTE PROCEDURE verifica_datos();
DROP PROCEDURE verifica_datos();

