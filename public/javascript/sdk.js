$(function() {
    // region Products
    $("button#create-new-product").click(function () {
        CreateNewProduct({product_data: {name: $("input#new-product-name").val()}}, function(data){console.log(data)});
    });

    $("button#delete-product").click(function () {
        DeleteProduct({product_data: {id: $("input#delete-product-id").val()}},  function(data){console.log(data)})
    });

    $("button#show-all-products").click(function () {
        GetAllProducts(function(data){
            console.log(data);
            $( "tr#all-product-element" ).remove();
            $.each( data['products'], function( key, value ) {
                $("table#products-list tbody").append(GenerateRowForProduct(value['id'], value['name'],  value['created_at']));
            });
        });
    });

    function GenerateRowForProduct(id, name, created_ad){
       return "<tr id='all-product-element'><td>" + id + "</td><td>" + name + "</td><td>" + created_ad + "</td></tr>"
    }

    $("button#update-product").click(function () {
        EditProduct({product_data: {id: $("input#edit-product-id").val(), name: $("input#edit-product-name").val()}}, function(data){console.log(data)});
    });

    $("button#show-product").click(function () {
        $( "tr#all-product-element" ).remove();
        ShowProduct({product_data: {id: $("input#show-product-id").val()}}, function(data){
            $("table#show-product-list tbody").append(GenerateRowForProduct(data['product']['id'], data['product']['name'],  data['product']['created_at']));
            console.log(data)
        });
    });
        // endregion Products
});