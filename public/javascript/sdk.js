$(function() {
    // region Products
    $("button#create-new-product").click(function () {
        CreateNewProduct({product_data: {name: $("input#new-product-name").val()}}, function(data){console.log(data)});
    });

    $("button#delete-product").click(function (e) {
        DeleteProduct({product_data: {id: $("input#delete-product-id").val()}},  function(data){console.log(data)})
    });
    $("button#show-all-products").click(function (e) {
        GetAllProducts(function(data){
            console.log(data);
            $( "tr#all-product-element" ).remove();
            $.each( data['products'], function( key, value ) {
                new_string = "<tr id='all-product-element'><td>" + value['id'] + "</td><td>" + value['name'] + "</td><td>" + value['created_at'] + "</td></tr>";
                $("table#products-list tbody").append(new_string);
            });
        });
    });
        // endregion Products
});