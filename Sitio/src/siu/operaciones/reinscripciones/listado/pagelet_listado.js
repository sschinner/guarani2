kernel.renderer.registrar_pagelet('listado', function(info) {
    var id = '#' + info.id;

	return {
        onload: function() {
			$(".ver_comprobante").click(function() {
                $('tr[comprobante="'+$(this).data('comprobante')+'"]').toggle();
                
                if($(this).text() === info.mostrar_detalle){
                    $(this).text(info.ocultar_detalle);
                } else {
                    $(this).text(info.mostrar_detalle);
                }
			});
            
            $(id).on('click', '.js-print-comprobante', function() {
                var w = window.open($(this).data('img'), '_blank', 'menubar=0,scrollbars=0,location=0');
                w.document.title = 'Imprimir comprobante';
                w.onload = function() {
                    w.print();
                };
                return false;
            });
        }
		
    }
})