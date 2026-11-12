import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart'; 
import '../bloc/egzersiz_cubit.dart';
import '../bloc/egzersiz_state.dart';
import 'egzersiz_detay_ekrani.dart';

class EgzersizAnaEkran extends StatefulWidget {
  const EgzersizAnaEkran({super.key});

  @override
  State<EgzersizAnaEkran> createState() => _EgzersizAnaEkranState();
}

class _EgzersizAnaEkranState extends State<EgzersizAnaEkran> {
  @override
  void initState() {
    super.initState();
    context.read<EgzersizCubit>().egzersizleriGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hareket Kütüphanesi"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ARAMA ÇUBUĞU ALANI
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              // ÇÖZÜM BURASI: Kullanıcı klavyede her harfe bastığında anlık arama yapar (Real-time search)
              onChanged: (yazilanKelime) {
                context.read<EgzersizCubit>().egzersizAra(yazilanKelime);
              },
              decoration: InputDecoration(
                hintText: "Hangi hareketi arıyorsun?",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          Expanded(
            child: RefreshIndicator(
              color: Colors.greenAccent,
              onRefresh: () async {
                await context.read<EgzersizCubit>().egzersizleriGetir();
              },
              child: BlocBuilder<EgzersizCubit, EgzersizState>(
                builder: (context, state) {
                  if (state is EgzersizLoading || state is EgzersizInitial) {
                    return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
                  } 
                  else if (state is EgzersizError) {
                    return ListView(
                      children: [
                        const SizedBox(height: 100),
                        Center(child: Text(state.mesaj, style: const TextStyle(color: Colors.red))),
                      ],
                    );
                  } 
                  else if (state is EgzersizLoaded) {
                    final liste = state.egzersizler;
                    
                    // Arama sonucu boş çıkarsa şık bir uyarı göster
                    if (liste.isEmpty) {
                      return const Center(
                        child: Text(
                          "Bu isimde bir hareket bulunamadı.", 
                          style: TextStyle(color: Colors.grey, fontSize: 16)
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: liste.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final hareket = liste[index];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 55,
                                height: 55,
                                child: hareket.imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: hareket.imageUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey.shade800,
                                          child: const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey.shade800,
                                          child: const Icon(Icons.fitness_center, color: Colors.greenAccent),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey.shade800,
                                        child: const Icon(Icons.fitness_center, color: Colors.greenAccent),
                                      ),
                              ),
                            ),
                            title: Text(hareket.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text("Detayları görmek için dokunun", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EgzersizDetayEkrani(hareket: hareket),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}