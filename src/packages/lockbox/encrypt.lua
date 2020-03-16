--
-- Created by IntelliJ IDEA.
-- User: pt
-- Date: 16-2-23
-- Time: 下午3:50
-- To change this template use File | Settings | File Templates.
--

local iv = "7e09c984fd35d6ed99a18ed0e47c7f312cc2755a42ce994e75be79e9d9df0464"
local password = "47ea70cf08872bdb4afad3432b01d963ac7d165f6b575cd72ef47498f4459a90"

local mix1 = {
    {0x30, 0x11, 0x6f, 0x8, 0x79, 0x29, 0x7, 0x52, 0x5c, 0x35, 0x79, 0x15, 0x6f, 0x19, 0x3f, 0x7},
    {0x1, 0x74, 0x6a, 0x79, 0x31, 0x12, 0x75, 0x18, 0x4b, 0x11, 0x57, 0x73, 0x48, 0x66, 0x6b, 0x60},
    {0x18, 0x25, 0x64, 0x72, 0xc, 0x2c, 0x50, 0x62, 0x2e, 0x64, 0x13, 0x1f, 0x25, 0xf, 0x24, 0x54},
    {0x14, 0x7a, 0x5b, 0x7a, 0x14, 0x13, 0x5b, 0x73, 0x8, 0x3a, 0x77, 0x3e, 0x16, 0x58, 0x47, 0x76},
    {0x10, 0x31, 0x1a, 0x3c, 0x50, 0x79, 0x20, 0x3c, 0x68, 0x38, 0x7b, 0x5e, 0x1e, 0x30, 0x5b, 0x22},
    {0x56, 0x2, 0x25, 0x14, 0x54, 0xb, 0x16, 0x38, 0x7c, 0x69, 0x26, 0x27, 0x2, 0x38, 0x29, 0x37},
    {0x66, 0x62, 0x3a, 0x1c, 0x20, 0x6d, 0x76, 0x2e, 0x54, 0x30, 0x4c, 0x2b, 0x3c, 0x6a, 0x75, 0xc},
    {0x34, 0x41, 0x3a, 0x5f, 0x5c, 0x14, 0x24, 0x19, 0x46, 0xb, 0x19, 0x33, 0x3f, 0x5d, 0x4c, 0x71},
    {0x68, 0x2e, 0x5e, 0x6c, 0x1a, 0x51, 0x46, 0x29, 0x24, 0x42, 0x9, 0x2e, 0x48, 0x27, 0x6c, 0x4f},
    {0x29, 0x73, 0x3d, 0x44, 0x4f, 0x2b, 0x7f, 0x65, 0x37, 0x10, 0x57, 0x51, 0x7d, 0x6f, 0x7f, 0x28}
}

local s1 = {
    {11, 13, 7, 14, 1, 8, 9, 3, 6, 2, 15, 5, 0, 4, 12, 10},
    {11, 14, 7, 13, 0, 15, 10, 6, 12, 5, 3, 8, 4, 2, 1, 9},
    {1, 14, 9, 10, 0, 15, 3, 4, 6, 8, 12, 5, 2, 11, 7, 13},
    {2, 14, 10, 4, 1, 7, 6, 9, 3, 13, 0, 11, 8, 5, 12, 15},
    {3, 7, 14, 13, 0, 10, 9, 4, 11, 15, 12, 5, 8, 1, 2, 6},
    {9, 15, 5, 0, 11, 14, 2, 3, 7, 6, 1, 10, 4, 8, 13, 12},
    {15, 10, 3, 14, 12, 5, 1, 13, 11, 6, 7, 0, 2, 8, 4, 9},
    {14, 5, 0, 11, 7, 12, 15, 8, 6, 4, 2, 9, 13, 3, 1, 10},
    {8, 6, 11, 4, 14, 12, 15, 7, 9, 1, 2, 13, 0, 10, 5, 3},
    {1, 3, 2, 11, 15, 14, 10, 4, 5, 9, 8, 7, 6, 12, 0, 13},
}


----------------------------------------------------------import-methods------------------------------------

local Array = import(".util.array")
local Base64 = import(".util.base64")
local Bit = import(".util.bit")

-- local Array = require("lockbox.util.array")
-- local Base64 = require("lockbox.util.base64")
-- local Bit = require("lockbox.util.bit")

----------------------------------------------------------close-import-methods------------------------------------
local MAX_STEP = 8
local BLOCK_BYTES = 32;

local exp = {}

local Context = {}
local Block = {}

local util =  {};
-------------------- help methods ---------------------
function util.print_table(tb)
    return Array.toHex(tb)
end

