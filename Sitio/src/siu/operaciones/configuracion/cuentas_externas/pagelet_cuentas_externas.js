kernel.renderer.registrar_pagelet('cuentas_externas', function(info) {
	var id = '#' + info.id;

    window.returnPopup = function(data) {
        recargar(data);
    };

    function recargar(data) {
        kernel.ajax.call(info.url_recargar, {
            type: 'get',
            data: {    },
            success: function (paquete) {
                $('#cuentas_externas').html(paquete.cont);
                kernel.renderer.pagelet('cuentas_externas').onload();

                if (data.error){
                    kernel.ui.show_mensaje(data.error, {tipo: 'alert-danger'});

                }

            }
        });
    }

	return {
		onload: function() {

            $(".js-desvincular").click(function(){
                kernel.ajax.call($(this).attr('href'), {
                    type: 'get',
                    data: {	},
                    success: function(paquete) {
                        recargar(paquete.cont);
                    }
                });
                return false;
            });

            $(".js-vincular").click(function(){
                var w = 500, h = 500, left = (screen.width/2)-(w/2), top = (screen.height/2)-(h/2);
                window.open($(this).attr('href'), '', 'menubar=no,status=no,titlebar=no,toolbar=no,width='+w+', height='+h+', top='+top+', left='+left);
                return false;
            });


        }
    }
});