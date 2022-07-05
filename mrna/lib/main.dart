import 'package:flutter/material.dart';
import 'home.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main(){
	runApp(ProviderScope(
			child: MaterialApp(
		initialRoute: '/',
		routes: {
		'/': (context) => Home(),
//		'order' (context) => OrderRoute(),
		
		
		}
			
			
			)));



}



