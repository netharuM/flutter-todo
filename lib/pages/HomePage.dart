import 'package:flutter/material.dart';
import 'package:todo/DBHandler.dart';
import 'package:todo/pages/TaskEditor.dart';
import 'package:todo/widgets/Buttons.dart';
import 'package:todo/widgets/TaskCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DBHandler _dbHandler = DBHandler.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // page
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 32, bottom: 16, left: 12),
                    width: 50,
                    child: Image(
                      image: AssetImage('assets/images/icon.png'),
                    ),
                  ),
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: NoGlowBehaviour(),
                      child: FutureBuilder(
                        initialData: [],
                        future: _dbHandler.getTasks(),
                        builder: (context, AsyncSnapshot snapshot) {
                          return ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return TaskCard(
                                task: snapshot.data[index],
                                onTap: (task) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskEditingPage(
                                        task: task,
                                      ),
                                    ),
                                  ).then((value) {
                                    setState(() {});
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // add button
            Positioned(
              right: 16,
              bottom: 30,
              child: AddButton(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskEditingPage(),
                      )).then(
                    (value) {
                      setState(() {});
                      // redirecting to edit description and those things
                      if (value != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskEditingPage(
                              task: value,
                            ),
                          ),
                        ).then((value) {
                          setState(() {});
                        });
                      }
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NoGlowBehaviour extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
