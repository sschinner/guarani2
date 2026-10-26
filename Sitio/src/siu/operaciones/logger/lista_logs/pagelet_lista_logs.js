kernel.renderer.registrar_pagelet('lista_logs', function(info) {
    var id = '#' + info.id;
    return {
        onload: function() {
//            var filtro = new util.filtro_lista({
//                valor_defecto: 'Buscar log...',
//                selector_input: '#filtro_logs input',
//                selector_li: '#lista_logs li'
//            });
        }
    }
})