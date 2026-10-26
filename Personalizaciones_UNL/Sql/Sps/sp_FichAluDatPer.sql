CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_fichaludatper') THEN
		DROP PROCEDURE sp_FichAluDatPer;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- *****************************************************************************
-- SIU - SGA - Sistema de Gestion de Alumnos
-- Version 1.7.0
-- Ultima Version de modificación 2.03.0, 2.8.0, 2.9.5
-- Procedure sp_FichAluDatPer
--
-- Modificado version xxx, para que devuelva la fecha de actualización y el último domicilio declarado.
-- 
-- Consulta los datos personales de una persona en la unidad academica.
-- *****************************************************************************

DROP PROCEDURE sp_FichAluDatPer;
CREATE PROCEDURE sp_FichAluDatPer ( pUA LIKE sga_personas.unidad_academica, pNroInscripcion LIKE sga_personas.nro_inscripcion )
       RETURNING 
		varchar(5), varchar(10), varchar(30), varchar(30), varchar(15), date, integer, decimal(15,0), 
		integer, integer, varchar(3), varchar(40), varchar(255), varchar(12), varchar(50), varchar(5), 
		varchar(3), varchar(5), varchar(3), integer, varchar(18), varchar(50), varchar(18), varchar(15), 
		varchar(100), varchar(60), varchar(30), varchar(10), varchar(100), varchar(60), varchar(60), 
		varchar(60), varchar(100), varchar(100), varchar(60), varchar(60), varchar(60);

-- Descripcion del Return:
-- varchar(5),    -- vc_UA
-- varchar(10),   -- vc_NroInscripcion
-- varchar(30),   -- vc_Apellido
-- varchar(30),   -- vc_Nombres
-- varchar(15),   -- vc_NroDocumento
-- date,          -- vd_FechaInscrip
-- integer,       -- vi_AnioIng
-- decimal(15,0), -- vc_NroCi
-- integer,       -- vc_EmisorCi
-- integer,       -- vc_TituloSec
-- varchar(3),    -- vc_TipoDocDesAbre
-- varchar(40),   -- vc_EmisorCiDesc
-- varchar(255),   -- vc_TituloSecDesc
-- varchar(12),   -- vc_fecha_actualiza
-- varchar(50),   -- vc_CallePl
-- varchar(5),    -- vc_NumeroPl
-- varchar(3),    -- vc_PisoPl
-- varchar(5),    -- vc_DptoPl
-- varchar(3),    -- vc_UnidadPl
-- integer,       -- vc_LocalidadPl

-- varchar(18),   -- vc_TelefonoPl
-- varchar(50),  --vc_E_mail
--varchar(18),  --vc_Celular_numero
--varchar(15),  --vc_Celular_compania

-- varchar(100),  -- vc_LocalidadNombre
-- varchar(60);   -- vc_ProvinciaNombre

-- varchar(30) -- nacionalidad
-- varchar(10) -- fecha de nacimiento
-- varchar(100) -- localidad nacimiento
-- varchar(60) -- dpto/partido nacimiento
-- varchar(60) -- provincia nacimiento
-- varchar(60) -- pais nacimiento

-- varchar(100) -- nombre colegio
-- varchar(100) -- localidad colegio
-- varchar(60) -- dpto/partido colegio
-- varchar(60) -- provincia colegio
-- varchar(60) -- pais colegio

-- variables.
DEFINE vc_UA              LIKE sga_personas.unidad_academica;
DEFINE vc_NroInscripcion  LIKE sga_personas.nro_inscripcion;
DEFINE vc_Apellido        LIKE sga_personas.apellido;
DEFINE vc_Nombres         LIKE sga_personas.nombres;
DEFINE vc_NroDocumento    LIKE sga_personas.nro_documento;
DEFINE vd_FechaInscrip    LIKE sga_personas.fecha_inscripcion;
DEFINE vi_AnioIng         INTEGER;
DEFINE vc_NroCi           LIKE sga_personas.nro_ci;
DEFINE vc_EmisorCi        LIKE sga_personas.ent_emisora_ci;
DEFINE vc_TituloSec       LIKE sga_personas.titulo_secundario;
DEFINE vc_TipoDocDesAbre  LIKE mdp_tipo_documento.desc_abreviada;
DEFINE vc_EmisorCiDesc    LIKE sga_entes_emis_ci.descripcion;
DEFINE vc_TituloSecDesc   LIKE sga_titulos_sec.descripcion;
DEFINE vc_fecha, vc_FechaMax   LIKE sga_datos_censales.fecha_relevamiento;

