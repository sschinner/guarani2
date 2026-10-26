<?php
namespace siu\util\consola\comandos;

use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console;

use siu\guarani;
use kernel\kernel;
use kernel\util\manejador_archivos;

class log extends comando_guarani
{
	protected $input; //Console\Input\InputInterface
    /**
     * @var Console\Output\OutputInterface    
     */
    protected $output; 
    

	protected function configure()
	{
        $this
        ->setName('log')
		->setDescription('Muestra el último log disponible para la ua seleccionada')
		->setDefinition(array(
			new InputOption('ua', 'u', InputOption::VALUE_REQUIRED, 'La unidad académica')
		))
        ->setHelp(sprintf(
				'%sMuestra el último log disponible para la ua seleccionada.%s',
				PHP_EOL, 
				PHP_EOL
		));
    }

    protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output)
	{
        $this->input = $input;
        $this->output = $output;
		$this->bootstrap_kernel($input->getOption('ua'));
		
		$archivos = manejador_archivos::get_archivos_directorio(kernel::proyecto()->get_dir_log());
        rsort($archivos);
		
		if (empty($archivos)) {
			$this->output->writeln('No hay logs para esta unidad académica');
			return;
		}
		
		$this->output->writeln(file_get_contents(current($archivos)));
    }
}

?>
