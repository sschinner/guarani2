kernel.renderer.registrar_pagelet('reporte', function(info) {
    var id = '#' + info.id;

    return {
        onload: function() {
			$(id).delegate(".link-js", "click", function() {
				$(this).find('.toggle').toggleClass(function(){
					if ($(this).is('.icon-chevron-up')) {
						return 'icon-chevron-down';
					} else {
						return 'icon-chevron-up';
					}
				});
				$("#"+$(this).attr('data-link')).toggle();				
				return false;
			});
        }
    }
})