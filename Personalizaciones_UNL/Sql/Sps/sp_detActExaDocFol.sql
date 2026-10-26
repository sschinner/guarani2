CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_detactexadocfol') THEN
		DROP PROCEDURE sp_detactexadocfol;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ***********************************************************************************
-- SIU-GUARANI
-- 
-- Procedure sp_detActExaDocFol
-- Version 2.02.0
-- 
-- Recupera el detalle de un Acta de Examen, para un folio determinado.
-- U820 Se personaliza para mostrar la condición de regularidad según UNL (ej.: PP; EP; etc.)
-- ***********************************************************************************
-- DROP PROCEDURE sp_detActExaDocFol(char, char, char,char);
 CREATE PROCEDURE "dba".sp_detactexadocfol( pUnidadAcademica LIKE sga_actas_examen.unidad_academica,
                                      pTipoActa  LIKE sga_actas_examen.tipo_acta,
                                      pActa  LIKE sga_actas_examen.acta, pFolio LIKE sga_detalle_acta.folio )
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
                 varchar(20),  -- Descripcion Nota
                 varchar(15),  -- Concepto Nota
                 varchar(65),  -- Nombre Alumno
                 varchar(45),  -- Documento Persona
		 varchar(180); -- Nombre del archivo que contiene la foto


DEFINE vcUnidadAcademica  LIKE sga_detalle_acta.unidad_academica;   
DEFINE vcTipoActa         LIKE sga_detalle_acta.tipo_acta;   
DEFINE vcActa             LIKE sga_detalle_acta.acta;   
DEFINE vcCarrera          LIKE sga_detalle_acta.carrera;   
DEFINE vcLegajo           LIKE sga_detalle_acta.legajo;   
DEFINE vcFolio            LIKE sga_detalle_acta.folio;   
DEFINE vcRenglon          LIKE sga_detalle_acta.renglon;   
DEFINE vcTipoInscripcion  varchar(2); --LIKE sga_detalle_acta.tipo_inscripcion;   
DEFINE vcFechadeExamen    LIKE sga_detalle_acta.fecha_de_examen;   
DEFINE vcResultado        LIKE sga_detalle_acta.resultado;   
DEFINE vcNota             LIKE sga_detalle_acta.nota;   
DEFINE vcPlan             LIKE sga_detalle_acta.plan;   
DEFINE vcVersion          LIKE sga_detalle_acta.version;   
DEFINE vcEstadoExamen     LIKE sga_detalle_acta.estado;    
DEFINE vcDescNota         varchar(20);
DEFINE vcConceptoNota     varchar(15);    
DEFINE vcNombrePersona    varchar(65);
DEFINE vcDocumento        varchar(45);
DEFINE auxFechaEx         varchar(10);
DEFINE vcArchivoFoto      varchar(180);

BEGIN

FOREACH EXECUTE PROCEDURE sp_det_ActaExaDoc(pUnidadAcademica, pTipoActa, pActa) 
	INTO vcUnidadAcademica, vcTipoActa, vcActa, vcCarrera, vcLegajo,
	       vcFolio, vcRenglon, vcTipoInscripcion, auxFechaEx, vcResultado,
	       vcNota, vcPlan, vcVersion, vcEstadoExamen, vcDescNota, vcConceptoNota,  vcNombrePersona, vcDocumento, vcArchivoFoto
	IF vcFolio = pFolio THEN       
		RETURN   vcUnidadAcademica, vcTipoActa, vcActa, vcCarrera, vcLegajo, vcFolio, vcRenglon, vcTipoInscripcion, auxFechaEx, vcResultado,
		       vcNota, vcPlan, vcVersion, vcEstadoExamen, vcDescNota, vcConceptoNota,  vcNombrePersona, vcDocumento, vcArchivoFoto WITH RESUME;
        END IF 
END FOREACH;

END;
END PROCEDURE;
-- +++++++++++++++++++++++++++++++++++++++ Fin Proceso sp_detActExaDocFol ++++++++++++++++++++++++++++++++++++++++


-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_detActExaDocFol 
-- *****************************************************************************
revoke execute on "dba".sp_detActExaDocFol from public;
grant execute on "dba".sp_detActExaDocFol to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_detActExaDocFol to internet; -- Rol de usuario de Internet
