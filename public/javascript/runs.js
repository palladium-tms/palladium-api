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

// data = {run_data: {plan_id: int}}
// callback = function(data){console.log(data)}. Feel free to replace console.log(data) to any code
function ShowRuns(data, callback) {
    $.ajax({
        type: "GET",
        url: 'runs',
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