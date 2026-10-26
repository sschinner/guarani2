<?php

namespace siu\operaciones\logger;

use kernel\kernel;
use siu\extension_kernel\vista_g3w2;

class vista extends vista_g3w2
{
    function ini() 
    {
        $clase = 'operaciones\logger\pagelet_lista_logs';
        $pl = kernel::localizador()->instanciar($clase, 'lista_logs');
        $this->add_pagelet($pl);

        $clase = 'operaciones\logger\pagelet_info_log';
        $pl = kernel::localizador()->instanciar($clase, 'info_log');
        $this->add_pagelet($pl);

        kernel::pagina()->set_etiqueta('titulo', "Logger");
        kernel::pagina()->set_etiqueta('sub_titulo', "");        
    }
}
?>
