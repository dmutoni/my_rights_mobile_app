import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_rights_mobile_app/models/lawyer.dart';
import 'package:my_rights_mobile_app/provider/lawyer_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class LawyerProfileScreen extends ConsumerWidget {
  final String lawyerId;

  const LawyerProfileScreen({
    super.key,
    required this.lawyerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lawyerAsync = ref.watch(lawyerByIdProvider(lawyerId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: lawyerAsync.when(
        data: (lawyer) {
          if (lawyer == null) {
            return const Center(
              child: Text(
                'Lawyer not found',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return _buildLawyerDetail(context, lawyer);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLawyerDetail(BuildContext context, Lawyer lawyer) {
    return CustomScrollView(
      slivers: [
        // Custom App Bar with back button
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          pinned: true,
          leadingWidth: 56,
          leading: Container(
            margin: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => context.pop(),
            ),
          ),
          title: const Text(
            'Legal Aid Lawyer',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        
        // Profile Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF81C784),
                    shape: BoxShape.circle,
                  ),
                  child: lawyer.profileImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            lawyer.profileImageUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          ),
                        )
                      : _buildDefaultAvatar(),
                ),
                
                const SizedBox(height: 20),
                
                // Name and Title
                Text(
                  lawyer.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  'Legal Aid Lawyer',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  lawyer.organization,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // About Section
                _buildSection(
                  'About',
                  _getAboutText(lawyer),
                ),
                
                const SizedBox(height: 24),
                
                // Credentials Section
                _buildCredentialsSection(lawyer),
                
                const SizedBox(height: 24),
                
                // Contact Section
                _buildContactSection(lawyer),
                
                const SizedBox(height: 32),
                
                // Call Button
                _buildCallButton(context, lawyer),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF81C784),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCredentialsSection(Lawyer lawyer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Credentials',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Bar Admission
        _buildCredentialItem(
          'Bar Admission',
          'Rwanda Bar Association',
        ),
        
        const SizedBox(height: 12),
        
        // Education
        _buildCredentialItem(
          'Education',
          'LL.B, University of Rwanda',
        ),
        
        const SizedBox(height: 12),
        
        // Languages
        _buildCredentialItem(
          'Languages',
          'Kinyarwanda, English, French',
        ),
      ],
    );
  }

  Widget _buildCredentialItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(Lawyer lawyer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Phone
        if (lawyer.phoneNumber != null)
          _buildContactItem(
            Icons.phone_outlined,
            lawyer.phoneNumber!,
            () => _launchPhone(lawyer.phoneNumber!),
          ),
        
        const SizedBox(height: 16),
        
        // Email
        if (lawyer.email != null)
          _buildContactItem(
            Icons.email_outlined,
            lawyer.email!,
            () => _launchEmail(lawyer.email!),
          ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton(BuildContext context, Lawyer lawyer) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: lawyer.phoneNumber != null 
            ? () => _launchPhone(lawyer.phoneNumber!)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Call',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAboutText(Lawyer lawyer) {
    // Generate a realistic about text based on lawyer data
    final experience = lawyer.experienceYears ?? 5;
    final specializations = lawyer.specializations?.join(', ') ?? 'legal assistance';
    
    return '${lawyer.name} is a dedicated legal aid lawyer with $experience+ years of experience in providing legal assistance to underserved communities in Rwanda. She specializes in $specializations, and human rights advocacy.';
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}