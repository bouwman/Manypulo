//
//  RadioView.swift
//  Manypulo
//
//  Created by Tassilo Bouwman on 10/12/2019.
//  Copyright © 2019 Tassilo Bouwman. All rights reserved.
//

import SwiftUI
import MediaPlayer
//
//struct RadioView: View {
//    
//    lazy var mediaPlayer = MPMusicPlayerController.systemMusicPlayer
//    lazy var volumeView = MPVolumeView()
//    var output: Output?
//    var startVolume: Float = 0
//    
//    init() {
//        let query = MPMediaQuery.playlists()
//        guard let playlists = query.collections else { return }
//        
//        for playlist in playlists {
//            if let playlistName = playlist.value(forProperty: MPMediaPlaylistPropertyName) as? String, playlistName == Const.Media.playlist {
//                mediaPlayer.setQueue(with: playlist)
//            }
//        }
//    }
//    
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//struct RadioView_Previews: PreviewProvider {
//    static var previews: some View {
//        RadioView()
//    }
//}
