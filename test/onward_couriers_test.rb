require 'test_helper'

class OnwardCouriersTest < Minitest::Test
  should "detect each Onward carrier through TrackingNumber.new" do
    {
      "YWE00000000000001" => :ywe,
      "YWLAX000000000001" => :ywe,
      "YW000000001" => :yanwen,
      "UUS0000000000000001" => :uniuni,
      "UR00000000000000001" => :uniuni,
      "U000000000000001" => :uniuni,
      "SPXABC000000000001" => :speedx,
      "SPXABC000000000000000001" => :speedx,
      "1MSPX00000000000001" => :speedx,
      "1LSABC000000001" => :lasership,
      "BTPA00000ABC123" => :better_trucks,
      "BTS_00000ABCDEF" => :better_trucks,
      "VHABCDEF000001" => :veho,
      "abcdef00000000001" => :veho,
      "SWX000000000000000001" => :swiftx,
      "JT00000000000001" => :jitsu,
      "ND0ABCDEF000000000A1" => :ics_courier,
      "TUSKABCDEFGHIJKL" => :tusk,
      "GM0000000000000001" => :dhl_ecommerce,
      "GFCA00000000000001" => :gofo_canada,
      "GFFR00000000000001" => :gofo_france,
      "GFNL00000000000001" => :gofo_netherlands,
      "GFES00000000000001" => :gofo_spain,
      "CR000000000001" => :cirro,
      "CRA000000000001" => :cirro,
      "CRIN00000000000001" => :cirro,
      "33ABC000000000000000001" => :australia_post,
      "CDLABCDEF000001" => :cdl,
      "SE000000ABC1" => :intelcom,
      "ESIG00000000000001" => :intelcom,
      "INTLCMJ000000001" => :intelcom,
      "SBAAAAAAAAAAAA001" => :shipbob,
      "PG0000000001CA" => :passport,
      "H0ABCD0000000001" => :passport,
      "DG00000000001" => :pro_carrier,
      "0-00000000000000001" => :asendia_usa,
      "EPG000000000000001" => :epost_global,
      "MPL00000000001" => :mayple,
      "MPL0000000000001" => :mayple,
      "61290000000000000001" => :fedex,
      "74890000000000000001" => :fedex,
    }.each do |number, courier_code|
      assert_equal courier_code, TrackingNumber.new(number).courier_code, number
    end
  end

  should "keep the carrier of numbers upstream already recognizes" do
    {
      "GFUS00000000000001" => :gofo,
      "1Z879E930346834440" => :ups,
      "9400111206206406260787" => :usps,
      "TBA000000000000" => :amazon,
      "0073938000549297" => :canada_post,
    }.each do |number, courier_code|
      assert_equal courier_code, TrackingNumber.new(number).courier_code, number
    end
  end

  should "return the national post's code for an S10 number from a mapped country, and s10 otherwise" do
    assert_equal :royal_mail, TrackingNumber.new("RB123456785GB").courier_code
    assert_equal "Royal Mail Group plc", TrackingNumber.new("RB123456785GB").courier_name
    assert_equal :s10, TrackingNumber.new("RB123456785CV").courier_code
    assert_equal :s10, TrackingNumber.new("RB123456785US").courier_code
  end

  should "list every courier code the gem can return" do
    codes = TrackingNumber.courier_codes

    assert_includes codes, :s10
    assert_includes codes, :royal_mail
    assert_includes codes, :posten_norge
    assert_includes codes, :dhl_ecommerce
    assert_includes codes, :ups
    assert_equal codes.uniq, codes
  end
end
