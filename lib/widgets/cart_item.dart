import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/products_provider.dart';

class CartItem extends StatelessWidget {
  final MapEntry<String, CartProduct> cartProduct;
  const CartItem(this.cartProduct, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final product = productsProvider.products
        .firstWhere((element) => element.id == cartProduct.key);
    final productInCart = cartProduct.value;
    final cartProvider = Provider.of<CartProvider>(context);
    return Dismissible(
      key: ValueKey(cartProduct.key),
      onDismissed: (_) {
        cartProvider.removeAllFromCart(product);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Removed item"), action: SnackBarAction(label: 'UNDO',
            onPressed: () {
              cartProvider.undoRemoveAllFromCart(MapEntry(cartProduct.key, productInCart));
            },
        ),));
      },
      child: Card(
        elevation: 4,
        child: ListTile(
          leading: SizedBox(
            width: 60,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (ctx, _, __) {
                return const SizedBox();
            }
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${productInCart.price} x ${productInCart.quantity} =",
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 20,),
              Text(
                "\$${productInCart.price * productInCart.quantity}",
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
