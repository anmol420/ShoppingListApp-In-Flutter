import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https(
        'shopping-list-app-4dd09-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectedCategory.title,
          },
        ),
      );

      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must Be Between 1 and 50 Characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must Be A Valid Positive Number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final catergory in categories.entries)
                          DropdownMenuItem(
                            value: catergory.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: catergory.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  catergory.value.title.toString(),
                                ),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: const Text(
                      'Reset',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: const Text(
                      'Add Item',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
