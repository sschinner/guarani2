kernel.renderer.registrar_pagelet('lista_noticias', function(info) {
    var id = '#' + info.id;

    return {
        onload: function() {

            $(".noti-cont-dsc").dotdotdot({
                //watch		: true,
                callback	: function( isTruncated, orgContent ) {

                    if(isTruncated){

                        var noti_cont_dsc_full = $('<div class="noti-cont-dsc-full"></div>');
                        $(noti_cont_dsc_full).html(orgContent);
                        $(this).after('<a href="#" class="less">'+info.ocultar+'</a>');
                        $(this).after('<a href="#" class="more">'+info.ver_mas+'</a>');
                        $(this).after($(noti_cont_dsc_full));

                    }

                }
            });

            $('a.more').on("click", function( event ){

                event.preventDefault();
                var noticia = $( this ).parents('.noticia');
                var noti_cont_dsc = $(noticia).find('.noti-cont-dsc');
                var noti_cont_dsc_full = $(noticia).find('.noti-cont-dsc-full');
                var ocultar = $(noticia).find('a.less');
                $(this).hide();
                $(noti_cont_dsc).hide();
                $(noti_cont_dsc_full).show();
                $(ocultar).show();

            });

            $('a.less').on("click", function( event ){

                event.preventDefault();
                var noticia = $( this ).parents('.noticia');
                var noti_cont_dsc = $(noticia).find('.noti-cont-dsc');
                var noti_cont_dsc_full = $(noticia).find('.noti-cont-dsc-full');
                var ver_mas = $(noticia).find('a.more');
                $(this).hide();
                $(noti_cont_dsc_full).hide();
                $(noti_cont_dsc).show();
                $(ver_mas).show();

            });

        }
    }
})