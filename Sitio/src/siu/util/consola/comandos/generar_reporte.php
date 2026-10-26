<?php
namespace siu\util\consola\comandos;

use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console;

use siu\guarani;
use kernel\kernel;
use kernel\util\manejador_archivos;

class generar_reporte extends comando_guarani
{
	protected $input; //Console\Input\InputInterface
	protected $output; //Console\Output\OutputInterface
	
	/* 
	 * interno: true, false
	 * true: generar el reporte en src/siu/operaciones
	 * false: genera el reporte en src/pers/%personalizacion%/operaciones
	 */
	protected $interno = false;

	protected function configure()
	{
        $this
        ->setName('generar_reporte')
		->setDescription('Generar reporte. generar_reporte nombre_personalizacion nombre_reporte')
        
		->setDefinition(array(
            new InputArgument('c', InputArgument::REQUIRED, 'Nombre de personalizacion'),
			new InputArgument('n', InputArgument::REQUIRED, 'Nombre del reporte'),
        ))
		
        ->setHelp(sprintf(
				'%sGenera un nuevo reporte.%s',
				PHP_EOL,
				PHP_EOL
		));
    }

    protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output)
	{
		$this->input = $input->getArguments();
		$carpeta = $input->getArgument('c');
		$nombre = $input->getArgument('n');

		if ($this->interno){
			$dir_operacion = realpath(guarani::dir()."/..")."/siu/operaciones/{$nombre}";
		}
		else
		{
			$dir_operacion = realpath(guarani::dir()."/..")."/pers/{$carpeta}/operaciones/{$nombre}";
		}
		
		if (is_dir($dir_operacion)){
			$helper = $this->getHelper('dialog');
			$preg = $helper->ask($output, 'El directorio existe desea sobreescribirlo? (s/[n]) ', 'n');
			if ($preg == 's'){
				$this->generar_archivos($carpeta, $nombre, $output, $dir_operacion);
				$output->writeln('');
				$output->writeln('');
				$output->writeln('******************************************************************');
				$output->writeln('El reporte se creo correctamente');
				$output->writeln('******************************************************************');
				$output->writeln('');
				$output->writeln('Implemente los siguientes metodos:');
				$output->writeln('get_columnas(), get_total_registros(), get_datos() y get_data_reporte()');
				$output->writeln('en el archivo pagelet_contenido.php');
				$output->writeln('ubicado en '.manejador_archivos::path_a_plataforma($dir_operacion));
			}
			else
			{
				$output->writeln('Se cancelo la generacion del reporte');
			}
		}
		else
		{
			$this->generar_archivos($carpeta, $nombre, $output, $dir_operacion);
			$output->writeln('');
			$output->writeln('');
			$output->writeln('******************************************************************');
			$output->writeln('El reporte se creo correctamente');
			$output->writeln('******************************************************************');
			$output->writeln('');
			$output->writeln('Implemente los siguientes metodos:');
			$output->writeln('get_columnas(), get_total_registros() y get_data_reporte()');
			$output->writeln('en el archivo pagelet_contenido.php');
			$output->writeln('ubicado en '.manejador_archivos::path_a_plataforma($dir_operacion));
		}
		$this->output = $output;
    }

	protected function generar_archivos($carpeta, $nombre, $output, $dir_operacion){
		\kernel\util\manejador_archivos::crear_arbol_directorios($dir_operacion);

		$dir_archivos = manejador_archivos::path_a_plataforma(guarani::dir().'\operaciones\_comun\operaciones\reporte\template_reporte');
		$archivos = \kernel\util\manejador_archivos::get_archivos_directorio($dir_archivos,null,false);

		foreach($archivos as $archivo) {
            $nombre_archivo = basename($archivo);
			if (!is_dir($archivo)) {
				$contenido = file_get_contents($archivo);
				$contenido = str_replace('%operacion%', $nombre, $contenido);
				if ($this->interno){
					$contenido = str_replace('%pers%', 'siu', $contenido);
				}
				else
				{
					$contenido = str_replace('%pers%', $carpeta, $contenido);
				}				

				\kernel\util\manejador_archivos::crear_archivo_con_datos($dir_operacion."/".$nombre_archivo, $contenido);
				unset($contenido);
			}
		}

		$dir_archivos = manejador_archivos::path_a_plataforma(guarani::dir().'\operaciones\_comun\operaciones\reporte\template_reporte\reporte');
		$archivos = \kernel\util\manejador_archivos::get_archivos_directorio($dir_archivos,null,false);

		foreach($archivos as $archivo) {
			$nombre_archivo = basename($archivo);
			$contenido = file_get_contents($archivo);
			$contenido = str_replace('%operacion%', $nombre, $contenido);
			if ($this->interno){
				$contenido = str_replace('%pers%', 'siu', $contenido);
			}
			else
			{
				$contenido = str_replace('%pers%', $carpeta, $contenido);
			}
			\kernel\util\manejador_archivos::crear_archivo_con_datos($dir_operacion."/reporte/".$nombre_archivo, $contenido);
			unset($contenido);
		}
	}
}