CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_fichalhisaca') THEN
		DROP PROCEDURE sp820_fichalhisaca;
	END IF;		
END
END PROCEDURE;

EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.7.0
-- Procedure sp_FichAluHisAcad
-- Ultima version de modificacion: 2.0.0
-- 
-- Muestra la historia academica de una persona (todas las carreras).
-- Usa el SP: sp_histAcademica (que trae la info de un alumno).
--
-- PERSONALIZACION:
-- Procedure sp820_FichAlHisAca
-- Usa el SP: sp820_histAcadEss (que trae la info de un alumno).
-- *****************************************************************************

CREATE PROCEDURE "dba".sp820_FichAlHisAca ( pUnidadAcademica LIKE sga_personas.unidad_academica, pNroInscripcion LIKE sga_personas.nro_inscripcion )
       RETURNING varchar(5), varchar(10), varchar(30), varchar(30), varchar(5), varchar(100), varchar(15), varchar(5), varchar(5), varchar(5), varchar(100), date, varchar(15), varchar(5), varchar(255), char(1), varchar(10), varchar(10), varchar(15), varchar(15), varchar(15), varchar(1);

-- Descripcion del Return:
-- varchar(5),   -- unidad_academica
-- varchar(10),  -- nro_inscripcion
-- varchar(30),  -- apellido
-- varchar(30),  -- nombres
-- varchar(5),   -- carrera
-- varchar(100), -- carrera_nombre
-- varchar(15),  -- legajo
-- varchar(5),   -- plan
-- varchar(5),   -- version
-- varchar(5),   -- materia
-- varchar(100), -- nombre de la materia
-- date,         -- fecha
-- varchar(15),  -- resultado
-- varchar(5),   -- nota
-- varchar(255),  -- forma de aprobacion
-- char(1),      -- tipo de acta
-- varchar(10),  -- acta
-- varchar(10),  -- acta promocion
-- varchar(15)   -- nro resolucion
-- varchar(15),	-- Descripcion de la nota
-- varchar(15);	-- Concepto de la nota
-- varchar(1)	-- Suma en totales (S/N)

DEFINE vc_apellido         LIKE sga_personas.apellido;
DEFINE vc_nombres          LIKE sga_personas.nombres;
DEFINE vc_carrera          LIKE sga_alumnos.carrera;
DEFINE vc_carrera_nombre   LIKE sga_carreras.nombre;
DEFINE vc_legajo           LIKE sga_alumnos.legajo;
DEFINE vc_plan             LIKE sga_atrib_mat_plan.plan;
DEFINE vc_version          LIKE sga_atrib_mat_plan.version;
DEFINE vc_materia          LIKE sga_materias.materia;
DEFINE vc_materia_nombre   LIKE sga_materias.nombre;
DEFINE vcNombreMatRed  varchar(30);
DEFINE vdt_fecha           LIKE sga_detalle_acta.fecha_de_examen;
DEFINE vc_resultado        VARCHAR(15);
DEFINE vc_nota             LIKE sga_detalle_acta.nota;
DEFINE vc_forma_aprob      VARCHAR(255);
DEFINE vc_tipo_acta        LIKE sga_actas_examen.tipo_acta;
DEFINE vc_acta             LIKE sga_actas_examen.acta;
DEFINE vc_acta_promo       LIKE sga_actas_promo.acta;
DEFINE vc_nro_resol        LIKE sga_equiv_resol.nro_resolucion;
DEFINE iEquivalencia        LIKE sga_equiv_otorgada.equivalencia;
DEFINE vc_car_nom_red      LIKE sga_carreras.nombre_reducido;
DEFINE vi_retorno          SMALLINT;
DEFINE iEscalaNota       integer;
DEFINE suma_totales       varchar(1);

DEFINE	vcDescripcion	LIKE sga_det_escala.descripcion;
DEFINE	vcConcepto	LIKE sga_det_escala.concepto;

