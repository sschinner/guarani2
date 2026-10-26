<?php
namespace siu\util\consola\comandos;

use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console\Formatter\OutputFormatterStyle,
    Symfony\Component\Console;

use siu\guarani;
use kernel\kernel;
use kernel\util\db\dba;
use kernel\error_kernel_db;

class test_conexion extends comando_guarani
{
	protected $dir;
	protected $clase_def = "_info_catalogo";
	protected $info = array();

	protected function configure()
	{
		parent::configure();
        $this
        ->setName('test_conexion')
		->setDescription('Testea la conexión a la BD')
		->setDefinition(array(
            new InputArgument('acceso', InputArgument::REQUIRED, 'ID del bloque de acceso a testear la conexión')
        ))		
        ->addOption('vendor', null, InputOption::VALUE_OPTIONAL, 'Reemplaza drivers para conexión')                
        ->addOption('database', null, InputOption::VALUE_OPTIONAL, 'Reemplaza la base de datos')                
        ->addOption('host', null, InputOption::VALUE_OPTIONAL, 'Reemplaza el Host de conexión')                                
        ->addOption('server', null, InputOption::VALUE_OPTIONAL, 'Reemplaza el server de conexión')                
        ->addOption('client_locale', null, InputOption::VALUE_OPTIONAL, 'Reemplaza el Locale del Cliente')                
        ->addOption('service', null, InputOption::VALUE_OPTIONAL, 'Reemplaza el puerto de conexión')                
        ->addOption('protocol', null, InputOption::VALUE_OPTIONAL, 'Reemplaza el protocolo de conexión')                
        ->addOption('LogonID', null, InputOption::VALUE_OPTIONAL, 'Reemplaza el usuario de conexión')                
        ->addOption('pwd', null, InputOption::VALUE_OPTIONAL, 'Reemplaza el password de conexión')                
                
                /*
        ->setDefinition(array(
            new InputArgument('x', InputArgument::OPTIONAL, 'First addend'),
            new InputArgument('y', InputArgument::OPTIONAL, 'Second addend'),
            ->addOption('user', 'u', InputOption::PARAMETER_OPTIONAL, 'Username', ''
        ))        
                
                
                
        /*
		->setDefinition(array(
            new InputArgument('x', InputArgument::REQUIRED, 'First addend'),
            new InputArgument('y', InputArgument::REQUIRED, 'Second addend'),
            new InputOption('round', null, null, 'Round result')
        ))*/
        ->setHelp(sprintf(
				'%sTestea la conexion a la BD%s',
				PHP_EOL, 
				PHP_EOL
		));
    }

    protected function imprimir($parametros, $TITULO='')
    {
        echo $TITULO . "\n\n";
        foreach ($parametros as $key => $parametro) {
                echo $key . ": " .$parametro ."\n"; 
        }
        echo "\n\n";
    }
    
    function writeln($texto, $output, $estilo=null)
    {
        $letra=null;
        $fondo=null;
        if (isset($estilo)) {
            switch ($estilo) {
               case 'exito':
                    $letra = 'white';
                    $fondo = 'green';
               break;
               case 'falla':
                    $letra = 'white';
                    $fondo = 'red';
               break;
               default:
                    break;
            }
           $style = new OutputFormatterStyle($letra, $fondo, array('bold', 'blink'));
           $output->getFormatter()->setStyle($estilo, $style);
           $output->writeln("<$estilo>$texto</$estilo>");
        } else {
           $output->writeln($texto);
        }
        
    }
	
    protected function execute(Console\Input\InputInterface $input, Console\Output\OutputInterface $output)
	{
		$punto_acceso = $input->getArgument('acceso');
		if ($punto_acceso) {
            $this->bootstrap_kernel($punto_acceso);
        }
        $options = $input->getOptions();
        $parametros_aplicacion = kernel::proyecto()->get_parametros_db();
        $parametros_modificados = $parametros_aplicacion;
        
        $modificados = false;
        unset($options['help']);
        unset($options['quiet']);
        unset($options['verbose']);
        unset($options['version']);
        unset($options['ansi']);
        unset($options['no-ansi']);
        unset($options['no-interaction']);
        
        
        foreach ($options as $opcion => $valor){
            if (isset($options[$opcion])) {
                    $parametros_modificados[$opcion] = $valor;
                    $modificados = true;
            }
        }
        try {
           $db      = dba::conectar($parametros_modificados);
           $ua      = $db->consultar_fila("select unidad_academica from sga_unidades_acad");
           $sql     = "execute procedure sp_unidadAcademica('".$ua['UNIDAD_ACADEMICA']."')";
           $datos   = $db->consultar_fila($sql);

		   $this->writeln('SE CONECTO CON EXITO!!!!!!!!!',$output , 'exito');
           $this->imprimir($parametros_aplicacion, 'PARÁMETROS DE LA APLICACION');
           if ($modificados) {
               $this->imprimir($parametros_modificados, 'PARÁMETROS UTILIZADOS');
           }
           $this->imprimir($datos, 'DATOS');
		   
			$bloque_acceso = kernel::proyecto()->get_bloque_acceso();
			$accesos = kernel::proyecto()->get_accesos();
			$acceso = $accesos[$bloque_acceso];
			$ua_ingresada = $acceso["ua"];
			if($ua['UNIDAD_ACADEMICA'] != $ua_ingresada)
			{
				$this->writeln('CÓDIGO DE ua INCORRECTO', $output, 'falla');
				$this->imprimir($ua, 'Deberá ingresar el siguiente código de Unidad Académica para el correcto ingreso de los usuarios al sistema.');
			}
			
        } catch (error_kernel_db $e) {
            $this->writeln('ERROR AL CONECTAR!!!!!!!!!', $output, 'falla');
            $this->writeln($e->getMessage(), $output, 'falla');
            $this->imprimir($parametros_aplicacion, 'PARAMETROS DE LA APLIACACION');
            if ($modificados) {
               $this->imprimir($parametros_modificados, 'PARÁMETROS UTILIZADOS');
            }
        }
    }


}