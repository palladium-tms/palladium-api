// data = {product_data: {name: 'product name'}}
// callback = function(data){console.log(data)}. Feel free to replace console.log(data) to any code
function CreateNewPlan(data, callback) {
    $.ajax({
        type: "POST",
        url: 'plan_new',
        data: (data),
        statusCode: {
            200: function (data) {
                callback(data);
            },
        }
    });
};

// data = {plan_data: {product_id: int}}
// callback = function(data){console.log(data)}. Feel free to replace console.log(data) to any code
function ShowPlans(data, callback) {
    $.ajax({
        type: "GET",
        url: 'plans',
        data: (data),
        statusCode: {
            200: function (data) {
                callback(data);
            },
        }
    });
};


// data= {plan_data: {id: plan_id}}, plan_id is number
// callback = function(data){console.log(data)}. Feel free to replace console.log(data) to any code
function DeletePlan(data, callback) {
    $.ajax({
        type: "DELETE",
        url: 'plan_delete',
        data: (data),
        statusCode: {
            200: function (data) {
                callback(data);
            }
        }
    });
};
//
// // callback = function(data){console.log(data)}. Feel free to replace console.log(data) to any code
// function GetAllProducts(callback) {
//     $.ajax({
//         type: "GET",
//         url: 'products',
//         statusCode: {
//             200: function (data) {
//                 callback(data);
//             }
//         }
//     });
// };
//
// // callback = function(data){console.log(data)}. Feel free to replace console.log(data) to any code
// function EditProduct(data, callback) {
//     $.ajax({
//         type: "POST",
//         data: (data),
//         url: 'product_edit',
//         statusCode: {
//             200: function (data) {
//                 callback(data);
//             }
//         }
//     });
// };
//
// // data= {product_data: {id: product_id}}, product_id is number
// // callback = function(data){console.log(data)}. Feel free to replace console.log(data) to any code
// function ShowProduct(data, callback) {
//     $.ajax({
//         type: "GET",
//         data: (data),
//         url: 'product',
//         statusCode: {
//             200: function (data) {
//                 callback(data);
//             }
//         }
//     });
// };