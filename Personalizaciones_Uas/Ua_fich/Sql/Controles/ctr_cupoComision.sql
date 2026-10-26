-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Control:ctr_cupoComision
-- Ultima version de modificacion: 2.05.0
--
-- Verifica el cupo de la comision con respecto a las inscripciones a cursadas en la misma
-- Si el cupo de la comision es Nulo o 0 no controla nada.
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- drop procedure ctr_cupoComision;
CREATE PROCEDURE ctr_cupoComision( pUnidadAcademica 	LIKE sga_alumnos.unidad_academica,
					pCarrera 		LIKE sga_alumnos.carrera,
					pLegajo		LIKE sga_alumnos.legajo,
					pComision 	LIKE sga_comisiones.comision,
					pMateriaGenerica	LIKE sga_insc_cursadas.materia_generica)
	RETURNING 	smallint, 		-- status
			varchar(255);	-- <mensaje, parametros>

/* La capacidad de la comisión debe ser mayor que la cantidad de inscripciones para admitir una nueva inscripción 

CORR 1: fue modificado para que en vez de retornar el id de la comision retorne el nombre de la misma  (29/05/2000) */

  -- vars para la respuesta
  DEFINE iStatus 		smallint			;	-- status
  DEFINE vcMsg 		varchar(255)		;	-- mensaje y parametros

  -- var's para el manejo de excepciones
   DEFINE sql_err 		integer		;
   DEFINE isam_err 		integer		;
   DEFINE error_info 	varchar(76)	;
   DEFINE vcUserError	varchar(10) 	;
   DEFINE vcIgresante char(1) 	;


  DEFINE iCupo		LIKE  sga_comisiones.capacidad 	;
  DEFINE vcMateria		LIKE  sga_materias.materia 		;
  DEFINE vcNombreMat	LIKE  sga_materias.nombre 		;
  DEFINE vcNombreCom	LIKE  sga_comisiones.nombre 	;
  DEFINE iCantInscriptos	integer 				;
	-- Defino las variables que voy a utilizar
	define v_anio_academico	like sga_comisiones.anio_academico;
	define v_periodo_lectivo	like sga_comisiones.periodo_lectivo;
	define v_materia		like sga_comisiones.materia;

   -- blk de excepciones
   ON EXCEPTION SET sql_err, isam_err, error_info                                        
     LET iStatus = -1 ;
     LET vcMsg = '800321' || ',' || 'cupoComision' || ',' || sql_err || ' - '  || error_info ; 	
     RETURN iStatus, vcMsg ;
   END EXCEPTION;        

BEGIN
   -- inicializo con OK, porque puede ser que termine sin llegar al final
   LET iStatus = 1 		;
   LET vcMsg = '800320' 	;
LET vcIgresante = 'N';

	-- Cargo las variables con los datos de la comision
	select anio_academico, periodo_lectivo, materia into v_anio_academico, v_periodo_lectivo, v_materia
	from sga_comisiones
	where comision = pcomision;

execute PROCEDURE sp_es_ingr_anio(pUnidadAcademica, pCarrera,	pLegajo, v_anio_academico) INTO  vcIgresante ;


if pcomision in (12026) then -- Comisión solo para recursantes

	if vcIgresante = 'S' then
	     LET iStatus = -1 ;
	     LET vcMsg = '800369' || ',' || pComision ; 	
	     RETURN iStatus, vcMsg ;
	end if;
else 
	if pcomision in (11975, 12023, 12024, 12025) then -- Comisión solo para ingresantes
		if vcIgresante = 'N' then
		     LET iStatus = -1 ;
		     LET vcMsg = '800369' || ',' || pComision ; 	
		     RETURN iStatus, vcMsg ;
		end if;
	end if;
end if;

   -- recupero la cantidad maxima de inscripciones de la comision 
   SELECT c.capacidad, 
	  c.nombre, 
	  c.materia
       INTO iCupo, 
	vcNombreCom, 
	vcMateria
      FROM sga_comisiones c
   WHERE c.comision                 = pComision ; 	

   -- si no existe la comision...
   IF DBINFO("SQLCA.SQLErrD2") <= 0 THEN
     LET iStatus = -1 ;
     LET vcMsg = '800365' || ',' || pComision ; 	
     RETURN iStatus, vcMsg ;
   END IF;

   -- si el cupo de la comision es NULO o 0 no restringe nada
   IF iCupo IS NULL or iCupo <= 0 THEN
      RETURN iStatus, vcMsg ;
   END IF;

   -- cuento la cantidad de alumnos inscriptos para cursar en esa comision
   SELECT COUNT(i.legajo)
       INTO iCantInscriptos
      FROM sga_insc_cursadas i
   WHERE i.comision = pComision ; 	 
	
   -- comparo la cantidad de inscriptos con el cupo	
   IF iCantInscriptos >= iCupo THEN
     LET iStatus = -1 ;
     LET vcMsg = '800369' || ',' || vcNombreCom || ',' || iCupo; 	
     RETURN iStatus, vcMsg ;
   END IF;

      RETURN iStatus, vcMsg ;
END;

END PROCEDURE;
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
