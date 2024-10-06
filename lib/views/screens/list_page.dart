import 'dart:async';

import 'package:flutter/material.dart';
import 'package:list_client_flutter/data/model/client.dart';
import 'package:list_client_flutter/views/screens/cadastro_page.dart';
import 'package:list_client_flutter/logic/client_provider.dart';
import 'package:list_client_flutter/views/widgets/client_card.dart';
import 'package:provider/provider.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Horário"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Pesquisar',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  clientProvider.searchClients(value);
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder(
          future: clientProvider.fetchClients(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar horários.'));
            }
            return Consumer<ClientProvider>(
                builder: (context, provider, child) {
              List<Client> listClient = provider.clients;
              if (listClient.isEmpty) {
                return const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Text('Nenhum horário encontrado.'),
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(top: 5),
                child: ListView.builder(
                  itemCount: listClient.length,
                  itemBuilder: (context, index) {
                    Client client = listClient[index];
                    return ClientCard(
                      client: listClient[index],
                      onDelete: () async {
                        provider.removeClients(int.parse(client.id));
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CadastroPage(
                              clientEdit: client,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            });
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CadastroPage(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
