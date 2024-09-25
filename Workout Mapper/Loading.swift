//
//  Loading.swift
//  Workout Mapper
//
//  Created by Michael Bryant on 9/24/24.
//

import SwiftUI

struct Loading: View {
    
    var body: some View {
            
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.black.opacity(0.7))
            .frame(width: 300, height: 200)
            .overlay(
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                        .padding(.top, 16)
                    Text("Fetching Workouts...")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 24)
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

}

#Preview {
    Loading()
}
