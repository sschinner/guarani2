DROP PROCEDURE "dba".ctr_materiacursada;
CREATE PROCEDURE "dba".ctr_materiacursada(pUnidadAcademica  LIKE sga_alumnos.unidad_academica,
                                  pCarrera          LIKE sga_alumnos.carrera,
                                  pLegajo           LIKE sga_alumnos.legajo,
                                  pMateria          LIKE sga_materias.materia)

	RETURNING 	smallint,       -- status
			varchar(255);   -- <mensaje, parametros>

  /*  controla el Alumno tiene o no la Materia Cursada
       devuelve:  1 - si esta OK            no tiene la Materia Cursada
             -1 - en otro caso       Tiene la Materia Cursada
  */

  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 	integer;
   DEFINE error_info 	varchar(76);
   DEFINE vcUserError	varchar(10);


   -- variables locales
   DEFINE viCantRegul integer;
   DEFINE viCantAplazos integer;
   DEFINE vd_fecha_regularidad date;
   DEFINE vd_fecha_fin_regularidad date;

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'materiacursada' || ',' || sql_err || ' - '  || error_info ;  
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN
   -- seteo los valores default
   LET iStatus		= 1 ;
   LET vcMsg		= 'OK';
   LET viCantRegul  = 0;
   LET viCantAplazos = 0;
   LET vd_fecha_regularidad = NULL;

   LET vd_fecha_fin_regularidad = NULL;

-- Materias Exceptuadas, las que se pueden cursar sin condicion alguna  

IF pMateria in ('4110', '5110', '5170', '2330', '5270', '1080',  '1081') THEN
	RETURN iStatus, vcMsg; 
END IF;

----- se obtiene máx. fecha de cursada

SELECT max(fecha_regularidad) INTO vd_fecha_regularidad 
     FROM sga_cursadas cur , 
          sga_comisiones com   -- NO tiene regularizada la materia
    WHERE cur.unidad_academica      = pUnidadAcademica
     -- AND cur.carrera               = pCarrera  
      AND cur.legajo                = pLegajo   
      AND com.comision              = cur.comision
      AND com.materia               = pMateria
      AND origen <> 'CE'
	AND cur.cond_regularidad not in (2, 9, 11);

---- se calcula fecha de fin de regularidad como un año después de la fecha de cursada

LET vd_fecha_fin_regularidad = MDY( month(vd_fecha_regularidad ),day(vd_fecha_regularidad ),year(vd_fecha_regularidad ) + 1);

IF vd_fecha_fin_regularidad IS NULL OR vd_fecha_fin_regularidad < TODAY THEN
	RETURN iStatus, vcMsg; 
END IF;

---- si la fecha de fin no finalizó aún, se determina si tiene 3 aplazos

SELECT COUNT(*) INTO viCantAplazos 
     FROM vw820_hist_academ hc
   
    WHERE hc.unidad_academica      = pUnidadAcademica
      -- AND hc.carrera               = pCarrera  
      AND hc.legajo                = pLegajo   
      AND hc.materia               = pMateria
	and hc.resultado = 'R'
	and hc.forma_aprobacion = 'Examen'
             ----   and ((pMateria = 1030 and hc.fecha >= '07/01/2006') or (pMateria = 2040 and hc.fecha >= '07/01/2007')
              -----         or pMateria not in (1030,2040))
              ---- corrección nov./2011 
                 and hc.fecha >= '20/06/2011';


    IF   ( viCantAplazos < 3 ) THEN
       -- Error. Tiene la Materia Cursada y no tiene  3 o mas aplazos
       LET vcUserError  = '800383';
       LET iStatus 	  = -1; 
       LET vcMsg 	  =  vcUserError || ',' || pMateria || ',' || pCarrera;
       RETURN iStatus, vcMsg; 
   END IF;


RETURN iStatus, vcMsg; 
END;
END PROCEDURE;
                                                                                                                                                                                             
