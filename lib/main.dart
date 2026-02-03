import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const SocialMediaContentGeneratorApp());
}

class SocialMediaContentGeneratorApp extends StatelessWidget {
  const SocialMediaContentGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media Content Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const GeneratorPage(),
    );
  }
}

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final TextEditingController _topicController = TextEditingController();
  String selectedPlatform = 'instagram';
  String selectedTone = 'friendly';
  bool includeHashtags = true;
  bool includeEmojis = true;
  String generatedContent = '';
  final List<String> history = [];

  final List<String> platforms = [
    'instagram',
    'twitter',
    'facebook',
    'linkedin',
  ];
  final List<String> tones = [
    'professional',
    'friendly',
    'humorous',
    'inspirational',
    'urgent',
  ];

  void generatePost() {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a topic')));
      return;
    }

    final hashtags = includeHashtags
        ? '\n\n#${topic.replaceAll(' ', '')} #innovation #trending'
        : '';

    final Map<String, Map<String, String>> posts = {
      'instagram': {
        'friendly':
            "Hey there! 👋 We've got something super cool to share about $topic! 😉$hashtags",
        'professional':
            "Exciting news! We're thrilled to announce our new $topic!$hashtags",
        'humorous':
            "Breaking news: $topic is here and it's AMAZING! 😂$hashtags",
        'inspirational':
            "Dream bigger. Achieve more. ✨ Our new $topic will help you reach new heights.$hashtags",
        'urgent': "LAST CHANCE! 🚨 Our $topic offer ends soon!$hashtags",
      },
      'twitter': {
        'friendly': "BIG news about $topic! 🎉 Stay tuned!$hashtags",
        'professional':
            "Announcing: Our innovative $topic is now available!$hashtags",
        'humorous': "$topic is HERE! 🤯$hashtags",
        'inspirational':
            "\"The only way to do great work is to love what you do.\" $hashtags",
        'urgent': "⏰ Time's running out! $topic offer ends soon!$hashtags",
      },
      'facebook': {
        'friendly': "Guess what, friends? 😊 We're launching $topic!$hashtags",
        'professional': "We're proud to introduce our new $topic.$hashtags",
        'humorous': "$topic has arrived and it's SO GOOD. 😂$hashtags",
        'inspirational':
            "Every journey begins with a single step. Here's $topic! ✨$hashtags",
        'urgent': "🚨 Attention! Our $topic promotion ends tonight!$hashtags",
      },
      'linkedin': {
        'friendly': "Thrilled to announce $topic!$hashtags",
        'professional': "Excited to share our new $topic launch!$hashtags",
        'humorous': "BREAKING: $topic is HERE! 😄$hashtags",
        'inspirational':
            "Progress isn't perfection. $topic helps you grow. #growth$hashtags",
        'urgent': "Final opportunity: $topic pricing ends this week!$hashtags",
      },
    };

    String content = posts[selectedPlatform]?[selectedTone] ?? '';

    if (!includeEmojis) {
      content = content.replaceAll(
        RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true),
        '',
      );
      content = content.replaceAll(
        RegExp(r'[\u{1F300}-\u{1F5FF}]', unicode: true),
        '',
      );
    }

    setState(() {
      generatedContent = content;
      // add to history (most recent first), avoid duplicate consecutive entries
      if (content.isNotEmpty) {
        if (history.isEmpty || history.first != content) {
          history.insert(0, content);
          // keep history to a reasonable size
          if (history.length > 100) history.removeRange(100, history.length);
        }
      }
    });
  }

  Future<void> copyToClipboard() async {
    if (generatedContent.isNotEmpty) {
      final text = generatedContent;
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
    }
  }

  Future<void> downloadTextFile() async {
    if (generatedContent.isNotEmpty) {
      await Share.share(generatedContent, subject: 'Your Social Media Post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.indigo),
                  child: Text(
                    'Generated History',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: history.isEmpty
                      ? const Center(child: Text('No generated posts yet'))
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final item = history[index];
                            return ListTile(
                              title: Text(
                                item.split('\n').first.length > 60
                                    ? '${item.split('\n').first.substring(0, 60)}...'
                                    : item.split('\n').first,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text('${item.length} chars'),
                              onTap: () {
                                setState(() {
                                  generatedContent = item;
                                });
                                Navigator.of(context).pop();
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  setState(() => history.removeAt(index));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Removed from history'),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear History'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: history.isEmpty
                        ? null
                        : () {
                            setState(() => history.clear());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('History cleared')),
                            );
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('AI Social Media Content Generator'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Color.fromRGBO(255, 255, 255, 0.95),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _topicController,
                    decoration: InputDecoration(
                      labelText: 'Post Topic',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Target Platform:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children: platforms.map((platform) {
                      final isSelected = platform == selectedPlatform;
                      return ChoiceChip(
                        label: Text(platform.toUpperCase()),
                        selected: isSelected,
                        selectedColor: Colors.indigo,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) =>
                            setState(() => selectedPlatform = platform),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Content Tone:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children: tones.map((tone) {
                      final isSelected = tone == selectedTone;
                      return ChoiceChip(
                        label: Text(tone[0].toUpperCase() + tone.substring(1)),
                        selected: isSelected,
                        selectedColor: Colors.indigo,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() => selectedTone = tone),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('Include Hashtags'),
                    value: includeHashtags,
                    onChanged: (val) => setState(() => includeHashtags = val),
                  ),
                  SwitchListTile(
                    title: const Text('Include Emojis'),
                    value: includeEmojis,
                    onChanged: (val) => setState(() => includeEmojis = val),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Generate Post'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      onPressed: generatePost,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Generated Post:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.indigo.shade100),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      generatedContent.isEmpty
                          ? 'Your generated content will appear here...'
                          : generatedContent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy'),
                          onPressed: generatedContent.isEmpty
                              ? null
                              : copyToClipboard,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.indigo,
                            side: const BorderSide(color: Colors.indigo),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                          onPressed: generatedContent.isEmpty
                              ? null
                              : downloadTextFile,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.indigo,
                            side: const BorderSide(color: Colors.indigo),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
