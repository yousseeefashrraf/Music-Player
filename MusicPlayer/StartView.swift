//
//  StartView.swift
//  MusicPlayer
//
//  Created by Youssef Ashraf on 12/04/2025.
//

import SwiftUI

struct StartView: View {
    @Binding var isNew: Bool
    var body: some View {
        ZStack{
            Color(.black)
            
            VStack{
                Image(systemName: "music.note")
                    .resizable()
                    .foregroundStyle(LinearGradient(colors: [.blue,.white, .blue], startPoint: .trailing, endPoint: .leading))
                    .scaledToFit()
                    .frame(width: 200)
                    .padding(.top, UIScreen.main.bounds.height * 0.2)
                
                VStack(alignment: .leading, spacing: 10){
                    Text("Feel The Rythem").foregroundStyle(LinearGradient(colors: [.blue,.white, .blue], startPoint: .trailing, endPoint: .leading))
                    
                    Text("Live  the beat").foregroundStyle(LinearGradient(colors: [.blue,.white, .blue], startPoint: .trailing, endPoint: .leading))
                }
                .font(.largeTitle)
                .padding(.top, 50)
                
                .bold()
                Spacer()
                Button(){
                    isNew = false
                }label: {
                    Text ("Next")
                        .foregroundStyle(.white)
                        .font(.title)
                        .bold()
                        .frame(width: 315, height: 67)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                                
                        
                }
            }
            .padding(.bottom, 50)
            
                
        }
        .ignoresSafeArea()
    }
}

#Preview {
    StartView(isNew: .constant(false))
}
