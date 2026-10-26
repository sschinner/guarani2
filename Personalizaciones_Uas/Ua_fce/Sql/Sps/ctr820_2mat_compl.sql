DROP PROCEDURE "dba".ctr820_2mat_compl;
CREATE PROCEDURE "dba".ctr820_2mat_compl(pUnidadAcademica 	LIKE sga_insc_cursadas.unidad_academica,
					 pCarrera	 		LIKE sga_insc_cursadas.carrera,
				 	 pLegajo  		                LIKE sga_insc_cursadas.legajo,
					 pMateria 		                LIKE sga_materias.materia
)


RETURNING smallint, varchar(255);
  -- vars para la respuesta
  DEFINE iStatus 		smallint;	-- status
  DEFINE vcMsg 		varchar(255);	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err,isam_err 	integer;
   DEFINE error_info 	varchar(76);
   DEFINE vcUserError	varchar(100);

   -- variables locales
   DEFINE	vcPlan		LIKE sga_insc_cursadas.plan;
   DEFINE	vcVersion		LIKE sga_insc_cursadas.version;
   DEFINE 	viTotal INTEGER;

 

BEGIN
   -- seteo los valores default
   LET iStatus		= 1 ;
   LET vcMsg		= 'OK';

-- obtengo el plan y version del alumno
   EXECUTE PROCEDURE sp_plan_de_alumno( pUnidadAcademica, pCarrera, pLegajo, TODAY ) 	INTO vcPlan, vcVersion ;
--- Obtengo la cantidad de materias aprobadas por el alumno
   EXECUTE PROCEDURE u820_cuenta_mat_rapido( pUnidadAcademica, pCarrera, pLegajo,'A',vcPlan,vcVersion)  INTO viTotal ;

IF viTotal < 36 THEN
   RETURN iStatus, vcMsg; 
-------RETURN viTotal , vcMsg;

END IF;

 --- Aprobó Complemento I

/* IF NOT EXISTS
 (Select '1'  from sga_cursadas
				 where materia = '1030'
			       and resultado = 'A'
			       and cond_regularidad = 11 
			       and fin_vigencia_regul >= TODAY
                                                        and carrera = pCarrera
                                                         and legajo =  pLegajo)
  AND
 NOT EXISTS
  (Select '1' from vw820_hist_academ
         	where materia = '1030'
               and resultado = 'A' 
               and fecha >= '05/01/2006'
               and carrera = pCarrera
               and legajo =  pLegajo)
AND
 NOT EXISTS               
  (Select '1' from vw820_hist_academ
         	where materia = '2040'
               and resultado = 'A' 
               and carrera = pCarrera
               and legajo =  pLegajo)
THEN
 LET iStatus = -1;
 LET vcUserError = 82002030;
 LET vcMsg = vcUserError  || ',' || 'Complemento I'  ;  
 RETURN iStatus, vcMsg;
END IF; */

IF NOT EXISTS
         (Select '1'  from sga_cursadas
				 where materia = '1030'
			       and resultado = 'A'
			       and cond_regularidad = 11 
			       and fin_vigencia_regul >= TODAY
                                                        and carrera = pCarrera
                                                         and legajo =  pLegajo)
AND
  EXISTS
  (Select '1' from vw820_hist_academ
         	where materia = '1030'
               and resultado = 'A' 
               and fecha <= '04/30/2006'
               and carrera = pCarrera
               and legajo =  pLegajo)
AND

       NOT EXISTS
          (Select '1' from  vw820_hist_academ
         	where materia = '2040'
               and resultado = 'A' 
               and carrera = pCarrera
               and legajo =  pLegajo)
THEN
 LET iStatus = -1;
 LET vcUserError = 82002030;
 LET vcMsg = vcUserError  || ',' || 'Complemento I'  ;  
END IF;


--- Aprobó Complemento II
/* IF pCarrera = '0201' or pCarrera = '0202'  THEN    
IF NOT EXISTS
(Select '1'  from sga_cursadas
				 where materia = '2040'
			       and resultado = 'A'
			       and cond_regularidad = 11 
			       and fin_vigencia_regul >= TODAY
                                                        and carrera = pCarrera
                                                         and legajo =  pLegajo)
  AND
 NOT EXISTS
  (Select '1' from  vw820_hist_academ
         	where  materia in ('4040','4240')
               and resultado = 'A' 
               and fecha  > '05/31/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)
AND
 NOT EXISTS
  (Select '1' from  vw820_hist_academ
         	where  
            materia = '2040'
               and resultado = 'A' 
               and fecha <= '05/31/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)
THEN
 LET iStatus = -1;
 LET vcUserError = 82002030;
 LET vcMsg = vcUserError  || ',' || 'Complemento II'  ;  
 RETURN iStatus, vcMsg;
END IF;
END IF; */

IF pCarrera = '0201' or pCarrera = '0202'  THEN    
  IF NOT EXISTS
         (Select '1'  from sga_cursadas
		               where materia = '2040'
			       and resultado = 'A'
			       and cond_regularidad = 11 
			       and fin_vigencia_regul >= TODAY
                                                        and carrera = pCarrera
                                                         and legajo =  pLegajo)
