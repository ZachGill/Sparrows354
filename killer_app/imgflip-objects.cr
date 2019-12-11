### Classes for parsing ImgFlip responses into ###

class ImgFlipMeme
    JSON.mapping(
        id: String,
        name: String
    )
end

class ImgFlipMemesData
    JSON.mapping(
        memes: Array(ImgFlipMeme)
    )
end

class ImgFlipMemesResponse
    JSON.mapping(
        success: Bool,
        data: ImgFlipMemesData
    )
end

class ImgFlipCaptionData
    JSON.mapping(
        url: String
    )
end

class ImgFlipCaptionResponse
    JSON.mapping(
        data: ImgFlipCaptionData
    )
end