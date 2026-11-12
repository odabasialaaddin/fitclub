import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/antrenman_cubit.dart';
import '../bloc/antrenman_state.dart';

class RutinlerEkrani extends StatefulWidget {
  const RutinlerEkrani({super.key});

  @override
  State<RutinlerEkrani> createState() => _RutinlerEkraniState();
}

class _RutinlerEkraniState extends State<RutinlerEkrani> {
  @override
  void initState() {
    super.initState();
    context.read<AntrenmanCubit>().rutinleriGetir();
  }

  void _rutinSilOnayiIste(BuildContext context, String rutinId, String rutinAdi) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text("Rutini Sil", style: TextStyle(color: Colors.redAccent)),
          content: Text("$rutinAdi şablonunu silmek istediğinize emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                context.pop();
                context.read<AntrenmanCubit>().rutinSil(rutinId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Rutin başarıyla silindi."),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              child: const Text("Evet, Sil", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Antrenman Rutinlerim"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<AntrenmanCubit, AntrenmanState>(
        builder: (context, state) {
          if (state is AntrenmanLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            );
          } else if (state is AntrenmanError) {
            return Center(
              child: Text(
                state.mesaj,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          } else if (state is AntrenmanLoaded){
            final rutinler = state.rutinler;

            if (rutinler.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list_alt, size: 80, color: Colors.grey.shade700),
                    const SizedBox(height: 16),
                    const Text(
                      "Henüz hiç antrenman rutini oluşturmadın.\nYeni bir şablon eklemek için + butonuna bas!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rutinler.length,
              itemBuilder: (context, index) {
                final rutin = rutinler[index];
                
                return Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      rutin.rutinAdi,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "${rutin.hareketler.length} Hareket",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow, color: Colors.greenAccent),
                          onPressed: () {
                            context.push('/rutinler/aktif-rutin', extra: rutin);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _rutinSilOnayiIste(context, rutin.id, rutin.rutinAdi),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        onPressed: () {
          context.push('/rutinler/yeni-rutin');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}