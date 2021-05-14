import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vendorapp_mulitvendorapp/screens/edit_view_product.dart';
import 'package:vendorapp_mulitvendorapp/services/firebase_services.dart';

class PublishedProducts extends StatelessWidget {
  const PublishedProducts({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseServices _services=FirebaseServices();

    return Container(
      child: StreamBuilder(
        stream: _services.products.where('published', isEqualTo: true).snapshots(),
        builder: (context,snapshot){
          if(snapshot.hasError){
            return Text('Something went wrong');
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator() ,
            );
          }
          return SingleChildScrollView(
            child: FittedBox(
              child: DataTable(
                  showBottomBorder: true,
                  dataRowHeight: 60,
                  headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                  columns: [
                    DataColumn(label: Expanded( child: Text('Product '),),),
                    DataColumn(label: Text('Image'),),
                    DataColumn(label: Text('Info'),),
                    DataColumn(label: Text('Actions'),),
                  ],
                  rows:_productDetails(snapshot.data,context)
              ),
            ),
          );
        },
      ),
    );
  }
  List<DataRow> _productDetails(QuerySnapshot snapshot,context){
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document){
      if(document!=null){
        return DataRow(
          cells: [
            DataCell(
              Container(
                child:ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Expanded(child: Text('Name: ', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),)),
                      Expanded(child: Text(document.data()['productName'], style: TextStyle(fontSize: 15),)),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Text(document.data()['SKU: '],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),
                      Text(document.data()['sku'],style: TextStyle(fontSize: 12),),
                    ],
                  ),
                ),
              ),
            ),
            DataCell(
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Row(
                    children: [
                      Image.network(document.data()['productImage'],width: 50,),

                    ],
                  ),
                ),
              ),
            ),
            DataCell(
              IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder:(context)=> EditViewProduct(
                    productId: document.data()['productId'],
                  )));
                },
                icon: Icon(Icons.info_outline),
              ),
            ),
            DataCell(
              popUpButton(document.data()),
            ),
          ],
        );
      }
    }).toList();
    return newList;
  }
  Widget popUpButton(data,{BuildContext context}){
    FirebaseServices _services =FirebaseServices();

    return PopupMenuButton<String>(
        onSelected: (String value){
          if(value=='unpublish'){
            _services.unpublishProduct(
              id:data['productId'],
            );
          }
        },

        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem(
              value: 'unpublish',
              child: ListTile(
                leading: Icon(Icons.check),
                title: Text('Un Publish'),
              )
          ),
        ]);
  }
}
