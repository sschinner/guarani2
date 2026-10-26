UPDATE mce_formularios SET objeto = 'dl_ted_1a' WHERE entidad = 1 and formulario = 10;
UPDATE mce_formularios SET objeto = 'dl820_fce_ted_1b' WHERE entidad = 1 and formulario = 20;
UPDATE mce_formularios SET objeto = 'dl820_fce_ted_1c' WHERE entidad = 1 and formulario = 30;
UPDATE mce_formularios SET objeto = 'dl820_fce_ted_1d' WHERE entidad = 1 and formulario = 40;
UPDATE mce_formularios SET objeto = 'dl820_fce_ted_1e' WHERE entidad = 1 and formulario = 50;
UPDATE mce_formularios SET objeto = 'dl820_ted_1f' WHERE entidad = 1 and formulario = 60;
UPDATE mce_formularios SET objeto = 'dl_ted_1g' WHERE entidad = 1 and formulario = 70;	
UPDATE mce_formularios SET objeto = 'dl_ted_2_1' WHERE entidad = 1 and formulario = 80;		
UPDATE mce_formularios SET objeto = 'dl820_constancia_inicio_tramite' WHERE entidad = 1 and formulario = 90;
UPDATE mce_formularios SET objeto = 'dl_ted_2_2' WHERE entidad = 1 and formulario = 85;
UPDATE mce_formularios SET objeto = 'dl820_fce_ted_1e' WHERE entidad = 1 and formulario = 100;	
UPDATE mce_formularios SET objeto = 'dl820_diploma_tramite' WHERE entidad = 1 and formulario = 105;
UPDATE mce_formularios SET objeto = 'dl820_certificado_fin_carrera' WHERE entidad = 1 and formulario = 110;
UPDATE mce_formularios SET objeto = 'dl820_ted_1f_2' WHERE entidad = 1 and formulario = 65;
UPDATE mce_formularios SET objeto = 'dl820_fce_ted_1f_3' WHERE entidad = 1 and formulario = 67;
UPDATE mce_formularios SET objeto = 'dl820_certificado_timbrado_titulo' WHERE entidad = 1 and formulario = 820001;	
UPDATE mce_formularios SET objeto = 'dl820_certif_fin_carrera' WHERE entidad = 1 and formulario = 68;
UPDATE mce_formularios SET objeto = 'dl820_recibo_diploma' WHERE entidad = 1 and formulario = 69;

{
INSERT INTO mce_formularios VALUES (
	1,
	10,
	'Seguimiento Interno de Título',
	'Seguimiento Interno de Título',
	'dl_ted_1a',
	'N');

INSERT INTO mce_formularios VALUES (
	1,
	20,
	'Solicitud de Diploma (SUR-D1)',
	'Solicitud de Diploma (SUR-D1)',
	'dl820_fce_ted_1b',
	'S');
	
INSERT INTO mce_formularios VALUES (
	1,
	30,
	'Registro de Graduados (SUR-D22)',
	'Registro de Graudados (SUR-D22)',
	'dl820_fce_ted_1c',
	'S');
	
INSERT INTO mce_formularios VALUES (
	1,
	40,
	'Opción de Juramento',
	'Opción de Juramento',
	'dl820_fce_ted_1d',
	'S');
	
INSERT INTO mce_formularios VALUES (
	1,
	50,
	'Certificado Analítico de Egreso (SUR-D2)',
	'Certificado Analítico de Egreso (SUR-D2)',
	'dl820_fce_ted_1e',
	'N');
	
INSERT INTO mce_formularios VALUES (
	1,
	60,
	'Resolución C.D.',
	'Resolución C.D.',
	'dl820_ted_1f',
	'N');
	
INSERT INTO mce_formularios VALUES (
	1,
	70,
	'Elevar al Sec. Gral. Academ.',
	'Elevar al Sec. Gral. Academ.',
	'dl_ted_1g',
	'N');

INSERT INTO mce_formularios VALUES (
	1,
	80,
	'Seguimiento Externo de Título',
	'Seguimiento Externo de Título',
	'dl_ted_2_1',
	'N');

INSERT INTO mce_formularios VALUES (
	1,
	90,
	'Constancia de Inicio de Trámite',
	'Constancia de Inicio de Trámite',
	'dl820_constancia_inicio_tramite',
	'N');
	
INSERT INTO mce_formularios VALUES (
	1,
	85,
	'Seguimiento Externo de Título (Hoja 2)',
	'Seguimiento Externo de Título (Hoja 2)',
	'dl_ted_2_2',
	'N');
	
INSERT INTO mce_formularios VALUES (
	1,
	100,
	'Certificado Analítico de Egreso (SUR-D2)',
	'Certificado Analítico de Egreso (SUR-D2)',
	'dl820_fce_ted_1e',
	'S');

INSERT INTO mce_formularios VALUES (
	1,
	105,
	'Certificado de Título en Trámite',
	'Certificado de Título en Trámite',
	'dl820_diploma_tramite',
	'S');
	
INSERT INTO mce_formularios VALUES (
	1,
	110,
	'Certificado de Fin de Carrera',
	'Certificado de Fin de Carrera',
	'dl820_certificado_fin_carrera',
	'S');
	
INSERT INTO mce_formularios VALUES (
	1,
	65,
	'Resolución C.D. Fdo.',
	'Resolución C.D. Fdo.',
	'dl820_ted_1f_2',
	'N');
	
INSERT INTO mce_formularios VALUES (
	1,
	67,
	'Despacho C.E e I.R.',
	'Despacho C.E e I.R.',
	'dl820_fce_ted_1f_3',
	'N');
	
INSERT INTO mce_formularios VALUES (
	1,
	820001,
	'Tasa de Expedición de Diploma',
	'Tasa de Expedición de Diploma',
	'dl820_certificado_timbrado_titulo',
	'S');

INSERT INTO mce_formularios VALUES (
	1,
	68,
	'Certificación de Fin de Carrera (SUR-D3)',
	'Certificación de Fin de Carrera (SUR-D3)',
	'dl820_certif_fin_carrera',
	'N');
	
INSERT INTO mce_formularios VALUES (
	1,
	69,
	'Recibo de Diploma',
	'Recibo de Diploma',
	'dl820_recibo_diploma',
	'S');

}