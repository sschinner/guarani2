-- ==========================================================
-- PROCESO: sp_815_sfechaletra
--
--  DEFINICIÓN de parámetros:
-- 
--	pFecha  = > 'dd-mm-yyyy' Formato Español devuelta por la función f_feha_a_string( fecha DATE)

--	pFORMA =	1) treinta y uno de marzo de mil novecientos noventa y cinco
--			2) a los treinta y un días del mes de marzo del año mil novecientos noventa y cinco
--			3) A los treinta y un días del mes de marzo del año mil novecientos noventa y cinco

-- Universidad Nacional de Gral. Sarmiento
--=======================================================================


CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_815_sfechaletra') THEN
		DROP PROCEDURE sp_815_sfechaletra;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();


-- DROP PROCEDURE sp_815_sfechaletra;
CREATE PROCEDURE sp_815_sfechaletra ( pFecha varchar(10), pForma INT ) 
	returning varchar(255);

DEFINE Retornar varchar(255);

DEFINE vc_Resultado varchar(255);
DEFINE i_anio INT;
DEFINE i_Mes INT;
DEFINE i_Dia INT;

DEFINE i_anio_mil INT;
DEFINE i_anio_cen INT;
DEFINE i_anio_dec INT;
DEFINE i_anio_uni INT;

DEFINE i_dia_uni INT;
DEFINE i_dia_dec INT;

DEFINE vc_aux varchar(255);
DEFINE vc_aux2 varchar(255);
DEFINE date_Erroneo INT; -- para capturar error de fecha inválida.
DEFINE vFecha DATE; -- Fecha Inglesa


	-- Variables para el manejo de excepciones
	DEFINE SQLErr             integer;
	DEFINE ISAMError          integer;
	DEFINE errorInfo          varchar(76);


-- excepciones
ON EXCEPTION SET SQLErr , ISAMError, errorInfo
   RAISE EXCEPTION  sqlErr, isamError, errorinfo;
END EXCEPTION;


Begin

LET vc_AUX='';
LET vc_AUX2='';
LET vc_Resultado = '';


-------============> VALIDACIÓN DE ERRORES B <=====================

IF (NOT(pForma Between 1 and 3)) THEN
	raise exception -746,0,'Error en Parámetro pForma. Sólo valor entre 1 y 3';
END IF

-- Conversión a Date (mm/dd/yyyy)

Let vc_Aux= substr(pFecha,4,2) || '/' || substr(pFecha,1,2) || '/' || substr(pFecha,7,4);


---------- Fecha inválida --------
	-- MES
IF ((substr(pFecha,4,2)<=0)  or (substr(pFecha,4,2) >12)) THEN
	raise exception -746,0, 'Se introdujo una fecha inválida.';	
	--DIA
ELIF ((substr(pFecha,1,2)<=0)  or (substr(pFecha,4,2) >31)) THEN
	raise exception -746,0, 'Se introdujo una fecha inválida.';	
	-- AÑO
ELIF ((substr(pFecha,7,4)<=0)  or (substr(pFecha,7,4) >9999)) THEN
	raise exception -746,0, 'Se introdujo una fecha inválida.';	
END IF



-- SETEO VARIABLE vFECHA Local
LET vFecha=vc_aux; --- seteo fecha.


-- Año menor a 1000
IF YEAR(vFecha) <1000 THEN
	raise exception -746,0,'El Servidor no reconoce años inferiores al mil.';
END IF



LET i_anio = YEAR(vFECHA);
LET i_Mes = MONTH(vfecha);
LET i_Dia = DAY (vfecha);


LET i_Dia_dec = i_dia/10;
LET i_Dia_uni = i_Dia - (i_Dia_Dec*10);

-- Borra la tabla temporal
BEGIN
  -- Si no existía, continúa
  ON EXCEPTION IN  (-206)
  END EXCEPTION WITH RESUME ;
  -- Borra la tabla temporal
  DROP TABLE tmp_815_literal;
END



CREATE TEMP TABLE tmp_815_literal
	(
	unidad int,
	tipo varchar(8),
	nombre varchar(50)
	) ;


