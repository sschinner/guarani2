-- **********************************************************************
-- SP: sp820_ver_exi_mesa
-- Descripcion: Recupera las Mesas de Examen de la Materia que selecciono. En el caso de que ya este inscripto en alguna mesa, no devuelve nada.
-- el alumno para inscribirse a Examen
--
-- Fecha: 02/02/2000
-- Fecha de Ultima modificacion: 10/09/2001
--
-- Version de modificacion: 2.03.0
--    Se quito el ORDER BY y se agregó que la tabla 
--    temporal se cree sin logging.  
--    Se debe ordenar en la interfaz.
-- 
-- Recibe:	- Unidad_academica
--		- Tipo_documento
--		- Nro_documento
--		- Materia
--			
-- Retorna:	- Legajo y Datos de la Mesa de Examen
-- **********************************************************************
DROP PROCEDURE sp820_ver_exi_mesa;
CREATE PROCEDURE sp820_ver_exi_mesa(pUnidadAcademica LIKE sga_alumnos.unidad_academica,
									pTipoDocumento LIKE sga_personas.tipo_documento,
									pNroDocumento LIKE sga_personas.nro_documento,
									pMateria         LIKE sga_mesas_examen.materia)

                       RETURNING  varchar(5),   -- 0  unidad academica
                                  varchar(5),   	-- 1  carrera
                                  varchar(15),	-- 2  legajo
                                  varchar(5),   	-- 3  materia
                                  varchar(5),   	-- 4  materia generica
                                  integer,      	-- 5  anio academico
                                  varchar(20),	-- 6  turno examen
                                  varchar(15),	-- 7  mesa examen
                                  varchar(15),  	-- 8  catedra
                                  varchar(5),   	-- 9  grupo_carrera
                                  char(1),      	-- 10 admite libres
                                  integer,		-- 11 llamado
                                  date,         	-- 12 fecha inicio insc llamado
                                  date,	        	-- 13 fecha fin insc llamado
                                  char(8),      	-- 14 hora del prestamo del aula
                                  date,	        	-- 15 fecha del prestamo del aula
                                  varchar(255),	-- 16 docentes de una mesa
		  varchar(40);	-- 17 nombre materia 

   -- recupera las mesas de una materia segun una condicion de inscripcion o si la mesa admite libres
   -- llamado este habilitado
   -- que la fecha de prestamo sea mayor o igual a TODAY VER si va !!!
   -- que la fecha de inicio y fin de inscripcion a examen de la mesa este vigente
   -- Nota: NO toma en cuenta la condicion de inscripcion

   DEFINE vcUnidadAcademica LIKE sga_mesas_examen.unidad_academica;
   DEFINE vcMateria         LIKE sga_mesas_examen.materia;
   DEFINE vcNombreMat         LIKE sga_atrib_mat_plan.nombre_materia;
   DEFINE iAnioAcademico    LIKE sga_mesas_examen.anio_academico;
   DEFINE vcTurnoExamen     LIKE sga_mesas_examen.turno_examen;
   DEFINE vcMesaExamen      LIKE sga_mesas_examen.mesa_examen;
   DEFINE vcCatedra         LIKE sga_mesas_examen.catedra;
   DEFINE vcGrupoCarrera    LIKE sga_mesas_examen.grupo_carrera;
   DEFINE vcTipoInsc        CHAR(1);

   DEFINE cAdmiteLibres     LIKE sga_mesas_examen.admite_libres;
   DEFINE iLlamadoMesa      LIKE sga_llamados_mesa.llamado;
   DEFINE dFecInicioInscll  LIKE sga_fec_insc_llam.fecha_inicio;
   DEFINE dFecFinInscll     LIKE sga_fec_insc_llam.fecha_fin;
   DEFINE hHoraInicioPrest  char(8);
   DEFINE dFecPrest         LIKE sga_prestamos.fecha;
   DEFINE vcDocentesMesa    varchar(255);
   DEFINE vcModalidad       LIKE sga_param_sistema.valor;

   DEFINE v_plan            LIKE sga_planes.plan;
   DEFINE v_version         LIKE sga_versiones_plan.version;
   DEFINE cCtrTipoInsc      char(1); -- par_parametros_sis.parametro
   DEFINE vTieneRegularidad integer;
   DEFINE vFecha_Fin_Regul  date;
   
   DEFINE vc_carrera_int       LIKE sga_carreras.carrera;
   DEFINE vc_Tipo          CHAR(1);
   DEFINE vc_nro_inscr		LIKE 	sga_personas.nro_inscripcion;
   DEFINE vc_Legajo		LIKE	sga_alumnos.legajo;

	
