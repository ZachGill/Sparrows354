class SpotifyAuthResponse
    JSON.mapping(
        access_token: String,
        token_type: String,
        expires_in: Int32,
        scope: String
    )
end

class SpotifyItem
  JSON.mapping(
    name: String
  )
end

class SpotifyTrack
    JSON.mapping(
        items: Array(SpotifyItem)
    )
end

class SpotifyTracks
    JSON.mapping(
        tracks: SpotifyTrack
    )
end