BEGIN
   
   -- inicializaciones.
   LET vc_apellido         = NULL;
   LET vc_nombres          = NULL;
   LET vc_carrera          = NULL;
   LET vc_carrera_nombre   = NULL;
   LET vc_legajo           = NULL;
   LET vc_plan             = NULL;
   LET vc_version          = NULL;
   LET vc_materia          = NULL;
   LET vc_materia_nombre   = NULL;
   LET vdt_fecha           = NULL;
   LET vc_resultado        = NULL;
   LET vc_nota             = NULL;
   LET vc_forma_aprob      = NULL;
   LET vc_tipo_acta        = NULL;
   LET vc_acta             = NULL;
   LET vc_acta_promo       = NULL;
   LET vc_nro_resol        = NULL;
   LET vi_retorno          = 0;
   LET iEscalaNota        = NULL;
   LET vcNombreMatRed        = NULL;
   
   LET vcDescripcion	= NULL	;
   LET vcConcepto		= NULL	;
   LET suma_totales = NULL;

   -- selecciono los datos personales de la persona.
   SELECT sga_personas.apellido,
          sga_personas.nombres
     INTO vc_apellido, vc_nombres
     FROM sga_personas
    WHERE sga_personas.unidad_academica = pUnidadAcademica
      AND sga_personas.nro_inscripcion = pNroInscripcion;

   -- selecciono las carreras en las que esta inscripta la persona.
   FOREACH SELECT sga_alumnos.carrera,
                  sga_carreras.nombre_reducido,
                  sga_alumnos.legajo
             INTO vc_carrera, vc_carrera_nombre, vc_legajo
             FROM sga_carreras,
                  sga_alumnos
            WHERE sga_carreras.unidad_academica = sga_alumnos.unidad_academica
              AND sga_carreras.carrera = sga_alumnos.carrera
              AND sga_alumnos.unidad_academica = pUnidadAcademica
              AND sga_alumnos.nro_inscripcion = pNroInscripcion
         ORDER BY sga_alumnos.carrera
      
      -- ejecuto el SP de la historia academica para cada carrera de la persona.
      FOREACH EXECUTE PROCEDURE sp820_histAcadEss ( pUnidadAcademica, vc_carrera, vc_legajo ) 
         INTO vc_materia, vc_materia_nombre, vdt_fecha, vc_resultado, vc_nota, vc_forma_aprob, vc_tipo_acta, vc_acta, vc_acta_promo, vc_nro_resol, vc_plan, vc_version, vc_car_nom_red, vcNombreMatRed, iEscalaNota, iEquivalencia, vcDescripcion, vcConcepto
         
	let suma_totales = "S";
	if exists(	select ''
		from u820_cursos_ing
		where unidad_academica = pUnidadAcademica
			and carrera = vc_carrera
			and materia = vc_materia) then
		
		let suma_totales = "N";
	end if;
		

   
         -- el retorno final por cada materia.
         LET vi_retorno = 1;
         RETURN pUnidadAcademica, pNroInscripcion, vc_apellido, vc_nombres, vc_carrera, vc_carrera_nombre, vc_legajo, vc_plan, vc_version, vc_materia,
 		vc_materia_nombre, vdt_fecha, vc_resultado, vc_nota, vc_forma_aprob, vc_tipo_acta, vc_acta, vc_acta_promo, vc_nro_resol, 
		vcdescripcion, vcconcepto, suma_totales WITH RESUME;
         
      END FOREACH;

--****************************************************************************
-- Incluyo la actuación provisoria
--****************************************************************************
      LET iEquivalencia = null;
      LET vc_nro_resol = null;
      LET vc_forma_aprob = "Examen (Act.Prov.)";
      FOREACH  select a.materia, atr.nombre_materia, d.fecha_de_examen, DECODE(d.resultado,'A', 'Aprobado' , 'R',  'Reprobado', 'P', 'Promocionado'), d.nota, a.tipo_acta, a.acta, 0 as vc_acta_promo,
			d.plan, d.version, ca.nombre_reducido, atr.nombre_reducido, a.escala_notas, de.descripcion, de.concepto
		INTO vc_materia, vc_materia_nombre, vdt_fecha, vc_resultado, vc_nota, vc_tipo_acta, vc_acta, vc_acta_promo, 
			vc_plan, vc_version, vc_car_nom_red, vcNombreMatRed, iEscalaNota, vcDescripcion, vcConcepto
		from sga_actas_examen a
			join sga_detalle_acta d
				join sga_atrib_mat_plan atr
				  on d.carrera = atr.carrera
					and d.plan = atr.plan
					and d.version = atr.version
			  on a.tipo_acta = d.tipo_acta
				and a.acta = d.acta
			join sga_carreras ca
			  on d.carrera = ca.carrera
			join sga_det_escala de
			  on d.nota = de.nota
				and a.escala_notas = de.escala_notas
		where a.materia = atr.materia
			and  a.unidad_academica = pUnidadAcademica
			and d.carrera = vc_carrera
			and d.legajo = vc_legajo
			and a.estado not in ("B", "C")

         -- el retorno final por cada materia.
         LET vi_retorno = 1;
         RETURN pUnidadAcademica, pNroInscripcion, vc_apellido, vc_nombres, vc_carrera, vc_carrera_nombre, vc_legajo, vc_plan, vc_version, vc_materia, vc_materia_nombre, vdt_fecha,
		vc_resultado, vc_nota, vc_forma_aprob, vc_tipo_acta, vc_acta, vc_acta_promo, vc_nro_resol, 
		vcdescripcion, vcconcepto, suma_totales WITH RESUME;
         
      END FOREACH;

      -- reseteo las variables de carrera.
      LET vc_carrera = NULL;
      LET vc_carrera_nombre = NULL;
      LET vc_legajo = NULL;
      
   END FOREACH;
   
   -- si no tiene materias aprobadas en ninguna carrera, devuelvo solamente los datos personales.
   IF vi_retorno = 0 THEN
      RETURN pUnidadAcademica, pNroInscripcion, vc_apellido, vc_nombres, vc_carrera, vc_carrera_nombre, vc_legajo, vc_plan, vc_version, vc_materia,
	vc_materia_nombre, vdt_fecha, vc_resultado, vc_nota, vc_forma_aprob, vc_tipo_acta, vc_acta, vc_acta_promo, vc_nro_resol, vcdescripcion,
	vcconcepto, suma_totales WITH RESUME;
   END IF;
   
END;

END PROCEDURE;
-- **************************  Fin del Procedure "dba".sp820_FichAlHisAca **************************

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_FichAlHisAca 
-- *****************************************************************************
revoke execute on "dba".sp820_FichAlHisAca from public;
grant execute on "dba".sp820_FichAlHisAca to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_FichAlHisAca to internet; -- Rol de usuario de Internet



-- execute  PROCEDURE "dba".sp820_FichAlHisAca ( "FCJS", "00090830")
