import tkinter as tk
from tkinter import messagebox, font
import random
import string
from pathlib import Path 

class HangmanGame:
    def __init__(self, root):
        self.root = root
        self.root.title("Hangman Game")
        self.root.geometry("800x600")
        self.root.configure(bg="#f0f0f0")
        
        # Game state variables
        self.words = self.load_words()
        self.current_word = ""
        self.guessed_letters = set()
        self.wrong_letters = set()
        self.max_attempts = 6
        self.attempts_left = self.max_attempts
        self.game_over = False
        
        # Hangman ASCII art stages
        self.hangman_stages = [
            "",  # 0 wrong guesses
            "  +---+\n      |\n      |\n      |\n      |\n      |\n=========",  # 1
            "  +---+\n  |   |\n      |\n      |\n      |\n      |\n=========",  # 2
            "  +---+\n  |   |\n  O   |\n      |\n      |\n      |\n=========",  # 3
            "  +---+\n  |   |\n  O   |\n  |   |\n      |\n      |\n=========",  # 4
            "  +---+\n  |   |\n  O   |\n /|   |\n      |\n      |\n=========",  # 5
            "  +---+\n  |   |\n  O   |\n /|\\  |\n      |\n      |\n=========",  # 6
            "  +---+\n  |   |\n  O   |\n /|\\  |\n /    |\n      |\n=========",  # 7 (game over)
        ]
        
        self.setup_ui()
        self.new_game()
    
    def load_words(self):
        """Load words from words.txt file or use default list"""
        try:
            with open('words.txt', 'r') as file:
                words = [word.strip().upper() for word in file.readlines() if word.strip()]
                return words if words else self.get_default_words()
        except FileNotFoundError:
            return self.get_default_words()
    
    def get_default_words(self):
        """Default word list if words.txt is not found"""
        return [
            "PYTHON", "PROGRAMMING", "COMPUTER", "SCIENCE", "ALGORITHM",
            "FUNCTION", "VARIABLE", "LOOP", "CONDITION", "ARRAY",
            "STRING", "INTEGER", "BOOLEAN", "CLASS", "OBJECT",
            "METHOD", "LIBRARY", "FRAMEWORK", "DATABASE", "NETWORK"
        ]
    
    def setup_ui(self):
        """Setup the user interface"""
        # Title
        title_font = font.Font(family="Arial", size=24, weight="bold")
        title_label = tk.Label(self.root, text="🎮 HANGMAN GAME 🎮", 
                              font=title_font, bg="#f0f0f0", fg="#2c3e50")
        title_label.pack(pady=20)
        
        # Main frame
        main_frame = tk.Frame(self.root, bg="#f0f0f0")
        main_frame.pack(expand=True, fill="both", padx=20, pady=10)
        
        # Left side - Hangman display
        left_frame = tk.Frame(main_frame, bg="#f0f0f0")
        left_frame.pack(side="left", fill="both", expand=True)
        
        # Hangman display
        hangman_font = font.Font(family="Courier", size=12, weight="bold")
        self.hangman_label = tk.Label(left_frame, text="", font=hangman_font,
                                     bg="#f0f0f0", fg="#e74c3c", justify="left")
        self.hangman_label.pack(pady=20)
        
        # Right side - Game info
        right_frame = tk.Frame(main_frame, bg="#f0f0f0")
        right_frame.pack(side="right", fill="both", expand=True)
        
        # Word display
        word_font = font.Font(family="Arial", size=20, weight="bold")
        self.word_label = tk.Label(right_frame, text="", font=word_font,
                                  bg="#f0f0f0", fg="#2c3e50")
        self.word_label.pack(pady=20)
        
        # Game info frame
        info_frame = tk.Frame(right_frame, bg="#f0f0f0")
        info_frame.pack(pady=10)
        
        # Attempts left
        self.attempts_label = tk.Label(info_frame, text="", font=("Arial", 14),
                                      bg="#f0f0f0", fg="#27ae60")
        self.attempts_label.pack(pady=5)
        
        # Wrong letters
        self.wrong_label = tk.Label(info_frame, text="", font=("Arial", 12),
                                   bg="#f0f0f0", fg="#e74c3c", wraplength=300)
        self.wrong_label.pack(pady=5)
        
        # Message label
        self.message_label = tk.Label(right_frame, text="", font=("Arial", 16, "bold"),
                                     bg="#f0f0f0", fg="#8e44ad")
        self.message_label.pack(pady=20)
        
        # Letter buttons frame
        buttons_frame = tk.Frame(self.root, bg="#f0f0f0")
        buttons_frame.pack(pady=20)
        
        # Create letter buttons
        self.letter_buttons = {}
        button_font = font.Font(family="Arial", size=12, weight="bold")
        
        # First row (A-M)
        row1_frame = tk.Frame(buttons_frame, bg="#f0f0f0")
        row1_frame.pack(pady=5)
        for i, letter in enumerate(string.ascii_uppercase[:13]):
            btn = tk.Button(row1_frame, text=letter, font=button_font,
                           width=3, height=1, bg="#3498db", fg="white",
                           activebackground="#2980b9", activeforeground="white",
                           command=lambda l=letter: self.guess_letter(l))
            btn.pack(side="left", padx=2)
            self.letter_buttons[letter] = btn
        
        # Second row (N-Z)
        row2_frame = tk.Frame(buttons_frame, bg="#f0f0f0")
        row2_frame.pack(pady=5)
        for i, letter in enumerate(string.ascii_uppercase[13:]):
            btn = tk.Button(row2_frame, text=letter, font=button_font,
                           width=3, height=1, bg="#3498db", fg="white",
                           activebackground="#2980b9", activeforeground="white",
                           command=lambda l=letter: self.guess_letter(l))
            btn.pack(side="left", padx=2)
            self.letter_buttons[letter] = btn
        
        # Control buttons frame
        control_frame = tk.Frame(self.root, bg="#f0f0f0")
        control_frame.pack(pady=20)
        
        # Restart button
        restart_btn = tk.Button(control_frame, text="🔄 New Game", font=("Arial", 14, "bold"),
                               bg="#27ae60", fg="white", padx=20, pady=10,
                               activebackground="#229954", activeforeground="white",
                               command=self.new_game)
        restart_btn.pack(side="left", padx=10)
        
        # Hint button (bonus feature)
        hint_btn = tk.Button(control_frame, text="💡 Hint", font=("Arial", 14, "bold"),
                            bg="#f39c12", fg="white", padx=20, pady=10,
                            activebackground="#e67e22", activeforeground="white",
                            command=self.show_hint)
        hint_btn.pack(side="left", padx=10)
    
    def new_game(self):
        """Start a new game"""
        self.current_word = random.choice(self.words)
        self.guessed_letters = set()
        self.wrong_letters = set()
        self.attempts_left = self.max_attempts
        self.game_over = False
        
        # Reset UI
        self.update_display()
        self.message_label.config(text="Guess the word! Click letters to make your guess.")
        
        # Enable all letter buttons
        for button in self.letter_buttons.values():
            button.config(state="normal", bg="#3498db")
    
    def guess_letter(self, letter):
        """Handle letter guess"""
        if self.game_over or letter in self.guessed_letters:
            return
        
        self.guessed_letters.add(letter)
        
        # Disable the button and change color
        self.letter_buttons[letter].config(state="disabled")
        
        if letter in self.current_word:
            # Correct guess
            self.letter_buttons[letter].config(bg="#27ae60")
            self.check_win()
        else:
            # Wrong guess
            self.letter_buttons[letter].config(bg="#e74c3c")
            self.wrong_letters.add(letter)
            self.attempts_left -= 1
            self.check_lose()
        
        self.update_display()
    
    def update_display(self):
        """Update the game display"""
        # Update word display
        display_word = ""
        for letter in self.current_word:
            if letter in self.guessed_letters:
                display_word += letter + " "
            else:
                display_word += "_ "
        self.word_label.config(text=display_word.strip())
        
        # Update attempts left
        self.attempts_label.config(text=f"❤️ Lives remaining: {self.attempts_left}")
        
        # Update wrong letters
        if self.wrong_letters:
            wrong_text = f"❌ Wrong letters: {', '.join(sorted(self.wrong_letters))}"
        else:
            wrong_text = "❌ Wrong letters: None"
        self.wrong_label.config(text=wrong_text)
        
        # Update hangman display
        wrong_count = self.max_attempts - self.attempts_left
        if wrong_count < len(self.hangman_stages):
            self.hangman_label.config(text=self.hangman_stages[wrong_count])
    
    def check_win(self):
        """Check if player has won"""
        if all(letter in self.guessed_letters for letter in self.current_word):
            self.game_over = True
            self.message_label.config(text="🎉 YOU WIN! 🎉", fg="#27ae60")
            self.disable_all_buttons()
            messagebox.showinfo("Congratulations!", f"You won! The word was: {self.current_word}")
    
    def check_lose(self):
        """Check if player has lost"""
        if self.attempts_left <= 0:
            self.game_over = True
            self.message_label.config(text="💀 GAME OVER! 💀", fg="#e74c3c")
            self.disable_all_buttons()
            # Show final hangman stage
            self.hangman_label.config(text=self.hangman_stages[-1])
            messagebox.showinfo("Game Over!", f"You lost! The word was: {self.current_word}")
    
    def disable_all_buttons(self):
        """Disable all letter buttons"""
        for button in self.letter_buttons.values():
            if button.cget("state") != "disabled":
                button.config(state="disabled", bg="#95a5a6")
    
    def show_hint(self):
        """Show a hint for the current word (bonus feature)"""
        if self.game_over:
            return
        
        # Simple hint system - reveal a random unguessed letter
        unguessed = [letter for letter in self.current_word if letter not in self.guessed_letters]
        if unguessed:
            hint_letter = random.choice(unguessed)
            self.guess_letter(hint_letter)
            messagebox.showinfo("Hint!", f"Here's a hint: The letter '{hint_letter}' is in the word!")

def main():
    root = tk.Tk()
    game = HangmanGame(root)
    root.mainloop()

if __name__ == "__main__":
    main()