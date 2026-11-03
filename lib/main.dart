import 'package:flutter/material.dart';

import 'article_model.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Aplikasi Berita',
      debugShowCheckedModeBanner: false,
      home: BeritaScreen(),
    );
  }
}

class BeritaScreen extends StatefulWidget {
  const BeritaScreen({super.key});

  @override
  State<BeritaScreen> createState() => _BeritaScreenState();
}

class _BeritaScreenState extends State<BeritaScreen> {
  late Future<List<Article>> _articlesFuture;
  final ScrollController _scrollController = ScrollController();
  bool showButton = false;

  @override
  void initState() {
    super.initState();
    _articlesFuture = ApiService().fetchArticles();

    _scrollController.addListener(() {
      setState(() {
        showButton = _scrollController.offset > 300;
      });
    });
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aplikasi Berita')),
      body: RefreshIndicator(
        onRefresh: ApiService().fetchArticles,
        child: FutureBuilder(
          future: _articlesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final articles = snapshot.data!;
              return ListView.builder(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return Card(
                    child: ListTile(
                      leading: article.urlToImage != null
                          ? Image.network(
                              article.urlToImage!,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.broken_image),
                            )
                          : const Icon(Icons.image),
                      title: Text(article.title),
                      subtitle: Text(
                        article.description ?? 'Tidak ada deskripsi',
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text("Terjadi Kesalahan"));
            }
          },
        ),
      ),
      floatingActionButton: showButton
          ? FloatingActionButton(
              onPressed: scrollToTop,
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}
