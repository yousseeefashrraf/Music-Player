//
//  MusicPlayerMainView.swift
//  MusicPlayer
//
//  Created by Youssef Ashraf on 12/04/2025.
//

import SwiftUI

struct MusicPlayerMainView: View {
    @StateObject var audioManagerViewModel: AudioManagerViewModel

    var body: some View {
        ZStack{
                let colors = audioManagerViewModel.commonColors
            LinearGradient(colors: [colors.colorTwo, colors.colorOne], startPoint: .topLeading, endPoint: .bottomTrailing)
                .blur(radius: 5)

            

            VStack{
                Spacer()
                Spacer()
                Image(audioManagerViewModel.currentMusic?.imageName ?? "")
                    .resizable()
                    .scaledToFill()
                    .frame(width: audioManagerViewModel.isPlaying ? 370 : 300, height: audioManagerViewModel.isPlaying ? 370 : 300)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .animation(.spring, value: 10)
                SongTitleView(currentSong: $audioManagerViewModel.currentMusic)
                    .padding(.horizontal,audioManagerViewModel.isPlaying ? 0 : 20 )
                SongSliderView(value: $audioManagerViewModel.durationOf, audioManagerViewModel: audioManagerViewModel)
                    .padding(.horizontal,audioManagerViewModel.isPlaying ? 0 : 20 )
                
                ActionsView(isPlaying: $audioManagerViewModel.isPlaying, audioManagerViewModel: audioManagerViewModel)
                    .padding(.bottom, 50)
                    .padding(.horizontal, UIScreen.main.bounds.width * 0.1)

            }
            .frame(maxHeight: .infinity)
        }
        .background(.black)
        .ignoresSafeArea()
    }
}


struct SongSliderView: View{
    @Binding var value: Double
    @State var isDrag = false
    @State var updatingWidth = 0.0
    @State var lastWidth = 0.0
    @StateObject var audioManagerViewModel: AudioManagerViewModel
    @State var isSliding = false
    var sliderWidth = UIScreen.main.bounds.width * 0.95
    var padding = UIScreen.main.bounds.width * 0.05
    var widthOffset = 10.0
    let gridItems = [GridItem(.flexible(), alignment: .leading),
                     GridItem(.flexible(), alignment: .trailing)]
    var body: some View{
 
    
        VStack{
        ZStack(alignment: .leading){
        RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(.gray)
            .frame(width: sliderWidth-widthOffset-padding,height: 10)
        
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.white)
                .opacity(isSliding ? 1 : 0.7)
                .frame(width: isSliding ? updatingWidth : ((sliderWidth-widthOffset-padding) * value), height: isSliding ? 14 : 10 )
        
        
    }
       
            
        HStack{
            

            LazyVGrid(columns: gridItems) {
               
                let currentTime = audioManagerViewModel.getTime(timingScheme: .currentTime)
                    
                let durationTime = audioManagerViewModel.getTime(timingScheme: .duration)
                
                let currentTimeString: String = (currentTime.seconds == 0) ? "00" : "\(currentTime.seconds)"
                 
                let durationTimeString: String = (durationTime.seconds == 0) ? "00" : "\(durationTime.seconds)"
                    
                if isSliding{
                  
                    Text("\(currentTime.minutes):\(currentTimeString)")
                        .animation(.default)
                        .bold()
                    
                    Text("-\(durationTime.minutes):\(durationTimeString)")
                        .animation(.default)
                        .bold()
                    
                } else {
                    
                    Text("\(currentTime.minutes):\(currentTimeString)")
                        .animation(.default)
                    
                    Text("-\(durationTime.minutes):\(durationTimeString)")
                        .animation(.default)
                }
                
               
                
            }
           
                
        }
        .foregroundStyle(isSliding ? .white :.gray)
        .padding(.horizontal, 3)
        .padding(.top, 20)
        .frame(width: sliderWidth-widthOffset-padding,height: 10)

    }

