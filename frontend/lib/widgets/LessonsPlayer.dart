// lib/components/lesson_player.dart
import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';

class LessonStep {
  final String title;
  final String description;
  final String mediaType;
  final String mediaUrl;

  LessonStep({
    required this.title,
    required this.description,
    required this.mediaType,
    required this.mediaUrl,
  });
}

class LessonData {
  final String lessonTitle;
  final List<LessonStep> steps;

  LessonData({
    required this.lessonTitle,
    required this.steps,
  });
}

class LessonPlayer extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final LessonData lessonData;

  const LessonPlayer({
    Key? key,
    required this.isOpen,
    required this.onClose,
    required this.lessonData,
  }) : super(key: key);

  @override
  _LessonPlayerState createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<LessonPlayer> {
  int currentStep = 0;
  bool isCompleted = false;

  double get progress => ((currentStep + 1) / widget.lessonData.steps.length) * 100;
  bool get isLastStep => currentStep == widget.lessonData.steps.length - 1;
  bool get isFirstStep => currentStep == 0;

  @override
  void initState() {
    super.initState();
    if (widget.isOpen) {
      _resetState();
    }
  }

  @override
  void didUpdateWidget(LessonPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _resetState();
    }
  }

  void _resetState() {
    setState(() {
      currentStep = 0;
      isCompleted = false;
    });
  }

  void _handleNext() {
    setState(() {
      if (isLastStep) {
        isCompleted = true;
      } else {
        currentStep++;
      }
    });
  }

  void _handlePrevious() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
      }
    });
  }

  void _handleRestart() {
    setState(() {
      currentStep = 0;
      isCompleted = false;
    });
  }

  void _handleStepClick(int stepIndex) {
    setState(() {
      currentStep = stepIndex;
      isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return SizedBox.shrink();

    final currentStepData = widget.lessonData.steps.isNotEmpty 
        ? widget.lessonData.steps[currentStep] 
        : null;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.islamicWhite,
                AppColors.islamicCream,
              ],
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.lessonsBorder.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lessonData.lessonTitle,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lessonsTitle,
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Step ${isCompleted ? widget.lessonData.steps.length : currentStep + 1} of ${widget.lessonData.steps.length}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.lessonsSubtitle,
                                    ),
                                  ),
                                  Text(
                                    '${progress.round()}% Complete',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.lessonsSubtitle,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress / 100,
                                  backgroundColor: AppColors.lessonsBorder,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.lessonsHumanBadge,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onClose,
                          icon: Icon(
                            Icons.close,
                            color: AppColors.lessonsSubtitle,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: Row(
                  children: [
                    // Media Section
                    Expanded(
                      flex: 2,
                      child: Container(
                        color: AppColors.lessonsTitle,
                        child: Stack(
                          children: [
                            if (!isCompleted && currentStepData != null)
                              Center(
                                child: Container(
                                  margin: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      currentStepData.mediaUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => 
                                        Container(
                                          height: 300,
                                          color: AppColors.lessonsBorder,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image_not_supported,
                                                  size: 48,
                                                  color: AppColors.lessonsSubtitle,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Image not available',
                                                  style: TextStyle(
                                                    color: AppColors.lessonsSubtitle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ),
                                  ),
                                ),
                              ),

                            // Navigation Overlay
                            if (!isCompleted)
                              Positioned.fill(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(16),
                                      child: FloatingActionButton(
                                        onPressed: isFirstStep ? null : _handlePrevious,
                                        backgroundColor: Colors.white.withOpacity(0.2),
                                        child: Icon(
                                          Icons.chevron_left,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(16),
                                      child: FloatingActionButton(
                                        onPressed: _handleNext,
                                        backgroundColor: Colors.white.withOpacity(0.2),
                                        child: Icon(
                                          isLastStep ? Icons.check_circle : Icons.chevron_right,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Completion Screen
                            if (isCompleted)
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 96,
                                      color: AppColors.askPagePrivateIcon,
                                    ),
                                    SizedBox(height: 24),
                                    Text(
                                      'Excellent Work!',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'You\'ve completed this lesson. Well done!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white70,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(5, (index) =>
                                        Icon(
                                          Icons.star,
                                          color: AppColors.askPagePrivateIcon,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 32),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: _handleRestart,
                                          icon: Icon(Icons.refresh, color: Colors.white),
                                          label: Text(
                                            'Restart Lesson',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(color: Colors.white),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        ElevatedButton(
                                          onPressed: widget.onClose,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.askPagePrivateIcon,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: Text(
                                            'Continue Learning',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Content Panel
                    Container(
                      width: 384,
                      decoration: BoxDecoration(
                        color: AppColors.islamicWhite,
                        border: Border(
                          left: BorderSide(
                            color: AppColors.lessonsBorder.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          if (!isCompleted && currentStepData != null) ...[
                            // Step Content
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentStepData.title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.lessonsTitle,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      currentStepData.description,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.lessonsSubtitle,
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: 32),
                                    Text(
                                      'Lesson Steps',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.lessonsTitle,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: widget.lessonData.steps.length,
                                        itemBuilder: (context, index) {
                                          final step = widget.lessonData.steps[index];
                                          final isCurrentStep = index == currentStep;
                                          final isCompletedStep = index < currentStep;

                                          return Container(
                                            margin: EdgeInsets.only(bottom: 8),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () => _handleStepClick(index),
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: isCurrentStep
                                                        ? AppColors.lessonsBorder
                                                        : isCompletedStep
                                                            ? AppColors.lessonsBorder.withOpacity(0.3)
                                                            : AppColors.lessonsCategoryBackground.withOpacity(0.3),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: isCurrentStep
                                                          ? AppColors.lessonsHumanBadge
                                                          : isCompletedStep
                                                              ? AppColors.lessonsBorder
                                                              : AppColors.lessonsCategoryBackground,
                                                      width: isCurrentStep ? 2 : 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 24,
                                                        height: 24,
                                                        decoration: BoxDecoration(
                                                          color: isCompletedStep
                                                              ? AppColors.lessonsHumanBadge
                                                              : isCurrentStep
                                                                  ? AppColors.lessonsBorder
                                                                  : AppColors.lessonsCategoryBackground,
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Center(
                                                          child: isCompletedStep
                                                              ? Icon(
                                                                  Icons.check,
                                                                  color: Colors.white,
                                                                  size: 16,
                                                                )
                                                              : Text(
                                                                  '${index + 1}',
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: isCurrentStep
                                                                        ? AppColors.lessonsTitle
                                                                        : AppColors.lessonsSubtitle,
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          step.title,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w500,
                                                            color: isCurrentStep
                                                                ? AppColors.lessonsTitle
                                                                : AppColors.lessonsSubtitle,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Navigation
                            Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.lessonsBorder.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: isFirstStep ? null : _handlePrevious,
                                      icon: Icon(Icons.chevron_left),
                                      label: Text('Previous'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.lessonsTitle,
                                        side: BorderSide(color: AppColors.lessonsBorder),
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _handleNext,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.lessonsHumanBadge,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(isLastStep ? 'Complete' : 'Next'),
                                          if (!isLastStep) ...[
                                            SizedBox(width: 4),
                                            Icon(Icons.chevron_right, size: 16),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (isCompleted) ...[
                            // Completion Side Panel
                            Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Text(
                                    'Lesson Summary',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.lessonsTitle,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: widget.lessonData.steps.length,
                                      itemBuilder: (context, index) {
                                        final step = widget.lessonData.steps[index];
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 8),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.lessonsBorder.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: AppColors.lessonsHumanBadge,
                                                size: 20,
                                              ),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  step.title,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColors.lessonsTitle,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
