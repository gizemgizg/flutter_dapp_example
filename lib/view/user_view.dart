import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../viewmodel/user_viewmodel.dart';

class UserView extends StatelessWidget {
  UserView({super.key});
  final userVM = Get.put(UserViewModel());
  final userViewModel = Get.find<UserViewModel>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: userViewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {},
              child: Obx(()=>
               ListView.builder(
                  itemCount: userViewModel.users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(userViewModel.users[index].name),
                      subtitle: Text(userViewModel.users[index].surname),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          userViewModel.deleteUser(userViewModel.users[index].id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('New User'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: userViewModel.nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter name',
                      ),
                    ),
                    TextField(
                      controller: userViewModel.surnameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter surname',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      userViewModel.addUser(
                        userViewModel.nameController.text,
                        userViewModel.nameController.text,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
