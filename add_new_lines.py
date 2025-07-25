import json

# Load the current JSON
with open('assets/data/pickup_lines.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# New lines to add to each category
new_lines = {
    "sweet": [
        "Are you a time traveler? Because I see you in my future",
        "When I see you, I feel like the heavens have opened up for me",
        "You can fall from the sky. You can fall from a tree. But the best way is to fall in love with me",
        "A doctor said that I need vitamin 'U'",
        "I must be a snowflake, because I am just falling for you",
        "You are like water, I can't live without you",
        "My WI-FI is 4G but my heart is 4U",
        "I can't turn water to be wine, but I can turn you to be mine!",
        "Your hands looks heavy, should I hold them for you?",
        "I can't see any stars in the sky tonight, the most heavenly body is standing right next to me now"
    ],
    "witty": [
        "Do you work for CIA? Because you are cute, intelligent and attractive!",
        "Can you replace my X without asking Y?",
        "Are you an electrician? Because you're definitely lighting up my day!",
        "Are you from Tennessee? Because you're the only ten--see!",
        "Is Your Birthday October 10? No Wonder You Are 10/10.",
        "Are you a Manchester fan? I feel we are united",
        "People are catching corona, but I'm just catching feelings for you!",
        "I was just playing chess and I'm missing a queen - here you are!",
        "Are you Wi-fi? I feel a connection!",
        "You are like Google, you have everything I am looking for"
    ],
    "flirty": [
        "Do you know who I am? I'm your boyfriend!",
        "How do you use no pen and paper, but still draw my attention?",
        "Can I take a photo of you? I want to show Santa what I want for Christmas",
        "I have been thinking about you from AM to PM so I decided to DM",
        "I was gonna say something really sweet about you, but when I saw you I was speechless",
        "Baby, I need some answers for my math homework. What is your number?",
        "I always follow my dream, so I am going to follow you home",
        "I got blinded because of your beauty, I need your name and number for insurance purposes"
    ],
    "spicy": [
        "Do you care about the planet? Let's have shower together to save the water",
        "Sex burns a lot of calories. How about some workout?",
        "All your curves and me person with no brakes!",
        "You are like my boss, you give me a raise!",
        "I can be your slave tonight",
        "Are you a trampoline? Because I was about to jump on you!",
        "Now I know why we have global warming, you are so hot!",
        "Do you feel cold? Maybe want to use me as a blanket?"
    ],
    "dirty": [
        "I want 70 things. 1 is you and rest 69 we do together!",
        "Let's do some math, let's add the bed, subtract the clothes, divide the legs and I hope we don't multiply",
        "Roses are red, violets are fine, you be the 6 I'll be the 9",
        "Do you have any extra room in your mouth for my tongue?",
        "Treat me like a homework, put me on the table and do me all day long",
        "Hi, I have big toes. Do you know what this mean?",
        "Does your dad work in a bakery, you have a nice set of buns",
        "Do you work at subway? Because you just gave me a foot long"
    ],
    "seductive": [
        "Roses are red, your being very bratty, turn that ass around, so I can make you call me daddy.",
        "You're like a rental car. Everybody pays to ride you",
        "Roses are red, lemons are sour, open your legs and give me an hour",
        "Girl I want to kiss that lips... but firstly the ones on your face",
        "Baby, I have something nice to do that rhymes with 'truck'",
        "I am a rollercoaster. You know why? Cause the faster I go, the louder you'll scream"
    ],
    "compliments": [
        "Even the sun tries to shine as bright as you!",
        "You must be an alien, because you look out of this world!",
        "Your beauty shines so much, that it makes me blind",
        "In this world, there are things that money can't buy. You seem to be one of those things",
        "What did God use that you are so beautiful?",
        "I didn't know angels are allowed in my city",
        "I must be in the heaven. I am looking at an angel!"
    ]
}

# Add new lines to each category
for category in data:
    category_id = category['category_id']
    if category_id in new_lines:
        category['messages'].extend(new_lines[category_id])
        print(f"Added {len(new_lines[category_id])} lines to {category['category_name']}")

# Save the updated JSON
with open('assets/data/pickup_lines.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Successfully updated pickup_lines.json!")
print(f"Total categories: {len(data)}")
for category in data:
    print(f"- {category['category_name']}: {len(category['messages'])} messages")
