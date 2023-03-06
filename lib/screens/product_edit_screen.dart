import 'package:flutter/material.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';

class ProductEditScreen extends StatefulWidget {
  final Product? product;
  const ProductEditScreen({this.product, Key? key}) : super(key: key);

  static const routeName = 'edit_product_screen';

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _newProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');

  bool finishedHttpRequest = true;

  @override
  void initState() {
    _imageUrlController.text = widget.product?.imageUrl ?? "";
    super.initState();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  bool _submitForm() {
    if (_formKey.currentState?.validate() == false) {
      return false;
    }
    _formKey.currentState?.save();
    return true;
  }

  Future<void> _afterSubmitForm(
      ProductsProvider productsProvider, int productIndex) async {
    setState(() {
      finishedHttpRequest = false;
    });
    if (widget.product == null) {
      try {
        await productsProvider.addProduct(_newProduct);
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Added successfully")));
        }
      } catch (err) {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("Oops"),
                content: const Text(
                    "Something is wrong, please try adding again later"),
                actions: [
                  TextButton(
                    child: const Text(
                      "OK",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      } finally {
        setState(() {
          finishedHttpRequest = true;
        });
      }
    } else {
      try {
        await productsProvider
            .updateProduct(widget.product?.id ?? "", _newProduct)
            .then((_) {
          setState(() {
            finishedHttpRequest = true;
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Edited successfully")));
        });
      } catch (err) {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("Oops"),
                content: const Text(
                    "Something is wrong, please try editing again later"),
                actions: [
                  TextButton(
                    child: const Text(
                      "OK",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      } finally {
        setState(() {
          finishedHttpRequest = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ProductsProvider productsProvider = Provider.of<ProductsProvider>(context);
    List<Product> products = productsProvider.products;
    int productIndex =
        products.indexWhere((element) => element.id == widget.product?.id);
    double? tempPrice = 0.0;
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.product == null ? "Add" : "Edit"} Product'),
          actions: [
            IconButton(
              onPressed: () async {
                if (_submitForm()) {
                  _afterSubmitForm(productsProvider, productIndex);
                }
              },
              icon: const Icon(Icons.save),
            )
          ],
        ),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    initialValue: widget.product?.title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    },
                    onSaved: (title) {
                      _newProduct.title = title ?? "";
                    },
                    onChanged: (value) {
                      _newProduct.title = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please provide a title";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    initialValue: widget.product?.price.toString() ?? "",
                    decoration: const InputDecoration(labelText: 'Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _priceFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    onSaved: (price) {
                      _newProduct.price = double.parse(price ?? "0");
                    },
                    onChanged: (value) {
                      tempPrice = double.tryParse(value);
                    },
                    onEditingComplete: () {
                      _newProduct.price = tempPrice ?? 0.0;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please provide a price";
                      }
                      if (double.tryParse(value) == null) {
                        return "Invalid price";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: widget.product?.description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    focusNode: _descriptionFocusNode,
                    onSaved: (description) {
                      _newProduct.description = description ?? "";
                    },
                    onChanged: (value) {
                      _newProduct.description = value;
                    },
                  ),
                  Column(
                    children: <Widget>[
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        onSaved: (imageUrl) {
                          _newProduct.imageUrl = imageUrl ?? "";
                        },
                        onChanged: (value) {
                          _newProduct.imageUrl = value;
                        },
                        onEditingComplete: () {
                          setState(() {});
                        },
                      ),
                      Container(
                        height: 150,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                        child: _imageUrlController.text.isEmpty
                            ? const Text('Enter a URL')
                            : Image.network(
                                _imageUrlController.text,
                                fit: BoxFit.cover,
                              ),
                      ),
                      FilledButton(
                          onPressed: () {
                            if (_submitForm()) {
                              _afterSubmitForm(productsProvider, productIndex);
                            }
                          },
                          child: const Text("Submit Form"))
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!finishedHttpRequest)
            Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ]));
  }
}