-- DEFINE vc_Periodos        LIKE sga_periodo_insc.periodo_inscripcio;
DEFINE vd_fecha_actualiza        LIKE sga_datos_censales.fecha_actualiz;
DEFINE vc_fecha_actualiza varchar(12);

DEFINE vc_CallePl         LIKE sga_datos_censales.calle_per_lect;
DEFINE vc_NumeroPl        LIKE sga_datos_censales.numero_per_lect;
DEFINE vc_PisoPl          LIKE sga_datos_censales.piso_per_lect;
DEFINE vc_DptoPl          LIKE sga_datos_censales.dpto_per_lect;
DEFINE vc_UnidadPl        LIKE sga_datos_censales.unidad_per_lect;
DEFINE vc_LocalidadPl     LIKE sga_datos_censales.loc_per_lect;

DEFINE vc_TelefonoPl      LIKE sga_datos_censales.te_per_lect;
DEFINE vc_E_mail     LIKE sga_datos_censales.e_mail;
DEFINE vc_Celular_numero LIKE sga_datos_cen_aux.celular_numero;
DEFINE vc_Celular_compania LIKE mdp_celular_comp.nombre;

DEFINE vc_LocalidadNombre LIKE mug_localidades.nombre_abreviado;
DEFINE vc_ProvinciaNombre LIKE mug_provincias.nombre;

DEFINE vc_nac_pers varchar(30);
DEFINE vi_col_sec LIKE sga_personas.colegio_secundario;
DEFINE vi_loc_nacim integer;

DEFINE vc_fecha_nac varchar(10);
DEFINE vc_loc_nacim varchar(100);
DEFINE vc_dpto_nacim varchar(60);
DEFINE vc_prov_nacim varchar(60);
DEFINE vc_pais_nacim varchar(60);

DEFINE vc_nom_coleg varchar(100);
DEFINE vc_loc_coleg varchar(100);
DEFINE vc_dpto_coleg varchar(60);
DEFINE vc_prov_coleg varchar(60);
DEFINE vc_pais_coleg varchar(60);