BEGIN

   LET vcUnidadAcademica = '';
   LET vcMateria         = '';
   LET iAnioAcademico    = 1;
   LET vcTurnoExamen     = '';
   LET vcMesaExamen      = '';
   LET vcCatedra         = '';
   LET cAdmiteLibres     = '';
   LET iLlamadoMesa      = 0;	
   LET dFecInicioInscll  = TODAY;
   LET dFecFinInscll     = TODAY;
   LET hHoraInicioPrest  = '';
   LET dFecPrest         = TODAY;
   LET vcDocentesMesa	 = '';
   LET vTieneRegularidad = 1;
   LET vFecha_Fin_Regul  = NULL;


   
   -- Obtengo la carrera de integración de la unidad academica
    SELECT carrera INTO vc_carrera_int
    	FROM sga_carreras_grupo
    		WHERE grupo_carrera = 'i0001';

	SELECT p.nro_inscripcion,  alu.legajo INTO vc_nro_inscr, vc_legajo
		FROM sga_personas p
				join sga_alumnos alu
					on p.nro_inscripcion = alu.nro_inscripcion 
						and alu.carrera = vc_carrera_int
			WHERE p.unidad_academica = pUnidadAcademica
				AND p.tipo_documento   = pTipoDocumento
				AND p.nro_documento    = pNroDocumento;
   
   -- Mira los parámetros del sistema para saber si debe restringir las mesas de acuerdo
   -- al tipo de inscripción que admiten
   EXECUTE PROCEDURE sp_param_sistema('insc_examen_seleccion_auto_tipo_insc') INTO cCtrTipoInsc;
   
   -- Si lo debe controlar, se fija si el alumno tiene o no una regularidad para la materia
   IF cCtrTipoInsc = 'S' THEN
     EXECUTE PROCEDURE sp_existeRegAluMat(pUnidadAcademica, pMateria, vc_carrera_int, vc_Legajo) 
            INTO vTieneRegularidad, vFecha_Fin_Regul;
   END IF;

   -- Busca el plan del alumno
   EXECUTE PROCEDURE sp_plan_de_alumno( pUnidadAcademica, vc_carrera_int, vc_Legajo, TODAY)
           INTO v_plan, v_version;

   EXECUTE PROCEDURE sp_param_sistema('modalidad_de_inscripciones_a_examenes') 
           INTO vcModalidad;

   LET vcModalidad = TRIM(vcModalidad);

   IF vcModalidad = '' or vcModalidad IS NULL THEN
      -- Error
      RAISE EXCEPTION -746,0,'Error. Falta definir parametro "modalidad_de_inscripciones_a_examenes"';

   ELIF vcModalidad = '1' THEN
      -- La inscripcion es por Turno

   ELIF vcModalidad = '2' THEN
	-- La inscripcion es por Llamado
	-- recupera las materias que tienen mesas de examenes dependiendo de la condicion elegida por el alumno
	BEGIN
	  ON EXCEPTION IN (-206)
	  END EXCEPTION WITH RESUME;
	  DROP TABLE temp_matinsexa;
	END
	-- Grabo los datos en una tabla temporal
	SELECT sga_mesas_examen.unidad_academica,
		sga_mesas_examen.materia,
		sga_mesas_examen.anio_academico,
		sga_mesas_examen.turno_examen,
		sga_mesas_examen.mesa_examen,
		sga_mesas_examen.catedra,
		sga_mesas_examen.grupo_carrera,
		sga_mesas_examen.admite_libres,
		sga_llamados_mesa.llamado,
		sga_fec_insc_llam.fecha_inicio,
		sga_fec_insc_llam.fecha_fin,
		sga_prestamos.hora_inicio,
		sga_prestamos.fecha,
		sp_doc_una_mesa( sga_mesas_examen.unidad_academica, sga_mesas_examen.materia,
                                sga_mesas_examen.anio_academico, sga_mesas_examen.turno_examen, 
                                sga_mesas_examen.mesa_examen, sga_llamados_mesa.llamado) docentes_llamado
	FROM sga_mesas_examen,
		sga_llamados_mesa,
		sga_fec_insc_llam,
		sga_prestamos

	WHERE sga_mesas_examen.unidad_academica  = pUnidadAcademica
           AND sga_mesas_examen.materia           = pMateria

           AND sga_llamados_mesa.unidad_academica =  sga_mesas_examen.unidad_academica
           AND sga_llamados_mesa.materia          =  sga_mesas_examen.materia
           AND sga_llamados_mesa.anio_academico   =  sga_mesas_examen.anio_academico
           AND sga_llamados_mesa.turno_examen     =  sga_mesas_examen.turno_examen
           AND sga_llamados_mesa.mesa_examen      =  sga_mesas_examen.mesa_examen
           AND sga_llamados_mesa.habilitado       <> 'N'
           
           AND sga_llamados_mesa.prestamo         =  sga_prestamos.prestamo
           AND sga_prestamos.fecha                >= TODAY
              
           AND ( sga_mesas_examen.carrera = vc_carrera_int OR sga_mesas_examen.carrera IS NULL )
           AND ( sga_mesas_examen.plan = v_plan OR sga_mesas_examen.plan IS NULL)
              
           AND sga_fec_insc_llam.anio_academico   = sga_llamados_mesa.anio_academico
           AND sga_fec_insc_llam.turno_examen     = sga_llamados_mesa.turno_examen
           AND sga_fec_insc_llam.llamado          = sga_llamados_mesa.llamado
           AND CURRENT YEAR TO SECOND BETWEEN sga_fec_insc_llam.fecha_inicio AND sga_fec_insc_llam.fecha_fin
              
           AND NOT EXISTS (SELECT '' FROM sga_exep_insc_llam
                WHERE sga_exep_insc_llam.unidad_academica = sga_llamados_mesa.unidad_academica
                  AND sga_exep_insc_llam.materia          = sga_llamados_mesa.materia
                  AND sga_exep_insc_llam.anio_academico   = sga_llamados_mesa.anio_academico
                  AND sga_exep_insc_llam.turno_examen     = sga_llamados_mesa.turno_examen
                  AND sga_exep_insc_llam.mesa_examen      = sga_llamados_mesa.mesa_examen
                  AND sga_exep_insc_llam.llamado          = sga_llamados_mesa.llamado) 
              
        UNION 
             
	SELECT sga_mesas_examen.unidad_academica,
		sga_mesas_examen.materia,
	   sga_mesas_examen.anio_academico,
	   sga_mesas_examen.turno_examen,
	   sga_mesas_examen.mesa_examen,
	   sga_mesas_examen.catedra,
	   sga_mesas_examen.grupo_carrera,
	   sga_mesas_examen.admite_libres,
	   sga_llamados_mesa.llamado,
	   sga_exep_insc_llam.fecha_inicio,
	   sga_exep_insc_llam.fecha_fin,
	   sga_prestamos.hora_inicio,
	   sga_prestamos.fecha,
	   sp_doc_una_mesa( sga_mesas_examen.unidad_academica, sga_mesas_examen.materia, sga_mesas_examen.anio_academico,
	   sga_mesas_examen.turno_examen, sga_mesas_examen.mesa_examen, sga_llamados_mesa.llamado)
	FROM sga_mesas_examen,
		sga_llamados_mesa,
		sga_exep_insc_llam,
		sga_prestamos
	 WHERE sga_mesas_examen.unidad_academica   = pUnidadAcademica
	   AND sga_mesas_examen.materia            = pMateria
		   
	   AND sga_llamados_mesa.unidad_academica  = sga_mesas_examen.unidad_academica
	   AND sga_llamados_mesa.materia           = sga_mesas_examen.materia
	   AND sga_llamados_mesa.anio_academico    = sga_mesas_examen.anio_academico
	   AND sga_llamados_mesa.turno_examen      = sga_mesas_examen.turno_examen
	   AND sga_llamados_mesa.mesa_examen       = sga_mesas_examen.mesa_examen
	   AND sga_llamados_mesa.habilitado        <> 'N'
			
	   AND sga_llamados_mesa.prestamo          = sga_prestamos.prestamo
	   AND sga_prestamos.fecha                 >= TODAY
		   
	   AND ( sga_mesas_examen.carrera = vc_carrera_int OR sga_mesas_examen.carrera IS NULL )
	   AND ( sga_mesas_examen.plan = v_plan OR sga_mesas_examen.plan IS NULL)
		   
	   AND sga_exep_insc_llam.unidad_academica = sga_llamados_mesa.unidad_academica
	   AND sga_exep_insc_llam.materia          = sga_llamados_mesa.materia
	   AND sga_exep_insc_llam.anio_academico   = sga_llamados_mesa.anio_academico
	   AND sga_exep_insc_llam.turno_examen     = sga_llamados_mesa.turno_examen
	   AND sga_exep_insc_llam.mesa_examen      = sga_llamados_mesa.mesa_examen
	   AND sga_exep_insc_llam.llamado          = sga_llamados_mesa.llamado
	   AND CURRENT YEAR TO SECOND BETWEEN sga_exep_insc_llam.fecha_inicio AND sga_exep_insc_llam.fecha_fin

        -- ORDER BY 5,13
	INTO TEMP temp_matinsexa WITH NO LOG;

	IF DBINFO("sqlca.sqlerrd2") > 0 THEN	

	FOREACH 
            SELECT unidad_academica, materia, anio_academico,turno_examen,mesa_examen,
                   catedra,grupo_carrera,admite_libres, llamado,fecha_inicio, fecha_fin, hora_inicio, 
                   fecha, docentes_llamado
              INTO vcUnidadAcademica, vcMateria, iAnioAcademico, vcTurnoExamen, vcMesaExamen,
                   vcCatedra, vcGrupoCarrera, cAdmiteLibres, iLlamadoMesa, dFecInicioInscll,dFecFinInscll,
                   hHoraInicioPrest, dFecPrest, vcDocentesMesa
              FROM temp_matinsexa
           -- ORDER BY me.mesa_examen ASC,  pr.fecha ASC 

	-- Si tiene ya una inscripción no debe mostrar nada y mencionar la inscripcion

	IF EXISTS (select '*' 
		from sga_insc_examen
		where unidad_academica = vcUnidadAcademica
		and carrera = vc_carrera_int
		and legajo = vc_legajo
		and anio_academico =  iAnioAcademico
		and turno_examen = vcTurnoExamen
		--and mesa_examen =vcMesaExamen
		and llamado = iLlamadoMesa
		and materia =vcMateria) THEN

		EXIT FOREACH;
	END IF;

         
           -- Si debe filtrar las mesas según su tipo de inscripción, saltea la línea en las siguientes condiciones:
           
	IF cCtrTipoInsc = 'S' THEN

	  IF dFecPrest <= vFecha_Fin_Regul OR vFecha_Fin_Regul IS NULL THEN	
		 
		  -- Si el alumno tiene la regularidad y la mesa admite solo alumnos libres
		  IF vTieneRegularidad = 1 AND cAdmiteLibres = 'L' THEN
			  CONTINUE FOREACH;

			 -- Si el alumno no tiene la regularidad y la mesa admite solo alumnos regulares
		  ELIF vTieneRegularidad = -1 AND cAdmiteLibres = 'R' THEN

			  CONTINUE FOREACH;
		  END IF;

	 ELIF dFecPrest > vFecha_Fin_Regul  AND vFecha_Fin_Regul IS NOT NULL THEN	
		  
		  -- Si la mesa admite solo alumnos regulares
		  IF cAdmiteLibres = 'R' THEN
			  CONTINUE FOREACH;
		  END IF;

	  END IF;

	END IF

	-- Verifico el Grupo de Carrera en el que esta definido la mesa de examen
	IF vcGrupoCarrera IS NOT NULL THEN
		IF (SELECT count(*) 
			  FROM sga_carreras_grupo
			  WHERE unidad_academica = pUnidadAcademica
				AND grupo_carrera    = vcGrupoCarrera
				AND carrera          = vc_carrera_int) <= 0 THEN
			
			  -- Continua, la carrera del Alumno no pertenece al grupo de Carrera de la mesa de examen
			CONTINUE FOREACH;
		END IF;
    END IF;
	
