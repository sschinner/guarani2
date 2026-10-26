kernel.renderer.registrar_pagelet('prorrogas_regularidad', function(info) {
	var id = '#' + info.id;
	
	return {
		onload: function() {
//			$('#tabla_prorrogas').on('click', 'tr',function (){
//				guarani.cambiar_op({
//					href: $(this).data('link')
//				});
//				return false;
//			});
		}
	}
})