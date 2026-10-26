CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_datos_tituloegr') THEN
		DROP PROCEDURE sp_datos_tituloegr;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();

-- **************************************************************************
-- Stored Procedure: sp_datos_tituloegr
-- Version 2.5.0
-- Ultima version de modificacion: 
--
-- Recupera los datos del titulo actual y datos de promedios y fecha de egreso a la fecha
-- Calcula el mayor promedio y fecha de egreso con respecto a las orientaciones por las cual el alumno
-- adquirio el titulo. Si egresa por mas de una orientacion, toma el mayor promedio y fecha de egreso.
-- U820 Personalizado para contemplar el calculo del promedio según Resolucion 609/2010
-- **************************************************************************
CREATE PROCEDURE "dba".sp_datos_tituloegr ( pUA like sga_titulos_otorg.unidad_academica, pNroInscripcion like sga_titulos_otorg.nro_inscripcion, pTitulo like sga_titulos_otorg.titulo )

RETURNING 
		varchar (5),		-- Unidad Academica
		varchar (10),		-- Nro. inscripcion
		varchar(5),		-- Codigo de Título
		varchar(255),		-- Nombre del título
		varchar (15),		-- Legajo
		varchar (5),		-- Carrera
		varchar (255),		-- Nombre Carrera
		varchar (5),		-- Plan
		varchar(30),		-- Apellido
		varchar(30),		-- Nombres
		decimal(15,0),		-- Tipo de documento
		varchar(3),		-- Tipo Doc. Descrip.
		varchar(15),		-- Nro. de documento

		varchar (20),		-- Nro. Expediente
		char (1),			-- Estado titulo
		date,			-- fecha de egreso en sol del titulo
		float,			-- Promedio gral
		float,			-- Promedio sin aplazos (academico)

		date,			-- fecha de egreso actual
		float,			-- Promedio gral actual
		float,			-- Promedio sin aplazos actual
		char(1);			-- Si hubo cambios o no en promedios o fecha

-- variables manejo de errores
DEFINE sql_err, isam_err  	int;
DEFINE error_info         	varchar(255);

-- variables locales
DEFINE  vcExpedienteNro     varchar(20);
DEFINE  vcLegajo            varchar(15);
DEFINE  vcCarrera, vcOrientacion           varchar(5);
DEFINE  vcCarreraNombre     varchar(255);
DEFINE  vcPlan, vcVersion, vcPlanVersion              varchar(5);
DEFINE  vcApellido, vcNombre           varchar(30);
DEFINE  iDocTipo		integer; 
DEFINE	iDocNro            decimal(15,0);
DEFINE  vcDocNro             varchar(15);
DEFINE  vcDocTipoDescrip	char(3);
DEFINE  dEgresoFecha, dEgresoFecha_2, dFechaEgresoOrient		DATE;
DEFINE  pFechaEntvig 	datetime year to second;
DEFINE  fPromGral, fPromGral_2, fPromSinAplazos, fPromSinAplazos_2     float;
DEFINE  vcTituloNombre      varchar(255);
DEFINE	vcEstado, vcTieneOrient, vc_hay_cambios	char(1);

DEFINE cPromedioResolucion char(1);

ON EXCEPTION SET sql_err, isam_err, error_info
	  raise exception sql_err, isam_err, 'Error en sp_datos_tituloegr: ' || error_info;
END EXCEPTION;

LET cPromedioResolucion = 'N';

BEGIN
--------------------------------------------------------------
-- Datos del título
--------------------------------------------------------------
 SELECT sga_titulos_otorg.carrera, 
        sga_titulos_otorg.legajo,
        sga_titulos_otorg.nro_expediente,
        sga_titulos_otorg.fecha_egreso,
        sga_titulos_otorg.prom_general,
        sga_titulos_otorg.prom_sin_aplazos,
        sga_titulos_otorg.plan,
        sga_titulos_otorg.estado,
        sga_titulos.nombre
   INTO vcCarrera, 
        vcLegajo,
        vcExpedienteNro,
        dEgresoFecha,
        fPromGral,
        fPromSinAplazos,
        vcPlan,
        vcEstado,
        vcTituloNombre
   FROM sga_titulos_otorg, sga_titulos
  WHERE sga_titulos_otorg.unidad_academica = pUA 
    AND sga_titulos_otorg.nro_inscripcion = pNroInscripcion 
    AND sga_titulos_otorg.titulo = pTitulo
    AND sga_titulos.unidad_academica = sga_titulos_otorg.unidad_academica
    AND sga_titulos.titulo = sga_titulos_otorg.titulo ;


IF fPromGral IS NULL THEN
  LET fPromGral = 0;
END IF;
IF fPromSinAplazos IS NULL THEN
  LET fPromSinAplazos = 0;
END IF;

--------------------------------------------------------------
-- Descripcion del Plan y Carrera
--------------------------------------------------------------
 SELECT sga_planes.version_actual, sga_carreras.nombre
   INTO  vcPlanVersion, vcCarreraNombre
   FROM sga_planes, sga_carreras
  WHERE sga_planes.unidad_academica = pUA
    AND sga_planes.carrera = vcCarrera
    AND sga_planes.plan = vcPlan 
   AND sga_carreras.unidad_academica = sga_planes.unidad_academica
    AND sga_carreras.carrera = sga_planes.carrera;


--------------------------------------------------------------
-- Datos de la persona
--------------------------------------------------------------
 SELECT sga_personas.apellido,
        sga_personas.nombres,
        sga_personas.tipo_documento,
        sga_personas.nro_documento,
        mdp_tipo_documento.desc_abreviada
   INTO vcApellido,
        vcNombre,
        iDocTipo,
        iDocNro,
       vcDocTipoDescrip
   FROM sga_personas,
	mdp_tipo_documento	
  WHERE sga_personas.unidad_academica = pUA
    AND sga_personas.nro_inscripcion = pNroInscripcion 
    AND mdp_tipo_documento.tipo_documento = sga_personas.tipo_documento;

