kernel.renderer.registrar_pagelet('examenes', function(info) {
	var id = '#' + info.id;

	return {
		onload: function() {

			$(id+" a").on("click", function(){
				$('#'+$(this).attr("link")).toggle();
			});

			$(id+" #examenes_historicos").on("click", function(){
				var valor_check_exa = "A";
				if ($(this).prop('checked')){
					valor_check_exa = "T"
				}
				
				kernel.ajax.load(info.url_examenes, id, {
					historia: false,
					type: 'GET',
					data: {'examenes_historicos': valor_check_exa},
					success: function() {
						kernel.renderer.pagelet('examenes').onload();
					}
				});
			});

            function exp_pdf(url) {
                window.open(encodeURI(url));
            }

            $(id).on('click', '#pdf_btn',function (evt){
                exp_pdf($(this).attr('href'));
                evt.preventDefault();
                evt.stopPropagation();
            });

		}
	}
})