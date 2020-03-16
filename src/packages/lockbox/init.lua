local Lockbox = {};

--[[
package.path =  "./?.lua;"
				.. "./cipher/?.lua;"
				.. "./digest/?.lua;"
				.. "./kdf/?.lua;"
				.. "./mac/?.lua;"
				.. "./padding/?.lua;"
				.. "./test/?.lua;"
				.. "./util/?.lua;"
				.. package.path;
]]--
Lockbox.ALLOW_INSECURE = true;

Lockbox.insecure = function()
	assert(Lockbox.ALLOW_INSECURE,"This module is insecure!  It should not be used in production.  If you really want to use it, set Lockbox.ALLOW_INSECURE to true before importing it");
end

-- local cipher = {}
-- cipher.aes128 = import(.cipher.aes128)
-- Lockbox.BehaviorAction = import(".actions.BehaviorAction")

Lockbox.util = {}
Lockbox.util.array = import(".util.array")
Lockbox.util.base64 = import(".util.base64")
Lockbox.util.bit = import(".util.bit")
Lockbox.util.queue = import(".util.queue")
Lockbox.util.steam = import(".util.stream")

Lockbox.digest = {}
Lockbox.digest.md2 = import(".digest.md2")
Lockbox.digest.md4 = import(".digest.md4")
Lockbox.digest.md5 = import(".digest.md5")
Lockbox.digest.ripemd128 = import(".digest.ripemd128")
Lockbox.digest.ripemd160 = import(".digest.ripemd160")
Lockbox.digest.sha1 = import(".digest.sha1")
Lockbox.digest.sha2_224 = import(".digest.sha2_224")
Lockbox.digest.sha2_256 = import(".digest.sha2_256")

Lockbox.cipher = {}
Lockbox.cipher.aes128 = import(".cipher.aes128")
Lockbox.cipher.aes192 = import(".cipher.aes192")
Lockbox.cipher.aes256 = import(".cipher.aes256")
Lockbox.cipher.des3 = import(".cipher.des3")
Lockbox.cipher.des = import(".cipher.des")

Lockbox.cipher.mode = {}
Lockbox.cipher.mode.cbc = import(".cipher.mode.cbc")
Lockbox.cipher.mode.cfb = import(".cipher.mode.cfb")
Lockbox.cipher.mode.ctr = import(".cipher.mode.ctr")
Lockbox.cipher.mode.ecb = import(".cipher.mode.ecb")
Lockbox.cipher.mode.ofb = import(".cipher.mode.ofb")
Lockbox.cipher.mode.pcbc = import(".cipher.mode.pcbc")

Lockbox.kdf = {}
Lockbox.kdf.pbkdf2 = import(".kdf.pbkdf2")

Lockbox.mac = {}
Lockbox.mac.hmac = import(".mac.hmac")

Lockbox.padding = {}
Lockbox.padding.ansix923 = import(".padding.ansix923")
Lockbox.padding.isoiec7816 = import(".padding.isoiec7816")
Lockbox.padding.pkcs7 = import(".padding.pkcs7")
Lockbox.padding.zero = import(".padding.zero")

Lockbox.encrypt = import(".encrypt")

return Lockbox;
