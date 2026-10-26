CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_det_actaexadoc') THEN
		DROP PROCEDURE sp_det_actaexadoc;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ***********************************************************************************
-- SIU-GUARANI
-- Procedure sp_det_ActaExaDoc
-- Version 2.02.0, 2.08.0
-- Objetivo: Recupera Alumnos de un Acta de Examen para ingresar las notas y el resultado
--	     Usado desde Internet. Solo Actas de Examen Normales abiertas (estado = 'A')
-- 
-- Se renombr� el SP para que su denominaci�n quede uniforme con la de los demas SPs
-- que pertenecen al modulo de gesti�n por Internet de docentes.
-- De sp_det_acta_examen a sp_det_ActaExaDoc
--
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Stored Procedures que devuelven los alumnos de las Actas:
-- sp_det_acta_ex     (Examenes)
-- sp_det_acta_prom   (Promociones)
-- sp_det_acta_reg    (regulares solamente)
-- sp_det_acta_proreg (Promociones y regulares)
-- U820 Se personaliza para mostrar la condici�n de regularidad seg�n UNL (ej.: PP; EP; etc.)
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- DROP PROCEDURE "dba".sp_det_ActaExaDoc(char, char, char);
CREATE PROCEDURE "dba".sp_det_ActaExaDoc( 
   pUnidadAcademica LIKE sga_actas_examen.unidad_academica,
   pTipoActa  LIKE sga_actas_examen.tipo_acta,
   pActa  LIKE sga_actas_examen.acta )
RETURNING varchar(5),   -- Unidad Academica
          char(1),      -- Tipo Acta
          varchar(10),  -- Nro Acta
          varchar(5),   -- Carrera
          varchar(15),  -- Legajo
          INTEGER,      -- folio
          INTEGER,      -- Renglon
          varchar(2),      -- TipoInscripcion
          varchar(10),  -- Fecha deExamen:  dd/mm/yyyy
          varchar(2),   -- Resultado
          varchar(5),   -- Nota	
          varchar(5),   -- Plan
          varchar(5),   -- Version
          char(1),      -- Estado Examen
          varchar(50),  -- Descripcion Nota
          varchar(15),  -- Concepto Nota
          varchar(65),  -- Nombre Alumno
          varchar(45),  -- Documento Persona
          varchar(180);  -- Nombre del Archivo de la foto del alumno


DEFINE vcUnidadAcademica  LIKE sga_detalle_acta.unidad_academica;   
DEFINE vcTipoActa         LIKE sga_detalle_acta.tipo_acta;   
DEFINE vcActa             LIKE sga_detalle_acta.acta;   
DEFINE vcCarrera          LIKE sga_detalle_acta.carrera;   
DEFINE vcLegajo           LIKE sga_detalle_acta.legajo;   
DEFINE vcFolio            LIKE sga_detalle_acta.folio;   
DEFINE vcRenglon          LIKE sga_detalle_acta.renglon;   
--DEFINE vcTipoInscripcion  LIKE sga_detalle_acta.tipo_inscripcion;   
DEFINE vcTipoInscripcion  varchar(2);   
DEFINE vcFechadeExamen    LIKE sga_detalle_acta.fecha_de_examen;   
DEFINE vcResultado        LIKE sga_detalle_acta.resultado;   
DEFINE vcNota             LIKE sga_detalle_acta.nota;   
DEFINE vcPlan             LIKE sga_detalle_acta.plan;   
DEFINE vcVersion          LIKE sga_detalle_acta.version;   
DEFINE vcEstadoExamen     LIKE sga_detalle_acta.estado;    
DEFINE vcDescNota         varchar(50);
DEFINE vcConceptoNota     varchar(15);    
DEFINE vcNombrePersona    varchar(65);
DEFINE vcDocumento        varchar(45);
DEFINE auxFechaEx         varchar(10);
DEFINE vcArchivoFoto      varchar(180);

