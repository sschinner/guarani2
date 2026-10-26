CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'web_serv_enc_kolla') THEN
		DROP PROCEDURE web_serv_enc_kolla;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- Parámetros de WS:
-- Criterios:
CREATE PROCEDURE "dba".web_serv_enc_kolla(pUnidad_Academica varchar(5), pTipo_documento integer, pNro_documento varchar(15), pTituloAraucano integer, pFechaHora varchar(20), pNroTransaccion varchar(20))
RETURNING 

integer, -- codigo retorno
varchar(255);   -- mensaje

DEFINE vc_unidad_academica like sga_personas.unidad_academica;
DEFINE vc_legajo like sga_alumnos.legajo;
DEFINE vc_nro_inscripcion like sga_personas.nro_inscripcion;
DEFINE vi_codigo_ret integer;
DEFINE vc_carrera varchar(5);
DEFINE vcMsg             varchar(255);   -- mensaje y parametros
DEFINE  vc_titulo varchar(5);

-- Variables para el manejo de excepciones

DEFINE ISAM_Err          integer;

-- blk de excepciones
ON EXCEPTION SET vi_codigo_ret , isam_err, vcMsg
   RETURN  vi_codigo_ret , vcMsg;
END EXCEPTION;

BEGIN

LET vc_unidad_academica = NULL;
LET vc_legajo = NULL;
LET vc_nro_inscripcion = NULL;
LET vi_codigo_ret = 0;
LET vc_carrera = NULL;
LET vcMsg = NULL;
LET vc_titulo = NULL;


-- Obtener el código de UA correspondiente.

select unidad_academica Into vc_unidad_academica
from u820_valor_inicial_sistema
where valor_inicial = pUnidad_Academica
and sistema = 'Kolla'
and campo = 'unidad_academica';


-- Obtener el código de titulo correspondiente al de Araucano. Precondición: el titulo esta steado en Guarani
-- Obtener datos del alumno. Precondición: el alumno esta egresado en Guarani

select per.nro_inscripcion, tit.titulo INTO  vc_nro_inscripcion, vc_titulo
from sga_personas per
	join sga_titulos_otorg tit
		on per.nro_inscripcion = tit.nro_inscripcion
	join sga_titulos tg
		on tit.titulo = tg.titulo
	join int_arau_titulos tara
		on tara.titulo_araucano = tg.titulo_araucano	
where per.tipo_documento = pTipo_documento 
	and per.nro_documento = pNro_documento
	and tara.titulo_araucano = pTituloAraucano ;


IF Not Exists (Select * from u820_encuesta_egr where unidad_academica = vc_unidad_academica and nro_inscripcion = vc_nro_inscripcion and titulo = vc_titulo) Then
 	Insert into u820_encuesta_egr values (vc_unidad_academica, vc_nro_inscripcion, vc_titulo, to_date(pFechaHora,"%d-%m-%Y %R") , 'S', pNroTransaccion);

Else 
	LET vcMsg = "El Egresado ya cumplimento la Encuesta";
	LET vi_codigo_ret = -1;
End if;


RETURN vi_codigo_ret, vcMsg ;

END;
END PROCEDURE;

-- Casos de prueba
{

EXECUTE PROCEDURE web_serv_enc_kolla('ESS', 0, 34360026, 2134, '18-02-2015 15:48', 10000);
}

-- *****************************************************************************
-- Permisos del procedimiento "dba".web_serv_enc_kolla
-- *****************************************************************************
revoke execute on "dba".web_serv_enc_kolla from public;
grant execute on "dba".web_serv_enc_kolla to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".web_serv_enc_kolla to internet; -- Rol de usuario de Internet