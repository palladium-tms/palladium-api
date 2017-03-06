// data = {product_data: {name: 'product name'}}
// callback = function(data){console.log(data)}. Feel free to replace console.log(data) to any code
function CreateNewResultSet(data, callback) {
    $.ajax({
        type: "POST",
        url: 'result_set_new',
        data: (data),
        statusCode: {
            200: function (data) {
                callback(data);
            },
        }
    });
};

// data = {run_data: {plan_id: int}}
// callback = function(data){console.log(data)}. Feel free to replace console.log(data) to any code
function ShowResultSets(data, callback) {
    $.ajax({
        type: "GET",
        url: 'result_sets',
        data: (data),
        statusCode: {
            200: function (data) {
                callback(data);
            },
        }
    });
};

function DeleteRun(data, callback) {
    $.ajax({
        type: "DELETE",
        url: 'run_delete',
        data: (data),
        statusCode: {
            200: function (data) {
                callback(data);
            }
        }
    });
};