BEGIN

 FOREACH
    SELECT sga_detalle_acta.unidad_academica,   
           sga_detalle_acta.tipo_acta,   
           sga_detalle_acta.acta,   
           sga_detalle_acta.carrera,   
           sga_detalle_acta.legajo,   
           sga_detalle_acta.folio,   
           sga_detalle_acta.renglon,
		case when sga_equiv_otorgada.alcance = 'P' then 'EP' -- Tiene una equivalencia parcial (de regularidad)
		when u820_sga_det_acta.condicion_reg = 1 then 'L'
		when u820_sga_det_acta.condicion_reg = 2 then 'L'
		when u820_sga_det_acta.condicion_reg = 3 then 'L'
		when u820_sga_det_acta.condicion_reg = 8 then 'L'
		when u820_sga_det_acta.condicion_reg = 4 then 'R'
		when u820_sga_det_acta.condicion_reg = 6 then 'R'
		when u820_sga_det_acta.condicion_reg = 9 then 'R'
		when u820_sga_det_acta.condicion_reg = 5 then 'PP' -- Tiene una promoci�n pendiente
		when u820_sga_det_acta.condicion_reg = 7 then 'PP'
		when u820_sga_det_acta.condicion_reg = 10  then 'TP' else '' end as condicion_reg,   
           -- sga_detalle_acta.tipo_inscripcion,   
           sga_detalle_acta.fecha_de_examen,   
           sga_detalle_acta.resultado,   
           sga_detalle_acta.nota,   
           sga_detalle_acta.plan,   
           sga_detalle_acta.version,   
           sga_detalle_acta.estado estado_examen,    
           '(' || TRIM(sga_det_escala.descripcion) || ')' descripcion_nota,   
           sga_det_escala.concepto     concepto_nota,  
           TRIM(sga_personas.apellido) || ', ' || TRIM(sga_personas.nombres) as nombre_alumno,
           mdp_tipo_documento.desc_abreviada || ' ' || sga_personas.nro_documento as documento,
           sga_personas.id_imagen 
      INTO vcUnidadAcademica,
           vcTipoActa,
           vcActa,
           vcCarrera,
           vcLegajo,
           vcFolio,
           vcRenglon,
           vcTipoInscripcion,
           vcFechadeExamen,
           vcResultado,
           vcNota,
           vcPlan,
           vcVersion,
           vcEstadoExamen,
           vcDescNota,
           vcConceptoNota,
           vcNombrePersona,
           vcDocumento,
           vcArchivoFoto
      FROM sga_actas_examen,
           sga_detalle_acta,sga_alumnos,
           sga_personas,
           mdp_tipo_documento,
           OUTER sga_det_escala,
           OUTER u820_sga_det_acta,
	   OUTER sga_equiv_otorgada
     WHERE sga_actas_examen.unidad_academica = pUnidadAcademica
       AND sga_actas_examen.tipo_acta = pTipoActa
       AND sga_actas_examen.acta = pActa
       AND sga_detalle_acta.unidad_academica = sga_actas_examen.unidad_academica
       AND sga_detalle_acta.tipo_acta = sga_actas_examen.tipo_acta
       AND sga_detalle_acta.acta = sga_actas_examen.acta
       AND sga_alumnos.unidad_academica = sga_detalle_acta.unidad_academica
       AND sga_alumnos.carrera = sga_detalle_acta.carrera
       AND sga_alumnos.legajo  = sga_detalle_acta.legajo
       AND sga_personas.unidad_academica = sga_alumnos.unidad_academica
       AND sga_personas.nro_inscripcion  = sga_alumnos.nro_inscripcion
       AND mdp_tipo_documento.tipo_documento = sga_personas.tipo_documento
       AND sga_det_escala.escala_notas = sga_actas_examen.escala_notas
       AND sga_det_escala.nota         = sga_detalle_acta.nota

       AND u820_sga_det_acta.unidad_academica = sga_detalle_acta.unidad_academica   
       AND u820_sga_det_acta.tipo_acta		= sga_detalle_acta.tipo_acta
       AND u820_sga_det_acta.acta		= sga_detalle_acta.acta
       AND u820_sga_det_acta.carrera		= sga_detalle_acta.carrera 
       AND u820_sga_det_acta.legajo		= sga_detalle_acta.legajo

	AND sga_equiv_otorgada.unidad_academica = sga_detalle_acta.unidad_academica  
        AND sga_equiv_otorgada.carrera = sga_detalle_acta.carrera  
        AND sga_equiv_otorgada.legajo = sga_detalle_acta.legajo  
        AND sga_equiv_otorgada.plan    = sga_detalle_acta.plan  
        AND sga_equiv_otorgada.version = sga_detalle_acta.version
        AND sga_equiv_otorgada.materia = sga_actas_examen.materia
	AND sga_equiv_otorgada.alcance = 'P'
	AND sga_equiv_otorgada.resultado = 'A'
	AND (sga_equiv_otorgada.vencimiento > today OR sga_equiv_otorgada.vencimiento is Null)
	AND sga_equiv_otorgada.estado = 'A'
	AND sga_equiv_otorgada.rectificado = 'N'


  ORDER BY sga_detalle_acta.folio ASC, sga_detalle_acta.renglon ASC

  IF vcFechadeExamen IS NOT NULL THEN
    LET auxFechaEx  = to_char(vcFechadeExamen, "%d/%m/%Y");
  ELSE
    LET auxFechaEx  = '';
  END IF;
        
	-- Devuelvo los registros del Acta.
	RETURN vcUnidadAcademica,
	       vcTipoActa,
	       vcActa,
	       vcCarrera,
	       vcLegajo,
	       vcFolio,
	       vcRenglon,
	       vcTipoInscripcion,
	       auxFechaEx,
	       vcResultado,
	       vcNota,
	       vcPlan,
	       vcVersion,
	       vcEstadoExamen,
	       vcDescNota,
	       vcConceptoNota,
	       vcNombrePersona,
	       vcDocumento,
	       vcArchivoFoto  WITH RESUME;
        
  END FOREACH;

END;
END PROCEDURE;
-- +++++++++++++++++++++++++++++++++++++++ Fin Proceso sp_det_ActaExaDoc ++++++++++++++++++++++++++++++++++++++++


-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_det_ActaExaDoc 
-- *****************************************************************************
revoke execute on "dba".sp_det_ActaExaDoc from public;
grant execute on "dba".sp_det_ActaExaDoc to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_det_ActaExaDoc to internet; -- Rol de usuario de Internet