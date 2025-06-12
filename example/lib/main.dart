import 'package:flutter/material.dart';
import 'package:flutter_scrapper/mobile_scraper.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Mobile Scraper Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ScrapingExample(),
    );
  }
}

class ScrapingExample extends StatefulWidget {
  const ScrapingExample({super.key});

  @override
  State<ScrapingExample> createState() => _ScrapingExampleState();
}

class _ScrapingExampleState extends State<ScrapingExample> {
  final _urlController =
      TextEditingController(text: 'https://httpbin.org/html');
  final _results = <String>[];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _scrapeWebsite() async {
    if (_urlController.text.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _results.clear();
    });

    try {
      // Create scraper with custom configuration
      final scraper = MobileScraper(
        url: _urlController.text.trim(),
        config: const ScraperConfig(
          timeout: Duration(seconds: 10),
          userAgent: 'Flutter Mobile Scraper Example/1.0',
        ),
      );

      // Load the webpage
      await scraper.load();

      // Extract different types of content
      final titles = scraper.queryAll(tag: 'h1');
      final paragraphs = scraper.queryAll(tag: 'p');
      final links = scraper.queryWithRegex(pattern: r'href="([^"]+)"');

      setState(() {
        _results.addAll([
          '=== Page Titles (h1) ===',
          ...titles.map((title) => '• $title'),
          '',
          '=== Paragraphs ===',
          ...paragraphs.take(3).map((p) => '• $p'),
          '',
          '=== Links ===',
          ...links.take(5).map((link) => '• $link'),
        ]);
        _loading = false;
      });

      // Don't forget to dispose of resources
      scraper.dispose();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Scraper Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // URL Input
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Website URL',
                border: OutlineInputBorder(),
                hintText: 'https://example.com',
              ),
            ),
            const SizedBox(height: 16),

            // Scrape Button
            ElevatedButton(
              onPressed: _loading ? null : _scrapeWebsite,
              child: _loading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Scraping...'),
                      ],
                    )
                  : const Text('Scrape Website'),
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _error != null
                    ? Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Error: $_error',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : _results.isEmpty
                        ? const Center(
                            child: Text(
                              'Enter a URL and tap "Scrape Website" to see results',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final result = _results[index];
                              if (result.startsWith('===')) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    result,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                );
                              }
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text(result),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
