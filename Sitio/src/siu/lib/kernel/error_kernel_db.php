<?php

namespace kernel;

class error_kernel_db extends error_kernel
{
	protected $sqlstate;
	
    function set_sqlstate($sqlstate)
	{
		$this->sqlstate = $sqlstate;
	}
	
	function get_sqlstate()
	{
		return $this->sqlstate;
	}
}

?>
