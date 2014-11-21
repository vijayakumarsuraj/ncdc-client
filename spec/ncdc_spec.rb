require 'spec_helper'

describe 'NCDC client' do
  it 'should return a list of location categories' do
    location_categories = @client.get_locationcategories
    expect(location_categories).not_to be_empty
  end
  it 'should return details of a particular location category' do
    id = 'CITY'
    category = @client.get_locationcategory(id)
    expect(category.id).to eq(id)
  end
  it 'should return a list of locations for a given category' do
    category = 'CNTRY'
    locations = @client.get_locations('locationcategoryid' => category)
    expect(locations).not_to be_empty
  end
  it 'should return details of a particular location' do
    id = 'FIPS:CA'
    location = @client.get_location(id)
    expect(location.id).to eq(id)
  end
  it 'should return a list of stations for a given location' do
    location = 'FIPS:UK'
    stations = @client.get_stations('locationid' => location)
    expect(stations).not_to be_empty
  end
  it 'should return details of a particular station' do
    id = 'COOP:172868'
    station = @client.get_station(id)
    expect(station.id).to eq(id)
  end
  it 'should return data sets for a particular station' do
    station = @client.get_station('GHCND:CA006158350')
    datasets = station.data_sets
    expect(datasets).not_to be_empty
  end
  it 'should return data categories for a particular station' do
    station = @client.get_station('GHCND:USW00014922')
    datacategories = station.data_categories
    expect(datacategories).not_to be_empty
  end
  it 'should return data types for a particular station' do
    station = @client.get_station('GHCND:IN012070800')
    datatypes = station.data_types
    expect(datatypes).not_to be_empty
  end
  it 'should raise an error for invalid station data' do
    station = @client.request_single('stations', 'COOP:029015')
    station.delete('id')
    expect { Ncdc::Results::Station.new(station, @client) }.to raise_error(Ncdc::Error)
  end
  it 'should raise an error for invalid location data' do
    station = @client.request_single('locations', 'CITY:AO000005')
    station.delete('maxdate')
    expect { Ncdc::Results::Station.new(station, @client) }.to raise_error(Ncdc::Error)
  end
end
