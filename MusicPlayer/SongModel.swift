
import Foundation
import AVFAudio
import SwiftUI

enum ColorSelection {
    case brightest, darkest, hybird
}

enum SongTiming{
    case duration, currentTime
}

extension UIImage {
    func quantize(_ value: UInt8, toNearest: UInt8) -> UInt8 {
        
        return (value / toNearest) * toNearest
    }
    
    func getImageInRawForm() throws -> [UInt8] {
        
        let image = self
        guard let cgImage = image.cgImage else {
            throw ImageError.cgImageError
        }
        
        guard let cgColorSpace = cgImage.colorSpace else {
            throw ImageError.colorSpaceError
        }
        
        //buffer data
        
        let width = 10
        let height = 10
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
    
    
    func commonTwoColor(forSelection: ColorSelection) -> (colorOne: Color, colorTwo: Color){
        
        
        let image: [UInt8]
        do {
            image = try self.getImageInRawForm()
        } catch ImageError.cgImageError {
            print("cgImage error")
            return (.black, .black)
        } catch ImageError.colorSpaceError {
            print("colorSpaceError")
            return (.black, .black)
        } catch ImageError.contextError {
            print("contextError")
            return (.black, .black)
        } catch {
            print("unknown error")
            return (.black, .black)
        }
        
       
        
        var allColorsInImage: [[UInt8]:Int] = [:]
        
        for i in stride(from: 0, through: image.count - 4, by: 4){
            var color: [UInt8] = []
            
            let alpha = image[i + 3]
            
            guard alpha > 200 else { continue }
            
            color.append(quantize(image[i], toNearest: 50))
            color.append(quantize(image[i+1], toNearest: 50))
            color.append(quantize(image[i+2], toNearest: 50))
                        
            if allColorsInImage[color] != nil {
            allColorsInImage[color]! += 1
                
            } else {
                allColorsInImage[color] = 1
            }
        }
        
        var sorted = allColorsInImage.sorted { a, b in
           return a.value > b.value

        }
        
         sorted = sorted[0..<10].sorted { a, b in
             return (Int(a.key[0])+Int(a.key[1])+Int(a.key[2])) < (Int(b.key[0])+Int(b.key[1])+Int(b.key[2]))
        }
        
        if sorted.count < 2 {
            return (.red, .red)
        }
        var colorOne: Color
        var colorTwo: Color
        
        //from dark to brighter
        switch forSelection{
        case .brightest:
            sorted = allColorsInImage.sorted { a, b in
                return (Int(a.key[0])+Int(a.key[1])+Int(a.key[2])) > (Int(b.key[0])+Int(b.key[1])+Int(b.key[2]))
                
            }

            colorOne = Color(red: Double(sorted[sorted.count - 2].key[0]) / 255 , green: Double(sorted[sorted.count - 2].key[1]) / 255, blue: Double(sorted[sorted.count - 2].key[2]) / 255)
            colorTwo = Color(red: Double(sorted[1].key[0]) / 255 , green: Double(sorted[1].key[1]) / 255, blue: Double(sorted[1].key[2]) / 255)
            
        case .darkest:
            colorOne = Color(red: Double(sorted[0].key[0]) / 255 , green: Double(sorted[0].key[1]) / 255, blue: Double(sorted[0].key[2]) / 255)
            colorTwo = Color(red: Double(sorted[1].key[0]) / 255 , green: Double(sorted[1].key[1]) / 255, blue: Double(sorted[1].key[2]) / 255)
        case .hybird:
            colorOne = Color(red: Double(sorted[0].key[0]) / 255 , green: Double(sorted[0].key[1]) / 255, blue: Double(sorted[0].key[2]) / 255)
            
            colorTwo = Color(red: Double(sorted[1].key[0]) / 255 , green: Double(sorted[1].key[1]) / 255, blue: Double(sorted[1].key[2]) / 255)
        }

        
        
        return (colorOne, colorTwo)
    }
}

class SongViewModel: ObservableObject{
    @Published var song: Song
    
    init(song: Song) {
        self.song = song
    }
}

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

class Album: ObservableObject, Identifiable {
    var id = UUID()
    var albumName: String
    @Published var songs: [Song]
    var isSingle: Bool
    
    init(albumName: String, songs: [Song], isSingle: Bool) {
        self.albumName = albumName
        self.songs = songs
        self.isSingle = isSingle
    }
    
    
}
class SongsViewModel: ObservableObject{
    @Published var songsData: SongsData? = nil
    @Published var albums: [Album]
    
