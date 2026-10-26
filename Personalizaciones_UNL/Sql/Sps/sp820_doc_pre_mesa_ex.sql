CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp820_doc_pre_mesa_ex') THEN
		DROP PROCEDURE sp820_doc_pre_mesa_ex;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- ***********************************************************************
-- Stored Procedure: sp_doc_rol_mesa_ex
-- Version 2.03.0
--
-- Retorna los docentes de una mesa de examen con su rol.
-- Devuelve los valores de la siguiente forma: Rol=Nombre docente;Rol=Nombre;Rol=Nombre...
-- ***********************************************************************
-- DROP PROCEDURE sp820_doc_pre_mesa_ex;
CREATE PROCEDURE "dba".sp820_doc_pre_mesa_ex( pUnidadAcademica   LIKE sga_llamados_mesa.unidad_academica,
                                   pMateria           LIKE sga_llamados_mesa.materia,
                                   pAnioAcademico     LIKE sga_llamados_mesa.anio_academico,
                                   pTurnoExamen       LIKE sga_llamados_mesa.turno_examen, 
                                   pMesaExamen        LIKE sga_llamados_mesa.mesa_examen,
                                   pLlamado           LIKE sga_llamados_mesa.llamado)

	RETURNING varchar(10);     -- Nro. Inscripcion del presidente de mesa

	DEFINE vNroInscripcion            varchar(10);   

	-- Variables para el manejo de excepciones
	DEFINE SQLErr             integer;
	DEFINE ISAMError          integer;
	DEFINE errorInfo          varchar(76);

	-- Si hay algun error
	ON EXCEPTION SET SQLErr, ISAMError, errorInfo                                        
		RAISE EXCEPTION SQLErr, ISAMError, errorInfo;
	END EXCEPTION;
BEGIN
-- Devuelve los docentes de esta forma: "P=XXXX, YYYY;V=Perez, Juan;S=Miguel, Jose;"
-- Roles:
--	P = Presidente
--	V = Vocal
--	S = Vocal Suplente 

  LET vNroInscripcion = "";

SELECT sga_personas.nro_inscripcion
	 INTO vNroInscripcion 
	 FROM sga_docentes_llama,
	       sga_docentes,
	       sga_personas
	 WHERE sga_docentes.legajo = sga_docentes_llama.legajo
	   AND sga_docentes_llama.unidad_academica = pUnidadAcademica
	   AND sga_docentes_llama.materia = pMateria
	   AND sga_docentes_llama.anio_academico = pAnioAcademico
	   AND sga_docentes_llama.turno_examen = pTurnoExamen
	   AND sga_docentes_llama.mesa_examen = pMesaExamen
	   AND sga_docentes_llama.llamado = pLlamado
	   AND sga_docentes_llama.rol = 'P' 

	   AND sga_docentes.unidad_academica = sga_personas.unidad_academica
	   AND sga_docentes.nro_inscripcion = sga_personas.nro_inscripcion;

  IF vNroInscripcion IS NULL THEN
	LET vNroInscripcion = "";
  END IF;
  RETURN vNroInscripcion;
END;
END PROCEDURE;
-- ************************** Fin Procedure sp820_doc_pre_mesa_ex **************************
-- execute procedure sp820_doc_pre_mesa_ex ('FICH', 'IF004', '2011', 'SEXTO TURNO', 'A', 1);

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp820_doc_pre_mesa_ex 
-- *****************************************************************************
revoke execute on "dba".sp820_doc_pre_mesa_ex from public;
grant execute on "dba".sp820_doc_pre_mesa_ex to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp820_doc_pre_mesa_ex to internet; -- Rol de usuario de Internet
