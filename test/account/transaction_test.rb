require "test_helper"
require 'bitcoin_secp256k1'

class TransactionTest < Minitest::Test
  def setup
    @provider = Minitest::Mock.new
    @wallet = Zilliqa::Account::Wallet.new(@provider)
    @address = nil
    10.times do
      ret = @wallet.create
      @address = ret unless @address
    end
  end

  def test_should_poll_and_call_queued_handlers_on_confirmation
    responses = [
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          balance: 888,
          nonce: 1,
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          TranID: 'some_hash',
          Info: 'Non-contract txn, sent to shard',
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          ID: 'some_hash',
          receipt: { cumulative_gas: 1000, success: true },
        },
      },
    ].map do |res|
      JSON.parse(JSON.generate(res))
    end

    tx_params = {
      version: 0,
      amount: '0',
      gas_price: '1000',
      gas_limit: 1000,
      to_addr: '1234567890123456789012345678901234567890'
    }

    tx = Zilliqa::Account::Transaction.new(tx_params, @provider)

    @provider.expect("GetBalance", responses[0], [@address])
    pending = @wallet.sign(tx)

    @provider.expect("GetTransaction", responses[2], ['some_hash'])
    confirmed = pending.confirm('some_hash');
    state = confirmed

    assert confirmed.confirmed?
    assert_equal ({"cumulative_gas"=>1000, "success"=>true}), state.receipt

    @provider.verify
  end

  def test_should_not_reject_the_promise_if_receipt_success_equal_false
    responses = [
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          balance: 888,
          nonce: 1,
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          TranID: 'some_hash',
          Info: 'Non-contract txn, sent to shard',
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          ID: 'some_hash',
          receipt: { cumulative_gas: 1000, success: false },
        },
      },
    ].map do |res|
      JSON.parse(JSON.generate(res))
    end

    tx_params = {
      version: 0,
      amount: '0',
      gas_price: '1000',
      gas_limit: 1000,
      to_addr: '1234567890123456789012345678901234567890'
    }

    tx = Zilliqa::Account::Transaction.new(tx_params, @provider)

    @provider.expect("GetTransaction", responses[2], ['some_hash'])
    rejected = tx.confirm('some_hash');

    assert !rejected.receipt['success']

    @provider.verify
  end

  def test_should_try_for_n_attempts_before_timing_out
    responses = [
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          balance: 888,
          nonce: 1,
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          TranID: 'some_hash',
          Info: 'Non-contract txn, sent to shard',
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        error: {
          code: -888,
          message: 'Not found',
        }
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          ID: 'some_hash',
          receipt: { cumulative_gas: 1000, success: true },
        }
      }
    ].map do |res|
      JSON.parse(JSON.generate(res))
    end

    tx_params = {
      version: 0,
      amount: '0',
      gas_price: '1000',
      gas_limit: 1000,
      to_addr: '1234567890123456789012345678901234567890'
    }

    tx = Zilliqa::Account::Transaction.new(tx_params, @provider)

    40.times do |i|
      @provider.expect("GetTransaction", responses[2], ['40_times'])
    end

    assert_raises 'The transaction is still not confirmed after 40 attempts.' do
      tx.confirm('40_times', 40, 0)
    end

    @provider.verify
  end

  def test_encode_transaction_proto
    tx_params = {
      version: 0,
      nonce: 0,
      sender_pub_key: '0246e7178dc8253201101e18fd6f6eb9972451d121fc57aa2a06dd5c111e58dc6a',
      amount: '0',
      gas_price: '100',
      gas_limit: 1000,
      to_addr: '3c9b415b19ae4035503a06192a0fad76e04243',
      code: 'abc',
      data: 'def'
    }

    tx = Zilliqa::Account::Transaction.new(tx_params, nil)

    ret = tx.bytes
    ret_hex = Zilliqa::Util.encode_hex(ret)
    exp = '080010001a133c9b415b19ae4035503a06192a0fad76e0424322230a210246e7178dc8253201101e18fd6f6eb9972451d121fc57aa2a06dd5c111e58dc6a2a120a100000000000000000000000000000000032120a100000000000000000000000000000006438e80742036162634a03646566'
    assert_equal exp.downcase, ret_hex
  end

  def test_encode_transaction_proto_for_null_code_and_null_data
    tx_params = {
      version: 0,
      nonce: 0,
      sender_pub_key: '0246e7178dc8253201101e18fd6f6eb9972451d121fc57aa2a06dd5c111e58dc6a',
      amount: '10000',
      gas_price: '100',
      gas_limit: 1000,
      to_addr: '3c9b415b19ae4035503a06192a0fad76e04243'
    }

    tx = Zilliqa::Account::Transaction.new(tx_params, nil)

    ret = tx.bytes
    ret_hex = Zilliqa::Util.encode_hex(ret)
    exp = '080010001a133c9b415b19ae4035503a06192a0fad76e0424322230a210246e7178dc8253201101e18fd6f6eb9972451d121fc57aa2a06dd5c111e58dc6a2a120a100000000000000000000000000000271032120a100000000000000000000000000000006438e807'
    assert_equal exp.downcase, ret_hex
  end

  def test_devnet
    id = nil
    version = 21_823_489
    gas_price = '2000000000'
    gas_limit = 50

    sender_pub_key = '027eaa76955940798e22ec4007b00dbf0002fcd34f501f58c04b06c604f2228076'
    to_addr = '0xFeEd7997A0a45682CD4D8CEda27f2d81F6ba587c'
    amount = '1000000000000'

    provider = Zilliqa::Jsonrpc::Provider.new('https://dev-api.zilliqa.com')
    signer = Zilliqa::Account::Wallet.new(provider)

    private_key = '7e78c742bca06824e4a5f0591260a2646339507c231daa5a47bf91d801f98239'
    signer.add_by_private_key(private_key)

    tx_params = {
      id: id,
      version: version,
      sender_pub_key: sender_pub_key,
      amount: amount,
      gas_price: gas_price,
      gas_limit: gas_limit,
      to_addr: to_addr,
      code: nil,
      data: nil
    }

    tx = Zilliqa::Account::Transaction.new(tx_params, provider, Zilliqa::Account::Transaction::TX_STATUSES[:initialized], false)

    signed = signer.sign(tx)
    payload = signed.to_payload

    provider.CreateTransaction(payload)
  end
end
