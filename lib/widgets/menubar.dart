import 'package:docautomations/main.dart';
import 'package:flutter/material.dart';

class Menubar extends StatefulWidget {
  const Menubar({super.key});

  @override
  State<Menubar> createState() => _MenubarState();
}

class _MenubarState extends State<Menubar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prescriptor"),),
      drawer:  Drawer(child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              
              image: DecorationImage(
                fit: BoxFit.fill,
                image:  AssetImage("images/healthcare.jpg"))
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),color: Colors.lightBlue),
                  child: Center(child: Text("CC",style:TextStyle(fontSize: 26))),
                  ),
                  SizedBox(height: 20,),
                  
                  Text("Dr. Prescreptor ", style:TextStyle(color: Colors.black,fontSize: 26),)
              ],
            )),
            ListTile(
              onTap: () {Navigator.push(
                context, MaterialPageRoute(builder: (context)=>MyHomePage(title: "Prescriptor1")),
                );
                },
              leading: Icon(Icons.home,size:26,color: Colors.black,),
              title: Text("HomePage",style: TextStyle(fontSize: 20)),
            ),
            
            ListTile(
              onTap: () {},
              leading: Icon(Icons.info,size:26,color: Colors.black,),
              title: Text("Dr. Info",style: TextStyle(fontSize: 20)),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.logo_dev,size:26,color: Colors.black,),
              title: Text("Logo",style: TextStyle(fontSize: 20)),
            ),

           
            ListTile(
              onTap: () {},
              leading: Icon(Icons.settings,size:26,color: Colors.black,),
              title: Text("Settings",style: TextStyle(fontSize: 20)),
            ),
             Divider(color: Colors.black,),
            ListTile(
              onTap: () {},
              leading: Icon(Icons.logout,size:26,color: Colors.black,),
              title: Text("Logout",style: TextStyle(fontSize: 20)),
            ),
        ],
      ),),
      body: Container(), 
    );
  }
}