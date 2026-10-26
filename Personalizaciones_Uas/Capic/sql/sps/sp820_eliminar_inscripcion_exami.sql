-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.7.0. Ultima version de modificacion: 2.0.0
--
-- SP: sp820_eliminar_inscripcion_exami
-- Anula una Inscripcion a Examen, es decir, borra la inscripcion a examen y
-- la agrega en la tabla de bajas. La fecha en que se está dando de baja la
-- inscripción debe ser menor que la fecha tope para bajas en esa mesa de examen.
-- Si la mesa usa fechas de inscripción distintas de las del llamado, usa como
-- tope la fecha de fin de inscripción.
-- 
-- Recibe: - Alumno, Mesa - Llamado
-- 
-- Retorna: Estado del DELETE
-- *****************************************************************************
DROP PROCEDURE sp820_eliminar_inscripcion_exami;

CREATE PROCEDURE sp820_eliminar_inscripcion_exami( pUnidadAcademica	LIKE sga_alumnos.unidad_academica,
				--pCarrera		LIKE sga_alumnos.carrera,
				pLegajo 		LIKE sga_alumnos.legajo,
				pMateria 		LIKE sga_insc_examen.materia,
				pAnioacademico 		LIKE sga_insc_examen.anio_academico,
				pTurnoExamen 		LIKE sga_insc_examen.turno_examen,
				pMesaExamen 		LIKE sga_insc_examen.mesa_examen,
				pLlamado 		LIKE sga_insc_examen.llamado,
				pInterfase		LIKE sga_insc_examen.interfaz )

 RETURNING  	smallint,		-- status -1 Error/ 1 OK
	           	varchar(255);	-- mensaje 

   -- vars para el manejo de excepciones
   DEFINE 	SQLErr, ISAMError	integer		;
   DEFINE 	errorInfo 		varchar(76)	;
   DEFINE	vcUserError	varchar(10)	;

   -- vars locales
   DEFINE 	iStatus 		smallint		;
   DEFINE 	vcMsg 		varchar(255)	;
   DEFINE 	iOK		smallint		;


   DEFINE 	ctipoInscripcion	LIKE sga_insc_examen.tipo_inscripcion;  
   DEFINE 	vcMateriaGenerica	LIKE sga_insc_examen.materia_generica	;
   DEFINE 	vcEquivParcial	LIKE sga_insc_examen.equiv_parcial	;
   DEFINE	dFecInscripcion	LIKE sga_insc_examen.fecha_inscripcion;	 
   DEFINE	vcTipoInscripcion	LIKE sga_insc_examen.tipo_inscripcion;	 
   DEFINE	vcNroTransaccion	LIKE sga_insc_examen.nro_transaccion	; 
   DEFINE	iInterfaz		LIKE sga_insc_examen.interfaz		; 
   DEFINE	ilistadoExamen	LIKE sga_insc_examen.listado_examen;	 
   DEFINE	vcNroTransacBaja	LIKE sga_insc_examen.nro_transaccion	; 
   DEFINE   pCarrera		LIKE sga_alumnos.carrera;

   DEFINE	vcModalidad		LIKE	sga_param_sistema.valor;
   DEFINE 	dFecTopeBajaInsc	LIKE sga_insc_exa_bajas.fecha_baja	;
   DEFINE 	dFEchaExamen	LIKE sga_prestamos.fecha;
   DEFINE 	vcFEchaExamen	varchar(10);


  -- si hay algun error
  ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
      LET vcUserError  = '800402' ;
      LET iStatus 	  = -1; 
      LET vcMsg 	  =  vcUserError || ',' || SQLErr || ' - ' || errorInfo;
      RETURN iStatus, vcMsg;
--      RAISE EXCEPTION  SQLErr, ISAMError, errorInfo ;
   END EXCEPTION;

