kernel.renderer.registrar_pagelet('nueva_solicitud', function(info) {
    var id = '#' + info.id;

    return {
        onload: function() {
			
			
			
			if(info.error){
				
				kernel.ui.show_mensaje(info.mensajes.error_msj, {
                    tipo: 'alert-error',
                    timeout: 10000
                });
				
			}
			
			
			
		}
	}
});
