class ImprovementTrendsSection extends StatelessWidget {
  const ImprovementTrendsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Improvement Trends',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        
        // Zaman dilimi seçimi (7 Days, 30 Days, 90 Days)
        Row(
          children: [
            _buildTimePill('7 Days', isSelected: true),
            _buildTimePill('30 Days', isSelected: false),
            _buildTimePill('90 Days', isSelected: false),
          ],
        ),
        const SizedBox(height: 15),
        
        // Grafik Placeholder
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Image.asset(
              'assets/chart_placeholder.png', // Gerçek uygulamada grafik kütüphanesi (fl_chart) kullanılır
              height: 180,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePill(String text, {required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accentPurple : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}