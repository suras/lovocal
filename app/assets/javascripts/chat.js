 function chat(data){
 	console.log(data.sender);
 	if(data.sender.sender_type.toLowerCase() == "servcie")
 	  {
        var in_div_id = "other-chat";
        var sent_by = "sent_by"+ chat.sender.sender_name+"</br>";
 	  }
 	else
 	  {
        var in_div_id = "my-chat";
        var sent_by = "";
 	  }
      var sent_time = '&nbsp;<i><small>'+data.sent_time+'</small></i><br>';
 	 var html = '<div id='+in_div_id+'>'+data.message+'<br>'+
      sent_by+sent_time+'</div>';
 	$('<div id="chat-box-item"></div>').html(html).appendTo('#chat-box');
    $("#chat_chat_id").val(data.chat_id);
    $("#chat_sent_time").val("2014-08-01T14:11:42+0530");
 }      

 