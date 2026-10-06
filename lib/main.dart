import 'package:flutter/material.dart';

void main() {
  runApp(const BmiApp());
}

class BmiApp extends StatelessWidget {
  const BmiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Calculator',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F7F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B8C72),
        ),
      ),
      home: const BmiInputScreen(),
    );
  }
}

// ============================================================
// BMI INPUT SCREEN
// ============================================================

class BmiInputScreen extends StatefulWidget {
  const BmiInputScreen({super.key});

  @override
  State<BmiInputScreen> createState() => _BmiInputScreenState();
}

class _BmiInputScreenState extends State<BmiInputScreen> {
  // Controllers for input fields
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // Selected values
  String selectedGender = '';
  String heightUnit = 'cm';
  String weightUnit = 'kg';

  // ----------------------------------------------------------
  // Reset all input fields
  // ----------------------------------------------------------

  void resetFields() {
    setState(() {
      ageController.clear();
      heightController.clear();
      weightController.clear();
      selectedGender = '';
      heightUnit = 'cm';
      weightUnit = 'kg';
    });
  }

  // ----------------------------------------------------------
  // Calculate BMI
  // ----------------------------------------------------------

  Future<void> calculateBMI() async {
    final ageText = ageController.text.trim();
    final heightText = heightController.text.trim();
    final weightText = weightController.text.trim();

    // Check empty fields
    if (ageText.isEmpty ||
        heightText.isEmpty ||
        weightText.isEmpty ||
        selectedGender.isEmpty) {
      showErrorMessage('Please enter all details.');
      return;
    }

    // Convert input text to numbers
    final double? age = double.tryParse(ageText);
    final double? height = double.tryParse(heightText);
    final double? weight = double.tryParse(weightText);

    // Check valid numbers
    if (age == null || height == null || weight == null) {
      showErrorMessage('Please enter valid numbers.');
      return;
    }

    // Age constraint (1 to 120 years)
    if (age < 1 || age > 120) {
      showErrorMessage('Please enter a valid age between 1 and 120 years.');
      return;
    }

    // Height constraint
    if (heightUnit == 'cm') {
      if (height < 50 || height > 300) {
        showErrorMessage('Please enter a valid height between 50 and 300 cm.');
        return;
      }
    } else {
      if (height < 20 || height > 120) {
        showErrorMessage('Please enter a valid height between 20 and 120 inches.');
        return;
      }
    }

    // Weight constraint
    if (weightUnit == 'kg') {
      if (weight < 10 || weight > 500) {
        showErrorMessage('Please enter a valid weight between 10 and 500 kg.');
        return;
      }
    } else {
      if (weight < 22 || weight > 1100) {
        showErrorMessage('Please enter a valid weight between 22 and 1100 lbs.');
        return;
      }
    }

    // --------------------------------------------------------
    // Convert height to metres
    // --------------------------------------------------------

    final double heightInMeters;
    if (heightUnit == 'cm') {
      heightInMeters = height / 100;
    } else {
      // Inches to metres
      heightInMeters = height * 0.0254;
    }

    // --------------------------------------------------------
    // Convert weight to kilograms
    // --------------------------------------------------------

    final double weightInKg;
    if (weightUnit == 'kg') {
      weightInKg = weight;
    } else {
      // Pounds to kilograms
      weightInKg = weight * 0.453592;
    }

    // --------------------------------------------------------
    // BMI Formula
    // --------------------------------------------------------

    final double bmi = weightInKg / (heightInMeters * heightInMeters);

    if (!bmi.isFinite || bmi <= 0) {
      showErrorMessage('Invalid calculation result. Please check your inputs.');
      return;
    }

    // Open result screen
    final shouldReset = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BmiResultScreen(
          bmi: bmi,
          age: age,
          gender: selectedGender,
        ),
      ),
    );

    // Clear previous calculation values when returning from "Calculate Again"
    if (shouldReset == true && mounted) {
      resetFields();
    }
  }

  // ----------------------------------------------------------
  // Error message
  // ----------------------------------------------------------

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ----------------------------------------------------------
  // Dispose controllers
  // ----------------------------------------------------------

  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // BUILD INPUT SCREEN
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // =================================================
                // HEADER
                // =================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 32),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5B8C72),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BMI Calculator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Calculate your Body Mass Index',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // =================================================
                // INPUT CARD
                // =================================================
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // =================================================
                        // AGE
                        // =================================================
                        const Text(
                          'Age',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          decoration: inputDecoration(
                            'Enter your age (1 - 120)',
                            Icons.calendar_today,
                            'years',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // =================================================
                        // GENDER
                        // =================================================
                        const Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: genderButton(
                                'Male',
                                Icons.male,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: genderButton(
                                'Female',
                                Icons.female,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // =================================================
                        // HEIGHT
                        // =================================================
                        const Text(
                          'Height',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: heightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: inputDecoration(
                                  heightUnit == 'cm'
                                      ? 'Enter height (50 - 300)'
                                      : 'Enter height (20 - 120)',
                                  Icons.height,
                                  heightUnit,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            unitButton(
                              'cm',
                              heightUnit == 'cm',
                              () {
                                setState(() {
                                  heightUnit = 'cm';
                                });
                              },
                            ),
                            const SizedBox(width: 5),
                            unitButton(
                              'in',
                              heightUnit == 'in',
                              () {
                                setState(() {
                                  heightUnit = 'in';
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // =================================================
                        // WEIGHT
                        // =================================================
                        const Text(
                          'Weight',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: weightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: inputDecoration(
                                  weightUnit == 'kg'
                                      ? 'Enter weight (10 - 500)'
                                      : 'Enter weight (22 - 1100)',
                                  Icons.monitor_weight_outlined,
                                  weightUnit,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            unitButton(
                              'kg',
                              weightUnit == 'kg',
                              () {
                                setState(() {
                                  weightUnit = 'kg';
                                });
                              },
                            ),
                            const SizedBox(width: 5),
                            unitButton(
                              'lbs',
                              weightUnit == 'lbs',
                              () {
                                setState(() {
                                  weightUnit = 'lbs';
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // =================================================
                        // CALCULATE BUTTON
                        // =================================================
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: calculateBMI,
                            icon: const Icon(Icons.calculate),
                            label: const Text(
                              'Calculate BMI',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B8C72),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 25),
                  child: Text(
                    'BMI is a general screening measure and is not a medical diagnosis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // INPUT FIELD DESIGN
  // ==========================================================

  InputDecoration inputDecoration(
    String hint,
    IconData icon,
    String suffix,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF5B8C72),
      ),
      suffixText: suffix,
      filled: true,
      fillColor: const Color(0xFFF5F9F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFC7DCCB),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFC7DCCB),
        ),
      ),
    );
  }

  // ==========================================================
  // GENDER BUTTON
  // ==========================================================

  Widget genderButton(
    String gender,
    IconData icon,
  ) {
    final bool selected = selectedGender == gender;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5B8C72) : const Color(0xFFF5F9F5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFC7DCCB),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF5B8C72),
            ),
            const SizedBox(width: 7),
            Text(
              gender,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // UNIT BUTTON
  // ==========================================================

  Widget unitButton(
    String text,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5B8C72) : const Color(0xFFE7F1E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF5B8C72),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BMI RESULT SCREEN
// ============================================================

class BmiResultScreen extends StatelessWidget {
  final double bmi;
  final double age;
  final String gender;

  const BmiResultScreen({
    super.key,
    required this.bmi,
    required this.age,
    required this.gender,
  });

  // ==========================================================
  // BMI CATEGORY
  // ==========================================================

  String get category {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal Weight';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obesity';
    }
  }

  // ==========================================================
  // RESULT MESSAGE
  // ==========================================================

  String get message {
    if (bmi < 18.5) {
      return 'Your BMI is below the general healthy range.';
    } else if (bmi < 25) {
      return 'Your BMI is within the general healthy range.';
    } else if (bmi < 30) {
      return 'Your BMI is above the general healthy range.';
    } else {
      return 'Your BMI is in the obesity range. Consider professional guidance.';
    }
  }

  // ==========================================================
  // SUGGESTIONS
  // ==========================================================

  List<String> get suggestions {
    if (bmi < 18.5) {
      return [
        'Eat a balanced and nutritious diet.',
        'Include healthy sources of protein and calories.',
        'Focus on gradual and healthy weight gain.',
        'Consider professional guidance if needed.',
      ];
    } else if (bmi < 25) {
      return [
        'Continue eating a balanced diet.',
        'Stay physically active.',
        'Maintain good sleep and hydration.',
        'Continue taking care of your overall health.',
      ];
    } else if (bmi < 30) {
      return [
        'Focus on balanced meals and portion control.',
        'Include regular physical activity.',
        'Reduce excessive sugary and processed foods.',
        'Set gradual and sustainable health goals.',
      ];
    } else {
      return [
        'Focus on gradual and sustainable lifestyle changes.',
        'Maintain balanced eating habits.',
        'Include suitable physical activity.',
        'Consider consulting a qualified healthcare professional.',
      ];
    }
  }

  // ==========================================================
  // CATEGORY COLOR
  // ==========================================================

  Color get categoryColor {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi < 25) {
      return const Color(0xFF5B8C72);
    } else if (bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // ==========================================================
  // RESULT SCREEN
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F3),
      appBar: AppBar(
        title: const Text(
          'BMI Result',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF5B8C72),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // =================================================
            // BMI RESULT CARD
            // =================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // User Summary Chips (Age & Gender)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B8C72).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              gender.toLowerCase() == 'female'
                                  ? Icons.female
                                  : Icons.male,
                              size: 18,
                              color: const Color(0xFF5B8C72),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              gender,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5B8C72),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B8C72).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 15,
                              color: Color(0xFF5B8C72),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${age.toStringAsFixed(age.truncateToDouble() == age ? 0 : 1)} yrs',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5B8C72),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // BMI circle
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: categoryColor.withValues(alpha: 0.10),
                      border: Border.all(
                        color: categoryColor,
                        width: 6,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bmi.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                        const Text(
                          'kg/m²',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // BMI RANGE
            // =================================================
            buildBmiRange(),

            const SizedBox(height: 20),

            // =================================================
            // BMI CLASSIFICATION
            // =================================================
            buildBmiClassification(),

            const SizedBox(height: 20),

            // =================================================
            // SUGGESTIONS
            // =================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF5B8C72),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Suggestions for You',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Display suggestions
                  for (String suggestion in suggestions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 20,
                            color: Color(0xFF5B8C72),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // CALCULATE AGAIN
            // =================================================
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Calculate Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B8C72),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'BMI is a general screening measure and does not directly measure body fat or overall health. It should not be used as a medical diagnosis.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BMI RANGE WIDGET
  // ==========================================================

  Widget buildBmiRange() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BMI Range',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          // Colored bar
          Container(
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Colors.blue,
                  Color(0xFF5B8C72),
                  Colors.orange,
                  Colors.red,
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '< 18.5\nUnderweight',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10),
              ),
              Text(
                '18.5 - 24.9\nNormal',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10),
              ),
              Text(
                '25 - 29.9\nOverweight',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10),
              ),
              Text(
                '≥ 30\nObesity',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BMI CLASSIFICATION
  // ==========================================================

  Widget buildBmiClassification() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BMI Classification',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          bmiRow(
            'Underweight',
            '< 18.5',
            Colors.blue,
            bmi < 18.5,
          ),
          bmiRow(
            'Normal Weight',
            '18.5 - 24.9',
            const Color(0xFF5B8C72),
            bmi >= 18.5 && bmi < 25,
          ),
          bmiRow(
            'Overweight',
            '25 - 29.9',
            Colors.orange,
            bmi >= 25 && bmi < 30,
          ),
          bmiRow(
            'Obesity',
            '≥ 30',
            Colors.red,
            bmi >= 30,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BMI ROW
  // ==========================================================

  Widget bmiRow(
    String name,
    String range,
    Color color,
    bool selected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: selected ? color.withValues(alpha: 0.10) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: selected
            ? Border.all(
                color: color,
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}