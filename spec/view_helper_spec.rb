require_relative 'spec_helper'
require_relative '../app/helpers/view_helper.rb'

describe ViewHelper do
  helper = Object.new.extend ViewHelper

  describe '#simple_format' do
    it 'should wrap paragraphs in <p> tags' do
      paragraphs = "hello\n\nworld"
      expect(helper.simple_format(paragraphs))
        .to eq '<p>hello</p><p>world</p>'
    end

    it 'should turn single newlines into <br> tags' do
      expect(helper.simple_format("hello\nworld"))
        .to eq '<p>hello<br>world</p>'
    end

    it 'should handle mixed single and double newlines' do
      text1 = "hello\n\nmy name is\nMary"
      expect(helper.simple_format(text1))
        .to eq '<p>hello</p><p>my name is<br>Mary</p>'
    end
  end

  describe '#format_address' do
    address1 = {
      'address1' => '123 Canyon Road',
      'city' => 'Los Angeles',
      'zip' => '90210',
      'province_code' => 'CA'
    }

    address2 = {
      'address1' => '123 Canyon Road',
      'address2' => 'Apt 1',
      'city' => 'Los Angeles',
      'zip' => '90210',
      'province_code' => 'CA'
    }

    it 'should format an address' do
      expect(helper.format_address(address1))
        .to eq "123 Canyon Road\nLos Angeles, CA 90210"
    end

    it 'should conditionally include the `address2` field' do
      address2_field = /Apt 1/
      address1_output = helper.format_address(address1)
      address2_output = helper.format_address(address2)
      expect(address1_output).to_not match(address2_field)
      expect(address2_output).to match(address2_field)
    end
  end
end