        .frame(width: sliderWidth-widthOffset-padding, height: 100, alignment: .center)
        .contentShape(Rectangle())
        .gesture(
            
            DragGesture()
                .updating(.init(initialValue: 0)){ _ , _, _ in
                    withAnimation(.smooth){
                        if !isSliding {
                            isSliding = true
                        }
                    }
                }
                .onChanged({ gesture in
                    let diffWidth = gesture.translation.width
                    value =  (lastWidth + diffWidth) / (sliderWidth-widthOffset-padding)
                    value = min(max(value, 0), 1)
                    updatingWidth = (sliderWidth-widthOffset-padding) * value
                   
                })
                .onEnded{ gesture in
                        let diffWidth = gesture.translation.width
                        value =  (lastWidth + diffWidth) / (sliderWidth-widthOffset-padding)
                        value = min(max(value, 0), 1)

                        audioManagerViewModel.audioPlayer?.currentTime = TimeInterval(floatLiteral: ((audioManagerViewModel.audioPlayer?.duration ?? 0) * value))
                        
                    withAnimation(.spring){
                        isSliding = false
                    }
                    lastWidth = value == 1 ? 0 :  (sliderWidth-widthOffset-padding) * value
                    }
            
            
            
        )
        .scaleEffect(x: isSliding ? 1.05 : 1, y: isSliding ? 1.05 : 1)
    }
        
}

struct ButtonView: View{
    @Binding var isPlaying: Bool
    @StateObject var audioManagerViewModel: AudioManagerViewModel
    var size: CGFloat
    var body: some View{
        Button{
            withAnimation(.spring) {
                isPlaying.toggle()
            }
            
            audioManagerViewModel.toggleMusic()
            
        } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .resizable()
                .scaledToFit()
                .frame(width: size, alignment: .center)
                .foregroundStyle(.white)

                
        }
    }
}
struct ActionsView: View{
    @Binding var isPlaying: Bool
    @ObservedObject var audioManagerViewModel: AudioManagerViewModel
    var body: some View{
        HStack(alignment: .center){
            let size: CGFloat = 25
            Button{
            } label: {
                HStack(alignment: .center, spacing: 0){
                    Image(systemName: "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size)
                        .foregroundStyle(.white)
                        
                    Image(systemName: "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size)
                        .foregroundStyle(.white)

                        
                }
                .scaleEffect(x: -1)

                
                
            }
            Spacer()
            ButtonView(isPlaying: $isPlaying, audioManagerViewModel: audioManagerViewModel, size: 40)
           
            

            Spacer()
            Button{
            } label: {
                HStack(alignment: .center, spacing: 0){
                    Image(systemName: "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size)
                        .foregroundStyle(.white)
                        
                    Image(systemName: "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: size)
                        .foregroundStyle(.white)

                        
                }

            
            }
            }
              
        .padding(40)
           
    }
}

struct SongTitleView: View{
    @Binding var currentSong: Song?
    var body: some View{
        HStack(alignment: .top){
            VStack(alignment: .leading, spacing: 0){
                Text(currentSong?.songName ?? "")
                Text(currentSong?.artistName ?? "")
                    .foregroundStyle(.placeholder)
            }
            .frame(alignment: .top)
            .font(.title2)
            .bold()
            
            Spacer()
            
            Button{
                currentSong?.isFavorite.toggle()
                
            } label: {
                Image(systemName: currentSong?.isFavorite ?? false ? "star.fill" : "star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.white)
                    
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(20)
    }
    
}
#Preview {
    var audioPlayer = {
        let player = AudioManagerViewModel()
        player.currentMusic = SongsViewModel().songsData?.songs.first!
        player.playMusic()
        
        return player
    }
    MusicPlayerMainView(audioManagerViewModel: audioPlayer())
//    ActionsView(isPlaying: .constant(true))
//    SongTitleView(currentSong: .constant( SongViewModel()?.songsData?.songs[0]))
}
