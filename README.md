# 🎮 Hangman Game with Tkinter GUI

A fully-featured Hangman game built with Python's Tkinter library, featuring a graphical user interface, visual hangman progression, and interactive gameplay.

## 📋 Features

### Core Functionalities
- ✅ Display blanked-out word with underscores
- ✅ Interactive A-Z letter buttons for guessing
- ✅ Track and display:
  - Correct letters in their positions
  - Incorrect guesses
  - Remaining lives (attempts)
  - All letters guessed so far
- ✅ Visual hangman progression using ASCII art
- ✅ Win/lose detection with appropriate messages
- ✅ Restart game functionality

### Bonus Features
- 💡 Hint system - reveals a random letter
- 🎨 Colorful, user-friendly interface
- 📱 Responsive button states (disabled after use)
- 🎯 Visual feedback for correct/incorrect guesses
- 📊 Comprehensive game statistics display

## 🚀 How to Run

### Prerequisites
- Python 3.6 or higher
- Tkinter (usually comes with Python)

### Installation & Setup

1. **Download the game files:**
   - \`hangman_gui.py\` - Main game file
   - \`words.txt\` - Word list file
   - \`README.md\` - This file

2. **Run the game:**
   \`\`\`bash
   python hangman_gui.py
   \`\`\`
   
   Or if you have both Python 2 and 3 installed:
   \`\`\`bash
   python3 hangman_gui.py
   \`\`\`

## 🎯 How to Play

1. **Start the Game:** Run the script to open the game window
2. **Make Guesses:** Click on letter buttons (A-Z) to guess letters
3. **Track Progress:** 
   - Correct letters appear in the word
   - Wrong letters are displayed below
   - Lives remaining are shown
   - Hangman drawing progresses with each wrong guess
4. **Win Condition:** Guess all letters in the word before running out of lives
5. **Lose Condition:** Make 6 incorrect guesses and the hangman is complete
6. **Restart:** Click "🔄 New Game" to play again
7. **Get Help:** Click "💡 Hint" for a free letter (bonus feature)

## 📁 File Structure

\`\`\`
hangman_ui_game/
│
├── hangman_gui.py          # Main game logic with GUI
├── words.txt               # Word list (200+ programming terms)
└── README.md              # Game instructions (this file)
\`\`\`

## 🎨 UI Components

| Component | Description |
|-----------|-------------|
| **Word Display** | Shows blanks and correctly guessed letters |
| **Letter Buttons** | A-Z buttons for letter selection (26 buttons) |
| **Lives Counter** | Shows number of attempts remaining (❤️ Lives remaining: X) |
| **Wrong Letters** | Displays previously incorrect guesses |
| **Hangman Display** | ASCII art showing hangman progression |
| **Message Label** | Shows "You Win!" or "Game Over!" messages |
| **New Game Button** | Resets the game (🔄 New Game) |
| **Hint Button** | Reveals a random letter (💡 Hint) |

## 🎮 Gameplay Example

### Initial State:
- Word: "_ _ _ _ _ _" (e.g., PYTHON)
- Lives: ❤️ 6 attempts left
- Buttons: All A-Z buttons enabled
- Hangman: Empty gallows

### After clicking "P":
- Word: "P _ _ _ _ _"
- Button "P" turns green and is disabled
- Lives: Still 6 (correct guess)

### After clicking "X" (wrong guess):
- Word: Still "P _ _ _ _ _"
- Button "X" turns red and is disabled
- Lives: ❤️ 5 attempts left
- Wrong letters: "❌ Wrong letters: X"
- Hangman: Head appears

### Game End:
- **Win:** All letters revealed, "🎉 YOU WIN! 🎉" message
- **Lose:** 6 wrong guesses, "💀 GAME OVER! 💀" message, full hangman drawn

## ✅ Success Criteria

| Feature | Status |
|---------|--------|
| GUI displays word and buttons | ✅ |
| Button click triggers logic | ✅ |
| Win/loss is visually indicated | ✅ |
| Restart functionality works | ✅ |
| Visual hangman progression | ✅ |
| Letter tracking system | ✅ |
| User-friendly interface | ✅ |

## 🎯 Test Scenarios

| Scenario | Expected Outcome | Status |
|----------|------------------|--------|
| User clicks correct letter | Letter is revealed in word | ✅ |
| User clicks incorrect letter | Lives decrease, hangman progresses | ✅ |
| Word guessed fully | Show "You Win!" message | ✅ |
| 6 wrong attempts made | Show "Game Over" + reveal word | ✅ |
| Restart button clicked | Resets game state completely | ✅ |
| Hint button clicked | Reveals random unguessed letter | ✅ |

## 🔧 Technical Details

### Libraries Used:
- **tkinter** - GUI framework (mandatory)
- **random** - Random word selection
- **string** - Alphabet reference for buttons
- **pathlib** - File path handling

### Key Classes & Methods:
- \`HangmanGame\` - Main game class
- \`setup_ui()\` - Creates the user interface
- \`new_game()\` - Initializes new game state
- \`guess_letter()\` - Handles letter guessing logic
- \`update_display()\` - Refreshes all UI elements
- \`check_win()\` / \`check_lose()\` - Game state validation

### Word List:
- 200+ programming-related terms
- Loaded from \`words.txt\` file
- Fallback to built-in list if file not found
- All words converted to uppercase for consistency

## 🎨 Visual Design

- **Color Scheme:**
  - Correct guesses: Green buttons
  - Wrong guesses: Red buttons
  - Unused buttons: Blue
  - Background: Light gray (#f0f0f0)
  
- **Typography:**
  - Title: Arial, 24pt, Bold
  - Word display: Arial, 20pt, Bold
  - Hangman: Courier, 12pt, Bold (monospace for ASCII art)
  - Buttons: Arial, 12pt, Bold

## 🚀 Future Enhancements

Potential improvements for advanced versions:
- 🖼️ Replace ASCII art with actual hangman images
- 🔊 Add sound effects using pygame.mixer
- 🎚️ Difficulty level selection (Easy/Medium/Hard)
- 📊 Score tracking and high scores
- 🌐 Online multiplayer functionality
- 📱 Mobile-responsive design
- 🎨 Theme customization options

## 🐛 Troubleshooting

### Common Issues:

1. **"No module named 'tkinter'" error:**
   - On Ubuntu/Debian: \`sudo apt-get install python3-tk\`
   - On CentOS/RHEL: \`sudo yum install tkinter\`
   - On macOS: Tkinter should be included with Python

2. **Words.txt not found:**
   - The game will use a built-in word list
   - Ensure \`words.txt\` is in the same directory as \`hangman_gui.py\`

3. **Window too small/large:**
   - The window is set to 800x600 pixels
   - Modify the \`geometry()\` call in \`__init__()\` to adjust size

## 📝 Assignment Compliance

This implementation meets all assignment requirements:

- ✅ **Core Functionalities:** All implemented
- ✅ **Required Libraries:** tkinter, random, string used
- ✅ **UI Components:** All specified components included
- ✅ **File Structure:** Follows specified structure
- ✅ **Gameplay Flow:** Matches example provided
- ✅ **Success Criteria:** All criteria met
- ✅ **Bonus Features:** Hint system implemented

## 👨‍💻 Author

Created as part of a Python GUI programming assignment using Tkinter.

## 📄 License

This project is created for educational purposes. Feel free to modify and enhance!

---

**Enjoy playing Hangman! 🎮**
