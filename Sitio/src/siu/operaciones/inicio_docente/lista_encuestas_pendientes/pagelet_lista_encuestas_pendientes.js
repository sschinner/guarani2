kernel.renderer.registrar_pagelet('lista_encuestas_pendientes', function(info) {
    var id = '#' + info.id;

    return {
        onload: function() {

            $(id).on('click', '.colapsar',function (){
                $(this).parent('div').find('ul').toggle();
                return false;
            });

        }
    }
})