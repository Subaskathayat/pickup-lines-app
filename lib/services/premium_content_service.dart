import '../models/category.dart';
import 'pickup_lines_service.dart';

/// Service to manage premium-exclusive content
class PremiumContentService {
  static final PremiumContentService _instance =
      PremiumContentService._internal();
  factory PremiumContentService() => _instance;
  PremiumContentService._internal();

  static PremiumContentService get instance => _instance;

  /// Get the Top Secret category (premium exclusive)
  /// Now loads from JSON instead of hardcoded data
  Future<Category?> getTop100FavsCategory() async {
    final premiumCategories =
        await PickupLinesService.instance.loadPremiumCategories();

    try {
      return premiumCategories
          .firstWhere((category) => category.id == 'top100_premium');
    } catch (e) {
      // Return null if category not found
      return null;
    }
  }

  /// Get the Top Secret category synchronously (for backward compatibility)
  /// This method is deprecated and will be removed in future versions
  @Deprecated('Use getTop100FavsCategory() instead')
  Category getTop100FavsCategorySync() {
    return Category(
      id: 'top100_premium',
      name: 'Top Secret',
      icon: '💎',
      texts: _getTop100FavsLines(),
    );
  }

  /// Premium-exclusive Top Secret pickup lines
  List<String> _getTop100FavsLines() {
    return [
      "I hope you know CPR, because you just took my breath away!",
      "Your eyes are like the ocean; I could swim in them all day.",
      "I never believed in love at first sight, but that was before I saw you.",
      "They say Disney World is the happiest place on Earth, but clearly they've never stood next to you.",
      "I must be in a museum because you're a piece of art.",
      "If beauty were time, you'd be eternity.",
      "I swear someone stole the stars from the sky and put them in your eyes.",
      "Wow, when God made you, he was seriously showing off.",
      "Well, here I am! What are your other two wishes?",
      "I can't help but smile whenever I think about you.",
      "Are you a magician? Because whenever I look at you, everyone else disappears.",
      "Do you have a map? I keep getting lost in your eyes.",
      "If you were a vegetable, you'd be a cute-cumber.",
      "Are you made of copper and tellurium? Because you're Cu-Te.",
      "I must be a snowflake because I've fallen for you.",
      "Do you believe in love at first sight, or should I walk by again?",
      "Are you a parking ticket? Because you've got 'fine' written all over you.",
      "If I could rearrange the alphabet, I'd put U and I together.",
      "Are you a camera? Because every time I look at you, I smile.",
      "Do you have a Band-Aid? Because I just scraped my knee falling for you.",
      "Are you WiFi? Because I'm feeling a connection.",
      "If you were a triangle, you'd be acute one.",
      "Are you a time traveler? Because I see you in my future.",
      "Do you have a sunburn, or are you always this hot?",
      "Are you a loan from a bank? Because you have my interest.",
      "If you were a fruit, you'd be a fineapple.",
      "Are you Google? Because you have everything I've been searching for.",
      "Do you have a name, or can I call you mine?",
      "Are you a campfire? Because you're hot and I want s'more.",
      "If you were a cat, you'd purr-fect.",
      "Are you a beaver? Because daaaaam.",
      "Do you like Star Wars? Because Yoda one for me!",
      "Are you a 45-degree angle? Because you're acute-y.",
      "If you were a burger at McDonald's, you'd be the McGorgeous.",
      "Are you my phone charger? Because without you, I'd die.",
      "Do you have a quarter? Because I want to call my mom and tell her I met 'the one.'",
      "Are you a dictionary? Because you add meaning to my life.",
      "If you were a vegetable, you'd be a cute-cumber... wait, I already used that one. You're just that cute!",
      "Are you a magnet? Because you're attracting me over here.",
      "Do you have a pencil? Because I want to erase your past and write our future.",
      "Are you a bank loan? Because you have my interest and I'd like to take you out.",
      "If you were a song, you'd be the best track on the album.",
      "Are you a fire alarm? Because you're loud, annoying, and you wake me up.",
      "Do you have a mirror in your pocket? Because I can see myself in your pants.",
      "Are you a keyboard? Because you're just my type.",
      "If you were a pizza topping, you'd be supreme.",
      "Are you a tornado? Because you're spinning my world around.",
      "Do you have a GPS? Because I'm getting lost in your eyes.",
      "Are you a light bulb? Because you brighten up my day.",
      "If you were a superhero, you'd be Super-fine.",
      "Are you a thief? Because you stole my heart.",
      "Do you have a library card? Because I'm checking you out.",
      "Are you a volcano? Because I lava you.",
      "If you were a season, you'd be summer, because you're hot.",
      "Are you a chef? Because you're cooking up some serious feelings in me.",
      "Do you have a twin? Because you're twice as beautiful as anyone else.",
      "Are you a scientist? Because you've got my heart under a microscope.",
      "If you were a movie, you'd be a blockbuster.",
      "Are you a rainbow? Because you color my world.",
      "Do you have a compass? Because I'm lost without you.",
      "Are you a flower? Because you're blooming beautiful.",
      "If you were a book, you'd be a bestseller.",
      "Are you a star? Because you light up my night.",
      "Do you have a watch? Because I want to spend time with you.",
      "Are you a puzzle? Because I'm trying to figure you out.",
      "If you were a drink, you'd be a fine wine.",
      "Are you a garden? Because you make my heart grow.",
      "Do you have a key? Because you unlock my heart.",
      "Are you a sunrise? Because you make my day brighter.",
      "If you were a dance, you'd be a waltz, because you're elegant.",
      "Are you a poem? Because you're beautiful and I can't stop reading you.",
      "Do you have a flashlight? Because you light up my world.",
      "Are you a treasure? Because you're worth searching for.",
      "If you were a color, you'd be the most beautiful shade.",
      "Are you a melody? Because you're music to my ears.",
      "Do you have a parachute? Because you make my heart skip.",
      "Are you a dream? Because I never want to wake up.",
      "If you were a gem, you'd be a diamond.",
      "Are you a butterfly? Because you make my heart flutter.",
      "Do you have a magic wand? Because you've cast a spell on me.",
      "Are you a sunset? Because you're breathtakingly beautiful.",
      "If you were a story, you'd have a happy ending.",
      "Are you a constellation? Because you're written in the stars.",
      "Do you have a heart? Because you've stolen mine.",
      "Are you a miracle? Because meeting you feels like one.",
      "If you were a wish, you'd be the one that comes true.",
      "Are you an angel? Because heaven is missing one.",
      "Do you have wings? Because you've lifted my spirits.",
      "Are you a blessing? Because you've made my day.",
      "If you were a prayer, you'd be answered.",
      "Are you a gift? Because you're exactly what I've been hoping for.",
      "Do you have a halo? Because you're glowing.",
      "Are you a fairy tale? Because you're too good to be true.",
      "If you were a crown, you'd be fit for a queen.",
      "Are you a jewel? Because you're precious to me.",
      "Do you have a throne? Because you rule my heart.",
      "Are you royalty? Because you're treating me like a king.",
      "If you were a castle, you'd be my home.",
      "Are you a knight? Because you've rescued my heart.",
      "Do you have armor? Because you've protected my feelings.",
      "Are you a quest? Because I'd travel anywhere for you.",
      "If you were a legend, you'd be the greatest story ever told.",
      "Are you magic? Because you've transformed my world.",
      "Do you have a spell book? Because you've enchanted me.",
      "Are you a potion? Because you've made me fall under your spell.",
      "If you were a wizard, you'd be the most powerful one.",
      "Are you a crystal ball? Because I see my future with you."
    ];
  }
}
