import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:utmccos/Model/GetX/Controller/duplicate_controller.dart';
import 'package:utmccos/Model/Tools/Constant/const.dart';
import 'package:utmccos/Model/Widget/widget.dart';
import 'package:utmccos/View/CartScreen/CheckoutScreen/check_screen.dart';
import 'package:utmccos/Controller/CartController/bloc/cart_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

CartBloc? cartBloc;
//Cart Screen UI based on the CartBloc state. It displays product listings, total price, 
//and a checkout button for a filled cart.
//It also handles loading states, errors, and empty cart scenarios
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void dispose() {
    cartBloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = CartBloc();
        bloc.add(CartStart());
        cartBloc = bloc;
        return bloc;
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final duplicateController = Get.find<DuplicateController>();
          final colors = duplicateController.colors;
          final textStyle = duplicateController.textStyle;
          final uiDuplicate = duplicateController.uiDuplicate;
          if (state is CartSuccess) {
            final productList = state.productList;
            final String totalPrice = state.totalPrice;
            return DuplicateTemplate(
                colors: colors,
                textStyle: textStyle,
                title:"Cart Screen",
                child: Stack(
                    children: [
                      Positioned.fill(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 120),
                          physics: uiDuplicate.defaultScroll,
                          itemCount: productList.length,
                          itemBuilder: (context, index) {
                            final product = productList[index];
                            return HorizontalProductView(
                                colors: colors,
                                margin: const EdgeInsets.only(
                                    top: 15, right: 10, bottom: 15, left: 10),
                                product: product,
                                widget: CupertinoButton(
                                    child: Icon(
                                      Icons.delete,
                                      color: colors.whiteColor,
                                    ),
                                    onPressed: () async {
                                      //if user clicks delete icon
                                      final bool isDeleted =
                                          await duplicateController
                                              .cartFunctions
                                              .deleteProduct(index: index);
                                      if (isDeleted) {
                                        Get.snackbar("Delete", "",
                                            messageText: Text(
                                              "Product removed successfully",
                                              style: textStyle.bodyNormal,
                                            ),
                                            backgroundColor: colors.gray);
                                        cartBloc!.add(CartStart());
                                      }
                                    }),
                                textStyle: textStyle);
                          },
                        ),
                      ),
                      CartBottomItem(
                        colors: colors,
                        //goto checkout screen
                        navigateName: "Checkout",
                        widget: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total price",
                              style: textStyle.bodySmall
                                  .copyWith(color: colors.captionColor),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: 200,
                              child: AutoSizeText(
                                "RM $totalPrice",
                                style:
                                    textStyle.titleLarge.copyWith(fontSize: 20),
                                maxFontSize: 25,
                                minFontSize: 16,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        textStyle: textStyle,
                        callback: () {
                          Get.to(CheckoutScreen(
                              productList: productList,
                              totalPrice: totalPrice));
                        },
                      ),
                    ],
                  ));
          } else if (state is CartLoading) {
            return const CustomLoading();
          } else if (state is CartError) {
            return AppException(
              callback: () {
                cartBloc!.add(CartStart());
              },
            );
          } else if (state is CartEmpty) {
            return EmptyScreen(
              colors: colors,
              textStyle: textStyle,
              lottieName: emptyCartLottie,
              content: "your cart is empty , try to add something",
              title: "My cart",
            );
          }
          return Container();
        },
      ),
    );
  }
}
