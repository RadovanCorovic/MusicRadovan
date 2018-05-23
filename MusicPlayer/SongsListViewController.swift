//
//  SongsListViewController.swift
//  MusicPlayer
//
//  Created by Radovan Corovic on 5/20/18.
//  Copyright © 2018 Radovan Corovic. All rights reserved.
//

import UIKit
import AVFoundation

class SongsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var trackDurationOutlet = UILabel()
    var trackNameOutlet = UILabel()
    var selectedTrackDuration = String()
    var selectedSongTitle = String()
    var playerViewOutlet = UIView()
    var playButtonOutlet = UIButton()
    var pauseButtonOutlet = UIButton()
    
    var sliderOutlet = UISlider()
    var audioPlayer = AVAudioPlayer()
    var artistID = String()
    var genreeID = String()
    var trackDuration = String()
    var songDataset = [SongInfo]()
    var limit = 10
    var page = 1
    var totalPages = 0
    
    @IBOutlet weak var tableview: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        pauseButtonOutlet.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        tableview.reloadData()
        tableview.delegate = self
        tableview.dataSource = self
        
        //player
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "sample", ofType: "mp3")!))
            audioPlayer.prepareToPlay()
        }catch{
            print(error)
        }
        
        // Player view customization
        let window = UIApplication.shared.keyWindow!
        let playerView = UIView(frame: CGRect(x: 10, y: window.frame.height * 1.1, width: window.frame.width - 20, height: window.frame.height * 0.15))
        playerViewOutlet = playerView
        playerView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        playerView.layer.cornerRadius = 5
        playerViewOutlet.alpha = 0
        window.addSubview(playerView)
        
        // Play, Pause, Stop buttons
        let playButton = UIButton(frame: CGRect(x: window.frame.width / 2 - 35, y: window.frame.height * 0.07, width: 40, height: 40))
        playButtonOutlet = playButton
        playButton.layer.cornerRadius = 10
        playButton.setImage(#imageLiteral(resourceName: "playButton"), for: UIControlState.normal)
        playButton.addTarget(self, action: #selector(PlayButtonTapped), for: UIControlEvents.touchUpInside)
        playerView.addSubview(playButton)
        
        let stopButton = UIButton(frame: CGRect(x: window.frame.width * 0.6, y: window.frame.height * 0.07, width: 40, height: 40))
        stopButton.layer.cornerRadius = 10
        stopButton.addTarget(self, action: #selector(StopButtonTapped), for: UIControlEvents.touchUpInside)
        stopButton.setImage(#imageLiteral(resourceName: "stopButton"), for: UIControlState.normal)
        
        playerView.addSubview(stopButton)
        
        let pauseButton = UIButton(frame: CGRect(x: window.frame.width / 2 - 35, y: window.frame.height * 0.07, width: 40, height: 40))
        pauseButtonOutlet = pauseButton
        pauseButton.layer.cornerRadius = 10
        pauseButton.setImage(#imageLiteral(resourceName: "pauseButton"), for: UIControlState.normal)
        pauseButton.addTarget(self, action: #selector(PauseButtonTapped), for: UIControlEvents.touchUpInside)
        playerView.addSubview(pauseButton)
        
        // Track label
        let trackName = UILabel(frame: CGRect(x: window.frame.width * 0.07, y: 1, width: 300, height: 20))
        trackName.textAlignment = NSTextAlignment.center
        trackNameOutlet = trackName
        playerView.addSubview(trackName)
        
        // Slider
        let seekSlider = UISlider(frame: CGRect(x: window.frame.width * 0.07, y: window.frame.height * 0.03, width: 300, height: 40))
        seekSlider.addTarget(self, action: #selector(ChangeAudioTime), for: UIControlEvents.touchUpInside)
        sliderOutlet = seekSlider
        sliderOutlet.minimumValue = 0
        sliderOutlet.maximumValue = Float(audioPlayer.duration)
        var timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        playerView.addSubview(seekSlider)
        
        // Track duration label
        let trackDuration = UILabel(frame: CGRect(x: window.frame.width * 0.8, y: 42, width: 50, height: 20))
//        trackDurationOutlet = trackName
        trackDurationOutlet.backgroundColor = UIColor.red
        trackDurationOutlet = trackDuration
        playerView.addSubview(trackDuration)
        fetchSongs()
    }
    
    // Player butons functions
    
    @IBAction func cellPlayButtonTapped(_ button: UIButton) {
        audioPlayer.play()
        playButtonOutlet.isHidden = true
        pauseButtonOutlet.isHidden = false
        
        // Getting song name based on indexPath.row user selected
        if let indexPath = self.tableview.indexPathForView(button) {
            let data : SongInfo
            data = songDataset[indexPath.row]
            selectedSongTitle = data.track_title
            selectedTrackDuration = data.track_duration
            
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
            audioPlayer.stop()
            audioPlayer.currentTime = 0
            audioPlayer.play()
        }
        
        self.trackDurationOutlet.text = self.selectedTrackDuration
        self.trackNameOutlet.text = self.selectedSongTitle
        print("Song started playing")
    }
    
    @IBAction func cellPauseButtonTapped(_ sender: Any) {
        audioPlayer.pause()
        playButtonOutlet.isHidden = false
        pauseButtonOutlet.isHidden = true
    }
    
    @IBAction func cellStopButtonTapped(_ sender: Any) {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        
        if playerViewOutlet.alpha == 1 {
            UIView.animate(withDuration: 1) {
                self.playerViewOutlet.alpha = 0
                self.playerViewOutlet.frame.origin.y += 200
            }
        }
        print("Song stopped playing")
    }
    
    @IBAction func downloadButtonTapped(_ sender: Any) {
        //code for song download
    }

    @objc func PlayButtonTapped(sender: UIButton!) {
        audioPlayer.play()
        playButtonOutlet.isHidden = true
        pauseButtonOutlet.isHidden = false
        print("Song started playing")
        
    }
    @objc func StopButtonTapped(sender: UIButton!) {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        
        if playerViewOutlet.alpha == 1 {
            UIView.animate(withDuration: 1) {
                self.playerViewOutlet.alpha = 0
                self.playerViewOutlet.frame.origin.y += 200
            }
        }
        print("Song stopped playing")
    }
    @objc func PauseButtonTapped(sender: UIButton!) {
        audioPlayer.pause()
        playButtonOutlet.isHidden = false
        pauseButtonOutlet.isHidden = true
        print("Song is paused")
    }
    @objc func ChangeAudioTime(sender: UISlider!) {
        audioPlayer.stop()
        audioPlayer.currentTime = TimeInterval(sliderOutlet.value)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    // Function that updates slider time value
    @objc func updateSlider() {
        sliderOutlet.value = Float(audioPlayer.currentTime)
    }
    
    func fetchSongs() {
        var url = URLComponents(string: "https://freemusicarchive.org/api/get/tracks.json")!
        url.queryItems = [
            URLQueryItem(name: "api_key", value: "CFEFES9JPKBN4T7H"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "genre_id", value: genreeID)

        ]
        
        URLSession.shared.dataTask(with: url.url!) { (data, response, error) in
            
            guard let data = data else {return}
//            let dataString = String(data: data, encoding: .utf8)
            
            guard let songDescription = try? JSONDecoder().decode(SongDescription.self, from: data) else {
                print("Error: Couldn't decode data into dataset")
                return
            }
            
            self.songDataset.append(contentsOf: songDescription.dataset)
            self.totalPages = songDescription.total_pages

            
            DispatchQueue.main.async {
                self.tableview.reloadData()
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
        print(trackDuration)
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
            }
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