LET vcDocNro = iDocNro;  -- Convierto a string

-- ++++++++++++++++++++++++++++++++++++++++++++
-- Recupero la version del plan en la fecha de egreso.
-- ++++++++++++++++++++++++++++++++++++++++++++
LET pFechaEntvig = NULL;
SELECT max(fecha_ent_vigencia) INTO pFechaEntvig
	FROM sga_versiones_plan
	WHERE unidad_academica = pUA
	AND carrera = vcCarrera
	AND plan = vcPlan
	AND DATE(fecha_ent_vigencia) <= dEgresoFecha;

IF pFechaEntvig IS NULL THEN
	-- raise exception -746,0,'Error al recuperar la version del plan del alumno en la fecha de egreso: ' || to_char(dEgresoFecha, "%d/%m/%Y");

	-- Recupero la version actual del plan
	SELECT version_actual INTO vcVersion
		FROM sga_planes
		WHERE unidad_academica = pUA
		AND carrera = vcCarrera
		AND plan = vcPlan;
ELSE
	-- Version a la fecha de entrada en vigencia
	SELECT version INTO vcVersion
	FROM sga_versiones_plan
	WHERE unidad_academica = pUA
	AND carrera = vcCarrera
	AND plan = vcPlan
	AND fecha_ent_vigencia = pFechaEntvig;

END IF;

		
--------------------------------------------------------------
-- Vuelvo a calcular promedios y fecha de egreso
--------------------------------------------------------------
-- U820 ***********************************************************************************************
-- Personalizado para contemplar el calculo del promedio según Resolucion 609/2010
-- U820 ***********************************************************************************************

EXECUTE PROCEDURE sp820_prom_alu_res (pUA, vcCarrera, vcLegajo, 'S')  INTO fPromGral_2, cPromedioResolucion;
EXECUTE PROCEDURE sp820_prom_alu_res (pUA, vcCarrera, vcLegajo, 'N') INTO fPromSinAplazos_2, cPromedioResolucion ;

-- U820 ***********************************************************************************************
-- Personalizado para contemplar el calculo del promedio según Resolucion 609/2010
-- U820 ***********************************************************************************************

-- Recorro las orientaciones por las que aprobo el titulo final y calculo la maxima fecha de egreso.
LET dEgresoFecha_2 = to_date('01011900','%d%m%Y'); 
LET vcTieneOrient = 'N';
FOREACH SELECT orientacion 
	INTO vcOrientacion
	FROM sga_orie_tit_otorg
	WHERE	 unidad_academica = pUA
	AND nro_inscripcion = pNroInscripcion
	AND titulo     =  pTitulo
	AND carrera = vcCarrera
	AND plan     = vcPlan

	-- Recupero fecha de egreso de la Orientacion
	EXECUTE PROCEDURE sp_fecha_egreso(pUA, vcCarrera, vcLegajo, pTitulo, vcPlan, vcVersion, vcOrientacion) INTO dFechaEgresoOrient ;

	LET vcTieneOrient = 'S';
	--La fecha de egreso es la menos de todas las orientaciones
	 IF dFechaEgresoOrient > dEgresoFecha_2 THEN
		 LET dEgresoFecha_2 = dFechaEgresoOrient;
	END IF;
END FOREACH;

IF vcTieneOrient = 'N' THEN 
	LET vcOrientacion = '0'; -- Orientacion básica
	EXECUTE PROCEDURE sp_fecha_egreso(pUA, vcCarrera, vcLegajo, pTitulo, vcPlan, vcVersion, vcOrientacion) INTO dEgresoFecha_2;
END IF;

-- Redondeo a tres decimales.
LET fPromGral     = Round( fPromGral , 3);
LET fPromGral_2 = Round( fPromGral_2 , 3);
LET fPromSinAplazos = Round( fPromSinAplazos , 3);
LET fPromSinAplazos_2 = Round( fPromSinAplazos_2 , 3);

IF dEgresoFecha <> dEgresoFecha_2  OR fPromGral <> fPromGral_2  OR fPromSinAplazos <> fPromSinAplazos_2 THEN
	LET vc_hay_cambios = 'S';
ELSE
	LET vc_hay_cambios = 'N';
END IF;

-- Retorono los datos de la solicitud de titulo y nuevos promedios y fecha de egreso
RETURN pUA, pNroInscripcion , pTitulo, vcTituloNombre,vcLegajo,vcCarrera,vcCarreraNombre, vcPlan,
	vcApellido, vcNombre, iDocTipo, vcDocTipoDescrip, vcDocNro, 
	vcExpedienteNro, vcEstado, dEgresoFecha, fPromGral, fPromSinAplazos, dEgresoFecha_2, fPromGral_2, fPromSinAplazos_2, vc_hay_cambios ;

END;
END PROCEDURE;
-- ************************** FIN DEL PROCEDURE sp_datos_tituloegr **************************

-- execute procedure sp_datos_tituloegr ('FBCB', '2221', '1');

-- *****************************************************************************
-- Permisos del procedimiento "dba".sp_datos_tituloegr
-- *****************************************************************************
revoke execute on "dba".sp_datos_tituloegr from public;
grant execute on "dba".sp_datos_tituloegr to guarani; -- Rol de usuarios de Gestion
grant execute on "dba".sp_datos_tituloegr to internet; -- Rol de usuario de Internet