AND
  EXISTS
  (Select '1' from  vw820_hist_academ
         	where  materia in ('4040','4240')
               and resultado = 'A' 
               and fecha  <= '05/31/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)

AND
       NOT EXISTS
  (Select '1' from  vw820_hist_academ
         	where  
            materia = '2040'
               and resultado = 'A' 
               and fecha <= '05/31/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)
THEN
 LET iStatus = -1;
 LET vcUserError = 82002030;
 LET vcMsg = vcUserError  || ',' || 'Complemento II'  ;  
END IF;
END IF;


--- Aprobó Complemento III
/* IF pCarrera = '0201' or pCarrera = '0202'  THEN  
IF NOT EXISTS
 (Select '1'  from sga_cursadas
				 where materia in ('5140','5230')
			       and resultado = 'A'
			       and cond_regularidad = 11 
			       and fin_vigencia_regul >= TODAY
                                                        and carrera = pCarrera
                                                         and legajo =  pLegajo)
AND
 NOT EXISTS
  (Select '1' from  vw820_hist_academ
         	where  
               materia in ('5140','5230')
               and resultado = 'A' 
               and fecha  > '10/31/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)
AND
 NOT EXISTS
  (Select '1' from  vw820_hist_academ
         	where  
               materia = '2040'
               and resultado = 'A' 
               and fecha  <= '05/31/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)
THEN
 LET iStatus = -1;
 LET vcUserError = 82002030;
 LET vcMsg = vcUserError  || ',' || 'Complemento III'  ;  
END IF;
END IF; */

IF pCarrera = '0201' or pCarrera = '0202'  THEN
  IF NOT EXISTS
        (Select '1'  from sga_cursadas
				 where materia in ('5140','5230')
			       and resultado = 'A'
			       and cond_regularidad = 11 
			       and fin_vigencia_regul >= TODAY
                                                        and carrera = pCarrera
                                                         and legajo =  pLegajo)

AND
  EXISTS
  (Select '1' from  vw820_hist_academ
         	where  
               materia in ('5140','5230')
               and resultado = 'A' 
               and fecha  <= '10/31/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)


AND
       NOT EXISTS
  (Select '1' from  vw820_hist_academ
         	where  
               materia = '2040'
               and resultado = 'A' 
               and fecha  <= '05/31/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)

THEN
 LET iStatus = -1;
 LET vcUserError = 82002030;
 LET vcMsg = vcUserError  || ',' || 'Complemento III'  ;  
END IF;
END IF;


--- Aprobó Complemento IV

/* IF pCarrera = '0201'  THEN
   IF NOT EXISTS
(Select '1'  from sga_cursadas
				 where materia = '5130'
			       and resultado = 'A'
			       and cond_regularidad = 11 
			       and fin_vigencia_regul >= TODAY
                                                        and carrera = pCarrera
                                                         and legajo =  pLegajo)
AND
 NOT EXISTS 

  (Select '1' from  vw820_hist_academ
         	where
               materia = '5140'
               and resultado = 'A' 
               and fecha  > '11/01/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)
AND
 NOT EXISTS
  (Select '1' from  vw820_hist_academ
         	where    
               materia = '5130'
               and resultado = 'A' 
               and fecha <= '05/31/2008'
               and carrera = pCarrera
               and legajo =  pLegajo)
THEN
 LET iStatus = -1;
 LET vcUserError = 82002030;
 LET vcMsg = vcUserError  || ',' || 'Complemento IV'  ;  
END IF;
END IF; */

IF pCarrera = '0201'  THEN
  IF NOT EXISTS
         (Select '1'  from sga_cursadas
			 where materia = '5130'
			       and resultado = 'A'
			       and cond_regularidad = 11 
			       and fin_vigencia_regul >= TODAY
                                                        and carrera = pCarrera
                                                         and legajo =  pLegajo)
AND
  EXISTS
  (Select '1' from  vw820_hist_academ
         	where
               materia = '5140'
               and resultado = 'A' 
               and fecha  <= '11/01/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)
    AND
       NOT EXISTS
          (Select '1' from  vw820_hist_academ
         	where    
               materia = '5130'
               and resultado = 'A' 
               and fecha <= '05/31/2008'
               and carrera = pCarrera
               and legajo =  pLegajo)
THEN
 LET iStatus = -1;
 LET vcUserError = 82002030;
 LET vcMsg = vcUserError  || ',' || 'Complemento IV'  ;  
END IF;
END IF;

--- Aprobó Complemento V

/* IF pCarrera = '0202' THEN  
IF NOT EXISTS
 (Select '1'  from sga_cursadas
				 where materia = '3230'
			       and resultado = 'A'
			       and cond_regularidad = 11 
			       and fin_vigencia_regul >= TODAY
                                                        and carrera = pCarrera
                                                         and legajo =  pLegajo)
AND
 NOT EXISTS
  (Select '1' from  vw820_hist_academ
         	where   materia = '4240'
               and resultado = 'A' 
               and fecha  > '05/31/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)
AND
 NOT EXISTS
  (Select '1' from  vw820_hist_academ
         	where materia = '3230'
               and resultado = 'A' 
               and fecha <= '05/31/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)
THEN
 LET iStatus = -1;
 LET vcUserError = 82002030;
 LET vcMsg = vcUserError  || ',' || 'Complemento V'  ;  
END IF;
END IF; */

IF pCarrera = '0202'  THEN
  IF NOT EXISTS
 (Select '1'  from sga_cursadas
				 where materia = '3230'
			       and resultado = 'A'
			       and cond_regularidad = 11 
			       and fin_vigencia_regul >= TODAY
                                                        and carrera = pCarrera
                                                         and legajo =  pLegajo)
AND
  EXISTS
  (Select '1' from  vw820_hist_academ
         	where   materia = '4240'
               and resultado = 'A' 
               and fecha  <= '05/31/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)

    AND
       NOT EXISTS
  (Select '1' from  vw820_hist_academ
         	where materia = '3230'
               and resultado = 'A' 
               and fecha <= '05/31/2007'
               and carrera = pCarrera
               and legajo =  pLegajo)


THEN
 LET iStatus = -1;
 LET vcUserError = 82002030;
 LET vcMsg = vcUserError  || ',' || 'Complemento V'  ;  
END IF;
END IF;

RETURN iStatus, vcMsg; 
END;
END PROCEDURE;
                                                                               