SELECT nombre_materia INTO vcNombreMat FROM sga_atrib_mat_plan
		WHERE vcMateria=materia
		AND  carrera = vc_carrera_int
		AND plan = v_plan
		AND version = v_version;


   
	  -- si no encontro nada, devuelve nulos
	RETURN pUnidadAcademica, vc_carrera_int, vc_Legajo, vcMateria, "", 
			 iAnioAcademico, vcTurnoExamen, vcMesaExamen, vcCatedra, vcGrupoCarrera, cAdmiteLibres, 
			 iLlamadoMesa, dFecInicioInscll, dFecFinInscll, hHoraInicioPrest, dFecPrest, vcDocentesMesa, vcNombreMat  
	  WITH RESUME;

   END FOREACH ;

   BEGIN
	  ON EXCEPTION IN (-206)
	  END EXCEPTION WITH RESUME;
		 
	  -- Borro la tabla temporal	
	  DROP TABLE temp_matinsexa;
   END
  END IF;
ELSE
	-- Error
	RAISE EXCEPTION -746,0,'Error. Falta definir parametro "modalidad_de_inscripciones_a_examenes"';
END IF;  -- vcModalidad

END;
END PROCEDURE;
-- ++++++++++++++++++++++++++++++++++++++ Fin SP sp820_ver_exi_mesa  ++++++++++++++++++++++++++++++++++++++++++++++

-- execute procedure sp820_ver_exi_mesa  ('FBCB', 0, 32959464, '12003');

execute procedure sp820_ver_exi_mesa ('FHUC', 0, 32276666, 'BIO31');


select * from sga_atrib_mat_plan
where materia="BIO31"