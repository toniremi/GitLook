//
//  Loading.swift
//  GitLook
//
//  Created by Antoni Remeseiro Alfonso on 2025/06/18.
//
import SwiftUI

struct LoadingView: View {
    // make it optional
    var loadingText: String? = nil
    
    @State private var scale = false
    
    // create an init so we can construct this view with loading text optionally
    init(loadingText: String? = nil, scale: Bool = false) {
        self.loadingText = loadingText
        self.scale = scale
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                ForEach(0..<6) { i in
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 8, height: 30)
                        .scaleEffect(scale ? 1 : 0.5, anchor: .bottom)
                        .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.1), value: scale)
                }
            }
            .foregroundColor(.primary)
            .onAppear { scale.toggle() }
            
            // if our loading text is not empty then show it
            if let text = loadingText {
                Text(text) // Using the new myName constant
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(loadingText: "Loading ...")
            .previewLayout(.sizeThatFits)
    }
}
