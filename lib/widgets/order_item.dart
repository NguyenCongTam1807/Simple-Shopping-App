import 'package:flutter/material.dart';
import 'package:shop_app/providers/order_provider.dart';
import 'package:intl/intl.dart';
import 'cart_item.dart';

class OrderItem extends StatefulWidget {
  final Order order;
  const OrderItem(this.order, {Key? key}) : super(key: key);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> with SingleTickerProviderStateMixin {
  bool _expanded = false;

  late AnimationController _expandController;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    _expandController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250)
    );
    _sizeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _expandController, curve: Curves.easeInOut));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.all(3),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black, width: 4)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ID: ${widget.order.id}"),
              Text(
                  DateFormat("hh:mm, dd/MM/yyyy").format(widget.order.dateTime))
            ],
          ),
          //if (_expanded)
            SizeTransition(
              sizeFactor: _sizeAnimation,
              child: ListView.builder(
                itemBuilder: (ctx, index) {
                  return CartItem(widget.order.cartProducts[index]);
                },
                itemCount: widget.order.cartProducts.length,
                shrinkWrap: true,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Price: \$${widget.order.totalPrice}"),
              const Spacer(),
              Text(
                "Show ${_expanded ? "less" : "more"}",
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(
                width: 4,
              ),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.grey.withOpacity(0.3),
                child: InkWell(
                  child: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 15,
                  ),
                  onTap: () {
                    setState(() {
                      _expanded = !_expanded;
                      if (_expanded) {
                        _expandController.forward();
                      } else {
                        _expandController.reverse();
                      }
                    });
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
