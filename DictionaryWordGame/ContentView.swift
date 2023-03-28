//
//  ContentView.swift
//  DictionaryWordGame
//
//  Created by Fiona Kate Morgan on 28/03/2023.
//

import SwiftUI

struct ContentView: View {
    @State var inputText = ""
    @State var guessedWords: [String] = []
    @State var validWords: [String] = []
    @State var correctWord = ""
    @State var gameEnded = false
    @FocusState var wordInFocus: Bool
    @State var counter = 0
    
    var body: some View {
        VStack {
            TextField("Please enter your word", text: $inputText)
                .focused($wordInFocus)
                .onSubmit {
                    checkWord()
                }
                .padding()
            
            List {
                ForEach(guessedWords.sorted(), id: \.self) { word in
                    if word == correctWord {
                        if gameEnded {
                            Text(word)
                                .foregroundColor(.green)
                        } else {
                            Text("???")
                        }
                    } else {
                        Text(word)
                    }
                }
            }
            .onAppear() {
                validWords = loadWords(for: "valid-words")
                loadCorrectWord()
            }
            .alert(isPresented: $gameEnded) {
                Alert(title: Text("Well done"),
                      message: Text("You guessed the word was \"\(correctWord)\""),
                      primaryButton: .default(Text("New Game")) {
                    resetGame()
                },
                      secondaryButton: .cancel())
                
            }
        }
    }
    
    func checkWord() {
        // is it correct?
        if inputText.lowercased() == correctWord {
            
            counter += 1
            print("well done")
            gameEnded = true
            
        } else if validWords.contains(inputText.lowercased()) {
            counter += 1
            
            // append it to guessed words array
            guessedWords.append(inputText.lowercased())
            // reset input text
            inputText = ""
            wordInFocus = true
        }
    }
    
    func loadWords(for filename: String) -> [String] {
        var words: [String] = []
        
        if let wordsURL = Bundle.main.url(forResource: filename, withExtension: "json") {
            
            if let data = try? Data(contentsOf: wordsURL) {
                
                if let json = parseStrings(json: data) {
                    
                    for item in json {
                        if let word = item.1.dictionaryValue.first?.value.rawValue {
                            words.append("\(word)")
                        }
                    }
                }
            }
        }
        return words
    }
    
    func loadCorrectWord() {
        correctWord = loadWords(for: "correct-words").randomElement() ?? "house"
        print("correct word: \(correctWord)")
        guessedWords.append(correctWord)
    }
    
    func resetGame() {
        guessedWords = []
        loadCorrectWord()
        inputText = ""
        counter = 0
    }
}
