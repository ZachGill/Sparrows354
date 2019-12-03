### Classes for parsing ImgFlip responses into ###

class ImgFlipData
    JSON.mapping(
        url: String
    )
end

class ImgFlipResponse
    JSON.mapping(
        data: ImgFlipData
    )
end