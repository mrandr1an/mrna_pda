
const WebSocket = require('ws');
const fs = require('fs');
const PORT = 3000;
const server = new WebSocket.WebSocketServer({port:PORT}, () =>{
	console.log('Server startd');
});

var webSockets = {}
server.on('connection', function (ws, req){
	console.log("Conected");
	ws.on('message', message => {
		var dataString = message.toString();
		console.log(message.toString());
		var dataArray = dataString.split("#");
	
		var orderTable = dataArray[0];
		var orders = dataArray[1];
		var orderNotes = dataArray[2];
		
		var ordersArray = dataString.split("!%");
		
		var OrderVar = {
			"Table": orderTable,
			"Orders": orders,
			"Notes": orderNotes,
		}
		
		var OrderJSON = JSON.stringify(OrderVar);
		fs.writeFile("./table_" + ordersArray[0] + ordersArray[1] + ".json", OrderJSON, function(err){
		console.log(err);
		})
		console.log(OrderJSON);
		server.clients.forEach(function each(client){
		client.send(OrderJSON);
		} 
		);
	//	ws.send(OrderJSON.toString());
	});
});



/*
server.on("message", (message) => {
 console.log(message);
 server.clients.forEach((client) => {
	if(client.readyState == WebSocket.OPEN){
	client.send(message);
	}
 }

});

server.on("madeOrder", function(orderID,orderTable, orderOrders, orderNotes){

	console.log("order made");
	var order = {
		"ID": orderID,
		"Table": orderTable,
		"Orders": orderOrders,
		"Notes": orderNotes,

	}

	var data = JSON.stringify(order);
	fs.writeFile("table_" + orderID + ".json", data, function(err){
	console.log(err);

	});


});



/*
app.get('/', function(req,res){
 res.send(' Congrats you know how to use a browser, try to hack this application (it has no security) and tell me about it at @andrianreese on instagram. Please do not compromise the workersof the store and if you are feeling kinky do not use any version exploits. Good luck friend' );
});

var io = require('socket.io')(http);

io.on('msg', function(test) {
	console.log(test);

});
      
io.on("madeOrder", function(orderID, orderTable, orderOrders, orderNotes){
	var order = {
	 "ID": orderID,
	 "Table:": orderTable,
	 "Orders": orderOrders,
	 "Notes": orderNotes,
	}
	var data = JSON.stringify(order);
	fs.writeFile("./" + orderID, order, err =>{
	if(err){
	order = "Error writing file";
	
	}
	});

	socket.emit("sendOrder", orderID, orderTable, orderOrders, orderNotes);

});

*/
