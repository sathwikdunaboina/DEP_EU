/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CustomerDetailsWrapper {
    global CalculatorAPI.CustomerDetailsWrapper.Address Address;
    global CalculatorAPI.CustomerDetailsWrapper.Addresses Addresses;
    global String countryName;
    global CalculatorAPI.CustomerDetailsWrapper.CustomerDetailResponse CustomerDetailResponse;
    global CalculatorAPI.CustomerDetailsWrapper.DetailCustomer DetailCustomer;
    global CalculatorAPI.CustomerDetailsWrapper.DetailResponse DetailResponse;
    global CustomerDetailsWrapper() {

    }
global class Address {
    global String Address1;
    global String City;
    global Integer ZipCode;
    global Address() {

    }
}
global class Addresses {
    global CalculatorAPI.CustomerDetailsWrapper.Address Address;
    global Addresses() {

    }
}
global class CustomerDetailResponse {
    global CalculatorAPI.CustomerDetailsWrapper.DetailResponse DetailResponse;
    global CalculatorAPI.CustomerDetailsWrapper.Header Header;
    global CustomerDetailResponse() {

    }
}
global class DetailCustomer {
    global CalculatorAPI.CustomerDetailsWrapper.Addresses Addresses;
    global Long ChambreOfCommerce;
    global String CompanyName;
    global Integer CustomerId;
    global Integer CustomerNumber;
    global String NatureOfBusiness;
    global Integer Phone;
    global DetailCustomer() {

    }
}
global class DetailResponse {
    global CalculatorAPI.CustomerDetailsWrapper.DetailCustomer DetailCustomer;
    global Integer ErrorOccured;
    global DetailResponse() {

    }
}
global class Header {
    global String BusinessArea;
    global String CallingSystem;
    global String CompanyId;
    global String CountryCode;
    global String MarketCode;
    global String MessageDateTime;
    global Double MessageVersion;
    global CalculatorAPI.CustomerDetailsWrapper.SourceSystems SourceSystems;
    global String UserId;
    global Header() {

    }
}
global class SourceSystems {
    global String SourceSystem;
    global SourceSystems() {

    }
}
}
