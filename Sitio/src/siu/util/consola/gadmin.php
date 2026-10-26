<?php
namespace siu\util\consola;

use Symfony\Component\Console\Application,
	siu\util\consola\comandos;
use kernel\kernel;

class gadmin extends Application {

	public function __construct() {
    	parent::__construct('Guarani Web', '1.0');
    	
    	$this->addCommands(array(
			new comandos\cache(),
			new comandos\generar_catalogo(),
			new comandos\generar_puntos(),
			new comandos\casual(),
			new comandos\importar_fotos(),
			new comandos\datos_test(),
			new comandos\info(),
			new comandos\generar_reporte(),
			new comandos\generar_escalas_js(),
            new comandos\compilar_recursos(),
            new comandos\log(),
            new comandos\test_conexion(),
			new comandos\migrar_claves(),
            new comandos\limpiar_cache(),
			new comandos\generar_ssl(),
            new comandos\enviar_emails()
		));
    }

	public function run()
	{
        try {
			$status = parent::run();
			kernel::log()->guardar();
			exit($status);
		} catch (\Exception $e) {
			kernel::log()->add_error($e);
			kernel::log()->guardar();
		}
	}
}

