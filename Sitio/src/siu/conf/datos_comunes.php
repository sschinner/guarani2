<?php

namespace siu\conf;
use kernel\util\validador;
use siu\modelo\datos\catalogo;
use siu\operaciones\_comun\util\forms;
use siu\guarani;
//validador::TIPO_ALPHANUM
class datos_comunes
{
	static private function anios_egreso() 
	{
		$ano_actual = date('Y');
		$anos_egreso_ini = $ano_actual - 60;
		$anos_egreso = array("-");
		for($i = $anos_egreso_ini; $i <= $ano_actual; $i++){
			$anos_egreso[$i] = $i;
		}
		return $anos_egreso;
	}

	static protected $def = array (
		'AUX2_ALU_OTESTSUP_TIPO' => array(
											'' => '-',
											'1' => 'Pública',
											'2' => 'Privada'
										),
		'AUX2_ALU_OTESTSUP_AREA' => array(
											'' =>  '-',
											'1' => 'Educación',
											'2' => 'Ciencias Básicas',
											'3' => 'Ciencias Aplicadas',
											'4' => 'Ciencias Sociales',
											'5' => 'Ciencias Jurídicas',
											'6' => 'Ciencias Humanas',
											'7' => 'Ciencias de la Salud',
											'8' => 'Sin especificación'
										),
		'AUX2_ALU_OTESTSUP_NIV' =>  array(
											'' => '-',
											'1' => 'Universitario',
											'2' => 'Superior no universitario'
									),
		'AUX2_ALU_OTESTSUP_ESTA' => array(
											'' => '-',
											'1' => 'Terminó',
											'2' => 'Abandonó',
											'3' => 'Continúa'
										),
		'AUX2_ALU_OBRA_SOCIAL' => array(
										''   => '-',
										'1'  => 'Por ser familiar a cargo (de padre, madre, cónyuge o tutor)',
										'2'  => 'Por su propio trabajo',
										'3'  => 'Como afiliado voluntario (a obra social o prepaga)' ,
										'4'  => 'Otorgada por la universidad (por ser estudiante)',
										'5'  => 'Carece de cobertura de salud',
									),
		'CENS_ESTADO_CIVIL' => array(
									''   => '-',
									'1'  => 'Soltero',
									'2'  => 'Casado' ,
									'3'  => 'Separado',
									'4'  => 'Divorciado',
									'6'  => 'Viudo',
									),
		'CENS_TIPO_RESIDENCIA' => array(
										''   => '-',
										'1'  => 'Casa',
										'2'  => 'Departamento' ,
										'3'  => 'Pensiones o residencias',
										'4'  => 'Otros'
										),
		'AUX1_VIVE_ACTUAL_CON' => array(
										''   => '-',
										'1'  => 'Solo',
										'2'  => 'Con compañeros',
										'3'  => 'Con familia de origen (padres, hermanos, abuelos)',
										'4'  => 'Con su pareja/hijos',
										'5'  => 'Otros'
								),
		'AUX1_EXISTE_TRAB_ALUM' => array(
									'' => '-',
									'3' => 'No trabajó y no buscó trabajo (no esta pensando en trabajar)',
									'2' => 'No trabajó y buscó trabajo en algún momento de los últimos 30 días',
									'1' => 'Trabajó al menos una hora (incluye ausencia por licencia, vacaciones, enfermedad)'
								),
		'AUX2_ALU_TRAB_HACE' => array(
									'' => '-',
									'1' => 'Patrón (tiene empleados)',
									'2' => 'Cuenta propia',
									'3' => 'Obrero o empleado (asalariado)',
									'4' => 'Pasante',
								),
		'AUX2_ALU_TRAB_OCUP' => array(
									'' => '-',
									'1' => 'Permanente (incluye fijo, estable, de planta)',
									'2' => 'Temporaria (incluye changa, trabajo o estacional, contratado, suplencia, etc.)'
									),
		'CENS_HORA_SEM_TRAB_ALUM' => array(
									'' => '-',
									'1' => 'Hasta 10 horas',
									'2' => 'Más de 10 y hasta 20 horas',
									'3' => 'Más de 20 y menos de 35 horas',
									'4' => '35 o más horas'
								),
		'CENS_REL_TRAB_CARRERA' => array(
										'' => '-',
										'1' => 'Total',
										'2' => 'Parcial',
										'3' => 'Sin relación'
									),
		'AUX2_ALU_TEC_INT_REGUL' => array(
										'' => '-',
										'4' => 'Nunca',
										'3' => 'Sólo algunas veces por mes',
										'2' => 'Sólo algunas veces por semana',
										'1' => 'Todos los días'
									),
		'AUX2_ALU_TRAB_DESJUB' => array(
										'' => '-',
										'S' => 'Sí',
										'N' => 'No',
		),
		'AUX2_ALU_TRAB_FAMI' => array(
										'' => '-',
										'S' => 'Sí',
										'N' => 'No',
		),
		'AUX1_REMUNERACION' => array(
										'' => '-',
										'S' => 'Sí',
										'N' => 'No',
		),
	);

