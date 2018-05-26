//
//  SongsListViewController.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/20/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD

class SongsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var player: AVPlayer?
    var trackID = String()
    var trackURL = String()
    var currentTimeLabel = UILabel()
    var trackDurationOutlet = UILabel()
    var trackNameOutlet = UILabel()
    var selectedTrackDuration = String()
    var selectedSongTitle = String()
    var playerViewOutlet = UIView()
    var playButtonOutlet = UIButton()
    var pauseButtonOutlet = UIButton()
    var stopButtonOutlet = UIButton()
    
    var sliderOutlet = UISlider()
    var trackImage = String()
    var artistID = String()
    var genreeID = String()
    var trackDuration = String()
    var songDataset = [SongInfo]()
    var limit = 10
    var page = 1
    var totalPages = 0
    let window = UIApplication.shared.keyWindow!
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchSongs()
        tableview.reloadData()
        tableview.delegate = self
        tableview.dataSource = self
        
        // Player view customization
        customPlayerView()
        
        // Play, Pause, Stop buttons
        playElement()
        stopElement()
        pauseElement()

        // Labels
        trackNameElement()
        trackDurationElements()
        // Slider
        sliderElement()
        
    }
  
    // Player butons functions
    
    @IBAction func cellPlayButtonTapped(_ button: UIButton) {
        sliderOutlet.isEnabled = true
        playButtonOutlet.isHidden = true
        pauseButtonOutlet.isHidden = false
        
        // Getting song name based on indexPath.row user selected
        if let indexPath = self.tableview.indexPathForView(button) {
            let data : SongInfo
            data = songDataset[indexPath.row]
            selectedSongTitle = data.track_title
            selectedTrackDuration = data.track_duration
            trackURL = data.track_url
            trackID = data.track_id
            print(trackURL)
            setupPlayerView()
            print("Button tapped at index path \(indexPath)")
        } else {
            print("Button indexPath not found")
        }
        
        
        
        if playerViewOutlet.alpha == 0 {
            UIView.animate(withDuration: 1) {
                self.playerViewOutlet.alpha = 1
                self.playerViewOutlet.frame.origin.y -= 200
            }
        } else {
            // if player is visable and user taps next song to play, player will stop previous nad strat new song
            player?.pause()
            player?.rate = 0.0

            player?.play()
        }
        self.trackDurationOutlet.text = self.selectedTrackDuration
        self.trackNameOutlet.text = self.selectedSongTitle
        print("Song started playing")
    }
    
    func setupPlayerView() {
        // Playing track from internet
        let urlString = "\(trackURL)/download"
        if let url = URL(string: urlString) {
            
            player = AVPlayer(url: url)
            player?.play()
            
            player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        }
        // Playing track from local file
        if let filePath = UserDefaults.standard.string(forKey: "\(trackID)") {
            let fileManager = FileManager.default
            
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            let fileName = filePath.components(separatedBy: "/").last
            let finalTrackURL = documentsUrl.first!.appendingPathComponent(fileName!)
            
            player = AVPlayer(url: finalTrackURL)
            player?.play()
            
            player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        }
        // track player progress
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
 
            let seconds = CMTimeGetSeconds(progressTime)
            let secondsString = String(format: "%02d", Int(seconds) % 60)
            let minutesString = String(format: "%02d", Int(seconds) / 60)
            self.currentTimeLabel.text = "\(minutesString):\(secondsString)"
            
            // moving the slider thumb
            
            if let duration = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                
                self.sliderOutlet.value = Float(seconds / durationSeconds)
            }
        })
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // [layer is ready and rendering frames
        if keyPath == "currentItem.loadedTimeRanges" {
            print(change!)
        }
    }
    
    @IBAction func cellPauseButtonTapped(_ sender: Any) {
        player?.pause()
        playButtonOutlet.isHidden = false
        pauseButtonOutlet.isHidden = true
    }
    
    @IBAction func cellStopButtonTapped(_ sender: UIButton!) {
        stopButtonOutlet = sender.self
        player?.pause()
        player?.rate = 0.0
        
        
        if playerViewOutlet.alpha == 1 {
            UIView.animate(withDuration: 1) {
                self.playerViewOutlet.alpha = 0
                self.playerViewOutlet.frame.origin.y += 200
            }
        }
        print("Song stopped playing")
    }
    
    @IBAction func downloadButtonTapped(_ button: UIButton) {
        //code for song download
        SVProgressHUD.show(withStatus: "Downloading...")
        // Getting song name based on indexPath.row user selected
        if let indexPath = self.tableview.indexPathForView(button) {
            let data : SongInfo
            data = songDataset[indexPath.row]
            trackURL = data.track_url
            trackID = data.track_id
            
            print("Button tapped at index path \(indexPath)")
        } else {
            print("Button indexPath not found")
        }
        
        if let audioUrl = URL(string: "\(trackURL)/download") {
            
            // creating document folder url
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // creating destination file url
            var validUrl = URL(string: "\(trackURL).mp3")!
            let fileUrl = documentsDirectoryURL.appendingPathComponent(validUrl.lastPathComponent)

            UserDefaults.standard.set(fileUrl, forKey: "\(trackID)")

            print(fileUrl)
            
            // check if it exists before download
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                print("The file already exists at path")
                
               presentAlertMesage()
                
                // if file doesnt exist
            } else {
                
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    
                    do {
                        // // after downloading file we need to move it to ours destination url
                        SVProgressHUD.dismiss()
                        self.presentAlertMesage2()
                        try FileManager.default.moveItem(at: location, to: fileUrl)
                        print("File successfully moved to documents folder")
                        
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }

    @objc func PlayButtonTapped(sender: UIButton!) {
        player?.play()
        playButtonOutlet.isHidden = true
        pauseButtonOutlet.isHidden = false
        print("Song started playing")
        
    }
    @objc func StopButtonTapped(sender: UIButton!) {
        
        stopButtonOutlet = sender.self
        
        player?.pause()
        player?.rate = 0.0
        
        if playerViewOutlet.alpha == 1 {
            UIView.animate(withDuration: 1) {
                self.playerViewOutlet.alpha = 0
                self.playerViewOutlet.frame.origin.y += 200
            }
        }
        print("Song stopped playing")
    }
    @objc func PauseButtonTapped(sender: UIButton!) {
        player?.pause()
        playButtonOutlet.isHidden = false
        pauseButtonOutlet.isHidden = true
        print("Song is paused")
    }
    @objc func ChangeAudioTime(sender: UISlider!) {
        player?.pause()
        player?.rate = 0.0
        player?.rate = sliderOutlet.value
        player?.play()
    }
    
    func fetchSongs() {
        
        SVProgressHUD.show(withStatus: "Downloading songs..")
        var url = URLComponents(string: "https://freemusicarchive.org/api/get/tracks.json")!
        url.queryItems = [
            URLQueryItem(name: "api_key", value: "CFEFES9JPKBN4T7H"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "genre_id", value: genreeID)
        ]
        
        URLSession.shared.dataTask(with: url.url!) { (data, response, error) in
            
            guard let data = data else {return}
            let dataString = String(data: data, encoding: .utf8)
            
            guard let songDescription = try? JSONDecoder().decode(SongDescription.self, from: data) else {
                print("Error: Couldn't decode data into dataset")
                return
            }
            
            self.songDataset.append(contentsOf: songDescription.dataset)
            self.totalPages = songDescription.total_pages

            DispatchQueue.main.async {
                self.tableview.reloadData()
                SVProgressHUD.dismiss()
            }
        }.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songDataset.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell") as! SongsTableViewCell
        let song = songDataset[indexPath.row]
        
        cell.songTile.text = song.track_title
        cell.songArtist.text = song.artist_name

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = songDataset[indexPath.row]
        artistID = data.artist_id
        trackDuration = data.track_title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if(indexPath.row == songDataset.count - 1){
            // Last row
            if(totalPages > page){
                // It there is no more pages
                page += 1
                
                print("Fetching page: \(page) of total pages: \(totalPages)")
                fetchSongs()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSongDetails" {
            if let selectedRowForIndexPath = tableview.indexPathForSelectedRow {
                
                let songDetils: SongInfo
                
                songDetils = songDataset[selectedRowForIndexPath.row]
                
                let destinationVC = segue.destination as? SongDetailsViewController
                
                destinationVC?.songName = songDetils.track_title
                destinationVC?.artistName = songDetils.artist_name
                destinationVC?.artistId = songDetils.artist_id
                destinationVC?.trackArtwork = songDetils.track_image_file
                self.tableview.deselectRow(at: selectedRowForIndexPath, animated: false)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParentViewController
        {
            playerViewOutlet.isHidden = true
            print("View controller was popped")
            SVProgressHUD.dismiss()
        }
        else
        {
            print("New view controller was pushed")
        }
    }
}
public extension UITableView {
    
    /// Function converts cordinates from tap position in UIView to IndexPath that is used for getting correct data from API.
    ///
    /// - Parameter view: current view
    /// - Returns: IndexPath for selected row
    func indexPathForView(_ view: UIView) -> IndexPath? {
        let center = view.center
        let viewCenter = self.convert(center, from: view.superview)
        let indexPath = self.indexPathForRow(at: viewCenter)
        return indexPath
    }
}

extension SongsListViewController {
    // Creating player elements
    
    func customPlayerView() {
        
        let playerView = UIView(frame: CGRect(x: 10, y: window.frame.height * 1.1, width: window.frame.width - 20, height: window.frame.height * 0.15))
        playerViewOutlet = playerView
        playerView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        playerView.layer.cornerRadius = 5
        playerViewOutlet.alpha = 0
        window.addSubview(playerView)
    }
    
    func playElement() {
        let playButton = UIButton(frame: CGRect(x: window.frame.width / 2 - 35, y: window.frame.height * 0.07, width: 40, height: 40))
        playButtonOutlet = playButton
        playButton.layer.cornerRadius = 10
        playButton.setImage(#imageLiteral(resourceName: "playButton"), for: UIControlState.normal)
        playButton.addTarget(self, action: #selector(PlayButtonTapped), for: UIControlEvents.touchUpInside)
        playerViewOutlet.addSubview(playButton)
    }
    
    func stopElement() {
        let stopButton = UIButton(frame: CGRect(x: window.frame.width * 0.6, y: window.frame.height * 0.07, width: 40, height: 40))
        stopButtonOutlet = stopButton
        stopButton.layer.cornerRadius = 10
        stopButton.addTarget(self, action: #selector(StopButtonTapped), for: UIControlEvents.touchUpInside)
        stopButton.setImage(#imageLiteral(resourceName: "stopButton"), for: UIControlState.normal)
        playerViewOutlet.addSubview(stopButton)
    }
    
    func pauseElement() {
        let pauseButton = UIButton(frame: CGRect(x: window.frame.width / 2 - 35, y: window.frame.height * 0.07, width: 40, height: 40))
        pauseButtonOutlet = pauseButton
        pauseButton.layer.cornerRadius = 10
        pauseButton.setImage(#imageLiteral(resourceName: "pauseButton"), for: UIControlState.normal)
        pauseButton.addTarget(self, action: #selector(PauseButtonTapped), for: UIControlEvents.touchUpInside)
        playerViewOutlet.addSubview(pauseButton)
    }
    
    func trackNameElement() {
        let trackName = UILabel(frame: CGRect(x: window.frame.width * 0.07, y: 1, width: 300, height: 20))
        trackName.textAlignment = NSTextAlignment.center
        trackNameOutlet = trackName
        playerViewOutlet.addSubview(trackName)
    }
    
    func sliderElement() {
        let seekSlider = UISlider(frame: CGRect(x: window.frame.width * 0.07, y: window.frame.height * 0.03, width: 300, height: 40))
        seekSlider.addTarget(self, action: #selector(ChangeAudioTime), for: UIControlEvents.touchUpInside)
        sliderOutlet = seekSlider
        sliderOutlet.minimumTrackTintColor = UIColor.red
        sliderOutlet.setThumbImage(UIImage(named: "thumb"), for: UIControlState.normal)
        sliderOutlet.addTarget(self, action: #selector(handleSliderChange), for: UIControlEvents.touchUpInside)

        playerViewOutlet.addSubview(seekSlider)
    }
    
    @objc func handleSliderChange() {

            print(sliderOutlet.value)
            if let duration = player?.currentItem?.asset.duration {
                let seconds = CMTimeGetSeconds(duration)
                guard !(seconds.isNaN || seconds.isInfinite) else {
                    sliderOutlet.isEnabled = false
                    print("Cant seek song that is streaming")
                    
                    return
                }
                let value = Double(sliderOutlet.value) * Double(seconds)
                let seekTime = CMTime(value: Int64(value), timescale: 1)
                
                print("Duration: \(duration), seconds: \(seconds), value: \(value), seekTime: \(seekTime)")
                player?.seek(to: seekTime, completionHandler: { (completedSeek) in
                    // maybe do something here
                })
            }
    }
    
    func trackDurationElements() {
        // total track duration
        let trackDuration = UILabel(frame: CGRect(x: window.frame.width * 0.8, y: 45, width: 50, height: 20))
        trackDurationOutlet = trackDuration
        trackDurationOutlet.font = UIFont.boldSystemFont(ofSize: 13)
        playerViewOutlet.addSubview(trackDuration)
        
        //current time duration
        let currentTime = UILabel(frame: CGRect(x: window.frame.width * 0.03, y: 45, width: 50, height: 20))
        currentTimeLabel = currentTime
        currentTimeLabel.font = UIFont.boldSystemFont(ofSize: 13)
        currentTimeLabel.text = "00:00"
        playerViewOutlet.addSubview(currentTime)
    }
    
    func presentAlertMesage() {
        let alert = UIAlertController(title: "Alert:", message: "The file already exists.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func presentAlertMesage2() {
        let alert = UIAlertController(title: "Confirmation:", message: "Song is downloaded successfully!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