insert into tmp_815_literal values(1,'mes',	'Enero');
insert into tmp_815_literal values(2,'mes',	'Febrero');
insert into tmp_815_literal values(3,'mes',	'Marzo');
insert into tmp_815_literal values(4,'mes',	'Abril');
insert into tmp_815_literal values(5,'mes',	'Mayo');
insert into tmp_815_literal values(6,'mes',	'Junio');
insert into tmp_815_literal values(7,'mes',	'Julio');
insert into tmp_815_literal values(8,'mes',	'Agosto');
insert into tmp_815_literal values(9,'mes',	'Septiembre');
insert into tmp_815_literal values(10,'mes','Octubre');
insert into tmp_815_literal values(11,'mes','Noviembre');
insert into tmp_815_literal values(12,'mes','Diciembre');

-- unidad

insert into tmp_815_literal values(0,'unidad','');
insert into tmp_815_literal values(1,'unidad','Uno');
insert into tmp_815_literal values(2,'unidad','Dos');
insert into tmp_815_literal values(3,'unidad','Tres');
insert into tmp_815_literal values(4,'unidad','Cuatro');
insert into tmp_815_literal values(5,'unidad','Cinco');
insert into tmp_815_literal values(6,'unidad','Seis');
insert into tmp_815_literal values(7,'unidad','Siete');
insert into tmp_815_literal values(8,'unidad','Ocho');
insert into tmp_815_literal values(9,'unidad','Nueve');
insert into tmp_815_literal values(10,'unidad','Diez');
insert into tmp_815_literal values(11,'unidad','Once');
insert into tmp_815_literal values(12,'unidad','Doce');
insert into tmp_815_literal values(13,'unidad','Trece');
insert into tmp_815_literal values(14,'unidad','Catorce');
insert into tmp_815_literal values(15,'unidad','Quince');
insert into tmp_815_literal values(16,'unidad','Dieciseis');
insert into tmp_815_literal values(17,'unidad','Diecisiete');
insert into tmp_815_literal values(18,'unidad','Dieciocho');
insert into tmp_815_literal values(19,'unidad','Diecinueve');
insert into tmp_815_literal values(20,'unidad','Veinte');

-- unid_dec

insert into tmp_815_literal values(0,'unid_dec','');
insert into tmp_815_literal values(2,'unid_dec','Veinti');
insert into tmp_815_literal values(3,'unid_dec','Treinta');
insert into tmp_815_literal values(4,'unid_dec','Cuarenta');
insert into tmp_815_literal values(5,'unid_dec','Cincuenta');
insert into tmp_815_literal values(6,'unid_dec','Sesenta');
insert into tmp_815_literal values(7,'unid_dec','Setenta');
insert into tmp_815_literal values(8,'unid_dec','Ochenta');
insert into tmp_815_literal values(9,'unid_dec','Noventa');

-- num_cien

insert into tmp_815_literal values(0,'num_cien','');
insert into tmp_815_literal values(1,'num_cien','Ciento');
insert into tmp_815_literal values(2,'num_cien','Doscientos');
insert into tmp_815_literal values(3,'num_cien','Trescientos');
insert into tmp_815_literal values(4,'num_cien','Cuatrocientos');
insert into tmp_815_literal values(5,'num_cien','Quinientos');
insert into tmp_815_literal values(6,'num_cien','Seiscientos');
insert into tmp_815_literal values(7,'num_cien','Setecientos');
insert into tmp_815_literal values(8,'num_cien','Ochocientos');
insert into tmp_815_literal values(9,'num_cien','Novecientos');

	
LET i_anio_mil = i_anio/1000;
LET i_anio_cen = (i_anio - (i_anio_mil * 1000)) /100;
LET i_anio_dec = (i_anio - (i_anio_mil * 1000) - (i_anio_cen * 100)) /10;
LET i_anio_uni=  (i_anio - (i_anio_mil * 1000) - (i_anio_cen * 100) - (i_anio_dec* 10)) / 1 ;


-- =========>>>>>>>>> COMIENZO <<<<====================

