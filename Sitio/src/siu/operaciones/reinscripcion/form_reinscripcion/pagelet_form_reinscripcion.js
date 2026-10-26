kernel.renderer.registrar_pagelet('form_reinscripcion', function(info) {
    var id = '#' + info.id;

	return {
        onload: function() {
			$("#form-reinscripcion").submit(function() {
				kernel.ajax.load($(this).attr('action'), id, {
					historia: false,
					type: 'POST',
					success: function(paquete) {

                        if(!paquete.hubo_error){
                            kernel.ui.show_mensaje(paquete.msg_exito, {
                                until_interaction: true
                            });
                        }
						
						kernel.renderer.pagelet('form_reinscripcion').onload();
					}
				});
				return false;
			});
        }
		
    }
})