import 'package:ableone_app/features/ai/domain/entities/ai_context_entity.dart';

/// A mock AI datasource simulating tutor responses for explanations, summaries, translations, and simplifications.
class FakeAIDataSource {
  /// Simulates a network call delay and matches keywords in the user's [prompt] to return educational responses.
  Future<String> getAIResponse(String prompt, AIContextEntity context) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final normalized = prompt.toLowerCase().trim();
    String responseText = '';

    if (normalized.contains('photosynthesis')) {
      responseText = 'Photosynthesis is the process where plants convert sunlight into energy. Here is a simple breakdown:\n\n1. ☀️ Leaves capture sunlight.\n2. 💧 Roots absorb water.\n3. 💨 Leaves intake carbon dioxide.\n4. 🍎 The plant makes glucose (energy) and releases oxygen!';
    } else if (normalized.contains('explain topic') || normalized.contains('explain')) {
      responseText = 'I would be happy to explain that topic for you! Let\'s break down what you want to understand step-by-step. Just write the name of the topic, and I will explain it with simple terms and clear examples.';
    } else if (normalized.contains('summarize') || normalized.contains('summary')) {
      responseText = 'Here is a quick, easy-to-understand summary:\n\n• **Core Idea:** Keep reading and practicing sight words.\n• **Key Takeaway:** Repetition builds sight vocabulary.\n• **Action Item:** Focus on 3 words today and use them in a sentence.';
    } else if (normalized.contains('quiz') || normalized.contains('question')) {
      responseText = 'Let\'s test your knowledge! Here is a quick 1-question quiz:\n\n*Question: Which of these is a sight word?*\n\n1️⃣ Elephant\n2️⃣ Jump\n3️⃣ The\n\nChoose the number or type your answer!';
    } else if (normalized.contains('translate') || normalized.contains('translation')) {
      responseText = 'I can translate phrases to make learning inclusive! For example:\n\n• **Spanish:** "Hello, welcome!" becomes *"Hola, ¡bienvenido!"*\n• **French:** "Learn with me" becomes *"Apprends avec moi"*\n\nLet me know what text you would like to translate and into which language!';
    } else if (normalized.contains('simplify') || normalized.contains('simple')) {
      responseText = 'Let\'s make that simpler to understand! Instead of long academic terms, think of it this way:\n\n*Normal text:* "Cognitive comprehension requires active retention."\n*Simplified:* "Learning is about remembering and practicing what you read!"';
    } else {
      responseText = 'That is a great question! As your AbleOne AI Tutor, I am here to help you explain complex topics, summarize lessons, translate words, or simplify concepts. What would you like to learn today?';
    }

    // Append context-based formatting footnote
    final supportDesc = context.accessibilityNeeds.isEmpty ? 'General Support' : context.accessibilityNeeds.join(', ');
    final suffix = '\n\n*(Tailored for: Level ${context.userLevel} • ${context.learningPreference} • $supportDesc)*';

    return '$responseText$suffix';
  }
}
