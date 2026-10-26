kernel.renderer.registrar_pagelet('cursadas', function (info) {
    var id = '#' + info.id;

    return {
        onload: function () {

            $(id + " a").on("click", function () {
                $('#' + $(this).attr("link")).toggle();
            });

            $(id + " #cursadas_historicas").on("click", function () {
                var valor_check_cur = "A";
                if ($(this).prop('checked')) {
                    valor_check_cur = "T"
                }

                kernel.ajax.load(info.url_cursadas, id, {
                    historia: false,
                    type: 'GET',
                    data: {'cursadas_historicas': valor_check_cur},
                    success: function () {
                        kernel.renderer.pagelet('cursadas').onload();
                    }
                });
            });

            function exp_pdf(url) {
                window.open(encodeURI(url));
            }

            $(id).on('click', '#pdf_btn', function (evt) {
                exp_pdf($(this).attr('href'));
                evt.preventDefault();
                evt.stopPropagation();
            });

        }
    }
})