//
//  AuthorizationTutorial.swift
//  Workout Mapper
//
//  Created by Michael Bryant on 9/24/24.
//

import SwiftUI

struct AuthorizationTutorial: View {
    var authorizeUser: () -> Void
    
    var body: some View {
            
        VStack {
            Text("Please Authorize to Access Your Fitness Data")
                .font(.headline)
                .padding()
            
            Text("To provide personalized fitness maps, this app needs access to your workout data. Please follow the steps below:")
                .multilineTextAlignment(.center)
                .padding()
            
            Text("1. Go to your device's Settings.\n2. Scroll down and find this app.\n3. Tap on 'Health' and enable access to 'Workouts' and 'Workout Routes'.")
                .padding()
                .foregroundColor(.secondary)
            
            // Optionally, add a button to retry authorization if needed
            Button(action: {
                authorizeUser()
            }) {
                Text("Retry Authorization")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }

}

#Preview {
    AuthorizationTutorial(authorizeUser: {
        print("Authorization function called!")
    })
}
