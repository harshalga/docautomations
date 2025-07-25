
import 'package:docautomations/widgets/AddPrescrip.dart';
import 'package:flutter/material.dart';




class Menubar extends StatefulWidget {
  final Widget body; // 👈 new

  const Menubar({super.key, required this.body});

  @override
  State<Menubar> createState() => _MenubarState();
}

class _MenubarState extends State<Menubar> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prescriptor")),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("images/healthcare.jpg"),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.lightBlue,
                    ),
                    child: const Center(child: Text("CC", style: TextStyle(fontSize: 26))),
                  ),
                  const SizedBox(height: 20),
                  const Text("Dr. Prescriptor ", style: TextStyle(color: Colors.black, fontSize: 26)),
                ],
              ),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.home, size: 26, color: Colors.black),
              title: const Text("HomePage", style: TextStyle(fontSize: 20)),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Addprescrip(title: "PatientInfo")),
                );
              },
              leading: const Icon(Icons.info, size: 26, color: Colors.black),
              title: const Text("Dr. Info", style: TextStyle(fontSize: 20)),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.logo_dev, size: 26, color: Colors.black),
              title: const Text("Logo", style: TextStyle(fontSize: 20)),
            ),
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.settings, size: 26, color: Colors.black),
              title: const Text("Settings", style: TextStyle(fontSize: 20)),
            ),
            const Divider(color: Colors.black),
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.logout, size: 26, color: Colors.black),
              title: const Text("Logout", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
      body: SafeArea(child: widget.body), //widget.body, // 👈 load dynamic body here
      resizeToAvoidBottomInset: false,
    );
  }
}




// class Menubar extends StatefulWidget {
//   const Menubar({super.key});

//   @override
//   State<Menubar> createState() => _MenubarState();
// }

// class _MenubarState extends State<Menubar> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Prescriptor"),),
//       drawer:  Drawer(child: ListView(
//         children: [
//           DrawerHeader(
//             decoration: const BoxDecoration(
              
//               image: DecorationImage(
//                 fit: BoxFit.fill,
//                 image:  AssetImage("images/healthcare.jpg"))
//               ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   height: 60,
//                   width: 60,
//                   decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),color: Colors.lightBlue),
//                   child: const Center(child: Text("CC",style:TextStyle(fontSize: 26))),
//                   ),
//                   const SizedBox(height: 20,),
                  
//                   const Text("Dr. Prescriptor ", style:TextStyle(color: Colors.black,fontSize: 26),)
//               ],
//             )),
//             ListTile(
//               onTap: () {
//                 },
//               leading: const Icon(Icons.home,size:26,color: Colors.black,),
//               title: const Text("HomePage",style: TextStyle(fontSize: 20)),
//             ),
            
//             ListTile(
//               onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>const Addprescrip(title:"PatientInfo"),
//               ));},
//               leading: const Icon(Icons.info,size:26,color: Colors.black,),
//               title: const Text("Dr. Info",style: TextStyle(fontSize: 20)),
//             ),
//             ListTile(
//               onTap: () {},
//               leading: const Icon(Icons.logo_dev,size:26,color: Colors.black,),
//               title: const Text("Logo",style: TextStyle(fontSize: 20)),
//             ),

           
//             ListTile(
//               onTap: () {},
//               leading: const Icon(Icons.settings,size:26,color: Colors.black,),
//               title: const Text("Settings",style: TextStyle(fontSize: 20)),
//             ),
//              const Divider(color: Colors.black,),
//             ListTile(
//               onTap: () {},
//               leading: const Icon(Icons.logout,size:26,color: Colors.black,),
//               title: const Text("Logout",style: TextStyle(fontSize: 20)),
//             ),
//         ],
//       ),),
//       body: Container(), 
//     );
//   }
// }