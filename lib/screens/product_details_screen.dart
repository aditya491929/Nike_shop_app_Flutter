import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';
import './cart_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final String productId = ModalRoute.of(context).settings.arguments;
    final product = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);

    return Scaffold(
      appBar: AppBar(
        title: Image.network(
          'https://www.freepnglogos.com/uploads/nike-logo-6.jpg',
          fit: BoxFit.cover,
          height: 35,
        ),
        backgroundColor: Colors.white,
        actions: [
          Consumer<Cart>(
            builder: (ctx, cartData, ch) => Badge(
              child: ch,
              value: cartData.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                child: Hero(
                  tag: product.id,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    height: 500,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                width: double.infinity,
                child: Row(
                  children: [
                    Text(
                      product.title,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lato',
                      ),
                    ),
                    Spacer(),
                    Chip(
                      label: Text(
                        '\$ ${product.price}',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      backgroundColor: Theme.of(context).accentColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Text(
                  product.description,
                  style: TextStyle(fontSize: 18),
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Provider.of<Cart>(context, listen: false).addItem(
            product.id,
            product.price,
            product.title,
          );
        },
        icon: Icon(Icons.shopping_cart),
        label: Text("Add to cart"),
      ),
    );
  }
}
