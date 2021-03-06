require "test_helper"

class SchnorrTest < Minitest::Test
  def test_sign
    ds = datas['datas']

    ds.each do |d|
      message = d[0]
      public_key = d[1]
      private_key = d[2]

      sig = Zilliqa::Crypto::Schnorr.sign(message, private_key, public_key)
      result = Zilliqa::Crypto::Schnorr.verify(message, sig, public_key)
      assert result
    end
  end

  def test_verify
    ds = datas['datas']

    ds.each do |d|
      message = d[0]
      public_key = d[1]
      private_key = d[2]
      r = d[4]
      s = d[5]

      signature = Zilliqa::Crypto::Signature.new(r, s)
      result = Zilliqa::Crypto::Schnorr.verify(message, signature, public_key)
      assert result
    end
  end

  def test_try_sign
    message = "A6DC3EC1CF93C813645AD0401F17E02DEB0C3A7AD0DD1AF159BE69BAFCB866C9902FDF9E6049D9C6EB79A6EA071AA5613AFA9E4405A7E9E3BA6BB1D8B479134A7D1309670D0437327BA0FC9F9900EF602BFA37E9A7D055A6452BF28DCDD110D282F9A7B9083267C6251B28389BE72AE47530C14969043CC3ABA18DCCE38113B2F24955254EE7AEF7C68FE92324DFF8311D75A6F12D4F01D136D7C72D5407F2E598DE854F4203054CC588BDDA7385551C18A3D47D3EA5256C141E7847D412D768A6C4506E9FD9231127063F42D58B722311A7BCC5306706E0A4E445A27DAD264F6B0CF271AAD6A8B3352048281073657C872E97DBA73AB7E70CEE50B2CDAA3C8885FB0B3424A1352E271831061F9798987C5EDFF89532A46E3B3E0E952FBD3405F4C7F856D05920FF820929054E2BFB2C7BF1123FE492A1E25A497A6E23BAA4503B25129525317474B9AEC3B59A80D49C626DA9E139079BACF16C037829237C21E36F4042E14300E5042CD5D7F0E930EF1B8D378BA87AC7559738E7868389AAE126D177A5A228BA7E95BBF13F85E1B67D543D22D70F5867C5DCE0B80CED2D7B3925ADD9E62FB116F42746C31BFC16D72CC7364CC81A22BAA4E69D306B737E08F3F6F462B8EA1B2C5C9A3D5F7C57FAC41DC05950958C5155893A1FB4681A1B14CD99F32A50C91B273ED0E72F441E0F72DAED8E2058812B0B95579F6BB3678D3907"
    private_key = "A1578BF9E523BD8409ACF16677BFBA3FD757FC174DC896992DBB4126C237398D"

    public_key = "02a8368ee10bff2e04a9898dbbdb347cce707119a47c98fa00876bac947737939c"

    exp_signature = "81A8195DDD6DA31B0DB2B0E82ED899461A4D7AC00605B9731577FEEA478D94CBFBC31B7E9A90CE745B076F835737F5C5CB86AC5A95F871FFCB99FBEE6FF52D"

    k_bn = OpenSSL::BN.new('24496634657573626939630273597777596474511689412653372979371659856036567975428', 10)
    signature = Zilliqa::Crypto::Schnorr.try_sign(message, private_key, k_bn, public_key)
    assert_equal exp_signature, signature.to_s
  end

  def test_sign_and_verify
    message = "080010001a142e3c9b415b19ae4035503a06192a0fad76e0424322230a210246e7178dc8253201101e18fd6f6eb9972451d121fc57aa2a06dd5c111e58dc6a2a120a10ffffffffffffffffffffffffffffffff32120a100000000000000000000000000000006438e80742036162634a03646566"
    private_key = "e19d05c5452598e24caad4a0d85a49146f7be089515c905ae6a19e8a578a6930"
    public_key = "0246E7178DC8253201101E18FD6F6EB9972451D121FC57AA2A06DD5C111E58DC6A"

    sig = Zilliqa::Crypto::Schnorr.sign(message, private_key, public_key)
    result = Zilliqa::Crypto::Schnorr.verify(message, sig, public_key)

    assert result
  end

  def datas
    @datas = JSON.parse File.read(File.expand_path('../../fixtures/schnorr.json', __FILE__))
  end
end
