class_name EncryptLoad

const ENCRYPTION_KEY = "dRqZbnNWkqb6M81dd8UFlsbs73zKFd"

static func encrypt_payload(payload: String) -> String:
    var ctx = HMACContext.new()
    var err = ctx.start(HashingContext.HASH_SHA256, ENCRYPTION_KEY.to_utf8_buffer())
    assert(err == OK)
    err = ctx.update(payload.to_utf8_buffer())
    assert(err == OK)
    return ctx.finish().hex_encode()