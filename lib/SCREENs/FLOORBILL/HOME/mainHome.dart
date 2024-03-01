import 'package:floor_billing/SCREENs/ADDCUST/addcust.dart';
import 'package:floor_billing/SCREENs/FLOORBILL/1deliverybill.dart';
import 'package:floor_billing/SCREENs/FLOORBILL/HOME/DELIVERY/del1.dart';
import 'package:floor_billing/SCREENs/FLOORBILL/HOME/homeFloorBilling.dart';
import 'package:floor_billing/SCREENs/FLOORBILL/deliverybill.dart';
import 'package:floor_billing/SCREENs/FLOORBILL/floorBill.dart';
import 'package:floor_billing/SCREENs/ITEMDATA/itemsearch.dart';
import 'package:floor_billing/components/textfldCommon.dart';
import 'package:floor_billing/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

String date = "";
String cn = "";

class Menus {
  final String iconname;
  final String iconimg;
  Menus({required this.iconname, required this.iconimg});
}

class _MainHomeState extends State<MainHome> {
  List<Menus> l = [
    Menus(iconname: 'CREATE CUSTOMER', iconimg: 'assets/Cus.png'),
    Menus(iconname: 'FLOOR BILL', iconimg: 'assets/Fb.png'),
    // Menus(iconname: 'DELIVERY BILL', iconimg: 'assets/Del.png'),
    // Menus(iconname: 'FREE/ALOT SlOT', iconimg: 'assets/lock.png'),
    Menus(iconname: 'FLOORBILL HISTORY', iconimg: 'assets/lock.png'),
    Menus(iconname: 'ITEM SEARCH', iconimg: 'assets/lock.png'),
  ];

  @override
  void initState() {
    // TODO: implement initState
    date = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    super.initState();
  }

  getcname() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    cn = prefs.getString("cname")!;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print("width = ${size.width}");
    print("height = ${size.height}");
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          Navigator.of(context).pop(true);
          // Navigator.pushNamed(context, '/mainpage');
        }
      },
      child: SafeArea(
          child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.amber,
        // appBar: AppBar(
        //   backgroundColor: Colors.yellow,
        //   elevation: 0,
        // ),
        body: SafeArea(
            child: Center(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: l.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      child: Container(
                        height: 100,
                        width: size.width/1.2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.amber,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.fromARGB(255, 49, 83, 121),
                              Colors.black87,
                            ],
                            stops: [0.112, 0.789],
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Image.asset(
                                      l[index].iconimg.toString(),
                                    )),
                                SizedBox(
                                  width: 10,
                                ),
                                SizedBox(width: size.width/1.6,
                                  child: Text(
                                   "${l[index].iconname.toString()}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20),overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        if (index == 0) {
                          // Provider.of<Controller>(context, listen: false)
                          //     .getDeliveryBillList(0,context);
                          // Provider.of<Controller>(context, listen: false)
                          //     .getCustData(date, "XXXXXX", context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ADDCUSTOMER()),
                          );
                        } else if (index == 1) {
                          getcname();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeFloorBill()),
                          );
                        } else if (index == 2) {
                          Provider.of<Controller>(context, listen: false)
                              .getFBList(date.toString(), context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FloorBill()),
                          );
                        } else if (index == 3) {
                          Provider.of<Controller>(context, listen: false)
                              .clearSelectedBarcode(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ITEMSearch()),
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                );
              }),
        )),
      )),
    );
  }
}
