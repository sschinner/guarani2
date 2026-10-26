<?php
namespace siu\conf;
use kernel\util\validador;
use kernel\kernel;
use siu\conf\datos_comunes;

use siu\modelo\datos\catalogo;

class definicion_datos_censales
{
	const filtro = 'filtro';
	const filtro_params = 'filtro_params';
	const largo = 'largo';
	const obligatorio = 'obligatorio';
	const label = 'label';
	const clase_css = 'clase_css';
	const elemento = 'elemento_html';
	const sub_form = 'subform';
	const multiOptions = 'multiOptions';
	const nombre = 'nombre';
	const format = 'format';

	static protected $definicion_tabla;

    static protected $def = array (

		// --------------------   SUB_FORM PRINCIPALES---------------------------------

//		'CENS_E_MAIL' => array(	self::filtro => validador::TIPO_MAIL,
//								self::obligatorio => true,
//								self::clase_css => 'editable',
//								self::elemento => array('nombre' => 'text'),
//								self::sub_form => 'principales',
//								),

//		'AUX1_BARRIO_PER_LEC' => array(	self::filtro => validador::TIPO_TEXTO,
//										self::obligatorio => TRUE,
//										self::clase_css => 'editable',
//										self::elemento => array('nombre' => 'text'),
//										self::sub_form => 'principales',
//
//									),
		'CENS_CALLE_PER_LECT' => array(	self::filtro => validador::TIPO_TEXTO,
										self::obligatorio => true,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales',

									),
		'CENS_NUMERO_PER_LECT' => array(    self::filtro => validador::TIPO_TEXTO,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'principales',
										),

		'CENS_PISO_PER_LECT' => array(	self::filtro => validador::TIPO_ALPHANUM,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales',
									),

		'CENS_DPTO_PER_LECT' => array(	self::filtro => validador::TIPO_ALPHANUM,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales',
									),

		'CENS_UNIDAD_PER_LECT' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'principales',
									),