BEGIN

   -- inicializaciones.
   LET vc_UA              = NULL;
   LET vc_NroInscripcion  = NULL;
   LET vc_Apellido        = NULL;
   LET vc_Nombres         = NULL;
   LET vc_NroDocumento    = NULL;
   LET vd_FechaInscrip    = NULL;
   LET vc_NroCi           = NULL;
   LET vc_EmisorCi        = NULL;
   LET vc_TituloSec       = NULL;
   LET vc_TipoDocDesAbre  = NULL;
   LET vc_EmisorCiDesc    = NULL;
   LET vc_TituloSecDesc   = NULL;
   LET vc_Fecha           = NULL;
   LET vc_FechaMax       = NULL;
   LET vd_fecha_actualiza = NULL;
   LET vc_fecha_actualiza = NULL;
   

   LET vc_CallePl         = NULL;
   LET vc_NumeroPl        = NULL;
   LET vc_PisoPl          = NULL;
   LET vc_DptoPl          = NULL;
   LET vc_UnidadPl        = NULL;
   LET vc_LocalidadPl     = NULL;
   LET vc_TelefonoPl      = NULL;
   
   LET vc_E_mail  = NULL;
   LET vc_Celular_numero   = NULL;
   LET vc_Celular_compania   = NULL;

   LET vc_LocalidadNombre = NULL;
   LET vc_ProvinciaNombre = NULL;
   
   LET vc_nac_pers = NULL;

   LET vc_fecha_nac = NULL;
   LET vc_loc_nacim = NULL;
   LET vc_dpto_nacim = NULL;
   LET vc_prov_nacim = NULL;
   LET vc_pais_nacim = NULL;

   LET vc_nom_coleg = NULL;
   LET vc_loc_coleg = NULL;
   LET vc_dpto_coleg = NULL;
   LET vc_prov_coleg = NULL;
   LET vc_pais_coleg = NULL;

   -- Ultimo dato censal del alumno.
   SELECT MAX(fecha_relevamiento) INTO vc_FechaMax
     FROM sga_datos_censales
    WHERE sga_datos_censales.unidad_academica = vc_UA
      AND sga_datos_censales.nro_inscripcion =  vc_NroInscripcion;
	  
	   -- datos propios de la persona;
   SELECT sga_personas.unidad_academica,
          sga_personas.nro_inscripcion,
          sga_personas.apellido,
          sga_personas.nombres,
          sga_personas.nro_documento,
          sga_personas.fecha_inscripcion,
          sga_personas.nro_ci,
          sga_personas.ent_emisora_ci,
          sga_personas.titulo_secundario,
          mdp_tipo_documento.desc_abreviada,
          sga_personas.colegio_secundario,
          mdp_nacionalidades.descripcion,
          sga_personas.loc_nacimiento,
          to_char(sga_personas.fecha_nacimiento, "%d/%m/%Y")
     INTO vc_UA,
          vc_NroInscripcion,
          vc_Apellido,
          vc_Nombres,
          vc_NroDocumento,
          vd_FechaInscrip,
          vc_NroCi,
          vc_EmisorCi,
          vc_TituloSec,
          vc_TipoDocDesAbre,
          vi_col_sec,
          vc_nac_pers,
          vi_loc_nacim,
          vc_fecha_nac
     FROM sga_personas,
          mdp_tipo_documento,
          mdp_nacionalidades
    WHERE sga_personas.unidad_academica = pUA
      AND sga_personas.nro_inscripcion = pNroInscripcion
      AND mdp_tipo_documento.tipo_documento = sga_personas.tipo_documento
      AND mdp_nacionalidades.nacionalidad = sga_personas.nacionalidad;

   -- datos optativos de la persona;
   SELECT sga_entes_emis_ci.descripcion
     INTO vc_EmisorCiDesc
     FROM sga_entes_emis_ci
    WHERE sga_entes_emis_ci.entidad = vc_EmisorCi;

   -- datos optativos de la persona;
   SELECT sga_titulos_sec.descripcion
     INTO vc_TituloSecDesc
     FROM sga_titulos_sec
    WHERE sga_titulos_sec.titulo_secundario = vc_TituloSec;

   -- ultimo dato censal cargado con algo de domicilio;
   SELECT MAX(sga_datos_censales.fecha_relevamiento)
     INTO vc_fecha
     FROM sga_datos_censales
    WHERE sga_datos_censales.unidad_academica = vc_UA
      AND sga_datos_censales.nro_inscripcion =  vc_NroInscripcion
      AND (sga_datos_censales.calle_per_lect is not null or
          sga_datos_censales.numero_per_lect is not null or
          sga_datos_censales.piso_per_lect is not null or
          sga_datos_censales.dpto_per_lect is not null or
          sga_datos_censales.unidad_per_lect is not null or
          sga_datos_censales.loc_per_lect is not null or
          sga_datos_censales.te_per_lect is not null);

			   
  IF vc_fecha is not null THEN
   -- datos censales respecto de domicilio de procedencia
   SELECT sga_datos_censales.calle_per_lect,
          sga_datos_censales.numero_per_lect,
          sga_datos_censales.piso_per_lect,
          sga_datos_censales.dpto_per_lect,
          sga_datos_censales.unidad_per_lect,
          sga_datos_censales.loc_per_lect,
          sga_datos_censales.te_per_lect,
          -- to_char(sga_datos_censales.fecha_actualiz, "%d/%m/%Y"),
          sga_datos_censales.fecha_actualiz,
          sga_datos_censales.e_mail
     INTO vc_CallePl,
          vc_NumeroPl,
          vc_PisoPl,
          vc_DptoPl,
          vc_UnidadPl,
          vc_LocalidadPl,
          vc_TelefonoPl,
          vd_fecha_actualiza,
          vc_E_mail
     FROM sga_datos_censales
    WHERE sga_datos_censales.unidad_academica = vc_UA
      AND sga_datos_censales.nro_inscripcion = vc_NroInscripcion
      AND sga_datos_censales.fecha_relevamiento = vc_fecha;

	LET vc_fecha_actualiza = day(vd_fecha_actualiza) || '/' || month(vd_fecha_actualiza) || '/' || year(vd_fecha_actualiza);

   -- datos censales (optativos)
   SELECT mug_localidades.nombre_abreviado,  mug_provincias.nombre
     INTO vc_LocalidadNombre, vc_ProvinciaNombre
     FROM mug_localidades,
          mug_dptos_partidos,
          mug_provincias
    WHERE mug_localidades.localidad = vc_LocalidadPl
      AND mug_dptos_partidos.dpto_partido = mug_localidades.dpto_partido
      AND mug_provincias.provincia = mug_dptos_partidos.provincia;

 END IF;  -- Fin datos de domicilio de procedencia

 -- MAIL Y COMPANIA
 IF vc_FechaMax IS NOT NULL THEN  
   SELECT sga_datos_censales.e_mail, sga_datos_cen_aux.celular_numero, mdp_celular_comp.nombre
     INTO vc_E_mail, vc_Celular_numero, vc_Celular_compania
     FROM sga_datos_censales,
	      sga_datos_cen_aux, 
	      OUTER mdp_celular_comp
    WHERE sga_datos_cen_aux.unidad_academica   = vc_UA
      AND sga_datos_cen_aux.nro_inscripcion    = vc_NroInscripcion
      AND sga_datos_cen_aux.fecha_relevamiento = vc_FechaMax
      AND sga_datos_cen_aux.unidad_academica   = sga_datos_cen_aux.unidad_academica
      AND sga_datos_cen_aux.nro_inscripcion    = sga_datos_cen_aux.nro_inscripcion
      AND sga_datos_cen_aux.fecha_relevamiento = sga_datos_cen_aux.fecha_relevamiento
      AND mdp_celular_comp.celular_compania = sga_datos_cen_aux.celular_compania;
  END IF;
 
   
   -- Año de ingreso a la primer carrera.
   SELECT MIN(sga_periodo_insc.anio_academico)
     INTO vi_AnioIng
     FROM sga_carrera_aspira, sga_periodo_insc
    WHERE sga_carrera_aspira.unidad_academica = vc_UA
      AND sga_carrera_aspira.nro_inscripcion = vc_NroInscripcion
      AND sga_carrera_aspira.situacion_asp = 'IL'
      AND sga_carrera_aspira.periodo_inscripcio = sga_periodo_insc.periodo_inscripcio;
   

