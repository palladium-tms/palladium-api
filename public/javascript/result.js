// data = {result_data: {message: hash, status: str, result_set_id: int}}
// callback = function(data){console.log(data)}. Feel free to replace console.log(data) to any code
function CreateNewResult(data, callback) {
    $.ajax({
        type: "POST",
        url: 'result_new',
        data: (data),
        statusCode: {
            200: function (data) {
                callback(data);
            },
        }
    });
};