BEGIN

	-- Busco la carrera de integracion para la Unidad Academica
	SELECT carrera
		INTO pCarrera
		FROM sga_carreras_grupo
		WHERE grupo_carrera = "i0001";

   -- Recupero datos de la inscripcion a examen a eliminar
   SELECT fecha_inscripcion,
	  tipo_inscripcion,
	  materia_generica,
	  equiv_parcial,
	  nro_transaccion,
	  interfaz,
	  listado_examen
       INTO  dFecInscripcion,
	  vcTipoInscripcion,
	  vcMateriaGenerica,
	  vcEquivParcial,
	  vcNroTransaccion,
	  iInterfaz,
	  ilistadoexamen
      FROM sga_insc_examen
   WHERE unidad_academica = pUnidadAcademica
         AND carrera      = pCarrera
         AND legajo	      = pLegajo
         AND materia      = pMateria
	 AND anio_academico = pAnioacademico
	 AND  turno_examen   = pTurnoExamen
	 AND  mesa_examen   = pMesaExamen
	 AND  llamado   	= pLlamado;

    -- verifico que haya recuperado solo una inscripcion a examen
    IF DBINFO("SQLCA.SQLErrd2") <> 1 THEN
       LET vcUserError  = '800403' ;
       LET iStatus 	  = -1; 
       LET vcMsg 	  =  vcUserError || ',' || pMateria || ',' || pMesaexamen || ',' || pLlamado ;
       RETURN iStatus, vcMsg;
    END IF ;	

   -- *****************   Controles Obligatorios !!! **********************************************
   -- TODAY debe ser menor o igual a la Fecha Tope para Bajas de inscripciones para ese Llamado
   -- recupero la fecha tope de bajas de inscripciones para la comision
   -- **************************************************************************************

   -- 1)  La insc no debe existir en ningun  listado de Examen
   IF ilistadoexamen IS  NOT NULL THEN
	LET vcUserError  = '800406' ;
	LET iStatus 	  = -1; 
	LET vcMsg 	  =  vcUserError  || ',' || pMesaexamen || ',' || pLlamado || ',' || dFecTopeBajaInsc;
	RETURN iStatus, vcMsg;
   END IF;
	
   -- 2)  La insc no debe existir en ningun  Acta de Examen
   IF (SELECT COUNT(*) 
	FROM sga_actas_examen ae,
	            sga_detalle_acta da
	WHERE ae.unidad_academica = pUnidadAcademica
	AND   ae.materia = pMateria
	AND   ae.anio_academico = pAnioAcademico
	AND   ae.turno_examen = pTurnoexamen
	AND   ae.mesa_examen = pMesaExamen
	AND   ae.llamado = pLlamado
	AND  da.unidad_academica = ae.unidad_academica
	AND  da.Acta = ae.Acta
	AND  da.tipo_acta = ae.tipo_acta
	AND  da.Carrera = pCarrera
	AND  da.Legajo = pLegajo ) > 0 THEN

	LET vcUserError  = '800407' ;
	LET iStatus 	  = -1; 
	LET vcMsg 	  =  vcUserError ;
	-- LET vcMsg 	  =  vcUserError  || ',' || pMesaexamen || ',' || pLlamado || ',' || dFecTopeBajaInsc;
	RETURN iStatus, vcMsg;
   END IF;

   -- 3)
   EXECUTE PROCEDURE sp_param_sistema('modalidad_de_inscripciones_a_examenes') INTO vcModalidad;
   LET vcModalidad = TRIM(vcModalidad);
   IF vcModalidad = '' or vcModalidad IS NULL THEN
	-- Error
	raise exception -746,0,'Error. Falta definir parametro "modalidad_de_inscripciones_a_examenes"';
   ELIF vcModalidad = '1' THEN
	-- La inscripcion es por Turno

   ELIF vcModalidad = '2' THEN
	-- La inscripcion es por Llamado
        -- Busca la fecha de tope de baja en la excepción de la mesa (usa la fecha de fin de inscripción)
        -- 28/01/2002 - SE ELIMINO EL SELECT HACIA LAS EXCEPCIONES (REQ. 3442)
        SELECT fecha_tope_bajas
          INTO  dFecTopeBajaInsc
          FROM sga_fec_insc_llam 
         WHERE anio_academico = pAnioacademico
           AND  turno_examen   = pTurnoExamen
           AND  llamado   	= pLlamado
           AND  fecha_inicio   <= dFecInscripcion
           AND  fecha_fin      >= dFecInscripcion ;

      -- si ya paso la fecha tope de bajas para esa comision para cuando fue realizada la inscripcion
      IF CURRENT YEAR TO SECOND >  dFecTopeBajaInsc THEN
         LET vcUserError  = '800404' ;
         LET iStatus 	  = -1; 
         LET vcMsg 	  =  vcUserError  || ',' || pMesaexamen || ',' || pLlamado || ',' || dFecTopeBajaInsc;
         RETURN iStatus, vcMsg;
      END IF ;

      -- Debo controlar que la fecha actual no sea mayor a la fecha de Prestamo del Examen
      LET dFEchaExamen = NULL;	
      SELECT p.fecha   INTO dFechaExamen
	 FROM sga_llamados_mesa llm,  sga_prestamos  p
           WHERE llm.unidad_academica = pUnidadAcademica
             AND llm.materia      = pMateria
             AND llm.anio_academico = pAnioacademico
             AND llm.turno_examen   = pTurnoExamen
             AND llm.mesa_examen = pMesaexamen 
             AND llm.llamado = pLlamado 
             AND llm.prestamo = p.prestamo;

       IF dFechaExamen < TODAY   THEN
         LET vcFechaExamen = to_char(dFechaExamen,"%d/%m/%Y");
         LET vcUserError  = '800409' ;
         LET iStatus 	  = -1; 
         LET vcMsg 	  =  vcUserError  || ',' || vcFechaExamen;
         RETURN iStatus, vcMsg;
      END IF;
   END IF;	

   -- ************************* FIN CONTROLES OBLIGATORIOS *************************************************************

  --  El manejo de la transaccion lo hace la interface
   -- elimino la inscripcion.
   DELETE FROM sga_insc_examen
               WHERE unidad_academica 	= pUnidadAcademica
		AND carrera	= pCarrera
		AND legajo	= pLegajo
		AND materia	= pMateria
		AND anio_academico	= pAnioacademico
		AND  turno_examen	= pTurnoExamen
		AND  mesa_examen	= pMesaExamen
		AND  llamado	= pLlamado;

   -- obtengo el Nro. de Transaccion para la anulacion de la inscripcion
   EXECUTE PROCEDURE sp_nroTransaccAG( ) INTO vcNroTransacBaja ;

   -- agrego la baja de la inscripcion
   INSERT INTO sga_insc_exa_bajas (unidad_academica, 
				  carrera, 
				  legajo, 
				  materia, 
				  anio_academico, 
				  turno_examen, 
				  mesa_examen, 
				  llamado, 
				  fecha_baja,
				  fecha_inscripcion, 
				  tipo_inscripcion, 
				  equiv_parcial, 
				  materia_generica, 
	   			  nro_transaccion,
				  interfaz, 
				  nro_transac_baja,
				  interfaz_baja)
               		VALUES (pUnidadAcademica, 
				pCarrera, 
				pLegajo, 
				pMateria,
				pAnioacademico, 
				pTurnoexamen, 
				pMesaexamen, 
				pLlamado, 
				CURRENT year TO second, 
				dFecInscripcion, 
				vcTipoInscripcion, 
				vcEquivParcial,
				vcMateriaGenerica,
				vcNroTransaccion, 
				iInterfaz,
				vcNroTransacBaja,
				pInterfase ) ;

   -- si llego hasta aca, esta todo OK
   LET vcUserError  = '800405' ;
   LET iStatus 	= 1; 
   LET vcMsg 	=  vcUserError || ',' || vcNroTransacBaja ;

   -- devuelvo el resultado
   RETURN iStatus, vcMsg;

END;
END PROCEDURE;
-- ****************** FIN PROCEDURE sp820_eliminar_inscripcion_exami ******************


sp820_eliminar_inscripcion_exami( pUnidadAcademica	LIKE sga_alumnos.unidad_academica,
				pCarrera		LIKE sga_alumnos.carrera,
				pLegajo 		LIKE sga_alumnos.legajo,
				pMateria 		LIKE sga_insc_examen.materia,
				pAnioacademico 		LIKE sga_insc_examen.anio_academico,
				pTurnoExamen 		LIKE sga_insc_examen.turno_examen,
				pMesaExamen 		LIKE sga_insc_examen.mesa_examen,
				pLlamado 		LIKE sga_insc_examen.llamado,
				pInterfase		LIKE sga_insc_examen.interfaz )


select * from sga_insc_examen
where legajo = '32276666-4'

select * from sga_insc_exa_bajas
where legajo = '32276666-4'

select * from sga_fec_insc_llam
where turno_examen = 'junio'

execute procedure sp820_eliminar_inscripcion_exami('FHUC','AE','32276666-4','BIO31','2009','junio','A','1','3');
