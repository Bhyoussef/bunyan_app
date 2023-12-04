import 'package:bunyan/models/enterprise.dart';
import 'package:flutter/material.dart';

class ImageCard extends StatefulWidget {
  final EnterpriseModel product;



  const ImageCard({Key key, this.product}) : super(key: key);

  @override
  _ImageCardState createState() => _ImageCardState();
}

class _ImageCardState extends State<ImageCard> {
  int _selectedImageIndex = 0;

  List<String> _images = [    'https://picsum.photos/250?image=9',
    'https://picsum.photos/250?image=15',    'https://picsum.photos/250?image=25',
    'https://picsum.photos/250?image=30',  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // TODO: Add functionality to change main image
            },
            child: Image.network(
              _images[_selectedImageIndex],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < _images.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageIndex = i;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedImageIndex == i
                            ? Colors.blue
                            : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(_images[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Product',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '\$100',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