		'CENS_LOC_PER_LECT_TEXTO' => array (self::obligatorio => true,
											self::elemento => array('nombre' => 'text',
																	'readonly' => true),
											self::sub_form => 'principales',
											),
		'CENS_LOC_PER_LECT'		=> array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'hidden'),
											self::sub_form => 'principales'
										),
		'CENS_CP_PER_LECT' => array(	self::filtro => validador::TIPO_INT,
										self::obligatorio => true,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text',  
																'readonly' => true),
										self::sub_form => 'principales'
									),
		'CENS_TE_PER_LECT' => array(	self::filtro => validador::TIPO_CUSTOM,
										self::obligatorio => true,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales',
										self::format => '^[0-9\s\(\)\-]{0,18}'),

		'AUX1_CELULAR_NUMERO' => array(	self::filtro => validador::TIPO_CUSTOM,
										self::obligatorio => true,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales',
										self::format => '^[0-9\s\(\)\-]{0,18}'),

		'AUX1_CELULAR_COMPANIA' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'principales'),

		'AUX2_ALU_OBRA_SOCIAL' => array(self::filtro => validador::TIPO_INT,
										self::obligatorio => true,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'select'),
										self::sub_form => 'principales'),

		'CENS_ESTADO_CIVIL' => array(	self::filtro => validador::TIPO_INT,
										self::obligatorio => true,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'select'),
										self::sub_form => 'principales'),

		'AUX1_CANT_HIJOS_ALUM' => array(self::filtro => validador::TIPO_INT,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'select'),
										self::sub_form => 'principales'),

		'AUX1_CANT_FAMI_CARGO' => array(self::filtro => validador::TIPO_INT,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'select'),
										self::sub_form => 'principales'),

		'AUX2_ALU_EST_CIVIL_UH' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'principales'),

		'CENS_TIPO_RESIDENCIA' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => true,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'principales'),

		'AUX1_VIVE_ACTUAL_CON' => array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => true,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'principales'),

		'CENS_CALLE_PROC' => array(	self::filtro => validador::TIPO_TEXTO,
									self::obligatorio => true,
									self::clase_css => 'editable',
									self::elemento => array('nombre' => 'text'),
									self::sub_form => 'principales'),

		'CENS_NUMERO_PROC' => array(	self::filtro => validador::TIPO_TEXTO,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales'),

		'CENS_PISO_PROC' => array(	self::filtro => validador::TIPO_ALPHANUM,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales'),

		'CENS_DPTO_PROC' => array(	self::filtro => validador::TIPO_ALPHANUM,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales'),

		'CENS_UNIDAD_PROC' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'principales'),
                //  agregar require a la clase css  
		'CENS_LOC_PROC_TEXTO' => array (self::obligatorio => true,
										self::elemento => array('nombre' => 'text',
																'readonly' => true),
										self::sub_form => 'principales'),
		'CENS_LOC_PROC'		=> array(	self::filtro => validador::TIPO_INT,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'hidden'),
										self::sub_form => 'principales'),
		'CENS_CP_PROC' => array(	self::filtro => validador::TIPO_INT,
									self::obligatorio => true,
									self::clase_css => 'editable',
									self::elemento => array('nombre' => 'text',
															'readonly' => true),
									self::sub_form => 'principales'),
		'CENS_TE_PROC' => array(		self::filtro => validador::TIPO_CUSTOM,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales',
										self::format => '^[0-9\s\(\)\-]{0,18}'),

		'CENS_NOMBRE_PERS_ALLEG' => array(	self::filtro => validador::TIPO_TEXTO,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'principales'),

		'CENS_CALLE_PERS_ALLEG' => array(	self::filtro => validador::TIPO_TEXTO,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'principales',
									),

		'CENS_NRO_PERS_ALLEG' => array(		self::filtro => validador::TIPO_TEXTO,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'principales'),

		'CENS_PISO_PERS_ALLEG' => array(	self::filtro => validador::TIPO_ALPHANUM,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales',
									),
		'CENS_DPTO_PERS_ALLEG' => array(	self::filtro => validador::TIPO_ALPHANUM,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'principales',
									),
		'CENS_UNIDAD_PERS_ALLEG' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'principales',
									),
		
		'CENS_LOC_PERS_ALLEG_TEXTO' => array (	self::obligatorio => false,
												self::elemento => array('nombre' => 'text',
																		'readonly' => true),
												self::sub_form => 'principales',
											),
		'CENS_LOC_PERS_ALLEG'		=> array(	self::filtro => validador::TIPO_INT,
												self::obligatorio => false,
												self::clase_css => 'editable',
												self::elemento => array('nombre' => 'hidden'),
												self::sub_form => 'principales'
										),
		'CENS_CP_PERS_ALLEG' => array(		self::filtro => validador::TIPO_INT,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text',  
																	'readonly' => true),
											self::sub_form => 'principales'
									),
		'CENS_TE_PERS_ALLEG' => array(		self::filtro => validador::TIPO_CUSTOM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'principales',
											self::format => '^[0-9\s\(\)\-]{0,18}'),

		// --------------------   SUB_FORM FINANCIAMIENTO -----------------------------
		'AUX2_ALU_COS_EST_AP_FAM' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),

		'AUX2_ALU_COS_EST_PLSOC' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX2_ALU_COS_EST_TRAB' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX2_ALU_COS_EST_BECA' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX1_TIENE_BECA_UNIV' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX1_TIENE_BECA_INTER' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX1_TIENE_BECA_NACIO' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX2_ALU_BECA_PROV' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX2_ALU_BECA_MUNI' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX2_ALU_BECA_OTRA' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX2_ALU_BECA_TIPO_SER' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX2_ALU_BECA_TIPO_INV' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX2_ALU_BECA_TIPO_ECO' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX2_ALU_BECA_ECO_TRAN' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX2_ALU_BECA_ECO_EFEC' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX2_ALU_BECA_ECO_FOTO' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		
		'AUX2_ALU_BECA_ECO_HABI' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		'AUX2_ALU_BECA_ECO_COME' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'financiamiento'
										 ),
		
		'AUX2_ALU_COS_EST_ESPEC' => array(	self::filtro => validador::TIPO_TEXTO,
				                            self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'financiamiento',
										),

		// --------------------   SUB_FORM SITUACION LABORAL  ----------------------------------
		'AUX1_EXISTE_TRAB_ALUM'  => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => true,
											self::clase_css => 'editable',
											self::elemento => array(self::nombre		=> 'select'),
											self::sub_form => 'trabajo'
										),
		'AUX2_ALU_TRAB_HACE' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array(self::nombre		=> 'select'),
											self::sub_form => 'trabajo'
										),
		'AUX2_ALU_TRAB_OCUP' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array(self::nombre		=> 'select'),
											self::sub_form => 'trabajo'
										),
		'CENS_HORA_SEM_TRAB_ALUM' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array(self::nombre		=> 'select'),
											self::sub_form => 'trabajo'
										),
		'CENS_REL_TRAB_CARRERA' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array(self::nombre		=> 'select'),
											self::sub_form => 'trabajo'
										),
		'AUX2_ALU_TRAB_TAREA' => array(		self::filtro => validador::TIPO_TEXTO,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'trabajo',
										),
		'AUX2_ALU_TRAB_DESJUB' => array(self::filtro => validador::TIPO_ALPHANUM,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array(self::nombre		=> 'select'),
										self::sub_form => 'trabajo',
										),
		'AUX2_ALU_TRAB_FAMI' => array(	self::filtro => validador::TIPO_ALPHANUM,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array(self::nombre		=> 'select'),
										self::sub_form => 'trabajo',
									),
		'AUX1_REMUNERACION' => array(	self::filtro => validador::TIPO_ALPHANUM,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array(self::nombre		=> 'select'),
										self::sub_form => 'trabajo',
									),
		'CENS_EMPRESA' => array(	self::filtro => validador::TIPO_ALPHANUM,
									self::obligatorio => false,
									self::clase_css => 'editable',
									self::elemento => array(self::nombre		=> 'select'),
									self::sub_form => 'trabajo'
								),
		'CENS_EMPRESA_OTRA' => array(	self::filtro => validador::TIPO_TEXTO,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'trabajo',
									),
		'CENS_SECTOR' => array(		self::filtro => validador::TIPO_ALPHANUM,
									self::obligatorio => false,
									self::clase_css => 'editable',
									self::elemento => array(self::nombre		=> 'select'),
									self::sub_form => 'trabajo'
								),
		'CENS_SUBSECTOR' => array(	self::filtro => validador::TIPO_ALPHANUM,
									self::obligatorio => false,
									self::clase_css => 'editable',
									self::elemento => array(self::nombre		=> 'select'),
									self::sub_form => 'trabajo'
									),
		'CENS_FACILIDAD_EST_EMP' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array(self::nombre		=> 'select'),
											self::sub_form => 'trabajo'
										),
		'CENS_FACILIDAD_EST_INST' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array(self::nombre		=> 'select'),
											self::sub_form => 'trabajo'
										),
		'CENS_ANTIGUEDAD' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array(self::nombre		=> 'select'),
											self::sub_form => 'trabajo'
										),
		/*	NUEVOS CAMPOS
			Antigüedad (sga_datos_censales.antiguedad)
			En ese trabajo es usted (sga_datos_cen_aux2.alu_trab_hace)
		 */
		
		// --------------------   SUB_FORM PADRES  ----------------------------------
		
		 'AUX1_PADRE_VIVE' => array(	self::filtro => validador::TIPO_ALPHANUM,
										self::obligatorio => true,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'radio'),
										self::sub_form => 'padres'
										),
		
		'CENS_ULT_EST_CUR_PADRE' => array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => true,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'padres'
										),
		
		'CENS_SIT_LABORAL_PADRE' => array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'padres'
										),
		
		'AUX2_PADRE_TRAB_HACE' => array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'padres'
										),
		
		'AUX2_PADRE_TRAB_OCUP' => array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'padres'
										),
		
		 'AUX2_PADRE_TRAB_TAREA' => array(	self::filtro => validador::TIPO_TEXTO,
											self::obligatorio => false,
 											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'padres'
											 ),
		'AUX2_PADRE_TRAB_OTRO'	=> array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'padres'
										),
		'AUX1_MADRE_VIVE' => array(	self::filtro => validador::TIPO_ALPHANUM,
										self::obligatorio => true,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'radio'),
										self::sub_form => 'padres'
										),
		'CENS_ULT_EST_CUR_MADRE' => array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => true,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'padres'
										),
		'CENS_SIT_LABORAL_MADRE' => array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'padres'
										),
		
		'AUX2_MADRE_TRAB_HACE' => array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'padres'
										),
		'AUX2_MADRE_TRAB_OCUP' => array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'padres'
										),
		 'AUX2_MADRE_TRAB_TAREA' => array(	self::filtro => validador::TIPO_TEXTO,
											self::obligatorio => false,
 											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'padres'
											 ),
		'AUX2_MADRE_TRAB_OTRO'	=> array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'select'),
											self::sub_form => 'padres'
										),

		// --------------------   SUB_FORM ESTUDIOS  ----------------------------------
		'AUX2_ALU_OTESTSUP_UNI' => array(	self::filtro => validador::TIPO_TEXTO,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'text'),
											self::sub_form => 'estudios'
										),
		'AUX2_ALU_OTESTSUP_TIPO' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array(self::nombre		=> 'select'),
											self::sub_form => 'estudios'
										),
		'AUX2_ALU_OTESTSUP_CARR' => array(	self::filtro => validador::TIPO_TEXTO,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array(self::nombre		=> 'text'),
											self::sub_form => 'estudios'
										),
		
		'AUX2_ALU_OTESTSUP_AREA' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::elemento => array(self::nombre		=> 'select'),
											self::sub_form => 'estudios'
			
										),
		'AUX2_ALU_OTESTSUP_NIV' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::elemento => array(self::nombre		=> 'select'),
											self::sub_form => 'estudios'
											
										),
		
		'AUX2_ALU_OTESTSUP_ESTA' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::elemento => array(self::nombre	=> 'select'),
											self::sub_form => 'estudios'
										),
		
		'AUX2_ALU_OTESTSUP_EGRE' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::elemento => array(self::nombre	=> 'select'),
											self::sub_form => 'estudios'
										),
		
		// --------------------   SUB_FORM TECNOLOGIA -----------------------------
		
		'AUX2_ALU_TEC_PC_CASA' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),
	
		
		'AUX2_ALU_TEC_PC_TRAB' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),

		'AUX2_ALU_TEC_PC_UNIV' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),

		'AUX2_ALU_TEC_PC_OTRO' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),
		
		 'AUX2_ALU_TEC_INT_REGUL' => array(	self::filtro => validador::TIPO_INT,
											self::obligatorio => false,
											self::clase_css => 'editable',			
											self::elemento => array('nombre' => 'select'),			 
											self::sub_form => 'tecnologia'),
		
		'AUX2_ALU_TEC_INT_CASA' => array(	self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),
		
		'AUX2_ALU_TEC_INT_TRAB' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),
		
		'AUX2_ALU_TEC_INT_UNIV' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),
		
		'AUX2_ALU_TEC_INT_CYBER' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),
		
		'AUX2_ALU_TEC_INT_OTRO' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),
		
		'AUX2_ALU_TEC_USINT_CAP' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),
		
		'AUX2_ALU_TEC_USINT_EST' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),
		
		'AUX2_ALU_TEC_USINT_PER' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),
		
		'AUX2_ALU_TEC_USINT_MAI' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),
		
		'AUX2_ALU_TEC_USINT_CHA' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'tecnologia'),
		
		// --------------------   SUB_FORM DEPORTES -----------------------------
		
		
		
		
		'AUX1_PRACTICA_DEPORTES' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'deporte'),
		
		'AUX1_HACE_DEP_GIM_PRIV' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'deporte'),
		
		
		'AUX1_HACE_DEP_UNIV' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'deporte'),
		
		'AUX1_HACE_DEP_PARTIC' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'deporte'),
		
		'AUX1_HACE_DEP_OTROS' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'deporte'),
		
		'AUX1_PRAC_DEP_BASQUET' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'deporte'),
		
		'AUX1_PRAC_DEP_NATACION' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'deporte'),
		
		'AUX1_PRAC_DEP_FUTBOL' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'deporte'),
		
		'AUX1_PRAC_DEP_GIMNASIA' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'deporte'),
		
		'AUX1_PRAC_DEP_TENIS' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'deporte'),
		
		'AUX1_PRAC_DEP_HANDBALL' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'deporte'),
		
		'AUX1_PRAC_DEP_VOLEY' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'deporte'),
		
		'AUX1_PRAC_DEP_OTROS' => array(   self::filtro => validador::TIPO_ALPHANUM,
											self::obligatorio => false,
											self::clase_css => 'editable',
											self::elemento => array('nombre' => 'checkbox'),
											self::sub_form => 'deporte'),
		
		
		
		// --------------------   SUB_FORM IDIOMAS -----------------------------
			
		'AUX2_ALU_IDIOMA_INGL' => array(self::filtro => validador::TIPO_INT,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'radio'),
										self::sub_form => 'idioma'
										),
		'AUX2_ALU_IDIOMA_FRAN' => array(self::filtro => validador::TIPO_INT,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'radio'),
										self::sub_form => 'idioma'
										),
		'AUX2_ALU_IDIOMA_PORT' => array(self::filtro => validador::TIPO_INT,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'radio'),
										self::sub_form => 'idioma'
										),
		'AUX2_ALU_IDIOMA_ITAL' => array(self::filtro => validador::TIPO_INT,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'radio'),
										self::sub_form => 'idioma'
										),
		'AUX2_ALU_IDIOMA_ALEM' => array(self::filtro => validador::TIPO_INT,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'radio'),
										self::sub_form => 'idioma'
										),
		'AUX2_ALU_IDIOMA_OTRO' => array(self::filtro => validador::TIPO_TEXTO,
										self::obligatorio => false,
										self::clase_css => 'editable',
										self::elemento => array('nombre' => 'text'),
										self::sub_form => 'idioma'
										),
		
		);
		
	static function hay_campo($campo)
	{
		return isset(self::$def[$campo]);
	}
	
	static function es_campo_a_validar($campo)
	{
		if (isset(self::$def[$campo]) && isset(self::$def[$campo][self::filtro])) {
			return true;
		}
		return false;
	}
	
    static function get_campo($campo)
    {
		if (!isset(self::$definicion_tabla) || empty(self::$definicion_tabla)) {
			self::$definicion_tabla = catalogo::consultar('datos_censales', 'get_definicion_campos', array()); 
		}
        if (isset(self::$def[$campo])) {
			$def_campo = self::$def[$campo];
			// se obtiene el largo del campo y lo seteo para limitar los input
			foreach (self::$definicion_tabla as $definicion) {
				if (strtoupper($definicion['COLNAME']) == substr($campo,5)) {
					if ( $definicion['COLTYPE'] == 2) {
						// 2 es el tipo entero pero la definicion de informix pone 'COLLENGTH' = 4
						$def_campo['largo'] = 6;
					} else {
						$def_campo['largo'] = $definicion['COLLENGTH'];
					}
				}
			}
            return $def_campo;
        }
		throw new \siu\errores\error_guarani("DEFINICION DATOS CENSALES: campo '$campo' no está definido");
	}
	
	static function get_campos($sub_formulario) 
	{
		$retorno = array();
		foreach(self::$def as $campo_nombre => $campo) {
			if($campo[self::sub_form] == $sub_formulario) {
				$retorno[] = $campo_nombre;
			}
			
		}
		return $retorno;
	}
	
	static function get_def()
	{
		return static::$def;
	}
	
}
