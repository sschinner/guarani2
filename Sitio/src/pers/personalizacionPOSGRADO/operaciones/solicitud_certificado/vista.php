<?php

namespace personalizacionPOSGRADO\operaciones\solicitud_certificado;

use siu\extension_kernel\vista_g3w2;
use kernel\kernel;

class vista extends \siu\operaciones\solicitud_certificado\vista {

    function mostarUrl() {

        $clase = 'operaciones\solicitud_certificado\pagelet_formulario';
        $pl = kernel::localizador()->instanciar($clase, 'formulario');
        $this->add_pagelet($pl);


        kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_solicitud_certificado"));		
    }
    
    function mostarError() {

        $clase = 'operaciones\solicitud_certificado\pagelet_errorws';
        $pl = kernel::localizador()->instanciar($clase, 'errorws');
        $this->add_pagelet($pl);


        kernel::pagina()->set_etiqueta('titulo', kernel::traductor()->trans("tit_solicitud_certificado"));		
    }

}