-- localidad de nacimiento
   select ml.nombre, md.nombre, mpr.nombre, mp.nombre
   INTO vc_loc_nacim, vc_dpto_nacim, vc_prov_nacim, vc_pais_nacim 
   FROM mug_localidades ml,
	mug_dptos_partidos md,
	mug_provincias mpr,
	mug_paises mp
   WHERE ml.localidad = vi_loc_nacim
	AND ml.dpto_partido = md.dpto_partido
	AND md.provincia = mpr.provincia
	AND mpr.pais = mp.pais;


   SELECT scs.nombre, ml.nombre, md.nombre, mpr.nombre, mp.nombre
   INTO vc_nom_coleg, vc_loc_coleg, vc_dpto_coleg, vc_prov_coleg, vc_pais_coleg
   FROM sga_coleg_sec scs,
	mug_localidades ml,
	mug_dptos_partidos md,
	mug_provincias mpr,
	mug_paises mp
   WHERE scs.colegio = vi_col_sec
	AND ml.localidad = scs.localidad
	AND ml.dpto_partido = md.dpto_partido
	AND md.provincia = mpr.provincia
	AND mpr.pais = mp.pais;



   -- devuelvo los datos.
   RETURN vc_UA, vc_NroInscripcion, vc_Apellido, vc_Nombres, vc_NroDocumento, vd_FechaInscrip, vi_AnioIng, vc_NroCi, vc_EmisorCi, vc_TituloSec, vc_TipoDocDesAbre, vc_EmisorCiDesc, vc_TituloSecDesc, vc_fecha_actualiza, vc_CallePl, vc_NumeroPl, vc_PisoPl, vc_DptoPl, vc_UnidadPl, vc_LocalidadPl, vc_TelefonoPl, vc_E_mail, vc_Celular_numero, vc_Celular_compania, vc_LocalidadNombre, vc_ProvinciaNombre, vc_nac_pers, vc_fecha_nac, vc_loc_nacim, vc_dpto_nacim, vc_prov_nacim, vc_pais_nacim, 
vc_nom_coleg, vc_loc_coleg, vc_dpto_coleg, vc_prov_coleg, vc_pais_coleg;


END;
END PROCEDURE;
-- **************************  Fin del Procedure sp_FichAluDatPer **************************

GRANT EXECUTE ON sp_FichAluDatPer TO public;
