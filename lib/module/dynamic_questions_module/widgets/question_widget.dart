import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_densfa/module/dynamic_questions_module/model.dart';

/// Widget for displaying individual questions
/// Extracted from DynamicQuestionsView to improve maintainability
class QuestionWidget extends StatelessWidget {
  final QuestionModel question;
  final Function(String, String, bool, int) onAnswerUpdate;
  final int index;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.onAnswerUpdate,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionHeader(),
          SizedBox(height: 12.h),
          _buildQuestionContent(),
          if (question.isIssue == true) ...[
            SizedBox(height: 12.h),
            _buildIssueRemarkField(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: _getQuestionTypeColor(),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            question.questionType.name,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            question.question,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionContent() {
    switch (question.questionType) {
      case QuestionInputType.singleLineText:
      case QuestionInputType.multiLineText:
        return _buildTextInput();
      case QuestionInputType.number:
      case QuestionInputType.amount:
        return _buildNumberInput();
      case QuestionInputType.ddMMyy:
        return _buildDateInput();
      case QuestionInputType.time:
        return _buildTimeInput();
      case QuestionInputType.dropdown:
      case QuestionInputType.multiSelectDropdown:
        return _buildDropdownInput();
      case QuestionInputType.radio:
        return _buildRadioInput();
      case QuestionInputType.boolean:
        return _buildCheckboxInput();
      case QuestionInputType.rating:
        return _buildRatingInput();
      case QuestionInputType.image:
        return _buildImageInput();
      case QuestionInputType.multiAnswers:
        return _buildMultiSelectInput();
    }
  }

  Widget _buildTextInput() {
    return TextFormField(
      initialValue: question.answer,
      onChanged: (value) => onAnswerUpdate(
        question.uuid,
        value,
        question.isIssue,
        index,
      ),
      decoration: InputDecoration(
        hintText: 'Enter your answer',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
      ),
      maxLines: 3,
    );
  }

  Widget _buildNumberInput() {
    return TextFormField(
      initialValue: question.answer,
      keyboardType: TextInputType.number,
      onChanged: (value) => onAnswerUpdate(
        question.uuid,
        value,
        question.isIssue,
        index,
      ),
      decoration: InputDecoration(
        hintText: 'Enter number',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
      ),
    );
  }
  Widget _buildTimeInput() {
    return InkWell(
      onTap: () => _selectTime(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              question.answer ?? 'Select time',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: question.answer != null ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInput() {
    return InkWell(
      onTap: () => _selectDate(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              question.answer ?? 'Select date',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: question.answer != null ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDropdownInput() {
    // This would be implemented based on your dropdown options
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              question.answer ?? 'Select option',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: question.answer != null ? Colors.black : Colors.grey,
              ),
            ),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _buildRadioInput() {
    // This would be implemented based on your radio options
    return Column(
      children: [
        // Radio options would be implemented here
        Text(
          'Radio options not implemented',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxInput() {
    return Row(
      children: [
        Checkbox(
          value: question.answer == 'true',
          onChanged: (value) => onAnswerUpdate(
            question.uuid,
            value.toString(),
            question.isIssue,
            index,
          ),
        ),
        Text(
          'Check this option',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingInput() {
    // This would be implemented with a rating widget
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        'Rating widget not implemented',
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildIssueRemarkField() {
    return TextFormField(
      initialValue: question.issuesRemark,
      onChanged: (value) {
        // Update issue remark
        // This would be handled by the parent widget
      },
      decoration: InputDecoration(
        hintText: 'Enter issue remark',
        labelText: 'Issue Remark',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 12.h,
        ),
      ),
      maxLines: 2,
    );
  }

  Color _getQuestionTypeColor() {
    switch (question.questionType) {

      case QuestionInputType.singleLineText:
      case QuestionInputType.multiLineText:
        return Colors.blue;
      case QuestionInputType.number:
      case QuestionInputType.amount:
        return Colors.green;
      case QuestionInputType.ddMMyy:
        return Colors.orange;
      case QuestionInputType.time:
        return Colors.orange;
      case QuestionInputType.dropdown:
      case QuestionInputType.multiSelectDropdown:
        return Colors.red;
      case QuestionInputType.radio:
        return Colors.teal;
      case QuestionInputType.boolean:
        return Colors.indigo;
      case QuestionInputType.rating:
        return Colors.amber;
      case QuestionInputType.image:
        return Colors.purple;
      case QuestionInputType.multiAnswers:
        return Colors.brown;
    }
  }

  Widget _buildImageInput() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.image, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            'Image input not implemented',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectInput() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.checklist, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            'Multi-select not implemented',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate() {
    // Implement date selection
  }

   void _selectTime() {
    // Implement date selection
  }


}
