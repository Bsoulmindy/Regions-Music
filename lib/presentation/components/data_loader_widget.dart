import 'package:flutter/material.dart';

class DataLoaderWidget<T> extends StatelessWidget {
  const DataLoaderWidget(
      {super.key,
      required this.future,
      required this.onSuccess,
      this.loadingIndicator,
      this.onError});

  final Future<T> future;
  final Widget Function(BuildContext context, T data) onSuccess;
  final Widget Function(BuildContext context, Object? error)? onError;
  final Widget? loadingIndicator;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // The future is loading
          return Scaffold(
            body: loadingIndicator ??
                const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // The future failed
          return onError != null
              ? onError!(context, snapshot.error)
              : Center(
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error,
                      size: 32,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text(
                        "Something went wrong : ${snapshot.error.toString()}",
                        maxLines: 5,
                        style: const TextStyle(fontSize: 20),
                      ),
                    )
                  ],
                ));
        } else if (snapshot.hasData) {
          // Data is successfully loaded
          return onSuccess(context, snapshot.data!);
        } else {
          // No data were found
          return const Center(child: Text('No items were found!'));
        }
      },
    );
  }
}
