import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

import '../model/user.dart';

class UserViewModel extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  List<User> users = [];

  bool isLoading = true;

  final String _privatekey =
      '0x1f08ca5e13c9f1cefc321e68cc92f01953305588aaf4d44fbb58f6f86844d2d2';

  Web3Client web3client = Web3Client("http://localhost:7545", http.Client());

  @override
  void onReady() async {
    await getABI();
    await getCredentials();
    await getDeployedContract();
    super.onReady();
  }

  late ContractAbi _abiCode;
  late EthereumAddress _contractAddress;

  Future<void> getABI() async {
    String abiFile =
        await rootBundle.loadString('build/contracts/UsersContract.json');
    var jsonABI = jsonDecode(abiFile);
    _abiCode = ContractAbi.fromJson(jsonEncode(jsonABI['abi']), 'UserContract');
    _contractAddress =
        EthereumAddress.fromHex(jsonABI["networks"]["5777"]["address"]);
  }

  late EthPrivateKey _creds;
  Future<void> getCredentials() async {
    _creds = EthPrivateKey.fromHex(_privatekey);
  }

  late DeployedContract _deployedContract;
  late ContractFunction _createUser;
  late ContractFunction _deleteUser;
  late ContractFunction _users;
  late ContractFunction _userCount;

  Future<void> getDeployedContract() async {
    _deployedContract = DeployedContract(_abiCode, _contractAddress);
    _createUser = _deployedContract.function('createUser');
    _deleteUser = _deployedContract.function('deleteUser');
    _users = _deployedContract.function('users');
    _userCount = _deployedContract.function('userCount');
    await fetchUsers();
  }

  Future<void> fetchUsers() async {
    var data = await web3client.call(
      contract: _deployedContract,
      function: _userCount,
      params: [],
    );

    int totalTaskLen = data[0].toInt();
    users.clear();
    for (var i = 0; i < totalTaskLen; i++) {
      var temp = await web3client.call(
          contract: _deployedContract,
          function: _users,
          params: [BigInt.from(i)]);
      if (temp[1] != "") {
        users.add(
          User(
            id: (temp[0] as BigInt).toInt(),
            name: temp[1],
            surname: temp[2],
          ),
        );
      }
    }
    isLoading = false;
  }

  Future<void> addUser(String name, String surname) async {
    final response = await web3client.sendTransaction(
      _creds,
      chainId: 1337,
      Transaction.callContract(
        contract: _deployedContract,
        function: _createUser,
        parameters: [name, surname],
      ),
    );
    print(response);
    isLoading = true;
    fetchUsers();
  }

  Future<void> deleteUser(int id) async {
    await web3client.sendTransaction(
      _creds,
      chainId: 1337,
      Transaction.callContract(
        contract: _deployedContract,
        function: _deleteUser,
        parameters: [BigInt.from(id)],
      ),
    );
    isLoading = true;
    fetchUsers();
  }
}
