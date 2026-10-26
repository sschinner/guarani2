kernel.renderer.registrar_pagelet('comisiones', function(info) {
    var id = '#' + info.id;
	
	
	return {
        onload: function() {
			$(id + ' #js-link-ver-todo').on('click', function () {
				$(id + ' .js-comisiones-oculto').toggleClass('hide');
				
				if ($(id + ' .js-comisiones-oculto').hasClass('hide')){
					$(id + ' #js-link-ver-todo').text(info.ver_mas);
				} else {
					$(id + ' #js-link-ver-todo').text(info.ocultar);
				}
			});
		
	
        }
    }
})