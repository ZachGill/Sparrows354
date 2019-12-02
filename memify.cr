require "http/client" # Client used to send requests and get responses (https://crystal-lang.org/api/0.24.2/HTTP/Client/Response.html) back (See https://crystal-lang.org/api/0.24.2/HTTP/Client.html)
require "http/headers"
require "oauth2" # Used to authorize Spotify requests such as searching for tracks (https://crystal-lang.org/api/0.24.2/OAuth2.html)
require "base64" # (See Client Credentials Flow at https://developer.spotify.com/documentation/general/guides/authorization-guide/)
require "json"

class SpotifyTracks
  JSON.mapping(
    tracks: Array(SpotifyItem)
  )
end

class SpotifyItem
  JSON.mapping(
    name: String
  )
end

### Spotify OAuth Code (See Client Credentials Flow at https://developer.spotify.com/documentation/general/guides/authorization-guide/)

# 1. Encode Memify's client ID and secret ID to Base64 as defined by Client Credentials Flow
memifyClientID = "2a14ddcae92b4b24ad74583b5cd6a87a"
memifySecretID = "dea49ef0ee4d4cd6904cdb978bb75bb2"
memifyColonString = memifyClientID + ":" + memifySecretID
memifyAuthorizeValue = "Basic " + Base64.strict_encode(memifyColonString) # strict_encode to avoid newline chars

# 2. Create the headers for our POST request (headers using the value created in step 1)
spoofyOAuth2Headers = HTTP::Headers{"Authorization" => memifyAuthorizeValue,"Content-Type" => "application/x-www-form-urlencoded"}

# 3. Execute a POST request using the header created above
spoofyOAuth2Response = HTTP::Client.post "https://accounts.spotify.com/api/token",spoofyOAuth2Headers,"grant_type=client_credentials" # URL,Header,Body

# 4. Parse the access_token
spoofyOAuth2AccessToken = spoofyOAuth2Response.body.[](17,83) # Isolate the key from the response body


### Spotify Search Code (See https://developer.spotify.com/console/get-search-item/)

# 1. Create the strings we need to execute our search query (search an artist to return the data of the first track we find with that query)
searchAPIURL = "api.spotify.com/v1/search"
puts "Search the artist you wish to meme: "
searchQuery = gets.not_nil! # INTERESTING NOTE: Crystal doesn't allow you to pass gets string directly into HTTP Params because it could throw a null pointer, neat!
searchType = "track"
searchLimit = "1"

# 2. Create the params and headers objects for our request using the strings we made in step 1 and the OAuth2 key found above
spoofySearchParams = HTTP::Params.encode({"q" => searchQuery, "type" => searchType, "limit" => searchLimit})
spoofySearchHeader = HTTP::Headers{"Authorization" => "Bearer " + spoofyOAuth2AccessToken}

# 3. Execute a GET request using the query created with steps 1 and 2
spoofySearchResponse = HTTP::Client.get "https://api.spotify.com/v1/search?" + spoofySearchParams,spoofySearchHeader # Execute the search query using the auth key created above

# 4. Parse the song title from our search query response (HOW???)
spoofySearchResponseJSON = JSON.parse(spoofySearchResponse.body.to_json)#.lines.[35] # NEED TO PARSE SONG TITLE FROM RESPONSE, tracks.name field
puts spoofySearchResponseJSON
spoofySongString = SpotifyTracks.from_json(spoofySearchResponseJSON).tracks[0].name #parsed JSON


### imgFlip Code

# 1. Create the template for our meme (See caption_image at https://api.imgflip.com/)
memeID = "61544" # imgflip ID of our meme, 61544 ID is success kid
imgFlipUser = "ilovemaymays"
imgFlipPass = "ilovememesiloveem"
memeTopText = spotifySongString # REPLACE WITH SONG TITLE FOUND BY SPOTIFY
memeBottomText = "Like a boss!"

# 2. Create the params for the ImgFlip request using the strings we made in step 1
imgFlipParams = HTTP::Params.encode({"template_id" => memeID, "username" => imgFlipUser, "password" => imgFlipPass, "text0" => memeTopText, "text1" => memeBottomText})

#3. Create and post the meme to the imgflip account specified in step 1
memeResponse = HTTP::Client.exec "POST","https://api.imgflip.com/caption_image?" + imgFlipParams

#4. Print the URL from our successful response so we can show off our new meme
memeURL = memeResponse.body.[](31,35).delete("\\")
puts "Your meme is ready! View and download at: "
puts memeURL # Parse the body so it's only the URL and delete the extraneous \\'s

# 5. Opens the URL in the default browser (MAC OS ONLY!!!, don't think it's possible to check for OS)
#sleep 3.seconds
#system "open " + memeURL
