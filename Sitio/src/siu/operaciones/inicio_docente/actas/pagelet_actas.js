kernel.renderer.registrar_pagelet('actas', function(info) {
    var id = '#' + info.id;
	
	
	return {
        onload: function() {
			$(id + ' .js-comisiones-ver').on('click', function () {
				$(id + ' .js-comisiones-oculto').toggle(200);
			});
		
	
        }
    }
})