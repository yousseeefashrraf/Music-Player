//
//  AlbumView.swift
//  MusicPlayer
//
//  Created by Youssef Ashraf on 17/04/2025.
//

import SwiftUI

struct AlbumSongsView: View {
    var album: Album
    @StateObject var audioManagerViewModel: AudioManagerViewModel
    @Binding var isSheetUp: Bool
    let gridItems = [GridItem(.flexible(), alignment: .leading),
                     GridItem(.flexible(), alignment: .trailing)
    ]
    
    var body: some View {
        VStack(spacing: 50){
            ZStack{
                ScrollView{
                    VStack(spacing: 0){
                        ZStack{
                            Image(album.songs[0].imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 350, height: 250)
                                .blur(radius: 40)
                            Color.black.opacity(0.8)
                            VStack{
                                Image(album.songs[0].imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 250, height: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.bottom, 10)
                                Text(album.albumName)
                                    .font(.title2)
                                    .bold()
                                
                                Image(album.songs[0].imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 400, height: 10)
                                    .blur(radius: 40)
                                    .mask {
                                        Text(album.songs[0].artistName)
                                        
                                            .font(.title2)
                                            .bold()
                                    }
                                
                                
                                Spacer()
                            }
                            .padding(.top, 40)
                        }
                        .frame(width: 400, height: 400)
                        .clipped()
                        
                        LazyVGrid(columns: gridItems, spacing: 5){
                            Button{
                                audioManagerViewModel.currentMusic = album.songs[0]
                                audioManagerViewModel.playMusic()
                            }label: {
                                ZStack{
                                    Image(album.songs[0].imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .blur(radius: 40)
                                    HStack{
                                        Image(systemName: "play.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 17)
                                        
                                        Text("Play")
                                            .font(.title2)
                                            .bold()
                                        
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .foregroundStyle(.white)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .clipped()
                                }
                                .frame(height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            
                            
                            Button{
                                
                            }label: {
                                ZStack{
                                    
                                    Image(album.songs[0].imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .blur(radius: 40)
                                    
                                    
                                    HStack{
                                        Image(systemName: "shuffle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 17)
                                        
                                        Text("Shuffle")
                                            .font(.title2)
                                            .bold()
                                        
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .clipped()
                                }
                                .frame(height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                
                            }
                            
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 50)
                        
                        
                        VStack{
                            ForEach(album.songs, id: \.songName){ song in
                                let padding = 12.0
                                
                                VStack(spacing: 0){
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(maxWidth: .infinity, maxHeight: 1)
                                        .foregroundStyle(.placeholder)
                                        .padding(.bottom, padding)
                                    
                                    HStack(){
                                        Button{
                                            withAnimation(.spring) {
                                                isSheetUp = true
                                            }
                                            audioManagerViewModel.currentMusic = song
                                            audioManagerViewModel.playMusic()
                                            
                                        } label:{
                                            HStack(alignment: .center, spacing: 0){
                                                if song.isFavorite {
                                                    Image(systemName: "star.fill")
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 15, height: 15)
                                                        .foregroundStyle(.green)
                                                    
                                                }
                                                
                                                Text(" - " + song.songName)
                                                    .padding(.leading, song.isFavorite ? 5 : 20)
                                                
                                                
                                                
                                                
                                            }
                                            .foregroundStyle(.white)
                                            .sheet(isPresented: $isSheetUp) {
                                                
                                                MusicPlayerMainView(audioManagerViewModel: audioManagerViewModel)
                                                
                                            }
                                        }
                                        Spacer()
                                        Menu {
                                            VStack{
                                                Text("Add to queue")
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 4, height: 4)
                                                .foregroundStyle(
                                                    .white
                                                )
                                                .frame(width: 10, height: 10, alignment: .center)
                                                .padding(.trailing, 15)
                                            
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    
                                    .padding(.horizontal, 5)
                                    
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, padding)
                                }
                                
                            }
                            
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(maxHeight: 1)
                                .foregroundStyle(.placeholder)
                            
                            
                        }
                        .padding(.horizontal, 10)
                    }
                    
                    
                    
                    
                    Spacer()
                    
                }
                .padding(.bottom, 50)
                .scrollIndicators(.hidden)
                
                CurrentSongBar(audioManagerViewModel: audioManagerViewModel, isSheetUp: $isSheetUp)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 5)
                    
            }
    }
        
        .tint(.white)
    }
}

#Preview {

    @ObservedObject var audioPlayer = AudioManagerViewModel()
    AlbumSongsView(album: SongsViewModel().albums[5], audioManagerViewModel: audioPlayer, isSheetUp: .constant(false))
}
