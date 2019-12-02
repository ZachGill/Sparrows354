class SpotifyAuthResponse
    JSON.mapping(
        access_token: String
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

class SpotifySearchResponse
    JSON.mapping(
        tracks: SpotifyTrack
    )
end