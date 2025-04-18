//
//  HomePageView.swift
//  MusicPlayer
//
//  Created by Youssef Ashraf on 14/04/2025.
//

import SwiftUI

struct HomePageView: View {
    @StateObject var songViewModel: SongsViewModel
    @StateObject var audioManagerViewModel: AudioManagerViewModel
    @Binding var isSheetUp: Bool
    let gridItems = [GridItem(.flexible(), alignment: .leading),
                     GridItem(.flexible(), alignment: .trailing)
    ]
    
    
    var body: some View {
        let albums = songViewModel.albums
        NavigationStack{
            ZStack(alignment: .bottom){
                VStack(spacing: 0){
                    ScrollView(.vertical) {
                        VStack(alignment: .leading, spacing: 50){
                            
                            AlbumsView(songViewModel: songViewModel)
                            
                            SinglesView(audioManagerViewModel: audioManagerViewModel, isSheetUp: $isSheetUp, songViewModel: songViewModel)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.ignoresSafeArea())
                            Spacer()
                        }
                    }
                
                    .scrollIndicators(.hidden)
                    
                    .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .leading)
                    
                    .padding(.top, 80)
                    .padding(.horizontal, 20)
                    .background(Color.black.ignoresSafeArea())
                    
                    
                    
                }
                .tint(.white)
                
                .background(Color.black.ignoresSafeArea())
                .ignoresSafeArea()
                CurrentSongBar(audioManagerViewModel: audioManagerViewModel, isSheetUp: $isSheetUp)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 5)
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .foregroundStyle(.white)
            .navigationDestination(for: Int.self){ i in
                AlbumSongsView(album: songViewModel.albums[i], audioManagerViewModel: audioManagerViewModel, isSheetUp: $isSheetUp)
            }
        }
        .tint(.white)
        
    }
}

struct SinglesView: View{
    @StateObject var audioManagerViewModel: AudioManagerViewModel
    @Binding var isSheetUp: Bool
    @StateObject var songViewModel: SongsViewModel
    let gridItems = [GridItem(.flexible(), alignment: .leading),
                     GridItem(.flexible(), alignment: .trailing)
    ]
    
    var body: some View{
        let albums = songViewModel.albums
        VStack(alignment: .leading){
            Text("Singles")
                .font(.largeTitle)
                .bold()
            LazyVGrid(columns: gridItems, spacing: 30) {
                ForEach(albums, id: \.albumName){ album in
                    if album.isSingle{
                        Button {
                            isSheetUp = true
                            
                            if audioManagerViewModel.currentMusic?.songName != album.songs[0].songName {
                                audioManagerViewModel.currentMusic = album.songs[0]
                                audioManagerViewModel.playMusic()
                            }
                        } label: {
                            AlbumView(album: album)
                                .foregroundStyle(.white)
                        }
                        
                        
                    }
                }
                .background(Color.black.ignoresSafeArea())
                .sheet(isPresented: $isSheetUp) {
                    MusicPlayerMainView(audioManagerViewModel: audioManagerViewModel)
                        .background(Color.black.ignoresSafeArea())
                        .presentationBackground(.black)
                        .presentationDragIndicator(.visible)
                }
                .presentationBackground(.black)
                
                
                
            }
        }
    }
}
struct AlbumsView: View{
    @StateObject var songViewModel: SongsViewModel
    let gridItems = [GridItem(.flexible(), alignment: .leading),
                     GridItem(.flexible(), alignment: .trailing)
    ]
    var body: some View{
        VStack(alignment: .leading){
            Text("Albums")
                .font(.largeTitle)
                .bold()
            
            
            LazyVGrid(columns: gridItems, spacing: 30) {
                ForEach(0 ..< songViewModel.albums.count ){ index in
                    
                    let album = songViewModel.albums[index]
                    if !album.isSingle{
                        NavigationLink(value: index) {
                            AlbumView(album: album)
                        }
                            
                        
                    }
                }
                
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AlbumView: View{
    @StateObject var album: Album
    var body: some View{
        VStack(alignment: .leading){
            Image(album.songs[0].imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.bottom, 5)
            
            Text(album.isSingle ? album.songs[0].songName : album.songs[0].albumName)
                .bold()
            Text(album.songs[0].artistName)
                .foregroundStyle(.gray)
            
        }

    }
}

struct CurrentSongBar: View{

    @StateObject var audioManagerViewModel: AudioManagerViewModel
    @Binding var isSheetUp: Bool
    var body: some View {
        
        if let song = audioManagerViewModel.currentMusic{
            
            Button{
                withAnimation(.spring) {
                    isSheetUp = true
                }
            }
            label: {ZStack{
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                HStack{
                    Image(song.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    VStack(alignment: .leading){
                        Text(song.songName)
                            .bold()
                            .font(.headline)
                        Text(song.artistName)
                            .bold()
                            .font(.subheadline)
                            .foregroundStyle(.placeholder)
                    }
                    Spacer()
                    ButtonView(isPlaying: $audioManagerViewModel.isPlaying, audioManagerViewModel: audioManagerViewModel, size: 20)
                        .padding(.trailing, 5)
                    
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                
                
            }}
           
            .frame(maxWidth: .infinity, maxHeight: 60)
            .padding(10)
            .sheet(isPresented: $isSheetUp) {
                

                MusicPlayerMainView(audioManagerViewModel: audioManagerViewModel)
                
                
            }
            .clipped()
        }
    }
}

#Preview {
    var audioPlayer = {
        let player = AudioManagerViewModel()
        player.currentMusic = SongsViewModel().songsData?.songs.first!
        player.playMusic()
        
        return player
    }
//    CurrentSongBar(audioManagerViewModel: audioPlayer())
    
    HomePageView(songViewModel: SongsViewModel(), audioManagerViewModel: audioPlayer(), isSheetUp: .constant(false))
}
