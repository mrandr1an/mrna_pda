import 'package:flutter/material.dart';
import 'constants.dart' as CON;
import 'dart:io';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';

List<Order> orderList = [];
List<String> orderStringList = ["ErrorErrorError", "Error", "Errorss"];
final channelProvider = Provider.autoDispose((ref) {return IOWebSocketChannel.connect(CON.ServerIP);});

final messageProvider = StreamProvider.autoDispose<String>((ref) async*{
var stream = ref.watch(channelProvider).stream.asBroadcastStream(
		onCancel: (sub) => sub.cancel());
		stream.listen((event){
			 print("Event had been sent");
			 }, 
			onError: (e) {print(e.toString());},
			onDone:() { ref.refresh(channelProvider);}
			
			);
			
final channel = ref.watch(channelProvider);

ref.onDispose(() => channel.sink.close()); 
await for (var value in stream){
		value = value.toString();
		yield value;
	}
stream.drain();
});

class Home extends ConsumerStatefulWidget{
	
	@override	
	HomeState createState() => HomeState();

}


class HomeState extends ConsumerState<Home>{
List<TextEditingController> textFieldControllers = [
new TextEditingController(),
new TextEditingController(),
];

	//menu
void showMenu(channel){
		showDialog(
			context:context,
			builder: (context){
			return StatefulBuilder(
				builder: (context, setState){
				return Dialog(
					//title: const Text("Menu"),
					child:  CustomScrollView(
						slivers: <Widget>[
						SliverList(
							delegate: SliverChildBuilderDelegate(
								(BuildContext context, int index){
								Color color = Colors.blue;
								return CheckboxList(index);
								},
								childCount: menuList.length,
								),
							),//sliverlist
							SliverFixedExtentList(
								itemExtent: 50.00,
								delegate: SliverChildBuilderDelegate(
									(BuildContext context, int index){
									List<String> labels = ["Table Name", "Order notes"];
									return TextField(
										controller: textFieldControllers[index],
										obscureText: false,
										decoration: InputDecoration(
											border: OutlineInputBorder(),
											labelText: labels[index],
											),
										);
									},
									childCount: 2,
									),
								), //sliverfixedextentlist
						SliverToBoxAdapter(
						     child:
							ElevatedButton(
							child: const Text('Send'),
							onPressed: () {
							List<String> tempList = [];
							for(int i=0; i<fromMenuList.length; i++){
								tempList.add(fromMenuList[i]);
							}
							Order order = new Order(textFieldControllers[0].text, Status.delivered,							       tempList, textFieldControllers[1].text);
							setState((){
						        String table = order.orderTable;
							List<String> orders = order.orders;
							String ordersString = "";
							ordersString = orders.join("!%"); 
							
							String orderNotes = order.orderNotes;
							channel.sink.add("$table#$ordersString#$orderNotes");
							});
							fromMenuList.clear();
							Navigator.pop(context);
							},
							),
							),
							], //slivers
							),//scrollview
					
					);//alert dialog
				
				}
				
				); //stateful builder
			
			
			}, //context
			); //dialog
		
	
	}

	void proccessMsg(msg){
		String orderTable; Status orderStatus; List<String> orders; String orderNotes;
		var parsedJSON = jsonDecode(msg);
		orderTable = parsedJSON['Table'];
		orders = parsedJSON['Orders'].toString().split('!%');
		for(int i=0; i<orders.length; i++){
		orders[i] = orders[i].replaceAll('!%', '');
		}
		orderNotes = parsedJSON['Notes'];
		Order order = new Order(orderTable, Status.delivered, orders, orderNotes);
		orderList.add(order);
		print(orderList.toString());
		
			
	}


	@override
	void initState(){
		super.initState();
		final value = ref.read(messageProvider);
		print(value);

	}

	@override
	Widget build(BuildContext context){
		ref.watch(messageProvider).when(
			loading: () => print("LOADING"),
			error: (err,stack) => print("ERROR"),
			data: (message) {
				print("Message is " + message.toString());
				var exists = false;
				for(int i=0; i<orderStringList.length; i++){
				if(orderStringList[i]==message.toString()){
				 	print("Order already exists");
					exists = true;
				       	break;
				}} 
					print(orderStringList.toString());
					orderStringList.add(message.toString());
							
				if(!exists){
				proccessMsg(message);
				}
			}
	     		
			);
	       final channel =ref.watch(channelProvider);
	       
	return 	Scaffold(
		body: CustomScrollView(
			slivers: <Widget>[
			SliverGrid(
				gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
					maxCrossAxisExtent: 200.0,
					mainAxisSpacing: 40.0,
					crossAxisSpacing: 10.0,
					childAspectRatio: 4.0,
					
					
					),
				delegate: SliverChildBuilderDelegate(
					(BuildContext context, int index){
					return Dismissible(
						child: ListTile(
							title: Text(orderList[index].orderTable),
							tileColor: orderList[index].orderStatus.getColor(),
							onLongPress: ((){
							  OrderDialog orderDialog = new OrderDialog(orderList[index]);
							  orderDialog.showOrder(context);
							}
							),
							onTap: ((){
							  setState((){
							      if(orderList[index].orderStatus.index == 2){
					orderList[index].orderStatus = Status.values[0];
							      }	else{
					orderList[index].orderStatus = Status.values[orderList[index].orderStatus.index+1];				  
							      }
							      });	  
							}),
						),
						background: Container(color: orderList[index].orderStatus.getColor() ),
						key: UniqueKey(),
						onDismissed: (direction) {
						setState(() {
						 orderList.removeAt(index);
							
						});
	
						},
							);
					
					},
					
				
				
				childCount: orderList.length,	
				),
				),
			
			
			
			
			],
			
			
			),
		floatingActionButton: FloatingActionButton.extended(
			onPressed: () {
			//Menu menu = new Menu(ref);
		        //menu.showMenu(context);
			showMenu(channel);
			//channel.sink.add("holy#shit#itschris");	
			},

			label: const Text('Add Order'),
			icon: const Icon(Icons.add),

			
			),	
	       appBar: AppBar(
		       actions: <Widget> [
		      TextButton(
		       style: TextButton.styleFrom(
			       padding: const EdgeInsets.all(15.0),
			       primary: Colors.white,
			       textStyle: const TextStyle(fontSize: 15),
			       ),
		       onPressed: () {
		       setState((){
		       
	 			});
		       
		       
		       },
		       child: const Text('Refresh'),
		       
		       ), //textbutton
		       ],
		       centerTitle: true,
		       title: Text("Home"),

	       ),
		
		);
	
	}



}


