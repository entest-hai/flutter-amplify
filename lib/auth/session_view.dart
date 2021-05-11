import 'dart:convert';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_amplify/auth/models/user_model.dart';
import 'package:flutter_amplify/auth/session_cubit.dart';


class SessionView extends StatelessWidget {
  final User user;
  SessionView({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                BlocProvider.of<SessionCubit>(context).signOut();
              }),
        ],
        title: Text("User: ${user.username}"),
      ),
      body: SafeArea(
        child: Center(child: Text("Session ${user.username}"),),
      //     child: Stack(
      //   alignment: Alignment.bottomCenter,
      //   children: [
      //     MultiBlocProvider(
      //       providers: [
      //         BlocProvider(
      //             create: (context) => UserCTGCubit(
      //                 userCTGRepo: context.read<UserCTGRepository>())
      //               ..fetchUserCTG(user.id))
      //       ],
      //       child: UserHistoricalView(),
      //     )
      //   ],
      // )
      ),
    );
  }
}


// User Historical Data View
class UserHistoricalView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<UserCTGCubit, UserCTGState>(
              builder: (context, state) {
            if (state is UserCTGLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is UserCTGLoadedSuccess) {
              return ListView.builder(
                  itemCount: state.ctgs.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                          title: Text(
                              "username: ${state.ctgs[index].username} record Id: ${state.ctgs[index].id} mHR: ${state.ctgs[index].mHR} fHR: ${state.ctgs[index].fHR} acel: ${state.ctgs[index].acelsTime} decel: ${state.ctgs[index].decelsTime}")),
                    );
                  });
            }

            return Center(child: Text("Exception"));
          }),
        ),
        // ElevatedButton(onPressed: () {}, child: Text("Load Data")),
      ],
    );
  }
}

// CTG Data Model
class UserCTG {
  final String id;
  final String userId;
  final String username;
  final List<double> mHR;
  final List<double> fHR;
  final List<double> acelsTime;
  final List<double> acelsDur;
  final List<double> decelsTime;
  final List<double> decelsDur;
  final double basvar;
  final List<double> baseline;
  final double stv;
  final int createdTime;

  UserCTG(
      {this.id = "1234",
      this.userId = "123",
      this.username = "hai",
      this.mHR = const [60.1],
      this.fHR = const [150.1],
      this.acelsTime = const [1.1],
      this.acelsDur = const [2.1],
      this.decelsTime = const [1.1],
      this.decelsDur = const [2.1],
      this.basvar = 15.1,
      this.baseline = const [150.1],
      this.stv = 10.1,
      this.createdTime});

  factory UserCTG.fromJson(Map<String, dynamic> json) {
    final List<double> mHR = [];
    final List<double> fHR = [];
    final List<double> baseline = [];
    final List<double> acelsTime = [];
    final List<double> acelsDur = [];
    final List<double> decelsTime = [];
    final List<double> decelsDur = [];

    // parse mHR to double
    for (var mbeat in json['mHR']) {
      mHR.add(double.parse('$mbeat'));
    }

    // parse fHR to double
    for (var fbeat in json['fHR']) {
      fHR.add(double.parse('$fbeat'));
    }

    // parse baseline to double
    for (var beat in json['baseline']) {
      baseline.add(double.parse('$beat'));
    }

    // parse acels to double
    for (var acel in json['acelsTime']) {
      acelsTime.add(double.parse('$acel'));
    }
    for (var acel in json['acelsDuration']) {
      acelsDur.add(double.parse('$acel'));
    }

    // parse decels to double
    for (var dcel in json['decelsTime']) {
      decelsTime.add(double.parse('$dcel'));
    }
    for (var dcel in json['decelsDuration']) {
      decelsDur.add(double.parse('$dcel'));
    }

    final user = UserCTG(
      id: json['id'],
      userId: json['userid'],
      username: json['username'],
      mHR: mHR,
      fHR: fHR,
      acelsTime: acelsTime,
      acelsDur: acelsDur,
      decelsTime: decelsTime,
      decelsDur: decelsDur,
      basvar: json['basvar'] as double,
      baseline: baseline,
      stv: json['stv'] as double,
      createdTime: json['createdTime'] as int,
    );

    return user;
  }
}

// UserCTG Repository
class UserCTGRepository {
  Future<List<UserCTG>> fetchUserCTG(String userId) async {
    List<UserCTG> ctgs = [];

    try {
      String graphQLDocument = '''query listCTGs {
      listCTGs(filter: {userId: {eq: "$userId"}}) {
        items {
          acelsDuration
          acelsTime
          baseline
          basvar
          createdTime
          decelsDuration
          decelsTime
          fHR
          id
          mHR
          stv
          updatedAt
          userId
          username
        }
      }
    }''';

      var operation = Amplify.API
          .query(request: GraphQLRequest<String>(document: graphQLDocument));
      var response = await operation.response;
      var records = jsonDecode(response.data.toString())['listCTGs']["items"];
      for (var record in records) {
        ctgs.add(UserCTG.fromJson(record));
      }
      return ctgs;
    } catch (e) {
      print(e);
    }

    return [UserCTG()];
  }
}

// UserCTG State
abstract class UserCTGState {}

class UserCTGLoading extends UserCTGState {}

class UserCTGLoadedSuccess extends UserCTGState {
  final List<UserCTG> ctgs;
  UserCTGLoadedSuccess({this.ctgs});
}

class UserCTGLoadedFail extends UserCTGState {}

// UserCTG Cubit
class UserCTGCubit extends Cubit<UserCTGState> {
  final UserCTGRepository userCTGRepo;
  UserCTGCubit({this.userCTGRepo}) : super(UserCTGLoading());

  // Loading CTG
  Future<void> fetchUserCTG(String userId) async {
    emit(UserCTGLoading());

    try {
      // Query DB to get all CTGs of a given user
      final ctgs = await userCTGRepo.fetchUserCTG(userId);
      emit(UserCTGLoadedSuccess(ctgs: ctgs));
    } catch (e) {
      print(e);
      emit(UserCTGLoadedFail());
    }
  }
}