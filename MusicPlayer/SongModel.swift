
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

enum ImageError: Error{
    case cgImageError, colorSpaceError, contextError
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
    @Published var currentMusic: Song? = SongViewModel()?.songsData?.songs[3]
    @Published var timeOfPlay = 0.0
    @Published var timer: Timer?
    @Published var currentTime = 0.0
    @Published var durationOf = 0.0
    @Published var isPlaying = true
    lazy var commonColors = AudioManagerViewModel.commonTwoColor(forSong: currentMusic)

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
    
    
    
    static func getImageInRawForm(forSong song: Song) throws -> [UInt8] {
        
        let image = UIImage(named: song.imageName)
        guard let cgImage = image?.cgImage else {
            throw ImageError.cgImageError
        }
        
        guard let cgColorSpace = cgImage.colorSpace else {
            throw ImageError.colorSpaceError
        }
        
        //buffer data
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixle = 4
        let bytesPerRow = bytesPerPixle * width
        let bitsPerColor = 8
        
        var imagePixlesBuffer = [UInt8] (repeating: 0, count: bytesPerRow * height)
        
        guard let context = CGContext(data: &imagePixlesBuffer, width: width, height: height, bitsPerComponent: bitsPerColor, bytesPerRow: bytesPerRow, space: cgColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            print ("context error")
            throw ImageError.contextError
        }
        // try to understand that later
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        print ("context error")
        return imagePixlesBuffer
    }
    
    
    static func commonTwoColor(forSong: Song?) -> (colorOne: Color, colorTwo: Color){
        
        guard let song = forSong else {
            print("There is no song to play")
            return (.black, .black)
        }
        
        guard let image = try? getImageInRawForm(forSong: song) else{
            do {
                _ = try getImageInRawForm(forSong: song)
            } catch ImageError.cgImageError {
                print ("cgImage error")
            } catch ImageError.colorSpaceError {
                print ("colorSpaceError error")
            } catch ImageError.contextError {
                print ("contextError error")
            }catch  {
                print ("unknown error")
            }
            return (.black, .black)
        }
        
       
        
        var allColorsInImage: [[UInt8]:Int] = [:]
        
        for i in stride(from: 0, through: image.count - 4, by: 4){
            var color: [UInt8] = []
            color.append(image[i])
            color.append(image[i+1])
            color.append(image[i+2])
            
            if allColorsInImage[color] != nil {
            allColorsInImage[color]! += 1
                
            } else {
                allColorsInImage[color] = 1
            }
        }
        
        let sorted = allColorsInImage.sorted { a, b in
            b.value > a.value
        }
        
        return (Color(red: Double(sorted[0].key[0]) / 255,
                      green: Double(sorted[0].key[1]) / 255,
                      blue: Double(sorted[0].key[2]) / 255),
                
                Color(red: Double(sorted[1].key[0]) / 255,
                              green: Double(sorted[1].key[1]) / 255,
                              blue: Double(sorted[1].key[2]) / 255))
    }
}
