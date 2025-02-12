import 'package:flutter/material.dart';
import '../../controller/app_manager.dart';
import '../../utils/multivaluelistenablebuilder/mvlb.dart';

class ActionsWidget extends StatefulWidget {
  const ActionsWidget({super.key});

  @override
  State<ActionsWidget> createState() => _ActionsWidgetState();
}

class _ActionsWidgetState extends State<ActionsWidget> {
  ValueNotifier<bool> expanded = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final am = AppManager();
    // var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    //var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    return MultiValueListenableBuilder(
      valueListenables: [expanded, am.appActions],
      builder: (context, value, child){
        return !value[0] ?
          am.appActions.value.isEmpty ? const SizedBox() :
          ListTile(
            leading: Icon(
              Icons.file_download,
              color: Colors.white,
            ),
            title: Text(
              'Downloading/Uploading ${am.appActions.value.length} files',
              style: TextStyle(
                color: Colors.white,
                fontSize: normalSize,
              ),
            ),
            onTap: (){
              expanded.value = !expanded.value;
            },
          ) :
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            height: height * 0.3,
            child: ListView.builder(
              itemCount: am.appActions.value.length + 1,
              itemBuilder: (context, index){
                return index == 0 ?
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: height * 0.015,
                      ),
                      onPressed: (){
                        expanded.value = !expanded.value;
                      },
                    )
                    : ListTile(
                  title: Text(
                    am.appActions.value[index],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: normalSize,
                    ),
                  ),
                );
              },
            ),

          );
      },
    );

  }
}
