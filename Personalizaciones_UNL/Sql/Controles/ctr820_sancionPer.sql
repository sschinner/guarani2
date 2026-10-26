CREATE PROCEDURE verifica_datos()
BEGIN

-- ANTE CUALQUIER ERROR CONTINUO

ON EXCEPTION 
END EXCEPTION WITH RESUME;


INSERT INTO par_implem_control (stored_procedure, parametros) VALUES ('ctr820_sancionPer', 's,s,s');
INSERT INTO par_controles (control, stored_procedure, desc_abreviada, descripcion) VALUES (820005, 'ctr820_sancionPer', 'Controla sanciones activas de personas', 'Controla sanciones activas de personas');
INSERT INTO par_cont_x_punto (punto_de_control, control) VALUES (2, 820005);

Execute Procedure  sp_ConfCont_Cont (2, 820005);

END
END PROCEDURE;

EXECUTE PROCEDURE verifica_datos();
DROP PROCEDURE verifica_datos();

CREATE PROCEDURE verifica_objeto()

BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'ctr820_sancionper') THEN
		DROP PROCEDURE ctr820_sancionPer;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();

-- **************************************************************************
-- Control: ctr_sancionPer
-- Version: 2.05.2

-- Verifica si una persona tiene sanciones activas.
-- **************************************************************************

CREATE PROCEDURE "dba".ctr820_sancionPer (pUnidadAcademica  LIKE sga_personas.unidad_academica, pNroInscripcion LIKE sga_alumnos.nro_inscripcion, pOperacion LIKE acc_operaciones.operacion )

	RETURNING 	smallint, 		-- status
			varchar(255);	-- <mensaje, parametros>

  -- vars para la respuesta
  DEFINE iStatus            	smallint;      -- status
  DEFINE vcMsg              	varchar(255);  -- mensaje y parametros

   -- var's para el manejo de excepciones
   DEFINE sql_err, isam_err  	integer;
   DEFINE error_info         	varchar(76);
   DEFINE vcUserError        	varchar(10);
   
   -- var's para obtener los datos del stored procedure sp_sanciones_perso
   DEFINE vc_TipoSancion	LIKE dba.sga_sanciones_tipo.nombre;
   DEFINE vc_Resolucion 	VARCHAR(100);
   DEFINE vc_FechaDesde	LIKE dba.sga_sancion_pers.fecha_desde;
   DEFINE vc_FechaHasta	LIKE dba.sga_sancion_pers.fecha_hasta;
   DEFINE vc_ResolNro	LIKE sga_sancion_pers.resolucion;

   DEFINE vc_Fecha	VARCHAR(10);

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
      LET iStatus = -1 ;
      LET vcMsg = '800321,' || 'ctr820_sancionPer,' || sql_err || ' - '  || error_info ;

      RETURN iStatus, vcMsg;
   END EXCEPTION;

BEGIN

   -- seteo los valores default
   LET iStatus = 1;
   LET vcMsg = '800320';

   LET vc_Fecha = to_char(TODAY,"%d-%m-%Y");

   FOREACH 	EXECUTE PROCEDURE sp_sanc_per_fecha(pUnidadAcademica, pNroInscripcion, NULL, NULL, vc_Fecha, NULL)
        INTO    vc_TipoSancion,
		        vc_Resolucion,
		        vc_FechaDesde,
		        vc_FechaHasta,
                vc_ResolNro
	
      	-- Existen sanciones, el control falla
      	LET iStatus = -1;
        IF vc_FechaHasta IS NULL THEN 
      	    LET vcMsg = '800549,' || vc_TipoSancion || ',' || vc_FechaDesde || ','  ||  vc_Resolucion ; 
        ELSE
          	LET vcMsg = '800547,' || vc_TipoSancion || ',' || vc_FechaDesde || ',' || vc_FechaHasta || ',' ||  vc_Resolucion ; 
        END IF;

	RETURN iStatus, vcMsg ;
   END FOREACH;

   RETURN iStatus, vcMsg ;
END;
END PROCEDURE;
-- **************************************************************************


