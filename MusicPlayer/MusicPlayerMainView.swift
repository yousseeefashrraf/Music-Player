//
//  MusicPlayerMainView.swift
//  MusicPlayer
//
//  Created by Youssef Ashraf on 12/04/2025.
//

import SwiftUI

struct MusicPlayerMainView: View {
    @StateObject var audioManagerViewModel: AudioManagerViewModel = AudioManagerViewModel()
    var body: some View {
        ZStack{
            LinearGradient(colors: [.brown, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
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
                    .padding(.bottom, 40)
                Spacer()

            }
            .frame(maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}

struct SongSliderView: View{
    @Binding var value: Double
    @StateObject var audioManagerViewModel: AudioManagerViewModel
    let padding = 10.0
    let width = (UIScreen.main.bounds.width)
    
    var body: some View{
        HStack(spacing: -10){
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(LinearGradient(colors: [.brown, .brown, .white], startPoint: .leading, endPoint: .trailing))
                .frame(width: value > 0.001 ? ((width-padding) * value) : 15  , height: 10)
                .gesture(
                    DragGesture()
                        .onChanged{ gesture in
                            value = gesture.location.x /  (UIScreen.main.bounds.width)
                        }
                        .onEnded({ gesture in
                            value = gesture.location.x /  (UIScreen.main.bounds.width)
                            audioManagerViewModel.audioPlayer?.currentTime = TimeInterval(floatLiteral: ((audioManagerViewModel.audioPlayer?.duration ?? 0) * value))
                           
                        })
                )
            Circle()
                .frame(width: 16, height: 16)
                .foregroundStyle(LinearGradient(colors: [.white], startPoint: .leading, endPoint: .trailing))
                .overlay {
                    Circle()
                        .stroke(.black, lineWidth: 2)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .clipped()
    }
}

struct ActionsView: View{
    @Binding var isPlaying: Bool
    @ObservedObject var audioManagerViewModel: AudioManagerViewModel
    var body: some View{
        HStack(){
 
            Button{
            } label: {
                Image(systemName: "arrowtriangle.left.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.white)
            }
            Spacer()
            
            Button{
                withAnimation(.bouncy) {
                    isPlaying.toggle()
                }
                
                audioManagerViewModel.toggleMusic()
                
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.white)
            }
            

            Spacer()
            Button{
            } label: {
                Image(systemName: "arrowtriangle.right.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.white)
            
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
                    .foregroundStyle(.gray)
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
    MusicPlayerMainView()
    
//    ActionsView(isPlaying: .constant(true))
//    SongTitleView(currentSong: .constant( SongViewModel()?.songsData?.songs[0]))
}