---- DIA
IF i_dia<=20 THEN
	SELECT 	CASE
			WHEN pForma = 1
			THEN DECODE(NOMBRE,'Uno', 'Primero', nombre)
			ELSE  DECODE(NOMBRE,'Uno', 'Primer', nombre)
		END
	INTO	vc_Aux -- >Guardo el Día
	FROM 	tmp_815_literal 
	WHERE UNIDAD = i_dia
	and tipo = 'unidad';

ELSE

	SELECT 	CASE
		WHEN i_dia > 30 and (pForma = 2 or pForma = 3)
		THEN	A.NOMBRE || ' y ' || (DECODE(B.NOMBRE, 'Uno', 'Un',b.nombre)) 	-- x ej. treinta y cuatro ; treinta y un ...
		WHEN i_dia <=30 and (pForma = 2 or pForma = 3)
		THEN	A.NOMBRE || DECODE(B.NOMBRE,'Uno','Un', b.nombre)	-- x ej. ventidos ;  treinta 
		WHEN i_dia > 30 and pForma = 1
		THEN	A.NOMBRE || ' y ' || B.NOMBRE 	-- x ej. treinta y cuatro
		ELSE	A.NOMBRE || B.NOMBRE	-- x ej. ventidos ;  treinta 
	END 	

	INTO 	vc_Aux --> Guardo docena

	FROM	tmp_815_literal A,
		tmp_815_literal B
	WHERE	a.unidad = i_dia_dec
	and	b.unidad = i_dia_uni
	and	a.tipo='unid_dec'
	and	b.tipo='unidad';

	LET vc_Aux  = INITCAP(LOWER(vc_Aux ));

END IF


SELECT 	NOMBRE
INTO 	vc_AUX2 ----==> guardo el mes
FROM 	tmp_815_literal 
WHERE 	unidad= i_MEs
AND	tipo='mes';


------------========= FORMALIDAD SEGUNDO PARÁMETRO =============

IF PFORMA = 1 THEN 			-- Selector de parámetro

	LET vc_aux = vc_Aux  || ' de ' || vc_aux2 || ' de';

ELIF PFORMA=2 THEN

	IF i_DIA = 1 THEN
		LET vc_aux = 'al ' || vc_Aux  || ' día del mes de ' || vc_aux2 || ' del año';
	ELSE
		LET vc_aux = 'a los ' || vc_Aux  || ' días del mes de ' || vc_aux2 || ' del año';
	END IF

ELIF PFORMA=3 THEN ------ Agregado de primera letra en mayúscula (hay funciones en php y power para hacer esto!!!)

	IF i_DIA = 1 THEN
		LET vc_aux = 'Al ' || vc_Aux  || ' día del mes de ' || vc_aux2 || ' del año';
	ELSE
		LET vc_aux = 'A los ' || vc_Aux  || ' días del mes de ' || vc_aux2 || ' del año';
	END IF
ELSE
		
END IF


LET vc_Resultado =  vc_AUX;


------- AVERIGUO EL AÑO --------

IF i_anio_mil = 1 THEN
	LET vc_aux = 'Mil';
ELSE
	SELECT NOMBRE || ' Mil' 	-- concateno el mil
	INTO	vc_aux
	FROM	tmp_815_literal
	WHERE	tipo = 'unidad'
	AND 	unidad = i_anio_mil;

END IF


LET vc_Resultado =  vc_Resultado || ' ' || vc_AUX;

-- ===========> CIENTOS <=============
IF (i_anio_cen = 1) and (i_anio_dec = 0)  and (i_anio_uni = 0) THEN     --x ej. 1100 

	SELECT  	nombre
	INTO	vc_aux
	FROM	tmp_815_literal 	
	WHERE	unidad = 0 --------- para q me de el CIEN y no 'ciento'.
	AND	tipo='num_cien';

ELSE

	SELECT  	nombre
	INTO	vc_aux
	FROM	tmp_815_literal 	
	WHERE	unidad = i_anio_cen  --xxxciento/s
	AND	tipo='num_cien';

END IF

------ asigno Ciento ------
IF i_anio_cen = 0 THEN
	LET vc_Resultado =  vc_Resultado || ' ' || vc_AUX; -- si dejar espacio al final
ELSE
	LET vc_Resultado =  vc_Resultado || ' ' || vc_AUX || ' '; -- con espacio al final
END IF




