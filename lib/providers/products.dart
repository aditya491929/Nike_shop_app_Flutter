import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exceptions.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Nike Jacket',
    //   description:
    //       'The Nike Sportswear Windrunner Jacket updates our first running windbreaker with lightweight fabric made from recycled materials.',
    //   price: 89.99,
    //   imageUrl:
    //       'https://static.nike.com/a/images/t_PDP_864_v1/f_auto,b_rgb:f5f5f5/056bc3a3-6843-4afb-a785-7df1d0db9e47/sportswear-windrunner-hooded-jacket-VRVMZ4.png',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Nike Trousers',
    //   description:
    //       'The Nike Dri-FIT Strike Pants are made from stretchy, sweat-wicking fabric in a streamlined design, so nothing comes between you and the ball.Plus, zips on the lower legs allow for quick changes.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://static.nike.com/a/images/c_limit,w_592,f_auto/t_product_v1/8e2d822b-54e5-4f8a-bae2-921da0cd5987/dri-fit-strike-football-pants-VxmzGB.png',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Nike Air Max 90',
    //   description:
    //       'A variety of materials on the upper gives a modern look, while Max Air cushioning adds comfort to your journey.',
    //   price: 109.99,
    //   imageUrl:
    //       'https://static.nike.com/a/images/t_PDP_864_v1/f_auto,b_rgb:f5f5f5/a54ef0af-5cb0-4430-ae0e-33241625b0a0/air-max-90-shoe-hGrzDR.png',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'Nike Air Max Shoes',
    //   description:
    //       'Inspired by the early 2000s look, the Air Max Genome adds a fresh face to the Air Max house. Its techy upper features a mixture of materials including sleek no-sew skins, airy mesh and durable plastic details.',
    //   price: 149.99,
    //   imageUrl:
    //       'https://static.nike.com/a/images/c_limit,w_592,f_auto/t_product_v1/4518f08c-595a-435b-9b3b-231eff79e0f9/air-max-genome-shoe-lQ1nNw.png',
    // ),
  ];

  // var _showFavoritesOnly = false;

  String authToken;
  String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavourite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((pdt) => pdt.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  void updateUser(String token, String id) {
    this.userId = id;
    this.authToken = token;
    notifyListeners();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse('url');
    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (data == null) {
        return;
      }
      url = Uri.parse('url');
      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);
      data.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavourite:
              favouriteData == null ? false : favouriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse('url');
    try {
      final res = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        id: json.decode(res.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((product) => id == product.id);
    if (productIndex >= 0) {
      final url = Uri.parse('url');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('error');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse('url');
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Couldn\'t delete product!');
    }
    existingProduct = null;
  }
}
