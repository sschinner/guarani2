<?php

namespace kernel\consola\comandos;

use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console;

class comando_kernel extends Console\Command\Command
{
    function __construct($name = null) 
    {
        parent::__construct($name);
        $hs = new Console\Helper\HelperSet(array(new Console\Helper\DialogHelper()));
        $this->setHelperSet($hs);
    }
	
	protected function configure()
	{
		$this->instanciar_nucleo();
	}
	
	protected function instanciar_nucleo()
	{
		
	}
}

?>
