<?php

namespace siu\util\consola\comandos;

use Symfony\Component\Console\Input\InputArgument,
    Symfony\Component\Console\Input\InputOption,
    Symfony\Component\Console;

class comando_guarani extends Console\Command\Command
{
    function __construct($name = null) 
    {
        parent::__construct($name);
        $hs = new Console\Helper\HelperSet(array(new Console\Helper\DialogHelper()));
        $this->setHelperSet($hs);
    }
	
	function bootstrap_kernel($acceso=false)
	{
		\siu\bootstrap::cargar(true, $acceso);
	}
}

?>
