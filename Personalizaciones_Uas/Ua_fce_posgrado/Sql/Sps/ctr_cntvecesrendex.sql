DROP PROCEDURE "dba".ctr_cntvecesrendex;
CREATE PROCEDURE "dba".ctr_cntvecesrendex(

	pUnidadAcademica	LIKE sga_alumnos.unidad_academica,

	pCarrera		LIKE sga_alumnos.carrera,

	pLegajo 		LIKE sga_alumnos.legajo,

	pMateria 		LIKE sga_mesas_examen.materia,

	pAnioAcademico 	LIKE sga_mesas_examen.anio_academico,

	pTurnoExamen	LIKE sga_mesas_examen.turno_examen,

	pMesaExamen 	LIKE sga_mesas_examen.mesa_examen,

	pLlamado 	LIKE sga_insc_examen.llamado,

	pTipoInscripcion	LIKE sga_insc_examen.tipo_inscripcion)

	RETURNING smallint, varchar(255);



  /*  controla que no haya completado la cnt maxima de rendicion de una materia

      sin aprobarla.

       devuelve:  1 - si esta OK         

	         -1 - en otro caso       

  */



  -- vars para la respuesta

  DEFINE iStatus 	smallint	;	-- status

  DEFINE vcMsg 		varchar(255)	;	-- mensaje y parametros



  -- var's para el manejo de excepciones

   DEFINE sql_err,isam_err 		integer		;

   DEFINE error_info 	varchar(76)	;

   DEFINE vcUserError	varchar(10) 	;



  --vars locales

   DEFINE iCntRendidas, iCntExamenes 		smallint;

   DEFINE vFecha, vFechaAux	date;

   DEFINE vPlan varchar(5);



   -- blk de excepciones

   ON EXCEPTION SET sql_err, isam_err, error_info                                        

     LET iStatus = -1 ;

     LET vcMsg = '800321' || ',' || 'cntvecesrendex' || ',' || sql_err || ' - '  || error_info ; 	

     RETURN iStatus, vcMsg ;

   END EXCEPTION;        



BEGIN



   -- seteo los valores default

   LET iStatus		= 1 ;

   LET vcMsg		= 'OK';



  LET vPlan = (select Plan from sga_alumnos where unidad_academica = pUnidadacademica and carrera = pcarrera and legajo = pLegajo);





-- U820 ************************************************************************************************

-- No se realiza el control para las materias 1011 (Matemática Básica 1ra. Parte) y 1041 (Contabilidad Básica 1ra. Parte)

-- U820 ************************************************************************************************



    IF pMateria In ('1011', '1041') THEN

	RETURN iStatus, vcMsg; 

   END IF;





-- U820 ************************************************************************************************

-- Es indistinto como se inscriban

-- U820 ************************************************************************************************

--    IF pTipoInscripcion <> 'R' THEN

--	-- Si no es una inscripcion como Regular, entonces no realizo el control.

--	RETURN iStatus, vcMsg; 

--   END IF;



   LET iCntRendidas = 0;

   LET iCntExamenes = 0;

  

   -- Recupero el valor del param que indica la cnt de veces que puedo rendir un examen de uan materia

   Execute procedure sp_param_sistema('cant_veces_rendir_examen') INTO iCntExamenes;



   LET vFecha = to_date('01-01-1900','%d-%m-%Y');

   LET vFechaAux = vFecha;

	  	





-- U820 ************************************************************************************************

-- No es necesario tenerla cursada

-- U820 ************************************************************************************************

/*   -- Recupero la Fecha de Regularizacion de la Materia. La Ultima cursada

   FOREACH SELECT v.fecha_regularidad INTO vFechaAux

		FROM sga_cursadas v, sga_comisiones c

	       WHERE v.unidad_academica   = pUnidadAcademica 

	        AND  v.carrera		= pCarrera 

	        AND  v.legajo 		= pLegajo

	       AND c.comision = v.comision

		AND c.materia 		= pMateria

		AND v.resultado		= 'A'

	IF vFechaAux > vFecha Then

		LET vFecha = vFechaAux ;

	END IF;	

   END FOREACH;	



   -- Si no la tiene cursada, verifico si se la dio por equivalencia parcial.

   IF vFecha = 	to_date('01-01-1900','%d-%m-%Y') THEN

	

	SELECT sga_equiv_parcial.fecha INTO vFechaAux

	  FROM sga_equiv_parcial

	 WHERE sga_equiv_parcial.unidad_academica = pUnidadAcademica

	   AND sga_equiv_parcial.carrera = pCarrera

	   AND sga_equiv_parcial.legajo  = pLegajo

	   AND sga_equiv_parcial.materia  = pMateria

	   AND sga_equiv_parcial.resultado = 'A'

           AND sga_equiv_parcial.estado = 'A' ;

	

	IF vFechaAux > vFecha Then

		LET vFecha = vFechaAux ;

	END IF;	

	

      --ahora si no tiene la materia regularizada.

      IF vFecha = to_date('01-01-1900','%d-%m-%Y') THEN

         -- Salgo, el alumno nunca curso la materia! Saltara mas adelante el control

         -- de que no puede rendir la materia como regular si no la cursó

         RETURN iStatus, vcMsg; 

      END IF;

   

   END IF;

*/   

   -- Recupero la historia academica de la Persona.

   -- Lo hago asi porque si filtro por materia y resultado, la consulta tarda mucho.

   begin

     on exception in (-206)

       -- Tabla no existe continuo el proceso

     end exception with resume;

     DROP TABLE tmp_hist_acad;

   end





   SELECT materia, resultado, fecha 

     FROM vw_hist_academica 

        WHERE unidad_academica = pUnidadAcademica 

         AND  carrera		= pCarrera 

         AND  legajo 		= pLegajo

     INTO TEMP  tmp_hist_acad;



   IF DBINFO("sqlca.sqlerrd2") <= 0 THEN

	-- El alumno no tiene materias rendidas

	RETURN iStatus, vcMsg; 

   END IF;





-- U820 ************************************************************************************************

-- No interesa a partir de cuando rindio mal

-- U820 ************************************************************************************************

   -- Ahora recupero la cantidad de veces que el Alumno rindio el Examen y no lo

   -- aprobo, desde que el momento que curso la materia

   SELECT Count(*) INTO iCntRendidas

	FROM tmp_hist_acad

	WHERE materia = pMateria

	AND resultado = 'R';

--	AND fecha >= vFecha;



   IF (iCntRendidas >= iCntExamenes) and not exists 

				(select '' from u820_habilitados 

					where unidad_academica = punidadacademica

					and carrera = pcarrera

					and legajo = plegajo

					and plan =  vPlan

					and materia = pmateria

					and cant_aplazos >= iCntRendidas) THEN

	-- Error. no puede inscribirse para rendir la materia

	-- Llego al limite maximo de inscr a rendir una materia.

	LET vcUserError  = '800340';

	LET iStatus 	  = -1; 

	LET vcMsg 	  =  vcUserError || ',' || iCntExamenes || ',' || pMateria;

	RETURN iStatus, vcMsg; 

   END IF;



   begin

     -- Borro la tabla temporal	

     on exception in (-206)

       -- Tabla no existe continuo el proceso	

     end exception with resume;

     DROP TABLE tmp_hist_acad;

   end



   RETURN iStatus, vcMsg; 

END;

END PROCEDURE;
                                                                                                                                                                                                                                                              
