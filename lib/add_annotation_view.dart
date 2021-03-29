import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// annotation form cubit
import 'annotation_form_cubit.dart';
import 'annotation_form_state.dart';

class AddAnnotationView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          _timeAnnotate(context),
          _durationAnnotate(context),
          _description(context),
          SizedBox(
            height: 20,
          ),
          _saveButton(context),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _saveButton(BuildContext context) {
    return BlocBuilder<FormCubit, AnnotationFormState>(
        builder: (context, state) {
      return ElevatedButton(
          onPressed: () {
            BlocProvider.of<FormCubit>(context).submitForm();
            Navigator.pop(context);
          },
          child: Text("Save"));
    });
  }

  Widget _timeAnnotate(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
          icon: Icon(Icons.av_timer), hintText: "Starting Time"),
      onChanged: (value) {
        // Todo: cubit update form
        BlocProvider.of<FormCubit>(context).updateStartTime(value);
        // print(value);
      },
    );
  }

  Widget _durationAnnotate(BuildContext context) {
    return TextFormField(
      decoration:
          InputDecoration(icon: Icon(Icons.timer_10), hintText: "Duration"),
      onChanged: (value) {
        // Todo: cubit update form
        BlocProvider.of<FormCubit>(context)
            .updateDuration(double.parse('$value'));
        // print(value);
      },
    );
  }

  Widget _description(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(icon: Icon(Icons.edit), hintText: "Note"),
      onChanged: (value) {
        // Todo: cubit update form
        BlocProvider.of<FormCubit>(context).updateDescription(value);
        // print(value);
      },
    );
  }
}
