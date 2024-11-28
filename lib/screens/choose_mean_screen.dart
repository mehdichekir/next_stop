import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';
import 'package:transport_app/widgets/mean_of_transport.dart';

class ChooseMeanScreen extends StatefulWidget {
  final String userId;
  const ChooseMeanScreen(this.userId);

  @override
  State<ChooseMeanScreen> createState() => _ChooseMeanScreenState();
}

class _ChooseMeanScreenState extends State<ChooseMeanScreen> {
  String dropDownValue='Select Manually';
  bool locationSelector = false;
  String userLocation = 'Location Not Yet Specified';
  String? userName;
  
  
  Future<String> fetchUserName(String userid)async{
    final userDataJSON=await  FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    final Map<String,dynamic> ?userData=userDataJSON.data();
    return userData?['username'];
  }

  Future<void> getUserLocation ()async{
    final locData = await Location().getLocation();
    List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(locData.latitude!, locData.longitude!);
    geo.Placemark place = placemarks[0];
    setState(() {
      userLocation="${place.locality}, ${place.country}";
    });
    print("${place.name}, ${place.locality}, ${place.country}");
  }
  
@override
  void initState() {
    super.initState();
    fetchUserName(widget.userId).then((username) {
      setState(() {
        userName = username; 
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          DropdownButton(
            value: 'logout',
            items: [
            DropdownMenuItem(
              value: 'logout',
              child: Container(
              child: const Row(
                children: [
                  Icon(Icons.exit_to_app),
                  SizedBox(width: 8,),
                  Text('Logout')
                ],
              ),
            ))
          ],
          onChanged: (itemIdentifer){
            if(itemIdentifer == 'logout'){
              FirebaseAuth.instance.signOut();
            }
          },
          icon: const Icon(Icons.more_vert,color: Colors.lightBlue,),)
        ],
        backgroundColor: Colors.lightBlue,
        title: PreferredSize(
          preferredSize: const Size.fromHeight(200),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Text('Hello $userName', style: TextStyle(fontSize: 30,color: Colors.white),),
                const SizedBox(height: 20),
                Text(userLocation,style: const TextStyle(fontSize: 15,color: Colors.white,)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: getUserLocation,
                      style: TextButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft
                      ),
                      child: const Text('Select On Map',style: TextStyle(color: Colors.white),),
                      ),
                      const SizedBox(width: 30,),
                      
                     DropdownButton<String>(
                    value: dropDownValue,
                    icon: const Icon(Icons.arrow_drop_down,size: 40,),
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: Colors.lightBlue,
                    underline: Container(
                      height: 0,
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'Select Manually',
                        child: Text("Select Manually")),
                        DropdownMenuItem<String>(
                        value: 'Tunis, Tunisia',
                        child: Text("Tunis,Tunisia")),
                        DropdownMenuItem<String>(
                        value: 'Ariana, Tunisia',
                        child: Text("Ariana,Tunisia")),
                        DropdownMenuItem<String>(
                        value: 'Manouba, Tunisia',
                        child: Text("Manouba,Tunisia")),
                        DropdownMenuItem<String>(
                        value: 'Ben Arous, Tunisia',
                        child: Text("Ben Arous, Tunisia")),
                    ],
                    onChanged: (String? newValue){
                      setState(() {
                        dropDownValue=newValue!;
                        userLocation=newValue;
                      });
                    })
                  ],
                )
              ],
            ),
          ),
        ),
        toolbarHeight: 200,
      ),
      body:
         Stack(
           children:[
            Container(
              alignment: Alignment.bottomCenter,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30)
              )
            ),
             child: const Column(children: [
              SizedBox(height: 40,),
              MeanOfTransport(title: 'Bus',imageAsset:  'assets/blue-bus-no-bg.png'),
              MeanOfTransport(title: 'Metro',imageAsset:'assets/metro-no-bg.png'),
              MeanOfTransport(title: 'Train',imageAsset: 'assets/train-no-bg.png')
                     ],),
           ),
           Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(left: 30,top: 7),
            child: const Text(
              'Choose Your Transport',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)
           )
           ] 
         ),
    );
  }
}