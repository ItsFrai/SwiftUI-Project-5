//
//  ContentView.swift
//  Scramble
//
//  Created by Fraidoon Pourooshasb on 6/18/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        
                NavigationView {
                    List {
                        Section(header: Text("Current Word to Scramble:  \(rootWord)").foregroundColor(.black).bold()) {
                            TextField("Enter your word here", text: $newWord).autocapitalization(.none)
                        }
                        Section {
                            ForEach(usedWords, id: \.self) { word in
                                HStack {
                                    Image(systemName: "\(word.count).circle")
                                    Text(word)
                                }
                            }
                        }
                    }
                    .background(LinearGradient(
                        gradient: Gradient(colors: [.yellow,.red,.purple,.black]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Scramble")
                    .onSubmit(addNewWord)
                    .onAppear(perform: startGame)
                    .alert(isPresented: $showingError) {
                        Alert(title: Text(errorTitle),message: Text(errorMessage), dismissButton: .cancel(Text("OK")))
                    }
                    .toolbar {
                        Button("Restart", action: RestartGame)
                    }
                    
                }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "Be more original")
            return
        
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "Unknown word")
            return
        }
        guard answer != rootWord else {
                wordError(title: "Same as start word", message: "Please enter a different word.")
                return
            }
            
        guard answer.count >= 3 else {
                wordError(title: "Word too short", message: "Enter a word with at least three letters.")
                return
            }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: ".txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load")
    }
    
    func isOriginal(word:String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word:String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word:String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError (title:String, message:String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    func RestartGame() {
        usedWords = []
        newWord = ""
        startGame()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
