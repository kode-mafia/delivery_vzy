import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_services.dart';

class OrderServices {
  FirebaseServices _services = FirebaseServices();

  Color statusColor(document) {
    if (document['orderStatus'] == 'Rejected') {
      return Colors.red;
    }
    if (document['orderStatus'] == 'Accepted') {
      return Colors.blueGrey[400];
    }
    if (document['orderStatus'] == 'Picked Up') {
      return Colors.pink[900];
    }
    if (document['orderStatus'] == 'On the way') {
      return Colors.deepPurpleAccent;
    }
    if (document['orderStatus'] == 'Delivered') {
      return Colors.green;
    }

    return Colors.orange;
  }

  Icon statusIcon(document) {
    if (document['orderStatus'] == 'Accepted') {
      return Icon(
        Icons.assignment_turned_in_outlined,
        color: statusColor(document),
      );
    }
    if (document['orderStatus'] == 'Picked Up') {
      return Icon(
        Icons.cases,
        color: statusColor(document),
      );
    }
    if (document['orderStatus'] == 'On the way') {
      return Icon(
        Icons.delivery_dining,
        color: statusColor(document),
      );
    }
    if (document['orderStatus'] == 'Delivered') {
      return Icon(
        Icons.shopping_bag_outlined,
        color: statusColor(document),
      );
    }

    return Icon(
      Icons.assignment_turned_in_outlined,
      color: statusColor(document),
    );
  }

  Widget statusContainer(document, context) {
    if (document['deliveryBoy']['name'].length > 1) {
      if (document['orderStatus'] == 'Accepted') {
        return Container(
          color: Colors.grey[300],
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40.0, 8, 40, 8),
            child: TextButton(
              style: ButtonStyle(
                  backgroundColor: ButtonStyleButton.allOrNull<Color>(
                      statusColor(document)) //:-(
                  ),
              child: Text(
                'Update Status to Picked Up',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                EasyLoading.show();
                _services
                    .updateStatus(id: document.id, status: 'Picked Up')
                    .then((value) {
                  EasyLoading.showSuccess('Order Status is now Picked Up');
                });
              },
            ),
          ),
        );
      }
    }
    if (document['orderStatus'] == 'Picked Up') {
      return Container(
        color: Colors.grey[300],
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 8, 40, 8),
          child: TextButton(
            style: ButtonStyle(
                backgroundColor: ButtonStyleButton.allOrNull<Color>(
                    statusColor(document)) //:-(
                ),
            child: Text(
              'Update Status to On The Way',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              EasyLoading.show();
              _services
                  .updateStatus(id: document.id, status: 'On the way')
                  .then((value) {
                EasyLoading.showSuccess('Order Status is now On the way');
              });
            },
          ),
        ),
      );
    }

    if (document['orderStatus'] == 'On the way') {
      return Container(
        color: Colors.grey[300],
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 8, 40, 8),
          child: TextButton(
            style: ButtonStyle(
                backgroundColor: ButtonStyleButton.allOrNull<Color>(
                    statusColor(document)) //:-(
                ),
            child: Text(
              'Deliver Order',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if (document['cod'] == true) {
                return showMyDialog(
                    'Receive Payment', 'Delivered', document.id, context);
              } else {
                EasyLoading.show();
                _services
                    .updateStatus(id: document.id, status: 'Delivered')
                    .then((value) {
                  EasyLoading.showSuccess('Order Status is now delivered');
                });
              }
            },
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[300],
      height: 30,
      width: MediaQuery.of(context).size.width,
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: ButtonStyleButton.allOrNull<Color>(Colors.green)),
        child: Text(
          'Order Completed',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {},
      ),
    );
  }

  void launchCall(number) async => await canLaunch(number)
      ? await launch(number)
      : throw 'Could not launch $number';

  void launchMap(lat, long, name) async {
    final availableMaps = await MapLauncher.installedMaps;

    await availableMaps.first.showMarker(
      coords: Coords(lat, long),
      title: name,
    );
  }

  showMyDialog(title, status, documentId, context) {
    OrderServices _orderServices = OrderServices();
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text('Make sure you have received payment'),
            actions: [
              TextButton(
                child: Text(
                  'RECEIVE',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  EasyLoading.show();
                  _services
                      .updateStatus(id: documentId, status: 'Delivered')
                      .then((value) {
                    EasyLoading.showSuccess('Order status is now Delivered');
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}

//hi , now completed about delivery status with customer app, vendor app and delivery boy app.
//next important things pending is , notification and payment gateway.
//coming videos I will try to upload about payment gateway with different type of
//payment integration like , Razorpay, Paypal and Stripe
//I hope I can do that successfully.. thanks.

