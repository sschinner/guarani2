<?php
namespace siu;
/**
 * Description of version
 *
 * @author andres
 */
class version {
	protected static $activo = true;
	protected static $version_conversion = 'CNV2.09.5';
	protected static $version_creacion   = 'CNV2.09.0';
	protected static $ultimo_script_conversion = '12';
	
	static function es_valida()
	{
		if (! self::$activo) {
			return true;
		}
		
		return modelo\datos\catalogo::consultar('sistema', 'version_base_valida', array(
			'conversion'     => self::$version_conversion,
			'creacion'       => self::$version_creacion,
			'script_corrido' => self::$ultimo_script_conversion
		));
	}
	
	static function requerida()
	{
		$conv = self::$version_conversion;
		$crea = self::$version_creacion;
		$ultimo_script_conversion = self::$ultimo_script_conversion;
		return "Conversión: $conv; Ultimo script de conversión: $ultimo_script_conversion";
	}
}

?>
