import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
    {'name': 'GitHub', 'icon': Icons.code, 'color': const Color(0xFF181717)},
    {'name': 'LinkedIn', 'icon': Icons.business, 'color': const Color(0xFF0077B5)},
    {'name': 'Twitter', 'icon': Icons.chat, 'color': const Color(0xFF1DA1F2)},
    {'name': 'YouTube', 'icon': Icons.videocam, 'color': const Color(0xFFFF0000)},
    {'name': 'Instagram', 'icon': Icons.camera_alt, 'color': const Color(0xFFE4405F)},
    {'name': 'Facebook', 'icon': Icons.facebook, 'color': const Color(0xFF1877F2)},
    {'name': 'TikTok', 'icon': Icons.music_note, 'color': const Color(0xFF000000)},
    {'name': 'WhatsApp', 'icon': Icons.chat, 'color': const Color(0xFF25D366)},
    {'name': 'Telegram', 'icon': Icons.send, 'color': const Color(0xFF26A5E4)},
    {'name': 'Medium', 'icon': Icons.article, 'color': const Color(0xFF00AB6C)},
    {'name': 'Dev.to', 'icon': Icons.code, 'color': const Color(0xFF0A0A0A)},
    {'name': 'Stack Overflow', 'icon': Icons.question_answer, 'color': const Color(0xFFF48024)},
  ];

  @override
  void dispose() {
    _platformController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _addLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await Future.delayed(const Duration(milliseconds: 500));

      final provider = Provider.of<ProfileProvider>(context, listen: false);
      provider.addSocialLink(
        _platformController.text.trim(),
        _urlController.text.trim(),
      );

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '✅ تم إضافة رابط ${_platformController.text} بنجاح',
                  style: GoogleFonts.poppins(),
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
        title: Text(
          'إضافة رابط جديد',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[50]!, Colors.white],
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
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'أضف روابط حساباتك على منصات التواصل المختلفة',
                        style: GoogleFonts.poppins(color: const Color(0xFF4F46E5)),
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
                    Text(
                      'معلومات الرابط',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // اسم المنصة
                    _buildTextField(
                      controller: _platformController,
                      label: 'اسم المنصة',
                      hint: 'مثال: Twitter, GitHub, LinkedIn',
                      icon: Icons.link,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال اسم المنصة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // الرابط
                    _buildTextField(
                      controller: _urlController,
                      label: 'الرابط',
                      hint: 'https://...',
                      icon: Icons.http,
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
              Text(
                'منصات مقترحة',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
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
                          color: platform['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: platform['color'].withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              platform['icon'],
                              size: 32,
                              color: platform['color'],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              platform['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: platform['color'],
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
                  backgroundColor: const Color(0xFF7C3AED),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'إضافة الرابط',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF4F46E5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(),
        validator: validator,
      ),
    );
  }
}