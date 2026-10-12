require 'test_helper'

class OnwardCouriersTest < Minitest::Test
  should "detect each Onward carrier through TrackingNumber.new" do
    {
      "YWE00000000000001" => :ywe,
      "YWLAX000000000001" => :ywe,
      "YW000000001" => :yanwen,
    }.each do |number, courier_code|
      assert_equal courier_code, TrackingNumber.new(number).courier_code, number
    end
  end
end
