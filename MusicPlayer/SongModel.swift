
import Foundation
import AVFAudio
import SwiftUI

struct Song: Codable{
    var songName: String
    var artistName: String
    var albumName: String
    var audioName: String
    var imageName: String
    var isSingle: Bool
    var isFavorite: Bool
}

struct SongsData: Codable{
    var songs: [Song]
}

enum FileErorr: Error{
    case fileNotFound, wrongFormat
}

class SongViewModel: ObservableObject{
    @Published var songsData: SongsData? = nil
    init?(){
        do {
             let tryFetchData = try SongViewModel.fetchJSONData() 
            songsData = tryFetchData
        } catch FileErorr.fileNotFound{
            print("error file not found")
            return nil
        } catch FileErorr.wrongFormat{
            print("error file format")
            return nil
        } catch{
            print("unknown error")
            return nil
        }
        
    }
    
    static func fetchJSONData() throws -> SongsData? {
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
            throw FileErorr.fileNotFound
        }
        
        guard let jsonData = try? Data(contentsOf: url) else{
        
            print ("error in the link")
            return nil
        }
        guard let songData = try? JSONDecoder().decode(SongsData.self, from: jsonData) else {
            throw FileErorr.wrongFormat
        }
        return songData
    }
}

class AudioManagerViewModel: ObservableObject{
    @Published var audioPlayer: AVAudioPlayer?
    @Published var currentMusic: Song? = SongViewModel()?.songsData?.songs[4]
    @Published var timeOfPlay = 0.0
    @Published var timer: Timer?
    @Published var currentTime = 0.0
    @Published var durationOf = 0.0
    @Published var isPlaying = true
    func toggleMusic(){
        if let isPlaying = audioPlayer?.isPlaying, isPlaying {
            audioPlayer?.pause()
            print ("paused")
        } else {
           
            audioPlayer?.play()
            print ("playing at \(audioPlayer?.currentTime ?? 0)")
            print ("timer at \(audioPlayer?.currentTime ?? 0)")
            
        }
    }
    func playMusic(){

        guard let song = currentMusic else {
            return
        }
        guard let url = Bundle.main.url(forResource: song.audioName, withExtension: "mp3") else {
            print("music not found")
          return
        }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.play()
                startTimer()
                print ("Playing: \(song.audioName)")
            } catch{
                print("Can't play music right now")
            
        }
    }
    func startTimer() {
        stopTimer() // just in case
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if let player = self.audioPlayer {
                DispatchQueue.main.async {
                               self.currentTime = player.currentTime
                                self.durationOf = self.currentTime / player.duration
                    if self.durationOf >= 0.999{
                        self.audioPlayer?.pause()
                        self.isPlaying = false
                        
                    }
                           }
            }
        }
    }
    
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    init(){
        print ("A song will be played now")
        playMusic()
        
    }
}
