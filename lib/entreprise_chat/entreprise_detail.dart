import 'package:flutter/material.dart';
import '../models/enterprise.dart';
import 'entreprise_list.dart';


class EnterpriseListPage extends StatelessWidget {
  final List<EnterpriseModel> enterpriseList; // list of enterprise models

  const EnterpriseListPage({Key key, @required this.enterpriseList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enterprise List'),
      ),
      body: ListView.builder(
        itemCount: enterpriseList.length,
        itemBuilder: (context, index) {
          final enterprise = enterpriseList[index];
          return ListTile(
            title: Text(enterprise.name),
            subtitle: Text(enterprise.description),
            leading: Image.network(enterprise.image),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnterpriseDetailPage(
                    enterprise: enterprise,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
