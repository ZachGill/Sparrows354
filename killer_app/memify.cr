# Client used to send requests and get responses (https://crystal-lang.org/api/0.24.2/HTTP/Client/Response.html) back (See https://crystal-lang.org/api/0.24.2/HTTP/Client.html)
require "http/client"
require "http/headers"
# Used to authorize Spotify requests such as searching for tracks (https://crystal-lang.org/api/0.24.2/OAuth2.html)
require "oauth2" 
# (See Client Credentials Flow at https://developer.spotify.com/documentation/general/guides/authorization-guide/)
require "base64"
require "json"
# For generating random indexes
require "random"

# Local imports require a file path
require "./spotify-objects"
require "./imgflip-objects"
require "./memify-creds"

### Spotify OAuth Code ###
# (See Client Credentials Flow at https://developer.spotify.com/documentation/general/guides/authorization-guide/)

# 1. Encode Memify's client ID and secret ID to Base64 as defined by Client Credentials Flow
memifyColonString = "#{MemifyCreds::CLIENT_ID}:#{MemifyCreds::SECRET_ID}"
memifyAuthorizeValue = "Basic #{Base64.strict_encode(memifyColonString)}"  # strict_encode to avoid newline chars

# 2. Create the headers for our POST request (headers using the value created in step 1)
spoofyOAuth2Headers = HTTP::Headers{"Authorization" => memifyAuthorizeValue,
                                    "Content-Type" => "application/x-www-form-urlencoded"}

# 3. Execute a POST request using the header created above
begin
    spoofyOAuth2Response = HTTP::Client.post("https://accounts.spotify.com/api/token",
                                             spoofyOAuth2Headers,
                                             "grant_type=client_credentials") # URL,Header,Body
rescue ex
    # The || operator here will use "unknown" in place of the exception message when the message is nil
    puts "Error authorizing with Spotify: " + (ex.message || "unknown")
    exit(1)
end

# 4. Parse the access_token
begin
    spoofyOAuth2AccessToken = SpotifyAuthResponse.from_json(spoofyOAuth2Response.body) # Isolate the key from the response body
rescue
    puts "Invalid response from Spotify auth: #{spoofyOAuth2Response.body}"
    exit(1)
end

### Spotify Search Code ###
# (See https://developer.spotify.com/console/get-search-item/)

# 1. Create the strings we need to execute our search query (search an artist to return the data of the first track we find with that query)
searchAPIURL = "api.spotify.com/v1/search"
puts "Search the artist you wish to meme: "

# INTERESTING NOTE: Crystal doesn't allow you to pass gets string directly into HTTP Params because it could throw a null pointer, neat!
searchQuery = gets.not_nil!

searchType = "track"
searchLimit = "1"

# 2. Create the params and headers objects for our request using the strings we made in step 1 and the OAuth2 key found above
spoofySearchParams = HTTP::Params.encode({"q" => searchQuery,
                                          "type" => searchType,
                                          "limit" => searchLimit})
spoofySearchHeader = HTTP::Headers{"Authorization" => "Bearer #{spoofyOAuth2AccessToken.access_token}"}

# 3. Execute a GET request using the query created with steps 1 and 2
begin
    # Execute the search query using the auth key created above
    spoofySearchResponse = HTTP::Client.get("https://api.spotify.com/v1/search?#{spoofySearchParams}", spoofySearchHeader)
rescue ex
    puts "Error searching Spotify: " + (ex.message || "unknown")
    exit(1)
end

# 4. Parse the song title from our search query response
begin
    returnedTracks = SpotifySearchResponse.from_json(spoofySearchResponse.body)

    # Exit if our search yielded no results
    if returnedTracks.tracks.items.size == 0
        puts "No results for #{searchQuery}"
        exit(0)
    end

    # Grab the name of the first track from our parsed response.
    # This isn't super nice to look at, but we only have to use one variable ¯\_(ツ)_/¯
    spoofySongString = SpotifySearchResponse.from_json(spoofySearchResponse.body).tracks.items[0].name
rescue
    puts "Invalid response from Spotify search: #{spoofySearchResponse.body}"
    exit(1)
end

### ImgFlip Code ###

# 1. Get Top 100 Memes (see get_memes at https://api.imgflip.com/)

# Get memes
begin
    memesResponse = HTTP::Client.get("https://api.imgflip.com/get_memes")
rescue ex
    puts "Error sending request to ImgFlip: " + (ex.message || "unknown")
    exit(1)
end

# Parse response
begin
    memes = ImgFlipMemesResponse.from_json(memesResponse.body).data.memes
rescue
    puts "Invalid response from ImgFlip: #{memesResponse.body}"
    exit(1)
end

meme = memes[Random.rand(memes.size)]
memeID = meme.id
puts "Using #{meme.name}..."

# 1. Create the template for our meme (See caption_image at https://api.imgflip.com/)

# imgflip ID of our meme, 61544 ID is success kid
# memeID = "61544"

# Set top text to the song we found in Spotify
memeTopText = spoofySongString
bottomTexts = {"Like a boss!", "BOTTOM TEXT"}
memeBottomText = bottomTexts[Random.rand(bottomTexts.size)]

# 2. Create the params for the ImgFlip request using the strings we made in step 1
imgFlipParams = HTTP::Params.encode({"template_id" => memeID,
                                     "username" => MemifyCreds::IMGFLIP_USER,
                                     "password" => MemifyCreds::IMGFLIP_PASS,
                                     "text0" => memeTopText,
                                     "text1" => memeBottomText})

#3. Create and post the meme to the imgflip account specified in step 1
begin
    captionResponse = HTTP::Client.exec("POST","https://api.imgflip.com/caption_image?#{imgFlipParams}")
rescue ex
    puts "Error sending request to ImgFlip: " + (ex.message || "unknown")
    exit(1)
end

#4. Print the URL from our successful response so we can show off our new meme
begin
    memeURL = ImgFlipCaptionResponse.from_json(captionResponse.body).data.url

    # This causes an exception to be thrown
    #memeURL = ImgFlipResponse.from_json(%()).data.url
rescue
    puts "Invalid response from ImgFlip: #{captionResponse.body}"
    exit(1)
end

puts "Your meme is ready! View and download at: "
puts memeURL

# 5. Opens the URL in the default browser (MAC OS ONLY!!!, don't think it's possible to check for OS)
#sleep 3.seconds
#system "open " + memeURL
