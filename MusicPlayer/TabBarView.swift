//
//  TabBarView.swift
//  MusicPlayer
//
//  Created by Youssef Ashraf on 17/04/2025.
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject var songViewModel = SongsViewModel()
    @StateObject var audioManagerViewModel: AudioManagerViewModel = AudioManagerViewModel()
    @State var selection = 0
    @State var isSheetUp = false
    var body: some View {
        ZStack{
            Color.black
            VStack{
                let color: Color = audioManagerViewModel.currentMusic != nil ? audioManagerViewModel.commonBrightColors.colorTwo : .brown
                switch selection{
                case 0:
                    HomePageView(songViewModel: songViewModel, audioManagerViewModel: audioManagerViewModel, isSheetUp: $isSheetUp)
                    
                default:
                    Text("")
                }
                
                
                HStack(alignment: .center){
                    Button{
                        selection = 0
                    } label:{
                        VStack{
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .foregroundStyle(selection == 0 ? color : .gray)
                    }
                    
                    Spacer()
                    
                    Button{
                        selection = 1
                    } label:{
                        VStack{
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                        .foregroundStyle(selection == 1 ? color : .gray)
                    }
                    
                    
                    Spacer()
                    
                    Button{
                        selection = 2
                    } label:{
                        VStack{
                            Image(systemName: "sparkles.rectangle.stack.fill")
                            Text("Library")
                                .foregroundStyle(selection == 2 ? color : .gray)
                        }
                    }
                    
                    
                    
                }
                .frame(height: 35, alignment: .center)
                .padding(.horizontal,50)
                .foregroundStyle(.gray)
                .padding(.vertical, 10)
                
            }
            .background(.thinMaterial)
        }
        .background(Color.black.ignoresSafeArea())
        
    }
}



#Preview {
    TabBarView()
}
