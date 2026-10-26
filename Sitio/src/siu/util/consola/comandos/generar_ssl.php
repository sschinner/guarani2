<?php
namespace siu\util\consola\comandos;

use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console;

use siu\guarani;
use kernel\kernel;
use kernel\util\manejador_archivos;

class generar_ssl extends comando_guarani
{
	protected $input; //Console\Input\InputInterface
	protected $output; //Console\Output\OutputInterface
	
	protected function configure()
	{
        $this
        ->setName('generar_ssl')
		->setDescription('Generar certificado ssl. generar_ssl carpeta_con_openssl.ini')
        
		->setDefinition(array(
            new InputArgument('c', InputArgument::REQUIRED, 'Carpeta con archivo openssl.ini, relativa a instalacion/'),
        ))
		
        ->setHelp(sprintf(
				'%sGenera un par de clave publica y privada ssl en la carpeta relativa a instalacion/ que contiene la configuracion.%s',
				PHP_EOL,
				PHP_EOL
		));
    }

    protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output)
	{
		$this->input = $input->getArguments();
		$carpeta = $input->getArgument('c');
		$carpeta_completa = \siu\bootstrap::get_dir_instalacion()."/$carpeta";
		
		$output->writeln('');

		if (!is_dir($carpeta_completa)){
			$output ->writeln("No se encuentra la carpeta $carpeta_completa");
			$this->output = $output;
			return;
		}
		//Busco en el directorio de instalacion el archivo de configuracion para openssl
		if (! file_exists($carpeta_completa.'/openssl.ini')) {
			$output ->writeln("No existe el archivo '$carpeta_completa/openssl.ini', debe proveer uno para configurar el certificado.");
			$this->output = $output;
			return;
		}
		
		if (file_exists($carpeta_completa.'/privada.pkey') || file_exists($carpeta_completa.'/publica.crt'))  {
			$helper = $this->getHelper('dialog');
			$preg = $helper->ask($output, "Existen certificados privada.pkey y publica.crt en $carpeta_completa. Desea sobreescrirlos (s/[n]) ", 'n');
			if ($preg != 's'){
				$output ->writeln("Operacion cancelada.");
				$this->output = $output;
				return;
			}
		}
		$output->writeln('');
		$resultado = $this->generar_certificados($carpeta_completa);
		$output->writeln('');
		if($resultado === true){
			$output->writeln('******************************************************************');
			$output->writeln('Los certificados se crearon correctamente en: ');
		    $output->writeln($carpeta_completa);
			$output->writeln('******************************************************************');
			$output->writeln('');
		}else{
			$this->output->writeln($resultado);
		}
		$this->output = $output;
    }
	
	/**
	 * Genera los archivos para los certificados en el directorio especificado.
	 * Se asume que hay un archivo openssl.ini en el mismo con la configuracion.
	 */
	static function generar_certificados($directorio)
	{
		$cmd = "openssl req -x509 -nodes -days 20000 -newkey rsa:1024 -keyout $directorio/privada.key.sign -config $directorio/openssl.ini -out $directorio/publica.crt";
		
		exec($cmd, $output, $exito);
		if ($exito != '0') {
			return $output;
		}
		$cmd = "openssl rsa -in $directorio/privada.key.sign -out $directorio/privada.pkey";
		exec($cmd, $output, $exito);
		if ($exito != '0') {
			return $output;
		}		
		unlink("$directorio/privada.key.sign");
		return true;
	}
}