function testing(text)
{
    $.ajax({
        url: "/users",
        type: "GET",
        data: {"sort" : text, "ajax" : true },
        contentType: 'text/html',
        success: function(data) {
            $("#users tbody").empty().append(data);
        }
    });
}