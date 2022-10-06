// it's not stated wether the JS code must use Uint32Array or not
// just as it's not stated wether I can or cannot use the data as string
// so I will go the way I think is the most primitive and simple

const { utils } = require("ethers");

/// encrypts or decrypts data
/// @param {array} data array of bytes
/// @param {array} key array of bytes
/// @returns {array} array of bytes
module.exports = function encryptDecrypt(data, key) {
  let raw = "";
  for (let i = 0; i < data.length; i += 32) {
    const hexifiedChunk = utils.hexlify(data.slice(i, i + 32));
    // 32 bytes - 64 hex chars + 2 chars for 0x
    const padding = 66 - hexifiedChunk.length;

    let chunk = BigInt(hexifiedChunk.padEnd(66, "0"));

    chunk ^= BigInt(
      utils.keccak256(
        utils.hexlify(
          utils.solidityPack(["bytes", "uint256"], [utils.hexlify(key), i])
        )
      )
    );

    raw += utils.hexlify(chunk).slice(2, -padding || 66);
  }

  return utils.arrayify(raw, { allowMissingPrefix: true });
};
