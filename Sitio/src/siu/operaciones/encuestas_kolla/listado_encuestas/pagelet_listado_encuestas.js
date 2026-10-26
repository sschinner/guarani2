kernel.renderer.registrar_pagelet('listado_encuestas', function(info) {
	var id = '#' + info.id;
	
	function registrar_eventos() 
	{
		$(id).on('click', 'a', function() {
			$(id+' a').removeClass('active');
			kernel.evts.disparar('cargar_encuesta', {
				href: $(this).attr('href'),
				me: this.id
			});
			return false;
		});
		
		$(id).on('click', '.colapsar',function (){
			$(this).parent('div').find('ul').toggle();
			return false;
		});
	}

	return {
		onload: function() {
			registrar_eventos();
            kernel.evts.disparar('marcar_encuesta');
		}
	}
})