function util.xor_buf(a, b)
    local ret = {}
    for i = 1, #a do
        ret[i] = Bit.xor(a[i], b[i])
    end
    return ret
end


function util.map_buf(array, map)
    local ret = {}
    for i = 1, #map do
        ret[i] = array[map[i] + 1]
    end
    return ret
end

function util.array_to_blocks(array)
    local ret = {}
    local pos = 1
    while pos <= #array do
        local block = Block:new()
        local i = 1
        while i <= BLOCK_BYTES and pos <= #array do
            block[i] = array[pos]
            i = 1 + i
            pos = 1 + pos
        end
        table.insert(ret, block)
    end
    return ret
end

function util.block_count(size)
    return math.floor((size + 32+4)/BLOCK_BYTES)
end

function util.append_size_to_blocks(blocks, size)
    local bs = util.block_count(size)
    if #blocks < bs then
        local block = Block:new()
        table.insert(blocks, block)
    end

    local last = blocks[#blocks]
    util.write_uint32be(last, size, BLOCK_BYTES-4 +1)
end


function util.write_uint32be(block, value, offset)
    for i= 1, 4 do
        block[offset + 4 - i] = value % 256
        value = math.floor(value/256)
    end
end

function util.read_uint32be(block, offset)
    local ret = 0
    for i= 1, 4 do
        ret = block[offset + i - 1] + ret * 256
    end
    return ret
end

-------------------- close help methods ---------------------


function Block:new()
    local o = {}
    for i = 1, BLOCK_BYTES do
        o[i] = 0
    end
    return o
end



function Context:new(pwd, iv)
    local o = {}
    o.pwd = Array.fromHex(pwd)
    o.iv = Array.fromHex(iv)
    setmetatable(o, self)
    self.__index = self

    return o
end


function Context:f(array, keys, map)
    local ret = {}
    for i = 1, BLOCK_BYTES/2 do
        ret[i] = math.fmod(Bit.bxor(array[i], self.iv[i]) * keys[i], 256)
    end

    for i = 1, BLOCK_BYTES/2 do
        ret[i] = Bit.bxor(ret[i], self.pwd[i])
    end
    return util.map_buf(ret, map)

end

function Context:encrypt(array)
    local a = Array.slice(array, 1, BLOCK_BYTES/2)
    local b = Array.slice(array, BLOCK_BYTES/2 + 1, BLOCK_BYTES)
    local c, d

    for i = 1, MAX_STEP do
        c = self:f(a, mix1[i], s1[i])
        d = a
        a = Array.XOR(b, c)
        b = d
    end
    a, b = b , a

    return Array.concat(a, b)

end


function Context:decrypt(array)
    local a = Array.slice(array, 1, BLOCK_BYTES/2)
    local b = Array.slice(array, BLOCK_BYTES/2 + 1, BLOCK_BYTES)
    local c, d

    for j = 1, MAX_STEP do
        local i = MAX_STEP - j + 1
        c = self:f(a, mix1[i], s1[i])
        d = a
        a = Array.XOR(b, c)
        b = d
    end
    a, b = b , a

    return Array.concat(a, b)
end


exp.encrypt = function (text)

    local array = Array.fromString(text)

    local size = #array
    local ctx = Context:new(password, iv)

    local blocks = util.array_to_blocks(array)
    util.append_size_to_blocks(blocks, size)

    local enc_blocks = {}
    for i = 1, #blocks do
        enc_blocks = Array.concat(enc_blocks, ctx:encrypt(blocks[i]))
    end

    return Base64.fromArray(enc_blocks)
end

exp.decrypt = function (text)
    print("exp.decrypt" .. text)
    local input = Base64.toString(text)
    local array = Array.fromString(input)
    local ctx = Context:new(password, iv)

    local blocks = util.array_to_blocks(array)

    local dec_blocks = {}
    for i = 1, #blocks do
        dec_blocks = Array.concat(dec_blocks, ctx:decrypt(blocks[i]))
    end

    local size = util.read_uint32be(dec_blocks, #dec_blocks - 4 + 1)

    -- 临时处理编码错误 直接返回
    if size > 1000 then
        return
    end

    return Array.toString(Array.slice(dec_blocks, 1, size))
end





----example
--local encrypted = exp.encrypt("helloadsafdfasfdfsdfasdfafhelloadsafdfasfdfsdfasdfafasdfsdfhelloadsafdfasfdfsdfasdfafasdfsdfasdfsdf")
--print(encrypted)
-- print(exp.decrypt("57bf98734d7d08fa8983b5f532c2db0958ece6b14070468ffe2d469e0107d9bd"))


return exp;