enum Status {
	complete,
	pending,
	delivered,
}

extension StatusExtension on Status {
 	Color getColor(){
	 switch(this){
		 case Status.complete:
			 return Colors.green;
		 case Status.pending:
			 return Colors.red[900]!;
		 case Status.delivered:
			 return Colors.cyan[50]!;
		 default:
			 return Colors.black!;
	 
	 }
	
	}
}

class Order {
 String orderTable;
 Status orderStatus;
 List<String> orders;
 String orderNotes;

 Order(this.orderTable, this.orderStatus, this.orders,this.orderNotes);


}

List<String> menuList = ["coffe", "pizza", "shit", "ficl"];
List<String> fromMenuList = [];

class CheckboxList extends StatefulWidget{
 final int index; 
 const CheckboxList (this.index);

 

 @override
 CheckBoxListState createState() => CheckBoxListState();

}
/*
class orderNotifier extends ChangeNotifier{
 void toggle(Order order){
 	if(order.orderStatus.index == 2){
	order = Status.values[0];
	} else{
	order.orderStatus.index == order.orderStatus.index + 1;
	}
 }

}
*/
class CheckBoxListState extends State<CheckboxList>{
		bool _isChecked = false;	
		@override
		Widget build(BuildContext context){
		Text textValue = Text(menuList[widget.index]);	
		return CheckboxListTile(
			activeColor:Colors.pink[300],
			dense: true,
			title: textValue,
			value: _isChecked,
			onChanged: (bool? value){
				setState(() { _isChecked = value!;
					     if(_isChecked){
					     fromMenuList.add(textValue.data!);
			     		     } else if (fromMenuList.contains(textValue.data!)){
					     	fromMenuList.remove(textValue.data!);
					     }		     
				});
			},
			);
		
		}

}

/// POP UP MENU ///
/*
class Menu{
	List<TextEditingController> textFieldControllers = [
	new TextEditingController(),
	new TextEditingController(),
	];
	String OT;
	List<String> O;
	String ON;
	Menu(this.ref);
	WidgetRef ref;
	Future<void> sendOrder (String orderTable,List<String> orders, String orderNotes) async {
	//	var channel = ref.watch(channelProvider);
		String ordersString = orders.join('!%');
		//orderToSend.add("$orderTable#ordersString#orderNotes");
	  //      channel.sink.add("$orderTable#$ordersString#$orderNotes");
		this.OT = orderTable;
		this.O = orders;
		this.ON = orderNotes;
	}



	String getOrder() async{
			
		return  "$OT#$O#$ON";
	}

	void showMenu(BuildContext context){
	showDialog(
		context: context,
		builder: (context){
			return StatefulBuilder (
				builder: (context,setState) {	
				return AlertDialog(
				title: const Text("Menu"),
				content: CustomScrollView(
					slivers: <Widget>[
						SliverList(
							delegate: SliverChildBuilderDelegate(
								(BuildContext context, int index){
								Color color = Colors.blue;
								return CheckboxList(index); 
								},
								childCount: menuList.length,
								),
							
							),
						SliverFixedExtentList(
							itemExtent: 50.00,
							delegate: SliverChildBuilderDelegate(
								(BuildContext context, int index){
					               	List<String> labels = ["Table Name", "Order notes"];
							               return  TextField(
									controller: textFieldControllers[index],
									obscureText: false,
									decoration: InputDecoration(
										 border: OutlineInputBorder(),
										 labelText: labels[index],	
										),
									);
								},
								childCount: 2,
								),
							),
					],		
					),	
		actions: [
			MaterialButton(
				child: Text("Done"),
				onPressed: () {
	List<String> tempList = [];
	for(int i=0; i<fromMenuList.length; i++){
		tempList.add(fromMenuList[i]);
	}
	Order order = new Order(textFieldControllers[0].text,Status.delivered,tempList,textFieldControllers[1].text);
	setState((){
	sendOrder(order.orderTable, order.orders, order.orderNotes);
	
//	orderList.add(order);
	});
	fromMenuList.clear();
	Navigator.pop(context);
				},
				),
		
			],
			);
			},
			);
			},
			);		
	}
	}
*/
class OrderDialog{
	Order order;
	OrderDialog(this.order);

	void showOrder(BuildContext context){
	order.orders.add(order.orderNotes); //Full Order String
	showDialog(
		context: context,
		builder: (context){
		return Dialog(
			child: CustomScrollView(
				slivers: <Widget>[
		       		SliverList(
					delegate: SliverChildBuilderDelegate(
						(BuildContext context, int index){
						 return Container(
						 child: Center(child: Text(order.orders[index])),
						 );

					 },
					 childCount: order.orders.length,
						),

						),
					SliverToBoxAdapter(
						child:
				        	ElevatedButton(
						child: Text("Ok"),
						onPressed: (){
						Navigator.pop(context);
						},
						),
					),		
				
				
				],	 	
		  	),
			);
		},

		);
	
	}

}


