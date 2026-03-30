import SwiftUI
import UIKit

/// Temporary view to debug and find the exact font name
/// Use this to find the PostScript name of your custom font
struct FontDebugView: View {
    @State private var fontNames: [String] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Available Fonts")
                    .font(.title)
                    .bold()
                    .padding()
                
                if fontNames.isEmpty {
                    Button("Load All Fonts") {
                        loadFonts()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                } else {
                    // Search for Expo Arabic
                    let expoFonts = fontNames.filter { 
                        $0.lowercased().contains("expo") || 
                        $0.lowercased().contains("arabic")
                    }
                    
                    if !expoFonts.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("🎯 Expo Arabic Fonts Found:")
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding(.horizontal)
                            
                            ForEach(expoFonts, id: \.self) { font in
                                VStack(alignment: .leading) {
                                    Text(font)
                                        .font(.custom(font, size: 16))
                                        .foregroundColor(.blue)
                                    
                                    Text("مرحباً بك في مراسم")
                                        .font(.custom(font, size: 20))
                                    
                                    Text("Hello Welcome to Mrasem")
                                        .font(.custom(font, size: 20))
                                    
                                    Divider()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom)
                    }
                    
                    // Show all fonts
                    ForEach(fontNames, id: \.self) { font in
                        Text(font)
                            .font(.system(size: 14))
                            .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear {
            loadFonts()
        }
    }
    
    private func loadFonts() {
        var allFonts: [String] = []
        
        for family in UIFont.familyNames.sorted() {
            print("Family: \(family)")
            for font in UIFont.fontNames(forFamilyName: family) {
                print("  - \(font)")
                allFonts.append(font)
            }
        }
        
        fontNames = allFonts.sorted()
    }
}

#Preview {
    FontDebugView()
}