------- TRABAJO LAS DECENAS DEL AÑO
---- Si los dos ultimos digitos  ((i_anio_dec*10)+i_anio_uni)  son menores e iguales q 20 then 
IF ((i_anio_dec*10)+i_anio_uni)   <=20 THEN
	SELECT 	NOMBRE
	INTO	vc_Aux 
	FROM 	tmp_815_literal 
	WHERE UNIDAD = ((i_anio_dec*10)+i_anio_uni) --x ej. 19; 20
	and tipo = 'unidad';

ELSE     ---x ejemplo  ((%%32))


	SELECT 	CASE
		WHEN 	((i_anio_dec*10)+i_anio_uni)  > 30 
		THEN	A.NOMBRE || ' y ' || B.NOMBRE 	-- x ej. treinta y cuatro
		ELSE	A.NOMBRE || B.NOMBRE	-- x ej. ventidos ;  treinta 
	END

	INTO 	vc_Aux 
	FROM	tmp_815_literal A,
		tmp_815_literal B
	WHERE	a.unidad = i_anio_dec
	and	b.unidad = i_anio_uni
	and	a.tipo='unid_dec'
	and	b.tipo='unidad';

END IF

	LET vc_Resultado = vc_Resultado || '' || vc_aux ;	 ---- catorce x ejemplo


-----=========== >FIN BORRO tmp TABLAS <========
BEGIN
  ON EXCEPTION IN  (-206)
  END EXCEPTION WITH RESUME ;
  DROP TABLE tmp_815_literal;
END

-----=========== > RETORNO vc_Resultado <========
RETURN vc_Resultado ;

End;
END PROCEDURE;
-- +++++++++++++++++++++++++++++++++ Fin Proceso ++++++++++++++++++++++++++++++++++




CREATE PROCEDURE "dba".verifica_objeto()
BEGIN
	IF EXISTS (SELECT procid
			FROM sysprocedures
			WHERE procname = 'sp_815_dfechaletra') THEN
		DROP PROCEDURE sp_815_dfechaletra;
	END IF;		
END
END PROCEDURE;
EXECUTE PROCEDURE "dba".verifica_objeto();
DROP PROCEDURE "dba".verifica_objeto();



-- =======================================================================
-- Proceso: sp_815_dfechaletra
--
-- Recibe:  - Una fecha
--	    - Formato en que se devuelve la fecha..
--
-- Llama internamente al proceso "sp_815_sfechaletra"
-- =======================================================================

-- DROP PROCEDURE sp_815_dfechaletra;
CREATE PROCEDURE sp_815_dfechaletra ( pFecha DATE, pForma INT ) 
	returning varchar(255);

DEFINE vFecha varchar(10);
DEFINE vResultado varchar(255);

-- Variables para el manejo de excepciones
DEFINE SQLErr             integer;
DEFINE ISAMError          integer;
DEFINE errorInfo          varchar(76);

-- excepciones
ON EXCEPTION SET SQLErr , ISAMError, errorInfo
   RAISE EXCEPTION  sqlErr, isamError, errorinfo;
END EXCEPTION;

BEGIN

   LET vFecha = to_char(pFecha, "%d/%m/%Y");	
   EXECUTE PROCEDURE sp_815_sfechaletra	(vFecha, pForma) INTO vResultado;
   Return vResultado;
END
END PROCEDURE;
-- +++++++++++++++++++++++++++++++++ Fin Proceso ++++++++++++++++++++++++++++++++++







-- Verificaciones
execute procedure sp_815_sfechaletra('31/03/2004' ,1 );
execute procedure sp_815_sfechaletra('12/11/1099', 2 );
execute procedure sp_815_sfechaletra('04/02/1995', 2 );
execute procedure sp_815_sfechaletra('31/03/1000',3 );

execute procedure sp_815_dfechaletra('5/12/1099', 2 );
execute procedure sp_815_dfechaletra('4/2/1995', 2 );
execute procedure sp_815_dfechaletra('3/31/1000',3 );
execute procedure sp_815_dfechaletra('4/2/2095', 2 );
execute procedure sp_815_dfechaletra('4/2/2033', 2 );
execute procedure sp_815_dfechaletra('4/2/2008', 2 );