// lib/models/job_model.dart

class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String deadline;
  final String logo; // Logo URL
  final String category;
  final String description; // Circular in Details

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.deadline,
    required this.logo,
    required this.category,
    required this.description,
  });

  // In Future Firebase call
  factory JobModel.fromMap(Map<String, dynamic> data, String documentId) {
    return JobModel(
      id: documentId,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      location: data['location'] ?? '',
      salary: data['salary'] ?? '',
      deadline: data['deadline'] ?? '',
      logo: data['logo'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
