require 'test_helper'

class OnwardCouriersTest < Minitest::Test
  def self.couriers(folder)
    Dir.glob(File.join(__dir__, "../lib/#{folder}/couriers/*.json")).map { |file| JSON.parse(File.read(file)) }
  end

  ONWARD_COURIERS = couriers("onward_data")
  UPSTREAM_COURIERS = couriers("data")
  ONWARD_CLASSES = ONWARD_COURIERS.flat_map { |courier| courier["tracking_numbers"].map { |format| "TrackingNumber::#{format["name"].gsub(/[^0-9A-Za-z]/, '')}" } }
  UPSTREAM_OVERRIDES = ["TrackingNumber::DHLeCommerceGM"].freeze

  should "detect every Onward test number as its own carrier through TrackingNumber.new" do
    ONWARD_COURIERS.each do |courier|
      courier["tracking_numbers"].flat_map { |format| format["test_numbers"]["valid"] }.each do |number|
        assert_equal courier["courier_code"].to_sym, TrackingNumber.new(number).courier_code, number
      end
    end
  end

  should "load a class for every Onward format" do
    ONWARD_CLASSES.each { |name| assert Object.const_defined?(name), name }
  end

  should "leave upstream's valid test numbers to upstream's formats, except the GM override" do
    UPSTREAM_COURIERS.flat_map { |courier| courier["tracking_numbers"] }.flat_map { |format| format["test_numbers"]["valid"] }.each do |number|
      detected = TrackingNumber.new(number).class.name
      refute_includes ONWARD_CLASSES - UPSTREAM_OVERRIDES, detected, number
    end
  end

  should "detect lowercase numbers and numbers upstream already recognizes" do
    {
      "abcdef00000000001" => :veho,
      "GM0000000000000001" => :dhl_ecommerce,
      "61299998820821171811" => :fedex,
      "GFUS00000000000001" => :gofo,
      "1Z879E930346834440" => :ups,
      "9400111206206406260787" => :usps,
      "TBA000000000000" => :amazon,
      "0073938000549297" => :canada_post,
    }.each do |number, courier_code|
      assert_equal courier_code, TrackingNumber.new(number).courier_code, number
    end
  end

  should "not give a number the carrier of an ignored upstream format" do
    ignored_formats = UPSTREAM_COURIERS.flat_map do |courier|
      courier["tracking_numbers"].map { |format| [courier["courier_code"].to_sym, format] }
    end.select { |_, format| TrackingNumber::IGNORED_UPSTREAM_FORMAT_IDS.include?(format["id"]) }
    assert_equal TrackingNumber::IGNORED_UPSTREAM_FORMAT_IDS.size, ignored_formats.size

    ignored_formats.each do |courier_code, format|
      format["test_numbers"]["valid"].each { |number| refute_equal courier_code, TrackingNumber.new(number).courier_code, number }
    end
    assert_equal :unknown, TrackingNumber.new("00000000000000").courier_code
    assert_equal :unknown, TrackingNumber.new("ABC123456789").courier_code
  end

  should "return the national post's code for an S10 number from a mapped country, and s10 otherwise" do
    TrackingNumber::NATIONAL_POST_COURIER_CODES.each do |country, courier_code|
      assert_equal courier_code.to_sym, TrackingNumber.new("RB123456785#{country}").courier_code, country
    end
    assert_equal "Royal Mail Group plc", TrackingNumber.new("RB123456785GB").courier_name
    assert_equal :s10, TrackingNumber.new("RB123456785CV").courier_code
    assert_equal :s10, TrackingNumber.new("RB123456785US").courier_code
  end

  should "not match a FedEx number that is part of a longer barcode" do
    assert_empty TrackingNumber.search("ref 92 61290000000000000001 ok")
    assert_equal [:fedex], TrackingNumber.search("ref 61290000000000000001 ok").map(&:courier_code)
  end

  should "list every carrier code the gem can return" do
    codes = TrackingNumber.courier_codes

    assert_includes codes, :s10
    assert_includes codes, :royal_mail
    assert_includes codes, :dhl_ecommerce
    assert_includes codes, :ups
    refute_includes codes, :unknown
  end
end
