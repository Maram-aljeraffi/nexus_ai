import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nexus_ai/providers/profile_provider.dart';

class AddLinkView extends StatefulWidget {
  const AddLinkView({super.key});

  @override
  State<AddLinkView> createState() => _AddLinkViewState();
}

class _AddLinkViewState extends State<AddLinkView> {
  final _platformController = TextEditingController();
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // قائمة المنصات المقترحة
  final List<Map<String, dynamic>> _suggestedPlatforms = [
    {'name': 'GitHub', 'icon': Icons.code, 'color': 0xFF333333},
    {'name': 'LinkedIn', 'icon': Icons.business, 'color': 0xFF0077B5},
    {'name': 'Twitter', 'icon': Icons.chat, 'color': 0xFF1DA1F2},
    {'name': 'YouTube', 'icon': Icons.videocam, 'color': 0xFFFF0000},
    {'name': 'Instagram', 'icon': Icons.camera_alt, 'color': 0xFFE4405F},
    {'name': 'Facebook', 'icon': Icons.facebook, 'color': 0xFF1877F2},
    {'name': 'TikTok', 'icon': Icons.music_note, 'color': 0xFF000000},
    {'name': 'WhatsApp', 'icon': Icons.chat, 'color': 0xFF25D366},
    {'name': 'Telegram', 'icon': Icons.send, 'color': 0xFF26A5E4},
    {'name': 'Medium', 'icon': Icons.article, 'color': 0xFF00AB6C},
    {'name': 'Dev.to', 'icon': Icons.code, 'color': 0xFF0A0A0A},
    {'name': 'Stack Overflow', 'icon': Icons.question_answer, 'color': 0xFFF48024},
  ];

  @override
  void dispose() {
    _platformController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _addLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      final provider = Provider.of<ProfileProvider>(context, listen: false);
      provider.addSocialLink(
        _platformController.text.trim(),
        _urlController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تم إضافة رابط ${_platformController.text} بنجاح',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة رابط جديد'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF2196F3)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'أضف روابط حساباتك على منصات التواصل المختلفة',
                        style: TextStyle(color: Color(0xFF2196F3)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // نموذج الإضافة
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'معلومات الرابط',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // اسم المنصة
                    TextFormField(
                      controller: _platformController,
                      decoration: InputDecoration(
                        labelText: 'اسم المنصة',
                        hintText: 'مثال: Twitter, GitHub, LinkedIn',
                        prefixIcon: const Icon(Icons.link, color: Color(0xFF2196F3)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال اسم المنصة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // الرابط
                    TextFormField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'الرابط',
                        hintText: 'https://...',
                        prefixIcon: const Icon(Icons.http, color: Color(0xFF2196F3)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الرابط';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // منصات مقترحة
              const Text(
                'منصات مقترحة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestedPlatforms.length,
                  itemBuilder: (context, index) {
                    final platform = _suggestedPlatforms[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _platformController.text = platform['name'];
                        });
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Color(platform['color']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(platform['color']).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              platform['icon'],
                              size: 32,
                              color: Color(platform['color']),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              platform['name'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(platform['color']),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // زر الإضافة
              ElevatedButton(
                onPressed: _isLoading ? null : _addLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'إضافة الرابط',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}