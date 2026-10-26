CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_tesis_rep_tesis') THEN
		DROP PROCEDURE sp820_tesis_rep_tesis;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **************************************************************************
-- Proceso: sp_tesis_rep_tesis
-- Version 2.06.0
--
-- Reporte de las tesis y sus estados.
-- **************************************************************************
CREATE PROCEDURE "dba".sp820_tesis_rep_tesis( pTesis          integer,
                                     pEstado         varchar(5),
                                     pVencida        char(1) )
       RETURNING varchar(255), -- titulo
	varchar(255), -- estado actual
	date,  -- alta
	varchar(255),  -- alumno
	date, -- vencimiento
	date, -- aprobacion
	date, -- fecha estado
	varchar(255), -- estado anterior
	date; -- fecha en que llego al estado anterior

-- vars para la respuesta
DEFINE iStatus           smallint;       -- status
DEFINE vcMsg             varchar(255);   -- mensaje y parametros

-- vars para el manejo de excepciones
DEFINE sql_err           integer;
DEFINE isam_err          integer;
DEFINE error_info        varchar(76);

-- vars locales
DEFINE vi_Tesis          integer;
DEFINE vc_Titulo         varchar(255);
DEFINE vc_Estado         varchar(50);
DEFINE vc_Estado_Anterior         varchar(50);
DEFINE vc_Alumnos        varchar(255);   -- devuelvo lista de alumnos
DEFINE vd_FechaVenc      date;
DEFINE vd_Fecha          date;
DEFINE vd_FechaAprob          date;
DEFINE vd_FechaAlta          date;
DEFINE vd_FechaEstado          date;
DEFINE vd_fechaEstadoAnterior date;

BEGIN
  

LET vd_fechaEstadoAnterior = NULL;

   FOREACH
    SELECT DISTINCT dba.sga_tesis.tesis,
           dba.sga_tesis.fecha_vencimiento, fecha_alta, fecha_aprobacion, estado_actual.fecha, sga_tesis_estados.nombre, estado_anterior.fecha
      INTO vi_Tesis,
           vd_FechaVenc, vd_FechaAlta, vd_FechaAprob, vd_FechaEstado, vc_Estado_Anterior, vd_fechaEstadoAnterior
      FROM dba.sga_tesis,
           dba.sga_tesis_alumnos,
           dba.sga_tesis_tutores,
	dba.sga_tesis_hist estado_actual,
	dba.sga_tesis_estados,
	dba.sga_tesis_hist estado_anterior,
           OUTER(dba.sga_resoluciones)
     WHERE dba.sga_tesis_alumnos.tesis = sga_tesis.tesis
       AND dba.sga_tesis_tutores.tesis = sga_tesis.tesis

	AND dba.sga_tesis.tesis = estado_actual.tesis
	AND  estado_actual.fecha = (select max(fecha) from sga_tesis_hist where tesis = dba.sga_tesis.tesis AND estado_nuevo = dba.sga_tesis.estado )
	AND  estado_actual.estado_anterior = sga_tesis_estados.estado

	AND dba.sga_tesis.tesis = estado_anterior.tesis
	AND  estado_anterior.fecha = (select max(fecha) from sga_tesis_hist where tesis = estado_actual.tesis AND estado_nuevo = estado_actual.estado_anterior )
	AND  estado_actual.estado_anterior = sga_tesis_estados.estado

       AND dba.sga_resoluciones.resolucion = sga_tesis.resolucion
       AND ( (dba.sga_tesis.estado = pEstado ) OR ( pEstado = '' ) OR ( pEstado IS NULL ) )
      
      -- control que solo muestre las vencidas.
      IF pVencida = 'S' THEN
         
         LET vd_Fecha = TODAY;
         IF (vd_FechaVenc > vd_Fecha) THEN
            CONTINUE FOREACH;
         END IF;
         
         IF (vd_FechaVenc is null) THEN
            CONTINUE FOREACH;
         END IF;
         
      END IF;
      
      -- selecciono los datos de la tesis.
      SELECT dba.sga_tesis.titulo,
             dba.sga_tesis_estados.nombre
        INTO vc_Titulo,
             vc_Estado
        FROM dba.sga_tesis,
             dba.sga_tesis_estados
       WHERE dba.sga_tesis.tesis = vi_Tesis
         AND dba.sga_tesis_estados.estado = sga_tesis.estado;
      
      -- selecciono los alumnos de la tesis.
      EXECUTE PROCEDURE sp_tesis_alumnos ( vi_Tesis ) INTO vc_Alumnos;
            
      -- retorno de las filas
      RETURN vc_Titulo, vc_Estado, vd_FechaVenc, vc_Alumnos, vd_FechaAlta, vd_FechaAprob,  vd_FechaEstado, vc_Estado_Anterior, vd_fechaEstadoAnterior WITH RESUME;
      
   END FOREACH;
   
END;
END PROCEDURE;

-- ********************** FIN DEL PROCEDURE sp820_tesis_rep_tesis **********************
revoke execute on sp820_tesis_rep_tesis from public;

grant execute on sp820_tesis_rep_tesis to guarani; -- Rol de usuarios de Gestión
grant execute on sp820_tesis_rep_tesis to internet; -- Usuario de internet

-- execute  PROCEDURE sp820_tesis_rep_tesis(null, null, null);