    init(){
        do {
            let tryFetchData = try SongsViewModel.fetchJSONData()
            songsData = tryFetchData
            
        } catch FileErorr.fileNotFound{
            print("error file not found")
        } catch FileErorr.wrongFormat{
            print("error file format")
        } catch{
            print("unknown error")
        }
        
        albums = []
        self.getAllAlbums()
        

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
    
    func getAllAlbums(){
        guard let songs = songsData?.songs else{
            print("No albums to show")
            return
        }
        var allAlbums: [String: [Song]] = [:]
        
        for song in songs {
            allAlbums[song.isSingle ? song.songName : song.albumName, default: []].append(song)
            print(song)
        }
        
        for album in allAlbums{
                let tmp = Album(albumName: album.key, songs: album.value, isSingle: album.value[0].isSingle)
                self.albums.append(tmp)
        }
        
        self.albums = albums.sorted(by: { a, b in
            a.albumName > b.albumName
        })

    }
    
   
    
}


class AudioManagerViewModel: ObservableObject{
    @Published var audioPlayer: AVAudioPlayer?
    @Published var currentMusic: Song? = nil
    @Published var timeOfPlay = 0.0
    @Published var timer: Timer? = nil
    @Published var currentTime = 0.0
    @Published var durationOf = 0.0
    @Published var isPlaying = true
    lazy var commonColors = AudioManagerViewModel.commonTwoColor(forSong: currentMusic, forSelection: .hybird)
    lazy var commonBrightColors = AudioManagerViewModel.commonTwoColor(forSong: currentMusic, forSelection: .brightest)

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
        commonColors = AudioManagerViewModel.commonTwoColor(forSong: currentMusic, forSelection: .hybird)
        commonBrightColors = AudioManagerViewModel.commonTwoColor(forSong: currentMusic, forSelection: .brightest)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.play()
                startTimer()
                print ("Playing: \(song.audioName)")
            } catch{
                print("Can't play music right now")
            
        }
        
        if audioPlayer?.currentTime == audioPlayer?.duration {
            audioPlayer?.currentTime = 0
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
                        if self.audioPlayer?.currentTime == self.audioPlayer?.duration {
                            self.audioPlayer?.currentTime = 0
                        }
                        
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
    
    
    
    
    static func quantize(_ value: UInt8, toNearest: UInt8) -> UInt8 {
        return (value / toNearest) * toNearest
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
        
        let width = cgImage.width / 6
        let height = cgImage.height / 6
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
    
    
    static func commonTwoColor(forSong: Song?, forSelection: ColorSelection) -> (colorOne: Color, colorTwo: Color){
        
        guard let song = forSong else {
            print("There is no song to play")
            return (.black, .black)
        }
        
        let image: [UInt8]
        do {
            image = try getImageInRawForm(forSong: song)
        } catch ImageError.cgImageError {
            print("cgImage error")
            return (.black, .black)
        } catch ImageError.colorSpaceError {
            print("colorSpaceError")
            return (.black, .black)
        } catch ImageError.contextError {
            print("contextError")
            return (.black, .black)
        } catch {
            print("unknown error")
            return (.black, .black)
        }
        
       
        
        var allColorsInImage: [[UInt8]:Int] = [:]
        
        for i in stride(from: 0, through: image.count - 4, by: 4){
            var color: [UInt8] = []
            
            let alpha = image[i + 3]
            
            guard alpha > 200 else { continue }
            
            color.append(quantize(image[i], toNearest: 50))
            color.append(quantize(image[i+1], toNearest: 50))
            color.append(quantize(image[i+2], toNearest: 50))
                        
            if allColorsInImage[color] != nil {
            allColorsInImage[color]! += 1
                
            } else {
                allColorsInImage[color] = 1
            }
        }
        
        var sorted = allColorsInImage.sorted { a, b in
           return a.value > b.value

        }
        
         sorted = sorted[0..<10].sorted { a, b in
             return (Int(a.key[0])+Int(a.key[1])+Int(a.key[2])) < (Int(b.key[0])+Int(b.key[1])+Int(b.key[2]))
        }
        
        if sorted.count < 2 {
            return (.red, .red)
        }
        var colorOne: Color
        var colorTwo: Color
        
        //from dark to brighter
        switch forSelection{
        case .brightest:
            sorted = allColorsInImage.sorted { a, b in
                return (Int(a.key[0])+Int(a.key[1])+Int(a.key[2])) > (Int(b.key[0])+Int(b.key[1])+Int(b.key[2]))
                
            }

            colorOne = Color(red: Double(sorted[sorted.count - 2].key[0]) / 255 , green: Double(sorted[sorted.count - 2].key[1]) / 255, blue: Double(sorted[sorted.count - 2].key[2]) / 255)
            colorTwo = Color(red: Double(sorted[1].key[0]) / 255 , green: Double(sorted[1].key[1]) / 255, blue: Double(sorted[1].key[2]) / 255)
            
        case .darkest:
            colorOne = Color(red: Double(sorted[0].key[0]) / 255 , green: Double(sorted[0].key[1]) / 255, blue: Double(sorted[0].key[2]) / 255)
            colorTwo = Color(red: Double(sorted[1].key[0]) / 255 , green: Double(sorted[1].key[1]) / 255, blue: Double(sorted[1].key[2]) / 255)
        case .hybird:
            colorOne = Color(red: Double(sorted[0].key[0]) / 255 , green: Double(sorted[0].key[1]) / 255, blue: Double(sorted[0].key[2]) / 255)
            
            colorTwo = Color(red: Double(sorted[1].key[0]) / 255 , green: Double(sorted[1].key[1]) / 255, blue: Double(sorted[1].key[2]) / 255)
        }

        
        
        return (colorOne, colorTwo)
    }
    
    func getTime(timingScheme: SongTiming) -> (hours: Int ,minutes: Int, seconds: Int){
        
        switch timingScheme {
        case .currentTime:
            let minutes = Int(currentTime / 60)
            let seconds = Int(currentTime.truncatingRemainder(dividingBy: 60))
            let hours = minutes / 60
            
            return (hours, minutes, seconds)
        case .duration:
            guard let duration = audioPlayer?.duration else {
                return (0,0,0)
            }
            let minutes = Int(duration / 60)
            let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
            let hours = minutes / 60
            
            return (hours, minutes, seconds)
        }
    }
}
