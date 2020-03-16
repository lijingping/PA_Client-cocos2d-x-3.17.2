local Lockbox = cc.load("lockbox")
local exp = Lockbox.encrypt
local Base64 = Lockbox.util.base64
--local Stream = Lockbox.util.steam
local Array = Lockbox.util.array
local Stream = Lockbox.util.steam
local Digest = Lockbox.digest.md5

local Crypto = {}

function Crypto:encrypt(text)
	return exp.encrypt(text);
end

function Crypto:decrypt(encrypted)
	return exp.decrypt(encrypted)
end

function Crypto:enbase64(text)
	return Base64.fromStream(Stream.fromString("sean"));
end

function Crypto:debase64(base64text)
	local array = Base64.toArray(base64text)
	return Array.toString(array) 
end

function Crypto:md5(text)
	return Digest().update(Stream.fromString(text)).finish().asHex();
end

return Crypto