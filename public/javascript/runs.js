// data = {product_data: {name: 'product name'}}
// callback = function(data){console.log(data)}. Feel free to replace console.log(data) to any code
function CreateNewRun(data, callback) {
    $.ajax({
        type: "POST",
        url: 'run_new',
        data: (data),
        statusCode: {
            200: function (data) {
                callback(data);
            },
        }
    });
};