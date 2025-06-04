//
//  ContentView.swift
//  RoomBloom
//
//  Created by Jakob Mösenbacher on 28.04.25.
//


import SwiftUI

struct ContentView: View {
    @State private var selectedCard: Int? = nil
    @State private var showAlert = false
    @State private var navigateToAR = false

    let images = ["redChair", "gramophone", "coffeCup", "guitar", "pancakes", "robot"]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("RoomBloom")
                    .font(.largeTitle)
                    .bold()
                    .padding([.top, .horizontal])

                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 24), count: 2), spacing: 24) {
                        ForEach(0..<images.count, id: \.self) { index in
                            CardView(imageName: images[index], isSelected: selectedCard == index)
                                .onTapGesture {
                                    selectedCard = selectedCard == index ? nil : index
                                }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer().frame(height: 40)

                Button(action: {
                    if selectedCard != nil {
                        navigateToAR = true
                    } else {
                        showAlert = true
                    }
                }) {
                    Label("Starte AR-Erlebnis", systemImage: "arkit")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Fehler"),
                          message: Text("Bitte wähle ein Modell aus."),
                          dismissButton: .default(Text("OK")))
                }

                // Versteckter NavigationLink
                NavigationLink(
                    destination: ARViewContainer(imageName: selectedCard != nil ? images[selectedCard!] : ""),
                    isActive: $navigateToAR
                ) {
                    EmptyView()
                }

                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct CardView: View {
    var imageName: String
    var isSelected: Bool

    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 90)
                .clipped()
                .cornerRadius(8)
        }
        .frame(width: 150, height: 110)
        .background(isSelected ? Color.blue.opacity(0.7) : Color.blue)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(isSelected ? 1 : 0), lineWidth: 2)
        )
        .shadow(radius: isSelected ? 6 : 2)
        .animation(.easeInOut, value: isSelected)
    }
}
