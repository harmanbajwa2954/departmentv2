#Campus Core
A Flutter-based Department Management System designed for colleges or universities to streamline academic administration for teachers, students, and HODs. It leverages Firebase for real-time data handling, authentication, and storage.

🚀 Features
👨‍🏫 Teacher Panel:
✅ Mark Attendance: Subject-wise, section-based attendance with date-wise records.

📊 View Attendance Summary: Visual representation of class-wise student attendance.

📝 Approve Study Materials: Review and approve materials submitted by students.

🧾 Review Submissions: Access and grade student assignment submissions.

📢 Send Announcements: Push important notices to specific sections.

📈 Attendance Analytics (AI): Summary with statistics per class and student.

🎓 Student Panel:
👁️ View Attendance: Visual table showing attendance status for all subjects.

📂 Access Study Materials: Download approved notes, slides, and PDFs.

📬 Submit Complaints: Raise issues or feedback to faculty.

📄 Submit Assignments: Upload work for review by teachers.

🧑‍💼 HOD Panel (Optional/Future Scope):
🔎 View analytics of faculty and department.

📣 Broadcast department-wide announcements.

🛠 Tech Stack
Technology	Purpose
Flutter	Cross-platform app development
Firebase Auth	User authentication (student/teacher)
Firebase Firestore	Real-time NoSQL cloud database
Firebase Storage	File upload/download (study materials)
Cloud Functions	(Optional) Backend logic
Dart	Core programming language

🔐 Roles & Permissions
Role	Access Description
Student	View attendance, download materials, raise complaints
Teacher	Manage attendance, view analytics, approve materials
Admin/HOD	(optional) Full access, including CRUD operations on departments and roles

🧾 Firebase Structure Overview
bash
Copy
Edit
users/{userId}
  └── name, course, year, section, role

teachers/{teacherId}/attendance/{subject_course_year_section}/records/{YYYY-MM-DD}
  └── {studentId}: "Present"/"Absent"

users/{studentId}/attendance/{subject}/records/{YYYY-MM-DD}
  └── status, timestamp, etc.

study_materials/
  └── uploadedBy, url, fileName, timestamp

complaints/
  └── title, description, timestamp, raisedBy\



A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
