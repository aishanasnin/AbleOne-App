/// A mock AI datasource simulating tutor responses for explanations, summaries, translations, and simplifications.
class FakeAIDataSource {
  /// Simulates a network call delay and matches keywords in the user's [prompt] to return educational responses.
  Future<String> getAIResponse(String prompt) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final normalized = prompt.toLowerCase().trim();

    if (normalized.contains('photosynthesis')) {
      return 'Photosynthesis is the process where plants convert sunlight into energy. Here is a simple breakdown:\n\n1. ☀️ Leaves capture sunlight.\n2. 💧 Roots absorb water.\n3. 💨 Leaves intake carbon dioxide.\n4. 🍎 The plant makes glucose (energy) and releases oxygen!';
    }

    if (normalized.contains('explain topic') || normalized.contains('explain')) {
      return 'I would be happy to explain that topic for you! Let\'s break down what you want to understand step-by-step. Just write the name of the topic, and I will explain it with simple terms and clear examples.';
    }

    if (normalized.contains('summarize') || normalized.contains('summary')) {
      return 'Here is a quick, easy-to-understand summary:\n\n• **Core Idea:** Keep reading and practicing sight words.\n• **Key Takeaway:** Repetition builds sight vocabulary.\n• **Action Item:** Focus on 3 words today and use them in a sentence.';
    }

    if (normalized.contains('quiz') || normalized.contains('question')) {
      return 'Let\'s test your knowledge! Here is a quick 1-question quiz:\n\n*Question: Which of these is a sight word?*\n\n1️⃣ Elephant\n2️⃣ Jump\n3️⃣ The\n\nChoose the number or type your answer!';
    }

    if (normalized.contains('translate') || normalized.contains('translation')) {
      return 'I can translate phrases to make learning inclusive! For example:\n\n• **Spanish:** "Hello, welcome!" becomes *"Hola, ¡bienvenido!"*\n• **French:** "Learn with me" becomes *"Apprends avec moi"*\n\nLet me know what text you would like to translate and into which language!';
    }

    if (normalized.contains('simplify') || normalized.contains('simple')) {
      return 'Let\'s make that simpler to understand! Instead of long academic terms, think of it this way:\n\n*Normal text:* "Cognitive comprehension requires active retention."\n*Simplified:* "Learning is about remembering and practicing what you read!"';
    }

    // Default friendly fallback
    return 'That is a great question! As your AbleOne AI Tutor, I am here to help you explain complex topics, summarize lessons, translate words, or simplify concepts. What would you like to learn today?';
  }
}
