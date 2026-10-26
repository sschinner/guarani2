-- **********************************************************************
-- SP: sp820_inscPas
-- Descripcion: Recupera las Pasantías Activas en las que una Persona esta inscripto.
-- Fecha: 12/05/2005
--
-- Recibe:      - Unidad_academica
--              - nro de Inscripcion
--	
-- Retorna:     - Unidad Academica
--              - Carrera

--              - Pasantia
--              - Nombre Carrera
--              - Nombre Pasantia
-- **********************************************************************

-- Recupera las Inscripciones a Pasantias de un alumno.

DROP procedure sp820_inscpas;
CREATE PROCEDURE sp820_inscpas(pUnidadAcademica LIKE sga_insc_examen.unidad_academica, pNroInscripcion  LIKE sga_personas.nro_inscripcion)
 
RETURNING  varchar(5),                -- unidad academica
           varchar(5),                -- carrera

           integer,                      -- pasantia
           varchar(20),               -- Nombre Carrera Reducido
           varchar(60);               -- Pasantía Detalle

   -- variables utilizadas.
   DEFINE	vcCarNomReducido                    varchar(20);
   DEFINE	vcUnidadAcademica                   LIKE  sga_insc_examen.unidad_academica;
   DEFINE	vcCarrera                           LIKE  sga_insc_examen.carrera;

   DEFINE	viPasantia		LIKE u820_pasantias.id_pasantia;
   DEFINE 	vcPasantiaDetalle		LIKE u820_pasantias.detalle;

BEGIN


   -- recupera las inscripciones a las pasantias
FOREACH
	SELECT dba.u820_insc_pas.unidad_academica,
	       dba.sga_carreras.carrera,
	       dba.u820_insc_pas.id_pasantia,
	       dba.u820_pasantias.detalle,
	       dba.sga_carreras.nombre_reducido

	   INTO vcUnidadAcademica, vcCarrera, viPasantia, vcPasantiaDetalle, vcCarNomReducido

	  FROM dba.u820_insc_pas, 
		dba.sga_personas, 
		dba.sga_carreras, 
		dba.u820_pasantias,
		dba.u820_solicit_pas
       
 WHERE dba.u820_insc_pas.unidad_academica = pUnidadAcademica 
   	AND dba.u820_insc_pas.nro_inscripcion = pNroInscripcion 

	AND dba.u820_pasantias.unidad_academica = dba.u820_insc_pas.unidad_academica
	AND dba.u820_pasantias.id_pasantia = dba.u820_insc_pas.id_pasantia

	AND dba.u820_solicit_pas.unidad_academica = dba.u820_pasantias.unidad_academica
	AND dba.u820_solicit_pas.solicitante = dba.u820_pasantias.solicitante

	AND dba.sga_personas.unidad_academica = dba.u820_insc_pas.unidad_academica
	AND dba.sga_personas.nro_inscripcion = pNroInscripcion

	AND dba.sga_carreras.unidad_academica = dba.u820_insc_pas.unidad_academica
	AND dba.sga_carreras.carrera = dba.u820_insc_pas.carrera
	AND (dba.u820_pasantias.fecha_fin >= TODAY OR dba.u820_pasantias.fecha_tope_bajas >= TODAY)
 ORDER BY dba.sga_carreras.carrera, dba.u820_insc_pas.id_pasantia

     	  -- si no encontro nada, devuelve nulos
     	 RETURN  vcUnidadAcademica, vcCarrera, viPasantia, vcCarNomReducido, vcPasantiaDetalle WITH RESUME;


   END FOREACH ;
END;
END PROCEDURE;
-- **********************************************************************

-- execute procedure sp820_inscpas('FCJS', 'FCJS-6014');
-- select * from u820_insc_pas
-- select * from u820_pasantias order by fecha_fin;
