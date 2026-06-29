import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class HandbookService {
  static final HandbookService _instance = HandbookService._internal();
  factory HandbookService() => _instance;
  HandbookService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/naub_ai.db';
    return await openDatabase(
      path,
      version: 8,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS handbook_pages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT,
        keywords TEXT,
        page_number INTEGER
      )
    ''');
    await _seedHandbook(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 8) {
      await db.execute('DROP TABLE IF EXISTS handbook_pages');
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _seedHandbook(Database db) async {
    final List<Map<String, dynamic>> handbookEntries = [
      // ==================== GENERAL INFORMATION ====================
      {
        'title': 'About NAUB',
        'content': 'Nigerian Army University Biu (NAUB) is located in Biu, Borno State. The university was established to develop highly skilled military and civilian manpower with distinctive competence in technological solutions for the Nigerian Army and the nation.',
        'category': 'About NAUB',
        'keywords': 'about history location establishment',
        'page_number': 1
      },
      {
        'title': 'University Mission & Vision',
        'content': 'MISSION: To develop highly skilled military and civilian manpower with distinctive competence capable of providing technological solutions to the problems of the Nigerian Army, the military and the nation.\n\nVISION: To become a centre of excellence, promoting self-reliance, creativity and innovation, and addressing the challenges of the Nigerian Army, the military as well as the nation.',
        'category': 'About NAUB',
        'keywords': 'mission vision objectives philosophy',
        'page_number': 2
      },
      {
        'title': 'University Objectives',
        'content': '1. Provide facilities for learning and give instruction and training to students.\n2. Encourage the advancement of learning and conduct of research.\n3. Foster the development of high-level scientific and technological knowledge and skills.\n4. Promote productive activities that contribute to national development.',
        'category': 'About NAUB',
        'keywords': 'objectives goals aims',
        'page_number': 3
      },
      {
        'title': 'University Governance',
        'content': 'The University is governed by several bodies:\n\n1. The Visitor - President of the Federal Republic of Nigeria\n2. The Council - Governing body responsible for policy and administration\n3. The Senate - Supreme academic body headed by the Vice-Chancellor\n4. The Congregation - All academic and administrative staff with degrees\n5. Convocation - All graduates and degree-holding staff',
        'category': 'Governance',
        'keywords': 'governance council senate congregation convocation',
        'page_number': 4
      },
      {
        'title': 'The Senate - Powers & Functions',
        'content': 'The Senate is the supreme academic body of the University, presided over by the Vice-Chancellor. Its functions include:\n\n• Organizing and controlling teaching in the University\n• Admission of students and discipline\n• Promotion of research\n• Establishing faculties, departments and institutes\n• Awarding degrees and other qualifications\n• Supervising student welfare and conduct',
        'category': 'Governance',
        'keywords': 'senate academic powers functions',
        'page_number': 5
      },

      // ==================== STUDENT AFFAIRS ====================
      {
        'title': 'Student Affairs Division',
        'content': 'The Student Affairs Division handles all non-academic student services. It is headed by the Dean of Student Affairs.\n\nKey functions include:\n• Student welfare and accommodation\n• Discipline and conduct\n• Hostel management\n• Guidance and counseling\n• Career services',
        'category': 'Student Affairs',
        'keywords': 'student affairs dean welfare accommodation',
        'page_number': 6
      },
      {
        'title': 'Guidance & Counseling Unit',
        'content': 'The Counseling Unit provides confidential services to students experiencing psychological or emotional difficulties.\n\nServices offered:\n• Individual and group guidance\n• Orientation services for new students\n• Information on drug abuse, alcoholism, etc.\n• Career planning and placement\n• Referral to rehabilitation professionals',
        'category': 'Student Affairs',
        'keywords': 'counseling guidance psychological support',
        'page_number': 7
      },
      {
        'title': 'Student Discipline & Conduct',
        'content': 'All students are expected to maintain good behavior and dress decently. Offenses include:\n\nGROSS MISCONDUCT:\n• Cultism and secret society membership\n• Rape and gender-based violence\n• Drug abuse and possession of dangerous substances\n• Stealing and forgery\n• Examination malpractice\n\nPenalties range from warning to expulsion.',
        'category': 'Student Affairs',
        'keywords': 'discipline conduct penalties offenses',
        'page_number': 8
      },
      {
        'title': 'Acceptable Dress Code',
        'content': 'Students must dress decently and appropriately. Acceptable dress includes modest clothing that covers the body properly. Students should avoid transparent dresses that show inner wears and any clothing considered provocative.',
        'category': 'Student Affairs',
        'keywords': 'dress code clothing conduct',
        'page_number': 9
      },
      {
        'title': 'Unacceptable Dress Code',
        'content': 'The following are considered unacceptable dress codes:\n\n• Transparent dresses that show body or inner wears\n• Provocative or revealing clothing\n• Clothing that exposes the body inappropriately\n\nViolation may lead to disciplinary action.',
        'category': 'Student Affairs',
        'keywords': 'dress code prohibition conduct',
        'page_number': 10
      },

      // ==================== ADMISSIONS ====================
      {
        'title': 'Admission Requirements (UTME)',
        'content': 'Minimum UTME score: 180 (160+ eligible for screening).\n\nRequirements:\n1. Five credit passes in O\'level including English & Maths\n2. Four relevant JAMB subject combinations with required grade points\n3. Candidate must not be below 16 years of age',
        'category': 'Admissions',
        'keywords': 'admission utme requirements screening',
        'page_number': 11
      },
      {
        'title': 'Direct Entry Admission',
        'content': 'Direct Entry applicants should possess:\n\n1. Five credit passes in O\'level including English & Maths\n2. A-level certificate with minimum of lower credit in ND\n3. Or 10 points in NCE in relevant discipline',
        'category': 'Admissions',
        'keywords': 'direct entry admission requirements',
        'page_number': 12
      },

      // ==================== ACADEMIC REGULATIONS ====================
      {
        'title': 'Grading System',
        'content': 'GRADING SYSTEM:\n\nMarks% | Letter Grade | Grade Points\n70-100 | A | 5.0\n60-69 | B | 4.0\n50-59 | C | 3.0\n45-49 | D | 2.0\n40-44 | E | 1.0\nBelow 40 | F | 0.0\n\nGPA = Σ(Grade Points × Credit Units) / Σ(Credit Units)',
        'category': 'Academic',
        'keywords': 'grading gpa cgpa marks points',
        'page_number': 13
      },
      {
        'title': 'Degree Classifications',
        'content': 'CGPA | CLASSIFICATION\n4.50 - 5.00 | First Class Honours\n3.50 - 4.49 | Second Class Honours (Upper)\n2.40 - 3.49 | Second Class Honours (Lower)\n1.50 - 2.39 | Third Class Honours\n1.00 - 1.49 | Pass\nBelow 1.00 | Fail (No degree)',
        'category': 'Academic',
        'keywords': 'classification honours degree cgpa',
        'page_number': 14
      },
      {
        'title': 'Course Credit System',
        'content': 'One Credit Unit = 1 hour of lecture or tutorial per week per semester.\n\nCREDIT UNIT EQUIVALENTS:\n• 2 hours of seminar = 1 credit\n• 3 hours of laboratory/field work = 1 credit\n• 6 hours of teaching practice = 1 credit\n• 1 week of industrial attachment = 1 credit',
        'category': 'Academic',
        'keywords': 'credit units load system',
        'page_number': 15
      },
      {
        'title': 'Course Registration Policy',
        'content': '• Minimum credit load: 12 units\n• Maximum credit load: 24 units\n• Students must register within first 3 weeks\n• Late registration incurs penalties\n• Courses must be registered sequentially',
        'category': 'Academic',
        'keywords': 'registration credits load units',
        'page_number': 16
      },
      {
        'title': 'Add/Drop Procedure',
        'content': 'Students may make minor changes to registered courses at the beginning of second semester.\n\nPROCEDURE:\n1. Collect Drop/Add Form from Academic Affairs\n2. Pay appropriate fee (#5,000)\n3. Discuss changes with Level Coordinator\n4. Get endorsements from departments\n5. Complete within 3 weeks of lectures\n6. Cannot add/drop after 25% of course is covered',
        'category': 'Academic',
        'keywords': 'add drop procedure changes',
        'page_number': 17
      },
      {
        'title': 'Pre-Requisite Courses',
        'content': 'A pre-requisite course is a course which a student must take and pass before taking a particular course at a higher level.',
        'category': 'Academic',
        'keywords': 'prerequisite courses requirements',
        'page_number': 18
      },
      {
        'title': 'Repeating Failed Courses',
        'content': '• A student with 6 carry-overs must repeat the level\n• Must register all courses (passed and failed)\n• A student repeating twice at same level will be withdrawn\n\nConsideration may be given for transfer to other programmes.',
        'category': 'Academic',
        'keywords': 'repeat carry-over failed courses',
        'page_number': 19
      },
      {
        'title': 'Change of Course/Transfer',
        'content': 'Students may change course if:\n1. Vacancy exists in desired course\n2. Satisfies entry requirements\n3. Has required CGPA\n4. Has passed 100/200 level core courses\n\nSubject to Senate approval.',
        'category': 'Academic',
        'keywords': 'change course transfer inter-university',
        'page_number': 20
      },
      {
        'title': 'Deferment of Studies',
        'content': 'Application for deferment of studies is subject to Senate approval. Deferment is valid for only one academic year or as approved by Senate.',
        'category': 'Academic',
        'keywords': 'deferment leave suspension',
        'page_number': 21
      },

      // ==================== EXAMINATIONS ====================
      {
        'title': 'Examination Rules & Regulations',
        'content': '1. Must be registered for the course\n2. Must have fulfilled attendance and course work requirements\n3. Must be in exam venue 30 minutes before start\n4. Cannot be admitted 30 minutes after commencement\n5. Must sign attendance form\n6. Must bring examination/identity card\n7. No unauthorized materials allowed\n8. No speaking to other students except invigilator\n9. No handbags or briefcases allowed',
        'category': 'Examinations',
        'keywords': 'exam rules regulations conduct',
        'page_number': 22
      },
      {
        'title': 'Examination Materials Allowed',
        'content': 'Students are allowed to bring only:\n• Writing materials (pens, pencils)\n• Examination card/ID card\n• Items specifically permitted in the exam paper\n\nUnauthorized materials include books, notes, phones, and electronic devices.',
        'category': 'Examinations',
        'keywords': 'exam materials allowed prohibited',
        'page_number': 23
      },
      {
        'title': 'Examination Malpractice Penalties',
        'content': 'Examination malpractice includes:\n• Cheating or copying\n• Possession of unauthorized materials\n• Impersonation\n• Aiding others to cheat\n\nPENALTIES:\n• Warning for minor offenses\n• Suspension for serious offenses\n• Expulsion for gross misconduct\n• Cancellation of results',
        'category': 'Examinations',
        'keywords': 'malpractice penalties cheating expulsion',
        'page_number': 24
      },
      {
        'title': 'Special Examinations',
        'content': 'Students who miss examinations due to illness may be permitted to present for special examinations provided:\n\n1. Illness is reported before the examination\n2. Medical report is submitted\n3. Evidence of hospitalization is provided',
        'category': 'Examinations',
        'keywords': 'special exam illness medical',
        'page_number': 25
      },

      // ==================== FACULTIES & DEPARTMENTS ====================
      {
        'title': 'Faculties at NAUB',
        'content': 'NAUB offers programmes in the following faculties:\n\n1. Faculty of Arts & Management Sciences\n2. Faculty of Computing\n3. Faculty of Engineering & Technology\n4. Faculty of Environmental Sciences\n5. Faculty of Natural & Applied Sciences\n6. Faculty of Social Sciences',
        'category': 'Faculties',
        'keywords': 'faculties departments courses',
        'page_number': 26
      },
      {
        'title': 'Faculty of Computing Programmes',
        'content': 'Department of Computer Science: BSc Computer Science\nDepartment of Cyber Security: BSc Cyber Security\nDepartment of Information Systems: BSc Information Systems\nDepartment of Information Technology: BSc Information Technology\nDepartment of Software Engineering: BSc Software Engineering',
        'category': 'Faculties',
        'keywords': 'computing computer cyber security software',
        'page_number': 27
      },
      {
        'title': 'Faculty of Engineering Programmes',
        'content': 'Department of Civil Engineering: B.Eng. Civil Engineering\nDepartment of Electrical & Electronics: B.Eng. Electrical & Electronics\nDepartment of Mechanical Engineering: B.Eng. Mechanical Engineering',
        'category': 'Faculties',
        'keywords': 'engineering civil electrical mechanical',
        'page_number': 28
      },
      {
        'title': 'Faculty of Arts & Management Programmes',
        'content': 'Department of Accounting: BSc Accounting\nDepartment of History: B.A. Military History\nDepartment of Languages: B.A. Arabic, B.A. English\nDepartment of Management: BSc Management, BSc Transport & Logistics Management',
        'category': 'Faculties',
        'keywords': 'arts management accounting languages',
        'page_number': 29
      },

      // ==================== HOSTEL RULES ====================
      {
        'title': 'Hostel Accommodation',
        'content': 'Hostel accommodation is provided to eligible and interested students.\n\nKey rules:\n• Bed spaces allocated for one academic session only\n• Full accommodation fees payable in advance\n• Students must keep rooms clean\n• No cooking in rooms (use designated areas)\n• No pets allowed\n• No unauthorized transfer of rooms\n• Report damages to hall porter immediately',
        'category': 'Hostel',
        'keywords': 'hostel accommodation rooms rules',
        'page_number': 30
      },
      {
        'title': 'Hostel Visitors Policy',
        'content': 'VISITOR HOURS:\n• Monday - Friday: 11am - 8pm\n• Saturday: 11am - 8pm\n• Public Holidays: 11am - 8pm\n\nVisitors must sign in and out at the register.\nNo visitors allowed directly into students\' rooms without registration.',
        'category': 'Hostel',
        'keywords': 'hostel visitors hours policy',
        'page_number': 31
      },
      {
        'title': 'Audio & Electrical Appliances',
        'content': '• Radios, TVs and other instruments must not disturb other students\n• All electrical property must be registered with the porter\n• Only small transistor radios allowed\n• No cookers or stoves allowed in rooms\n• During blackouts, only battery-operated flashlights may be used',
        'category': 'Hostel',
        'keywords': 'audio electrical appliances rules',
        'page_number': 32
      },

      // ==================== LIBRARY & ICT ====================
      {
        'title': 'University Library',
        'content': 'The University Library is located in the Main Academic Area. It supports teaching, learning and research with both physical and electronic resources.\n\nMEMBERSHIP:\n• Students of the University\n• Staff of the University\n\nUsers must follow library rules and return materials on time.',
        'category': 'Facilities',
        'keywords': 'library books resources reading',
        'page_number': 33
      },

      // ==================== FEES & FINANCES ====================
      {
        'title': 'School Fees',
        'content': 'SCHOOL FEES (2025/2026):\n• New Science Students: ₦84,500\n• New Arts/Social Science: ₦64,500\n• Acceptance Fee: ₦5,000\n\nAlways verify on the student portal: https://my.naub.edu.ng/',
        'category': 'Fees',
        'keywords': 'fees tuition charges payment',
        'page_number': 34
      },
      {
        'title': 'NELFund - Nigerian Education Loan Fund',
        'content': 'NELFund is a Federal Government initiative providing interest-free loans to eligible Nigerian students.\n\nELIGIBILITY:\n• Must be a Nigerian student with valid Admission Number\n• Must have a commercial bank account\n• Must be registered in a public tertiary institution\n\nAPPLY AT: http://nelfund.org',
        'category': 'Fees',
        'keywords': 'nel fund loan scholarship financial aid',
        'page_number': 35
      },

      // ==================== SECURITY ====================
      {
        'title': 'Campus Security Services',
        'content': 'Security services are under the Office of the Vice Chancellor, headed by the Chief Security Officer.\n\nRESPONSIBILITIES:\n• Maintaining law and order\n• Sustaining peaceful activities\n• Receiving reports and vital information\n• Gate pass for private property\n• Custody of lost property and identification',
        'category': 'Security',
        'keywords': 'security safety campus police',
        'page_number': 36
      },
      {
        'title': 'Safety Tips for Students',
        'content': '1. Be conscious of your surroundings\n2. Do not bring expensive items to school\n3. Keep money in the bank, carry only pocket money\n4. Always lock doors when leaving your room\n5. Do not organize or participate in demonstrations\n6. Report any suspicious activity to security',
        'category': 'Security',
        'keywords': 'safety tips security awareness',
        'page_number': 37
      },

      // ==================== ACADEMIC EXCELLENCE ====================
      {
        'title': 'Keys to Academic Excellence',
        'content': '1. Meet your Advisor and Head of Department regularly\n2. Review your education program and career goals\n3. Discuss your academic interests and progress\n4. Explore enrichment activities, internships and research\n5. Don\'t hesitate to ask for help\n6. Use Academic Support Centres (ICT, library, tutorials)\n7. Read all University publications\n8. Plan your activities using calendars\n9. Participate in campus activities\n10. Stay in touch with family and friends',
        'category': 'Academic Tips',
        'keywords': 'academic excellence success tips',
        'page_number': 38
      },

      // ==================== HEALTH & WELLNESS ====================
      {
        'title': 'Sexually Transmitted Diseases (STDs)',
        'content': 'STDs include HIV/AIDS, gonorrhoea, syphilis, hepatitis B, and others.\n\nPREVENTION TIPS:\n• Abstinence is the safest choice\n• Be proud to be a virgin\n• Sex is short-lived but consequences can last a lifetime\n• Ensure tools used are properly sterilized\n• Share this knowledge with friends and relatives',
        'category': 'Health',
        'keywords': 'std hiv aids sexual health',
        'page_number': 39
      },
      {
        'title': 'Effects of Illicit Drug Abuse',
        'content': 'Drug abuse has multiple negative effects:\n\n• Addiction and dependency\n• Poor academic performance\n• Health problems (physical and mental)\n• Social isolation\n• Financial problems\n• Legal consequences\n\nDrugs commonly abused include alcohol, marijuana, cocaine, heroin, and tobacco.',
        'category': 'Health',
        'keywords': 'drugs addiction substance abuse',
        'page_number': 40
      },
      {
        'title': 'Consequences of Provocative Dressing',
        'content': 'Provocative dressing can lead to:\n\n• Unwanted attention and harassment\n• Being judged as ignorant or foolish\n• Incomplete education and unrealized goals\n• Sexual harassment by staff or students\n• Sexual violence such as rape and assault\n• Becoming an object of criticism\n• Bringing shame to your family\n• Loss of family respect',
        'category': 'Health',
        'keywords': 'dressing provocative consequences',
        'page_number': 41
      },

      // ==================== NYSC ====================
      {
        'title': 'National Youth Service Corps (NYSC)',
        'content': 'NYSC is a scheme where every Nigerian graduate serves the nation for one year.\n\nOBJECTIVES:\n• Promote national unity and integration\n• Develop common attitudes of national morality\n• Expose youths to different modes of living\n• Remove prejudices and eliminate ignorance\n• Promote free movement of labour\n\nMarried women with family responsibilities may be exempted.',
        'category': 'NYSC',
        'keywords': 'nysc service corps national youth',
        'page_number': 42
      },
    ];

    for (var entry in handbookEntries) {
      await db.insert('handbook_pages', entry, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Map<String, dynamic>>> searchHandbook(String query) async {
    final db = await database;
    return await db.query(
      'handbook_pages',
      where: 'title LIKE ? OR content LIKE ? OR category LIKE ? OR keywords LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'page_number ASC',
      limit: 50,
    );
  }

  Future<void> addPage(String title, String content, String category, {String? keywords}) async {
    final db = await database;
    await db.insert('handbook_pages', {
      'title': title,
      'content': content,
      'category': category,
      'keywords': keywords,
    });
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}