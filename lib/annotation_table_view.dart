import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// annotation cubit
import 'annotation_cubit.dart';
import 'annotation_state.dart';

class AnnotationTableView extends StatelessWidget {
  const AnnotationTableView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AnnotationCubit, AnnotationState>(
        builder: (context, state) {
          if (state is AnnotationAdded) {
            return ListView.separated(
              itemCount: state.annotations.length + 1,
              separatorBuilder: (context, index) => SizedBox(height: 0),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                      child: index == 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Time",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Duration",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Time",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text("    ")
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  Text(
                                      "${state.annotations[index - 1].startTime}"),
                                  Text(
                                      "${state.annotations[index - 1].duration}"),
                                  Text(
                                      "${state.annotations[index - 1].startTime}"),
                                  Icon(
                                    Icons.circle,
                                    color: Colors.blue,
                                  ),
                                ])),
                );
              },
            );
          }

          if (state is AnnotationInit) {
            return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Time",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Duration",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Time",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("    ")
                        ],
                      )),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
