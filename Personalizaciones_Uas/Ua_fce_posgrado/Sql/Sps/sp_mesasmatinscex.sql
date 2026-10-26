-------- Agregado para ejecución automática
CREATE PROCEDURE verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_mesasmatinscex') THEN
		DROP PROCEDURE sp_mesasmatinscex;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE verifica_objeto();
DROP PROCEDURE verifica_objeto();
---------------------------------------------------------------------------------------------------


CREATE PROCEDURE dba.sp_mesasmatinscex(pUnidadAcademica LIKE sga_alumnos.unidad_academica,
                                   pCarrera         LIKE sga_alumnos.carrera,
                                   pLegajo          LIKE sga_alumnos.legajo,
                                   pMateria         LIKE sga_mesas_examen.materia,
                                   pMateriaGenerica LIKE sga_mesas_examen.materia,
		pPlanAlumno      LIKE sga_planes.plan,
		pVersionAlumno   LIKE sga_versiones_plan.version,
		pCtrTipoInsc     char(1),   
		pCtrRindeCualqSede char(1),
		pCtrModalidad    char(1) 
)
                       RETURNING  varchar(5),
                                  varchar(5),  
                                  varchar(15),
                                  varchar(5),
                                  varchar(5),
                                  integer,
                                  varchar(20),
                                  varchar(15),
                                  varchar(15),
                                  varchar(5),
                                  char(1),
                                  integer,
                                  date,
                                  date,
                                  char(8),
                                  date,
                                  varchar(255),
                                  varchar(5),
		  varchar(255),
		varchar(10);
/*
Retorna:
	varchar(5),   -- 0  unidad academica
	varchar(5),   -- 1  carrera
	varchar(15),	-- 2  legajo
	varchar(5),   -- 3  materia
	varchar(5),   -- 4  materia generica
	integer,      -- 5  anio academico
	varchar(20),	-- 6  turno examen
	varchar(15),	-- 7  mesa examen
	varchar(15),  -- 8  catedra
	varchar(5),   -- 9  grupo_carrera
	char(1),      -- 10 admite libres
	integer,	-- 11 llamado
	date,         -- 12 fecha inicio insc llamado
	date,	 -- 13 fecha fin insc llamado
	char(8),      -- 14 hora del prestamo del aula
	date,	  -- 15 fecha del prestamo del aula
	varchar(255), -- 16 docentes de una mesa
	varchar(5);     -- 17 sede de la mesa
	varchar(255)  18 Nombre Sede
	varchar(10)   -- 19 fecha del prestamo del aula en formato string
*/
   -- recupera las mesas de una materia segun una condicion de inscripcion o si la mesa admite libres
   -- llamado este habilitado
   -- que la fecha de prestamo sea mayor o igual a TODAY VER si va !!!
   -- que la fecha de inicio y fin de inscripcion a examen de la mesa este vigente
   -- Nota: NO toma en cuenta la condicion de inscripcion

   DEFINE vcUnidadAcademica LIKE sga_mesas_examen.unidad_academica;
   DEFINE vcMateria         LIKE sga_mesas_examen.materia;
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
   DEFINE vcFecPrest       varchar(10);

   DEFINE vcDocentesMesa    varchar(255);
   DEFINE vcModalidad       LIKE sga_param_sistema.valor;

   DEFINE v_plan            LIKE sga_planes.plan;
   DEFINE v_version         LIKE sga_versiones_plan.version;
   DEFINE cCtrTipoInsc      char(1); -- par_parametros_sis.parametro
   DEFINE vTieneRegularidad integer;
   DEFINE vFecha_Fin_Regul  date;
   DEFINE v_vrindetodas varchar(2);
   DEFINE vsedemesa, vsede LIKE sga_sedes.sede;
   DEFINE vcNombreSede LIKE sga_sedes.nombre;
--- abril/11
   DEFINE vCondRegularidad  	integer;
   DEFINE vFecha_Fin_Regul_12 date;
	
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
   LET vcFecPrest         = '';
   LET vcDocentesMesa	 = '';
   LET vTieneRegularidad = 1;
   LET vFecha_Fin_Regul  = NULL;
   LET vFecha_Fin_Regul_12 = NULL;
   LET vCondRegularidad  = -1;

   -- Mira los parámetros del sistema para saber si debe restringir las mesas de acuerdo
   -- al tipo de inscripción que admiten
   EXECUTE PROCEDURE sp_param_sistema('insc_examen_seleccion_auto_tipo_insc') INTO cCtrTipoInsc;
   
   -- Si lo debe controlar, se fija si el alumno tiene o no una regularidad para la materia
   IF cCtrTipoInsc = 'S' THEN
     EXECUTE PROCEDURE sp_existeRegAluMat(pUnidadAcademica, pMateria, pCarrera, pLegajo) 
            INTO vTieneRegularidad, vFecha_Fin_Regul;
   END IF;


