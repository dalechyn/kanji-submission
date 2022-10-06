const encryptDecrypt = require("./encryptDecrypt.js");
const { utils } = require("ethers");

const KEY = utils.arrayify(
  "0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890"
);

test("encrypts and decrypts data correctly", () => {
  const data =
    "Ethereum is a decentralized, open-source blockchain with smart contract functionality. Ether is the native cryptocurrency of the platform. Among cryptocurrencies, ether is second only to bitcoin in market capitalization.";

  const bytes = utils.toUtf8Bytes(data);

  const bytes2 = encryptDecrypt(bytes, KEY);
  expect(
    [...bytes2].map((el) => el.toString(16).padStart(2, "0")).join("")
  ).toEqual(
    "5492834a6d8b60c64fad9eb18f7824ec278947a4741c52b19b8906cd94748f25a7be9d31c327d28b8d70d2ec3519ea101d624a7f4d280772f06516ebe44298897836cb68923956b0da22bab8bd26ebff12f222af6f3cee02c038b0fd6aa50ce4dd57ed74cc02211c80cfc98eb3870b6a909c35739c8de3a88b9b68d0ae284797bbc7329b4a19e1544fc1360a404f04497901172f3660760cdef81e5f7ae01ee5517abc1fb2b59aa1d4e3af464b3382571e41810856168f3229efcd4b9d1cc0e14fd71a331a21ec95320e76b915138f300109fef5917e4d49f1063056"
  );

  const bytes3 = encryptDecrypt(bytes2, KEY);
  expect(bytes3).toEqual(bytes);

  const decryptedData = utils.toUtf8String(bytes3);
  expect(data).toEqual(decryptedData);
});
