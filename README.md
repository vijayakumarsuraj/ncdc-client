# NCDC Client

### Creating the client
    client = Ncdc::Client.new('<auth token>')

### Supported methods
#### Data Sets (http://www.ncdc.noaa.gov/cdo-web/webservices/v2#datasets)
    get_datasets
    get_dataset(id)

#### Data Categories (http://www.ncdc.noaa.gov/cdo-web/webservices/v2#dataCategories)
    get_datacategories
    get_datacategory(id)

#### Data Types (http://www.ncdc.noaa.gov/cdo-web/webservices/v2#dataTypes)
    get_datatypes
    get_datatype(id)

#### Location Categories (http://www.ncdc.noaa.gov/cdo-web/webservices/v2#locationCategories)
    get_locationcategories
    get_locationcategory(id)

#### Locations (http://www.ncdc.noaa.gov/cdo-web/webservices/v2#locations)
    get_locations
    get_location(id)

#### Stations (http://www.ncdc.noaa.gov/cdo-web/webservices/v2#stations)
    get_stations
    get_station(id)

#### Data (http://www.ncdc.noaa.gov/cdo-web/webservices/v2#data)
    get_data


### Stations
    id = 'GHCND:USW00014922'
    station = client.get_station(id)
    station.data_sets
    station.data_categories
    station.data_types
    station.get_data(set_id, type_id, from, to)

