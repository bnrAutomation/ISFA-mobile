import 'package:flutter/material.dart';

class QuestionModel {
  final String question;
  String? answer;
  final QuestionInputType questionType;
  final String? placholder;
  final List<String> options;
  final TextInputType? keyboardPref;
  final bool isRequired;

  QuestionModel(
      {required this.question,
      required this.questionType,
      this.placholder,
      this.keyboardPref,
      required this.options,
      required this.isRequired})
      : assert(
            (questionType == QuestionInputType.dropdown ||
                    questionType == QuestionInputType.radio)
                ? options.isNotEmpty
                : options.isEmpty,
            'Dropdown/radio question must have options to show');
}

enum QuestionInputType {
  dropdown,
  amount,
  number,
  radio,
  image,
  singleLineText,
  multiLineText,
  ddMMyy
}

final dummySalesLogFormList = [
  QuestionModel(
      question: "Category Name",
      questionType: QuestionInputType.dropdown,
      placholder: "Select Category",
      options: ["option 1", "option 2"],
      isRequired: true),
  QuestionModel(
      question: "Sub Category Name",
      placholder: "Select sub category",
      questionType: QuestionInputType.dropdown,
      options: ["option 1", "option 2"],
      isRequired: true),
  QuestionModel(
      question: "Product Type",
      placholder: "Choose an option",
      questionType: QuestionInputType.dropdown,
      options: ["option 1", "option 2"],
      isRequired: true),
  QuestionModel(
      question: "Product Type",
      placholder: "Choose an option",
      questionType: QuestionInputType.dropdown,
      options: ["option 1", "option 2"],
      isRequired: true),
  QuestionModel(
      question: "Unit Price",
      placholder: "0000",
      questionType: QuestionInputType.amount,
      options: [],
      isRequired: true),
  QuestionModel(
      question: "Quantity",
      placholder: "00",
      questionType: QuestionInputType.number,
      options: [],
      isRequired: true),
  QuestionModel(
      question: "Total Amt",
      placholder: "000000",
      questionType: QuestionInputType.amount,
      options: [],
      isRequired: true),
];

final dummyOtherInfo = [
  QuestionModel(
      question: "Remarks",
      questionType: QuestionInputType.multiLineText,
      options: [],
      isRequired: true),
  QuestionModel(
      question: "Invoice image",
      placholder: "Upload Invoice Image",
      questionType: QuestionInputType.image,
      options: [],
      isRequired: true),
];

final dummyCustomerDetails = [
  QuestionModel(
      question: "Customer Name",
      placholder: "Enter customer name",
      questionType: QuestionInputType.singleLineText,
      options: [],
      keyboardPref: TextInputType.name,
      isRequired: true),
  QuestionModel(
      question: "Customer Contact Number",
      placholder: "Enter customer contact",
      questionType: QuestionInputType.singleLineText,
      options: [],
      keyboardPref: TextInputType.number,
      isRequired: true),
  QuestionModel(
      question: "Email Address",
      placholder: "Enter customer email address",
      questionType: QuestionInputType.singleLineText,
      options: [],
      keyboardPref: TextInputType.emailAddress,
      isRequired: true),
  QuestionModel(
      question: "Customer DOB",
      placholder: "DD/MM/YY",
      questionType: QuestionInputType.ddMMyy,
      options: [],
      isRequired: true),
  QuestionModel(
      question: "Invoice Number",
      placholder: "Enter invoice no",
      questionType: QuestionInputType.singleLineText,
      options: [],
      isRequired: true),
  QuestionModel(
      question: "Sales Date",
      placholder: "DD/MM/YY",
      questionType: QuestionInputType.ddMMyy,
      options: [],
      isRequired: true),
];