	static function get($campo)
	{
		if (isset(self::$def[$campo])) {
			return self::$def[$campo];

		} else {
			switch ($campo) {
				case 'AUX2_ALU_OTESTSUP_EGRE':
					return self::anios_egreso();
				break;
				case 'AUX1_CELULAR_COMPANIA':
					$empresas_celulares = catalogo::consultar('etiquetas', 'empresas_celulares');
					return forms::rs_to_select($empresas_celulares,'-- SELECCIONE --');
				case 'AUX1_CANT_HIJOS_ALUM':
				case 'AUX1_CANT_FAMI_CARGO':
					return array(	''   => '-',
									'0'  => 'No tiene',
									'1'  => 'Uno' ,
									'2'  => 'Dos',
									'3'  => 'Más de dos'
								);
				break;
				case 'AUX1_PADRE_VIVE':
				case 'AUX1_MADRE_VIVE':
					return  array(
									'S' => 'Si',
									'N' => 'No',
									'D' => 'Desconoce'
								);
				break;
				case 'CENS_ULT_EST_CUR_PADRE':
				case 'CENS_ULT_EST_CUR_MADRE':
					return array(
								'' => '-',
								'1' => 'No hizo estudios',
								'2' => 'Estudios primarios incompletos',
								'3' => 'Estudios primarios completos',
								'4' => 'Estudios secundarios incompletos',
								'5' => 'Estudios secundarios completos',
								'8' => 'Estudios superiores incompletos',
								'9' => 'Estudios superiores completos',
								'10' => 'Estudios universitarios incompletos',
								'11' => 'Estudios universitarios completos',
								'12' => 'Estudios de Post grado',
								'13' => 'Desconoce'
								);
				break;
				case 'ENS_SIT_LABORAL_PADRE':
				case 'ENS_SIT_LABORAL_MADRE':
					return array(
									'' => '-',
									'3' => 'No trabajó y no buscó trabajo (no esta pensando en trabajar)',
									'2' => 'No trabajó y buscó trabajo en algún momento de los últimos 30 días',
									'1' => 'Trabajó al menos una hora (incluye ausencia por licencia, vacaciones, enfermedad)',
									'4' => 'Desconoce'
					);
				break;
				case 'AUX2_PADRE_TRAB_HACE':
				case 'AUX2_MADRE_TRAB_HACE':
					return array(
									'' => '-',
									'1' => 'Patrón (tiene empleados)',
									'2' => 'Cuenta propia',
									'3' => 'Obrero o empleado (asalariado)',
									'4' => 'Desconoce'
					);
				break;
				case 'AUX2_PADRE_TRAB_OCUP':
				case 'AUX2_MADRE_TRAB_OCUP':
					return array(
									'' => '-',
									'1' => 'Permanente (incluye fijo, estable, de planta)',
									'2' => 'Temporaria (incluye changa, trabajo o estacional, contratado, suplencia, etc.)',
									'3' => 'Desconoce'
					);
				break;
				case 'AUX2_PADRE_TRAB_OTRO':
				case 'AUX2_MADRE_TRAB_OTRO':
					return array(
									'' => '-',
									'1' => 'Es jubilado ó pensionado',
									'2' => 'Es rentista',
									'3' => 'Es estudiante',
									'4' => 'Realiza tareas del hogar',
									'5' => 'Otro',
									'6' => 'Desconoce'
					);
				break;
				case 'CENS_SIT_LABORAL_PADRE':
				case 'CENS_SIT_LABORAL_MADRE':
					return array(
									'' => '-',
									'3' => 'No trabajó y no buscó trabajo (no esta pensando en trabajar)',
									'2' => 'No trabajó y buscó trabajo en algún momento de los últimos 30 días',
									'1' => 'Trabajó al menos una hora (incluye ausencia por licencia, vacaciones, enfermedad)',
									'4' => 'Desconoce'
					);
				break;
				case 'AUX2_ALU_IDIOMA_INGL':
				case 'AUX2_ALU_IDIOMA_FRAN':
				case 'AUX2_ALU_IDIOMA_PORT':
				case 'AUX2_ALU_IDIOMA_ITAL':
				case 'AUX2_ALU_IDIOMA_ALEM':
					return array(
									'3' => 'Básico',
									'2' => 'Bueno',
									'1' => 'Muy bueno',
									'4' => 'Ninguno'
							);
				break;
				// nuevos campos
				case 'CENS_SECTOR':
					$sectores = catalogo::consultar('etiquetas', 'sectores_ac_ec');
					return forms::rs_to_select($sectores,'-- SELECCIONE --');
				break;
				case 'CENS_SUBSECTOR':
					$datos = guarani::datos_censales()->get_datos_censales();
					$sector = $datos['CENS_SECTOR'];
					$subsectores = catalogo::consultar('etiquetas', 'subsectores_ac_ec', array('sector' => $sector));
					if (!empty($subsectores)){
						return forms::rs_to_select($subsectores,'-- SELECCIONE --');
					} else {
						return array();
					}
				break;
				case 'CENS_FACILIDAD_EST_EMP':
					return array(
									'' => '-- SELECCIONE --',
									'M' => 'MUCHA',
									'P' => 'POCA',
									'N' => 'NADA',
							);
				break;
				case 'CENS_FACILIDAD_EST_INST':
					return array(
									'' => '-- SELECCIONE --',
									'M' => 'MUCHA',
									'P' => 'POCA',
									'N' => 'NADA',
							);
				break;
				case 'CENS_EMPRESA':
					$empresas = catalogo::consultar('etiquetas', 'empresas');
					return forms::rs_to_select($empresas,'-- OTRA --');
				break;
				case 'CENS_ANTIGUEDAD':
					return array(
									'' => '-- SELECCIONE --',
									'0' => 'MENOS DE 1 AÑO',
									'1' => '1 AÑO',
									'2' => '2 AÑOS',
									'3' => '3 AÑOS',
									'4' => '4 AÑOS',
									'5' => '5 AÑOS',
									'6' => '6 O MÁS AÑOS',
							);
				break;
				default:
					throw new \siu\errores\error_guarani("NO EXISTEN DATOS COMUNES PARA EL CAMPO '$campo'");
			}
		}
	}
}
?>