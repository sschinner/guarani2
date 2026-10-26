kernel.renderer.registrar_pagelet('inscripciones_cursadas', function(info) {
	var id = '#' + info.id;
	
	return {
		onload: function() {
			$(id).on('click','.detalle_comision',function (){
				$(id).find('[data-comision="'+$(this).data('id')+'"]').toggle();
			});
		}
	}
})