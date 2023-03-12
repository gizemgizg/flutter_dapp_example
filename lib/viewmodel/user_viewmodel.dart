import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

import '../model/user.dart';

class UserViewModel extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  List<User> users = [];
  final String _rpcUrl = 'http://127.0.0.1:7545';

  final String _wsUrl = 'ws://127.0.0.1:7545';
  bool isLoading = true;

  final String _privatekey = 'f8121dae2e22e80a7e66011af99xxxxx.....';

  late Web3Client _web3cient;

  @override
  void onReady() async {
    _web3cient = Web3Client(
      _rpcUrl,
      http.Client(),
      socketConnector: () {
        return IOWebSocketChannel.connect(_wsUrl).cast<String>();
      },
    );
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
    var data = await _web3cient.call(
      contract: _deployedContract,
      function: _userCount,
      params: [],
    );

    int totalTaskLen = data[0].toInt();
    users.clear();
    for (var i = 0; i < totalTaskLen; i++) {
      var temp = await _web3cient.call(
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

  Future<void> addUser(String title, String description) async {
    await _web3cient.sendTransaction(
      _creds,
      Transaction.callContract(
        contract: _deployedContract,
        function: _createUser,
        parameters: [title, description],
      ),
    );
    isLoading = true;
    fetchUsers();
  }

  Future<void> deleteUser(int id) async {
    await _web3cient.sendTransaction(
      _creds,
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
