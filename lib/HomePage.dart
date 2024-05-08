import 'package:flutter/material.dart';
import 'print_page.dart';

class HomePage extends StatefulWidget {
  final List<Map<String, String>> textFields;

  const HomePage(this.textFields, {Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> textFields = [
    {'label': 'رقم المخالفه:', 'hint': 'ادخل رقم المخالفه'},
    {'label': 'اسم المخالف:', 'hint': 'ادخل اسم المخالف'},
    {'label': 'Select List Field', 'hint': 'Choose an option'},
  ];
  String _selectedValue = 'Choice 2'; // Pre-select option 2
  List<String> choices = ['Choice 1', 'Choice 2', 'Choice 3'];
  List<String> _userInputs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elbrens'),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var field in textFields)
              Row(
                children: [
                  Text(
                    field['label']!,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: field['label'] == 'Select List Field'
                        ? DropdownButton<String>(
                      isExpanded: true,
                      hint: Text(field['hint']!),
                      value: _selectedValue,
                      items: choices.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedValue = newValue!;
                        });
                      },
                    )
                        : TextFormField(
                      decoration: InputDecoration(
                        hintText: field['hint']!,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _userInputs.add(value);
                          // Add validation logic here (optional)
                        });
                      },
                      keyboardType: field['label']!.contains('رقم') ? TextInputType.number : null,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to print page with user inputs
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrintPage(_userInputs),
                  ),
                );
              },
              child: Text('Print'),
            ),
          ],
        ),
      ),
    );
  }
}
