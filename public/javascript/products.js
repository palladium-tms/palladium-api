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

    $("button#delete-product").click(function (e) {
        e.preventDefault();
        $.ajax({
            type: "DELETE",
            url: $(this).attr('action'),
            data: ({product_data: {id: $("input#delete-product-id").val()}}),
            statusCode: {
                200: function (data) {
                    console.log(data)
                },
            }
        });
    });
});
