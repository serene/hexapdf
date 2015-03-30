# -*- encoding: utf-8 -*-

require 'test_helper'
require 'hexapdf/pdf/encryption/arc4'

module ARC4EncryptionTests

  def setup
    super
    @encrypted = ['BBF316E8D940AF0AD3', '1021BF0420', '45A01F645FC35B383552544B9BF5'].
      map {|c| [c].pack('H*')}
    @plain = ['Plaintext', 'pedia', 'Attack at dawn'].each {|s| s.force_encoding('BINARY')}
    @keys = ['Key', 'Wiki', 'Secret']
  end

  def test_processes_the_test_vectors_from_the_RC4_wikipeda_page
    @keys.each_with_index do |key, i|
      assert_equal(@encrypted[i], @algorithm_class.new(key).process(@plain[i]))
    end
  end

  def test_can_accept_one_big_chunk_or_multiple_smaller_ones
    big = @algorithm_class.new('key')
    small = @algorithm_class.new('key')
    assert_equal(big.process('some big data chunk'),
                 small.process('some') << small.process(' big') << small.process(' data chunk'))
  end

end

describe HexaPDF::PDF::Encryption::ARC4 do

  before do
    @test_class = Class.new do
      prepend HexaPDF::PDF::Encryption::ARC4

      attr_reader :key

      def initialize(key)
        @key = key
      end

      def process(data)
        data
      end
      alias :encrypt :process
      alias :decrypt :process

    end
  end

  it "extends the class object with the necessary methods" do
    assert_respond_to(@test_class, :encrypt)
    assert_respond_to(@test_class, :decrypt)
  end

  it "correctly uses klass.encrypt and klass.decrypt" do
    assert_equal('data', @test_class.encrypt('mykey', 'data'))
    assert_equal('data', @test_class.decrypt('mykey', 'data'))
  end

end
