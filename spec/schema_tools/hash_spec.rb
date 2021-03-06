require 'spec_helper'

class Client
  attr_accessor :first_name, :last_name, :addresses, :id
  end

describe SchemaTools::Hash do

  context 'from_schema' do
    let(:client){Client.new}
    before :each do
      client.first_name = 'Peter'
      client.last_name = 'Paul'
      client.id = 'SomeID'
    end
    after :each do
      SchemaTools::Reader.registry_reset
    end

    it 'should return hash' do
      hash = SchemaTools::Hash.from_schema(client)
      hash['client']['last_name'].should == 'Paul'
    end

    it 'should use custom schema path' do
      custom_path = File.expand_path('../../fixtures', __FILE__)
      hash = SchemaTools::Hash.from_schema(client, path: custom_path)
      hash['client']['last_name'].should == 'Paul'
    end

    it 'should use custom schema' do
      hash = SchemaTools::Hash.from_schema(client, class_name: :contact)
      hash['contact']['last_name'].should == 'Paul'
    end

    it 'should use only give fields' do
      hash = SchemaTools::Hash.from_schema(client, fields: ['id', 'last_name'])
      hash['client'].keys.length.should == 2
      hash['client']['last_name'].should == client.last_name
      hash['client']['id'].should == client.id
      hash['client']['first_name'].should be_nil
    end
  end

  context 'with plain nested values' do

    class Lead < Client
      attr_accessor :links_clicked, :conversion
    end

    class Conversion
      attr_accessor :from, :to
    end


    let(:lead){Lead.new}
    before :each do
      lead.links_clicked = ['2012-12-12', '2012-12-15', '2012-12-16']
      conversion = Conversion.new
      conversion.from = 'whatever'
      conversion.to = 'whatever'
      lead.conversion = conversion
      @hash = SchemaTools::Hash.from_schema(lead)
    end
    after :each do
      SchemaTools::Reader.registry_reset
    end

    it 'should create array with values' do
      @hash['lead']['links_clicked'].should == lead.links_clicked
    end

    it 'should create object with values' do
      @hash['lead']['conversion']['from'].should == lead.conversion.from
      @hash['lead']['conversion']['to'].should == lead.conversion.to
    end

  end
end

