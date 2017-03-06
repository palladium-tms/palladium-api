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

    // region Plans
    function GenerateRowForPlan(id, name, product_id, created_ad, updated_at){
        return "<tr id='all-plan-element'><td>" + id + "</td><td>" + name + "</td><td>" + product_id + "</td><td>" + created_ad + "</td><td>" + updated_at + "</td></tr>"
    }

    $("button#create-new-plan").click(function () {
        CreateNewPlan({plan_data: {name: $("input#new-plan-name").val(), product_id: $("input#new-plan-product_id").val()}}, function(data){console.log(data)});
    });

    $("button#show-plans").click(function () {
        ShowPlans({plan_data: {product_id: $("input#show-plans-product_id").val()}}, function(data) {
            console.log(data);
            $( "tr#all-plan-element" ).remove();
            $.each( data['plans'], function( key, value ) {
                $("table#show-plans tbody").append(GenerateRowForPlan(value['id'], value['name'],  value['product_id'], value['created_at'], value['updated_at']));
            });
        });
    });

    $("button#update-plan").click(function () {
        EditPlan({plan_data: {id: $("input#edit-plan-id").val(), name: $("input#edit-plan-name").val()}}, function(data){console.log(data)});
    });

    $("button#delete-plan").click(function () {
        DeletePlan({plan_data: {id: $("input#delete-plan-id").val()}},  function(data){console.log(data)})
    });
    // endregion Plans
    // region Runs
    function GenerateRowForRun(id, name, plan_id, created_ad, updated_at){
        return "<tr id='all-run-element'><td>" + id + "</td><td>" + name + "</td><td>" + plan_id + "</td><td>" + created_ad + "</td><td>" + updated_at + "</td></tr>"
    }
    $("button#create-new-run").click(function () {
        CreateNewRun({run_data: {name: $("input#new-run-name").val(), plan_id: $("input#new-run-plan_id").val()}}, function(data){console.log(data)});
    });

    $("button#show-runs").click(function () {
        ShowRuns({run_data: {plan_id: $("input#show-runs-plan_id").val()}}, function(data) {
            console.log(data);
            $( "tr#all-run-element" ).remove();
            $.each( data['runs'], function( key, value ) {
                $("table#show-runs tbody").append(GenerateRowForRun(value['id'], value['name'],  value['plan_id'], value['created_at'], value['updated_at']));
            });
        });
    });

    $("button#delete-run").click(function () {
        DeleteRun({run_data: {id: $("input#delete-run-id").val()}},  function(data){console.log(data)})
    });
    // endregion Runs
});