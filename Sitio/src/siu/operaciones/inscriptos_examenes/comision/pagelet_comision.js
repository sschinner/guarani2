kernel.renderer.registrar_pagelet('comision', function(info) {
    var id = '#' + info.id;
	
    return {
        onload: function() {
                $('.js-ficha_alumno').click(function() {
                        var url = $(this).data('url-ficha');
                        kernel.ui.pagelet_modal(url);
                });
        }
    }
})