---- abril/11 se fija si el alumno tiene condición de regularidad 12 (regular con Trabajo aprobado)
    EXECUTE PROCEDURE sp820_condicionregalumat(pUnidadAcademica, pMateria, pCarrera, pLegajo) 
            INTO vCondRegularidad, vFecha_Fin_Regul_12;

   -- Busca el plan del alumno
   EXECUTE PROCEDURE sp_plan_de_alumno( pUnidadAcademica, pCarrera, pLegajo, TODAY)
           INTO v_plan, v_version;


  -- Verifico el parametro para saber si el alumno puede rendir en cualquier sede o no
    EXECUTE PROCEDURE sp_param_sistema ('rinde_en_cualquier_sede') INTO v_vrindetodas;

  -- Obtengo la sede del alumno
  SELECT sede  INTO vSede
  FROM sga_alumnos
  WHERE unidad_academica = punidadacademica AND
	carrera = pcarrera AND
	legajo = plegajo;


   EXECUTE PROCEDURE sp_param_sistema('modalidad_de_inscripciones_a_examenes') 
           INTO vcModalidad;

   LET vcModalidad = TRIM(vcModalidad);

   IF vcModalidad = '' or vcModalidad IS NULL 
   THEN
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
                                sga_mesas_examen.mesa_examen, sga_llamados_mesa.llamado) docentes_llamado,
	       sga_mesas_examen.sede
          FROM sga_mesas_examen,
               sga_llamados_mesa,
               sga_fec_insc_llam,
               sga_prestamos

         WHERE sga_mesas_examen.unidad_academica  = pUnidadAcademica
           AND sga_mesas_examen.materia           = pMateria
           AND ((sga_mesas_examen.sede = vSede AND v_vrindetodas = 'N' ) OR v_vrindetodas = 'S')
           AND sga_llamados_mesa.unidad_academica =  sga_mesas_examen.unidad_academica
           AND sga_llamados_mesa.materia          =  sga_mesas_examen.materia
           AND sga_llamados_mesa.anio_academico   =  sga_mesas_examen.anio_academico
           AND sga_llamados_mesa.turno_examen     =  sga_mesas_examen.turno_examen
           AND sga_llamados_mesa.mesa_examen      =  sga_mesas_examen.mesa_examen
           AND sga_llamados_mesa.habilitado       <> 'N'
           
           AND sga_llamados_mesa.prestamo         =  sga_prestamos.prestamo
           AND sga_prestamos.fecha                >= TODAY
              
           AND ( sga_mesas_examen.carrera = pCarrera OR sga_mesas_examen.carrera IS NULL )
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
                                sga_mesas_examen.turno_examen, sga_mesas_examen.mesa_examen, sga_llamados_mesa.llamado),
               sga_mesas_examen.sede
          FROM sga_mesas_examen,
               sga_llamados_mesa,
               sga_exep_insc_llam,
               sga_prestamos
         WHERE sga_mesas_examen.unidad_academica   = pUnidadAcademica
           AND sga_mesas_examen.materia            = pMateria
           AND ((sga_mesas_examen.sede = vSede AND v_vrindetodas = 'N' ) OR v_vrindetodas = 'S')
               
           AND sga_llamados_mesa.unidad_academica  = sga_mesas_examen.unidad_academica
           AND sga_llamados_mesa.materia           = sga_mesas_examen.materia
           AND sga_llamados_mesa.anio_academico    = sga_mesas_examen.anio_academico
           AND sga_llamados_mesa.turno_examen      = sga_mesas_examen.turno_examen
           AND sga_llamados_mesa.mesa_examen       = sga_mesas_examen.mesa_examen
           AND sga_llamados_mesa.habilitado        <> 'N'
                
           AND sga_llamados_mesa.prestamo          = sga_prestamos.prestamo
           AND sga_prestamos.fecha                 >= TODAY
               
           AND ( sga_mesas_examen.carrera = pCarrera OR sga_mesas_examen.carrera IS NULL )
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
                   fecha, docentes_llamado, temp_matinsexa.sede, sga_sedes.nombre
              INTO vcUnidadAcademica, vcMateria, iAnioAcademico, vcTurnoExamen, vcMesaExamen,
                   vcCatedra, vcGrupoCarrera, cAdmiteLibres, iLlamadoMesa, dFecInicioInscll,dFecFinInscll,
                   hHoraInicioPrest, dFecPrest, vcDocentesMesa, vsedemesa, vcNombreSede
              FROM temp_matinsexa, sga_sedes
		WHERE temp_matinsexa.sede = sga_sedes.sede
           -- ORDER BY me.mesa_examen ASC,  pr.fecha ASC 
         
           -- Si debe filtrar las mesas según su tipo de inscripción, saltea la línea en las siguientes condiciones:
           
            IF cCtrTipoInsc = 'S' THEN

               	IF dFecPrest <= vFecha_Fin_Regul OR vFecha_Fin_Regul IS NULL THEN	

                	IF vTieneRegularidad = 1 THEN
                    		 IF cAdmiteLibres = 'L' THEN
                      			CONTINUE FOREACH;
                     		else
                      		 --abril/11  si la mesa solo admite regulares con trabajo y el alumno no tiene la condición de regularidad con trabajo
                      		 	IF vCondRegularidad = -1 AND (cAdmiteLibres = 'F' ) THEN
                               				CONTINUE FOREACH;
                      			else
                  			--abril/11  si la mesa solo admite regulares  y el alumno  tiene la condición de regularidad con trabajo practico no vencida
                       				IF vCondRegularidad = 1  THEN
                                                                                       IF    (dFecPrest <= vFecha_Fin_Regul_12 OR vFecha_Fin_Regul_12 IS NULL)  THEN
                                                                                               IF (cAdmiteLibres = 'R' OR cAdmiteLibres = 'A' ) THEN
                       					CONTINUE FOREACH;
                                                                                               END IF;
                                                                                       ELSE
                                                                ---ABRIL/11 si tiene la regularidad con practico vencida no muestra este tipo de mesa, se considera como regular
                                                                                               IF (cAdmiteLibres = 'F' ) THEN
                       					CONTINUE FOREACH;
                                                                                               END IF;
                                                                                       END IF;
                       				END IF;
                      			end if;
			end if;
                   	
                	 ELSE
                 	 -- Si el alumno no tiene la regularidad y la mesa admite solo alumnos regulares
                 	  --abril/11   o regulares con trabajo aprobado
                     		IF (cAdmiteLibres = 'R'  or cAdmiteLibres = 'F' ) THEN
                     			 CONTINUE FOREACH;
                     		END IF;
                	END IF;
       	ELSE
                   -- Si la mesa admite solo alumnos regulares
                  	IF (cAdmiteLibres = 'R'  or cAdmiteLibres = 'F'  ) THEN
                      		CONTINUE FOREACH;
                  	END IF;
       	END IF;
            END IF;

	-- Verifico el Grupo de Carrera en el que esta definido la mesa de examen
	IF vcGrupoCarrera IS NOT NULL THEN
            IF (SELECT count(*) 
                  FROM sga_carreras_grupo
                  WHERE unidad_academica = pUnidadAcademica
                    AND grupo_carrera    = vcGrupoCarrera
                    AND carrera          = pCarrera) <= 0 THEN
                
                  -- Continua, la carrera del Alumno no pertenece al grupo de Carrera de la mesa de examen
                CONTINUE FOREACH;
            END IF;
          END IF;
	 
          -------------- Modificado 18-11-2014
       
         LET vcFecPrest = to_char(dFecPrest, '%d/%m/%Y');
          -------------

          -- si no encontro nada, devuelve nulos
 	  RETURN pUnidadAcademica, pCarrera, pLegajo, vcMateria, pMateriaGenerica, 
                 iAnioAcademico, vcTurnoExamen, vcMesaExamen, vcCatedra, vcGrupoCarrera, cAdmiteLibres, 
                 iLlamadoMesa, dFecInicioInscll, dFecFinInscll, hHoraInicioPrest, dFecPrest, vcDocentesMesa, vsedemesa, vcNombreSede, vcFecPrest  
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
END PROCEDURE                                                                                                                                                                                                                                                 
