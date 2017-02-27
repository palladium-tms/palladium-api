$(function () {
    $("button#create-new-product").click(function (e) {
        e.preventDefault();
        $.ajax({
            type: "POST",
            url: $(this).attr('action'),
            data: ({product_data: {name: $("input#new-product-name").val()}}),
            statusCode: {
                200: function (data) {
                    console.log(data)
                },
            }
        });
    });
});
